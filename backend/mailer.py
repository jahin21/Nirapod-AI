import os
import smtplib
import ssl
from email.message import EmailMessage
from urllib.parse import urlencode


def password_reset_email_configured():
    return bool(os.getenv("SMTP_HOST", "").strip() and os.getenv("SMTP_FROM", "").strip())


def send_password_reset_email(recipient, token):
    """Send a reset token without logging or returning the secret to the client."""
    host = os.getenv("SMTP_HOST", "").strip()
    sender = os.getenv("SMTP_FROM", "").strip()
    if not host or not sender:
        return False
    port = int(os.getenv("SMTP_PORT", "587"))
    username = os.getenv("SMTP_USERNAME", "").strip()
    password = os.getenv("SMTP_PASSWORD", "")
    base_url = os.getenv("NIRAPOD_RESET_BASE_URL", "").strip()
    link = f"{base_url}?{urlencode({'token': token})}" if base_url else ""
    message = EmailMessage()
    message["Subject"] = "Reset your Nirapod AI password"
    message["From"] = sender
    message["To"] = recipient
    message.set_content(
        "A password reset was requested for your Nirapod AI account.\n\n"
        f"Reset token: {token}\n\n"
        + (f"Reset link: {link}\n\n" if link else "")
        + "The token expires in 30 minutes and can be used once. "
        "If you did not request this, you can ignore this email."
    )
    context = ssl.create_default_context()
    try:
        if port == 465:
            with smtplib.SMTP_SSL(host, port, context=context, timeout=10) as client:
                if username:
                    client.login(username, password)
                client.send_message(message)
        else:
            with smtplib.SMTP(host, port, timeout=10) as client:
                client.starttls(context=context)
                if username:
                    client.login(username, password)
                client.send_message(message)
        return True
    except (OSError, smtplib.SMTPException):
        return False
