import ipaddress
import math
import os
import re
import socket
import json
from pathlib import Path
from functools import lru_cache
from concurrent.futures import ThreadPoolExecutor, TimeoutError
from difflib import SequenceMatcher
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import urlopen
from urllib.parse import urlparse

from sklearn.ensemble import RandomForestClassifier
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline

try:
    import joblib
except ImportError:  # scikit-learn currently installs joblib transitively.
    joblib = None


MODEL_DIR = Path(__file__).resolve().parent / "models"
MODEL_MANIFEST = MODEL_DIR / "model_manifest.json"

SUSPICIOUS_WORDS = (
    "login",
    "verify",
    "secure",
    "account",
    "update",
    "bank",
    "password",
    "wallet",
    "confirm",
)

SHORTENERS = ("bit.ly", "tinyurl.com", "t.co", "goo.gl", "ow.ly")

TRUSTED_DOMAINS = {
    "google.com",
    "microsoft.com",
    "apple.com",
    "github.com",
    "wikipedia.org",
    "flutter.dev",
    "upm.edu.my",
    "maybank2u.com.my",
}

KNOWN_BRANDS = {
    "google": "google.com",
    "microsoft": "microsoft.com",
    "apple": "apple.com",
    "amazon": "amazon.com",
    "paypal": "paypal.com",
    "maybank": "maybank2u.com.my",
    "facebook": "facebook.com",
    "instagram": "instagram.com",
    "whatsapp": "whatsapp.com",
}

HIGH_RISK_TLDS = {
    "click", "top", "xyz", "zip", "mov", "work", "support", "country",
    "gq", "tk", "ml", "cf", "ga",
}


def normalize_url(value):
    value = value.strip()
    if not value.startswith(("http://", "https://")):
        value = f"https://{value}"
    return value


def url_features(value):
    value = normalize_url(value)
    parsed = urlparse(value)
    host = parsed.hostname or ""
    lowered = value.lower()
    try:
        ipaddress.ip_address(host)
        uses_ip = 1
    except ValueError:
        uses_ip = 0
    return [
        len(value),
        len(host),
        value.count("."),
        value.count("-"),
        value.count("@"),
        value.count("="),
        value.count("%"),
        value.count("/"),
        host.count("."),
        uses_ip,
        int(parsed.scheme != "https"),
        sum(word in lowered for word in SUSPICIOUS_WORDS),
        int(any(shortener in host for shortener in SHORTENERS)),
        int("xn--" in host),
        int(len(parsed.query) > 40),
    ]


def registered_domain(host):
    parts = host.lower().strip(".").split(".")
    if len(parts) <= 2:
        return ".".join(parts)
    # Covers the common country-code pattern used by this project (for example,
    # example.com.my). A production deployment should use the Public Suffix List.
    if len(parts[-1]) == 2 and parts[-2] in {"com", "net", "org", "edu", "gov"}:
        return ".".join(parts[-3:])
    return ".".join(parts[-2:])


def shannon_entropy(value):
    if not value:
        return 0.0
    return -sum(
        (value.count(character) / len(value))
        * math.log2(value.count(character) / len(value))
        for character in set(value)
    )


@lru_cache(maxsize=1024)
def domain_resolves(host):
    if not host:
        return False
    executor = ThreadPoolExecutor(max_workers=1)
    future = executor.submit(socket.getaddrinfo, host, 443)
    try:
        future.result(timeout=0.8)
        return True
    except (socket.gaierror, OSError, TimeoutError):
        return False
    finally:
        executor.shutdown(wait=False, cancel_futures=True)


def google_safe_browsing_check(url):
    api_key = os.getenv("GOOGLE_SAFE_BROWSING_API_KEY", "").strip()
    if not api_key:
        return None
    query = urlencode([("urls", url), ("key", api_key)])
    try:
        with urlopen(
            f"https://safebrowsing.googleapis.com/v5/urls:search?{query}",
            timeout=4,
        ) as response:
            data = json.loads(response.read().decode("utf-8"))
        return data.get("threats", [])
    except (HTTPError, URLError, TimeoutError, ValueError):
        return None


