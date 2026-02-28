-- ================================================================
-- ANALYTICS VIEWS
-- ================================================================

CREATE OR REPLACE VIEW vw_agent_performance AS
SELECT a.agent_id,
  a.first_name||' '||a.last_name AS agent_name,
  a.base_commission_rate,
  COUNT(DISTINCT c.contract_id)  AS total_contracts,
  COALESCE(SUM(c.sale_price),0)  AS total_sales,
  COALESCE(AVG(c.sale_price),0)  AS avg_sale_price,
  COUNT(DISTINCT c.buyer_id)     AS unique_clients
FROM agents a
LEFT JOIN contracts c ON c.agent_id=a.agent_id AND c.status='Signed'
GROUP BY a.agent_id,a.first_name,a.last_name,a.base_commission_rate;

CREATE OR REPLACE VIEW vw_client_behavior AS
SELECT cl.client_id,
  cl.first_name||' '||cl.last_name AS client_name,
  cl.email, cl.client_type,
  COUNT(DISTINCT c.contract_id)     AS total_contracts,
  COALESCE(SUM(c.sale_price),0)     AS total_spent,
  MIN(c.contract_date)              AS first_purchase,
  MAX(c.contract_date)              AS last_purchase
FROM clients cl
LEFT JOIN contracts c ON c.buyer_id=cl.client_id AND c.status='Signed'
WHERE cl.is_deleted=FALSE
GROUP BY cl.client_id,cl.first_name,cl.last_name,cl.email,cl.client_type;

CREATE OR REPLACE VIEW vw_property_performance AS
SELECT p.property_id, p.property_type, p.city, p.address,
  COUNT(DISTINCT c.contract_id)  AS total_contracts,
  COALESCE(SUM(c.sale_price),0)  AS total_value,
  COUNT(DISTINCT l.listing_id)   AS total_listings,
  COUNT(DISTINCT l.listing_id) FILTER(WHERE l.status='Active')  AS active_listings
FROM properties p
LEFT JOIN contracts c ON c.property_id=p.property_id AND c.status='Signed'
LEFT JOIN listings  l ON l.property_id=p.property_id
WHERE p.is_deleted=FALSE
GROUP BY p.property_id,p.property_type,p.city,p.address;

-- ================================================================
-- BITEMPORAL UNION VIEWS (Current + History)
-- ================================================================

CREATE OR REPLACE VIEW vw_listing_price_history AS
SELECT listing_id,list_price,currency::TEXT,status::TEXT,
  valid_from, valid_to,
  sys_start AS recorded_from, sys_end AS recorded_to, 'Historical' AS version_type
FROM listings_history
UNION ALL
SELECT listing_id,list_price,currency::TEXT,status::TEXT,
  valid_from, valid_to,
  updated_at, 'infinity'::timestamptz, 'Current'
FROM listings;

CREATE OR REPLACE VIEW vw_agent_commission_history AS
SELECT agent_id,first_name,last_name,base_commission_rate,
  valid_from,valid_to,
  sys_start AS recorded_from, sys_end AS recorded_to, 'Historical' AS version_type
FROM agents_history
UNION ALL
SELECT agent_id,first_name,last_name,base_commission_rate,
  valid_from,valid_to,
  updated_at,'infinity'::timestamptz,'Current'
FROM agents;

-- ================================================================
-- "CURRENT" CONVENIENCE VIEWS (valid today)
-- ================================================================

CREATE OR REPLACE VIEW v_clients_current AS
SELECT *
FROM clients
WHERE is_deleted = FALSE
  AND CURRENT_DATE >= valid_from
  AND CURRENT_DATE <  valid_to;

CREATE OR REPLACE VIEW v_properties_current AS
SELECT *
FROM properties
WHERE is_deleted = FALSE
  AND CURRENT_DATE >= valid_from
  AND CURRENT_DATE <  valid_to;

CREATE OR REPLACE VIEW v_listings_current AS
SELECT l.*, p.city, p.address, p.property_type::TEXT
FROM listings l
JOIN properties p ON p.property_id = l.property_id
WHERE l.status = 'Active'
  AND p.is_deleted = FALSE
  AND CURRENT_DATE >= l.valid_from
  AND CURRENT_DATE <  l.valid_to;