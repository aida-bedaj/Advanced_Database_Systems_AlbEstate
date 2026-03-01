BEGIN;

-- Use admin user_id if exists (seed.py creates it)
WITH admin_u AS (
  SELECT user_id FROM users WHERE username='admin' LIMIT 1
)

-- -------------------------
-- 1) CLIENTS (50)
-- -------------------------
INSERT INTO clients (first_name,last_name,personal_no,phone,email,client_type,valid_from,valid_to,updated_by,is_deleted)
SELECT v.first_name, v.last_name, v.personal_no, v.phone, v.email, v.client_type::client_type,
       CURRENT_DATE, '9999-12-31', (SELECT user_id FROM admin_u), FALSE
FROM (VALUES
('Ardit','Hoxha','PN001','+35569000001','ardit.hoxha@mail.com','Buyer'),
('Erion','Krasniqi','PN002','+35569000002','erion.krasniqi@mail.com','Seller'),
('Aida','Gashi','PN003','+35569000003','aida.gashi@mail.com','Buyer'),
('Blerta','Dervishi','PN004','+35569000004','blerta.dervishi@mail.com','Seller'),
('Elton','Shehu','PN005','+35569000005','elton.shehu@mail.com','Buyer'),
('Klea','Kola','PN006','+35569000006','klea.kola@mail.com','Seller'),
('Gentian','Leka','PN007','+35569000007','gentian.leka@mail.com','Both'),
('Besa','Meta','PN008','+35569000008','besa.meta@mail.com','Seller'),
('Alban','Berisha','PN009','+35569000009','alban.berisha@mail.com','Buyer'),
('Diana','Kastrati','PN010','+35569000010','diana.kastrati@mail.com','Both'),
('Ilir','Gjoni','PN011','+35569000011','ilir.gjoni@mail.com','Seller'),
('Arlinda','Basha','PN012','+35569000012','arlinda.basha@mail.com','Buyer'),
('Besnik','Tafa','PN013','+35569000013','besnik.tafa@mail.com','Seller'),
('Megi','Haziri','PN014','+35569000014','megi.haziri@mail.com','Buyer'),
('Sokol','Kamberi','PN015','+35569000015','sokol.kamberi@mail.com','Seller'),
('Anisa','Qerimi','PN016','+35569000016','anisa.qerimi@mail.com','Buyer'),
('Florian','Rama','PN017','+35569000017','florian.rama@mail.com','Both'),
('Elda','Hasani','PN018','+35569000018','elda.hasani@mail.com','Seller'),
('Valon','Islami','PN019','+35569000019','valon.islami@mail.com','Buyer'),
('Marigona','Kurtaj','PN020','+35569000020','marigona.kurtaj@mail.com','Seller'),
('Lorik','Demiri','PN021','+35569000021','lorik.demiri@mail.com','Buyer'),
('Enxhi','Kelmendi','PN022','+35569000022','enxhi.kelmendi@mail.com','Seller'),
('Artan','Hajdari','PN023','+35569000023','artan.hajdari@mail.com','Buyer'),
('Gentiana','Xhaferi','PN024','+35569000024','gentiana.xhaferi@mail.com','Seller'),
('Kreshnik','Zeqiri','PN025','+35569000025','kreshnik.zeqiri@mail.com','Both'),
('Jona','Tahiri','PN026','+35569000026','jona.tahiri@mail.com','Buyer'),
('Arben','Vata','PN027','+35569000027','arben.vata@mail.com','Seller'),
('Ornela','Spahiu','PN028','+35569000028','ornela.spahiu@mail.com','Buyer'),
('Shkelzen','Pllana','PN029','+35569000029','shkelzen.pllana@mail.com','Seller'),
('Lediana','Musa','PN030','+35569000030','lediana.musa@mail.com','Buyer'),
('Armand','Syla','PN031','+35569000031','armand.syla@mail.com','Seller'),
('Valbona','Duka','PN032','+35569000032','valbona.duka@mail.com','Buyer'),
('Endrit','Lleshi','PN033','+35569000033','endrit.lleshi@mail.com','Seller'),
('Sara','Bregu','PN034','+35569000034','sara.bregu@mail.com','Buyer'),
('Fatjon','Koci','PN035','+35569000035','fatjon.koci@mail.com','Seller'),
('Aurela','Shala','PN036','+35569000036','aurela.shala@mail.com','Buyer'),
('Ermal','Hysa','PN037','+35569000037','ermal.hysa@mail.com','Both'),
('Anxhela','Gega','PN038','+35569000038','anxhela.gega@mail.com','Seller'),
('Klodian','Rexhepi','PN039','+35569000039','klodian.rexhepi@mail.com','Buyer'),
('Elira','Kajtazi','PN040','+35569000040','elira.kajtazi@mail.com','Seller'),
('Adriatik','Hoxhaj','PN041','+35569000041','adriatik.hoxhaj@mail.com','Buyer'),
('Rovena','Zogaj','PN042','+35569000042','rovena.zogaj@mail.com','Seller'),
('Blerim','Kamberi','PN043','+35569000043','blerim.kamberi@mail.com','Buyer'),
('Mirela','Toska','PN044','+35569000044','mirela.toska@mail.com','Seller'),
('Artur','Hila','PN045','+35569000045','artur.hila@mail.com','Buyer'),
('Denisa','Nela','PN046','+35569000046','denisa.nela@mail.com','Seller'),
('Bujar','Cani','PN047','+35569000047','bujar.cani@mail.com','Buyer'),
('Flutura','Kaceli','PN048','+35569000048','flutura.kaceli@mail.com','Seller'),
('Gerti','Mema','PN049','+35569000049','gerti.mema@mail.com','Buyer'),
('Venera','Gashi','PN050','+35569000050','venera.gashi@mail.com','Seller')
) AS v(first_name,last_name,personal_no,phone,email,client_type)
ON CONFLICT (personal_no) DO NOTHING;

