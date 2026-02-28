from __future__ import annotations

import os
from datetime import datetime, timedelta, timezone
from typing import Any, Optional

from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError
from jose import jwt


# Argon2id is a modern, strong default
_ph = PasswordHasher()

from jose import JWTError

def decode_token(token: str) -> dict[str, Any]:
    try:
        return jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALG])
    except JWTError:
        raise ValueError("Invalid or expired token")

JWT_SECRET = os.getenv("JWT_SECRET", "change_me")
JWT_ALG = "HS256"
JWT_EXP_MINUTES = int(os.getenv("JWT_EXP_MINUTES", "120"))


def hash_password(password: str) -> str:
    return _ph.hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    try:
        return _ph.verify(password_hash, password)
    except VerifyMismatchError:
        return False


def create_access_token(sub: str, role: str, agent_id: Optional[int] = None) -> str:
    now = datetime.now(timezone.utc)
    payload: dict[str, Any] = {
        "sub": sub,
        "role": role,
        "agent_id": agent_id,
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(minutes=JWT_EXP_MINUTES)).timestamp()),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALG)