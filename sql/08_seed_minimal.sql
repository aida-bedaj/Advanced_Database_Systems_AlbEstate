-- Minimal seed. Use python seed.py for real bcrypt hashes.
INSERT INTO users(username, pass_hash, role)
VALUES ('admin', '$2b$12$REPLACE_WITH_REAL_HASH', 'Admin')
ON CONFLICT (username) DO NOTHING;