from __future__ import annotations

import os
from dataclasses import dataclass
from typing import Any, Iterable, Optional

import psycopg
from dotenv import load_dotenv
from psycopg.rows import dict_row


# Load .env once, as early as possible (project root)
load_dotenv()


@dataclass(frozen=True)
class Settings:
    db_host: str
    db_port: int
    db_name: str
    db_user: str
    db_password: str

    @staticmethod
    def from_env() -> "Settings":
        return Settings(
            db_host=os.getenv("DB_HOST", "localhost"),
            db_port=int(os.getenv("DB_PORT", "5432")),
            db_name=os.getenv("DB_NAME", "albestate"),
            db_user=os.getenv("DB_USER", "postgres"),
            db_password=os.getenv("DB_PASSWORD", "2004"),
        )

    def dsn(self) -> str:
        # Keyword DSN format psycopg understands
        return (
            f"host={self.db_host} port={self.db_port} dbname={self.db_name} "
            f"user={self.db_user} password={self.db_password}"
        )


_settings = Settings.from_env()

# Fail fast if password is missing (prevents confusing psycopg errors)
if not _settings.db_password:
    raise RuntimeError(
        "DB_PASSWORD is missing. Create a .env file in the project root and set DB_PASSWORD=..."
    )

_conn: Optional[psycopg.Connection] = None


def get_conn() -> psycopg.Connection:
    """Single-connection helper (fine for a student project)."""
    global _conn
    if _conn is None or _conn.closed:
        _conn = psycopg.connect(_settings.dsn(), row_factory=dict_row, autocommit=False)
    return _conn


def fetch_all(sql: str, params: Iterable[Any] = ()) -> list[dict[str, Any]]:
    conn = get_conn()
    with conn.cursor() as cur:
        cur.execute(sql, params)
        return list(cur.fetchall())


def fetch_one(sql: str, params: Iterable[Any] = ()) -> Optional[dict[str, Any]]:
    conn = get_conn()
    with conn.cursor() as cur:
        cur.execute(sql, params)
        row = cur.fetchone()
        return dict(row) if row else None


def execute(sql: str, params: Iterable[Any] = ()) -> None:
    conn = get_conn()
    with conn.cursor() as cur:
        cur.execute(sql, params)


def commit() -> None:
    get_conn().commit()


def rollback() -> None:
    # Only rollback if connection exists and is open
    global _conn
    if _conn is not None and not _conn.closed:
        _conn.rollback()