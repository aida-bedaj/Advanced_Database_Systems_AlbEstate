-- ================================================================
-- HISTORY TRIGGER FUNCTIONS
-- ================================================================

CREATE OR REPLACE FUNCTION trg_clients_history() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    INSERT INTO clients_history(client_id,first_name,last_name,personal_no,phone,email,
      client_type,valid_from,valid_to,sys_start,sys_end,changed_by,operation)
    VALUES(OLD.client_id,OLD.first_name,OLD.last_name,OLD.personal_no,OLD.phone,OLD.email,
      OLD.client_type,OLD.valid_from,OLD.valid_to,OLD.updated_at,NOW(),OLD.updated_by,'D');
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO clients_history(client_id,first_name,last_name,personal_no,phone,email,
      client_type,valid_from,valid_to,sys_start,sys_end,changed_by,operation)
    VALUES(OLD.client_id,OLD.first_name,OLD.last_name,OLD.personal_no,OLD.phone,OLD.email,
      OLD.client_type,OLD.valid_from,OLD.valid_to,OLD.updated_at,NOW(),OLD.updated_by,'U');
  END IF;

  NEW.updated_at := NOW();
  RETURN NEW;
END;$$;

CREATE OR REPLACE FUNCTION trg_agents_history() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    INSERT INTO agents_history(agent_id,first_name,last_name,phone,email,hire_date,
      base_commission_rate,is_active,valid_from,valid_to,sys_start,sys_end,changed_by,operation)
    VALUES(OLD.agent_id,OLD.first_name,OLD.last_name,OLD.phone,OLD.email,OLD.hire_date,
      OLD.base_commission_rate,OLD.is_active,OLD.valid_from,OLD.valid_to,OLD.updated_at,NOW(),OLD.updated_by,'D');
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO agents_history(agent_id,first_name,last_name,phone,email,hire_date,
      base_commission_rate,is_active,valid_from,valid_to,sys_start,sys_end,changed_by,operation)
    VALUES(OLD.agent_id,OLD.first_name,OLD.last_name,OLD.phone,OLD.email,OLD.hire_date,
      OLD.base_commission_rate,OLD.is_active,OLD.valid_from,OLD.valid_to,OLD.updated_at,NOW(),OLD.updated_by,'U');
  END IF;

  NEW.updated_at := NOW();
  RETURN NEW;
END;$$;

CREATE OR REPLACE FUNCTION trg_properties_history() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    INSERT INTO properties_history(property_id,seller_id,property_type,city,address,
      area_m2,rooms,floor,year_built,valid_from,valid_to,sys_start,sys_end,changed_by,operation)
    VALUES(OLD.property_id,OLD.seller_id,OLD.property_type,OLD.city,OLD.address,
      OLD.area_m2,OLD.rooms,OLD.floor,OLD.year_built,OLD.valid_from,OLD.valid_to,
      OLD.updated_at,NOW(),OLD.updated_by,'D');
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO properties_history(property_id,seller_id,property_type,city,address,
      area_m2,rooms,floor,year_built,valid_from,valid_to,sys_start,sys_end,changed_by,operation)
    VALUES(OLD.property_id,OLD.seller_id,OLD.property_type,OLD.city,OLD.address,
      OLD.area_m2,OLD.rooms,OLD.floor,OLD.year_built,OLD.valid_from,OLD.valid_to,
      OLD.updated_at,NOW(),OLD.updated_by,'U');
  END IF;

  NEW.updated_at := NOW();
  RETURN NEW;
END;$$;

