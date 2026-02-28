-- ================================================================
-- TRIGGERS
-- ================================================================

DROP TRIGGER IF EXISTS trg_clients_hist    ON clients;
DROP TRIGGER IF EXISTS trg_agents_hist     ON agents;
DROP TRIGGER IF EXISTS trg_properties_hist ON properties;
DROP TRIGGER IF EXISTS trg_listings_hist   ON listings;
DROP TRIGGER IF EXISTS trg_contracts_hist  ON contracts;
DROP TRIGGER IF EXISTS trg_close_listing   ON contracts;

CREATE TRIGGER trg_clients_hist
  BEFORE UPDATE OR DELETE ON clients
  FOR EACH ROW EXECUTE FUNCTION trg_clients_history();

CREATE TRIGGER trg_agents_hist
  BEFORE UPDATE OR DELETE ON agents
  FOR EACH ROW EXECUTE FUNCTION trg_agents_history();

CREATE TRIGGER trg_properties_hist
  BEFORE UPDATE OR DELETE ON properties
  FOR EACH ROW EXECUTE FUNCTION trg_properties_history();

CREATE TRIGGER trg_listings_hist
  BEFORE UPDATE OR DELETE ON listings
  FOR EACH ROW EXECUTE FUNCTION trg_listings_history();

CREATE TRIGGER trg_contracts_hist
  BEFORE UPDATE OR DELETE ON contracts
  FOR EACH ROW EXECUTE FUNCTION trg_contracts_history();

CREATE TRIGGER trg_close_listing
  AFTER INSERT OR UPDATE ON contracts
  FOR EACH ROW EXECUTE FUNCTION trg_close_listing_on_contract();