-- -------------------------
-- 2) AGENTS (20) 
-- -------------------------
WITH admin_u AS (SELECT user_id FROM users WHERE username='admin' LIMIT 1)
INSERT INTO agents (first_name,last_name,phone,email,hire_date,base_commission_rate,is_active,valid_from,valid_to,updated_by)
SELECT v.first_name, v.last_name, v.phone, v.email, v.hire_date::date, v.base_commission_rate, TRUE,
       CURRENT_DATE, '9999-12-31', (SELECT user_id FROM admin_u)
FROM (VALUES
('Ina','Kola','+35568000001','ina.kola@agency.al', DATE '2022-01-15', 3.00),
('Erisa','Hoxha','+35568000002','erisa.hoxha@agency.al', DATE '2021-03-10', 3.50),
('Altin','Leka','+35568000003','altin.leka@agency.al', DATE '2020-06-01', 2.80),
('Kledi','Dervishi','+35568000004','kledi.dervishi@agency.al', DATE '2019-09-12', 3.20),
('Gent','Meta','+35568000005','gent.meta@agency.al', DATE '2018-11-20', 3.00),
('Sara','Shehu','+35568000006','sara.shehu@agency.al', DATE '2020-02-14', 2.90),
('Arjan','Berisha','+35568000007','arjan.berisha@agency.al', DATE '2017-05-05', 3.80),
('Elona','Krasniqi','+35568000008','elona.krasniqi@agency.al', DATE '2021-12-01', 3.10),
('Dritan','Gjoni','+35568000009','dritan.gjoni@agency.al', DATE '2019-07-07', 2.70),
('Rina','Basha','+35568000010','rina.basha@agency.al', DATE '2022-08-18', 3.40),
('Fation','Islami','+35568000011','fation.islami@agency.al', DATE '2020-10-10', 2.95),
('Mira','Tahiri','+35568000012','mira.tahiri@agency.al', DATE '2018-04-23', 3.60),
('Erion','Demiri','+35568000013','erion.demiri@agency.al', DATE '2016-01-30', 4.10),
('Anila','Kelmendi','+35568000014','anila.kelmendi@agency.al', DATE '2021-05-19', 3.05),
('Luan','Hajdari','+35568000015','luan.hajdari@agency.al', DATE '2017-03-03', 3.75),
('Bora','Spahiu','+35568000016','bora.spahiu@agency.al', DATE '2019-12-28', 3.15),
('Arian','Zeqiri','+35568000017','arian.zeqiri@agency.al', DATE '2022-02-02', 2.85),
('Joni','Rexhepi','+35568000018','joni.rexhepi@agency.al', DATE '2018-06-16', 3.25),
('Evi','Kajtazi','+35568000019','evi.kajtazi@agency.al', DATE '2020-01-08', 3.00),
('Sindi','Gega','+35568000020','sindi.gega@agency.al', DATE '2021-09-09', 3.35)
) AS v(first_name,last_name,phone,email,hire_date,base_commission_rate)
ON CONFLICT (email) DO NOTHING;