CREATE OR REPLACE FUNCTION trg_listings_history() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    INSERT INTO listings_history(listing_id,property_id,agent_id,list_price,currency,
      valid_from,valid_to,status,sys_start,sys_end,changed_by,operation)
    VALUES(OLD.listing_id,OLD.property_id,OLD.agent_id,OLD.list_price,OLD.currency,
      OLD.valid_from,OLD.valid_to,OLD.status,OLD.updated_at,NOW(),OLD.updated_by,'D');
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO listings_history(listing_id,property_id,agent_id,list_price,currency,
      valid_from,valid_to,status,sys_start,sys_end,changed_by,operation)
    VALUES(OLD.listing_id,OLD.property_id,OLD.agent_id,OLD.list_price,OLD.currency,
      OLD.valid_from,OLD.valid_to,OLD.status,OLD.updated_at,NOW(),OLD.updated_by,'U');
  END IF;

  NEW.updated_at := NOW();
  RETURN NEW;
END;$$;

CREATE OR REPLACE FUNCTION trg_contracts_history() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    INSERT INTO contracts_history(contract_id,property_id,buyer_id,seller_id,agent_id,
      contract_date,sale_price,commission_rate,status,notes,sys_start,sys_end,changed_by,operation)
    VALUES(OLD.contract_id,OLD.property_id,OLD.buyer_id,OLD.seller_id,OLD.agent_id,
      OLD.contract_date,OLD.sale_price,OLD.commission_rate,OLD.status,OLD.notes,
      OLD.updated_at,NOW(),OLD.updated_by,'D');
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO contracts_history(contract_id,property_id,buyer_id,seller_id,agent_id,
      contract_date,sale_price,commission_rate,status,notes,sys_start,sys_end,changed_by,operation)
    VALUES(OLD.contract_id,OLD.property_id,OLD.buyer_id,OLD.seller_id,OLD.agent_id,
      OLD.contract_date,OLD.sale_price,OLD.commission_rate,OLD.status,OLD.notes,
      OLD.updated_at,NOW(),OLD.updated_by,'U');
  END IF;

  NEW.updated_at := NOW();
  RETURN NEW;
END;$$;

-- Auto-close listing when contract becomes Signed
CREATE OR REPLACE FUNCTION trg_close_listing_on_contract() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.status = 'Signed' AND (OLD IS NULL OR OLD.status <> 'Signed') THEN
    UPDATE listings
    SET status   = 'Closed',
        valid_to = LEAST(valid_to, CURRENT_DATE)  -- close valid time today
    WHERE property_id = NEW.property_id
      AND status = 'Active';
  END IF;
  RETURN NEW;
END;$$;

-- ================================================================
-- Bitemporal helper function: "valid on date AND known at tx time"
-- ================================================================
CREATE OR REPLACE FUNCTION bt_client_as_of(p_client_id INT, p_valid_date DATE, p_tx_time TIMESTAMPTZ)
RETURNS TABLE (
  client_id INT,
  first_name VARCHAR,
  last_name VARCHAR,
  personal_no VARCHAR,
  phone VARCHAR,
  email VARCHAR,
  client_type client_type,
  valid_from DATE,
  valid_to DATE
) LANGUAGE sql AS $$
  WITH versions AS (
    -- Current version (transaction interval = [updated_at, infinity))
    SELECT
      c.client_id, c.first_name, c.last_name, c.personal_no, c.phone, c.email,
      c.client_type, c.valid_from, c.valid_to,
      c.updated_at AS sys_start,
      'infinity'::timestamptz AS sys_end
    FROM clients c
    WHERE c.client_id = p_client_id

    UNION ALL

    -- Historical versions (transaction interval = [sys_start, sys_end))
    SELECT
      h.client_id, h.first_name, h.last_name, h.personal_no, h.phone, h.email,
      h.client_type, h.valid_from, h.valid_to,
      h.sys_start, h.sys_end
    FROM clients_history h
    WHERE h.client_id = p_client_id
  )
  SELECT client_id, first_name, last_name, personal_no, phone, email, client_type, valid_from, valid_to
  FROM versions
  WHERE p_tx_time >= sys_start AND p_tx_time < sys_end
    AND p_valid_date >= valid_from AND p_valid_date < valid_to
  ORDER BY sys_start DESC
  LIMIT 1;
$$;