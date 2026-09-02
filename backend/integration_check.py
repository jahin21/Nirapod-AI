import json
import os
import tempfile
import threading
import time
import urllib.request
from urllib.error import HTTPError
from pathlib import Path

import database

database.DATABASE_PATH = Path(tempfile.mkdtemp()) / "test.db"
os.environ["SMTP_HOST"] = "smtp.example.test"
os.environ["SMTP_FROM"] = "noreply@example.test"

import uvicorn

import ml_models

original_model_dir = ml_models.MODEL_DIR
original_manifest = ml_models.MODEL_MANIFEST
broken_model_dir = Path(tempfile.mkdtemp())
(broken_model_dir / "model_manifest.json").write_text(
    json.dumps({
        "status": "promoted",
        "model_version": "broken-test-model",
        "url_model": "missing.joblib",
    }),
    encoding="utf-8",
)
ml_models.MODEL_DIR = broken_model_dir
ml_models.MODEL_MANIFEST = broken_model_dir / "model_manifest.json"
fallback_models = ml_models.DetectionModels()
assert fallback_models.model_source == "embedded_fallback"
assert fallback_models.model_version == "embedded-baseline-v1"
ml_models.MODEL_DIR = original_model_dir
ml_models.MODEL_MANIFEST = original_manifest

import main

assert main.models.predict_url("not a valid destination")[0] == "inconclusive"
assert main.models.predict_url("https://xn--microsft-5za.example/login")[0] == "dangerous"
assert main.models.predict_url("https://paypa1-secure.example.com/login")[0] == "dangerous"


server = uvicorn.Server(
    uvicorn.Config(main.app, host="127.0.0.1", port=8765, log_level="error")
)
thread = threading.Thread(target=server.run, daemon=True)
thread.start()
for _ in range(50):
    if server.started:
        break
    time.sleep(0.1)


def request(path, method="GET", payload=None, token=None):
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    body = json.dumps(payload).encode() if payload is not None else None
    req = urllib.request.Request(
        f"http://127.0.0.1:8765{path}",
        data=body,
        headers=headers,
        method=method,
    )
    with urllib.request.urlopen(req, timeout=20) as response:
        return response.status, json.loads(response.read())


def error_status(path, method="GET", payload=None, token=None):
    try:
        request(path, method, payload, token)
    except HTTPError as error:
        return error.code
    raise AssertionError(f"Expected {path} to fail")