-- -------------------------
-- 3) PROPERTIES (50)
-- seller_id comes from existing clients (prefer Seller/Both)
-- -------------------------
WITH admin_u AS (SELECT user_id FROM users WHERE username='admin' LIMIT 1),
sellers AS (
  SELECT client_id, ROW_NUMBER() OVER (ORDER BY client_id) rn
  FROM clients
  WHERE client_type IN ('Seller','Both') AND is_deleted=FALSE
),
props AS (
  SELECT
    g AS rn,
    (ARRAY['Apartment','House','Land','Commercial'])[(g % 4)+1]::property_type AS ptype,
    (ARRAY['Tirana','Durres','Vlore','Shkoder','Elbasan','Fier','Korce','Lezhe'])[(g % 8)+1] AS city,
    'Rruga '||g||', Nr. '||(g%20+1) AS address,
    (50 + g*2)::numeric(10,2) AS area_m2,
    (g % 6 + 1)::smallint AS rooms,
    (g % 10)::smallint AS floor,
    (2000 + (g % 20))::smallint AS year_built
  FROM generate_series(1,50) g
)
INSERT INTO properties (seller_id,property_type,city,address,area_m2,rooms,floor,year_built,valid_from,valid_to,updated_by,is_deleted)
SELECT s.client_id, p.ptype, p.city, p.address, p.area_m2, p.rooms, p.floor, p.year_built,
       CURRENT_DATE, '9999-12-31', (SELECT user_id FROM admin_u), FALSE
FROM props p
JOIN sellers s ON s.rn = ((p.rn - 1) % (SELECT COUNT(*) FROM sellers)) + 1;

-- -------------------------
-- 4) LISTINGS (50)
-- each property gets a listing, agents assigned round-robin
-- -------------------------
WITH admin_u AS (SELECT user_id FROM users WHERE username='admin' LIMIT 1),
p AS (
  SELECT property_id, ROW_NUMBER() OVER (ORDER BY property_id) rn
  FROM properties WHERE is_deleted=FALSE
),
a AS (
  SELECT agent_id, ROW_NUMBER() OVER (ORDER BY agent_id) rn
  FROM agents WHERE is_active=TRUE
)
INSERT INTO listings (property_id,agent_id,list_price,currency,valid_from,valid_to,status,updated_by)
SELECT
  p.property_id,
  a.agent_id,
  (60000 + p.rn*2500)::numeric(18,2),
  (ARRAY['EUR','ALL','USD'])[(p.rn % 3)+1]::currency_type,
  CURRENT_DATE,
  '9999-12-31',
  (ARRAY['Active','Active','Active','Suspended','Closed'])[(p.rn % 5)+1]::listing_status,
  (SELECT user_id FROM admin_u)
FROM p
JOIN a ON a.rn = ((p.rn - 1) % (SELECT COUNT(*) FROM a)) + 1
WHERE p.rn <= 50;

