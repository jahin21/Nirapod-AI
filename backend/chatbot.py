import hashlib
import json
import os
import re
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

SYSTEM_INSTRUCTIONS = """
You are Nirapod Guide, a calm and accurate cybersecurity assistant.
Answer directly in clear language. You may answer broad lawful questions, but
cybersecurity guidance must remain defensive, protective, and educational. Never
help steal credentials, evade security, deploy malware, or attack systems. Never
ask for passwords, OTPs, card numbers, private keys, or recovery codes. For active
scam victims, lead with containment steps. Treat scan classifications as evidence,
not certainty. Do not call a link safe merely because it is absent from a blocklist.
""".strip()


def _local_answer(question, knowledge=""):
    lowered = question.lower().strip()
    normalized = re.sub(r"[^\w\s']", "", lowered)
    if normalized in {"hi", "hello", "hey", "hiya", "good morning", "good afternoon", "good evening"}:
        return (
            "Hi! I'm Nirapod Guide. 👋 How are you? You can chat with me normally "
            "or ask me about suspicious links, scams, account safety, or anything "
            "else you need help understanding."
        )
    if re.fullmatch(r"(?:how|hows) (?:are )?(?:you|u)(?: doing)?", normalized) or normalized in {
        "how is it going",
        "how are things",
    }:
        return (
            "I'm doing well, thanks for asking! I'm here and ready to help. "
            "How are you doing?"
        )
    if normalized in {"who are you", "what is your name", "whats your name", "what are you"}:
        return (
            "I'm Nirapod Guide, your friendly AI assistant inside Nirapod. "
            "I specialize in cybersecurity, but you can also talk to me normally "
            "and ask simple questions."
        )
    if normalized in {"thanks", "thank you", "thankyou", "thx"}:
        return "You're welcome! Let me know if there is anything else I can help with."
    if normalized in {"bye", "goodbye", "see you", "see you later"}:
        return "Goodbye! Stay safe online, and come back anytime you need help. 👋"
    if normalized in {"what can you do", "help", "how can you help me"}:
        return (
            "I can explain scan results, help you recognize scams, guide you after a "
            "security incident, answer questions about passwords and privacy, and chat "
            "about simple everyday topics. What would you like to know?"
        )
    name_match = re.fullmatch(r"(?:my name is|im|i am) ([a-z][a-z '\-]{0,40})", normalized)
    if name_match:
        return (
            f"Nice to meet you, {name_match.group(1).title()}! "
            "How can I help you today?"
        )
    if re.search(r"\b(clicked|opened|entered|gave|shared)\b.*\b(phish|scam|otp|password|link)\b", lowered):
        return (
            "Act immediately:\n"
            "1. Leave the suspicious site and do not contact the sender.\n"
            "2. From a trusted device, change the affected and reused passwords.\n"
            "3. Enable MFA and sign out other sessions.\n"
            "4. If banking information was involved, call the bank using its official number.\n"
            "5. Scan the device, preserve evidence, and report the incident.\n"
            "Never share an OTP or recovery code."
        )
    if "otp" in lowered:
        return (
            "An OTP is a secret authentication code. Never give it to a caller, support "
            "agent, friend, or anyone messaging you. If you already shared it, contact "
            "the affected service through its official app immediately."
        )
    if any(term in lowered for term in ("phishing", "suspicious link", "safe link", "url")):
        return (
            "Inspect the complete domain, not the logo. Check for misspellings, unexpected "
            "subdomains, shortened links, urgency, credential requests, and unusual domains. "
            "HTTPS does not prove legitimacy. Scan it and verify independently through the "
            "organization's official app or a manually typed address."
        )
    if any(term in lowered for term in ("password", "account security", "secure account")):
        return (
            "Use a unique password of at least 14 characters, a reputable password manager, "
            "MFA, and review active sessions and recovery methods. Never send passwords in chat."
        )
    if any(term in lowered for term in ("malware", "virus", "trojan", "spyware")):
        return (
            "Malware is software designed to harm a device, steal information, or gain "
            "unauthorized access. Disconnect an actively affected device from networks, "
            "run a reputable security scan, install updates, remove unknown applications, "
            "and change important passwords from a separate trusted device."
        )
    if "ransomware" in lowered:
        return (
            "Ransomware encrypts or steals data and demands payment. Isolate the affected "
            "device immediately, do not spread files to other systems, preserve evidence, "
            "notify the responsible security team or authorities, and restore only from a "
            "known-clean offline backup. Payment does not guarantee recovery."
        )
    if any(term in lowered for term in ("two factor", "2fa", "mfa", "authenticator")):
        return (
            "Multi-factor authentication adds another proof of identity beyond a password. "
            "An authenticator app or hardware security key is generally safer than SMS. "
            "Store recovery codes offline and never share approval prompts or codes."
        )
    if any(term in lowered for term in ("public wifi", "wi-fi", "wifi", "wireless")):
        return (
            "On public Wi-Fi, verify the network name with staff, disable automatic joining "
            "and file sharing, prefer HTTPS, avoid sensitive account changes, and use mobile "
            "data when possible. A VPN protects traffic in transit but cannot make a phishing "
            "website trustworthy."
        )
    if "vpn" in lowered:
        return (
            "A VPN encrypts traffic between your device and the VPN provider. It can reduce "
            "local network snooping, but it does not block phishing, malware, unsafe downloads, "
            "or dishonest VPN providers. Choose a reputable provider and keep normal security controls."
        )
    if any(term in lowered for term in ("data breach", "breached", "leaked password", "hacked")):
        return (
            "Change the affected password from a trusted device, replace every reused password, "
            "enable MFA, review active sessions and recovery details, check financial activity, "
            "and watch for targeted phishing. Contact the provider through its official channel."
        )
    if any(term in lowered for term in ("social engineering", "impersonation", "fake support")):
        return (
            "Social engineering manipulates people rather than directly breaking technology. "
            "Common signs include urgency, secrecy, authority claims, unexpected payment or "
            "credential requests, and pressure to bypass normal procedures. Stop and verify "
            "through an independently obtained official contact."
        )
    if any(term in lowered for term in ("backup", "back up", "updates", "update device")):
        return (
            "Keep automatic security updates enabled and maintain tested backups. A useful rule "
            "is 3-2-1: three copies of important data, on two types of storage, with one copy "
            "offline or off-site. Periodically test that files can actually be restored."
        )
    if any(term in lowered for term in ("encryption", "encrypt", "firewall", "antivirus")):
        return (
            "Encryption protects readable data with a key, a firewall controls network traffic, "
            "and antivirus looks for malicious behavior or files. They solve different problems "
            "and work best together with updates, backups, MFA, and careful user decisions."
        )
    if any(term in lowered for term in ("privacy", "personal data", "app permission")):
        return (
            "Share only necessary information, review app permissions, disable access that is "
            "not needed, use device encryption and a screen lock, limit ad tracking, and delete "
            "old accounts or stored data you no longer need."
        )
    if any(term in lowered for term in ("report", "dashboard", "history", "scan record")):
        return (
            "Nirapod stores scan history under your signed-in account when Save Scan History "
            "is enabled. History filters URL, QR, message, screenshot/OCR, and room-check records. "
            "Reports calculate real 30-day totals and dates from those saved records."
        )
    if any(term in lowered for term in ("qr", "quishing")):
        return (
            "QR codes can hide malicious destinations. Scan first, inspect the revealed domain, "
            "and verify the recipient before entering credentials or approving a payment."
        )
    if any(
        term in lowered
        for term in (
            "hidden camera",
            "hotel camera",
            "spy camera",
            "thermal camera",
            "infrared camera",
            "room privacy",
        )
    ):
        return (
            "Use Nirapod Hidden Camera Safety Check for a guided inspection. Dim the room "
            "and slowly inspect smoke detectors, clocks, chargers, vents, mirrors, and objects "
            "facing beds or bathrooms for a small sharp lens reflection. Check the room Wi-Fi "
            "for unfamiliar camera-like devices only if you are authorized to use that network. "
            "A normal phone cannot certify that a room is camera-free and may miss infrared, "
            "thermal, wired, offline, or separately networked cameras. Reliable RF or thermal "
            "confirmation requires compatible specialist hardware. If you find something, do "
            "not touch it—leave, preserve photos, contact hotel management, and notify local authorities."
        )
    if knowledge:
        return (
            f"Based on the Nirapod Help Centre:\n\n{knowledge[:1200]}\n\n"
            "Share the situation without passwords, OTPs, or financial details for more guidance."
        )
    return (
        "That's a good question. I may need a little more context to give you a useful "
        "answer. Tell me what happened or what you would like to understand, and I'll "
        "help you work through it clearly. Please leave out passwords, OTPs, recovery "
        "codes, and banking details."
    )