URL_SAMPLES = [
    ("https://google.com", 0),
    ("https://wikipedia.org/wiki/Phishing", 0),
    ("https://www.microsoft.com/en-us/security", 0),
    ("https://github.com/openai", 0),
    ("https://upm.edu.my", 0),
    ("https://maybank2u.com.my", 0),
    ("https://apple.com/my", 0),
    ("https://amazon.com/orders", 0),
    ("https://support.google.com/accounts", 0),
    ("https://docs.flutter.dev", 0),
    ("http://192.168.1.8/bank/login", 1),
    ("http://verify-account-now.example.net/login", 1),
    ("https://secure-paypal-confirm.example.org", 1),
    ("http://amaz0n-account-update.example.com", 1),
    ("https://bit.ly/free-bank-reward", 1),
    ("http://185.199.110.153/verify/password", 1),
    ("https://xn--microsft-5za.example/login", 1),
    ("http://account-security-alert.example.xyz", 1),
    ("https://bank-wallet-confirm.example.top/?session=reset-password", 1),
    ("http://free-prize-now.example.click/login", 1),
]

MESSAGE_SAMPLES = [
    ("Your parcel will arrive tomorrow between 2 PM and 5 PM.", 0),
    ("Your appointment is confirmed for Monday.", 0),
    ("The meeting room has changed to Block B.", 0),
    ("Your verification code is 392104. Do not share it.", 0),
    ("Thank you for your payment. View your receipt in the official app.", 0),
    ("Class is cancelled today due to heavy rain.", 0),
    ("Your account is locked! Verify now using this link.", 1),
    ("URGENT: Send your OTP immediately to prevent suspension.", 1),
    ("Congratulations, you won an iPhone. Claim your prize now!", 1),
    ("Police case registered against you. Pay today to avoid arrest.", 1),
    ("Bank security alert: confirm password and card information.", 1),
    ("Your parcel failed. Pay a small redelivery fee at this link.", 1),
    ("Investment guaranteed 300% return. Join our WhatsApp group.", 1),
    ("Final warning! Your wallet will be disabled within one hour.", 1),
    ("Click here to receive your government cash assistance.", 1),
    ("We detected unusual activity. Login at secure-account-update now.", 1),
]


