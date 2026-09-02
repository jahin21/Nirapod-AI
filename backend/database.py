import json
import hashlib
import os
import re
import secrets
import sqlite3
from datetime import datetime, timedelta, timezone
from contextlib import contextmanager
from pathlib import Path

try:
    import psycopg
except ImportError:  # Local SQLite development does not require psycopg.
    psycopg = None

INTEGRITY_ERRORS = (
    (sqlite3.IntegrityError, psycopg.IntegrityError)
    if psycopg is not None
    else (sqlite3.IntegrityError,)
)

DATABASE_PATH = Path(__file__).resolve().parent / "nirapod.db"
DATABASE_URL = os.getenv("DATABASE_URL", "").strip()
USING_POSTGRES = DATABASE_URL.startswith(("postgres://", "postgresql://"))


class DatabaseRow(dict):
    """Mapping row that also supports SQLite-style numeric indexing."""

    def __getitem__(self, key):
        if isinstance(key, int):
            return tuple(self.values())[key]
        return super().__getitem__(key)


class PostgresResult:
    def __init__(self, cursor):
        self.cursor = cursor

    def _row(self, values):
        if values is None:
            return None
        names = [column.name for column in self.cursor.description]
        return DatabaseRow(zip(names, values))

    def fetchone(self):
        return self._row(self.cursor.fetchone())

    def fetchall(self):
        return [self._row(row) for row in self.cursor.fetchall()]

    def __iter__(self):
        return iter(self.fetchall())

    @property
    def lastrowid(self):
        row = self.fetchone()
        return row[0] if row else 0


class PostgresConnection:
    _returning_id_tables = {
        "scans",
        "community_reports",
        "users",
        "support_tickets",
        "chat_messages",
    }

    def __init__(self, connection):
        self.connection = connection

    @staticmethod
    def _convert_sql(sql):
        converted = sql.replace("COLLATE NOCASE", "")
        converted = converted.replace(
            "date(created_at) >= date('now', ?)",
            "created_at::date >= CURRENT_DATE + (?)::interval",
        )
        converted = converted.replace(
            "datetime('now', '-1 second')",
            "CURRENT_TIMESTAMP - INTERVAL '1 second'",
        )
        ignore = bool(re.search(r"INSERT\s+OR\s+IGNORE", converted, re.I))
        converted = re.sub(r"INSERT\s+OR\s+IGNORE", "INSERT", converted, flags=re.I)
        converted = converted.replace("?", "%s")
        if ignore:
            converted = converted.rstrip().rstrip(";") + " ON CONFLICT DO NOTHING"
        match = re.match(r"\s*INSERT\s+INTO\s+([a-z_]+)", converted, re.I)
        if match and match.group(1).lower() in PostgresConnection._returning_id_tables:
            converted = converted.rstrip().rstrip(";") + " RETURNING id"
        return converted

    def execute(self, sql, values=()):
        cursor = self.connection.cursor()
        cursor.execute(self._convert_sql(sql), tuple(values or ()))
        return PostgresResult(cursor)

    def executemany(self, sql, values):
        cursor = self.connection.cursor()
        cursor.executemany(self._convert_sql(sql), values)
        return PostgresResult(cursor)

    def commit(self):
        self.connection.commit()

    def close(self):
        self.connection.close()


def database_name():
    return "postgresql" if USING_POSTGRES else "sqlite"


@contextmanager
def connection():
    if USING_POSTGRES:
        if psycopg is None:
            raise RuntimeError(
                "DATABASE_URL is PostgreSQL but psycopg is not installed. "
                "Run pip install -r requirements.txt."
            )
        raw = psycopg.connect(DATABASE_URL, prepare_threshold=None)
        db = PostgresConnection(raw)
        try:
            yield db
            db.commit()
        finally:
            db.close()
        return
    db = sqlite3.connect(DATABASE_PATH)
    db.row_factory = sqlite3.Row
    db.execute("PRAGMA foreign_keys = ON")
    db.execute("PRAGMA busy_timeout = 5000")
    db.execute("PRAGMA journal_mode = WAL")
    try:
        yield db
        db.commit()
    finally:
        db.close()


def _column_names(db, table):
    if USING_POSTGRES:
        return {
            row[0]
            for row in db.execute(
                """
                SELECT column_name FROM information_schema.columns
                WHERE table_schema = 'public' AND table_name = ?
                """,
                (table,),
            ).fetchall()
        }
    return {
        row["name"] for row in db.execute(f"PRAGMA table_info({table})").fetchall()
    }


