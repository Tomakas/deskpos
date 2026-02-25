-- Seed demo data templates for server-side demo company creation.
-- Holds templates for 4 variants: cs/gastro, en/gastro, cs/retail, en/retail.
-- Read only by service_role via PL/pgSQL function — no RLS needed.

-- ============================================================================
-- TABLE DEFINITION
-- ============================================================================

CREATE TABLE public.seed_demo_data (
  id serial PRIMARY KEY,
  locale text,               -- 'cs', 'en', or NULL (universal)
  mode text NOT NULL,        -- 'gastro', 'retail', or '_all' (shared)
  entity_type text NOT NULL, -- real table name or '_day_template', '_schedule'
  ref text NOT NULL,         -- stable reference key
  data jsonb NOT NULL,       -- entity fields
  sort_order int DEFAULT 0,
  UNIQUE(locale, mode, ref)
);

-- ============================================================================
-- UNIVERSAL DATA (locale=NULL, mode='_all')
-- ============================================================================

-- Tax rates (labels resolved by function per locale)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
(NULL, '_all', 'tax_rates', 'tax:21', '{"type":"regular","rate":2100,"is_default":true}', 0),
(NULL, '_all', 'tax_rates', 'tax:12', '{"type":"regular","rate":1200}', 1),
(NULL, '_all', 'tax_rates', 'tax:0',  '{"type":"noTax","rate":0}', 2);

-- Payment methods (names resolved by function per locale)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
(NULL, '_all', 'payment_methods', 'pm:cash',    '{"type":"cash"}', 0),
(NULL, '_all', 'payment_methods', 'pm:card',    '{"type":"card"}', 1),
(NULL, '_all', 'payment_methods', 'pm:bank',    '{"type":"bank"}', 2),
(NULL, '_all', 'payment_methods', 'pm:credit',  '{"type":"credit"}', 3),
(NULL, '_all', 'payment_methods', 'pm:voucher', '{"type":"voucher"}', 4);

-- Warehouses (name resolved by function per locale)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
(NULL, '_all', 'warehouses', 'wh:default', '{"is_default":true}', 0);

-- ============================================================================
-- GASTRO MODE — CS locale
-- ============================================================================

-- Sections (cs/gastro)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs', 'gastro', 'sections', 'sec:hlavni',  '{"name":"Hlavní","color":"#4CAF50","is_default":true}', 0),
('cs', 'gastro', 'sections', 'sec:zahradka','{"name":"Zahrádka","color":"#FF9800"}', 1),
('cs', 'gastro', 'sections', 'sec:interni', '{"name":"Interní","color":"#9E9E9E"}', 2);

-- Tables (cs/gastro) — 18 tables
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
-- Hlavní section
('cs','gastro','tables','tbl:1','{"name":"Stůl 1","section_ref":"sec:hlavni","capacity":4,"grid_row":1,"grid_col":1,"grid_width":4,"grid_height":4,"shape":"round","font_size":14}',0),
('cs','gastro','tables','tbl:2','{"name":"Stůl 2","section_ref":"sec:hlavni","capacity":4,"grid_row":7,"grid_col":1,"grid_width":4,"grid_height":4,"shape":"round","font_size":14}',1),
('cs','gastro','tables','tbl:3','{"name":"Stůl 3","section_ref":"sec:hlavni","capacity":4,"grid_row":13,"grid_col":1,"grid_width":4,"grid_height":4,"shape":"round","font_size":14}',2),
('cs','gastro','tables','tbl:4','{"name":"Stůl 4","section_ref":"sec:hlavni","capacity":4,"grid_row":1,"grid_col":9,"grid_width":4,"grid_height":4,"shape":"diamond","font_size":14}',3),
('cs','gastro','tables','tbl:5','{"name":"Stůl 5","section_ref":"sec:hlavni","capacity":4,"grid_row":1,"grid_col":17,"grid_width":4,"grid_height":4,"shape":"diamond","font_size":14}',4),
('cs','gastro','tables','tbl:6','{"name":"Stůl 6","section_ref":"sec:hlavni","grid_row":1,"grid_col":25,"grid_width":4,"grid_height":4,"shape":"diamond","font_size":14}',5),
('cs','gastro','tables','tbl:bar1','{"name":"Bar 1","section_ref":"sec:hlavni","grid_row":8,"grid_col":22,"grid_width":2,"grid_height":2,"color":"#4CAF50","font_size":14}',6),
('cs','gastro','tables','tbl:7','{"name":"Stůl 7","section_ref":"sec:hlavni","grid_row":10,"grid_col":10,"grid_width":7,"grid_height":4,"font_size":14}',7),
('cs','gastro','tables','tbl:bar2','{"name":"Bar 2","section_ref":"sec:hlavni","grid_row":11,"grid_col":22,"grid_width":2,"grid_height":2,"font_size":14}',8),
('cs','gastro','tables','tbl:bar3','{"name":"Bar 3","section_ref":"sec:hlavni","grid_row":14,"grid_col":22,"grid_width":2,"grid_height":2,"font_size":14}',9),
-- Zahrádka section
('cs','gastro','tables','tbl:z1','{"name":"Stolek 1","section_ref":"sec:zahradka","capacity":2,"grid_row":14,"grid_col":2,"grid_width":2,"grid_height":2}',10),
('cs','gastro','tables','tbl:z2','{"name":"Stolek 2","section_ref":"sec:zahradka","capacity":2,"grid_row":14,"grid_col":8,"grid_width":2,"grid_height":2}',11),
('cs','gastro','tables','tbl:z3','{"name":"Stolek 3","section_ref":"sec:zahradka","capacity":2,"grid_row":14,"grid_col":14,"grid_width":2,"grid_height":2}',12),
('cs','gastro','tables','tbl:z4','{"name":"Stolek 4","section_ref":"sec:zahradka","capacity":2,"grid_row":14,"grid_col":20,"grid_width":2,"grid_height":2}',13),
('cs','gastro','tables','tbl:z5','{"name":"Stolek 5","section_ref":"sec:zahradka","capacity":2,"grid_row":14,"grid_col":26,"grid_width":2,"grid_height":2}',14),
-- Interní section
('cs','gastro','tables','tbl:i1','{"name":"Majitel","section_ref":"sec:interni","capacity":0,"grid_row":-1,"grid_col":-1}',15),
('cs','gastro','tables','tbl:i2','{"name":"Repre","section_ref":"sec:interni","capacity":0,"grid_row":-1,"grid_col":-1}',16),
('cs','gastro','tables','tbl:i3','{"name":"Odpisy","section_ref":"sec:interni","capacity":0,"grid_row":-1,"grid_col":-1}',17);

-- Map elements (cs/gastro) — 8 elements, all in hlavni section
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','gastro','map_elements','me:wall1','{"section_ref":"sec:hlavni","grid_row":0,"grid_col":6,"grid_width":1,"grid_height":11,"color":"#000000","fill_style":1,"border_style":1}',0),
('cs','gastro','map_elements','me:bar_v','{"section_ref":"sec:hlavni","grid_row":7,"grid_col":24,"grid_width":2,"grid_height":11,"label":"BAR","color":"#795548","fill_style":2,"border_style":2}',1),
('cs','gastro','map_elements','me:bar_h','{"section_ref":"sec:hlavni","grid_row":7,"grid_col":24,"grid_width":6,"grid_height":2,"color":"#795548","fill_style":2,"border_style":2}',2),
('cs','gastro','map_elements','me:shelf','{"section_ref":"sec:hlavni","grid_row":11,"grid_col":23,"grid_width":2,"grid_height":2}',3),
('cs','gastro','map_elements','me:area1','{"section_ref":"sec:hlavni","grid_row":12,"grid_col":12,"grid_width":8,"grid_height":5}',4),
('cs','gastro','map_elements','me:wall2','{"section_ref":"sec:hlavni","grid_row":13,"grid_col":6,"grid_width":1,"grid_height":7,"color":"#000000"}',5),
('cs','gastro','map_elements','me:pillar','{"section_ref":"sec:hlavni","grid_row":17,"grid_col":6,"grid_width":2,"grid_height":2}',6),
('cs','gastro','map_elements','me:exit','{"section_ref":"sec:hlavni","grid_row":19,"grid_col":11,"grid_width":9,"grid_height":1,"label":"EXIT","font_size":20,"fill_style":2,"border_style":2}',7);

-- Categories (cs/gastro)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','gastro','categories','cat:napoje',      '{"name":"Nápoje"}', 0),
('cs','gastro','categories','cat:pivo',        '{"name":"Pivo"}', 1),
('cs','gastro','categories','cat:hlavni_jidla','{"name":"Hlavní jídla"}', 2),
('cs','gastro','categories','cat:predkrmy',    '{"name":"Předkrmy"}', 3),
('cs','gastro','categories','cat:dezerty',     '{"name":"Dezerty"}', 4),
('cs','gastro','categories','cat:suroviny',    '{"name":"Suroviny"}', 5),
('cs','gastro','categories','cat:sluzby',      '{"name":"Služby"}', 6);

-- Suppliers (cs/gastro)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','gastro','suppliers','sup:makro','{"supplier_name":"Makro Cash & Carry","contact_person":"Jan Novák","email":"objednavky@makro.cz","phone":"+420 601 111 222"}',0),
('cs','gastro','suppliers','sup:napoje','{"supplier_name":"Nápoje Express a.s.","contact_person":"Petra Dvořáková","email":"info@napoje-express.cz","phone":"+420 602 333 444"}',1);

-- Manufacturers (cs/gastro)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','gastro','manufacturers','mfr:prazdroj','{"name":"Plzeňský Prazdroj"}',0),
('cs','gastro','manufacturers','mfr:kofola','{"name":"Kofola ČeskoSlovensko"}',1);

