-- ================================================================
-- CORE TABLES (Valid-time in main tables where relevant)
-- ================================================================

-- USERS (auth)
CREATE TABLE IF NOT EXISTS users (
  user_id    SERIAL       PRIMARY KEY,
  username   VARCHAR(50)  NOT NULL UNIQUE,
  pass_hash  VARCHAR(255) NOT NULL,
  role       user_role    NOT NULL,
  agent_id   INT          NULL,
  is_active  BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- CLIENTS (bitemporal: valid-time in base + tx-time in history)
CREATE TABLE IF NOT EXISTS clients (
  client_id   SERIAL       PRIMARY KEY,
  first_name  VARCHAR(50)  NOT NULL,
  last_name   VARCHAR(50)  NOT NULL,
  personal_no VARCHAR(20)  NOT NULL UNIQUE,
  phone       VARCHAR(20)  NOT NULL,
  email       VARCHAR(100),
  client_type client_type  NOT NULL,

  valid_from  DATE         NOT NULL DEFAULT CURRENT_DATE,
  valid_to    DATE         NOT NULL DEFAULT '9999-12-31',
  CONSTRAINT ck_clients_valid CHECK (valid_to > valid_from),

  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_by  INT          REFERENCES users(user_id),
  is_deleted  BOOLEAN      NOT NULL DEFAULT FALSE
);

-- AGENTS (bitemporal: valid-time in base + tx-time in history)
CREATE TABLE IF NOT EXISTS agents (
  agent_id             SERIAL        PRIMARY KEY,
  first_name           VARCHAR(50)   NOT NULL,
  last_name            VARCHAR(50)   NOT NULL,
  phone                VARCHAR(20)   NOT NULL,
  email                VARCHAR(100)  NOT NULL UNIQUE,
  hire_date            DATE          NOT NULL,
  base_commission_rate NUMERIC(5,2)  NOT NULL DEFAULT 3.0
                       CHECK (base_commission_rate BETWEEN 0 AND 20),
  is_active            BOOLEAN       NOT NULL DEFAULT TRUE,

  valid_from           DATE          NOT NULL DEFAULT CURRENT_DATE,
  valid_to             DATE          NOT NULL DEFAULT '9999-12-31',
  CONSTRAINT ck_agents_valid CHECK (valid_to > valid_from),

  created_at           TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at           TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_by           INT           REFERENCES users(user_id)
);

-- PROPERTIES (now includes valid-time so "current" views work)
CREATE TABLE IF NOT EXISTS properties (
  property_id   SERIAL        PRIMARY KEY,
  seller_id     INT           NOT NULL REFERENCES clients(client_id),
  property_type property_type NOT NULL,
  city          VARCHAR(50)   NOT NULL,
  address       VARCHAR(120)  NOT NULL,
  area_m2       NUMERIC(10,2) NOT NULL CHECK (area_m2 > 0),
  rooms         SMALLINT,
  floor         SMALLINT,
  year_built    SMALLINT,

  valid_from    DATE          NOT NULL DEFAULT CURRENT_DATE,
  valid_to      DATE          NOT NULL DEFAULT '9999-12-31',
  CONSTRAINT ck_properties_valid CHECK (valid_to > valid_from),

  created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_by    INT           REFERENCES users(user_id),
  is_deleted    BOOLEAN       NOT NULL DEFAULT FALSE
);

-- LISTINGS (valid_from/valid_to instead of start_date/end_date)
CREATE TABLE IF NOT EXISTS listings (
  listing_id  SERIAL         PRIMARY KEY,
  property_id INT            NOT NULL REFERENCES properties(property_id),
  agent_id    INT            NOT NULL REFERENCES agents(agent_id),
  list_price  NUMERIC(18,2)  NOT NULL CHECK (list_price > 0),
  currency    currency_type  NOT NULL DEFAULT 'EUR',

  valid_from  DATE           NOT NULL DEFAULT CURRENT_DATE,
  valid_to    DATE           NOT NULL DEFAULT '9999-12-31',
  CONSTRAINT ck_listings_valid CHECK (valid_to > valid_from),

  status      listing_status NOT NULL DEFAULT 'Active',
  created_at  TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  updated_by  INT            REFERENCES users(user_id)
);

-- CONTRACTS
CREATE TABLE IF NOT EXISTS contracts (
  contract_id       SERIAL          PRIMARY KEY,
  property_id       INT             NOT NULL REFERENCES properties(property_id),
  buyer_id          INT             NOT NULL REFERENCES clients(client_id),
  seller_id         INT             NOT NULL REFERENCES clients(client_id),
  agent_id          INT             NOT NULL REFERENCES agents(agent_id),
  contract_date     DATE            NOT NULL DEFAULT CURRENT_DATE,
  sale_price        NUMERIC(18,2)   NOT NULL CHECK (sale_price > 0),
  commission_rate   NUMERIC(5,2)    NOT NULL CHECK (commission_rate BETWEEN 0 AND 20),
  status            contract_status NOT NULL DEFAULT 'Draft',
  notes             TEXT,
  CONSTRAINT ck_contracts_parties CHECK (buyer_id <> seller_id),
  created_at        TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
  updated_by        INT             REFERENCES users(user_id)
);

-- PAYMENTS (immutable)
CREATE TABLE IF NOT EXISTS payments (
  payment_id      SERIAL           PRIMARY KEY,
  contract_id     INT              NOT NULL REFERENCES contracts(contract_id),
  payment_date    DATE             NOT NULL DEFAULT CURRENT_DATE,
  amount          NUMERIC(18,2)    NOT NULL CHECK (amount > 0),
  payment_method  payment_method   NOT NULL,
  payment_type    payment_type_val NOT NULL,
  notes           TEXT,
  created_at      TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
  created_by      INT              REFERENCES users(user_id)
);