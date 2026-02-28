-- ENUM TYPES (idempotent)
DO $$ BEGIN
  CREATE TYPE client_type AS ENUM ('Buyer','Seller','Both');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE property_type AS ENUM ('Apartment','House','Land','Commercial');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE currency_type AS ENUM ('EUR','ALL','USD');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE listing_status AS ENUM ('Active','Closed','Suspended');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE contract_status AS ENUM ('Draft','Signed','Cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE payment_method AS ENUM ('Cash','Bank','Card');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE payment_type_val AS ENUM ('Deposit','Installment','Final');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE user_role AS ENUM ('Admin','Agent');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;