class DetectionModels:
    def __init__(self):
        self.model_version = "embedded-baseline-v1"
        self.model_source = "embedded_fallback"
        self.url_model = RandomForestClassifier(
            n_estimators=160,
            max_depth=8,
            random_state=42,
            class_weight="balanced",
        )
        self.url_model.fit(
            [url_features(url) for url, _ in URL_SAMPLES],
            [label for _, label in URL_SAMPLES],
        )
        self.message_model = Pipeline(
            [
                (
                    "tfidf",
                    TfidfVectorizer(
                        lowercase=True,
                        ngram_range=(1, 2),
                        min_df=1,
                        sublinear_tf=True,
                    ),
                ),
                (
                    "classifier",
                    LogisticRegression(
                        random_state=42,
                        class_weight="balanced",
                    ),
                ),
            ]
        )
        self.message_model.fit(
            [text for text, _ in MESSAGE_SAMPLES],
            [label for _, label in MESSAGE_SAMPLES],
        )
        self._load_candidate_models()

    def _load_candidate_models(self):
        """Load validated offline artifacts while preserving baseline fallback."""
        if joblib is None or not MODEL_MANIFEST.exists():
            return
        try:
            manifest = json.loads(MODEL_MANIFEST.read_text(encoding="utf-8"))
            if manifest.get("status") != "promoted":
                return
            loaded_models = {}
            for key, attribute in (
                ("url_model", "url_model"),
                ("message_model", "message_model"),
            ):
                relative = manifest.get(key)
                if not relative:
                    continue
                artifact = (MODEL_DIR / relative).resolve()
                if MODEL_DIR.resolve() not in artifact.parents:
                    raise ValueError("Model artifact must remain inside the models directory")
                loaded_models[attribute] = joblib.load(artifact)
            if not loaded_models:
                return
            for attribute, model in loaded_models.items():
                setattr(self, attribute, model)
            self.model_version = str(manifest["model_version"])
            self.model_source = "offline_validated_artifact:" + ",".join(
                loaded_models
            )
        except Exception:
            # A corrupt or incompatible candidate must never prevent startup.
            self.model_version = "embedded-baseline-v1"
            self.model_source = "embedded_fallback"

    @staticmethod
    def _classification(risk):
        if risk >= 70:
            return "dangerous"
        if risk >= 35:
            return "suspicious"
        return "safe"

    def predict_url(self, value):
        normalized = normalize_url(value)
        probability = float(self.url_model.predict_proba([url_features(normalized)])[0][1])
        parsed = urlparse(normalized)
        host = (parsed.hostname or "").lower().strip(".")
        domain = registered_domain(host)
        primary_label = domain.split(".")[0] if domain else ""
        host_labels = [label for label in host.split(".") if label]
        lowered = normalized.lower()
        reasons = []
        # This model is trained from a deliberately small teaching dataset.
        # Its probability is supporting evidence, not an authoritative
        # reputation verdict. Never let it mark an otherwise ordinary URL as
        # suspicious without an observable risk indicator.
        risk_floors = [min(round(probability * 100), 20)]
        verified_safe = domain in TRUSTED_DOMAINS

        try:
            ipaddress.ip_address(host)
            host_is_ip = True
        except ValueError:
            host_is_ip = False
        valid_public_domain = bool(
            host
            and "." in host
            and re.fullmatch(
            r"(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}",
            host,
            )
        )
        if not valid_public_domain and not host_is_ip:
            return (
                "inconclusive",
                0,
                0.0,
                ["The destination is not a valid public website address"],
            )
        if parsed.scheme != "https":
            risk_floors.append(45)
            reasons.append("The website does not use an encrypted HTTPS connection")
        if host_is_ip:
            risk_floors.append(75)
            reasons.append("The link uses an IP address instead of a recognizable domain")
        matched = [word for word in SUSPICIOUS_WORDS if word in lowered]
        if matched:
            risk_floors.append(42)
            reasons.append(f"Suspicious terms detected: {', '.join(matched[:3])}")
        if host.count(".") >= 3:
            risk_floors.append(45)
            reasons.append("The domain contains an unusually high number of subdomains")
        if any(shortener in host for shortener in SHORTENERS):
            risk_floors.append(55)
            reasons.append("The destination is hidden behind a URL-shortening service")
        if host.startswith("xn--") or ".xn--" in host:
            risk_floors.append(75)
            reasons.append("The domain uses internationalized encoding that can hide look-alike characters")
        if domain.rsplit(".", 1)[-1] in HIGH_RISK_TLDS:
            risk_floors.append(48)
            reasons.append("The domain uses a top-level domain frequently abused by disposable sites")

        label_entropy = shannon_entropy(primary_label)
        longest_consonants = max(
            (len(group) for group in re.findall(r"[^aeiou\d\W]+", primary_label)),
            default=0,
        )
        if (
            len(primary_label) >= 11
            and label_entropy >= 3.1
            and longest_consonants >= 4
        ):
            risk_floors.append(52)
            reasons.append("The domain name has a highly random, machine-generated pattern")

        for brand, official_domain in KNOWN_BRANDS.items():
            candidate_labels = [
                part.translate(str.maketrans({"0": "o", "1": "l", "3": "e", "5": "s"}))
                for label in host_labels
                for part in {label, *label.split("-")}
                if part
            ]
            suspicious_label = next(
                (
                    label
                    for label in candidate_labels
                    if brand in label
                    or (
                        len(label) >= 5
                        and SequenceMatcher(None, label, brand).ratio() >= 0.78
                    )
                ),
                None,
            )
            if domain != official_domain and suspicious_label:
                risk_floors.append(78)
                reasons.append(
                    f"The domain resembles {brand.title()} but is not its official domain"
                )
                break

        resolves = domain_resolves(host) if host and "." in host else False
        if not resolves:
            risk_floors.append(62)
            reasons.append("The domain has no reachable DNS record and could not be verified")

        google_threats = google_safe_browsing_check(normalized)
        if google_threats:
            risk_floors.append(98)
            threat_types = sorted({
                threat
                for item in google_threats
                for threat in item.get("threatTypes", [])
            })
            reasons.append(
                "Google Safe Browsing reports this URL as "
                + (", ".join(threat_types) if threat_types else "unsafe")
            )
        elif google_threats == []:
            reasons.append("No match was found in Google Safe Browsing threat lists")

        # Being unknown is also not evidence of phishing. Report the limits of
        # the scan without manufacturing a warning-level score.
        if not verified_safe and not reasons:
            risk_floors.append(18)
            reasons.extend([
                "The URL uses an encrypted HTTPS connection",
                "The public domain resolves successfully through DNS",
                "No high-risk structural phishing indicators were detected",
            ])
        elif verified_safe and not reasons:
            reasons.append("The registered domain matches a locally verified trusted service")

        risk = min(100, max(risk_floors))
        classification = self._classification(risk)
        confidence = risk / 100 if classification != "safe" else 1 - (risk / 100)
        return classification, risk, round(confidence, 4), reasons

    def predict_message(self, value):
        normalized = " ".join(value.split()).strip()
        tokens = re.findall(r"[^\W_]+", normalized, flags=re.UNICODE)
        has_url = bool(re.search(r"https?://|www\.", normalized, re.IGNORECASE))
        has_digit = bool(re.search(r"\d", normalized))
        # Random or content-free input is not evidence of safety or danger.
        # Return an honest uncertainty result instead of a confident guess.
        if (
            not normalized
            or len(normalized) < 4
            or (
                len(tokens) <= 1
                and not has_url
                and not has_digit
                and len(normalized) < 32
            )
        ):
            return (
                "inconclusive",
                0,
                0.0,
                ["Insufficient meaningful information was supplied for assessment"],
            )
        probability = float(self.message_model.predict_proba([normalized])[0][1])
        lowered = value.lower()
        reasons = []
        patterns = {
            "urgent or threatening language": (
                r"\b(urgent|warning|suspend(?:ed)?|locked|arrest|immediately|"
                r"segera|amaran|digantung|dikunci|tangkap)\b|"
                r"(জরুরি|সতর্কতা|বন্ধ|লক|গ্রেফতার)"
            ),
            "requests for passwords, OTPs, PINs, card numbers, or banking details": (
                r"\b(password|otp|pin|card number|bank(?:ing)? details|"
                r"kata laluan|nombor kad|butiran bank)\b|"
                r"(পাসওয়ার্ড|ওটিপি|পিন|কার্ড নম্বর|ব্যাংক তথ্য)"
            ),
            "prize or reward language": (
                r"\b(prize|winner|won|reward|free gift|claim reward|"
                r"hadiah|pemenang|percuma|tuntut hadiah)\b|"
                r"(পুরস্কার|বিজয়ী|উপহার|ফ্রি|দাবি করুন)"
            ),
            "a request to click, verify, or sign in": (
                r"\b(click|verify|confirm|login|sign in|follow (?:this )?link|"
                r"klik|sahkan|log masuk|pautan)\b|"
                r"(ক্লিক|যাচাই|নিশ্চিত|লগইন|লিংক)"
            ),
        }
        for reason, pattern in patterns.items():
            if re.search(pattern, lowered):
                reasons.append(f"The message contains {reason}")
        risk_floors = [min(round(probability * 100), 25)]
        indicator_count = len(reasons)
        if indicator_count == 1:
            risk_floors.append(45)
        elif indicator_count == 2:
            risk_floors.append(65)
        elif indicator_count >= 3:
            risk_floors.append(85)

        credential_request = any("passwords, OTPs" in reason for reason in reasons)
        action_request = any("click, verify" in reason for reason in reasons)
        if credential_request and action_request:
            risk_floors.append(88)

        embedded_urls = re.findall(r"https?://[^\s<>\"']+", value, flags=re.IGNORECASE)
        for embedded_url in embedded_urls[:3]:
            url_result = self.predict_url(embedded_url.rstrip(".,);]"))
            if url_result[1] >= 70:
                risk_floors.append(92)
                reasons.append("The message contains a high-risk URL")
                break
            if url_result[1] >= 35:
                risk_floors.append(68)
                reasons.append("The message contains a suspicious URL")
                break

        if not reasons:
            reasons.extend([
                "No common social-engineering phrases were detected",
                "No suspicious link was detected in the supplied content",
            ])
        risk = min(100, max(risk_floors))
        classification = self._classification(risk)
        confidence = risk / 100 if classification != "safe" else 1 - (risk / 100)
        return classification, risk, round(confidence, 4), reasons