def _initialize_postgres(db):
    statements = [
        """CREATE TABLE IF NOT EXISTS scans (
            id BIGSERIAL PRIMARY KEY, scan_type TEXT NOT NULL, content TEXT NOT NULL,
            classification TEXT NOT NULL, risk_score INTEGER NOT NULL,
            confidence DOUBLE PRECISION NOT NULL, reasons TEXT NOT NULL,
            created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
            user_id BIGINT)""",
        """CREATE TABLE IF NOT EXISTS community_reports (
            id BIGSERIAL PRIMARY KEY, report_type TEXT NOT NULL, content TEXT NOT NULL,
            details TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
            user_id BIGINT)""",
        """CREATE TABLE IF NOT EXISTS app_profile (
            id INTEGER PRIMARY KEY CHECK (id = 1), name TEXT NOT NULL, email TEXT NOT NULL,
            notifications_enabled INTEGER NOT NULL DEFAULT 1,
            privacy_mode INTEGER NOT NULL DEFAULT 1)""",
        """CREATE TABLE IF NOT EXISTS users (
            id BIGSERIAL PRIMARY KEY, name TEXT NOT NULL, email TEXT NOT NULL,
            password_hash TEXT NOT NULL, password_salt TEXT NOT NULL,
            provider TEXT NOT NULL DEFAULT 'email',
            created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP)""",
        "CREATE UNIQUE INDEX IF NOT EXISTS users_email_lower_idx ON users (LOWER(email))",
        """CREATE TABLE IF NOT EXISTS sessions (
            token TEXT PRIMARY KEY, user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
            expires_at TIMESTAMPTZ NOT NULL)""",
        """CREATE TABLE IF NOT EXISTS help_articles (
            id BIGSERIAL PRIMARY KEY, category TEXT NOT NULL, title TEXT NOT NULL UNIQUE,
            summary TEXT NOT NULL, content TEXT NOT NULL)""",
        """CREATE TABLE IF NOT EXISTS support_tickets (
            id BIGSERIAL PRIMARY KEY, user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
            subject TEXT NOT NULL, message TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'open',
            created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP)""",
        """CREATE TABLE IF NOT EXISTS notifications (
            id BIGSERIAL PRIMARY KEY, user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            notification_type TEXT NOT NULL, title TEXT NOT NULL, message TEXT NOT NULL,
            is_read INTEGER NOT NULL DEFAULT 0,
            created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP)""",
        """CREATE TABLE IF NOT EXISTS user_settings (
            user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
            auto_scan_links INTEGER NOT NULL DEFAULT 0,
            scan_notifications INTEGER NOT NULL DEFAULT 1,
            wifi_scan_warning INTEGER NOT NULL DEFAULT 1,
            default_browser TEXT NOT NULL DEFAULT 'in_app',
            save_scan_history INTEGER NOT NULL DEFAULT 1,
            app_lock_mode TEXT NOT NULL DEFAULT 'off',
            threat_updates TEXT NOT NULL DEFAULT 'automatic',
            cloud_protection INTEGER NOT NULL DEFAULT 1,
            dark_mode INTEGER NOT NULL DEFAULT 0,
            text_size TEXT NOT NULL DEFAULT 'medium',
            accent_color TEXT NOT NULL DEFAULT 'purple',
            language TEXT NOT NULL DEFAULT 'en')""",
        """CREATE TABLE IF NOT EXISTS chat_messages (
            id BIGSERIAL PRIMARY KEY, user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
            content TEXT NOT NULL, provider TEXT NOT NULL DEFAULT 'local',
            created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP)""",
        """CREATE TABLE IF NOT EXISTS password_reset_tokens (
            token_hash TEXT PRIMARY KEY,
            user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            expires_at TIMESTAMPTZ NOT NULL,
            used_at TIMESTAMPTZ)""",
    ]
    for statement in statements:
        db.execute(statement)
    db.execute(
        """INSERT INTO app_profile (id, name, email)
        VALUES (1, 'Jahin Ahmed', 'jahin.ahmed@email.com')
        ON CONFLICT (id) DO NOTHING"""
    )