-- Items (cs/gastro) — Nápoje (12% tax, stocked)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','gastro','items','item:coca_cola','{"name":"Coca-Cola 0.33l","item_type":"product","sku":"NAP-001","alt_sku":"5449000000996","unit_price":4900,"purchase_price":2200,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","category_ref":"cat:napoje"}',0),
('cs','gastro','items','item:mattoni','{"name":"Mattoni neperlivá 0.33l","item_type":"product","sku":"NAP-002","unit_price":3900,"purchase_price":1200,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","category_ref":"cat:napoje"}',1),
('cs','gastro','items','item:juice','{"name":"Džus pomerančový 0.2l","item_type":"product","sku":"NAP-003","unit_price":4500,"purchase_price":1800,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","category_ref":"cat:napoje"}',2),
('cs','gastro','items','item:kofola','{"name":"Kofola Original 0.5l","item_type":"product","sku":"NAP-004","alt_sku":"8593868001019","unit_price":4500,"purchase_price":1800,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","manufacturer_ref":"mfr:kofola","category_ref":"cat:napoje"}',3),
('cs','gastro','items','item:rajec','{"name":"Rajec jemně perlivá 0.33l","item_type":"product","sku":"NAP-005","unit_price":3900,"purchase_price":1100,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","manufacturer_ref":"mfr:kofola","category_ref":"cat:napoje"}',4),
('cs','gastro','items','item:espresso','{"name":"Espresso","item_type":"product","sku":"NAP-006","unit_price":5500,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:napoje"}',5),
('cs','gastro','items','item:cappuccino','{"name":"Cappuccino","item_type":"product","sku":"NAP-007","unit_price":6500,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:napoje"}',6),
('cs','gastro','items','item:tea','{"name":"Čaj (výběr)","item_type":"product","sku":"NAP-008","unit_price":4500,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:napoje"}',7),
('cs','gastro','items','item:lemonade','{"name":"Domácí limonáda 0.4l","item_type":"product","sku":"NAP-009","unit_price":6900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:napoje"}',8);

-- Items (cs/gastro) — Pivo (21% tax, stocked)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','gastro','items','item:pilsner','{"name":"Pilsner Urquell 0.5l","item_type":"product","sku":"PIV-001","alt_sku":"8594404000015","unit_price":5900,"purchase_price":2500,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","manufacturer_ref":"mfr:prazdroj","category_ref":"cat:pivo"}',10),
('cs','gastro','items','item:kozel','{"name":"Kozel 11° 0.5l","item_type":"product","sku":"PIV-002","unit_price":4900,"purchase_price":2000,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","manufacturer_ref":"mfr:prazdroj","category_ref":"cat:pivo"}',11),
('cs','gastro','items','item:gambrinus','{"name":"Gambrinus 10° 0.5l","item_type":"product","sku":"PIV-003","unit_price":3900,"purchase_price":1600,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","manufacturer_ref":"mfr:prazdroj","category_ref":"cat:pivo"}',12),
('cs','gastro','items','item:bernard','{"name":"Bernard 12° 0.5l","item_type":"product","sku":"PIV-004","unit_price":5500,"purchase_price":2400,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","category_ref":"cat:pivo"}',13),
('cs','gastro','items','item:staropramen','{"name":"Staropramen 11° 0.5l","item_type":"product","sku":"PIV-005","unit_price":4500,"purchase_price":1900,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","category_ref":"cat:pivo"}',14),
('cs','gastro','items','item:birell','{"name":"Birell Pomelo 0.5l","item_type":"product","sku":"PIV-006","unit_price":4500,"purchase_price":2000,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","manufacturer_ref":"mfr:prazdroj","category_ref":"cat:pivo"}',15);

-- Items (cs/gastro) — Hlavní jídla (12%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','gastro','items','item:svickova','{"name":"Svíčková na smetaně","item_type":"product","sku":"HJ-001","unit_price":22900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:hlavni_jidla"}',20),
('cs','gastro','items','item:schnitzel','{"name":"Řízek s bramborovým salátem","item_type":"product","sku":"HJ-002","unit_price":19900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:hlavni_jidla"}',21),
('cs','gastro','items','item:salmon','{"name":"Grilovaný losos","item_type":"product","sku":"HJ-003","unit_price":27900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:hlavni_jidla"}',22),
('cs','gastro','items','item:chicken','{"name":"Kuřecí steak s hranolky","item_type":"product","sku":"HJ-004","unit_price":18900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:hlavni_jidla"}',23),
('cs','gastro','items','item:fried_cheese','{"name":"Smažený sýr s hranolky","item_type":"recipe","sku":"HJ-005","unit_price":17900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:hlavni_jidla"}',24),
('cs','gastro','items','item:burger','{"name":"Hovězí burger","item_type":"product","sku":"HJ-006","unit_price":21900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:hlavni_jidla"}',25),
('cs','gastro','items','item:burger_classic','{"name":"Burger – klasický","item_type":"variant","sku":"HJ-006-KLA","unit_price":21900,"sale_tax_rate_ref":"tax:12","unit":"ks","parent_ref":"item:burger","category_ref":"cat:hlavni_jidla"}',26),
('cs','gastro','items','item:burger_double','{"name":"Burger – double","item_type":"variant","sku":"HJ-006-DBL","unit_price":25900,"sale_tax_rate_ref":"tax:12","unit":"ks","parent_ref":"item:burger","category_ref":"cat:hlavni_jidla"}',27),
('cs','gastro','items','item:burger_veg','{"name":"Burger – vegetariánský","item_type":"variant","sku":"HJ-006-VEG","unit_price":18900,"sale_tax_rate_ref":"tax:12","unit":"ks","parent_ref":"item:burger","category_ref":"cat:hlavni_jidla"}',28);

-- Items (cs/gastro) — Modifiers (no category, 12%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','gastro','items','item:mod_cheese','{"name":"Extra sýr","item_type":"modifier","unit_price":2900,"sale_tax_rate_ref":"tax:12","unit":"ks"}',30),
('cs','gastro','items','item:mod_bacon','{"name":"Extra slanina","item_type":"modifier","unit_price":3900,"sale_tax_rate_ref":"tax:12","unit":"ks"}',31),
('cs','gastro','items','item:mod_fries','{"name":"Příloha hranolky","item_type":"modifier","unit_price":4900,"sale_tax_rate_ref":"tax:12","unit":"ks"}',32),
('cs','gastro','items','item:mod_ketchup','{"name":"Kečup","item_type":"modifier","unit_price":0,"sale_tax_rate_ref":"tax:12","unit":"ks"}',33),
('cs','gastro','items','item:mod_mayo','{"name":"Majonéza","item_type":"modifier","unit_price":0,"sale_tax_rate_ref":"tax:12","unit":"ks"}',34),
('cs','gastro','items','item:mod_bbq','{"name":"BBQ omáčka","item_type":"modifier","unit_price":1500,"sale_tax_rate_ref":"tax:12","unit":"ks"}',35),
('cs','gastro','items','item:mod_salad','{"name":"Salát","item_type":"modifier","unit_price":3900,"sale_tax_rate_ref":"tax:12","unit":"ks"}',36);

-- Items (cs/gastro) — Předkrmy (12%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','gastro','items','item:tartare','{"name":"Tatarský biftek","item_type":"product","sku":"PK-001","unit_price":18900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:predkrmy"}',40),
('cs','gastro','items','item:carpaccio','{"name":"Carpaccio z hovězího","item_type":"product","sku":"PK-002","unit_price":16900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:predkrmy"}',41),
('cs','gastro','items','item:bruschetta','{"name":"Bruschetta","item_type":"product","sku":"PK-003","unit_price":12900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:predkrmy"}',42),
('cs','gastro','items','item:soup','{"name":"Polévka dne","item_type":"product","sku":"PK-004","unit_price":6900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:predkrmy"}',43),
('cs','gastro','items','item:caesar','{"name":"Caesar salát","item_type":"product","sku":"PK-005","unit_price":14900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:predkrmy"}',44);

-- Items (cs/gastro) — Dezerty (12%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','gastro','items','item:tiramisu','{"name":"Tiramisu","item_type":"product","sku":"DES-001","unit_price":11900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:dezerty"}',50),
('cs','gastro','items','item:fondant','{"name":"Čokoládový fondant","item_type":"product","sku":"DES-002","unit_price":13900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:dezerty"}',51),
('cs','gastro','items','item:pancakes','{"name":"Palačinky s Nutellou","item_type":"product","sku":"DES-003","unit_price":10900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:dezerty"}',52),
('cs','gastro','items','item:sundae','{"name":"Zmrzlinový pohár","item_type":"product","sku":"DES-004","unit_price":9900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:dezerty"}',53),
('cs','gastro','items','item:strudel','{"name":"Jablečný štrúdl","item_type":"product","sku":"DES-005","unit_price":8900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:dezerty"}',54);

-- Items (cs/gastro) — Suroviny (12%, not sellable, stocked, from Makro)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','gastro','items','item:chicken_breast','{"name":"Kuřecí prsa","item_type":"ingredient","sku":"SUR-001","unit_price":18900,"purchase_price":18900,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"kg","is_sellable":false,"is_stock_tracked":true,"supplier_ref":"sup:makro","category_ref":"cat:suroviny"}',60),
('cs','gastro','items','item:beef_sirloin','{"name":"Hovězí svíčková","item_type":"ingredient","sku":"SUR-002","unit_price":34900,"purchase_price":34900,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"g","is_sellable":false,"is_stock_tracked":true,"supplier_ref":"sup:makro","category_ref":"cat:suroviny"}',61),
('cs','gastro','items','item:flour','{"name":"Mouka hladká","item_type":"ingredient","sku":"SUR-003","unit_price":2900,"purchase_price":2900,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"kg","is_sellable":false,"is_stock_tracked":true,"supplier_ref":"sup:makro","category_ref":"cat:suroviny"}',62),
('cs','gastro','items','item:cream','{"name":"Smetana 33%","item_type":"ingredient","sku":"SUR-004","unit_price":6900,"purchase_price":6900,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"l","is_sellable":false,"is_stock_tracked":true,"supplier_ref":"sup:makro","category_ref":"cat:suroviny"}',63),
('cs','gastro','items','item:edam','{"name":"Eidam 30%","item_type":"ingredient","sku":"SUR-005","unit_price":15900,"purchase_price":15900,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"g","is_sellable":false,"is_stock_tracked":true,"supplier_ref":"sup:makro","category_ref":"cat:suroviny"}',64);

-- Items (cs/gastro) — Counter/Consumables (21%, not sellable, stocked, from Makro)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','gastro','items','item:napkin','{"name":"Ubrousek","item_type":"counter","sku":"SPT-001","unit_price":100,"purchase_price":50,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_sellable":false,"is_stock_tracked":true,"supplier_ref":"sup:makro","category_ref":"cat:suroviny"}',70),
('cs','gastro','items','item:cup','{"name":"Kelímek na odnos","item_type":"counter","sku":"SPT-002","unit_price":500,"purchase_price":250,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_sellable":false,"is_stock_tracked":true,"supplier_ref":"sup:makro","category_ref":"cat:suroviny"}',71),
('cs','gastro','items','item:tray','{"name":"Papírový tácek","item_type":"counter","sku":"SPT-003","unit_price":200,"purchase_price":100,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_sellable":false,"is_stock_tracked":true,"supplier_ref":"sup:makro","category_ref":"cat:suroviny"}',72);

-- Items (cs/gastro) — Services (21%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','gastro','items','item:hall_rental','{"name":"Pronájem sálu (hodina)","item_type":"service","sku":"SLU-001","unit_price":150000,"sale_tax_rate_ref":"tax:21","unit":"h","category_ref":"cat:sluzby"}',80),
('cs','gastro','items','item:catering','{"name":"Raut – obsluha (osoba)","item_type":"service","sku":"SLU-002","unit_price":50000,"sale_tax_rate_ref":"tax:21","unit":"ks","category_ref":"cat:sluzby"}',81);

-- Modifier groups (cs/gastro)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','gastro','modifier_groups','mg:sides','{"name":"Přílohy","min_selections":0,"max_selections":1}',0),
('cs','gastro','modifier_groups','mg:extra','{"name":"Extra ingredience","min_selections":0,"max_selections":null}',1),
('cs','gastro','modifier_groups','mg:sauces','{"name":"Omáčky","min_selections":0,"max_selections":2}',2);

-- Modifier group items (cs/gastro)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','gastro','modifier_group_items','mgi:sides_fries','{"modifier_group_ref":"mg:sides","item_ref":"item:mod_fries","is_default":true}',0),
('cs','gastro','modifier_group_items','mgi:sides_salad','{"modifier_group_ref":"mg:sides","item_ref":"item:mod_salad"}',1),
('cs','gastro','modifier_group_items','mgi:extra_cheese','{"modifier_group_ref":"mg:extra","item_ref":"item:mod_cheese"}',2),
('cs','gastro','modifier_group_items','mgi:extra_bacon','{"modifier_group_ref":"mg:extra","item_ref":"item:mod_bacon"}',3),
('cs','gastro','modifier_group_items','mgi:sauces_ketchup','{"modifier_group_ref":"mg:sauces","item_ref":"item:mod_ketchup"}',4),
('cs','gastro','modifier_group_items','mgi:sauces_mayo','{"modifier_group_ref":"mg:sauces","item_ref":"item:mod_mayo"}',5),
('cs','gastro','modifier_group_items','mgi:sauces_bbq','{"modifier_group_ref":"mg:sauces","item_ref":"item:mod_bbq"}',6);

-- Item modifier groups (cs/gastro) — assign groups to burger
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','gastro','item_modifier_groups','img:burger_sides','{"item_ref":"item:burger","modifier_group_ref":"mg:sides"}',0),
('cs','gastro','item_modifier_groups','img:burger_extra','{"item_ref":"item:burger","modifier_group_ref":"mg:extra"}',1),
('cs','gastro','item_modifier_groups','img:burger_sauces','{"item_ref":"item:burger","modifier_group_ref":"mg:sauces"}',2);

-- Product recipes (cs/gastro) — fried cheese recipe
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','gastro','product_recipes','pr:fc_edam','{"parent_ref":"item:fried_cheese","component_ref":"item:edam","quantity":150.0}',0),
('cs','gastro','product_recipes','pr:fc_flour','{"parent_ref":"item:fried_cheese","component_ref":"item:flour","quantity":0.05}',1),
('cs','gastro','product_recipes','pr:fc_cream','{"parent_ref":"item:fried_cheese","component_ref":"item:cream","quantity":0.02}',2);

-- ============================================================================
-- GASTRO MODE — EN locale
-- ============================================================================

-- Sections (en/gastro)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en', 'gastro', 'sections', 'sec:hlavni',  '{"name":"Main","color":"#4CAF50","is_default":true}', 0),
('en', 'gastro', 'sections', 'sec:zahradka','{"name":"Garden","color":"#FF9800"}', 1),
('en', 'gastro', 'sections', 'sec:interni', '{"name":"Internal","color":"#9E9E9E"}', 2);

-- Tables (en/gastro) — 18 tables
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
-- Main section
('en','gastro','tables','tbl:1','{"name":"Table 1","section_ref":"sec:hlavni","capacity":4,"grid_row":1,"grid_col":1,"grid_width":4,"grid_height":4,"shape":"round","font_size":14}',0),
('en','gastro','tables','tbl:2','{"name":"Table 2","section_ref":"sec:hlavni","capacity":4,"grid_row":7,"grid_col":1,"grid_width":4,"grid_height":4,"shape":"round","font_size":14}',1),
('en','gastro','tables','tbl:3','{"name":"Table 3","section_ref":"sec:hlavni","capacity":4,"grid_row":13,"grid_col":1,"grid_width":4,"grid_height":4,"shape":"round","font_size":14}',2),
('en','gastro','tables','tbl:4','{"name":"Table 4","section_ref":"sec:hlavni","capacity":4,"grid_row":1,"grid_col":9,"grid_width":4,"grid_height":4,"shape":"diamond","font_size":14}',3),
('en','gastro','tables','tbl:5','{"name":"Table 5","section_ref":"sec:hlavni","capacity":4,"grid_row":1,"grid_col":17,"grid_width":4,"grid_height":4,"shape":"diamond","font_size":14}',4),
('en','gastro','tables','tbl:6','{"name":"Table 6","section_ref":"sec:hlavni","grid_row":1,"grid_col":25,"grid_width":4,"grid_height":4,"shape":"diamond","font_size":14}',5),
('en','gastro','tables','tbl:bar1','{"name":"Bar 1","section_ref":"sec:hlavni","grid_row":8,"grid_col":22,"grid_width":2,"grid_height":2,"color":"#4CAF50","font_size":14}',6),
('en','gastro','tables','tbl:7','{"name":"Table 7","section_ref":"sec:hlavni","grid_row":10,"grid_col":10,"grid_width":7,"grid_height":4,"font_size":14}',7),
('en','gastro','tables','tbl:bar2','{"name":"Bar 2","section_ref":"sec:hlavni","grid_row":11,"grid_col":22,"grid_width":2,"grid_height":2,"font_size":14}',8),
('en','gastro','tables','tbl:bar3','{"name":"Bar 3","section_ref":"sec:hlavni","grid_row":14,"grid_col":22,"grid_width":2,"grid_height":2,"font_size":14}',9),
-- Garden section
('en','gastro','tables','tbl:z1','{"name":"Table 1","section_ref":"sec:zahradka","capacity":2,"grid_row":14,"grid_col":2,"grid_width":2,"grid_height":2}',10),
('en','gastro','tables','tbl:z2','{"name":"Table 2","section_ref":"sec:zahradka","capacity":2,"grid_row":14,"grid_col":8,"grid_width":2,"grid_height":2}',11),
('en','gastro','tables','tbl:z3','{"name":"Table 3","section_ref":"sec:zahradka","capacity":2,"grid_row":14,"grid_col":14,"grid_width":2,"grid_height":2}',12),
('en','gastro','tables','tbl:z4','{"name":"Table 4","section_ref":"sec:zahradka","capacity":2,"grid_row":14,"grid_col":20,"grid_width":2,"grid_height":2}',13),
('en','gastro','tables','tbl:z5','{"name":"Table 5","section_ref":"sec:zahradka","capacity":2,"grid_row":14,"grid_col":26,"grid_width":2,"grid_height":2}',14),
-- Internal section
('en','gastro','tables','tbl:i1','{"name":"Owner","section_ref":"sec:interni","capacity":0,"grid_row":-1,"grid_col":-1}',15),
('en','gastro','tables','tbl:i2','{"name":"Entertainment","section_ref":"sec:interni","capacity":0,"grid_row":-1,"grid_col":-1}',16),
('en','gastro','tables','tbl:i3','{"name":"Write-offs","section_ref":"sec:interni","capacity":0,"grid_row":-1,"grid_col":-1}',17);

-- Map elements (en/gastro) — identical layout to cs, same refs
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','gastro','map_elements','me:wall1','{"section_ref":"sec:hlavni","grid_row":0,"grid_col":6,"grid_width":1,"grid_height":11,"color":"#000000","fill_style":1,"border_style":1}',0),
('en','gastro','map_elements','me:bar_v','{"section_ref":"sec:hlavni","grid_row":7,"grid_col":24,"grid_width":2,"grid_height":11,"label":"BAR","color":"#795548","fill_style":2,"border_style":2}',1),
('en','gastro','map_elements','me:bar_h','{"section_ref":"sec:hlavni","grid_row":7,"grid_col":24,"grid_width":6,"grid_height":2,"color":"#795548","fill_style":2,"border_style":2}',2),
('en','gastro','map_elements','me:shelf','{"section_ref":"sec:hlavni","grid_row":11,"grid_col":23,"grid_width":2,"grid_height":2}',3),
('en','gastro','map_elements','me:area1','{"section_ref":"sec:hlavni","grid_row":12,"grid_col":12,"grid_width":8,"grid_height":5}',4),
('en','gastro','map_elements','me:wall2','{"section_ref":"sec:hlavni","grid_row":13,"grid_col":6,"grid_width":1,"grid_height":7,"color":"#000000"}',5),
('en','gastro','map_elements','me:pillar','{"section_ref":"sec:hlavni","grid_row":17,"grid_col":6,"grid_width":2,"grid_height":2}',6),
('en','gastro','map_elements','me:exit','{"section_ref":"sec:hlavni","grid_row":19,"grid_col":11,"grid_width":9,"grid_height":1,"label":"EXIT","font_size":20,"fill_style":2,"border_style":2}',7);

-- Categories (en/gastro)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','gastro','categories','cat:napoje',      '{"name":"Beverages"}', 0),
('en','gastro','categories','cat:pivo',        '{"name":"Beer"}', 1),
('en','gastro','categories','cat:hlavni_jidla','{"name":"Main Courses"}', 2),
('en','gastro','categories','cat:predkrmy',    '{"name":"Starters"}', 3),
('en','gastro','categories','cat:dezerty',     '{"name":"Desserts"}', 4),
('en','gastro','categories','cat:suroviny',    '{"name":"Ingredients"}', 5),
('en','gastro','categories','cat:sluzby',      '{"name":"Services"}', 6);

-- Suppliers (en/gastro)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','gastro','suppliers','sup:makro','{"supplier_name":"Makro Cash & Carry","contact_person":"John Smith","email":"orders@makro.com","phone":"+1 555 111 222"}',0),
('en','gastro','suppliers','sup:napoje','{"supplier_name":"Drinks Express Ltd.","contact_person":"Sarah Johnson","email":"info@drinks-express.com","phone":"+1 555 333 444"}',1);

-- Manufacturers (en/gastro)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','gastro','manufacturers','mfr:prazdroj','{"name":"Pilsner Urquell Brewery"}',0),
('en','gastro','manufacturers','mfr:kofola','{"name":"Kofola Inc."}',1);

-- Items (en/gastro) — Beverages (12% tax, stocked)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','gastro','items','item:coca_cola','{"name":"Coca-Cola 0.33l","item_type":"product","sku":"NAP-001","alt_sku":"5449000000996","unit_price":4900,"purchase_price":2200,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","category_ref":"cat:napoje"}',0),
('en','gastro','items','item:mattoni','{"name":"Mattoni Still 0.33l","item_type":"product","sku":"NAP-002","unit_price":3900,"purchase_price":1200,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","category_ref":"cat:napoje"}',1),
('en','gastro','items','item:juice','{"name":"Orange Juice 0.2l","item_type":"product","sku":"NAP-003","unit_price":4500,"purchase_price":1800,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","category_ref":"cat:napoje"}',2),
('en','gastro','items','item:kofola','{"name":"Kofola Original 0.5l","item_type":"product","sku":"NAP-004","alt_sku":"8593868001019","unit_price":4500,"purchase_price":1800,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","manufacturer_ref":"mfr:kofola","category_ref":"cat:napoje"}',3),
('en','gastro','items','item:rajec','{"name":"Rajec Sparkling 0.33l","item_type":"product","sku":"NAP-005","unit_price":3900,"purchase_price":1100,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","manufacturer_ref":"mfr:kofola","category_ref":"cat:napoje"}',4),
('en','gastro','items','item:espresso','{"name":"Espresso","item_type":"product","sku":"NAP-006","unit_price":5500,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:napoje"}',5),
('en','gastro','items','item:cappuccino','{"name":"Cappuccino","item_type":"product","sku":"NAP-007","unit_price":6500,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:napoje"}',6),
('en','gastro','items','item:tea','{"name":"Tea (selection)","item_type":"product","sku":"NAP-008","unit_price":4500,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:napoje"}',7),
('en','gastro','items','item:lemonade','{"name":"Homemade Lemonade 0.4l","item_type":"product","sku":"NAP-009","unit_price":6900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:napoje"}',8);

-- Items (en/gastro) — Beer (21% tax, stocked)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','gastro','items','item:pilsner','{"name":"Pilsner Urquell 0.5l","item_type":"product","sku":"PIV-001","alt_sku":"8594404000015","unit_price":5900,"purchase_price":2500,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","manufacturer_ref":"mfr:prazdroj","category_ref":"cat:pivo"}',10),
('en','gastro','items','item:kozel','{"name":"Kozel 11° 0.5l","item_type":"product","sku":"PIV-002","unit_price":4900,"purchase_price":2000,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","manufacturer_ref":"mfr:prazdroj","category_ref":"cat:pivo"}',11),
('en','gastro','items','item:gambrinus','{"name":"Gambrinus 10° 0.5l","item_type":"product","sku":"PIV-003","unit_price":3900,"purchase_price":1600,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","manufacturer_ref":"mfr:prazdroj","category_ref":"cat:pivo"}',12),
('en','gastro','items','item:bernard','{"name":"Bernard 12° 0.5l","item_type":"product","sku":"PIV-004","unit_price":5500,"purchase_price":2400,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","category_ref":"cat:pivo"}',13),
('en','gastro','items','item:staropramen','{"name":"Staropramen 11° 0.5l","item_type":"product","sku":"PIV-005","unit_price":4500,"purchase_price":1900,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","category_ref":"cat:pivo"}',14),
('en','gastro','items','item:birell','{"name":"Birell Pomelo 0.5l","item_type":"product","sku":"PIV-006","unit_price":4500,"purchase_price":2000,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"supplier_ref":"sup:napoje","manufacturer_ref":"mfr:prazdroj","category_ref":"cat:pivo"}',15);

-- Items (en/gastro) — Main Courses (12%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','gastro','items','item:svickova','{"name":"Beef Sirloin in Cream Sauce","item_type":"product","sku":"HJ-001","unit_price":22900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:hlavni_jidla"}',20),
('en','gastro','items','item:schnitzel','{"name":"Schnitzel with Potato Salad","item_type":"product","sku":"HJ-002","unit_price":19900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:hlavni_jidla"}',21),
('en','gastro','items','item:salmon','{"name":"Grilled Salmon","item_type":"product","sku":"HJ-003","unit_price":27900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:hlavni_jidla"}',22),
('en','gastro','items','item:chicken','{"name":"Chicken Steak with Fries","item_type":"product","sku":"HJ-004","unit_price":18900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:hlavni_jidla"}',23),
('en','gastro','items','item:fried_cheese','{"name":"Fried Cheese with Fries","item_type":"recipe","sku":"HJ-005","unit_price":17900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:hlavni_jidla"}',24),
('en','gastro','items','item:burger','{"name":"Beef Burger","item_type":"product","sku":"HJ-006","unit_price":21900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:hlavni_jidla"}',25),
('en','gastro','items','item:burger_classic','{"name":"Burger – Classic","item_type":"variant","sku":"HJ-006-KLA","unit_price":21900,"sale_tax_rate_ref":"tax:12","unit":"ks","parent_ref":"item:burger","category_ref":"cat:hlavni_jidla"}',26),
('en','gastro','items','item:burger_double','{"name":"Burger – Double","item_type":"variant","sku":"HJ-006-DBL","unit_price":25900,"sale_tax_rate_ref":"tax:12","unit":"ks","parent_ref":"item:burger","category_ref":"cat:hlavni_jidla"}',27),
('en','gastro','items','item:burger_veg','{"name":"Burger – Vegetarian","item_type":"variant","sku":"HJ-006-VEG","unit_price":18900,"sale_tax_rate_ref":"tax:12","unit":"ks","parent_ref":"item:burger","category_ref":"cat:hlavni_jidla"}',28);

-- Items (en/gastro) — Modifiers (no category, 12%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','gastro','items','item:mod_cheese','{"name":"Extra Cheese","item_type":"modifier","unit_price":2900,"sale_tax_rate_ref":"tax:12","unit":"ks"}',30),
('en','gastro','items','item:mod_bacon','{"name":"Extra Bacon","item_type":"modifier","unit_price":3900,"sale_tax_rate_ref":"tax:12","unit":"ks"}',31),
('en','gastro','items','item:mod_fries','{"name":"Side Fries","item_type":"modifier","unit_price":4900,"sale_tax_rate_ref":"tax:12","unit":"ks"}',32),
('en','gastro','items','item:mod_ketchup','{"name":"Ketchup","item_type":"modifier","unit_price":0,"sale_tax_rate_ref":"tax:12","unit":"ks"}',33),
('en','gastro','items','item:mod_mayo','{"name":"Mayonnaise","item_type":"modifier","unit_price":0,"sale_tax_rate_ref":"tax:12","unit":"ks"}',34),
('en','gastro','items','item:mod_bbq','{"name":"BBQ Sauce","item_type":"modifier","unit_price":1500,"sale_tax_rate_ref":"tax:12","unit":"ks"}',35),
('en','gastro','items','item:mod_salad','{"name":"Salad","item_type":"modifier","unit_price":3900,"sale_tax_rate_ref":"tax:12","unit":"ks"}',36);

-- Items (en/gastro) — Starters (12%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','gastro','items','item:tartare','{"name":"Beef Tartare","item_type":"product","sku":"PK-001","unit_price":18900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:predkrmy"}',40),
('en','gastro','items','item:carpaccio','{"name":"Beef Carpaccio","item_type":"product","sku":"PK-002","unit_price":16900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:predkrmy"}',41),
('en','gastro','items','item:bruschetta','{"name":"Bruschetta","item_type":"product","sku":"PK-003","unit_price":12900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:predkrmy"}',42),
('en','gastro','items','item:soup','{"name":"Soup of the Day","item_type":"product","sku":"PK-004","unit_price":6900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:predkrmy"}',43),
('en','gastro','items','item:caesar','{"name":"Caesar Salad","item_type":"product","sku":"PK-005","unit_price":14900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:predkrmy"}',44);

-- Items (en/gastro) — Desserts (12%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','gastro','items','item:tiramisu','{"name":"Tiramisu","item_type":"product","sku":"DES-001","unit_price":11900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:dezerty"}',50),
('en','gastro','items','item:fondant','{"name":"Chocolate Fondant","item_type":"product","sku":"DES-002","unit_price":13900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:dezerty"}',51),
('en','gastro','items','item:pancakes','{"name":"Nutella Pancakes","item_type":"product","sku":"DES-003","unit_price":10900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:dezerty"}',52),
('en','gastro','items','item:sundae','{"name":"Ice Cream Sundae","item_type":"product","sku":"DES-004","unit_price":9900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:dezerty"}',53),
('en','gastro','items','item:strudel','{"name":"Apple Strudel","item_type":"product","sku":"DES-005","unit_price":8900,"sale_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:dezerty"}',54);

-- Items (en/gastro) — Ingredients (12%, not sellable, stocked)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','gastro','items','item:chicken_breast','{"name":"Chicken Breast","item_type":"ingredient","sku":"SUR-001","unit_price":18900,"purchase_price":18900,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"kg","is_sellable":false,"is_stock_tracked":true,"supplier_ref":"sup:makro","category_ref":"cat:suroviny"}',60),
('en','gastro','items','item:beef_sirloin','{"name":"Beef Sirloin","item_type":"ingredient","sku":"SUR-002","unit_price":34900,"purchase_price":34900,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"g","is_sellable":false,"is_stock_tracked":true,"supplier_ref":"sup:makro","category_ref":"cat:suroviny"}',61),
('en','gastro','items','item:flour','{"name":"Plain Flour","item_type":"ingredient","sku":"SUR-003","unit_price":2900,"purchase_price":2900,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"kg","is_sellable":false,"is_stock_tracked":true,"supplier_ref":"sup:makro","category_ref":"cat:suroviny"}',62),
('en','gastro','items','item:cream','{"name":"Heavy Cream 33%","item_type":"ingredient","sku":"SUR-004","unit_price":6900,"purchase_price":6900,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"l","is_sellable":false,"is_stock_tracked":true,"supplier_ref":"sup:makro","category_ref":"cat:suroviny"}',63),
('en','gastro','items','item:edam','{"name":"Edam Cheese 30%","item_type":"ingredient","sku":"SUR-005","unit_price":15900,"purchase_price":15900,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"g","is_sellable":false,"is_stock_tracked":true,"supplier_ref":"sup:makro","category_ref":"cat:suroviny"}',64);

-- Items (en/gastro) — Counter/Consumables (21%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','gastro','items','item:napkin','{"name":"Napkin","item_type":"counter","sku":"SPT-001","unit_price":100,"purchase_price":50,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_sellable":false,"is_stock_tracked":true,"supplier_ref":"sup:makro","category_ref":"cat:suroviny"}',70),
('en','gastro','items','item:cup','{"name":"Takeaway Cup","item_type":"counter","sku":"SPT-002","unit_price":500,"purchase_price":250,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_sellable":false,"is_stock_tracked":true,"supplier_ref":"sup:makro","category_ref":"cat:suroviny"}',71),
('en','gastro','items','item:tray','{"name":"Paper Tray","item_type":"counter","sku":"SPT-003","unit_price":200,"purchase_price":100,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_sellable":false,"is_stock_tracked":true,"supplier_ref":"sup:makro","category_ref":"cat:suroviny"}',72);

-- Items (en/gastro) — Services (21%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','gastro','items','item:hall_rental','{"name":"Hall Rental (hour)","item_type":"service","sku":"SLU-001","unit_price":150000,"sale_tax_rate_ref":"tax:21","unit":"h","category_ref":"cat:sluzby"}',80),
('en','gastro','items','item:catering','{"name":"Catering – Staff (person)","item_type":"service","sku":"SLU-002","unit_price":50000,"sale_tax_rate_ref":"tax:21","unit":"ks","category_ref":"cat:sluzby"}',81);

-- Modifier groups (en/gastro)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','gastro','modifier_groups','mg:sides','{"name":"Side Dishes","min_selections":0,"max_selections":1}',0),
('en','gastro','modifier_groups','mg:extra','{"name":"Extra Ingredients","min_selections":0,"max_selections":null}',1),
('en','gastro','modifier_groups','mg:sauces','{"name":"Sauces","min_selections":0,"max_selections":2}',2);

-- Modifier group items (en/gastro)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','gastro','modifier_group_items','mgi:sides_fries','{"modifier_group_ref":"mg:sides","item_ref":"item:mod_fries","is_default":true}',0),
('en','gastro','modifier_group_items','mgi:sides_salad','{"modifier_group_ref":"mg:sides","item_ref":"item:mod_salad"}',1),
('en','gastro','modifier_group_items','mgi:extra_cheese','{"modifier_group_ref":"mg:extra","item_ref":"item:mod_cheese"}',2),
('en','gastro','modifier_group_items','mgi:extra_bacon','{"modifier_group_ref":"mg:extra","item_ref":"item:mod_bacon"}',3),
('en','gastro','modifier_group_items','mgi:sauces_ketchup','{"modifier_group_ref":"mg:sauces","item_ref":"item:mod_ketchup"}',4),
('en','gastro','modifier_group_items','mgi:sauces_mayo','{"modifier_group_ref":"mg:sauces","item_ref":"item:mod_mayo"}',5),
('en','gastro','modifier_group_items','mgi:sauces_bbq','{"modifier_group_ref":"mg:sauces","item_ref":"item:mod_bbq"}',6);

-- Item modifier groups (en/gastro)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','gastro','item_modifier_groups','img:burger_sides','{"item_ref":"item:burger","modifier_group_ref":"mg:sides"}',0),
('en','gastro','item_modifier_groups','img:burger_extra','{"item_ref":"item:burger","modifier_group_ref":"mg:extra"}',1),
('en','gastro','item_modifier_groups','img:burger_sauces','{"item_ref":"item:burger","modifier_group_ref":"mg:sauces"}',2);

-- Product recipes (en/gastro)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','gastro','product_recipes','pr:fc_edam','{"parent_ref":"item:fried_cheese","component_ref":"item:edam","quantity":150.0}',0),
('en','gastro','product_recipes','pr:fc_flour','{"parent_ref":"item:fried_cheese","component_ref":"item:flour","quantity":0.05}',1),
('en','gastro','product_recipes','pr:fc_cream','{"parent_ref":"item:fried_cheese","component_ref":"item:cream","quantity":0.02}',2);

-- ============================================================================
-- RETAIL MODE — CS locale
-- ============================================================================

-- Sections (cs/retail)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs', 'retail', 'sections', 'sec:store', '{"name":"Prodejna","color":"#4CAF50","is_default":true}', 0);

-- No tables or map_elements for retail

-- Categories (cs/retail)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','retail','categories','cat:beverages_r','{"name":"Nápoje"}', 0),
('cs','retail','categories','cat:groceries',  '{"name":"Potraviny"}', 1),
('cs','retail','categories','cat:household',  '{"name":"Drogerie"}', 2),
('cs','retail','categories','cat:alcohol',    '{"name":"Alkohol & Tabák"}', 3),
('cs','retail','categories','cat:press',      '{"name":"Noviny & Časopisy"}', 4);

-- Suppliers (cs/retail)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','retail','suppliers','sup:wholesale','{"supplier_name":"Velkoobchod Praha"}',0),
('cs','retail','suppliers','sup:press_dist','{"supplier_name":"PNS distribuce"}',1);

-- Manufacturers (cs/retail)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','retail','manufacturers','mfr:cola_company','{"name":"Coca-Cola Company"}',0),
('cs','retail','manufacturers','mfr:henkel','{"name":"Henkel"}',1);

-- Items (cs/retail) — Beverages (12%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','retail','items','item:r_cola','{"name":"Coca-Cola 0.5l","item_type":"product","sku":"RET-001","alt_sku":"5449000131805","unit_price":3500,"purchase_price":1800,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:beverages_r"}',0),
('cs','retail','items','item:r_water','{"name":"Mattoni 0.5l","item_type":"product","sku":"RET-002","unit_price":2500,"purchase_price":1000,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:beverages_r"}',1),
('cs','retail','items','item:r_juice_orange','{"name":"Džus pomerančový 1l","item_type":"product","sku":"RET-003","unit_price":5900,"purchase_price":3200,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:beverages_r"}',2),
('cs','retail','items','item:r_energy','{"name":"Red Bull 0.25l","item_type":"product","sku":"RET-004","unit_price":4900,"purchase_price":2800,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:beverages_r"}',3),
('cs','retail','items','item:r_milk','{"name":"Mléko polotučné 1l","item_type":"product","sku":"RET-005","unit_price":2900,"purchase_price":1800,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:beverages_r"}',4);

-- Items (cs/retail) — Groceries (12%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','retail','items','item:r_bread','{"name":"Chléb celozrnný","item_type":"product","sku":"RET-010","unit_price":4500,"purchase_price":2500,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:groceries"}',10),
('cs','retail','items','item:r_butter','{"name":"Máslo 250g","item_type":"product","sku":"RET-011","unit_price":5900,"purchase_price":3800,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:groceries"}',11),
('cs','retail','items','item:r_cheese','{"name":"Eidam 30% 100g","item_type":"product","sku":"RET-012","unit_price":2900,"purchase_price":1500,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:groceries"}',12),
('cs','retail','items','item:r_yogurt','{"name":"Jogurt bílý","item_type":"product","sku":"RET-013","unit_price":1900,"purchase_price":900,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:groceries"}',13),
('cs','retail','items','item:r_eggs','{"name":"Vejce M 10ks","item_type":"product","sku":"RET-014","unit_price":5900,"purchase_price":3500,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:groceries"}',14),
('cs','retail','items','item:r_ham','{"name":"Šunka výběrová 100g","item_type":"product","sku":"RET-015","unit_price":3900,"purchase_price":2200,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:groceries"}',15),
('cs','retail','items','item:r_pasta','{"name":"Těstoviny penne 500g","item_type":"product","sku":"RET-016","unit_price":3500,"purchase_price":1800,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:groceries"}',16),
('cs','retail','items','item:r_rice','{"name":"Rýže dlouhozrnná 1kg","item_type":"product","sku":"RET-017","unit_price":4500,"purchase_price":2500,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:groceries"}',17),
('cs','retail','items','item:r_chips','{"name":"Bohemia Chips 130g","item_type":"product","sku":"RET-018","unit_price":3900,"purchase_price":2000,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:groceries"}',18);

-- Items (cs/retail) — Household (21%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','retail','items','item:r_soap','{"name":"Tekuté mýdlo 500ml","item_type":"product","sku":"RET-020","unit_price":6900,"purchase_price":3500,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"category_ref":"cat:household"}',20),
('cs','retail','items','item:r_detergent','{"name":"Prací prášek 2kg","item_type":"product","sku":"RET-021","unit_price":14900,"purchase_price":8500,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","category_ref":"cat:household"}',21),
('cs','retail','items','item:r_tissue','{"name":"Toaletní papír 4ks","item_type":"product","sku":"RET-022","unit_price":5900,"purchase_price":3200,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"category_ref":"cat:household"}',22),
('cs','retail','items','item:r_bags','{"name":"Sáčky na odpad 30l 20ks","item_type":"product","sku":"RET-023","unit_price":3900,"purchase_price":2000,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","category_ref":"cat:household"}',23),
('cs','retail','items','item:r_sponge','{"name":"Houbička na nádobí 5ks","item_type":"product","sku":"RET-024","unit_price":2900,"purchase_price":1200,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","category_ref":"cat:household"}',24);

-- Items (cs/retail) — Alcohol & Tobacco (21%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','retail','items','item:r_beer','{"name":"Pilsner Urquell 0.5l sklo","item_type":"product","sku":"RET-030","unit_price":2900,"purchase_price":1500,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"category_ref":"cat:alcohol"}',30),
('cs','retail','items','item:r_wine','{"name":"Frankovka 0.75l","item_type":"product","sku":"RET-031","unit_price":14900,"purchase_price":8000,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"category_ref":"cat:alcohol"}',31),
('cs','retail','items','item:r_vodka','{"name":"Finlandia 0.5l","item_type":"product","sku":"RET-032","unit_price":29900,"purchase_price":18000,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","category_ref":"cat:alcohol"}',32),
('cs','retail','items','item:r_cig','{"name":"Marlboro Red","item_type":"product","sku":"RET-033","unit_price":15000,"purchase_price":12000,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","category_ref":"cat:alcohol"}',33);

-- Items (cs/retail) — Press (0% tax)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','retail','items','item:r_newspaper','{"name":"Deník MF DNES","item_type":"product","sku":"RET-040","unit_price":2500,"purchase_price":1500,"sale_tax_rate_ref":"tax:0","purchase_tax_rate_ref":"tax:0","unit":"ks","category_ref":"cat:press"}',40),
('cs','retail','items','item:r_magazine','{"name":"Časopis Reflex","item_type":"product","sku":"RET-041","unit_price":6900,"purchase_price":4000,"sale_tax_rate_ref":"tax:0","purchase_tax_rate_ref":"tax:0","unit":"ks","category_ref":"cat:press"}',41);

-- Items (cs/retail) — Variant: Shopping bag
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','retail','items','item:r_bag_parent','{"name":"Taška","item_type":"product","sku":"RET-050","unit_price":500,"sale_tax_rate_ref":"tax:21","unit":"ks","category_ref":"cat:groceries"}',50),
('cs','retail','items','item:r_bag_small','{"name":"Taška malá","item_type":"variant","unit_price":300,"sale_tax_rate_ref":"tax:21","unit":"ks","parent_ref":"item:r_bag_parent","category_ref":"cat:groceries"}',51),
('cs','retail','items','item:r_bag_large','{"name":"Taška velká","item_type":"variant","unit_price":500,"sale_tax_rate_ref":"tax:21","unit":"ks","parent_ref":"item:r_bag_parent","category_ref":"cat:groceries"}',52);

-- Modifier groups (cs/retail)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','retail','modifier_groups','mg:size','{"name":"Velikost balení","min_selections":0,"max_selections":1}',0);

-- ============================================================================
-- RETAIL MODE — EN locale
-- ============================================================================

-- Sections (en/retail)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','retail','sections','sec:store','{"name":"Store","color":"#4CAF50","is_default":true}',0);

-- Categories (en/retail)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','retail','categories','cat:beverages_r','{"name":"Beverages"}',0),
('en','retail','categories','cat:groceries',  '{"name":"Groceries"}',1),
('en','retail','categories','cat:household',  '{"name":"Household"}',2),
('en','retail','categories','cat:alcohol',    '{"name":"Alcohol & Tobacco"}',3),
('en','retail','categories','cat:press',      '{"name":"Press"}',4);

-- Suppliers (en/retail)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','retail','suppliers','sup:wholesale','{"supplier_name":"City Wholesale"}',0),
('en','retail','suppliers','sup:press_dist','{"supplier_name":"Press Distribution"}',1);

-- Manufacturers (en/retail)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','retail','manufacturers','mfr:cola_company','{"name":"Coca-Cola Company"}',0),
('en','retail','manufacturers','mfr:henkel','{"name":"Henkel"}',1);

-- Items (en/retail) — Beverages (12%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','retail','items','item:r_cola','{"name":"Coca-Cola 0.5l","item_type":"product","sku":"RET-001","alt_sku":"5449000131805","unit_price":3500,"purchase_price":1800,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:beverages_r"}',0),
('en','retail','items','item:r_water','{"name":"Spring Water 0.5l","item_type":"product","sku":"RET-002","unit_price":2500,"purchase_price":1000,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:beverages_r"}',1),
('en','retail','items','item:r_juice_orange','{"name":"Orange Juice 1l","item_type":"product","sku":"RET-003","unit_price":5900,"purchase_price":3200,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:beverages_r"}',2),
('en','retail','items','item:r_energy','{"name":"Red Bull 0.25l","item_type":"product","sku":"RET-004","unit_price":4900,"purchase_price":2800,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:beverages_r"}',3),
('en','retail','items','item:r_milk','{"name":"Semi-skimmed Milk 1l","item_type":"product","sku":"RET-005","unit_price":2900,"purchase_price":1800,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:beverages_r"}',4);

-- Items (en/retail) — Groceries (12%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','retail','items','item:r_bread','{"name":"Whole Grain Bread","item_type":"product","sku":"RET-010","unit_price":4500,"purchase_price":2500,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:groceries"}',10),
('en','retail','items','item:r_butter','{"name":"Butter 250g","item_type":"product","sku":"RET-011","unit_price":5900,"purchase_price":3800,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:groceries"}',11),
('en','retail','items','item:r_cheese','{"name":"Edam Cheese 100g","item_type":"product","sku":"RET-012","unit_price":2900,"purchase_price":1500,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:groceries"}',12),
('en','retail','items','item:r_yogurt','{"name":"Plain Yogurt","item_type":"product","sku":"RET-013","unit_price":1900,"purchase_price":900,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:groceries"}',13),
('en','retail','items','item:r_eggs','{"name":"Eggs M 10pcs","item_type":"product","sku":"RET-014","unit_price":5900,"purchase_price":3500,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","is_stock_tracked":true,"category_ref":"cat:groceries"}',14),
('en','retail','items','item:r_ham','{"name":"Premium Ham 100g","item_type":"product","sku":"RET-015","unit_price":3900,"purchase_price":2200,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:groceries"}',15),
('en','retail','items','item:r_pasta','{"name":"Penne Pasta 500g","item_type":"product","sku":"RET-016","unit_price":3500,"purchase_price":1800,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:groceries"}',16),
('en','retail','items','item:r_rice','{"name":"Long Grain Rice 1kg","item_type":"product","sku":"RET-017","unit_price":4500,"purchase_price":2500,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:groceries"}',17),
('en','retail','items','item:r_chips','{"name":"Potato Chips 130g","item_type":"product","sku":"RET-018","unit_price":3900,"purchase_price":2000,"sale_tax_rate_ref":"tax:12","purchase_tax_rate_ref":"tax:12","unit":"ks","category_ref":"cat:groceries"}',18);

-- Items (en/retail) — Household (21%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','retail','items','item:r_soap','{"name":"Liquid Soap 500ml","item_type":"product","sku":"RET-020","unit_price":6900,"purchase_price":3500,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"category_ref":"cat:household"}',20),
('en','retail','items','item:r_detergent','{"name":"Laundry Detergent 2kg","item_type":"product","sku":"RET-021","unit_price":14900,"purchase_price":8500,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","category_ref":"cat:household"}',21),
('en','retail','items','item:r_tissue','{"name":"Toilet Paper 4pcs","item_type":"product","sku":"RET-022","unit_price":5900,"purchase_price":3200,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"category_ref":"cat:household"}',22),
('en','retail','items','item:r_bags','{"name":"Trash Bags 30l 20pcs","item_type":"product","sku":"RET-023","unit_price":3900,"purchase_price":2000,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","category_ref":"cat:household"}',23),
('en','retail','items','item:r_sponge','{"name":"Dish Sponge 5pcs","item_type":"product","sku":"RET-024","unit_price":2900,"purchase_price":1200,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","category_ref":"cat:household"}',24);

-- Items (en/retail) — Alcohol & Tobacco (21%)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','retail','items','item:r_beer','{"name":"Pilsner Urquell 0.5l bottle","item_type":"product","sku":"RET-030","unit_price":2900,"purchase_price":1500,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"category_ref":"cat:alcohol"}',30),
('en','retail','items','item:r_wine','{"name":"Red Wine 0.75l","item_type":"product","sku":"RET-031","unit_price":14900,"purchase_price":8000,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","is_stock_tracked":true,"category_ref":"cat:alcohol"}',31),
('en','retail','items','item:r_vodka','{"name":"Finlandia Vodka 0.5l","item_type":"product","sku":"RET-032","unit_price":29900,"purchase_price":18000,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","category_ref":"cat:alcohol"}',32),
('en','retail','items','item:r_cig','{"name":"Marlboro Red","item_type":"product","sku":"RET-033","unit_price":15000,"purchase_price":12000,"sale_tax_rate_ref":"tax:21","purchase_tax_rate_ref":"tax:21","unit":"ks","category_ref":"cat:alcohol"}',33);

-- Items (en/retail) — Press (0% tax)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','retail','items','item:r_newspaper','{"name":"Daily Newspaper","item_type":"product","sku":"RET-040","unit_price":2500,"purchase_price":1500,"sale_tax_rate_ref":"tax:0","purchase_tax_rate_ref":"tax:0","unit":"ks","category_ref":"cat:press"}',40),
('en','retail','items','item:r_magazine','{"name":"Weekly Magazine","item_type":"product","sku":"RET-041","unit_price":6900,"purchase_price":4000,"sale_tax_rate_ref":"tax:0","purchase_tax_rate_ref":"tax:0","unit":"ks","category_ref":"cat:press"}',41);

-- Items (en/retail) — Variant: Shopping bag
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','retail','items','item:r_bag_parent','{"name":"Shopping Bag","item_type":"product","sku":"RET-050","unit_price":500,"sale_tax_rate_ref":"tax:21","unit":"ks","category_ref":"cat:groceries"}',50),
('en','retail','items','item:r_bag_small','{"name":"Small Bag","item_type":"variant","unit_price":300,"sale_tax_rate_ref":"tax:21","unit":"ks","parent_ref":"item:r_bag_parent","category_ref":"cat:groceries"}',51),
('en','retail','items','item:r_bag_large','{"name":"Large Bag","item_type":"variant","unit_price":500,"sale_tax_rate_ref":"tax:21","unit":"ks","parent_ref":"item:r_bag_parent","category_ref":"cat:groceries"}',52);

-- Modifier groups (en/retail)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','retail','modifier_groups','mg:size','{"name":"Package Size","min_selections":0,"max_selections":1}',0);

-- ============================================================================
-- SHARED DATA — CS locale (mode='_all')
-- ============================================================================

-- Users (cs)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','_all','users','usr:admin',   '{"full_name":"Tomáš Barta","username":"tomas","role_ref":"admin","is_auth_user":true}',0),
('cs','_all','users','usr:manager', '{"full_name":"Marek Novotný","username":"marek","role_ref":"manager"}',1),
('cs','_all','users','usr:operator','{"full_name":"Martina Malá","username":"martina","role_ref":"operator"}',2),
('cs','_all','users','usr:helper',  '{"full_name":"Eliška Krásná","username":"eliska","role_ref":"helper"}',3);

-- Customers (cs)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','_all','customers','cust:svoboda', '{"first_name":"Martin","last_name":"Svoboda","email":"martin.svoboda@email.cz","phone":"+420 777 111 222"}',0),
('cs','_all','customers','cust:cerna',   '{"first_name":"Lucie","last_name":"Černá","email":"lucie.cerna@email.cz","phone":"+420 777 333 444"}',1),
('cs','_all','customers','cust:krejci',  '{"first_name":"Tomáš","last_name":"Krejčí","phone":"+420 608 555 666"}',2),
('cs','_all','customers','cust:novakova','{"first_name":"Eva","last_name":"Nováková","email":"eva.novakova@firma.cz","address":"Dlouhá 15, Praha 1"}',3),
('cs','_all','customers','cust:vesely',  '{"first_name":"Petr","last_name":"Veselý","phone":"+420 603 777 888","address":"Náměstí Míru 8, Brno","birthdate":"1985-06-15"}',4),
('cs','_all','customers','cust:firma',   '{"first_name":"Firma","last_name":"ABC s.r.o.","email":"info@firmaabc.cz","address":"Průmyslová 42, Ostrava"}',5),
('cs','_all','customers','cust:student', '{"first_name":"Jana","last_name":"Studentová","phone":"+420 775 999 000"}',6),
('cs','_all','customers','cust:senior',  '{"first_name":"Václav","last_name":"Starý","phone":"+420 602 111 333","birthdate":"1955-03-22"}',7);

-- Vouchers (cs) — all types/statuses
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('cs','_all','vouchers','vch:gift_active',   '{"code":"GIFT-001","type":"gift","status":"active","value":50000,"created_days_back":60}',0),
('cs','_all','vouchers','vch:gift_redeemed', '{"code":"GIFT-002","type":"gift","status":"redeemed","value":30000,"created_days_back":45}',1),
('cs','_all','vouchers','vch:disc_bill_pct', '{"code":"DISC-10PCT","type":"discount","status":"active","value":1000,"discount_type":"percent","discount_scope":"bill","created_days_back":75}',2),
('cs','_all','vouchers','vch:disc_prod_abs', '{"code":"DISC-50ABS","type":"discount","status":"active","value":5000,"discount_type":"absolute","discount_scope":"product","created_days_back":55}',3),
('cs','_all','vouchers','vch:disc_cat',      '{"code":"DISC-CAT15","type":"discount","status":"active","value":1500,"discount_type":"percent","discount_scope":"category","category_ref":"cat:napoje","created_days_back":40}',4),
('cs','_all','vouchers','vch:deposit',       '{"code":"DEP-001","type":"deposit","status":"active","value":100000,"created_days_back":30}',5),
('cs','_all','vouchers','vch:expired',       '{"code":"GIFT-EXP","type":"gift","status":"expired","value":25000,"expires_days_ago":30,"created_days_back":90}',6),
('cs','_all','vouchers','vch:cancelled',     '{"code":"GIFT-CAN","type":"gift","status":"cancelled","value":20000,"created_days_back":20}',7);

-- ============================================================================
-- SHARED DATA — EN locale (mode='_all')
-- ============================================================================

-- Users (en)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','_all','users','usr:admin',   '{"full_name":"Tom Barrett","username":"tom","role_ref":"admin","is_auth_user":true}',0),
('en','_all','users','usr:manager', '{"full_name":"Mark Newton","username":"mark","role_ref":"manager"}',1),
('en','_all','users','usr:operator','{"full_name":"Martha Miller","username":"martha","role_ref":"operator"}',2),
('en','_all','users','usr:helper',  '{"full_name":"Lisa Craig","username":"lisa","role_ref":"helper"}',3);

-- Customers (en)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','_all','customers','cust:svoboda', '{"first_name":"Martin","last_name":"Smith","email":"martin.smith@email.com","phone":"+1 555 111 222"}',0),
('en','_all','customers','cust:cerna',   '{"first_name":"Lucy","last_name":"Black","email":"lucy.black@email.com","phone":"+1 555 333 444"}',1),
('en','_all','customers','cust:krejci',  '{"first_name":"Thomas","last_name":"Taylor","phone":"+1 555 555 666"}',2),
('en','_all','customers','cust:novakova','{"first_name":"Eva","last_name":"Newman","email":"eva.newman@company.com","address":"15 Long Street, London"}',3),
('en','_all','customers','cust:vesely',  '{"first_name":"Peter","last_name":"Wesley","phone":"+1 555 777 888","address":"8 Peace Square, Bristol","birthdate":"1985-06-15"}',4),
('en','_all','customers','cust:firma',   '{"first_name":"ABC","last_name":"Company Ltd.","email":"info@abccompany.com","address":"42 Industrial Ave, Manchester"}',5),
('en','_all','customers','cust:student', '{"first_name":"Jane","last_name":"Student","phone":"+1 555 999 000"}',6),
('en','_all','customers','cust:senior',  '{"first_name":"Victor","last_name":"Senior","phone":"+1 555 111 333","birthdate":"1955-03-22"}',7);

-- Vouchers (en) — same codes/values, different locale
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data, sort_order) VALUES
('en','_all','vouchers','vch:gift_active',   '{"code":"GIFT-001","type":"gift","status":"active","value":50000,"created_days_back":60}',0),
('en','_all','vouchers','vch:gift_redeemed', '{"code":"GIFT-002","type":"gift","status":"redeemed","value":30000,"created_days_back":45}',1),
('en','_all','vouchers','vch:disc_bill_pct', '{"code":"DISC-10PCT","type":"discount","status":"active","value":1000,"discount_type":"percent","discount_scope":"bill","created_days_back":75}',2),
('en','_all','vouchers','vch:disc_prod_abs', '{"code":"DISC-50ABS","type":"discount","status":"active","value":5000,"discount_type":"absolute","discount_scope":"product","created_days_back":55}',3),
('en','_all','vouchers','vch:disc_cat',      '{"code":"DISC-CAT15","type":"discount","status":"active","value":1500,"discount_type":"percent","discount_scope":"category","category_ref":"cat:beverages","created_days_back":40}',4),
('en','_all','vouchers','vch:deposit',       '{"code":"DEP-001","type":"deposit","status":"active","value":100000,"created_days_back":30}',5),
('en','_all','vouchers','vch:expired',       '{"code":"GIFT-EXP","type":"gift","status":"expired","value":25000,"expires_days_ago":30,"created_days_back":90}',6),
('en','_all','vouchers','vch:cancelled',     '{"code":"GIFT-CAN","type":"gift","status":"cancelled","value":20000,"created_days_back":20}',7);

-- ============================================================================
-- DAY TEMPLATES (locale=NULL, mode='_all')
-- ============================================================================

-- day:light — Quiet day, 6 bills, cash only
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:light','{"shift_pattern":"single_user","morning_user_ref":"usr:operator","session_open_minutes":480,"session_close_minutes":1320,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":60,"table_ref":"tbl:1","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:espresso","qty":2,"unit_price":5500},{"item_ref":"item:strudel","qty":1,"unit_price":8900}]}],"payments":[{"method_ref":"pm:cash","amount":19900}]},{"time_offset_minutes":120,"table_ref":"tbl:2","guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:soup","qty":1,"unit_price":6900},{"item_ref":"item:schnitzel","qty":1,"unit_price":19900}]}],"payments":[{"method_ref":"pm:cash","amount":26800}]},{"time_offset_minutes":210,"table_ref":"tbl:4","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":2,"unit_price":5900},{"item_ref":"item:svickova","qty":2,"unit_price":22900}]}],"payments":[{"method_ref":"pm:cash","amount":57600}]},{"time_offset_minutes":330,"table_ref":"tbl:1","guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:cappuccino","qty":1,"unit_price":6500},{"item_ref":"item:tiramisu","qty":1,"unit_price":11900}]}],"payments":[{"method_ref":"pm:cash","amount":18400}]},{"time_offset_minutes":450,"table_ref":"tbl:5","guests":3,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:kozel","qty":3,"unit_price":4900},{"item_ref":"item:chicken","qty":2,"unit_price":18900},{"item_ref":"item:salmon","qty":1,"unit_price":27900}]}],"payments":[{"method_ref":"pm:cash","amount":80400}]},{"time_offset_minutes":540,"table_ref":"tbl:bar1","guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:gambrinus","qty":2,"unit_price":3900},{"item_ref":"item:kofola","qty":1,"unit_price":4500}]}],"payments":[{"method_ref":"pm:cash","amount":12300}]}],"stock_documents":[],"reservations":[],"customer_transactions":[]}');

-- day:regular — Normal day, 14 bills, mix of cash+card, multi-course
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:regular','{"shift_pattern":"two_users","morning_user_ref":"usr:operator","evening_user_ref":"usr:helper","session_open_minutes":480,"session_close_minutes":1380,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":30,"table_ref":"tbl:1","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:espresso","qty":2,"unit_price":5500},{"item_ref":"item:caesar","qty":1,"unit_price":14900}]}],"payments":[{"method_ref":"pm:cash","amount":25900}]},{"time_offset_minutes":60,"table_ref":"tbl:2","guests":4,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:soup","qty":4,"unit_price":6900},{"item_ref":"item:svickova","qty":2,"unit_price":22900},{"item_ref":"item:schnitzel","qty":2,"unit_price":19900}]},{"items":[{"item_ref":"item:pilsner","qty":4,"unit_price":5900},{"item_ref":"item:tiramisu","qty":2,"unit_price":11900}]}],"payments":[{"method_ref":"pm:card","amount":137200}]},{"time_offset_minutes":90,"table_ref":"tbl:4","guests":2,"user_ref":"usr:operator","customer_ref":"cust:svoboda","status":"paid","orders":[{"items":[{"item_ref":"item:mattoni","qty":2,"unit_price":3900},{"item_ref":"item:salmon","qty":1,"unit_price":27900},{"item_ref":"item:chicken","qty":1,"unit_price":18900}]}],"payments":[{"method_ref":"pm:card","amount":54600}]},{"time_offset_minutes":120,"table_ref":"tbl:5","guests":3,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:kozel","qty":3,"unit_price":4900},{"item_ref":"item:tartare","qty":1,"unit_price":18900},{"item_ref":"item:burger","qty":2,"unit_price":21900}]}],"payments":[{"method_ref":"pm:cash","amount":76500}]},{"time_offset_minutes":150,"table_ref":"tbl:bar1","guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":2,"unit_price":5900},{"item_ref":"item:kofola","qty":1,"unit_price":4500}]}],"payments":[{"method_ref":"pm:cash","amount":16300}]},{"time_offset_minutes":210,"table_ref":"tbl:6","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:cappuccino","qty":2,"unit_price":6500},{"item_ref":"item:pancakes","qty":2,"unit_price":10900}]}],"payments":[{"method_ref":"pm:cash","amount":34800}]},{"time_offset_minutes":270,"table_ref":"tbl:7","guests":6,"user_ref":"usr:operator","customer_ref":"cust:firma","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":4,"unit_price":5900},{"item_ref":"item:mattoni","qty":2,"unit_price":3900},{"item_ref":"item:soup","qty":6,"unit_price":6900}]},{"items":[{"item_ref":"item:svickova","qty":3,"unit_price":22900},{"item_ref":"item:salmon","qty":2,"unit_price":27900},{"item_ref":"item:fried_cheese","qty":1,"unit_price":17900}]}],"payments":[{"method_ref":"pm:card","amount":202800}]},{"time_offset_minutes":360,"table_ref":"tbl:1","guests":2,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:tea","qty":2,"unit_price":4500},{"item_ref":"item:fondant","qty":2,"unit_price":13900}]}],"payments":[{"method_ref":"pm:cash","amount":36800}]},{"time_offset_minutes":420,"table_ref":"tbl:3","guests":4,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:bernard","qty":4,"unit_price":5500},{"item_ref":"item:bruschetta","qty":2,"unit_price":12900},{"item_ref":"item:chicken","qty":3,"unit_price":18900}]}],"payments":[{"method_ref":"pm:card","amount":104500}]},{"time_offset_minutes":480,"table_ref":"tbl:z1","guests":2,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:lemonade","qty":2,"unit_price":6900},{"item_ref":"item:caesar","qty":2,"unit_price":14900}]}],"payments":[{"method_ref":"pm:cash","amount":43600}]},{"time_offset_minutes":540,"table_ref":"tbl:bar2","guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:staropramen","qty":3,"unit_price":4500}]}],"payments":[{"method_ref":"pm:cash","amount":13500}]},{"time_offset_minutes":600,"table_ref":"tbl:4","guests":2,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":2,"unit_price":5900},{"item_ref":"item:schnitzel","qty":2,"unit_price":19900}]}],"payments":[{"method_ref":"pm:card","amount":51600}]},{"time_offset_minutes":660,"table_ref":"tbl:z3","guests":2,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:juice","qty":2,"unit_price":4500},{"item_ref":"item:sundae","qty":2,"unit_price":9900}]}],"payments":[{"method_ref":"pm:cash","amount":28800}]},{"time_offset_minutes":720,"table_ref":"tbl:5","guests":2,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:gambrinus","qty":2,"unit_price":3900},{"item_ref":"item:birell","qty":1,"unit_price":4500}]}],"payments":[{"method_ref":"pm:cash","amount":12300}]}],"stock_documents":[{"type":"receipt","supplier_ref":"sup:makro","time_offset_minutes":45,"items":[{"item_ref":"item:chicken_breast","qty":3,"unit_price":18900}]}],"reservations":[{"table_ref": "tbl:3", "customer_ref": "cust:svoboda", "time_offset_minutes": 50, "guests": 2, "status": "seated", "note_cs": "Oběd", "note_en": "Lunch"}, {"table_ref": "tbl:6", "customer_ref": "cust:novakova", "time_offset_minutes": 540, "guests": 4, "status": "confirmed", "note_cs": "Večeře", "note_en": "Dinner"}],"customer_transactions":[]}');

-- day:busy — Busy day, 22 bills, high revenue
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:busy','{"shift_pattern":"two_users","morning_user_ref":"usr:operator","evening_user_ref":"usr:helper","session_open_minutes":480,"session_close_minutes":1440,"opening_cash":800000,"cash_movements":[{"type":"deposit","amount":300000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"},{"type":"withdrawal","amount":200000,"reason_cs":"Odvod do trezoru","reason_en":"Safe transfer","time_offset_minutes":400,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":15,"table_ref":"tbl:1","guests":4,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:espresso","qty":4,"unit_price":5500},{"item_ref":"item:soup","qty":4,"unit_price":6900}]},{"items":[{"item_ref":"item:svickova","qty":2,"unit_price":22900},{"item_ref":"item:chicken","qty":2,"unit_price":18900}]}],"payments":[{"method_ref":"pm:card","amount":133200}]},{"time_offset_minutes":30,"table_ref":"tbl:2","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":2,"unit_price":5900},{"item_ref":"item:tartare","qty":1,"unit_price":18900},{"item_ref":"item:schnitzel","qty":1,"unit_price":19900}]}],"payments":[{"method_ref":"pm:cash","amount":50600}]},{"time_offset_minutes":45,"table_ref":"tbl:3","guests":3,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:kozel","qty":3,"unit_price":4900},{"item_ref":"item:burger","qty":3,"unit_price":21900}]}],"payments":[{"method_ref":"pm:card","amount":80400}]},{"time_offset_minutes":60,"table_ref":"tbl:4","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:mattoni","qty":2,"unit_price":3900},{"item_ref":"item:salmon","qty":2,"unit_price":27900}]}],"payments":[{"method_ref":"pm:cash","amount":63600}]},{"time_offset_minutes":75,"table_ref":"tbl:5","guests":4,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":4,"unit_price":5900},{"item_ref":"item:soup","qty":4,"unit_price":6900},{"item_ref":"item:svickova","qty":4,"unit_price":22900}]}],"payments":[{"method_ref":"pm:card","amount":142800}]},{"time_offset_minutes":100,"table_ref":"tbl:6","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:cappuccino","qty":2,"unit_price":6500},{"item_ref":"item:fried_cheese","qty":2,"unit_price":17900}]}],"payments":[{"method_ref":"pm:cash","amount":48800}]},{"time_offset_minutes":120,"table_ref":"tbl:bar1","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:gambrinus","qty":4,"unit_price":3900}]}],"payments":[{"method_ref":"pm:cash","amount":15600}]},{"time_offset_minutes":150,"table_ref":"tbl:7","guests":8,"user_ref":"usr:operator","customer_ref":"cust:vesely","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":6,"unit_price":5900},{"item_ref":"item:mattoni","qty":2,"unit_price":3900},{"item_ref":"item:bruschetta","qty":4,"unit_price":12900}]},{"items":[{"item_ref":"item:svickova","qty":3,"unit_price":22900},{"item_ref":"item:salmon","qty":3,"unit_price":27900},{"item_ref":"item:burger","qty":2,"unit_price":21900}]}],"payments":[{"method_ref":"pm:card","amount":299600}]},{"time_offset_minutes":180,"table_ref":"tbl:z1","guests":2,"user_ref":"usr:operator","customer_ref":"cust:novakova","status":"paid","orders":[{"items":[{"item_ref":"item:lemonade","qty":2,"unit_price":6900},{"item_ref":"item:caesar","qty":2,"unit_price":14900}]}],"payments":[{"method_ref":"pm:cash","amount":43600}]},{"time_offset_minutes":210,"table_ref":"tbl:z2","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:juice","qty":2,"unit_price":4500},{"item_ref":"item:carpaccio","qty":2,"unit_price":16900}]}],"payments":[{"method_ref":"pm:card","amount":42800}]},{"time_offset_minutes":240,"table_ref":"tbl:z3","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:kofola","qty":2,"unit_price":4500},{"item_ref":"item:chicken","qty":2,"unit_price":18900}]}],"payments":[{"method_ref":"pm:cash","amount":46800}]},{"time_offset_minutes":300,"table_ref":"tbl:1","guests":2,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:tea","qty":2,"unit_price":4500},{"item_ref":"item:strudel","qty":2,"unit_price":8900}]}],"payments":[{"method_ref":"pm:cash","amount":26800}]},{"time_offset_minutes":330,"table_ref":"tbl:2","guests":3,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:bernard","qty":3,"unit_price":5500},{"item_ref":"item:schnitzel","qty":3,"unit_price":19900}]}],"payments":[{"method_ref":"pm:card","amount":76200}]},{"time_offset_minutes":360,"table_ref":"tbl:3","guests":2,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:rajec","qty":2,"unit_price":3900},{"item_ref":"item:svickova","qty":2,"unit_price":22900}]}],"payments":[{"method_ref":"pm:cash","amount":53600}]},{"time_offset_minutes":390,"table_ref":"tbl:4","guests":4,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":4,"unit_price":5900},{"item_ref":"item:soup","qty":2,"unit_price":6900},{"item_ref":"item:burger","qty":4,"unit_price":21900}]}],"payments":[{"method_ref":"pm:card","amount":124800}]},{"time_offset_minutes":420,"table_ref":"tbl:bar2","guests":2,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:staropramen","qty":4,"unit_price":4500}]}],"payments":[{"method_ref":"pm:cash","amount":18000}]},{"time_offset_minutes":450,"table_ref":"tbl:5","guests":2,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:mattoni","qty":2,"unit_price":3900},{"item_ref":"item:tiramisu","qty":2,"unit_price":11900}]}],"payments":[{"method_ref":"pm:card","amount":31600}]},{"time_offset_minutes":510,"table_ref":"tbl:6","guests":4,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:kozel","qty":4,"unit_price":4900},{"item_ref":"item:fried_cheese","qty":4,"unit_price":17900}]}],"payments":[{"method_ref":"pm:cash","amount":91200}]},{"time_offset_minutes":570,"table_ref":"tbl:z4","guests":2,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:lemonade","qty":2,"unit_price":6900},{"item_ref":"item:fondant","qty":2,"unit_price":13900}]}],"payments":[{"method_ref":"pm:card","amount":41600}]},{"time_offset_minutes":630,"table_ref":"tbl:bar3","guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":2,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":11800}]},{"time_offset_minutes":690,"table_ref":"tbl:7","guests":4,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:bernard","qty":4,"unit_price":5500},{"item_ref":"item:salmon","qty":2,"unit_price":27900},{"item_ref":"item:chicken","qty":2,"unit_price":18900}]}],"payments":[{"method_ref":"pm:card","amount":115600}]},{"time_offset_minutes":750,"table_ref":"tbl:3","guests":2,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:gambrinus","qty":2,"unit_price":3900},{"item_ref":"item:espresso","qty":2,"unit_price":5500}]}],"payments":[{"method_ref":"pm:cash","amount":18800}]}],"stock_documents":[{"type":"receipt","supplier_ref":"sup:napoje","time_offset_minutes":40,"items":[{"item_ref":"item:cream","qty":2,"unit_price":6900}]},{"type":"waste","time_offset_minutes":600,"items":[{"item_ref":"item:flour","qty":0.5,"unit_price":2900}]}],"reservations":[{"table_ref": "tbl:1", "customer_ref": "cust:firma", "time_offset_minutes": 55, "guests": 4, "status": "seated", "note_cs": "Firemní oběd", "note_en": "Business lunch"}, {"table_ref": "tbl:7", "customer_ref": "cust:vesely", "time_offset_minutes": 145, "guests": 6, "status": "seated", "note_cs": "Oslava", "note_en": "Celebration"}, {"table_ref": "tbl:z1", "customer_ref": "cust:krejci", "time_offset_minutes": 600, "guests": 2, "status": "confirmed", "note_cs": "Večeře", "note_en": "Dinner"}],"customer_transactions":[]}');

