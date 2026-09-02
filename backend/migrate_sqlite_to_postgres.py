"""One-time migration from local Nirapod SQLite data to PostgreSQL/Supabase.

Usage:
    set DATABASE_URL=postgresql://...
    python migrate_sqlite_to_postgres.py

The script never prints passwords, password hashes, session tokens, or the
connection string. Take a Supabase backup before rerunning it against live data.
"""

import os
import sqlite3
from pathlib import Path

import psycopg
from psycopg import sql

SOURCE = Path(__file__).resolve().parent / "nirapod.db"
DATABASE_URL = os.getenv("DATABASE_URL", "").strip()
TABLES = [
    "app_profile",
    "users",
    "sessions",
    "help_articles",
    "user_settings",
    "scans",
    "community_reports",
    "support_tickets",
    "notifications",
    "chat_messages",
]


def main():
    if not DATABASE_URL.startswith(("postgres://", "postgresql://")):
        raise SystemExit("Set DATABASE_URL to the Supabase PostgreSQL connection string.")
    if not SOURCE.exists():
        raise SystemExit(f"SQLite source not found: {SOURCE}")

    # Import only after DATABASE_URL is validated so database.py creates the
    # PostgreSQL schema instead of opening the local SQLite fallback.
    from database import initialize_database

    initialize_database()
    source = sqlite3.connect(SOURCE)
    source.row_factory = sqlite3.Row
    target = psycopg.connect(DATABASE_URL, prepare_threshold=None)
    try:
        with target.cursor() as cursor:
            for table in TABLES:
                rows = source.execute(f'SELECT * FROM "{table}"').fetchall()
                if not rows:
                    continue
                target_columns = {
                    row[0]
                    for row in cursor.execute(
                        """SELECT column_name FROM information_schema.columns
                        WHERE table_schema = 'public' AND table_name = %s""",
                        (table,),
                    ).fetchall()
                }
                columns = [name for name in rows[0].keys() if name in target_columns]
                statement = sql.SQL("INSERT INTO {} ({}) VALUES ({}) ON CONFLICT DO NOTHING").format(
                    sql.Identifier(table),
                    sql.SQL(", ").join(map(sql.Identifier, columns)),
                    sql.SQL(", ").join(sql.Placeholder() for _ in columns),
                )
                cursor.executemany(
                    statement,
                    [tuple(row[column] for column in columns) for row in rows],
                )
                print(f"{table}: considered {len(rows)} row(s)")

            for table in TABLES:
                if "id" not in {
                    row[0]
                    for row in cursor.execute(
                        """SELECT column_name FROM information_schema.columns
                        WHERE table_schema = 'public' AND table_name = %s""",
                        (table,),
                    ).fetchall()
                }:
                    continue
                sequence = cursor.execute(
                    "SELECT pg_get_serial_sequence(%s, 'id')",
                    (table,),
                ).fetchone()[0]
                if sequence:
                    cursor.execute(
                        sql.SQL(
                            "SELECT setval(%s, COALESCE((SELECT MAX(id) FROM {}), 1), true)"
                        ).format(sql.Identifier(table)),
                        (sequence,),
                    )
        target.commit()
    except Exception:
        target.rollback()
        raise
    finally:
        target.close()
        source.close()
    print("Migration completed without exposing credentials or stored secrets.")


if __name__ == "__main__":
    main()