def _output_text(response):
    if response.get("output_text"):
        return response["output_text"].strip()
    texts = []
    for item in response.get("output", []):
        for content in item.get("content", []):
            if content.get("type") == "output_text" and content.get("text"):
                texts.append(content["text"])
    return "\n".join(texts).strip()


def _multilingual_local_answer(question, language):
    """Offline, privacy-preserving answers in the selected app language."""
    q = question.lower().strip()
    if language == "ms":
        if q in {"hi", "hello", "hey", "hai", "apa khabar", "how are you", "how are u"}:
            return "Hai! Saya Nirapod Guide. 👋 Saya sihat dan sedia membantu. Apa khabar? Anda boleh bertanya tentang keselamatan siber atau berbual secara biasa."
        if any(x in q for x in ("phishing", "pancingan", "link", "url")):
            return "Periksa domain penuh, kesalahan ejaan, subdomain pelik, pautan pendek dan permintaan mendesak untuk kata laluan atau OTP. HTTPS sahaja tidak membuktikan laman itu sah. Imbas pautan dan sahkan melalui aplikasi rasmi organisasi."
        if any(x in q for x in ("password", "kata laluan", "account", "akaun")):
            return "Gunakan kata laluan unik sekurang-kurangnya 14 aksara, pengurus kata laluan dan MFA. Semak sesi aktif dan jangan kongsi kata laluan atau OTP dengan sesiapa."
        if any(x in q for x in ("qr", "kamera", "camera", "room", "bilik")):
            return "Imbas kod QR sebelum membukanya dan semak domain yang didedahkan. Untuk pemeriksaan bilik, periksa objek yang menghadap kawasan peribadi dan pantulan kanta; telefon biasa tidak boleh menjamin bilik bebas kamera tersembunyi."
        if any(x in q for x in ("scam", "ditipu", "hacked", "digodam")):
            return "Hentikan hubungan dengan pengirim, tukar kata laluan melalui peranti dipercayai, aktifkan MFA, tamatkan sesi lain dan hubungi bank melalui nombor rasmi jika maklumat kewangan terlibat."
        return "Saya faham. Berikan sedikit lagi konteks supaya saya boleh membantu dengan tepat. Jangan sertakan kata laluan, OTP, kod pemulihan atau maklumat perbankan."
    if language == "bn":
        if q in {"hi", "hello", "hey", "হাই", "হ্যালো", "কেমন আছ", "how are you", "how are u"}:
            return "হ্যালো! আমি Nirapod গাইড। 👋 আমি ভালো আছি এবং সাহায্য করতে প্রস্তুত। আপনি কেমন আছেন? সাইবার নিরাপত্তা নিয়ে প্রশ্ন করতে বা সাধারণভাবে কথা বলতে পারেন।"
        if any(x in q for x in ("phishing", "ফিশিং", "link", "লিংক", "url")):
            return "সম্পূর্ণ ডোমেইন, বানান ভুল, অস্বাভাবিক সাবডোমেইন, ছোট করা লিংক এবং পাসওয়ার্ড বা OTP চাওয়া জরুরি বার্তা পরীক্ষা করুন। শুধু HTTPS থাকলেই সাইট বৈধ হয় না। লিংক স্ক্যান করুন এবং প্রতিষ্ঠানের অফিসিয়াল অ্যাপ দিয়ে যাচাই করুন।"
        if any(x in q for x in ("password", "পাসওয়ার্ড", "account", "অ্যাকাউন্ট")):
            return "কমপক্ষে ১৪ অক্ষরের আলাদা পাসওয়ার্ড, একটি বিশ্বস্ত পাসওয়ার্ড ম্যানেজার এবং MFA ব্যবহার করুন। সক্রিয় সেশন দেখুন এবং কারও সঙ্গে পাসওয়ার্ড বা OTP শেয়ার করবেন না।"
        if any(x in q for x in ("qr", "ক্যামেরা", "camera", "room", "রুম", "কক্ষ")):
            return "QR কোড খোলার আগে স্ক্যান করে গন্তব্য ডোমেইন দেখুন। কক্ষ পরীক্ষায় ব্যক্তিগত এলাকার দিকে মুখ করা বস্তু ও ছোট লেন্সের প্রতিফলন খুঁজুন; সাধারণ ফোন কোনো কক্ষকে গোপন ক্যামেরামুক্ত বলে নিশ্চিত করতে পারে না।"
        if any(x in q for x in ("scam", "প্রতারণা", "hacked", "হ্যাক")):
            return "প্রেরকের সঙ্গে যোগাযোগ বন্ধ করুন, বিশ্বস্ত ডিভাইস থেকে পাসওয়ার্ড বদলান, MFA চালু করুন, অন্য সেশন বন্ধ করুন এবং আর্থিক তথ্য জড়িত থাকলে অফিসিয়াল নম্বরে ব্যাংকের সঙ্গে যোগাযোগ করুন।"
        return "আমি বুঝেছি। সঠিকভাবে সাহায্য করতে একটু বিস্তারিত বলুন। পাসওয়ার্ড, OTP, রিকভারি কোড বা ব্যাংক তথ্য দেবেন না।"
    return None