-- day:feat_discounts — Discounts: item % off, item abs off, bill % off, bill abs off
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:feat_discounts','{"shift_pattern":"single_user","morning_user_ref":"usr:manager","session_open_minutes":480,"session_close_minutes":1320,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:manager"}],"bills":[{"time_offset_minutes":60,"table_ref":"tbl:1","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:svickova","qty":2,"unit_price":22900,"discount_percent":1000}]}],"payments":[{"method_ref":"pm:cash","amount":41220}]},{"time_offset_minutes":120,"table_ref":"tbl:2","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":2,"unit_price":5900},{"item_ref":"item:schnitzel","qty":2,"unit_price":19900,"discount_amount":2000}]}],"payments":[{"method_ref":"pm:card","amount":47600}]},{"time_offset_minutes":180,"table_ref":"tbl:3","guests":4,"user_ref":"usr:manager","status":"paid","bill_discount_percent":1000,"orders":[{"items":[{"item_ref":"item:soup","qty":4,"unit_price":6900},{"item_ref":"item:chicken","qty":4,"unit_price":18900}]}],"payments":[{"method_ref":"pm:cash","amount":92880}]},{"time_offset_minutes":240,"table_ref":"tbl:4","guests":2,"user_ref":"usr:manager","status":"paid","bill_discount_amount":5000,"orders":[{"items":[{"item_ref":"item:salmon","qty":2,"unit_price":27900},{"item_ref":"item:mattoni","qty":2,"unit_price":3900}]}],"payments":[{"method_ref":"pm:card","amount":58600}]},{"time_offset_minutes":300,"table_ref":"tbl:5","guests":3,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:kozel","qty":3,"unit_price":4900,"discount_percent":500},{"item_ref":"item:burger","qty":3,"unit_price":21900}]}],"payments":[{"method_ref":"pm:cash","amount":79650}]},{"time_offset_minutes":360,"table_ref":"tbl:6","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:espresso","qty":2,"unit_price":5500},{"item_ref":"item:tiramisu","qty":2,"unit_price":11900,"discount_amount":1000}]}],"payments":[{"method_ref":"pm:card","amount":32800}]},{"time_offset_minutes":420,"table_ref":"tbl:bar1","guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":3,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":17700}]},{"time_offset_minutes":480,"table_ref":"tbl:7","guests":6,"user_ref":"usr:manager","status":"paid","bill_discount_percent":500,"orders":[{"items":[{"item_ref":"item:pilsner","qty":6,"unit_price":5900},{"item_ref":"item:svickova","qty":3,"unit_price":22900},{"item_ref":"item:schnitzel","qty":3,"unit_price":19900}]}],"payments":[{"method_ref":"pm:card","amount":158460}]},{"time_offset_minutes":540,"table_ref":"tbl:z1","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:lemonade","qty":2,"unit_price":6900},{"item_ref":"item:caesar","qty":2,"unit_price":14900}]}],"payments":[{"method_ref":"pm:cash","amount":43600}]},{"time_offset_minutes":600,"table_ref":"tbl:z2","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:cappuccino","qty":2,"unit_price":6500},{"item_ref":"item:fondant","qty":2,"unit_price":13900}]}],"payments":[{"method_ref":"pm:card","amount":40800}]}],"stock_documents":[],"reservations":[],"customer_transactions":[]}');

-- day:feat_storno — Voided items, cancelled bill, refunded bill
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:feat_storno','{"shift_pattern":"two_users","morning_user_ref":"usr:operator","evening_user_ref":"usr:manager","session_open_minutes":480,"session_close_minutes":1320,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":60,"table_ref":"tbl:1","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":2,"unit_price":5900},{"item_ref":"item:svickova","qty":1,"unit_price":22900},{"item_ref":"item:salmon","qty":1,"unit_price":27900,"status":"voided"}]}],"payments":[{"method_ref":"pm:cash","amount":34700}]},{"time_offset_minutes":120,"table_ref":"tbl:2","guests":2,"user_ref":"usr:operator","status":"cancelled","orders":[{"items":[{"item_ref":"item:soup","qty":2,"unit_price":6900},{"item_ref":"item:schnitzel","qty":2,"unit_price":19900}]}],"payments":[]},{"time_offset_minutes":180,"table_ref":"tbl:3","guests":3,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:kozel","qty":3,"unit_price":4900},{"item_ref":"item:burger","qty":3,"unit_price":21900}]}],"payments":[{"method_ref":"pm:card","amount":80400}]},{"time_offset_minutes":240,"table_ref":"tbl:4","guests":2,"user_ref":"usr:manager","status":"refunded","orders":[{"items":[{"item_ref":"item:chicken","qty":2,"unit_price":18900}]}],"payments":[{"method_ref":"pm:card","amount":37800}]},{"time_offset_minutes":300,"table_ref":"tbl:5","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:espresso","qty":2,"unit_price":5500},{"item_ref":"item:tiramisu","qty":1,"unit_price":11900},{"item_ref":"item:fondant","qty":1,"unit_price":13900,"status":"voided"}]}],"payments":[{"method_ref":"pm:cash","amount":22900}]},{"time_offset_minutes":360,"table_ref":"tbl:6","guests":4,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":4,"unit_price":5900},{"item_ref":"item:mattoni","qty":2,"unit_price":3900}]},{"items":[{"item_ref":"item:svickova","qty":2,"unit_price":22900},{"item_ref":"item:fried_cheese","qty":2,"unit_price":17900}]}],"payments":[{"method_ref":"pm:card","amount":113000}]},{"time_offset_minutes":420,"table_ref":"tbl:bar1","guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:gambrinus","qty":2,"unit_price":3900}]}],"payments":[{"method_ref":"pm:cash","amount":7800}]},{"time_offset_minutes":480,"table_ref":"tbl:7","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:cappuccino","qty":2,"unit_price":6500},{"item_ref":"item:strudel","qty":2,"unit_price":8900}]}],"payments":[{"method_ref":"pm:cash","amount":30800}]}],"stock_documents":[],"reservations":[],"customer_transactions":[]}');

-- day:feat_vouchers — Voucher creation + redemption
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:feat_vouchers','{"shift_pattern":"single_user","morning_user_ref":"usr:manager","session_open_minutes":480,"session_close_minutes":1320,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:manager"}],"bills":[{"time_offset_minutes":60,"table_ref":"tbl:1","guests":2,"user_ref":"usr:manager","status":"paid","voucher_ref":"vch:disc_bill_pct","orders":[{"items":[{"item_ref":"item:svickova","qty":2,"unit_price":22900}]}],"payments":[{"method_ref":"pm:cash","amount":41220}]},{"time_offset_minutes":120,"table_ref":"tbl:2","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":2,"unit_price":5900},{"item_ref":"item:schnitzel","qty":2,"unit_price":19900}]}],"payments":[{"method_ref":"pm:card","amount":51600}]},{"time_offset_minutes":180,"table_ref":"tbl:3","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:salmon","qty":2,"unit_price":27900}]}],"payments":[{"method_ref":"pm:cash","amount":55800}]},{"time_offset_minutes":240,"table_ref":"tbl:4","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:kozel","qty":2,"unit_price":4900},{"item_ref":"item:chicken","qty":2,"unit_price":18900}]}],"payments":[{"method_ref":"pm:card","amount":47600}]},{"time_offset_minutes":300,"table_ref":"tbl:5","guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:espresso","qty":1,"unit_price":5500},{"item_ref":"item:tiramisu","qty":1,"unit_price":11900}]}],"payments":[{"method_ref":"pm:cash","amount":17400}]},{"time_offset_minutes":360,"table_ref":"tbl:6","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:cappuccino","qty":2,"unit_price":6500},{"item_ref":"item:pancakes","qty":2,"unit_price":10900}]}],"payments":[{"method_ref":"pm:cash","amount":34800}]},{"time_offset_minutes":420,"table_ref":"tbl:bar1","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":4,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":23600}]},{"time_offset_minutes":480,"table_ref":"tbl:7","guests":4,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:soup","qty":4,"unit_price":6900},{"item_ref":"item:svickova","qty":4,"unit_price":22900}]}],"payments":[{"method_ref":"pm:card","amount":119200}]}],"stock_documents":[],"reservations":[],"customer_transactions":[]}');

-- day:feat_loyalty — Points earn + redeem, credit top-up + use
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:feat_loyalty','{"shift_pattern":"single_user","morning_user_ref":"usr:operator","session_open_minutes":480,"session_close_minutes":1320,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":60,"table_ref":"tbl:1","guests":2,"user_ref":"usr:operator","customer_ref":"cust:svoboda","status":"paid","orders":[{"items":[{"item_ref":"item:svickova","qty":2,"unit_price":22900},{"item_ref":"item:pilsner","qty":2,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":57600}]},{"time_offset_minutes":120,"table_ref":"tbl:2","guests":2,"user_ref":"usr:operator","customer_ref":"cust:cerna","status":"paid","orders":[{"items":[{"item_ref":"item:salmon","qty":2,"unit_price":27900}]}],"payments":[{"method_ref":"pm:card","amount":55800}]},{"time_offset_minutes":180,"table_ref":"tbl:3","guests":3,"user_ref":"usr:operator","customer_ref":"cust:vesely","status":"paid","orders":[{"items":[{"item_ref":"item:kozel","qty":3,"unit_price":4900},{"item_ref":"item:burger","qty":3,"unit_price":21900}]}],"payments":[{"method_ref":"pm:cash","amount":80400}]},{"time_offset_minutes":240,"table_ref":"tbl:4","guests":2,"user_ref":"usr:operator","customer_ref":"cust:novakova","status":"paid","orders":[{"items":[{"item_ref":"item:chicken","qty":2,"unit_price":18900},{"item_ref":"item:mattoni","qty":2,"unit_price":3900}]}],"payments":[{"method_ref":"pm:card","amount":45600}]},{"time_offset_minutes":300,"table_ref":"tbl:5","guests":2,"user_ref":"usr:operator","customer_ref":"cust:svoboda","status":"paid","loyalty_points_used":50,"orders":[{"items":[{"item_ref":"item:espresso","qty":2,"unit_price":5500},{"item_ref":"item:tiramisu","qty":2,"unit_price":11900}]}],"payments":[{"method_ref":"pm:cash","amount":29800}]},{"time_offset_minutes":360,"table_ref":"tbl:6","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:cappuccino","qty":2,"unit_price":6500},{"item_ref":"item:fondant","qty":2,"unit_price":13900}]}],"payments":[{"method_ref":"pm:cash","amount":40800}]},{"time_offset_minutes":420,"table_ref":"tbl:bar1","guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":2,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":11800}]},{"time_offset_minutes":480,"table_ref":"tbl:7","guests":4,"user_ref":"usr:operator","customer_ref":"cust:firma","status":"paid","orders":[{"items":[{"item_ref":"item:soup","qty":4,"unit_price":6900},{"item_ref":"item:schnitzel","qty":4,"unit_price":19900}]}],"payments":[{"method_ref":"pm:card","amount":107200}]}],"stock_documents":[],"reservations":[],"customer_transactions":[{"customer_ref":"cust:svoboda","type":"points_earn","points":57,"time_offset_minutes":65},{"customer_ref":"cust:cerna","type":"points_earn","points":55,"time_offset_minutes":125},{"customer_ref":"cust:vesely","type":"points_earn","points":80,"time_offset_minutes":185},{"customer_ref":"cust:novakova","type":"points_earn","points":45,"time_offset_minutes":245},{"customer_ref":"cust:svoboda","type":"points_redeem","points":-50,"time_offset_minutes":305},{"customer_ref":"cust:cerna","type":"credit_topup","credit":50000,"time_offset_minutes":130},{"customer_ref":"cust:firma","type":"points_earn","points":107,"time_offset_minutes":485}]}');

-- day:feat_split_tips — Split cash+card, tips
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:feat_split_tips','{"shift_pattern":"two_users","morning_user_ref":"usr:operator","evening_user_ref":"usr:helper","session_open_minutes":480,"session_close_minutes":1380,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":60,"table_ref":"tbl:1","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:svickova","qty":2,"unit_price":22900},{"item_ref":"item:pilsner","qty":2,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":30000,"tip":2400},{"method_ref":"pm:card","amount":30000,"tip":2400}]},{"time_offset_minutes":120,"table_ref":"tbl:2","guests":4,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:soup","qty":4,"unit_price":6900},{"item_ref":"item:salmon","qty":2,"unit_price":27900},{"item_ref":"item:chicken","qty":2,"unit_price":18900}]}],"payments":[{"method_ref":"pm:card","amount":131600,"tip":10000}]},{"time_offset_minutes":180,"table_ref":"tbl:3","guests":3,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:kozel","qty":3,"unit_price":4900},{"item_ref":"item:burger","qty":3,"unit_price":21900}]}],"payments":[{"method_ref":"pm:cash","amount":40000},{"method_ref":"pm:card","amount":45400,"tip":5000}]},{"time_offset_minutes":240,"table_ref":"tbl:4","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:mattoni","qty":2,"unit_price":3900},{"item_ref":"item:schnitzel","qty":2,"unit_price":19900}]}],"payments":[{"method_ref":"pm:cash","amount":50600,"tip":3000}]},{"time_offset_minutes":300,"table_ref":"tbl:5","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:espresso","qty":2,"unit_price":5500},{"item_ref":"item:tiramisu","qty":2,"unit_price":11900}]}],"payments":[{"method_ref":"pm:card","amount":36800,"tip":2000}]},{"time_offset_minutes":360,"table_ref":"tbl:6","guests":4,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":4,"unit_price":5900},{"item_ref":"item:svickova","qty":2,"unit_price":22900},{"item_ref":"item:fried_cheese","qty":2,"unit_price":17900}]}],"payments":[{"method_ref":"pm:cash","amount":55000,"tip":4600},{"method_ref":"pm:card","amount":55000,"tip":4600}]},{"time_offset_minutes":420,"table_ref":"tbl:7","guests":6,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:bernard","qty":6,"unit_price":5500},{"item_ref":"item:tartare","qty":2,"unit_price":18900},{"item_ref":"item:salmon","qty":4,"unit_price":27900}]}],"payments":[{"method_ref":"pm:card","amount":192400,"tip":15000}]},{"time_offset_minutes":480,"table_ref":"tbl:bar1","guests":2,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:gambrinus","qty":4,"unit_price":3900}]}],"payments":[{"method_ref":"pm:cash","amount":17600,"tip":2000}]},{"time_offset_minutes":540,"table_ref":"tbl:z1","guests":2,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:lemonade","qty":2,"unit_price":6900},{"item_ref":"item:caesar","qty":2,"unit_price":14900}]}],"payments":[{"method_ref":"pm:cash","amount":23000},{"method_ref":"pm:card","amount":23600,"tip":3000}]},{"time_offset_minutes":600,"table_ref":"tbl:z2","guests":2,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:cappuccino","qty":2,"unit_price":6500},{"item_ref":"item:pancakes","qty":2,"unit_price":10900}]}],"payments":[{"method_ref":"pm:card","amount":36800,"tip":2000}]}],"stock_documents":[],"reservations":[],"customer_transactions":[]}');

-- day:feat_modifiers — Items with modifiers, recipe items
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:feat_modifiers','{"shift_pattern":"single_user","morning_user_ref":"usr:operator","session_open_minutes":480,"session_close_minutes":1320,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":60,"table_ref":"tbl:1","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:burger_classic","qty":1,"unit_price":21900,"modifiers":[{"ref":"item:mod_fries","qty":1,"unit_price":4900},{"ref":"item:mod_cheese","qty":1,"unit_price":2900},{"ref":"item:mod_ketchup","qty":1,"unit_price":0}]},{"item_ref":"item:burger_double","qty":1,"unit_price":25900,"modifiers":[{"ref":"item:mod_fries","qty":1,"unit_price":4900},{"ref":"item:mod_bacon","qty":1,"unit_price":3900},{"ref":"item:mod_bbq","qty":1,"unit_price":1500}]}]}],"payments":[{"method_ref":"pm:cash","amount":65900}]},{"time_offset_minutes":120,"table_ref":"tbl:2","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:fried_cheese","qty":2,"unit_price":17900},{"item_ref":"item:pilsner","qty":2,"unit_price":5900}]}],"payments":[{"method_ref":"pm:card","amount":47600}]},{"time_offset_minutes":180,"table_ref":"tbl:3","guests":3,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:burger_veg","qty":1,"unit_price":18900,"modifiers":[{"ref":"item:mod_salad","qty":1,"unit_price":3900},{"ref":"item:mod_mayo","qty":1,"unit_price":0}]},{"item_ref":"item:burger_classic","qty":2,"unit_price":21900,"modifiers":[{"ref":"item:mod_fries","qty":1,"unit_price":4900}]}]}],"payments":[{"method_ref":"pm:cash","amount":76500}]},{"time_offset_minutes":240,"table_ref":"tbl:4","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:svickova","qty":2,"unit_price":22900}]}],"payments":[{"method_ref":"pm:card","amount":45800}]},{"time_offset_minutes":300,"table_ref":"tbl:5","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:kozel","qty":2,"unit_price":4900},{"item_ref":"item:chicken","qty":2,"unit_price":18900}]}],"payments":[{"method_ref":"pm:cash","amount":47600}]},{"time_offset_minutes":360,"table_ref":"tbl:6","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:fried_cheese","qty":1,"unit_price":17900},{"item_ref":"item:burger_classic","qty":1,"unit_price":21900,"modifiers":[{"ref":"item:mod_cheese","qty":2,"unit_price":2900}]}]}],"payments":[{"method_ref":"pm:card","amount":45600}]},{"time_offset_minutes":420,"table_ref":"tbl:bar1","guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":2,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":11800}]},{"time_offset_minutes":480,"table_ref":"tbl:7","guests":4,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:burger_classic","qty":2,"unit_price":21900,"modifiers":[{"ref":"item:mod_fries","qty":1,"unit_price":4900},{"ref":"item:mod_bbq","qty":1,"unit_price":1500}]},{"item_ref":"item:burger_double","qty":2,"unit_price":25900,"modifiers":[{"ref":"item:mod_fries","qty":1,"unit_price":4900},{"ref":"item:mod_cheese","qty":1,"unit_price":2900},{"ref":"item:mod_bacon","qty":1,"unit_price":3900}]}]}],"payments":[{"method_ref":"pm:card","amount":129200}]}],"stock_documents":[],"reservations":[],"customer_transactions":[]}');