-- -------------------------
-- 5) CONTRACTS (30)
-- pick 30 active listings -> create contracts with buyers/sellers
-- -------------------------
WITH admin_u AS (SELECT user_id FROM users WHERE username='admin' LIMIT 1),
active_listings AS (
  SELECT l.listing_id, l.property_id, l.agent_id, l.list_price,
         ROW_NUMBER() OVER (ORDER BY l.listing_id) rn
  FROM listings l
  WHERE l.status IN ('Active','Closed')  -- allow some closed too
),
buyers AS (
  SELECT client_id, ROW_NUMBER() OVER (ORDER BY client_id) rn
  FROM clients
  WHERE client_type IN ('Buyer','Both') AND is_deleted=FALSE
),
prop_seller AS (
  SELECT property_id, seller_id FROM properties
)
INSERT INTO contracts (property_id,buyer_id,seller_id,agent_id,contract_date,sale_price,commission_rate,status,notes,updated_by)
SELECT
  al.property_id,
  b.client_id AS buyer_id,
  ps.seller_id,
  al.agent_id,
  CURRENT_DATE - (al.rn || ' days')::interval,
  (al.list_price * (0.95 + (al.rn % 6)*0.01))::numeric(18,2),
  (3.0 + (al.rn % 4)*0.25)::numeric(5,2),
  (ARRAY['Draft','Signed','Signed','Cancelled'])[(al.rn % 4)+1]::contract_status,
  CASE WHEN (al.rn % 5)=0 THEN 'Negotiated discount applied.' ELSE NULL END,
  (SELECT user_id FROM admin_u)
FROM active_listings al
JOIN prop_seller ps ON ps.property_id = al.property_id
JOIN buyers b ON b.rn = ((al.rn - 1) % (SELECT COUNT(*) FROM buyers)) + 1
WHERE al.rn <= 30
  AND b.client_id <> ps.seller_id;

-- -------------------------
-- 6) PAYMENTS (60) - 2 payments per contract
-- -------------------------
WITH admin_u AS (SELECT user_id FROM users WHERE username='admin' LIMIT 1),
c AS (
  SELECT contract_id, sale_price, ROW_NUMBER() OVER (ORDER BY contract_id) rn
  FROM contracts
),
p1 AS (
  SELECT contract_id,
         CURRENT_DATE - (rn || ' days')::interval AS payment_date,
         (sale_price * 0.10)::numeric(18,2) AS amount,
         (ARRAY['Bank','Card','Cash'])[(rn % 3)+1]::payment_method AS payment_method,
         'Deposit'::payment_type_val AS payment_type,
         'Initial deposit'::text AS notes
  FROM c
),
p2 AS (
  SELECT contract_id,
         CURRENT_DATE - ((rn-2) || ' days')::interval AS payment_date,
         (sale_price * 0.20)::numeric(18,2) AS amount,
         (ARRAY['Bank','Card','Cash'])[((rn+1) % 3)+1]::payment_method AS payment_method,
         'Installment'::payment_type_val AS payment_type,
         'Second installment'::text AS notes
  FROM c
)
INSERT INTO payments (contract_id,payment_date,amount,payment_method,payment_type,notes,created_by)
SELECT contract_id, payment_date::date, amount, payment_method, payment_type, notes, (SELECT user_id FROM admin_u)
FROM p1
UNION ALL
SELECT contract_id, payment_date::date, amount, payment_method, payment_type, notes, (SELECT user_id FROM admin_u)
FROM p2;

-- -------------------------
-- OPTIONAL: create bitemporal history rows (triggers write to *_history)
-- -------------------------
UPDATE clients
SET phone = '+35569' || LPAD(client_id::text, 7, '9'),
    updated_at = NOW(),
    updated_by = (SELECT user_id FROM users WHERE username='admin' LIMIT 1)
WHERE client_id <= 10;

UPDATE listings
SET list_price = list_price + 5000,
    updated_at = NOW(),
    updated_by = (SELECT user_id FROM users WHERE username='admin' LIMIT 1)
WHERE listing_id <= 15;

COMMIT;