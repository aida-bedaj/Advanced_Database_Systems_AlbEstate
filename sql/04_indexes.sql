-- ================================================================
-- INDEXES
-- ================================================================

CREATE INDEX IF NOT EXISTS idx_clients_valid      ON clients(valid_from, valid_to);
CREATE INDEX IF NOT EXISTS idx_clients_deleted    ON clients(is_deleted);
CREATE INDEX IF NOT EXISTS idx_clients_hist       ON clients_history(client_id, sys_start);

CREATE INDEX IF NOT EXISTS idx_agents_valid       ON agents(valid_from, valid_to);
CREATE INDEX IF NOT EXISTS idx_agents_hist        ON agents_history(agent_id, sys_start);

CREATE INDEX IF NOT EXISTS idx_props_city         ON properties(city);
CREATE INDEX IF NOT EXISTS idx_props_type         ON properties(property_type);
CREATE INDEX IF NOT EXISTS idx_props_deleted      ON properties(is_deleted);

CREATE INDEX IF NOT EXISTS idx_listings_status    ON listings(status);
CREATE INDEX IF NOT EXISTS idx_listings_agent     ON listings(agent_id);
CREATE INDEX IF NOT EXISTS idx_listings_property  ON listings(property_id);
CREATE INDEX IF NOT EXISTS idx_listings_hist      ON listings_history(listing_id, sys_start);

CREATE INDEX IF NOT EXISTS idx_contracts_agent    ON contracts(agent_id);
CREATE INDEX IF NOT EXISTS idx_contracts_buyer    ON contracts(buyer_id);
CREATE INDEX IF NOT EXISTS idx_contracts_date     ON contracts(contract_date);

CREATE INDEX IF NOT EXISTS idx_payments_contract  ON payments(contract_id);