-- day:feat_stock — Stock receipt, waste, inventory, correction + normal sales
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:feat_stock','{"shift_pattern":"single_user","morning_user_ref":"usr:manager","session_open_minutes":480,"session_close_minutes":1320,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:manager"}],"bills":[{"time_offset_minutes":90,"table_ref":"tbl:1","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":2,"unit_price":5900},{"item_ref":"item:svickova","qty":2,"unit_price":22900}]}],"payments":[{"method_ref":"pm:cash","amount":57600}]},{"time_offset_minutes":150,"table_ref":"tbl:2","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:mattoni","qty":2,"unit_price":3900},{"item_ref":"item:salmon","qty":2,"unit_price":27900}]}],"payments":[{"method_ref":"pm:card","amount":63600}]},{"time_offset_minutes":210,"table_ref":"tbl:3","guests":3,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:kozel","qty":3,"unit_price":4900},{"item_ref":"item:schnitzel","qty":3,"unit_price":19900}]}],"payments":[{"method_ref":"pm:cash","amount":74400}]},{"time_offset_minutes":300,"table_ref":"tbl:4","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:espresso","qty":2,"unit_price":5500},{"item_ref":"item:tiramisu","qty":2,"unit_price":11900}]}],"payments":[{"method_ref":"pm:card","amount":34800}]},{"time_offset_minutes":360,"table_ref":"tbl:5","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:chicken","qty":2,"unit_price":18900},{"item_ref":"item:pilsner","qty":2,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":49600}]},{"time_offset_minutes":420,"table_ref":"tbl:bar1","guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:gambrinus","qty":2,"unit_price":3900}]}],"payments":[{"method_ref":"pm:cash","amount":7800}]},{"time_offset_minutes":480,"table_ref":"tbl:6","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:cappuccino","qty":2,"unit_price":6500},{"item_ref":"item:fondant","qty":2,"unit_price":13900}]}],"payments":[{"method_ref":"pm:card","amount":40800}]},{"time_offset_minutes":540,"table_ref":"tbl:7","guests":4,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:bernard","qty":4,"unit_price":5500},{"item_ref":"item:burger","qty":4,"unit_price":21900}]}],"payments":[{"method_ref":"pm:card","amount":109600}]}],"stock_documents":[{"type":"receipt","supplier_ref":"sup:makro","time_offset_minutes":30,"items":[{"item_ref":"item:chicken_breast","qty":10,"unit_price":18900},{"item_ref":"item:edam","qty":5000,"unit_price":16},{"item_ref":"item:flour","qty":5,"unit_price":2900},{"item_ref":"item:cream","qty":3,"unit_price":6900}]},{"type":"waste","time_offset_minutes":35,"items":[{"item_ref":"item:cream","qty":0.5,"unit_price":6900}]},{"type":"inventory","time_offset_minutes":600,"items":[{"item_ref":"item:chicken_breast","qty":8,"unit_price":18900},{"item_ref":"item:flour","qty":4.5,"unit_price":2900}]},{"type":"correction","time_offset_minutes":610,"items":[{"item_ref":"item:edam","qty":100,"unit_price":16}]}],"reservations":[],"customer_transactions":[]}');

