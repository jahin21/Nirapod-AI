from contextlib import asynccontextmanager
from collections import defaultdict, deque
from datetime import datetime, timezone
from functools import lru_cache
import ipaddress
import json
import os
import re
import socket
import threading
import time
from urllib.parse import urlparse
from urllib.request import Request, urlopen

from fastapi import FastAPI, Header, HTTPException, Request as FastAPIRequest
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, HttpUrl

from database import (
    export_all_data,
    get_profile,
    get_user_profile,
    initialize_database,
    save_report,
    save_scan,
    scan_count,
    scan_history,
    user_analytics,
    update_profile,
    update_user_profile,
    export_user_data,
    create_support_ticket,
    login_user,
    logout_session,
    register_user,
    session_user,
    search_help_articles,
    mark_notification_read,
    user_notifications,
    get_user_settings,
    database_name,
    update_user_settings,
    save_chat_message,
    chat_history,
    clear_chat_history,
    create_password_reset,
    reset_password,
)
from ml_models import DetectionModels
from chatbot import answer_question
from mailer import password_reset_email_configured, send_password_reset_email
from room_fusion import SignalEvidence, fuse_room_evidence

models = DetectionModels()
allowed_origins = [
    origin.strip()
    for origin in os.getenv(
        "NIRAPOD_ALLOWED_ORIGINS",
        "http://localhost,http://127.0.0.1",
    ).split(",")
    if origin.strip()
]


@asynccontextmanager
async def lifespan(_app):
    initialize_database()
    yield


