# AlbEstate (Bitemporal) — Python + PostgreSQL

This is a bitemporal database project implemented with:
- **PostgreSQL** for storage (Valid Time + Transaction Time via history tables)
- **Python + FastAPI** for the API (no HTML front-end required)
- **JWT authentication** (Admin / Agent)

> Bitemporal model used here:
> - **Valid Time**: `valid_from`, `valid_to` on base tables (what is true in the business world)
> - **Transaction Time**: `sys_start`, `sys_end` on `*_history` tables (what the system knew, and when)

## 0) What you need installed
1. **PostgreSQL** (and `psql` command)
2. **Python 3.11+**
3. **VS Code** + the Python extension

## 1) Create the project folder
Unzip this project somewhere, e.g. `C:\Projects\albestate_python`.

## 2) Create a Python virtual environment (VS Code)
Open VS Code → *File → Open Folder* → choose the project folder.

Open the terminal inside VS Code:
- Windows PowerShell:
  ```powershell
  py -m venv .venv
  .\.venv\Scripts\Activate.ps1
  ```
- macOS/Linux:
  ```bash
  python3 -m venv .venv
  source .venv/bin/activate
  ```

Install packages:
```bash
pip install -r requirements.txt
```

## 3) Create the database in PostgreSQL
Open a terminal (VS Code terminal is fine) and run:

```bash
createdb -U postgres albestate
```

If `createdb` is not available, open `psql`:
```bash
psql -U postgres
```
and run:
```sql
CREATE DATABASE albestate;
\q
```

## 4) Run the schema (creates tables, triggers, views)
From the project root:

```bash
psql -U postgres -d albestate -f sql/schema.sql
```

## 5) Configure environment variables
Copy `.env.example` to `.env` in the project root.

- On Windows:
  - Right click `.env.example` → copy → paste → rename to `.env`
- Then edit `.env` and set:
  - `DB_PASSWORD`
  - `JWT_SECRET` (any long random string)

**Important:** `JWT_SECRET` is the Python replacement for `SESSION_SECRET` in the Node version.

## 6) Seed demo data (creates admin/agent accounts)
```bash
python seed.py
```

This creates:
- `admin / admin123`
- `agent / agent123`

## 7) Start the API server
```bash
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

Open in browser:
- Swagger UI: http://127.0.0.1:8000/docs

## 8) Try the system quickly (Swagger UI)
1. **POST** `/api/auth/login` with:
   ```json
   {"username":"admin","password":"admin123"}
   ```
   Copy the `token`.

2. Click **Authorize** (top right) and paste:
   ```
   Bearer <token>
   ```

3. Call:
- `/api/admin/stats`
- `/api/public/listings`
- `/api/agent/me` (login as agent to use this)

## 9) Bitemporal demo query
Endpoint:
- `GET /api/bitemporal/client/{client_id}?valid_date=2026-02-28&tx_time=2026-02-28T10:00:00Z`

This calls the SQL function `bt_client_as_of(...)` which demonstrates:
- valid-time filtering (`valid_date between valid_from and valid_to`)
- transaction-time filtering (`tx_time between sys_start and sys_end`)