-- day:feat_reservations — Reservations all statuses (gastro only)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:feat_reservations','{"shift_pattern":"two_users","morning_user_ref":"usr:operator","evening_user_ref":"usr:helper","session_open_minutes":480,"session_close_minutes":1380,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":60,"table_ref":"tbl:1","guests":4,"user_ref":"usr:operator","customer_ref":"cust:svoboda","status":"paid","orders":[{"items":[{"item_ref":"item:soup","qty":4,"unit_price":6900},{"item_ref":"item:svickova","qty":4,"unit_price":22900}]}],"payments":[{"method_ref":"pm:card","amount":119200}]},{"time_offset_minutes":120,"table_ref":"tbl:2","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":2,"unit_price":5900},{"item_ref":"item:schnitzel","qty":2,"unit_price":19900}]}],"payments":[{"method_ref":"pm:cash","amount":51600}]},{"time_offset_minutes":180,"table_ref":"tbl:3","guests":3,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:kozel","qty":3,"unit_price":4900},{"item_ref":"item:chicken","qty":3,"unit_price":18900}]}],"payments":[{"method_ref":"pm:card","amount":71400}]},{"time_offset_minutes":240,"table_ref":"tbl:4","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:mattoni","qty":2,"unit_price":3900},{"item_ref":"item:salmon","qty":2,"unit_price":27900}]}],"payments":[{"method_ref":"pm:cash","amount":63600}]},{"time_offset_minutes":300,"table_ref":"tbl:5","guests":2,"user_ref":"usr:operator","customer_ref":"cust:vesely","status":"paid","orders":[{"items":[{"item_ref":"item:espresso","qty":2,"unit_price":5500},{"item_ref":"item:tiramisu","qty":2,"unit_price":11900}]}],"payments":[{"method_ref":"pm:card","amount":34800}]},{"time_offset_minutes":360,"table_ref":"tbl:6","guests":4,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":4,"unit_price":5900},{"item_ref":"item:svickova","qty":2,"unit_price":22900},{"item_ref":"item:burger","qty":2,"unit_price":21900}]}],"payments":[{"method_ref":"pm:cash","amount":113200}]},{"time_offset_minutes":420,"table_ref":"tbl:7","guests":6,"user_ref":"usr:helper","customer_ref":"cust:firma","status":"paid","orders":[{"items":[{"item_ref":"item:bernard","qty":6,"unit_price":5500},{"item_ref":"item:tartare","qty":3,"unit_price":18900},{"item_ref":"item:salmon","qty":3,"unit_price":27900}]}],"payments":[{"method_ref":"pm:card","amount":173400}]},{"time_offset_minutes":480,"table_ref":"tbl:bar1","guests":2,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:gambrinus","qty":4,"unit_price":3900}]}],"payments":[{"method_ref":"pm:cash","amount":15600}]},{"time_offset_minutes":540,"table_ref":"tbl:z1","guests":2,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:lemonade","qty":2,"unit_price":6900},{"item_ref":"item:caesar","qty":2,"unit_price":14900}]}],"payments":[{"method_ref":"pm:card","amount":43600}]},{"time_offset_minutes":600,"table_ref":"tbl:z2","guests":2,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:cappuccino","qty":2,"unit_price":6500},{"item_ref":"item:fondant","qty":2,"unit_price":13900}]}],"payments":[{"method_ref":"pm:cash","amount":40800}]}],"stock_documents":[],"reservations":[{"table_ref":"tbl:1","customer_ref":"cust:svoboda","time_offset_minutes":55,"guests":4,"status":"seated","note_cs":"Narozeniny","note_en":"Birthday"},{"table_ref":"tbl:5","customer_ref":"cust:vesely","time_offset_minutes":295,"guests":2,"status":"seated","note_cs":"Výročí","note_en":"Anniversary"},{"table_ref":"tbl:7","customer_ref":"cust:firma","time_offset_minutes":415,"guests":6,"status":"seated","note_cs":"Firemní oběd","note_en":"Business lunch"},{"table_ref":"tbl:z3","customer_ref":"cust:krejci","time_offset_minutes":500,"guests":2,"status":"cancelled","note_cs":"Zrušeno telefonicky","note_en":"Cancelled by phone"},{"table_ref":"tbl:z4","customer_ref":"cust:student","time_offset_minutes":550,"guests":3,"status":"cancelled"},{"table_ref":"tbl:3","customer_ref":"cust:novakova","time_offset_minutes":800,"guests":4,"status":"confirmed","note_cs":"Večeře","note_en":"Dinner"}],"customer_transactions":[]}');

