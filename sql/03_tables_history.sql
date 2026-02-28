-- ================================================================
-- HISTORY TABLES (transaction-time)
-- ================================================================

CREATE TABLE IF NOT EXISTS clients_history (
  history_id  SERIAL      PRIMARY KEY,
  client_id   INT         NOT NULL,
  first_name  VARCHAR(50),
  last_name   VARCHAR(50),
  personal_no VARCHAR(20),
  phone       VARCHAR(20),
  email       VARCHAR(100),
  client_type client_type,
  valid_from  DATE,
  valid_to    DATE,
  sys_start   TIMESTAMPTZ NOT NULL,
  sys_end     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  changed_by  INT,
  operation   CHAR(1)     NOT NULL
);

CREATE TABLE IF NOT EXISTS agents_history (
  history_id           SERIAL       PRIMARY KEY,
  agent_id             INT          NOT NULL,
  first_name           VARCHAR(50),
  last_name            VARCHAR(50),
  phone                VARCHAR(20),
  email                VARCHAR(100),
  hire_date            DATE,
  base_commission_rate NUMERIC(5,2),
  is_active            BOOLEAN,
  valid_from           DATE,
  valid_to             DATE,
  sys_start            TIMESTAMPTZ  NOT NULL,
  sys_end              TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  changed_by           INT,
  operation            CHAR(1)      NOT NULL
);

CREATE TABLE IF NOT EXISTS properties_history (
  history_id    SERIAL        PRIMARY KEY,
  property_id   INT           NOT NULL,
  seller_id     INT,
  property_type property_type,
  city          VARCHAR(50),
  address       VARCHAR(120),
  area_m2       NUMERIC(10,2),
  rooms         SMALLINT,
  floor         SMALLINT,
  year_built    SMALLINT,
  valid_from    DATE,
  valid_to      DATE,
  sys_start     TIMESTAMPTZ   NOT NULL,
  sys_end       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  changed_by    INT,
  operation     CHAR(1)       NOT NULL
);

CREATE TABLE IF NOT EXISTS listings_history (
  history_id  SERIAL         PRIMARY KEY,
  listing_id  INT            NOT NULL,
  property_id INT,
  agent_id    INT,
  list_price  NUMERIC(18,2),
  currency    currency_type,
  valid_from  DATE,
  valid_to    DATE,
  status      listing_status,
  sys_start   TIMESTAMPTZ    NOT NULL,
  sys_end     TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  changed_by  INT,
  operation   CHAR(1)        NOT NULL
);

CREATE TABLE IF NOT EXISTS contracts_history (
  history_id      SERIAL          PRIMARY KEY,
  contract_id     INT             NOT NULL,
  property_id     INT,
  buyer_id        INT,
  seller_id       INT,
  agent_id        INT,
  contract_date   DATE,
  sale_price      NUMERIC(18,2),
  commission_rate NUMERIC(5,2),
  status          contract_status,
  notes           TEXT,
  sys_start       TIMESTAMPTZ     NOT NULL,
  sys_end         TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
  changed_by      INT,
  operation       CHAR(1)         NOT NULL
);