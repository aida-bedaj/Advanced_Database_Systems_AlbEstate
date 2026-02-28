from __future__ import annotations

import os
from datetime import date, datetime, timezone
from typing import Optional

from dotenv import load_dotenv
from fastapi import Depends, FastAPI, HTTPException, Header, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from . import db
from .security import create_access_token, verify_password, decode_token

load_dotenv()

app = FastAPI(title="AlbEstate (Bitemporal) — Python + PostgreSQL", version="1.0.0")

bearer_scheme = HTTPBearer()

@app.get("/")
def root():
    return {
        "ok": True,
        "service": "AlbEstate API",
        "docs": "/docs",
        "health": "/health",
    }

@app.get("/health")
def health():
    return {"ok": True}

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # tighten for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------
# Auth helpers
# -----------------------------
class LoginIn(BaseModel):
    username: str
    password: str


class TokenOut(BaseModel):
    ok: bool = True
    token: str
    user: dict


def get_current_user(
    creds: HTTPAuthorizationCredentials = Depends(bearer_scheme),
) -> dict:
    token = creds.credentials
    try:
        payload = decode_token(token)
        return {
            "user_id": int(payload["sub"]),
            "role": payload.get("role"),
            "agent_id": payload.get("agent_id"),
        }
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid or expired token")


def require_role(role: str):
    def _dep(user: dict = Depends(get_current_user)) -> dict:
        if user.get("role") != role:
            raise HTTPException(status_code=403, detail=f"{role} only")
        return user

    return _dep


# -----------------------------
# Auth routes
# -----------------------------
@app.post("/api/auth/login", response_model=TokenOut)
def login(body: LoginIn):
    user = db.fetch_one(
        "SELECT user_id, username, role::text AS role, agent_id, pass_hash "
        "FROM users WHERE username=%s AND is_active=TRUE",
        (body.username.strip(),),
    )
    if not user or not verify_password(body.password, user["pass_hash"]):
        raise HTTPException(status_code=401, detail="Invalid username or password")

    token = create_access_token(sub=str(user["user_id"]), role=user["role"], agent_id=user["agent_id"])
    return TokenOut(
        token=token,
        user={"username": user["username"], "role": user["role"], "agent_id": user["agent_id"]},
    )


@app.get("/api/auth/me")
def me(user: dict = Depends(get_current_user)):
    return {"ok": True, "user": user}


# -----------------------------
# Public routes
# -----------------------------
@app.get("/api/public/listings")
def public_listings(
    city: Optional[str] = None,
    type: Optional[str] = None,
    minPrice: Optional[float] = None,
    maxPrice: Optional[float] = None,
    minArea: Optional[float] = None,
    page: int = 1,
    limit: int = 20,
):
    limit = max(1, min(limit, 200))
    offset = (max(1, page) - 1) * limit

    params = []
    conds = ["l.status='Active'", "p.is_deleted=FALSE"]
    if city:
        params.append(f"%{city}%")
        conds.append("p.city ILIKE %s")
    if type:
        params.append(type)
        conds.append("p.property_type=%s::property_type")
    if minPrice is not None:
        params.append(minPrice)
        conds.append("l.list_price >= %s")
    if maxPrice is not None:
        params.append(maxPrice)
        conds.append("l.list_price <= %s")
    if minArea is not None:
        params.append(minArea)
        conds.append("p.area_m2 >= %s")

    where = " AND ".join(conds)
    params_data = params + [limit, offset]

    data = db.fetch_all(
        f"""
        SELECT l.listing_id, l.property_id, l.list_price, l.currency::TEXT AS currency, l.status::TEXT AS status,
               p.property_type::TEXT AS property_type, p.city, p.address, p.area_m2, p.rooms
        FROM listings l
        JOIN properties p ON p.property_id = l.property_id
        WHERE {where}
        ORDER BY l.listing_id DESC
        LIMIT %s OFFSET %s
        """,
        tuple(params_data),
    )
    return {"ok": True, "data": data, "page": page, "limit": limit}


# -----------------------------
# Admin routes
# -----------------------------
@app.get("/api/admin/stats")
def admin_stats(user: dict = Depends(require_role("Admin"))):
    stats = db.fetch_one(
        """
        SELECT
          (SELECT COUNT(*) FROM properties WHERE is_deleted=FALSE)::INT AS properties,
          (SELECT COUNT(*) FROM clients    WHERE is_deleted=FALSE)::INT AS clients,
          (SELECT COUNT(*) FROM agents     WHERE is_active=TRUE)::INT AS agents,
          (SELECT COUNT(*) FROM listings   WHERE status='Active')::INT AS active_listings
        """
    )
    return {"ok": True, "data": stats}


# -----------------------------
# Agent routes
# -----------------------------
def require_agent(user: dict = Depends(get_current_user)) -> dict:
    if user.get("role") != "Agent":
        raise HTTPException(status_code=403, detail="Agent only")
    if not user.get("agent_id"):
        raise HTTPException(status_code=403, detail="User not linked to an agent record")
    return user


@app.get("/api/agent/me")
def agent_me(user: dict = Depends(require_agent)):
    r = db.fetch_one("SELECT * FROM agents WHERE agent_id=%s", (int(user["agent_id"]),))
    return {"ok": True, "data": r}


@app.get("/api/agent/listings")
def agent_listings(user: dict = Depends(require_agent), page: int = 1, limit: int = 20):
    limit = max(1, min(limit, 100))
    offset = (max(1, page) - 1) * limit
    agent_id = int(user["agent_id"])

    data = db.fetch_all(
        """
        SELECT l.*, l.currency::TEXT AS currency, l.status::TEXT AS status,
               p.property_type::TEXT AS property_type, p.city, p.address, p.area_m2, p.rooms, p.floor, p.year_built
        FROM listings l
        JOIN properties p ON p.property_id = l.property_id
        WHERE l.agent_id=%s
        ORDER BY l.listing_id DESC
        LIMIT %s OFFSET %s
        """,
        (agent_id, limit, offset),
    )
    count = db.fetch_one("SELECT COUNT(*)::INT AS c FROM listings WHERE agent_id=%s", (agent_id,))
    return {"ok": True, "data": data, "page": page, "limit": limit, "total": count["c"]}


# -----------------------------
# Bitemporal demo route (Admin only)
# -----------------------------
@app.get("/api/bitemporal/client/{client_id}")
def client_as_of(
    client_id: int,
    valid_date: date = Query(default_factory=date.today, description="Valid date (YYYY-MM-DD)"),
    tx_time: datetime = Query(
        default_factory=lambda: datetime.now(timezone.utc),
        description="Transaction time (ISO timestamp)",
    ),
    user: dict = Depends(require_role("Admin")),
):
    # Demonstrates bitemporal query using the SQL function.
    row = db.fetch_one(
        "SELECT * FROM bt_client_as_of(%s, %s::date, %s::timestamptz)",
        (client_id, valid_date.isoformat(), tx_time.isoformat()),
    )
    return {"ok": True, "data": row}