def initialize_database():
    with connection() as db:
        if USING_POSTGRES:
            _initialize_postgres(db)
        else:
            db.executescript(
            """
            CREATE TABLE IF NOT EXISTS scans (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                scan_type TEXT NOT NULL,
                content TEXT NOT NULL,
                classification TEXT NOT NULL,
                risk_score INTEGER NOT NULL,
                confidence REAL NOT NULL,
                reasons TEXT NOT NULL,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS community_reports (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                report_type TEXT NOT NULL,
                content TEXT NOT NULL,
                details TEXT,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS app_profile (
                id INTEGER PRIMARY KEY CHECK (id = 1),
                name TEXT NOT NULL,
                email TEXT NOT NULL,
                notifications_enabled INTEGER NOT NULL DEFAULT 1,
                privacy_mode INTEGER NOT NULL DEFAULT 1
            );

            INSERT OR IGNORE INTO app_profile (id, name, email)
            VALUES (1, 'Jahin Ahmed', 'jahin.ahmed@email.com');

            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                email TEXT NOT NULL UNIQUE COLLATE NOCASE,
                password_hash TEXT NOT NULL,
                password_salt TEXT NOT NULL,
                provider TEXT NOT NULL DEFAULT 'email',
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS sessions (
                token TEXT PRIMARY KEY,
                user_id INTEGER NOT NULL,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                expires_at TEXT NOT NULL,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS help_articles (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                category TEXT NOT NULL,
                title TEXT NOT NULL UNIQUE,
                summary TEXT NOT NULL,
                content TEXT NOT NULL
            );

            CREATE TABLE IF NOT EXISTS support_tickets (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER,
                subject TEXT NOT NULL,
                message TEXT NOT NULL,
                status TEXT NOT NULL DEFAULT 'open',
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
            );

            CREATE TABLE IF NOT EXISTS notifications (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                notification_type TEXT NOT NULL,
                title TEXT NOT NULL,
                message TEXT NOT NULL,
                is_read INTEGER NOT NULL DEFAULT 0,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS user_settings (
                user_id INTEGER PRIMARY KEY,
                auto_scan_links INTEGER NOT NULL DEFAULT 0,
                scan_notifications INTEGER NOT NULL DEFAULT 1,
                wifi_scan_warning INTEGER NOT NULL DEFAULT 1,
                default_browser TEXT NOT NULL DEFAULT 'in_app',
                save_scan_history INTEGER NOT NULL DEFAULT 1,
                app_lock_mode TEXT NOT NULL DEFAULT 'off',
                threat_updates TEXT NOT NULL DEFAULT 'automatic',
                cloud_protection INTEGER NOT NULL DEFAULT 1,
                dark_mode INTEGER NOT NULL DEFAULT 0,
                text_size TEXT NOT NULL DEFAULT 'medium',
                accent_color TEXT NOT NULL DEFAULT 'purple',
                language TEXT NOT NULL DEFAULT 'en',
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS chat_messages (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
                content TEXT NOT NULL,
                provider TEXT NOT NULL DEFAULT 'local',
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS password_reset_tokens (
                token_hash TEXT PRIMARY KEY,
                user_id INTEGER NOT NULL,
                expires_at TEXT NOT NULL,
                used_at TEXT,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            );
            """
        )
        columns = _column_names(db, "user_settings")
        if "language" not in columns:
            db.execute(
                "ALTER TABLE user_settings ADD COLUMN language TEXT NOT NULL DEFAULT 'en'"
            )
        if db.execute("SELECT COUNT(*) FROM help_articles").fetchone()[0] == 0:
            db.executemany(
                """
                INSERT INTO help_articles (category, title, summary, content)
                VALUES (?, ?, ?, ?)
                """,
                [
                    ("getting_started", "How do I scan a link?", "Learn how to check the safety of any website link.", "Open Scan, choose URL / Link Scanner, paste the complete link, and select Scan URL. Nirapod evaluates URL structure with its machine-learning model and explains the detected risk indicators."),
                    ("getting_started", "What does each risk level mean?", "Understand Safe, Suspicious, and Dangerous results.", "Safe means no strong threat indicators were found. Suspicious means the item has warning signs and should be verified. Dangerous means strong phishing or scam indicators were detected and you should not continue."),
                    ("security", "How does Nirapod AI work?", "Learn how the detection engine identifies threats.", "URLs and QR destinations are evaluated by a Random Forest classifier using structural URL features. Messages and OCR text are evaluated by an NLP classifier using TF-IDF features and Logistic Regression."),
                    ("security", "Can I report a false positive?", "Help improve results that appear incorrect.", "Open Reports, choose Report a Scam, provide the scanned content and explain why the result seems incorrect. The report is stored for review."),
                    ("scanning", "How do I scan a QR code?", "Use your camera or gallery to inspect a QR destination.", "Open QR Code Scanner and allow camera access. Hold the QR code inside the frame. Nirapod extracts its destination and analyzes the URL before you open it."),
                    ("scanning", "How does Screenshot OCR work?", "Extract and analyze suspicious text from an image.", "Choose a clear screenshot under 10 MB. OCR extracts visible text and sends that text to the message phishing classifier. Images are not stored by scan history."),
                ],
            )
        if db.execute(
            "SELECT COUNT(*) FROM help_articles WHERE title = ?",
            ("How do I check a room for hidden cameras?",),
        ).fetchone()[0] == 0:
            db.execute(
                """
                INSERT INTO help_articles (category, title, summary, content)
                VALUES (?, ?, ?, ?)
                """,
                (
                    "security",
                    "How do I check a room for hidden cameras?",
                    "Use realistic phone-assisted checks without false safety claims.",
                    "Open Hidden Camera Safety Check from Scan. Dim the room and inspect smoke detectors, clocks, chargers, vents, mirrors, and objects facing beds or bathrooms for small sharp lens reflections. Record unfamiliar camera-like devices found independently on the room Wi-Fi and suspicious objects or pinholes. A normal phone cannot certify a room camera-free or reliably detect infrared, thermal, wired, offline, or separately networked cameras. RF and thermal confirmation require suitable specialist hardware. Do not touch a suspected device; leave, preserve evidence, contact hotel management, and report it to local authorities.",
                ),
            )
        learning_articles = [
            (
                "phishing",
                "What is Phishing?",
                "Learn how phishing attacks work and how to stay safe.",
                "Phishing is an attempt to trick you into revealing passwords, payment details, one-time codes, or other sensitive information. Attackers often create urgency, imitate trusted organizations, and send links to look-alike websites. Check the sender independently, inspect links before opening them, never share an OTP, and contact the organization through its official app or website when unsure.",
            ),
            (
                "phishing",
                "How to Identify Fake Websites",
                "Tips to spot fake websites and protect your information.",
                "Check the complete domain name, not only the page logo. Watch for misspellings, unusual subdomains, pressure to act immediately, unexpected login requests, and payment methods that cannot be reversed. HTTPS encrypts a connection but does not prove a site is honest. Scan the URL with Nirapod before entering information and use a trusted bookmark for banking or government services.",
            ),
            (
                "qr_codes",
                "QR Code Scams",
                "How scammers use QR codes and how to avoid them.",
                "A QR code can hide a website address until it is scanned. Criminals may cover legitimate codes on parking meters, menus, parcels, or payment signs. Preview and scan the destination before opening it, confirm the domain, avoid installing applications from QR links, and stop if a page requests credentials or payment details unexpectedly.",
            ),
            (
                "messages",
                "OTP and Banking Scams",
                "Protect yourself from OTP and banking fraud.",
                "Banks and legitimate support staff do not need your password, PIN, or one-time code. Do not approve an unexpected login or payment notification. End the call or chat, open the official banking application yourself, and contact the number printed on your card. If you shared information, freeze affected accounts immediately and report the incident.",
            ),
            (
                "room_privacy",
                "Hidden Camera Safety",
                "Learn realistic phone-assisted checks and their limitations.",
                "Inspect objects facing beds or bathrooms, including clocks, chargers, smoke detectors, vents, and mirrors. Look for unusual pinholes or sharp lens reflections and review unfamiliar devices on an authorized Wi-Fi network. Phone checks cannot certify that a room is camera-free and may miss offline, wired, infrared, or separately networked devices. Do not touch suspected equipment; leave safely, preserve evidence, and contact management or local authorities.",
            ),
        ]
        for category, title, summary, content in learning_articles:
            if db.execute(
                "SELECT COUNT(*) FROM help_articles WHERE title = ?",
                (title,),
            ).fetchone()[0] == 0:
                db.execute(
                    """
                    INSERT INTO help_articles (category, title, summary, content)
                    VALUES (?, ?, ?, ?)
                    """,
                    (category, title, summary, content),
                )
        scan_columns = _column_names(db, "scans")
        if "user_id" not in scan_columns:
            db.execute("ALTER TABLE scans ADD COLUMN user_id INTEGER")
        report_columns = _column_names(db, "community_reports")
        if "user_id" not in report_columns:
            db.execute("ALTER TABLE community_reports ADD COLUMN user_id INTEGER")
        session_columns = _column_names(db, "sessions")
        if "expires_at" not in session_columns:
            db.execute("ALTER TABLE sessions ADD COLUMN expires_at TEXT")
            db.execute(
                "UPDATE sessions SET expires_at = datetime('now', '-1 second') "
                "WHERE expires_at IS NULL"
            )
        db.execute("DELETE FROM sessions WHERE expires_at <= CURRENT_TIMESTAMP")
        db.execute(
            "DELETE FROM password_reset_tokens WHERE expires_at <= CURRENT_TIMESTAMP"
        )