-- day:feat_multicurrency — EUR payments with exchange rate
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:feat_multicurrency','{"shift_pattern":"single_user","morning_user_ref":"usr:operator","session_open_minutes":480,"session_close_minutes":1320,"opening_cash":500000,"has_foreign_currency":true,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":60,"table_ref":"tbl:1","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:svickova","qty":2,"unit_price":22900}]}],"payments":[{"method_ref":"pm:cash","amount":45800,"foreign_currency":"EUR","foreign_amount":1800,"exchange_rate":25.50}]},{"time_offset_minutes":120,"table_ref":"tbl:2","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":2,"unit_price":5900},{"item_ref":"item:schnitzel","qty":2,"unit_price":19900}]}],"payments":[{"method_ref":"pm:card","amount":51600}]},{"time_offset_minutes":180,"table_ref":"tbl:3","guests":3,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:kozel","qty":3,"unit_price":4900},{"item_ref":"item:salmon","qty":3,"unit_price":27900}]}],"payments":[{"method_ref":"pm:cash","amount":98400,"foreign_currency":"EUR","foreign_amount":3900,"exchange_rate":25.50}]},{"time_offset_minutes":240,"table_ref":"tbl:4","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:mattoni","qty":2,"unit_price":3900},{"item_ref":"item:chicken","qty":2,"unit_price":18900}]}],"payments":[{"method_ref":"pm:cash","amount":45600}]},{"time_offset_minutes":300,"table_ref":"tbl:5","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:espresso","qty":2,"unit_price":5500},{"item_ref":"item:tiramisu","qty":2,"unit_price":11900}]}],"payments":[{"method_ref":"pm:card","amount":34800}]},{"time_offset_minutes":360,"table_ref":"tbl:6","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:cappuccino","qty":2,"unit_price":6500},{"item_ref":"item:pancakes","qty":2,"unit_price":10900}]}],"payments":[{"method_ref":"pm:cash","amount":34800}]},{"time_offset_minutes":420,"table_ref":"tbl:bar1","guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":2,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":11800,"foreign_currency":"EUR","foreign_amount":500,"exchange_rate":25.50}]},{"time_offset_minutes":480,"table_ref":"tbl:7","guests":4,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:soup","qty":4,"unit_price":6900},{"item_ref":"item:svickova","qty":4,"unit_price":22900}]}],"payments":[{"method_ref":"pm:card","amount":119200}]}],"stock_documents":[],"reservations":[],"customer_transactions":[]}');