app = FastAPI(
    title="Nirapod AI API",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_origin_regex=r"^https?://(localhost|127\.0\.0\.1)(:\d+)?$",
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

_auth_attempts = defaultdict(deque)
_auth_attempts_lock = threading.Lock()


@app.middleware("http")
async def limit_auth_attempts(request: FastAPIRequest, call_next):
    """Limit authentication abuse without penalizing successful sign-ins."""
    limited_paths = {
        "/auth/login",
        "/auth/register",
        "/auth/password-reset/request",
        "/auth/password-reset/confirm",
    }
    if request.url.path not in limited_paths:
        return await call_next(request)
    trust_proxy = os.getenv("NIRAPOD_TRUST_PROXY_HEADERS", "").lower() == "true"
    forwarded = request.headers.get("x-forwarded-for", "").split(",", 1)[0].strip()
    client_ip = (
        forwarded
        if trust_proxy and forwarded
        else (request.client.host if request.client else "unknown")
    )
    key = (client_ip, request.url.path)
    now = time.monotonic()
    with _auth_attempts_lock:
        attempts = _auth_attempts[key]
        while attempts and now - attempts[0] > 300:
            attempts.popleft()
        if len(attempts) >= 10:
            return JSONResponse(
                status_code=429,
                content={"detail": "Too many attempts. Please wait five minutes."},
                headers={"Retry-After": "300"},
            )
    response = await call_next(request)
    count_attempt = (
        request.url.path == "/auth/password-reset/request"
        or response.status_code >= 400
    )
    if count_attempt:
        with _auth_attempts_lock:
            _auth_attempts[key].append(time.monotonic())
    return response


class ScanRequest(BaseModel):
    content: str = Field(min_length=3, max_length=10000)

class AdvancedSensorReading(BaseModel):
    sensor_type: str = Field(pattern="^(thermal|directional_rf|uwb)$")
    detected: bool = False
    confidence: float = Field(default=0.0, ge=0.0, le=1.0)
    source: str = Field(default="", max_length=120)
    target_label: str = Field(default="", max_length=120)
    distance_m: float | None = Field(default=None, ge=0.0, le=1000.0)
    azimuth_deg: float | None = Field(default=None, ge=-180.0, le=180.0)
    elevation_deg: float | None = Field(default=None, ge=-90.0, le=90.0)
    temperature_c: float | None = Field(default=None, ge=-100.0, le=500.0)
    signal_dbm: float | None = Field(default=None, ge=-200.0, le=50.0)
    context_validated: bool = False

class RoomCheckRequest(BaseModel):
    reflection_detected: bool = False
    suspicious_object: bool = False
    visual_check_completed: bool = False
    network_check_completed: bool = False
    bluetooth_check_completed: bool = False
    network_findings: list[dict] = Field(default_factory=list, max_length=100)
    bluetooth_findings: list[dict] = Field(default_factory=list, max_length=100)
    advanced_readings: list[AdvancedSensorReading] = Field(default_factory=list, max_length=30)
    stage_a_result: dict = Field(default_factory=dict)
    stage_b_result: dict = Field(default_factory=dict)


class WifiSafetyRequest(BaseModel):
    ssid: str = Field(min_length=1, max_length=100)
    security: str = Field(default="Unknown", max_length=80)
    rssi: int | None = Field(default=None, ge=-127, le=0)
    frequency_mhz: int | None = Field(default=None, ge=0, le=100000)
    network_findings: list[dict] = Field(default_factory=list, max_length=254)


class ReportRequest(BaseModel):
    report_type: str = Field(min_length=2, max_length=30)
    content: str = Field(min_length=3, max_length=10000)
    details: str = Field(default="", max_length=2000)


class ProfileRequest(BaseModel):
    name: str = Field(min_length=2, max_length=100)
    email: str = Field(
        min_length=5,
        max_length=200,
        pattern=r"^[^@\s]+@[^@\s]+\.[^@\s]+$",
    )


class RegisterRequest(BaseModel):
    name: str = Field(min_length=2, max_length=100)
    email: str = Field(
        min_length=5,
        max_length=200,
        pattern=r"^[^@\s]+@[^@\s]+\.[^@\s]+$",
    )
    password: str = Field(min_length=8, max_length=200)


class LoginRequest(BaseModel):
    email: str = Field(
        min_length=5,
        max_length=200,
        pattern=r"^[^@\s]+@[^@\s]+\.[^@\s]+$",
    )
    password: str = Field(min_length=8, max_length=200)


class PasswordResetRequest(BaseModel):
    email: str = Field(
        min_length=5,
        max_length=200,
        pattern=r"^[^@\s]+@[^@\s]+\.[^@\s]+$",
    )


class PasswordResetConfirmRequest(BaseModel):
    token: str = Field(min_length=20, max_length=300)
    new_password: str = Field(min_length=8, max_length=200)


class SupportRequest(BaseModel):
    subject: str = Field(min_length=3, max_length=150)
    message: str = Field(min_length=10, max_length=5000)


class SettingsRequest(BaseModel):
    auto_scan_links: bool
    scan_notifications: bool
    wifi_scan_warning: bool
    default_browser: str = Field(pattern="^(in_app|system)$")
    save_scan_history: bool
    app_lock_mode: str = Field(pattern="^(off|pin|biometric)$")
    threat_updates: str = Field(pattern="^(automatic|manual)$")
    cloud_protection: bool
    dark_mode: bool
    text_size: str = Field(pattern="^(small|medium|large)$")
    accent_color: str = Field(pattern="^(purple|blue|green)$")
    language: str = Field(default="en", pattern="^(en|ms|bn)$")


class ChatRequest(BaseModel):
    message: str = Field(min_length=1, max_length=4000)


def bearer_token(authorization):
    if not authorization or not authorization.startswith("Bearer "):
        return None
    return authorization.removeprefix("Bearer ").strip()


def require_user(authorization):
    user = session_user(bearer_token(authorization))
    if not user:
        raise HTTPException(status_code=401, detail="Authentication required.")
    return user


@lru_cache(maxsize=512)
def public_url_intelligence(content: str):
    """Return public DNS and approximate hosting-location metadata.

    This only uses public infrastructure information. IP geolocation describes
    the hosting endpoint and must never be presented as the attacker's exact
    physical location.
    """
    candidate = content.strip()
    if "://" not in candidate:
        candidate = f"https://{candidate}"
    parsed = urlparse(candidate)
    hostname = (parsed.hostname or "").strip().lower()
    details = {
        "domain": hostname or "Unavailable",
        "ip_address": "Unavailable",
        "location": "Unavailable",
        "country": "Unavailable",
        "region": "Unavailable",
        "city": "Unavailable",
        "network_provider": "Unavailable",
        "asn": "Unavailable",
        "location_accuracy": "Approximate hosting/server location only",
        "infrastructure_role": "Website hosting endpoint",
        "destination_note": (
            "Infrastructure location does not establish the website owner's or "
            "shared place's physical location."
        ),
        "lookup_status": "unavailable",
    }
    if not hostname:
        return details
    try:
        addresses = socket.getaddrinfo(hostname, None, type=socket.SOCK_STREAM)
        public_addresses = []
        for address in addresses:
            value = address[4][0]
            parsed_ip = ipaddress.ip_address(value)
            if not parsed_ip.is_private and not parsed_ip.is_loopback:
                public_addresses.append(value)
        if not public_addresses:
            details["lookup_status"] = "private_or_unresolved"
            return details
        ip = next((value for value in public_addresses if ":" not in value), public_addresses[0])
        details["ip_address"] = ip
        request = Request(
            f"https://ipwho.is/{ip}",
            headers={"User-Agent": "NirapodAI/1.0 defensive-url-analysis"},
        )
        with urlopen(request, timeout=1.5) as response:
            payload = json.loads(response.read().decode("utf-8"))
        if payload.get("success") is False:
            details["lookup_status"] = "dns_only"
            return details
        connection = payload.get("connection") or {}
        details.update({
            "country": payload.get("country") or "Unavailable",
            "region": payload.get("region") or "Unavailable",
            "city": payload.get("city") or "Unavailable",
            "network_provider": connection.get("isp") or connection.get("org") or "Unavailable",
            "asn": str(connection.get("asn") or "Unavailable"),
            "lookup_status": "complete",
        })
        provider_text = details["network_provider"].lower()
        if hostname == "share.google" or hostname.endswith(".share.google"):
            details["infrastructure_role"] = (
                "Google short-link endpoint; not the shared content or place"
            )
            details["destination_note"] = (
                "This country belongs to Google's short-link infrastructure. "
                "The destination's real-world country cannot be inferred from this IP."
            )
        elif any(name in provider_text for name in (
            "sucuri", "cloudflare", "akamai", "fastly", "incapsula", "imperva"
        )):
            details["infrastructure_role"] = (
                "Security/CDN endpoint; not the organisation's physical location"
            )
            details["destination_note"] = (
                "This country belongs to a CDN or security endpoint, not necessarily "
                "the organisation or content being viewed."
            )
        location_parts = [
            value for value in (details["city"], details["region"], details["country"])
            if value != "Unavailable"
        ]
        details["location"] = ", ".join(location_parts) or "Unavailable"
        if hostname == "share.google" or hostname.endswith(".share.google"):
            details["location"] = (
                "Not applicable — Google short-link infrastructure"
            )
    except (OSError, ValueError, json.JSONDecodeError):
        details["lookup_status"] = (
            "dns_only" if details["ip_address"] != "Unavailable" else "unavailable"
        )
    return details


def _is_http_url(value: str) -> bool:
    parsed = urlparse(value.strip())
    return parsed.scheme.lower() in {"http", "https"} and bool(parsed.hostname)


def _crc16_ccitt_false(value: str) -> str:
    crc = 0xFFFF
    for byte in value.encode("utf-8"):
        crc ^= byte << 8
        for _ in range(8):
            crc = (((crc << 1) ^ 0x1021) & 0xFFFF) if crc & 0x8000 else ((crc << 1) & 0xFFFF)
    return f"{crc:04X}"


def _valid_emv_payment_qr(payload: str) -> bool:
    value = payload.strip()
    if not value.startswith(("000201", "000202")) or len(value) < 16:
        return False
    if value[-8:-4] != "6304":
        return False
    index = 0
    while index < len(value):
        if index + 4 > len(value) or not value[index:index + 4].isdigit():
            return False
        length = int(value[index + 2:index + 4])
        index += 4 + length
        if index > len(value):
            return False
    return index == len(value) and _crc16_ccitt_false(value[:-4]) == value[-4:].upper()


def predict_qr_payload(content: str):
    value = content.strip()
    if not value:
        raise ValueError("QR code content is empty.")
    if _is_http_url(value):
        return models.predict_url(value)

    embedded_url = re.search(r"https?://[^\s]+", value, flags=re.IGNORECASE)
    if embedded_url:
        return models.predict_url(embedded_url.group(0))

    if value.startswith(("000201", "000202")):
        if _valid_emv_payment_qr(value):
            return (
                "safe",
                8,
                0.96,
                [
                    "Valid EMV payment QR structure and checksum.",
                    "The QR payload is intact; confirm the merchant name and amount before paying.",
                ],
            )
        return (
            "suspicious",
            68,
            0.92,
            [
                "Payment QR structure or checksum is invalid.",
                "Do not pay until the merchant provides a verified replacement code.",
            ],
        )

    message_prediction = models.predict_message(value)
    if message_prediction[0] == "dangerous" or message_prediction[1] >= 45:
        return message_prediction
    return (
        "safe",
        min(int(message_prediction[1]), 20),
        max(float(message_prediction[2]), 0.75),
        [
            "QR contains non-website data and no strong phishing indicators were detected.",
            "Verify the displayed action or recipient before continuing.",
        ],
    )


def prediction_response(scan_type, content, prediction, user_id=None):
    classification, risk_score, confidence, reasons = prediction
    scan_id = save_scan(
        scan_type,
        content,
        classification,
        risk_score,
        confidence,
        reasons,
        user_id,
    )
    response = {
        "id": scan_id,
        "scan_type": scan_type,
        "content": content,
        "classification": classification,
        "risk_score": risk_score,
        "confidence": confidence,
        "reasons": reasons,
        "model_version": models.model_version,
        "model_source": models.model_source,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "limitations": [
            "Automated analysis can miss new or deliberately disguised threats.",
            "No threat-database match is not proof that content is safe.",
        ],
        "recommendation": (
            "Do not touch a suspected device. Leave the room, preserve evidence, contact hotel management, and notify local authorities."
            if scan_type == "hidden_camera" and classification != "safe"
            else "No indicators were reported, but this check cannot certify that the room is camera-free. Remain observant."
            if scan_type == "hidden_camera"
            else
            "Do not open the link or share personal information."
            if classification == "dangerous"
            else "Verify the sender or destination before continuing."
            if classification == "suspicious"
            else "Provide more meaningful context, a complete message, or a valid destination for assessment."
            if classification == "inconclusive"
            else "No strong threat indicators were detected. Continue carefully."
        ),
    }
    if scan_type in {"url", "qr"} and _is_http_url(content):
        response["url_intelligence"] = public_url_intelligence(content)
    return response


@app.get("/health")
def health():
    return {
        "status": "ok",
        "api_version": 14,
        "chatbot_version": "full-localization-v6",
        "models": ["url-hybrid", "message-nlp"],
        "model_version": models.model_version,
        "model_source": models.model_source,
        "database": database_name(),
        "google_safe_browsing": (
            "configured"
            if os.getenv("GOOGLE_SAFE_BROWSING_API_KEY")
            else "not_configured"
        ),
        "chatbot": "openai" if os.getenv("OPENAI_API_KEY") else "local",
        "password_reset_email": (
            "configured" if password_reset_email_configured() else "not_configured"
        ),
    }


@app.post("/auth/register")
def register(request: RegisterRequest):
    try:
        return register_user(
            request.name.strip(),
            request.email.strip(),
            request.password,
        )
    except ValueError as error:
        raise HTTPException(status_code=409, detail=str(error)) from error


@app.post("/auth/login")
def login(request: LoginRequest):
    try:
        return login_user(request.email.strip(), request.password)
    except ValueError as error:
        raise HTTPException(status_code=401, detail=str(error)) from error


@app.post("/auth/password-reset/request")
def request_password_reset(request: PasswordResetRequest):
    if not password_reset_email_configured():
        raise HTTPException(
            status_code=503,
            detail="Password recovery email is not configured on this server.",
        )
    token = create_password_reset(request.email.strip())
    if token and not send_password_reset_email(request.email.strip(), token):
        raise HTTPException(
            status_code=503,
            detail="Password recovery email is temporarily unavailable.",
        )
    return {
        "message": (
            "If an account exists for that email, a single-use reset token "
            "has been sent. It expires in 30 minutes."
        )
    }


@app.post("/auth/password-reset/confirm")
def confirm_password_reset(request: PasswordResetConfirmRequest):
    try:
        reset_password(request.token.strip(), request.new_password)
    except ValueError as error:
        raise HTTPException(status_code=400, detail=str(error)) from error
    return {"message": "Password reset successfully. Sign in with your new password."}


@app.get("/auth/me")
def me(authorization: str | None = Header(default=None)):
    user = session_user(bearer_token(authorization))
    if not user:
        raise HTTPException(status_code=401, detail="Authentication required.")
    return user


@app.post("/auth/logout")
def logout(authorization: str | None = Header(default=None)):
    token = bearer_token(authorization)
    if token:
        logout_session(token)
    return {"status": "signed_out"}


@app.post("/scan/url")
def scan_url(request: ScanRequest, authorization: str | None = Header(default=None)):
    user = require_user(authorization)
    try:
        return prediction_response(
            "url",
            request.content,
            models.predict_url(request.content),
            user["id"],
        )
    except ValueError as error:
        raise HTTPException(status_code=400, detail=str(error)) from error


@app.post("/scan/message")
def scan_message(request: ScanRequest, authorization: str | None = Header(default=None)):
    user = require_user(authorization)
    return prediction_response(
        "message",
        request.content,
        models.predict_message(request.content),
        user["id"],
    )

@app.post("/scan/{scan_type}")
def scan_typed_content(
    scan_type: str,
    request: ScanRequest,
    authorization: str | None = Header(default=None),
):
    if scan_type not in {"text", "sms", "email", "ocr", "qr"}:
        raise HTTPException(status_code=404, detail="Unknown scan type.")
    user = require_user(authorization)
    try:
        prediction = (
            predict_qr_payload(request.content)
            if scan_type == "qr"
            else models.predict_message(request.content)
        )
        return prediction_response(
            scan_type,
            request.content,
            prediction,
            user["id"],
        )
    except ValueError as error:
        raise HTTPException(status_code=400, detail=str(error)) from error

@app.post("/wifi-safety-check")
def wifi_safety_check(
    request: WifiSafetyRequest,
    authorization: str | None = Header(default=None),
):
    user = require_user(authorization)
    security = request.security.strip() or "Unknown"
    normalized = security.lower()
    reasons = [f"Connected network: {request.ssid}", f"Security: {security}"]

    if normalized == "open" or "wep" in normalized:
        classification, risk_score, confidence = "dangerous", 82, 0.95
        reasons.append("This Wi-Fi uses no encryption or obsolete WEP protection")
        reasons.append("Do not enter passwords, banking details, or other sensitive information")
    elif "wpa3" in normalized or "owe" in normalized:
        classification, risk_score, confidence = "safe", 10, 0.93
        reasons.append("Modern Wi-Fi encryption is active")
        reasons.append("Encryption protects the wireless link but cannot guarantee that every device or website is trustworthy")
    elif "wpa2" in normalized or "wpa/" in normalized:
        classification, risk_score, confidence = "safe", 22, 0.90
        reasons.append("Recognized encrypted Wi-Fi protection is active")
        reasons.append("Use HTTPS and avoid sharing sensitive data if you do not trust the network owner")
    else:
        classification, risk_score, confidence = "suspicious", 48, 0.70
        reasons.append("Android could not confirm the Wi-Fi encryption type")
        reasons.append("Review the network details on the phone before sending sensitive information")

    if request.rssi is not None:
        reasons.append(f"Signal strength reported by Android: {request.rssi} dBm")
    reasons.append(
        f"{len(request.network_findings)} device(s) exposed one or more checked local-network ports; this is inventory information, not proof of compromise"
    )
    return prediction_response(
        "wifi",
        request.ssid,
        (classification, risk_score, confidence, reasons),
        user["id"],
    )


@app.post("/room-safety-check")
def room_safety_check(
    request: RoomCheckRequest,
    authorization: str | None = Header(default=None),
):
    user = require_user(authorization)
    strong_network = []
    camera_names = ("camera", "ipcam", "webcam", "nvr", "dvr", "arlo", "ring", "wyze", "tapo", "hikvision", "dahua", "reolink")

    for item in request.network_findings:
        ports = {int(port) for port in item.get("ports", []) if str(port).isdigit()}
        if ports.intersection({554, 8554}):
            strong_network.append(f"{item.get('ip', 'Nearby device')} exposes a camera-streaming service")

    named_bluetooth = []
    for item in request.bluetooth_findings:
        name = str(item.get("name", "")).strip()
        if name and any(word in name.lower() for word in camera_names):
            named_bluetooth.append(f"Nearby device name resembles camera equipment: {name}")

    visual_evidence = []
    if request.reflection_detected:
        visual_evidence.append("Possible lens reflection observed")
    if request.suspicious_object:
        visual_evidence.append("Suspicious object, pinhole, wiring, or placement observed")

    stage_a_confident = request.stage_a_result.get("confidentKnownSafe") is True
    stage_a_confidence = float(request.stage_a_result.get("confidence", 0.0) or 0.0)
    stage_a_label = str(request.stage_a_result.get("label", "unclassified"))
    stage_b_positive = request.stage_b_result.get("positive") is True and not stage_a_confident
    if stage_b_positive:
        visual_evidence.append("Stage B found a compact reflection or locally contrasted pinhole-like pattern")

    signals = [
        SignalEvidence(
            "known_safe_classifier",
            "Stage A ordinary-device classifier",
            False,
            stage_a_confidence,
            "This only classifies visual resemblance to an ordinary device; it cannot prove that the object or room is safe.",
            f"Confident ordinary {stage_a_label}" if stage_a_confident else "Unclassified; routed to visual heuristics",
            "visual",
        ),
        SignalEvidence(
            "visual_heuristic",
            "Visual heuristic check",
            bool(visual_evidence),
            0.68 if len(visual_evidence) > 1 else 0.55 if visual_evidence else 0.0,
            "Reflection and pinhole patterns can come from ordinary electronics, shadows, or shiny materials and are not conclusive.",
            "; ".join(visual_evidence) if visual_evidence else "No hit reported",
            "visual",
        ),
        SignalEvidence(
            "network_service",
            "Network camera-service check",
            bool(strong_network),
            0.68 if strong_network else 0.0,
            "An exposed streaming port can belong to an authorized camera or unrelated service.",
            "; ".join(strong_network[:3]) if strong_network else "No hit reported",
            "network_service",
        ),
        SignalEvidence(
            "bluetooth_name",
            "Bluetooth name check",
            bool(named_bluetooth),
            0.35 if named_bluetooth else 0.0,
            "Bluetooth names can be spoofed or misleading and are not conclusive.",
            "; ".join(named_bluetooth[:3]) if named_bluetooth else "No hit reported",
            "bluetooth",
        ),
    ]

    thermal_readings = []
    rf_readings = []
    uwb_readings = []
    for reading in request.advanced_readings:
        if not reading.detected or reading.confidence < 0.60 or not reading.source.strip():
            continue
        if reading.sensor_type == "thermal":
            detail = "Thermal accessory reported a localized heat anomaly"
            if reading.temperature_c is not None:
                detail += f" ({reading.temperature_c:.1f} C)"
            thermal_readings.append((reading, detail))
        elif reading.sensor_type == "directional_rf":
            detail = "Directional RF accessory reported a localized radio-frequency anomaly"
            if reading.azimuth_deg is not None:
                detail += f" near {reading.azimuth_deg:.0f} degrees relative to the accessory"
            rf_readings.append((reading, detail))
        elif reading.sensor_type == "uwb" and "camera" in reading.target_label.lower():
            detail = "UWB ranged a participating device identified by the accessory as camera equipment"
            if reading.distance_m is not None:
                detail += f" at approximately {reading.distance_m:.2f} m"
            uwb_readings.append((reading, detail))

    max_thermal = max((item[0].confidence for item in thermal_readings), default=0.0)
    thermal_decisive = any(
        reading.confidence >= 0.90 and reading.context_validated
        for reading, _ in thermal_readings
    )
    signals.extend([
        SignalEvidence(
            "thermal",
            "Thermal accessory check",
            bool(thermal_readings),
            max_thermal,
            "Heat can come from normal electronics; thermal evidence requires compatible calibrated hardware and context.",
            "; ".join(detail for _, detail in thermal_readings[:3]) if thermal_readings else "No hit reported",
            "thermal",
            thermal_decisive,
        ),
        SignalEvidence(
            "directional_rf",
            "Directional RF check",
            bool(rf_readings),
            max((item[0].confidence for item in rf_readings), default=0.0),
            "Radio signals may come from legitimate nearby devices and require specialist directional hardware.",
            "; ".join(detail for _, detail in rf_readings[:3]) if rf_readings else "No hit reported",
            "directional_rf",
        ),
        SignalEvidence(
            "uwb",
            "UWB participating-device check",
            bool(uwb_readings),
            max((item[0].confidence for item in uwb_readings), default=0.0),
            "UWB detects only compatible participating devices and cannot identify an ordinary hidden camera.",
            "; ".join(detail for _, detail in uwb_readings[:3]) if uwb_readings else "No hit reported",
            "uwb",
        ),
    ])

    checks_completed = sum((
        request.visual_check_completed,
        request.network_check_completed,
        request.bluetooth_check_completed,
        bool(request.advanced_readings),
    ))
    fusion = fuse_room_evidence(signals, checks_completed)
    reasons = [fusion["summary"]]
    reasons.extend(signal.evidence for signal in signals if signal.detected)
    reasons.append("Every signal has limitations and must be interpreted as supporting evidence.")
    response = prediction_response(
        "hidden_camera",
        "Hotel room hidden-camera safety check",
        (
            fusion["classification"],
            fusion["risk_score"],
            fusion["confidence"],
            reasons,
        ),
        user["id"],
    )
    response["signal_details"] = fusion["signals"]
    return response


@app.get("/history")
def history(
    limit: int = 50,
    offset: int = 0,
    scan_type: str | None = None,
    search: str | None = None,
    authorization: str | None = Header(default=None),
):
    user = require_user(authorization)
    type_groups = {
        "url": ("url",),
        "qr": ("qr",),
        "message": ("message", "text", "sms", "email"),
        "ocr": ("ocr",),
        "room": ("hidden_camera",),
    }
    scan_types = type_groups.get(scan_type) if scan_type else None
    return {
        "items": scan_history(
            max(1, min(limit, 1000)),
            user_id=user["id"],
            offset=max(0, offset),
            scan_types=scan_types,
            search=search,
        ),
        "total": scan_count(user["id"], scan_types=scan_types, search=search),
    }


@app.get("/analytics")
def analytics(
    days: int = 30,
    authorization: str | None = Header(default=None),
):
    user = require_user(authorization)
    return user_analytics(user["id"], days)


@app.post("/reports")
def report(
    request: ReportRequest,
    authorization: str | None = Header(default=None),
):
    user = require_user(authorization)
    report_id = save_report(
        request.report_type,
        request.content,
        request.details,
        user["id"],
    )
    return {"id": report_id, "status": "submitted"}


@app.get("/profile")
def profile(authorization: str | None = Header(default=None)):
    user = require_user(authorization)
    return get_user_profile(user["id"])


@app.put("/profile")
def save_profile(
    request: ProfileRequest,
    authorization: str | None = Header(default=None),
):
    user = require_user(authorization)
    try:
        return update_user_profile(
            user["id"],
            request.name.strip(),
            request.email.strip(),
        )
    except ValueError as error:
        raise HTTPException(status_code=409, detail=str(error)) from error


@app.get("/export")
def export_data(authorization: str | None = Header(default=None)):
    user = require_user(authorization)
    return export_user_data(user["id"])


@app.get("/settings")
def settings(authorization: str | None = Header(default=None)):
    user = require_user(authorization)
    return get_user_settings(user["id"])


@app.put("/settings")
def save_settings(
    request: SettingsRequest,
    authorization: str | None = Header(default=None),
):
    user = require_user(authorization)
    return update_user_settings(user["id"], request.model_dump())


@app.get("/chat/history")
def get_chat_history(authorization: str | None = Header(default=None)):
    user = require_user(authorization)
    return {"items": chat_history(user["id"])}


@app.delete("/chat/history")
def delete_chat_history(authorization: str | None = Header(default=None)):
    user = require_user(authorization)
    clear_chat_history(user["id"])
    return {"status": "cleared"}


@app.post("/chat")
def chat(
    request: ChatRequest,
    authorization: str | None = Header(default=None),
):
    user = require_user(authorization)
    question = request.message.strip()
    previous = chat_history(user["id"], limit=20)
    normalized_question = question.lower().strip(" .,!?'\"")
    small_talk = normalized_question in {
        "hi", "hello", "hey", "hiya", "good morning", "good afternoon",
        "good evening", "how are you", "how are you doing", "how's it going",
        "how are u", "how r u", "hows u",
        "who are you", "what is your name", "what's your name", "thanks",
        "thank you", "bye", "goodbye", "help", "what can you do",
    }
    articles = (
        []
        if small_talk or len(normalized_question) < 4
        else search_help_articles(query=question[:200])
    )
    knowledge = "\n\n".join(
        f"{item['title']}: {item['content']}" for item in articles[:5]
    )
    save_chat_message(user["id"], "user", question)
    language = get_user_settings(user["id"]).get("language", "en")
    answer, provider = answer_question(
        user["id"], question, previous, knowledge, language
    )
    message_id = save_chat_message(
        user["id"], "assistant", answer, provider
    )
    return {
        "id": message_id,
        "role": "assistant",
        "content": answer,
        "provider": provider,
    }


@app.get("/help/articles")
def help_articles(q: str = "", category: str = "all"):
    return {
        "items": search_help_articles(
            query=q.strip()[:200],
            category=category.strip().lower(),
        )
    }


@app.post("/help/tickets")
def support_ticket(
    request: SupportRequest,
    authorization: str | None = Header(default=None),
):
    user = require_user(authorization)
    return create_support_ticket(
        user["id"],
        request.subject.strip(),
        request.message.strip(),
    )


@app.get("/notifications")
def notifications(authorization: str | None = Header(default=None)):
    user = require_user(authorization)
    return {"items": user_notifications(user["id"])}


@app.put("/notifications/read-all")
def read_all_notifications(authorization: str | None = Header(default=None)):
    user = require_user(authorization)
    mark_notification_read(user["id"])
    return {"status": "updated"}


@app.put("/notifications/{notification_id}/read")
def read_notification(
    notification_id: int,
    authorization: str | None = Header(default=None),
):
    user = require_user(authorization)
    mark_notification_read(user["id"], notification_id)
    return {"status": "updated"}