def answer_question(user_id, question, history, knowledge="", language="en"):
    api_key = os.getenv("OPENAI_API_KEY", "").strip()
    if not api_key:
        localized = _multilingual_local_answer(question, language)
        if localized:
            return localized, "local"
        return _local_answer(question, knowledge), "local"
    conversation = [
        {"role": item["role"], "content": item["content"]}
        for item in history[-10:]
    ]
    conversation.append({"role": "user", "content": question})
    context = f"\n\nVerified Help Centre context:\n{knowledge[:5000]}" if knowledge else ""
    response_language = {
        "ms": "Always answer in natural Bahasa Melayu.",
        "bn": "Always answer in natural Bangla (Bengali script).",
    }.get(language, "Always answer in English.")
    payload = {
        "model": os.getenv("OPENAI_CHAT_MODEL", "gpt-5.6-sol"),
        "instructions": SYSTEM_INSTRUCTIONS + "\n" + response_language + context,
        "input": conversation,
        "reasoning": {"effort": "low"},
        "text": {"verbosity": "medium"},
        "max_output_tokens": 900,
        "safety_identifier": hashlib.sha256(
            f"nirapod-user-{user_id}".encode()
        ).hexdigest(),
        "store": False,
    }
    request = Request(
        "https://api.openai.com/v1/responses",
        data=json.dumps(payload).encode(),
        headers={"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urlopen(request, timeout=45) as response:
            answer = _output_text(json.loads(response.read().decode()))
        if not answer:
            raise ValueError("Empty AI response")
        return answer, "openai"
    except (HTTPError, URLError, TimeoutError, ValueError):
        localized = _multilingual_local_answer(question, language)
        if localized:
            return localized, "local_fallback"
        return (
            _local_answer(question, knowledge)
            + "\n\nThe online AI service was unavailable; this answer used the local guide."
        ), "local_fallback"