def save_scan(
    scan_type,
    content,
    classification,
    risk_score,
    confidence,
    reasons,
    user_id=None,
):
    with connection() as db:
        settings = _ensure_user_settings(db, user_id) if user_id is not None else None
        save_history = settings is None or bool(settings["save_scan_history"])
        send_notification = settings is None or bool(settings["scan_notifications"])
        cursor = None
        if save_history:
            cursor = db.execute(
                """
                INSERT INTO scans
                    (scan_type, content, classification, risk_score, confidence, reasons, user_id)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    scan_type,
                    content,
                    classification,
                    risk_score,
                    confidence,
                    json.dumps(reasons),
                    user_id,
                ),
            )
        if user_id is not None and send_notification:
            title = {
                "dangerous": "Dangerous item detected",
                "suspicious": "Suspicious item detected",
                "safe": "Scan completed safely",
            }.get(classification, "Scan completed")
            db.execute(
                """
                INSERT INTO notifications
                    (user_id, notification_type, title, message)
                VALUES (?, ?, ?, ?)
                """,
                (
                    user_id,
                    classification,
                    title,
                    f"{scan_type.title()} scan: {content[:160]}",
                ),
            )
        return cursor.lastrowid if cursor is not None else 0


def _ensure_user_settings(db, user_id):
    db.execute(
        "INSERT OR IGNORE INTO user_settings (user_id) VALUES (?)",
        (user_id,),
    )
    return db.execute(
        "SELECT * FROM user_settings WHERE user_id = ?",
        (user_id,),
    ).fetchone()


def get_user_settings(user_id):
    with connection() as db:
        row = _ensure_user_settings(db, user_id)
    result = dict(row)
    for key in (
        "auto_scan_links",
        "scan_notifications",
        "wifi_scan_warning",
        "save_scan_history",
        "cloud_protection",
        "dark_mode",
    ):
        result[key] = bool(result[key])
    result.pop("user_id", None)
    return result


def update_user_settings(user_id, values):
    allowed = {
        "auto_scan_links",
        "scan_notifications",
        "wifi_scan_warning",
        "default_browser",
        "save_scan_history",
        "app_lock_mode",
        "threat_updates",
        "cloud_protection",
        "dark_mode",
        "text_size",
        "accent_color",
        "language",
    }
    updates = {key: value for key, value in values.items() if key in allowed}
    with connection() as db:
        _ensure_user_settings(db, user_id)
        if updates:
            assignments = ", ".join(f"{key} = ?" for key in updates)
            db.execute(
                f"UPDATE user_settings SET {assignments} WHERE user_id = ?",
                [*updates.values(), user_id],
            )
    return get_user_settings(user_id)


def scan_history(limit=50, user_id=None, offset=0, scan_types=None, search=None):
    with connection() as db:
        type_clause = ""
        type_values = []
        if scan_types:
            placeholders = ", ".join("?" for _ in scan_types)
            type_clause = f" AND scan_type IN ({placeholders})"
            type_values = list(scan_types)
        search_clause = ""
        search_values = []
        if search and search.strip():
            search_clause = (
                " AND (content LIKE ? COLLATE NOCASE "
                "OR classification LIKE ? COLLATE NOCASE "
                "OR scan_type LIKE ? COLLATE NOCASE)"
            )
            pattern = f"%{search.strip()}%"
            search_values = [pattern, pattern, pattern]
        if user_id is None:
            rows = db.execute(
                f"""SELECT * FROM scans WHERE 1 = 1 {type_clause} {search_clause}
                ORDER BY created_at DESC, id DESC LIMIT ? OFFSET ?""",
                (*type_values, *search_values, limit, offset),
            ).fetchall()
        else:
            rows = db.execute(
                f"""
                SELECT * FROM scans WHERE user_id = ? {type_clause} {search_clause}
                ORDER BY created_at DESC, id DESC LIMIT ? OFFSET ?
                """,
                (user_id, *type_values, *search_values, limit, offset),
            ).fetchall()
    return [
        {
            **dict(row),
            "reasons": json.loads(row["reasons"]),
        }
        for row in rows
    ]


def scan_count(user_id=None, scan_types=None, search=None):
    with connection() as db:
        type_clause = ""
        type_values = []
        if scan_types:
            placeholders = ", ".join("?" for _ in scan_types)
            type_clause = f" AND scan_type IN ({placeholders})"
            type_values = list(scan_types)
        search_clause = ""
        search_values = []
        if search and search.strip():
            search_clause = (
                " AND (content LIKE ? COLLATE NOCASE "
                "OR classification LIKE ? COLLATE NOCASE "
                "OR scan_type LIKE ? COLLATE NOCASE)"
            )
            pattern = f"%{search.strip()}%"
            search_values = [pattern, pattern, pattern]
        if user_id is None:
            return db.execute(
                f"SELECT COUNT(*) FROM scans WHERE 1 = 1 {type_clause} {search_clause}",
                (*type_values, *search_values),
            ).fetchone()[0]
        return db.execute(
            f"SELECT COUNT(*) FROM scans WHERE user_id = ? {type_clause} {search_clause}",
            (user_id, *type_values, *search_values),
        ).fetchone()[0]


def user_analytics(user_id, days=30):
    days = max(1, min(int(days), 365))
    modifier = f"-{days - 1} days"
    with connection() as db:
        summary_rows = db.execute(
            """
            SELECT classification, COUNT(*) AS count
            FROM scans
            WHERE user_id = ? AND date(created_at) >= date('now', ?)
            GROUP BY classification
            """,
            (user_id, modifier),
        ).fetchall()
        type_rows = db.execute(
            """
            SELECT scan_type, COUNT(*) AS count
            FROM scans
            WHERE user_id = ? AND date(created_at) >= date('now', ?)
            GROUP BY scan_type
            """,
            (user_id, modifier),
        ).fetchall()
        daily_rows = db.execute(
            """
            SELECT date(created_at) AS scan_date, COUNT(*) AS count
            FROM scans
            WHERE user_id = ? AND date(created_at) >= date('now', ?)
            GROUP BY date(created_at)
            ORDER BY scan_date
            """,
            (user_id, modifier),
        ).fetchall()
        recent_rows = db.execute(
            """
            SELECT id, scan_type, content, classification, risk_score,
                   confidence, reasons, created_at
            FROM scans
            WHERE user_id = ? AND classification IN ('suspicious', 'dangerous')
            ORDER BY created_at DESC, id DESC
            LIMIT 5
            """,
            (user_id,),
        ).fetchall()

    summary = {"safe": 0, "suspicious": 0, "dangerous": 0, "inconclusive": 0}
    for row in summary_rows:
        summary[row["classification"]] = row["count"]
    summary["total"] = sum(summary.values())
    start_date = datetime.now(timezone.utc).date() - timedelta(days=days - 1)
    daily_lookup = {row["scan_date"]: row["count"] for row in daily_rows}
    daily = [
        {
            "date": (start_date + timedelta(days=index)).isoformat(),
            "count": daily_lookup.get(
                (start_date + timedelta(days=index)).isoformat(),
                0,
            ),
        }
        for index in range(days)
    ]
    recent = []
    for row in recent_rows:
        item = dict(row)
        item["reasons"] = json.loads(item["reasons"])
        recent.append(item)
    return {
        "period_days": days,
        "from_date": daily[0]["date"],
        "to_date": daily[-1]["date"],
        "summary": summary,
        "by_type": {row["scan_type"]: row["count"] for row in type_rows},
        "daily": daily,
        "recent_threats": recent,
    }


def save_report(report_type, content, details, user_id=None):
    with connection() as db:
        cursor = db.execute(
            """
            INSERT INTO community_reports (report_type, content, details, user_id)
            VALUES (?, ?, ?, ?)
            """,
            (report_type, content, details, user_id),
        )
        return cursor.lastrowid


def get_profile():
    with connection() as db:
        row = db.execute(
            "SELECT name, email, notifications_enabled, privacy_mode FROM app_profile WHERE id = 1"
        ).fetchone()
        total_scans = db.execute("SELECT COUNT(*) FROM scans").fetchone()[0]
    return {**dict(row), "total_scans": total_scans}


def update_profile(name, email):
    with connection() as db:
        db.execute(
            "UPDATE app_profile SET name = ?, email = ? WHERE id = 1",
            (name, email),
        )
    return get_profile()


def export_all_data():
    with connection() as db:
        scans = [dict(row) for row in db.execute("SELECT * FROM scans ORDER BY id DESC")]
        reports = [
            dict(row)
            for row in db.execute("SELECT * FROM community_reports ORDER BY id DESC")
        ]
    for scan in scans:
        scan["reasons"] = json.loads(scan["reasons"])
    return {"profile": get_profile(), "scans": scans, "community_reports": reports}


def _password_hash(password, salt):
    return hashlib.pbkdf2_hmac(
        "sha256",
        password.encode("utf-8"),
        bytes.fromhex(salt),
        310_000,
    ).hex()


def register_user(name, email, password):
    salt = secrets.token_hex(16)
    password_hash = _password_hash(password, salt)
    try:
        with connection() as db:
            cursor = db.execute(
                """
                INSERT INTO users (name, email, password_hash, password_salt)
                VALUES (?, ?, ?, ?)
                """,
                (name, email.lower(), password_hash, salt),
            )
            user_id = cursor.lastrowid
            db.execute(
                "INSERT INTO user_settings (user_id) VALUES (?)",
                (user_id,),
            )
            db.execute(
                """
                INSERT INTO notifications
                    (user_id, notification_type, title, message)
                VALUES (?, 'welcome', 'Welcome to Nirapod AI',
                        'Your account is ready. Start your first security scan.')
                """,
                (user_id,),
            )
    except INTEGRITY_ERRORS as error:
        raise ValueError("An account with this email already exists.") from error
    return create_session(user_id)


def login_user(email, password):
    with connection() as db:
        row = db.execute(
            "SELECT * FROM users WHERE email = ? COLLATE NOCASE",
            (email,),
        ).fetchone()
    if row is None or not secrets.compare_digest(
        row["password_hash"],
        _password_hash(password, row["password_salt"]),
    ):
        raise ValueError("Incorrect email address or password.")
    return create_session(row["id"])


def create_password_reset(email):
    """Create a short-lived, single-use reset token without storing plaintext."""
    with connection() as db:
        user = db.execute(
            "SELECT id FROM users WHERE email = ? COLLATE NOCASE",
            (email.lower(),),
        ).fetchone()
        if user is None:
            return None
        token = secrets.token_urlsafe(32)
        token_hash = hashlib.sha256(token.encode("utf-8")).hexdigest()
        expires_at = datetime.now(timezone.utc) + timedelta(minutes=30)
        db.execute(
            "DELETE FROM password_reset_tokens WHERE user_id = ?",
            (user["id"],),
        )
        db.execute(
            """INSERT INTO password_reset_tokens (token_hash, user_id, expires_at)
            VALUES (?, ?, ?)""",
            (
                token_hash,
                user["id"],
                expires_at.strftime("%Y-%m-%d %H:%M:%S"),
            ),
        )
    return token


def reset_password(token, new_password):
    token_hash = hashlib.sha256(token.encode("utf-8")).hexdigest()
    salt = secrets.token_hex(16)
    password_hash = _password_hash(new_password, salt)
    with connection() as db:
        row = db.execute(
            """SELECT user_id FROM password_reset_tokens
            WHERE token_hash = ? AND used_at IS NULL
              AND expires_at > CURRENT_TIMESTAMP""",
            (token_hash,),
        ).fetchone()
        if row is None:
            raise ValueError("This password reset token is invalid or expired.")
        db.execute(
            "UPDATE users SET password_hash = ?, password_salt = ? WHERE id = ?",
            (password_hash, salt, row["user_id"]),
        )
        db.execute(
            "UPDATE password_reset_tokens SET used_at = CURRENT_TIMESTAMP WHERE token_hash = ?",
            (token_hash,),
        )
        db.execute("DELETE FROM sessions WHERE user_id = ?", (row["user_id"],))


def create_session(user_id):
    token = secrets.token_urlsafe(48)
    token_hash = hashlib.sha256(token.encode("utf-8")).hexdigest()
    expires_at = datetime.now(timezone.utc) + timedelta(days=7)
    with connection() as db:
        db.execute(
            "INSERT INTO sessions (token, user_id, expires_at) VALUES (?, ?, ?)",
            (token_hash, user_id, expires_at.strftime("%Y-%m-%d %H:%M:%S")),
        )
        user = db.execute(
            "SELECT id, name, email, provider, created_at FROM users WHERE id = ?",
            (user_id,),
        ).fetchone()
    return {"token": token, "user": dict(user)}


def session_user(token):
    if not token:
        return None
    token_hash = hashlib.sha256(token.encode("utf-8")).hexdigest()
    with connection() as db:
        row = db.execute(
            """
            SELECT users.id, users.name, users.email, users.provider, users.created_at
            FROM sessions
            JOIN users ON users.id = sessions.user_id
            WHERE sessions.token = ? AND sessions.expires_at > CURRENT_TIMESTAMP
            """,
            (token_hash,),
        ).fetchone()
    return dict(row) if row else None


def logout_session(token):
    token_hash = hashlib.sha256(token.encode("utf-8")).hexdigest()
    with connection() as db:
        db.execute("DELETE FROM sessions WHERE token = ?", (token_hash,))


def get_user_profile(user_id):
    with connection() as db:
        user = db.execute(
            "SELECT id, name, email, provider, created_at FROM users WHERE id = ?",
            (user_id,),
        ).fetchone()
        total_scans = db.execute(
            "SELECT COUNT(*) FROM scans WHERE user_id = ?",
            (user_id,),
        ).fetchone()[0]
    return {**dict(user), "total_scans": total_scans}


def update_user_profile(user_id, name, email):
    try:
        with connection() as db:
            db.execute(
                "UPDATE users SET name = ?, email = ? WHERE id = ?",
                (name, email.lower(), user_id),
            )
    except INTEGRITY_ERRORS as error:
        raise ValueError("This email is already used by another account.") from error
    return get_user_profile(user_id)


def export_user_data(user_id):
    with connection() as db:
        scans = [
            dict(row)
            for row in db.execute(
                "SELECT * FROM scans WHERE user_id = ? ORDER BY id DESC",
                (user_id,),
            )
        ]
        reports = [
            dict(row)
            for row in db.execute(
                """
                SELECT * FROM community_reports
                WHERE user_id = ? ORDER BY id DESC
                """,
                (user_id,),
            )
        ]
    for scan in scans:
        scan["reasons"] = json.loads(scan["reasons"])
    return {
        "profile": get_user_profile(user_id),
        "scans": scans,
        "community_reports": reports,
    }


def search_help_articles(query="", category=""):
    sql = "SELECT id, category, title, summary, content FROM help_articles"
    clauses = []
    values = []
    if query:
        clauses.append("(title LIKE ? OR summary LIKE ? OR content LIKE ?)")
        pattern = f"%{query}%"
        values.extend([pattern, pattern, pattern])
    if category and category != "all":
        clauses.append("category = ?")
        values.append(category)
    if clauses:
        sql += " WHERE " + " AND ".join(clauses)
    sql += " ORDER BY title"
    with connection() as db:
        rows = db.execute(sql, values).fetchall()
    return [dict(row) for row in rows]


def create_support_ticket(user_id, subject, message):
    with connection() as db:
        cursor = db.execute(
            """
            INSERT INTO support_tickets (user_id, subject, message)
            VALUES (?, ?, ?)
            """,
            (user_id, subject, message),
        )
        ticket_id = cursor.lastrowid
    return {"id": ticket_id, "status": "open"}


def user_notifications(user_id, limit=50):
    with connection() as db:
        rows = db.execute(
            """
            SELECT id, notification_type, title, message, is_read, created_at
            FROM notifications
            WHERE user_id = ?
            ORDER BY created_at DESC, id DESC
            LIMIT ?
            """,
            (user_id, limit),
        ).fetchall()
    return [dict(row) for row in rows]


def mark_notification_read(user_id, notification_id=None):
    with connection() as db:
        if notification_id is None:
            db.execute(
                "UPDATE notifications SET is_read = 1 WHERE user_id = ?",
                (user_id,),
            )
        else:
            db.execute(
                """
                UPDATE notifications SET is_read = 1
                WHERE user_id = ? AND id = ?
                """,
                (user_id, notification_id),
            )


def save_chat_message(user_id, role, content, provider="local"):
    with connection() as db:
        cursor = db.execute(
            """
            INSERT INTO chat_messages (user_id, role, content, provider)
            VALUES (?, ?, ?, ?)
            """,
            (user_id, role, content, provider),
        )
        return cursor.lastrowid


def chat_history(user_id, limit=30):
    with connection() as db:
        rows = db.execute(
            """
            SELECT id, role, content, provider, created_at
            FROM chat_messages
            WHERE user_id = ?
            ORDER BY id DESC LIMIT ?
            """,
            (user_id, limit),
        ).fetchall()
    return [dict(row) for row in reversed(rows)]


def clear_chat_history(user_id):
    with connection() as db:
        db.execute("DELETE FROM chat_messages WHERE user_id = ?", (user_id,))