-- day:feat_cash_ops — Various cash movements
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:feat_cash_ops','{"shift_pattern":"two_users","morning_user_ref":"usr:manager","evening_user_ref":"usr:operator","session_open_minutes":480,"session_close_minutes":1380,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":300000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:manager"},{"type":"withdrawal","amount":100000,"reason_cs":"Výplata brigádník","reason_en":"Employee payroll","time_offset_minutes":120,"user_ref":"usr:manager"},{"type":"expense","amount":15000,"reason_cs":"Nákup čistících prostředků","reason_en":"Cleaning supplies purchase","time_offset_minutes":180,"user_ref":"usr:manager"},{"type":"withdrawal","amount":200000,"reason_cs":"Odvod do trezoru","reason_en":"Safe transfer","time_offset_minutes":400,"user_ref":"usr:manager"},{"type":"deposit","amount":50000,"reason_cs":"Drobné pro večerní směnu","reason_en":"Evening shift change","time_offset_minutes":480,"user_ref":"usr:operator"},{"type":"expense","amount":8500,"reason_cs":"Poštovné","reason_en":"Postage","time_offset_minutes":600,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":60,"table_ref":"tbl:1","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:svickova","qty":2,"unit_price":22900},{"item_ref":"item:pilsner","qty":2,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":57600}]},{"time_offset_minutes":150,"table_ref":"tbl:2","guests":3,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:soup","qty":3,"unit_price":6900},{"item_ref":"item:schnitzel","qty":3,"unit_price":19900}]}],"payments":[{"method_ref":"pm:cash","amount":80400}]},{"time_offset_minutes":240,"table_ref":"tbl:3","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:salmon","qty":2,"unit_price":27900},{"item_ref":"item:mattoni","qty":2,"unit_price":3900}]}],"payments":[{"method_ref":"pm:card","amount":63600}]},{"time_offset_minutes":330,"table_ref":"tbl:4","guests":4,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:kozel","qty":4,"unit_price":4900},{"item_ref":"item:burger","qty":4,"unit_price":21900}]}],"payments":[{"method_ref":"pm:cash","amount":107200}]},{"time_offset_minutes":420,"table_ref":"tbl:5","guests":2,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:espresso","qty":2,"unit_price":5500},{"item_ref":"item:tiramisu","qty":2,"unit_price":11900}]}],"payments":[{"method_ref":"pm:card","amount":34800}]},{"time_offset_minutes":510,"table_ref":"tbl:6","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:cappuccino","qty":2,"unit_price":6500},{"item_ref":"item:fondant","qty":2,"unit_price":13900}]}],"payments":[{"method_ref":"pm:cash","amount":40800}]},{"time_offset_minutes":570,"table_ref":"tbl:bar1","guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":3,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":17700}]},{"time_offset_minutes":630,"table_ref":"tbl:7","guests":4,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:bernard","qty":4,"unit_price":5500},{"item_ref":"item:chicken","qty":4,"unit_price":18900}]}],"payments":[{"method_ref":"pm:card","amount":97600}]},{"time_offset_minutes":690,"table_ref":"tbl:z1","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:lemonade","qty":2,"unit_price":6900},{"item_ref":"item:caesar","qty":2,"unit_price":14900}]}],"payments":[{"method_ref":"pm:cash","amount":43600}]},{"time_offset_minutes":750,"table_ref":"tbl:z2","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:tea","qty":2,"unit_price":4500},{"item_ref":"item:strudel","qty":2,"unit_price":8900}]}],"payments":[{"method_ref":"pm:cash","amount":26800}]}],"stock_documents":[],"reservations":[],"customer_transactions":[]}');

-- day:feat_takeaway — All takeaway/no-table bills
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:feat_takeaway','{"shift_pattern":"single_user","morning_user_ref":"usr:operator","session_open_minutes":480,"session_close_minutes":1320,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":30,"is_takeaway":true,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:espresso","qty":2,"unit_price":5500}]}],"payments":[{"method_ref":"pm:cash","amount":11000}]},{"time_offset_minutes":60,"is_takeaway":true,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:cappuccino","qty":1,"unit_price":6500},{"item_ref":"item:strudel","qty":1,"unit_price":8900}]}],"payments":[{"method_ref":"pm:card","amount":15400}]},{"time_offset_minutes":120,"is_takeaway":true,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:svickova","qty":1,"unit_price":22900}]}],"payments":[{"method_ref":"pm:cash","amount":22900}]},{"time_offset_minutes":180,"is_takeaway":true,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:schnitzel","qty":2,"unit_price":19900}]}],"payments":[{"method_ref":"pm:card","amount":39800}]},{"time_offset_minutes":240,"is_takeaway":true,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:burger","qty":1,"unit_price":21900},{"item_ref":"item:kofola","qty":1,"unit_price":4500}]}],"payments":[{"method_ref":"pm:cash","amount":26400}]},{"time_offset_minutes":300,"is_takeaway":true,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:chicken","qty":2,"unit_price":18900},{"item_ref":"item:mattoni","qty":2,"unit_price":3900}]}],"payments":[{"method_ref":"pm:cash","amount":45600}]},{"time_offset_minutes":360,"is_takeaway":true,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:soup","qty":2,"unit_price":6900},{"item_ref":"item:salmon","qty":1,"unit_price":27900}]}],"payments":[{"method_ref":"pm:card","amount":41700}]},{"time_offset_minutes":420,"is_takeaway":true,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:tiramisu","qty":2,"unit_price":11900},{"item_ref":"item:fondant","qty":1,"unit_price":13900}]}],"payments":[{"method_ref":"pm:cash","amount":37700}]},{"time_offset_minutes":480,"is_takeaway":true,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:fried_cheese","qty":2,"unit_price":17900}]}],"payments":[{"method_ref":"pm:card","amount":35800}]},{"time_offset_minutes":540,"is_takeaway":true,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:tea","qty":1,"unit_price":4500},{"item_ref":"item:pancakes","qty":2,"unit_price":10900}]}],"payments":[{"method_ref":"pm:cash","amount":26300}]}],"stock_documents":[],"reservations":[],"customer_transactions":[]}');

-- day:today_open — Open session, 3 open bills, 1 open order
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:today_open','{"shift_pattern":"single_user","morning_user_ref":"usr:operator","session_open_minutes":480,"session_close_minutes":null,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"},{"type":"withdrawal","amount":150000,"reason_cs":"Odvod do trezoru","reason_en":"Safe transfer","time_offset_minutes":180,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":30,"table_ref":"tbl:1","guests":2,"user_ref":"usr:operator","customer_ref":"cust:svoboda","status":"paid","orders":[{"items":[{"item_ref":"item:espresso","qty":2,"unit_price":5500},{"item_ref":"item:caesar","qty":2,"unit_price":14900}]}],"payments":[{"method_ref":"pm:cash","amount":40800}]},{"time_offset_minutes":60,"table_ref":"tbl:2","guests":2,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:pilsner","qty":2,"unit_price":5900},{"item_ref":"item:svickova","qty":2,"unit_price":22900}]}],"payments":[{"method_ref":"pm:card","amount":57600}]},{"time_offset_minutes":120,"table_ref":"tbl:3","guests":4,"user_ref":"usr:operator","customer_ref":"cust:novakova","status":"opened","orders":[{"items":[{"item_ref":"item:kozel","qty":4,"unit_price":4900},{"item_ref":"item:soup","qty":4,"unit_price":6900}],"prep_status":"delivered"},{"items":[{"item_ref":"item:svickova","qty":2,"unit_price":22900},{"item_ref":"item:schnitzel","qty":2,"unit_price":19900}],"prep_status":"created"}],"payments":[]},{"time_offset_minutes":150,"table_ref":"tbl:5","guests":2,"user_ref":"usr:operator","status":"opened","orders":[{"items":[{"item_ref":"item:pilsner","qty":2,"unit_price":5900},{"item_ref":"item:mattoni","qty":2,"unit_price":3900}],"prep_status":"ready"}],"payments":[]},{"time_offset_minutes":180,"table_ref":"tbl:6","guests":3,"user_ref":"usr:operator","status":"opened","orders":[{"items":[{"item_ref":"item:lemonade","qty":3,"unit_price":6900}],"prep_status":"created"}],"payments":[]}],"stock_documents":[],"reservations":[{"table_ref":"tbl:7","customer_ref":"cust:firma","time_offset_minutes":240,"guests":4,"status":"confirmed","note_cs":"Firemní oběd","note_en":"Business lunch"},{"table_ref":"tbl:z2","customer_ref":"cust:vesely","time_offset_minutes":600,"guests":2,"status":"confirmed","note_cs":"Večeře","note_en":"Dinner"}],"customer_transactions":[]}');

-- ============================================================================
-- SCHEDULE (locale=NULL, mode='_all')
-- ============================================================================

INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_schedule','schedule:default','{"days_back":90,"work_days":["mon","tue","wed","thu","fri","sat"],"week_pattern":["day:regular","day:regular","day:regular","day:regular","day:busy","day:busy"],"overrides":{"85":"day:feat_stock","78":"day:feat_discounts","71":"day:feat_storno","64":"day:feat_vouchers","57":"day:feat_loyalty","50":"day:feat_split_tips","43":"day:feat_modifiers","36":"day:feat_reservations","29":"day:feat_multicurrency","22":"day:feat_cash_ops","15":"day:feat_stock","8":"day:feat_takeaway","1":"day:light","0":"day:today_open"}}');

-- ============================================================================
-- RLS — block all client access (anon + authenticated)
-- ============================================================================
-- SECURITY DEFINER functions (create_demo_company) bypass RLS automatically.
ALTER TABLE seed_demo_data ENABLE ROW LEVEL SECURITY;
