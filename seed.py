from __future__ import annotations

import os
from dotenv import load_dotenv

from app import db
from app.security import hash_password

load_dotenv()

def seed():
    try:
        db.execute("BEGIN")

        # Admin user
        db.execute(
            """
            INSERT INTO users(username, pass_hash, role)
            VALUES (%s, %s, 'Admin')
            ON CONFLICT (username) DO UPDATE SET pass_hash=EXCLUDED.pass_hash
            """,
            ("admin", hash_password("admin123")),
        )

        # Agents
        db.execute(
            """
            INSERT INTO agents(first_name,last_name,phone,email,hire_date,base_commission_rate)
            VALUES
              ('Ergi','Ramci','+355691234567','ergi@albestate.al','2022-03-01',3.5),
              ('Fjona','Marishta','+355692345678','fjona@albestate.al','2021-06-15',4.0)
            ON CONFLICT(email) DO NOTHING
            """
        )

        # Create an Agent user mapped to first agent
        agent = db.fetch_one("SELECT agent_id FROM agents ORDER BY agent_id ASC LIMIT 1")
        if agent:
            db.execute(
                """
                INSERT INTO users(username, pass_hash, role, agent_id)
                VALUES (%s, %s, 'Agent', %s)
                ON CONFLICT(username) DO UPDATE SET pass_hash=EXCLUDED.pass_hash, agent_id=EXCLUDED.agent_id
                """,
                ("agent", hash_password("agent123"), agent["agent_id"]),
            )

        db.commit()
        print("Seed complete.")
        print("Login credentials:")
        print("  admin / admin123")
        print("  agent / agent123")
    except Exception as e:
        db.rollback()
        raise

if __name__ == "__main__":
    seed()