try:
    assert error_status(
        "/auth/register",
        "POST",
        {
            "name": "Invalid Email",
            "email": "not-an-email",
            "password": "StrongPass123!",
        },
    ) == 422
    status, registered = request(
        "/auth/register",
        "POST",
        {
            "name": "Integration Test",
            "email": "integration@example.test",
            "password": "StrongPass123!",
        },
    )
    assert status == 200
    token = registered["token"]
    reset_delivery = {}

    def capture_reset(email, reset_token):
        reset_delivery.update({"email": email, "token": reset_token})
        return True

    main.send_password_reset_email = capture_reset
    status, _ = request(
        "/auth/password-reset/request",
        "POST",
        {"email": "integration@example.test"},
    )
    assert status == 200 and reset_delivery["token"]
    status, _ = request(
        "/auth/password-reset/confirm",
        "POST",
        {
            "token": reset_delivery["token"],
            "new_password": "NewStrongPass456!",
        },
    )
    assert status == 200
    assert error_status("/auth/me", token=token) == 401
    assert error_status(
        "/auth/password-reset/confirm",
        "POST",
        {
            "token": reset_delivery["token"],
            "new_password": "AnotherStrongPass789!",
        },
    ) == 400
    _, logged_in = request(
        "/auth/login",
        "POST",
        {
            "email": "integration@example.test",
            "password": "NewStrongPass456!",
        },
    )
    token = logged_in["token"]
    for _ in range(11):
        status, repeated_login = request(
            "/auth/login",
            "POST",
            {
                "email": "integration@example.test",
                "password": "NewStrongPass456!",
            },
        )
        assert status == 200
        token = repeated_login["token"]
    _, saved_settings = request(
        "/settings",
        "PUT",
        {
            "auto_scan_links": True,
            "scan_notifications": True,
            "wifi_scan_warning": True,
            "default_browser": "in_app",
            "save_scan_history": True,
            "app_lock_mode": "off",
            "threat_updates": "automatic",
            "cloud_protection": True,
            "dark_mode": False,
            "text_size": "medium",
            "accent_color": "purple",
            "language": "en",
        },
        token,
    )
    _, loaded_settings = request("/settings", token=token)
    assert saved_settings == loaded_settings
    checks = [
        ("/scan/url", {"content": "https://google.com"}),
        ("/scan/qr", {"content": "https://google.com"}),
        ("/scan/text", {"content": "Urgent: verify your account password now"}),
        ("/scan/sms", {"content": "Claim your prize and send your OTP now"}),
        (
            "/scan/email",
            {"content": "Your bank account is locked. Click to verify login."},
        ),
        (
            "/scan/ocr",
            {"content": "Security alert: enter your password immediately"},
        ),
        (
            "/room-safety-check",
            {
                "reflection_detected": False,
                "suspicious_object": False,
                "network_findings": [],
                "bluetooth_findings": [],
            },
        ),
    ]
    for path, payload in checks:
        status, _ = request(path, "POST", payload, token)
        assert status == 200, path
    _, inconclusive = request(
        "/scan/text", "POST", {"content": "kjsbijsbfjfb"}, token
    )
    assert inconclusive["classification"] == "inconclusive", inconclusive
    assert inconclusive["confidence"] == 0.0, inconclusive
    _, one_indicator = request(
        "/room-safety-check",
        "POST",
        {
            "reflection_detected": False,
            "suspicious_object": False,
            "network_check_completed": True,
            "network_findings": [{"ip": "192.168.1.20", "ports": [554]}],
            "bluetooth_findings": [],
        },
        token,
    )
    assert one_indicator["classification"] == "suspicious", one_indicator
    assert len(one_indicator["signal_details"]) == 6, one_indicator
    assert all(item["limitation"] for item in one_indicator["signal_details"])
    _, multiple_indicators = request(
        "/room-safety-check",
        "POST",
        {
            "reflection_detected": True,
            "suspicious_object": False,
            "visual_check_completed": True,
            "network_check_completed": True,
            "network_findings": [{"ip": "192.168.1.20", "ports": [554]}],
            "bluetooth_findings": [],
        },
        token,
    )
    assert multiple_indicators["classification"] == "dangerous", multiple_indicators
    _, thermal_indicator = request(
        "/room-safety-check",
        "POST",
        {
            "advanced_readings": [{
                "sensor_type": "thermal",
                "detected": True,
                "confidence": 0.82,
                "source": "verified-test-adapter",
                "temperature_c": 41.5,
            }],
        },
        token,
    )
    assert thermal_indicator["classification"] == "suspicious", thermal_indicator
    _, decisive_thermal = request(
        "/room-safety-check",
        "POST",
        {
            "advanced_readings": [{
                "sensor_type": "thermal",
                "detected": True,
                "confidence": 0.94,
                "source": "verified-calibrated-adapter",
                "temperature_c": 48.0,
                "context_validated": True,
            }],
        },
        token,
    )
    assert decisive_thermal["classification"] == "dangerous", decisive_thermal
    _, unsupported_uwb = request(
        "/room-safety-check",
        "POST",
        {
            "advanced_readings": [{
                "sensor_type": "uwb",
                "detected": True,
                "confidence": 0.95,
                "source": "phone-uwb",
                "target_label": "unknown participating tag",
                "distance_m": 1.2,
            }],
        },
        token,
    )
    assert unsupported_uwb["classification"] == "safe", unsupported_uwb
    _, open_wifi = request(
        "/wifi-safety-check",
        "POST",
        {
            "ssid": "Airport Guest",
            "security": "Open",
            "rssi": -55,
            "network_findings": [],
        },
        token,
    )
    assert open_wifi["classification"] == "dangerous", open_wifi
    _, wpa3_wifi = request(
        "/wifi-safety-check",
        "POST",
        {
            "ssid": "Trusted Home",
            "security": "WPA3-Personal",
            "rssi": -48,
            "network_findings": [],
        },
        token,
    )
    assert wpa3_wifi["classification"] == "safe", wpa3_wifi
    _, articles = request("/help/articles?q=What%20is%20Phishing%3F", token=token)
    assert articles["items"] and articles["items"][0]["content"], articles
    _, history = request("/history?limit=100", token=token)
    assert history["total"] == 15, history
    _, analytics = request("/analytics?days=30", token=token)
    assert analytics["summary"]["total"] == 15, analytics
    _, room = request("/history?scan_type=room", token=token)
    _, ocr = request("/history?scan_type=ocr", token=token)
    assert room["total"] == 6 and ocr["total"] == 1
    _, greeting = request("/chat", "POST", {"message": "how are u"}, token)
    assert "doing well" in greeting["content"].lower()
    assert greeting["provider"] == "local"
    print(
        "All authenticated scans, Wi-Fi safety, learning articles, history, database, and analytics routes passed."
    )
finally:
    server.should_exit = True
    thread.join(timeout=5)
