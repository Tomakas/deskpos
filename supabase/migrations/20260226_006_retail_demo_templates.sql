-- ============================================================================
-- Migration: 20260226_006_retail_demo_templates
-- Description: Add 12 retail day templates + retail schedule for demo creation.
--              Re-create create_demo_company() with NULL safety guards and
--              mode-aware schedule lookup so retail demos work correctly.
-- ============================================================================

-- ============================================================================
-- PART A: Retail day templates (locale=NULL, mode='_all')
-- ============================================================================

-- day:r_light — 6 bills, single (operator), cash only
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:r_light','{"shift_pattern":"single_user","morning_user_ref":"usr:operator","session_open_minutes":360,"session_close_minutes":1320,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":60,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_bread","qty":1,"unit_price":4500},{"item_ref":"item:r_butter","qty":1,"unit_price":5900},{"item_ref":"item:r_milk","qty":1,"unit_price":2900}]}],"payments":[{"method_ref":"pm:cash","amount":13300}]},{"time_offset_minutes":120,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_cola","qty":2,"unit_price":3500},{"item_ref":"item:r_chips","qty":1,"unit_price":3900}]}],"payments":[{"method_ref":"pm:cash","amount":10900}]},{"time_offset_minutes":210,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_newspaper","qty":1,"unit_price":2500},{"item_ref":"item:r_beer","qty":2,"unit_price":2900}]}],"payments":[{"method_ref":"pm:cash","amount":8300}]},{"time_offset_minutes":330,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_soap","qty":1,"unit_price":6900},{"item_ref":"item:r_tissue","qty":1,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":12800}]},{"time_offset_minutes":450,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_eggs","qty":1,"unit_price":5900},{"item_ref":"item:r_cheese","qty":2,"unit_price":2900},{"item_ref":"item:r_ham","qty":1,"unit_price":3900}]}],"payments":[{"method_ref":"pm:cash","amount":15600}]},{"time_offset_minutes":540,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_water","qty":3,"unit_price":2500},{"item_ref":"item:r_yogurt","qty":2,"unit_price":1900}]}],"payments":[{"method_ref":"pm:cash","amount":11300}]}],"stock_documents":[],"reservations":[],"customer_transactions":[]}');

-- day:r_regular — 12 bills, two users (operator+helper), cash+card, 1 stock receipt
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:r_regular','{"shift_pattern":"two_users","morning_user_ref":"usr:operator","evening_user_ref":"usr:helper","session_open_minutes":360,"session_close_minutes":1380,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":30,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_bread","qty":1,"unit_price":4500},{"item_ref":"item:r_butter","qty":1,"unit_price":5900},{"item_ref":"item:r_cola","qty":1,"unit_price":3500}]}],"payments":[{"method_ref":"pm:cash","amount":13900}]},{"time_offset_minutes":60,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_beer","qty":2,"unit_price":2900},{"item_ref":"item:r_wine","qty":1,"unit_price":14900},{"item_ref":"item:r_chips","qty":1,"unit_price":3900}]}],"payments":[{"method_ref":"pm:card","amount":24600}]},{"time_offset_minutes":90,"guests":1,"user_ref":"usr:operator","customer_ref":"cust:svoboda","status":"paid","orders":[{"items":[{"item_ref":"item:r_cola","qty":1,"unit_price":3500},{"item_ref":"item:r_water","qty":1,"unit_price":2500},{"item_ref":"item:r_energy","qty":1,"unit_price":4900}]}],"payments":[{"method_ref":"pm:cash","amount":10900}]},{"time_offset_minutes":120,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_cheese","qty":3,"unit_price":2900},{"item_ref":"item:r_ham","qty":2,"unit_price":3900},{"item_ref":"item:r_yogurt","qty":1,"unit_price":1900}]}],"payments":[{"method_ref":"pm:card","amount":18400}]},{"time_offset_minutes":150,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_soap","qty":1,"unit_price":6900},{"item_ref":"item:r_tissue","qty":1,"unit_price":5900},{"item_ref":"item:r_bags","qty":1,"unit_price":3900}]}],"payments":[{"method_ref":"pm:cash","amount":16700}]},{"time_offset_minutes":210,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_newspaper","qty":1,"unit_price":2500},{"item_ref":"item:r_magazine","qty":1,"unit_price":6900}]}],"payments":[{"method_ref":"pm:cash","amount":9400}]},{"time_offset_minutes":270,"guests":1,"user_ref":"usr:operator","customer_ref":"cust:firma","status":"paid","orders":[{"items":[{"item_ref":"item:r_bread","qty":1,"unit_price":4500},{"item_ref":"item:r_milk","qty":1,"unit_price":2900},{"item_ref":"item:r_eggs","qty":1,"unit_price":5900},{"item_ref":"item:r_butter","qty":1,"unit_price":5900}]}],"payments":[{"method_ref":"pm:card","amount":19200}]},{"time_offset_minutes":360,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_beer","qty":3,"unit_price":2900},{"item_ref":"item:r_cig","qty":1,"unit_price":15000}]}],"payments":[{"method_ref":"pm:cash","amount":23700}]},{"time_offset_minutes":420,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_water","qty":2,"unit_price":2500},{"item_ref":"item:r_juice_orange","qty":1,"unit_price":5900}]}],"payments":[{"method_ref":"pm:card","amount":10900}]},{"time_offset_minutes":480,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_detergent","qty":1,"unit_price":14900},{"item_ref":"item:r_sponge","qty":1,"unit_price":2900}]}],"payments":[{"method_ref":"pm:cash","amount":17800}]},{"time_offset_minutes":540,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_rice","qty":1,"unit_price":4500},{"item_ref":"item:r_pasta","qty":1,"unit_price":3500},{"item_ref":"item:r_cheese","qty":1,"unit_price":2900}]}],"payments":[{"method_ref":"pm:card","amount":10900}]},{"time_offset_minutes":600,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_cola","qty":2,"unit_price":3500},{"item_ref":"item:r_chips","qty":1,"unit_price":3900},{"item_ref":"item:r_energy","qty":1,"unit_price":4900}]}],"payments":[{"method_ref":"pm:cash","amount":15800}]}],"stock_documents":[{"type":"receipt","supplier_ref":"sup:wholesale","time_offset_minutes":45,"note_cs":"Běžné doplnění zásob","note_en":"Regular stock replenishment","items":[{"item_ref":"item:r_cola","qty":24,"unit_price":1800},{"item_ref":"item:r_water","qty":12,"unit_price":1000}]}],"reservations":[],"customer_transactions":[]}');

-- day:r_busy — 20 bills, two users, high revenue, receipt+waste
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:r_busy','{"shift_pattern":"two_users","morning_user_ref":"usr:operator","evening_user_ref":"usr:helper","session_open_minutes":360,"session_close_minutes":1440,"opening_cash":800000,"cash_movements":[{"type":"deposit","amount":300000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"},{"type":"withdrawal","amount":200000,"reason_cs":"Odvod do trezoru","reason_en":"Safe transfer","time_offset_minutes":400,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":15,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_bread","qty":3,"unit_price":4500},{"item_ref":"item:r_butter","qty":2,"unit_price":5900},{"item_ref":"item:r_milk","qty":2,"unit_price":2900}]}],"payments":[{"method_ref":"pm:card","amount":31100}]},{"time_offset_minutes":30,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_beer","qty":6,"unit_price":2900},{"item_ref":"item:r_chips","qty":1,"unit_price":3900}]}],"payments":[{"method_ref":"pm:cash","amount":21300}]},{"time_offset_minutes":45,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_cola","qty":4,"unit_price":3500},{"item_ref":"item:r_energy","qty":2,"unit_price":4900}]}],"payments":[{"method_ref":"pm:card","amount":23800}]},{"time_offset_minutes":60,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_wine","qty":1,"unit_price":14900},{"item_ref":"item:r_vodka","qty":1,"unit_price":29900}]}],"payments":[{"method_ref":"pm:cash","amount":44800}]},{"time_offset_minutes":75,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_eggs","qty":2,"unit_price":5900},{"item_ref":"item:r_cheese","qty":3,"unit_price":2900},{"item_ref":"item:r_ham","qty":1,"unit_price":3900}]}],"payments":[{"method_ref":"pm:card","amount":24400}]},{"time_offset_minutes":100,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_soap","qty":2,"unit_price":6900},{"item_ref":"item:r_tissue","qty":2,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":25600}]},{"time_offset_minutes":120,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_newspaper","qty":1,"unit_price":2500},{"item_ref":"item:r_magazine","qty":2,"unit_price":6900},{"item_ref":"item:r_cola","qty":1,"unit_price":3500}]}],"payments":[{"method_ref":"pm:cash","amount":19800}]},{"time_offset_minutes":150,"guests":1,"user_ref":"usr:operator","customer_ref":"cust:vesely","status":"paid","orders":[{"items":[{"item_ref":"item:r_bread","qty":1,"unit_price":4500},{"item_ref":"item:r_milk","qty":1,"unit_price":2900},{"item_ref":"item:r_juice_orange","qty":1,"unit_price":5900}]}],"payments":[{"method_ref":"pm:card","amount":13300}]},{"time_offset_minutes":180,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_water","qty":4,"unit_price":2500},{"item_ref":"item:r_energy","qty":2,"unit_price":4900}]}],"payments":[{"method_ref":"pm:cash","amount":19800}]},{"time_offset_minutes":210,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_pasta","qty":1,"unit_price":3500},{"item_ref":"item:r_rice","qty":1,"unit_price":4500},{"item_ref":"item:r_cheese","qty":2,"unit_price":2900}]}],"payments":[{"method_ref":"pm:card","amount":13800}]},{"time_offset_minutes":300,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_cola","qty":2,"unit_price":3500},{"item_ref":"item:r_yogurt","qty":2,"unit_price":1900}]}],"payments":[{"method_ref":"pm:cash","amount":10800}]},{"time_offset_minutes":330,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_beer","qty":4,"unit_price":2900},{"item_ref":"item:r_wine","qty":1,"unit_price":14900}]}],"payments":[{"method_ref":"pm:card","amount":26500}]},{"time_offset_minutes":360,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_eggs","qty":1,"unit_price":5900},{"item_ref":"item:r_bread","qty":1,"unit_price":4500},{"item_ref":"item:r_ham","qty":1,"unit_price":3900}]}],"payments":[{"method_ref":"pm:cash","amount":14300}]},{"time_offset_minutes":390,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_tissue","qty":1,"unit_price":5900},{"item_ref":"item:r_sponge","qty":1,"unit_price":2900},{"item_ref":"item:r_bags","qty":1,"unit_price":3900}]}],"payments":[{"method_ref":"pm:card","amount":12700}]},{"time_offset_minutes":420,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_cig","qty":1,"unit_price":15000},{"item_ref":"item:r_beer","qty":2,"unit_price":2900}]}],"payments":[{"method_ref":"pm:cash","amount":20800}]},{"time_offset_minutes":450,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_milk","qty":1,"unit_price":2900},{"item_ref":"item:r_butter","qty":1,"unit_price":5900},{"item_ref":"item:r_water","qty":2,"unit_price":2500}]}],"payments":[{"method_ref":"pm:card","amount":13800}]},{"time_offset_minutes":510,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_cola","qty":2,"unit_price":3500},{"item_ref":"item:r_energy","qty":1,"unit_price":4900},{"item_ref":"item:r_magazine","qty":1,"unit_price":6900}]}],"payments":[{"method_ref":"pm:cash","amount":18800}]},{"time_offset_minutes":570,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_bread","qty":1,"unit_price":4500},{"item_ref":"item:r_cheese","qty":1,"unit_price":2900},{"item_ref":"item:r_yogurt","qty":1,"unit_price":1900}]}],"payments":[{"method_ref":"pm:card","amount":9300}]},{"time_offset_minutes":630,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_vodka","qty":1,"unit_price":29900},{"item_ref":"item:r_cig","qty":1,"unit_price":15000}]}],"payments":[{"method_ref":"pm:cash","amount":44900}]},{"time_offset_minutes":690,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_soap","qty":1,"unit_price":6900},{"item_ref":"item:r_detergent","qty":1,"unit_price":14900}]}],"payments":[{"method_ref":"pm:card","amount":21800}]}],"stock_documents":[{"type":"receipt","supplier_ref":"sup:wholesale","time_offset_minutes":40,"note_cs":"Urgentní doplnění nápojů","note_en":"Urgent beverage restock","items":[{"item_ref":"item:r_cola","qty":48,"unit_price":1800},{"item_ref":"item:r_water","qty":24,"unit_price":1000},{"item_ref":"item:r_beer","qty":24,"unit_price":1500}]},{"type":"waste","time_offset_minutes":600,"note_cs":"Prošlá trvanlivost","note_en":"Past expiration date","items":[{"item_ref":"item:r_milk","qty":2,"unit_price":1800}]}],"reservations":[],"customer_transactions":[]}');

-- day:r_feat_discounts — 8 bills, single (manager), item %/abs + bill %/abs
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:r_feat_discounts','{"shift_pattern":"single_user","morning_user_ref":"usr:manager","session_open_minutes":360,"session_close_minutes":1320,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:manager"}],"bills":[{"time_offset_minutes":60,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_cola","qty":4,"unit_price":3500,"discount_percent":1000}]}],"payments":[{"method_ref":"pm:cash","amount":12600}]},{"time_offset_minutes":120,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_beer","qty":4,"unit_price":2900,"discount_amount":500},{"item_ref":"item:r_cola","qty":1,"unit_price":3500}]}],"payments":[{"method_ref":"pm:card","amount":13100}]},{"time_offset_minutes":180,"guests":1,"user_ref":"usr:manager","status":"paid","bill_discount_percent":1000,"orders":[{"items":[{"item_ref":"item:r_eggs","qty":1,"unit_price":5900},{"item_ref":"item:r_butter","qty":1,"unit_price":5900},{"item_ref":"item:r_milk","qty":1,"unit_price":2900}]}],"payments":[{"method_ref":"pm:cash","amount":13230}]},{"time_offset_minutes":240,"guests":1,"user_ref":"usr:manager","status":"paid","bill_discount_amount":5000,"orders":[{"items":[{"item_ref":"item:r_wine","qty":1,"unit_price":14900},{"item_ref":"item:r_vodka","qty":1,"unit_price":29900}]}],"payments":[{"method_ref":"pm:card","amount":39800}]},{"time_offset_minutes":300,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_energy","qty":2,"unit_price":4900,"discount_percent":500},{"item_ref":"item:r_water","qty":2,"unit_price":2500}]}],"payments":[{"method_ref":"pm:cash","amount":14310}]},{"time_offset_minutes":360,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_soap","qty":1,"unit_price":6900,"discount_amount":1000},{"item_ref":"item:r_tissue","qty":1,"unit_price":5900}]}],"payments":[{"method_ref":"pm:card","amount":11800}]},{"time_offset_minutes":420,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_newspaper","qty":1,"unit_price":2500},{"item_ref":"item:r_magazine","qty":1,"unit_price":6900}]}],"payments":[{"method_ref":"pm:cash","amount":9400}]},{"time_offset_minutes":480,"guests":1,"user_ref":"usr:manager","status":"paid","bill_discount_percent":500,"orders":[{"items":[{"item_ref":"item:r_eggs","qty":2,"unit_price":5900},{"item_ref":"item:r_butter","qty":2,"unit_price":5900}]}],"payments":[{"method_ref":"pm:card","amount":22420}]}],"stock_documents":[],"reservations":[],"customer_transactions":[]}');

-- day:r_feat_storno — 8 bills, two users, voided/cancelled/refunded
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:r_feat_storno','{"shift_pattern":"two_users","morning_user_ref":"usr:operator","evening_user_ref":"usr:manager","session_open_minutes":360,"session_close_minutes":1320,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":60,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_cola","qty":2,"unit_price":3500},{"item_ref":"item:r_bread","qty":1,"unit_price":4500},{"item_ref":"item:r_butter","qty":1,"unit_price":5900,"status":"voided"}]}],"payments":[{"method_ref":"pm:cash","amount":11500}]},{"time_offset_minutes":120,"guests":1,"user_ref":"usr:operator","status":"cancelled","orders":[{"items":[{"item_ref":"item:r_beer","qty":4,"unit_price":2900},{"item_ref":"item:r_chips","qty":1,"unit_price":3900}]}],"payments":[]},{"time_offset_minutes":180,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_cheese","qty":2,"unit_price":2900},{"item_ref":"item:r_ham","qty":1,"unit_price":3900}]}],"payments":[{"method_ref":"pm:voucher","amount":9700}]},{"time_offset_minutes":240,"guests":1,"user_ref":"usr:manager","status":"refunded","orders":[{"items":[{"item_ref":"item:r_wine","qty":1,"unit_price":14900}]}],"payments":[{"method_ref":"pm:card","amount":14900}]},{"time_offset_minutes":300,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_soap","qty":1,"unit_price":6900},{"item_ref":"item:r_tissue","qty":1,"unit_price":5900,"status":"voided"},{"item_ref":"item:r_sponge","qty":1,"unit_price":2900}]}],"payments":[{"method_ref":"pm:cash","amount":9800}]},{"time_offset_minutes":360,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_eggs","qty":1,"unit_price":5900},{"item_ref":"item:r_milk","qty":1,"unit_price":2900},{"item_ref":"item:r_bread","qty":1,"unit_price":4500}]}],"payments":[{"method_ref":"pm:card","amount":13300}]},{"time_offset_minutes":420,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_newspaper","qty":1,"unit_price":2500},{"item_ref":"item:r_cola","qty":1,"unit_price":3500}]}],"payments":[{"method_ref":"pm:cash","amount":6000}]},{"time_offset_minutes":480,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_energy","qty":2,"unit_price":4900},{"item_ref":"item:r_water","qty":1,"unit_price":2500}]}],"payments":[{"method_ref":"pm:cash","amount":12300}]}],"stock_documents":[],"reservations":[],"customer_transactions":[{"customer_ref":"cust:vesely","type":"credit_topup","credit":60000,"time_offset_minutes":185}]}');

-- day:r_feat_vouchers — 8 bills, single (manager), voucher discount+payment (no vch:disc_cat)
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:r_feat_vouchers','{"shift_pattern":"single_user","morning_user_ref":"usr:manager","session_open_minutes":360,"session_close_minutes":1320,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:manager"}],"bills":[{"time_offset_minutes":60,"guests":1,"user_ref":"usr:manager","status":"paid","voucher_ref":"vch:disc_bill_pct","voucher_discount_amount":1400,"orders":[{"items":[{"item_ref":"item:r_cola","qty":4,"unit_price":3500}]}],"payments":[{"method_ref":"pm:cash","amount":12600}]},{"time_offset_minutes":120,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_beer","qty":4,"unit_price":2900},{"item_ref":"item:r_chips","qty":1,"unit_price":3900}]}],"payments":[{"method_ref":"pm:voucher","amount":15500}]},{"time_offset_minutes":180,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_wine","qty":1,"unit_price":14900}]}],"payments":[{"method_ref":"pm:cash","amount":14900}]},{"time_offset_minutes":240,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_bread","qty":1,"unit_price":4500},{"item_ref":"item:r_cheese","qty":1,"unit_price":2900},{"item_ref":"item:r_ham","qty":1,"unit_price":3900}]}],"payments":[{"method_ref":"pm:card","amount":11300}]},{"time_offset_minutes":300,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_soap","qty":1,"unit_price":6900},{"item_ref":"item:r_tissue","qty":1,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":12800}]},{"time_offset_minutes":360,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_eggs","qty":1,"unit_price":5900},{"item_ref":"item:r_milk","qty":1,"unit_price":2900},{"item_ref":"item:r_butter","qty":1,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":14700}]},{"time_offset_minutes":420,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_newspaper","qty":1,"unit_price":2500},{"item_ref":"item:r_magazine","qty":1,"unit_price":6900}]}],"payments":[{"method_ref":"pm:cash","amount":9400}]},{"time_offset_minutes":480,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_energy","qty":2,"unit_price":4900},{"item_ref":"item:r_water","qty":2,"unit_price":2500},{"item_ref":"item:r_cola","qty":1,"unit_price":3500}]}],"payments":[{"method_ref":"pm:card","amount":18300}]}],"stock_documents":[],"reservations":[],"customer_transactions":[{"customer_ref":"cust:novakova","type":"credit_topup","credit":55000,"time_offset_minutes":125}]}');

-- day:r_feat_loyalty — 8 bills, single (operator), points earn/redeem, credit
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:r_feat_loyalty','{"shift_pattern":"single_user","morning_user_ref":"usr:operator","session_open_minutes":360,"session_close_minutes":1320,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":60,"guests":1,"user_ref":"usr:operator","customer_ref":"cust:svoboda","status":"paid","orders":[{"items":[{"item_ref":"item:r_bread","qty":1,"unit_price":4500},{"item_ref":"item:r_butter","qty":1,"unit_price":5900},{"item_ref":"item:r_milk","qty":1,"unit_price":2900}]}],"payments":[{"method_ref":"pm:cash","amount":13300}]},{"time_offset_minutes":120,"guests":1,"user_ref":"usr:operator","customer_ref":"cust:cerna","status":"paid","orders":[{"items":[{"item_ref":"item:r_cola","qty":2,"unit_price":3500},{"item_ref":"item:r_energy","qty":1,"unit_price":4900}]}],"payments":[{"method_ref":"pm:card","amount":11900}]},{"time_offset_minutes":180,"guests":1,"user_ref":"usr:operator","customer_ref":"cust:vesely","status":"paid","orders":[{"items":[{"item_ref":"item:r_beer","qty":4,"unit_price":2900},{"item_ref":"item:r_chips","qty":1,"unit_price":3900}]}],"payments":[{"method_ref":"pm:cash","amount":15500}]},{"time_offset_minutes":240,"guests":1,"user_ref":"usr:operator","customer_ref":"cust:novakova","status":"paid","orders":[{"items":[{"item_ref":"item:r_soap","qty":1,"unit_price":6900},{"item_ref":"item:r_detergent","qty":1,"unit_price":14900}]}],"payments":[{"method_ref":"pm:card","amount":21800}]},{"time_offset_minutes":300,"guests":1,"user_ref":"usr:operator","customer_ref":"cust:svoboda","status":"paid","loyalty_points_used":50,"orders":[{"items":[{"item_ref":"item:r_eggs","qty":1,"unit_price":5900},{"item_ref":"item:r_cheese","qty":2,"unit_price":2900}]}],"payments":[{"method_ref":"pm:cash","amount":6700}]},{"time_offset_minutes":360,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_water","qty":3,"unit_price":2500},{"item_ref":"item:r_yogurt","qty":1,"unit_price":1900}]}],"payments":[{"method_ref":"pm:cash","amount":9400}]},{"time_offset_minutes":420,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_newspaper","qty":1,"unit_price":2500},{"item_ref":"item:r_magazine","qty":1,"unit_price":6900}]}],"payments":[{"method_ref":"pm:cash","amount":9400}]},{"time_offset_minutes":480,"guests":1,"user_ref":"usr:operator","customer_ref":"cust:firma","status":"paid","orders":[{"items":[{"item_ref":"item:r_wine","qty":1,"unit_price":14900},{"item_ref":"item:r_beer","qty":2,"unit_price":2900}]}],"payments":[{"method_ref":"pm:card","amount":20700}]}],"stock_documents":[],"reservations":[],"customer_transactions":[{"customer_ref":"cust:svoboda","type":"points_earn","points":13,"time_offset_minutes":65},{"customer_ref":"cust:cerna","type":"points_earn","points":11,"time_offset_minutes":125},{"customer_ref":"cust:vesely","type":"points_earn","points":15,"time_offset_minutes":185},{"customer_ref":"cust:novakova","type":"points_earn","points":21,"time_offset_minutes":245},{"customer_ref":"cust:svoboda","type":"points_redeem","points":-50,"time_offset_minutes":305},{"customer_ref":"cust:cerna","type":"credit_topup","credit":50000,"time_offset_minutes":130},{"customer_ref":"cust:firma","type":"points_earn","points":20,"time_offset_minutes":485},{"customer_ref":"cust:firma","type":"credit_topup","credit":100000,"time_offset_minutes":250}]}');

-- day:r_feat_split_tips — 8 bills, two users, split cash+card, tips
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:r_feat_split_tips','{"shift_pattern":"two_users","morning_user_ref":"usr:operator","evening_user_ref":"usr:helper","session_open_minutes":360,"session_close_minutes":1380,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":60,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_cola","qty":2,"unit_price":3500},{"item_ref":"item:r_bread","qty":1,"unit_price":4500},{"item_ref":"item:r_butter","qty":1,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":9000,"tip":800},{"method_ref":"pm:card","amount":8400,"tip":800}]},{"time_offset_minutes":120,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_beer","qty":4,"unit_price":2900},{"item_ref":"item:r_wine","qty":1,"unit_price":14900},{"item_ref":"item:r_chips","qty":1,"unit_price":3900}]}],"payments":[{"method_ref":"pm:card","amount":30400,"tip":3000}]},{"time_offset_minutes":180,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_energy","qty":2,"unit_price":4900},{"item_ref":"item:r_water","qty":2,"unit_price":2500},{"item_ref":"item:r_cola","qty":1,"unit_price":3500}]}],"payments":[{"method_ref":"pm:cash","amount":9000},{"method_ref":"pm:card","amount":9300,"tip":1000}]},{"time_offset_minutes":240,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_cheese","qty":3,"unit_price":2900},{"item_ref":"item:r_ham","qty":2,"unit_price":3900}]}],"payments":[{"method_ref":"pm:cash","amount":16500,"tip":1500}]},{"time_offset_minutes":300,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_soap","qty":1,"unit_price":6900},{"item_ref":"item:r_tissue","qty":1,"unit_price":5900},{"item_ref":"item:r_detergent","qty":1,"unit_price":14900}]}],"payments":[{"method_ref":"pm:card","amount":27700,"tip":2000}]},{"time_offset_minutes":360,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_eggs","qty":1,"unit_price":5900},{"item_ref":"item:r_milk","qty":1,"unit_price":2900},{"item_ref":"item:r_bread","qty":1,"unit_price":4500},{"item_ref":"item:r_yogurt","qty":1,"unit_price":1900}]}],"payments":[{"method_ref":"pm:cash","amount":7600,"tip":500},{"method_ref":"pm:card","amount":7600,"tip":500}]},{"time_offset_minutes":420,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_newspaper","qty":1,"unit_price":2500},{"item_ref":"item:r_magazine","qty":1,"unit_price":6900},{"item_ref":"item:r_cola","qty":1,"unit_price":3500}]}],"payments":[{"method_ref":"pm:card","amount":12900,"tip":1000}]},{"time_offset_minutes":480,"guests":1,"user_ref":"usr:helper","status":"paid","orders":[{"items":[{"item_ref":"item:r_vodka","qty":1,"unit_price":29900},{"item_ref":"item:r_beer","qty":2,"unit_price":2900}]}],"payments":[{"method_ref":"pm:cash","amount":18000},{"method_ref":"pm:card","amount":17700,"tip":2000}]}],"stock_documents":[],"reservations":[],"customer_transactions":[]}');

-- day:r_feat_stock — 8 bills, single (manager), receipt/waste/inventory/correction
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:r_feat_stock','{"shift_pattern":"single_user","morning_user_ref":"usr:manager","session_open_minutes":360,"session_close_minutes":1320,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:manager"}],"bills":[{"time_offset_minutes":90,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_cola","qty":2,"unit_price":3500},{"item_ref":"item:r_bread","qty":1,"unit_price":4500}]}],"payments":[{"method_ref":"pm:cash","amount":11500}]},{"time_offset_minutes":150,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_beer","qty":4,"unit_price":2900},{"item_ref":"item:r_chips","qty":1,"unit_price":3900}]}],"payments":[{"method_ref":"pm:card","amount":15500}]},{"time_offset_minutes":210,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_water","qty":2,"unit_price":2500},{"item_ref":"item:r_energy","qty":1,"unit_price":4900},{"item_ref":"item:r_eggs","qty":1,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":15800}]},{"time_offset_minutes":300,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_wine","qty":1,"unit_price":14900},{"item_ref":"item:r_cheese","qty":1,"unit_price":2900}]}],"payments":[{"method_ref":"pm:voucher","amount":17800}]},{"time_offset_minutes":360,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_soap","qty":1,"unit_price":6900},{"item_ref":"item:r_tissue","qty":1,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":12800}]},{"time_offset_minutes":420,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_newspaper","qty":1,"unit_price":2500},{"item_ref":"item:r_magazine","qty":1,"unit_price":6900}]}],"payments":[{"method_ref":"pm:cash","amount":9400}]},{"time_offset_minutes":480,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_milk","qty":1,"unit_price":2900},{"item_ref":"item:r_butter","qty":1,"unit_price":5900},{"item_ref":"item:r_ham","qty":1,"unit_price":3900}]}],"payments":[{"method_ref":"pm:card","amount":12700}]},{"time_offset_minutes":540,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_cola","qty":2,"unit_price":3500},{"item_ref":"item:r_energy","qty":1,"unit_price":4900},{"item_ref":"item:r_water","qty":1,"unit_price":2500}]}],"payments":[{"method_ref":"pm:card","amount":14400}]}],"stock_documents":[{"type":"receipt","supplier_ref":"sup:wholesale","time_offset_minutes":30,"note_cs":"Týdenní zásobování","note_en":"Weekly supply","items":[{"item_ref":"item:r_cola","qty":48,"unit_price":1800},{"item_ref":"item:r_water","qty":24,"unit_price":1000},{"item_ref":"item:r_bread","qty":20,"unit_price":2500},{"item_ref":"item:r_beer","qty":24,"unit_price":1500}]},{"type":"waste","time_offset_minutes":35,"note_cs":"Zkažené mléko","note_en":"Spoiled milk","items":[{"item_ref":"item:r_milk","qty":3,"unit_price":1800}]},{"type":"inventory","time_offset_minutes":600,"note_cs":"Inventura prodejny","note_en":"Store inventory check","items":[{"item_ref":"item:r_cola","qty":40,"unit_price":1800},{"item_ref":"item:r_bread","qty":18,"unit_price":2500}]},{"type":"correction","time_offset_minutes":610,"note_cs":"Korekce po inventuře — chybějící sýr","note_en":"Post-inventory correction — missing cheese","items":[{"item_ref":"item:r_cheese","qty":5,"unit_price":1500}]}],"reservations":[],"customer_transactions":[]}');

-- day:r_feat_multicurrency — 8 bills, single (operator), EUR cash payments
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:r_feat_multicurrency','{"shift_pattern":"single_user","morning_user_ref":"usr:operator","session_open_minutes":360,"session_close_minutes":1320,"opening_cash":500000,"has_foreign_currency":true,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":60,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_bread","qty":1,"unit_price":4500},{"item_ref":"item:r_butter","qty":1,"unit_price":5900},{"item_ref":"item:r_milk","qty":1,"unit_price":2900}]}],"payments":[{"method_ref":"pm:cash","amount":13300,"foreign_currency":"EUR","foreign_amount":500,"exchange_rate":25.50}]},{"time_offset_minutes":120,"guests":1,"user_ref":"usr:operator","customer_ref":"cust:novakova","status":"paid","orders":[{"items":[{"item_ref":"item:r_beer","qty":4,"unit_price":2900}]}],"payments":[{"method_ref":"pm:credit","amount":11600}]},{"time_offset_minutes":180,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_cola","qty":2,"unit_price":3500},{"item_ref":"item:r_energy","qty":1,"unit_price":4900}]}],"payments":[{"method_ref":"pm:cash","amount":11900,"foreign_currency":"EUR","foreign_amount":500,"exchange_rate":25.50}]},{"time_offset_minutes":240,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_cheese","qty":1,"unit_price":2900},{"item_ref":"item:r_ham","qty":1,"unit_price":3900},{"item_ref":"item:r_eggs","qty":1,"unit_price":5900}]}],"payments":[{"method_ref":"pm:cash","amount":12700}]},{"time_offset_minutes":300,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_soap","qty":1,"unit_price":6900},{"item_ref":"item:r_tissue","qty":1,"unit_price":5900}]}],"payments":[{"method_ref":"pm:bank","amount":12800}]},{"time_offset_minutes":360,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_water","qty":2,"unit_price":2500},{"item_ref":"item:r_yogurt","qty":1,"unit_price":1900}]}],"payments":[{"method_ref":"pm:cash","amount":6900}]},{"time_offset_minutes":420,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_newspaper","qty":1,"unit_price":2500},{"item_ref":"item:r_cola","qty":1,"unit_price":3500}]}],"payments":[{"method_ref":"pm:cash","amount":6000,"foreign_currency":"EUR","foreign_amount":250,"exchange_rate":25.50}]},{"time_offset_minutes":480,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_wine","qty":1,"unit_price":14900},{"item_ref":"item:r_vodka","qty":1,"unit_price":29900}]}],"payments":[{"method_ref":"pm:card","amount":44800}]}],"stock_documents":[],"reservations":[],"customer_transactions":[{"customer_ref":"cust:novakova","type":"credit_spend","credit":-11600,"time_offset_minutes":125}]}');

-- day:r_feat_cash_ops — 8 bills, two users (manager+operator), 6 cash movements
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:r_feat_cash_ops','{"shift_pattern":"two_users","morning_user_ref":"usr:manager","evening_user_ref":"usr:operator","session_open_minutes":360,"session_close_minutes":1380,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":300000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:manager"},{"type":"withdrawal","amount":100000,"reason_cs":"Výplata brigádník","reason_en":"Employee payroll","time_offset_minutes":120,"user_ref":"usr:manager"},{"type":"expense","amount":15000,"reason_cs":"Nákup čistících prostředků","reason_en":"Cleaning supplies purchase","time_offset_minutes":180,"user_ref":"usr:manager"},{"type":"withdrawal","amount":200000,"reason_cs":"Odvod do trezoru","reason_en":"Safe transfer","time_offset_minutes":400,"user_ref":"usr:manager"},{"type":"deposit","amount":50000,"reason_cs":"Drobné pro večerní směnu","reason_en":"Evening shift change","time_offset_minutes":480,"user_ref":"usr:operator"},{"type":"expense","amount":8500,"reason_cs":"Poštovné","reason_en":"Postage","time_offset_minutes":600,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":60,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_bread","qty":1,"unit_price":4500},{"item_ref":"item:r_butter","qty":1,"unit_price":5900},{"item_ref":"item:r_cola","qty":1,"unit_price":3500}]}],"payments":[{"method_ref":"pm:cash","amount":13900}]},{"time_offset_minutes":150,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_beer","qty":4,"unit_price":2900},{"item_ref":"item:r_chips","qty":1,"unit_price":3900}]}],"payments":[{"method_ref":"pm:cash","amount":15500}]},{"time_offset_minutes":240,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_wine","qty":1,"unit_price":14900},{"item_ref":"item:r_cheese","qty":1,"unit_price":2900}]}],"payments":[{"method_ref":"pm:card","amount":17800}]},{"time_offset_minutes":330,"guests":1,"user_ref":"usr:manager","status":"paid","orders":[{"items":[{"item_ref":"item:r_eggs","qty":1,"unit_price":5900},{"item_ref":"item:r_milk","qty":1,"unit_price":2900},{"item_ref":"item:r_ham","qty":1,"unit_price":3900},{"item_ref":"item:r_yogurt","qty":1,"unit_price":1900}]}],"payments":[{"method_ref":"pm:cash","amount":14600}]},{"time_offset_minutes":420,"guests":1,"user_ref":"usr:manager","customer_ref":"cust:cerna","status":"paid","orders":[{"items":[{"item_ref":"item:r_soap","qty":1,"unit_price":6900},{"item_ref":"item:r_tissue","qty":1,"unit_price":5900}]}],"payments":[{"method_ref":"pm:credit","amount":12800}]},{"time_offset_minutes":510,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_newspaper","qty":1,"unit_price":2500},{"item_ref":"item:r_magazine","qty":1,"unit_price":6900}]}],"payments":[{"method_ref":"pm:cash","amount":9400}]},{"time_offset_minutes":570,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_cola","qty":2,"unit_price":3500},{"item_ref":"item:r_energy","qty":1,"unit_price":4900}]}],"payments":[{"method_ref":"pm:cash","amount":11900}]},{"time_offset_minutes":630,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_water","qty":3,"unit_price":2500},{"item_ref":"item:r_bread","qty":1,"unit_price":4500}]}],"payments":[{"method_ref":"pm:card","amount":12000}]}],"stock_documents":[],"reservations":[],"customer_transactions":[{"customer_ref":"cust:cerna","type":"credit_spend","credit":-12800,"time_offset_minutes":425}]}');

-- day:r_today_open — 5 bills (2 paid + 3 open), single (operator), no session close
INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_day_template','day:r_today_open','{"shift_pattern":"single_user","morning_user_ref":"usr:operator","session_open_minutes":360,"session_close_minutes":null,"opening_cash":500000,"cash_movements":[{"type":"deposit","amount":200000,"reason_cs":"Ranní vklad","reason_en":"Morning deposit","time_offset_minutes":5,"user_ref":"usr:operator"},{"type":"withdrawal","amount":150000,"reason_cs":"Odvod do trezoru","reason_en":"Safe transfer","time_offset_minutes":180,"user_ref":"usr:operator"}],"bills":[{"time_offset_minutes":30,"guests":1,"user_ref":"usr:operator","customer_ref":"cust:svoboda","status":"paid","orders":[{"items":[{"item_ref":"item:r_bread","qty":1,"unit_price":4500},{"item_ref":"item:r_butter","qty":1,"unit_price":5900},{"item_ref":"item:r_milk","qty":1,"unit_price":2900}]}],"payments":[{"method_ref":"pm:cash","amount":13300}]},{"time_offset_minutes":60,"guests":1,"user_ref":"usr:operator","status":"paid","orders":[{"items":[{"item_ref":"item:r_cola","qty":2,"unit_price":3500},{"item_ref":"item:r_chips","qty":1,"unit_price":3900}]}],"payments":[{"method_ref":"pm:card","amount":10900}]},{"time_offset_minutes":120,"guests":1,"user_ref":"usr:operator","status":"opened","orders":[{"items":[{"item_ref":"item:r_beer","qty":2,"unit_price":2900},{"item_ref":"item:r_wine","qty":1,"unit_price":14900}],"prep_status":"delivered"}],"payments":[]},{"time_offset_minutes":150,"guests":1,"user_ref":"usr:operator","status":"opened","orders":[{"items":[{"item_ref":"item:r_eggs","qty":1,"unit_price":5900},{"item_ref":"item:r_cheese","qty":1,"unit_price":2900}],"prep_status":"ready"}],"payments":[]},{"time_offset_minutes":180,"guests":1,"user_ref":"usr:operator","status":"opened","orders":[{"items":[{"item_ref":"item:r_soap","qty":1,"unit_price":6900},{"item_ref":"item:r_water","qty":1,"unit_price":2500}],"prep_status":"created"}],"payments":[]}],"stock_documents":[],"reservations":[],"customer_transactions":[]}');

-- ============================================================================
-- Retail schedule (locale=NULL, mode='_all')
-- ============================================================================

INSERT INTO seed_demo_data (locale, mode, entity_type, ref, data) VALUES
(NULL,'_all','_schedule','schedule:retail','{"days_back":90,"work_days":["mon","tue","wed","thu","fri","sat"],"week_pattern":["day:r_regular","day:r_regular","day:r_regular","day:r_regular","day:r_busy","day:r_busy"],"overrides":{"85":"day:r_feat_stock","78":"day:r_feat_discounts","71":"day:r_feat_storno","64":"day:r_feat_vouchers","57":"day:r_feat_loyalty","50":"day:r_feat_split_tips","43":"day:r_feat_multicurrency","36":"day:r_feat_cash_ops","29":"day:r_feat_stock","22":"day:r_feat_discounts","15":"day:r_feat_stock","8":"day:r_light","1":"day:r_light","0":"day:r_today_open"}}');

-- ============================================================================
-- PART B: Re-create function with NULL safety + mode-aware schedule
-- ============================================================================

CREATE OR REPLACE FUNCTION create_demo_company(
  p_auth_user_id uuid,
  p_locale text,         -- 'cs' | 'en'
  p_mode text,           -- 'gastro' | 'retail'
  p_currency_code text,  -- 'CZK' | 'EUR' etc
  p_company_name text
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
SET statement_timeout = '300s'
AS $$
DECLARE
  -- IDs
  v_company_id   text := gen_random_uuid()::text;
  v_settings_id  text := gen_random_uuid()::text;
  v_register_id  text := gen_random_uuid()::text;
  v_warehouse_id text;
  v_currency_id  text;
  v_now          timestamptz := now();

  -- Role IDs (looked up from roles table)
  v_role_admin    text;
  v_role_manager  text;
  v_role_operator text;
  v_role_helper   text;

  -- Counters
  v_bill_counter      int := 0;
  v_order_counter     int := 0;
  v_stock_doc_counter int := 0;

  -- Day loop
  v_schedule       jsonb;
  v_days_back      int;
  v_work_days      jsonb;
  v_week_pattern   jsonb;
  v_overrides      jsonb;
  v_day_templates  jsonb := '{}'::jsonb;
  v_day_idx        int;
  v_day_date       date;
  v_day_dow        text;
  v_day_ref        text;
  v_day_tpl        jsonb;
  v_is_today       boolean;

  -- Session
  v_session_id     text;
  v_session_open   timestamptz;
  v_session_close  timestamptz;
  v_opening_cash   int;

  -- Shift tracking
  v_shift_pattern  text;
  v_morning_user   text;
  v_evening_user   text;
  v_morning_shift_id text;
  v_evening_shift_id text;

  -- Bill processing
  v_bills          jsonb;
  v_bill           jsonb;
  v_bill_id        text;
  v_bill_status    text;
  v_bill_user_ref  text;
  v_bill_time      timestamptz;
  v_table_ref      text;
  v_table_id       text;
  v_section_id     text;
  v_customer_ref   text;
  v_customer_id    text;
  v_is_takeaway    boolean;
  v_guests         int;
  v_bill_discount_pct   int;
  v_bill_discount_amt   int;
  v_loyalty_discount_amount int;
  v_voucher_discount_amount int;
  v_loyalty_points_earned   int;

  -- Order processing
  v_orders         jsonb;
  v_order          jsonb;
  v_order_id       text;
  v_order_number   text;
  v_order_user     text;
  v_items          jsonb;
  v_item           jsonb;
  v_oi_id          text;
  v_item_ref       text;
  v_item_id        text;
  v_item_name      text;
  v_item_unit      text;
  v_qty            int;
  v_unit_price     int;
  v_item_disc_pct  int;
  v_item_disc_amt  int;
  v_tax_rate       int;
  v_tax_rate_id    text;
  v_item_gross     bigint;
  v_item_discount  bigint;
  v_item_after     bigint;
  v_item_tax       bigint;
  v_item_net       bigint;
  v_order_gross    bigint;
  v_order_net      bigint;
  v_order_tax      bigint;
  v_order_count    int;
  v_prep_status    text;

  -- Bill totals
  v_subtotal_gross bigint;
  v_subtotal_net   bigint;
  v_tax_total      bigint;
  v_total_gross    bigint;
  v_discount_total bigint;
  v_paid_amount    bigint;
  v_tip_total      bigint;

  -- Payments
  v_payments       jsonb;
  v_payment        jsonb;
  v_pay_id         text;
  v_pay_method_ref text;
  v_pay_method_id  text;
  v_pay_amount     int;
  v_pay_tip        int;

  -- Modifiers
  v_modifiers      jsonb;
  v_modifier       jsonb;
  v_mod_id         text;
  v_mod_ref        text;
  v_mod_item_id    text;
  v_mod_item_name  text;
  v_mod_qty        int;
  v_mod_unit_price int;
  v_mod_tax_rate   int;
  v_mod_tax_rate_id text;
  v_mod_gross      bigint;
  v_mod_tax        bigint;

  -- Cash tracking
  v_session_cash   bigint;  -- running cash in session
  v_expected_cash  bigint;
  v_cm             jsonb;
  v_cm_type        text;
  v_cm_amount      int;

  -- Stock documents
  v_stock_docs     jsonb;
  v_sdoc           jsonb;
  v_sdoc_id        text;
  v_sdoc_type      text;
  v_sdoc_items     jsonb;
  v_sitem          jsonb;
  v_sm_id          text;
  v_sm_direction   text;

  -- Reservations
  v_reservations   jsonb;
  v_resv           jsonb;
  v_resv_id        text;

  -- Customer transactions
  v_ctxns          jsonb;
  v_ctx            jsonb;
  v_ctx_id         text;

  -- Voucher processing
  v_voucher_ref    text;
  v_voucher_id     text;

  -- Foreign currency
  v_has_foreign    boolean;
  v_foreign_cur_id text;
  v_scc_id         text;
  v_foreign_cash   bigint;

  -- Layout
  v_grid_rows      int := 7;
  v_grid_cols      int := 8;

  -- Temp
  v_rec            record;
  v_row            record;
  v_salt           text;
  v_pin_hash       text;
  v_user_id        text;
  v_role_id        text;
  v_role_ref       text;
  v_idx            int;
  v_idx2           int;
  v_admin_user_id  text;
  v_display_id     text;
BEGIN
  -- Look up role IDs dynamically instead of hardcoding UUIDs
  SELECT id::text INTO STRICT v_role_admin    FROM roles WHERE name = 'admin';
  SELECT id::text INTO STRICT v_role_manager  FROM roles WHERE name = 'manager';
  SELECT id::text INTO STRICT v_role_operator FROM roles WHERE name = 'operator';
  SELECT id::text INTO STRICT v_role_helper   FROM roles WHERE name = 'helper';

  -- ========================================================================
  -- STEP 1: Setup — ref_map temp table, resolve currency
  -- ========================================================================
  CREATE TEMP TABLE _ref_map (ref text PRIMARY KEY, id text NOT NULL) ON COMMIT DROP;

  -- Look up default currency
  SELECT id INTO STRICT v_currency_id
  FROM currencies WHERE code = p_currency_code;

  -- ========================================================================
  -- STEP 2: Load templates and generate UUIDs
  -- ========================================================================
  FOR v_rec IN
    SELECT ref, entity_type, data, sort_order
    FROM seed_demo_data
    WHERE (locale = p_locale OR locale IS NULL)
      AND (mode = p_mode OR mode = '_all')
    ORDER BY sort_order
  LOOP
    -- Generate UUID for each ref (skip schedule/day templates)
    IF v_rec.entity_type NOT IN ('_schedule', '_day_template') THEN
      INSERT INTO _ref_map (ref, id)
      VALUES (v_rec.ref, gen_random_uuid()::text)
      ON CONFLICT (ref) DO NOTHING;
    END IF;
  END LOOP;

  -- Fixed refs
  INSERT INTO _ref_map (ref, id) VALUES
    ('company', v_company_id),
    ('register', v_register_id);

  -- ========================================================================
  -- STEP 3: Create company + settings
  -- ========================================================================
  INSERT INTO companies (
    id, name, status, default_currency_id, auth_user_id,
    business_id, vat_number, email, phone, address, city, postal_code, country,
    timezone, business_type,
    is_demo, demo_expires_at,
    client_created_at, client_updated_at
  )
  VALUES (
    v_company_id, p_company_name, 'trial', v_currency_id, p_auth_user_id,
    CASE p_locale
      WHEN 'cs' THEN '12345678'
      ELSE '12345678'
    END,
    CASE p_locale
      WHEN 'cs' THEN 'CZ12345678'
      ELSE 'EU12345678'
    END,
    CASE p_locale
      WHEN 'cs' THEN
        CASE p_mode WHEN 'gastro' THEN 'info@demobistro.cz' ELSE 'info@demomarket.cz' END
      ELSE
        CASE p_mode WHEN 'gastro' THEN 'info@demobistro.eu' ELSE 'info@demomarket.eu' END
    END,
    CASE p_locale
      WHEN 'cs' THEN '+420 123 456 789'
      ELSE '+43 1 234 5678'
    END,
    CASE p_locale
      WHEN 'cs' THEN
        CASE p_mode WHEN 'gastro' THEN 'Národní 15' ELSE 'Vinohradská 42' END
      ELSE
        CASE p_mode WHEN 'gastro' THEN 'Hauptstraße 15' ELSE 'Marktgasse 42' END
    END,
    CASE p_locale
      WHEN 'cs' THEN 'Praha'
      ELSE 'Wien'
    END,
    CASE p_locale
      WHEN 'cs' THEN '110 00'
      ELSE '1010'
    END,
    CASE p_locale
      WHEN 'cs' THEN 'CZ'
      ELSE 'AT'
    END,
    CASE p_locale WHEN 'cs' THEN 'Europe/Prague' ELSE 'Europe/Vienna' END,
    p_mode,
    true, v_now + interval '6 hours',
    v_now, v_now
  );

  INSERT INTO company_settings (id, company_id, locale, loyalty_earn_rate, loyalty_point_value,
                               auto_lock_timeout_minutes,
                               client_created_at, client_updated_at)
  VALUES (v_settings_id, v_company_id, p_locale, 1000, 100, 5, v_now, v_now);

  -- ========================================================================
  -- STEP 4: Tax rates
  -- ========================================================================
  FOR v_rec IN
    SELECT ref, data
    FROM seed_demo_data
    WHERE entity_type = 'tax_rates'
      AND (locale IS NULL OR locale = p_locale)
      AND (mode = '_all' OR mode = p_mode)
    ORDER BY sort_order
  LOOP
    INSERT INTO tax_rates (id, company_id, label, type, rate, is_default, client_created_at, client_updated_at)
    VALUES (
      (SELECT id FROM _ref_map WHERE ref = v_rec.ref),
      v_company_id,
      CASE v_rec.ref
        WHEN 'tax:21' THEN CASE p_locale WHEN 'cs' THEN 'Základní 21%' ELSE 'Standard 21%' END
        WHEN 'tax:12' THEN CASE p_locale WHEN 'cs' THEN 'Snížená 12%' ELSE 'Reduced 12%' END
        WHEN 'tax:0'  THEN CASE p_locale WHEN 'cs' THEN 'Nulová 0%' ELSE 'Zero 0%' END
      END,
      (v_rec.data->>'type')::tax_calc_type,
      (v_rec.data->>'rate')::int,
      COALESCE((v_rec.data->>'is_default')::boolean, false),
      v_now, v_now
    );
  END LOOP;

  -- ========================================================================
  -- STEP 5: Payment methods
  -- ========================================================================
  FOR v_rec IN
    SELECT ref, data
    FROM seed_demo_data
    WHERE entity_type = 'payment_methods'
      AND (locale IS NULL OR locale = p_locale)
      AND (mode = '_all' OR mode = p_mode)
    ORDER BY sort_order
  LOOP
    INSERT INTO payment_methods (id, company_id, name, type, is_active, client_created_at, client_updated_at)
    VALUES (
      (SELECT id FROM _ref_map WHERE ref = v_rec.ref),
      v_company_id,
      CASE v_rec.ref
        WHEN 'pm:cash'    THEN CASE p_locale WHEN 'cs' THEN 'Hotovost' ELSE 'Cash' END
        WHEN 'pm:card'    THEN CASE p_locale WHEN 'cs' THEN 'Karta' ELSE 'Card' END
        WHEN 'pm:bank'    THEN CASE p_locale WHEN 'cs' THEN 'Převod' ELSE 'Bank Transfer' END
        WHEN 'pm:credit'  THEN CASE p_locale WHEN 'cs' THEN 'Zákaznický kredit' ELSE 'Customer Credit' END
        WHEN 'pm:voucher' THEN CASE p_locale WHEN 'cs' THEN 'Stravenky' ELSE 'Meal Vouchers' END
      END,
      (v_rec.data->>'type')::payment_type,
      true,
      v_now, v_now
    );
  END LOOP;

  -- ========================================================================
  -- STEP 6: Warehouses
  -- ========================================================================
  FOR v_rec IN
    SELECT ref, data
    FROM seed_demo_data
    WHERE entity_type = 'warehouses'
      AND (locale IS NULL OR locale = p_locale)
      AND (mode = '_all' OR mode = p_mode)
    ORDER BY sort_order
  LOOP
    v_warehouse_id := (SELECT id FROM _ref_map WHERE ref = v_rec.ref);
    INSERT INTO warehouses (id, company_id, name, is_default, is_active, client_created_at, client_updated_at)
    VALUES (
      v_warehouse_id,
      v_company_id,
      CASE p_locale WHEN 'cs' THEN 'Hlavní sklad' ELSE 'Main Warehouse' END,
      COALESCE((v_rec.data->>'is_default')::boolean, false),
      true,
      v_now, v_now
    );
  END LOOP;

  -- ========================================================================
  -- STEP 7: Users (4 demo users, all PIN 1111)
  -- ========================================================================
  FOR v_rec IN
    SELECT ref, data
    FROM seed_demo_data
    WHERE entity_type = 'users'
      AND (locale = p_locale)
      AND (mode = '_all' OR mode = p_mode)
    ORDER BY sort_order
  LOOP
    v_user_id := (SELECT id FROM _ref_map WHERE ref = v_rec.ref);
    v_role_ref := v_rec.data->>'role_ref';
    v_role_id := CASE v_role_ref
      WHEN 'admin'    THEN v_role_admin
      WHEN 'manager'  THEN v_role_manager
      WHEN 'operator' THEN v_role_operator
      WHEN 'helper'   THEN v_role_helper
    END;

    -- Generate PIN hash for 1111
    v_salt := encode(gen_random_bytes(16), 'hex');
    v_pin_hash := v_salt || ':' || encode(digest(v_salt || ':' || '1111', 'sha256'), 'hex');

    INSERT INTO users (id, company_id, auth_user_id, username, full_name, pin_hash, pin_enabled, role_id, is_active, client_created_at, client_updated_at)
    VALUES (
      v_user_id,
      v_company_id,
      CASE WHEN (v_rec.data->>'is_auth_user')::boolean = true THEN p_auth_user_id ELSE NULL END,
      v_rec.data->>'username',
      v_rec.data->>'full_name',
      v_pin_hash,
      true,
      v_role_id,
      true,
      v_now, v_now
    );

    -- Track admin user for permissions granted_by
    IF v_role_ref = 'admin' THEN
      v_admin_user_id := v_user_id;
    END IF;
  END LOOP;

  -- ========================================================================
  -- STEP 8: User permissions
  -- ========================================================================
  FOR v_rec IN
    SELECT u.id AS user_id, u.role_id
    FROM users u
    WHERE u.company_id = v_company_id
  LOOP
    INSERT INTO user_permissions (id, company_id, user_id, permission_id, granted_by, client_created_at, client_updated_at)
    SELECT
      gen_random_uuid()::text,
      v_company_id,
      v_rec.user_id,
      rp.permission_id,
      v_admin_user_id,
      v_now, v_now
    FROM role_permissions rp
    WHERE rp.role_id = v_rec.role_id;
  END LOOP;

  -- ========================================================================
  -- STEP 9: Sections
  -- ========================================================================
  FOR v_rec IN
    SELECT ref, data, sort_order
    FROM seed_demo_data
    WHERE entity_type = 'sections'
      AND (locale = p_locale)
      AND (mode = p_mode)
    ORDER BY sort_order
  LOOP
    INSERT INTO sections (id, company_id, name, color, is_active, is_default, sort_order, client_created_at, client_updated_at)
    VALUES (
      (SELECT id FROM _ref_map WHERE ref = v_rec.ref),
      v_company_id,
      v_rec.data->>'name',
      v_rec.data->>'color',
      true,
      COALESCE((v_rec.data->>'is_default')::boolean, false),
      v_rec.sort_order,
      v_now, v_now
    );
  END LOOP;

  -- ========================================================================
  -- STEP 9b: Tables
  -- ========================================================================
  FOR v_rec IN
    SELECT ref, data
    FROM seed_demo_data
    WHERE entity_type = 'tables'
      AND (locale = p_locale)
      AND (mode = p_mode)
    ORDER BY sort_order
  LOOP
    INSERT INTO tables (id, company_id, table_name, section_id, capacity, is_active,
                        grid_row, grid_col, grid_width, grid_height,
                        color, font_size, fill_style, border_style, shape,
                        client_created_at, client_updated_at)
    VALUES (
      (SELECT id FROM _ref_map WHERE ref = v_rec.ref),
      v_company_id,
      v_rec.data->>'name',
      (SELECT id FROM _ref_map WHERE ref = v_rec.data->>'section_ref'),
      COALESCE((v_rec.data->>'capacity')::int, 0),
      true,
      (v_rec.data->>'grid_row')::int,
      (v_rec.data->>'grid_col')::int,
      COALESCE((v_rec.data->>'grid_width')::int, 1),
      COALESCE((v_rec.data->>'grid_height')::int, 1),
      v_rec.data->>'color',
      (v_rec.data->>'font_size')::int,
      COALESCE((v_rec.data->>'fill_style')::int, 1),
      COALESCE((v_rec.data->>'border_style')::int, 1),
      COALESCE((v_rec.data->>'shape')::table_shape, 'rectangle'::table_shape),
      v_now, v_now
    );
  END LOOP;

  -- ========================================================================
  -- STEP 9c: Map elements
  -- ========================================================================
  FOR v_rec IN
    SELECT ref, data
    FROM seed_demo_data
    WHERE entity_type = 'map_elements'
      AND (locale = p_locale)
      AND (mode = p_mode)
    ORDER BY sort_order
  LOOP
    INSERT INTO map_elements (id, company_id, section_id,
                              grid_row, grid_col, grid_width, grid_height,
                              label, color, font_size, fill_style, border_style, shape,
                              client_created_at, client_updated_at)
    VALUES (
      (SELECT id FROM _ref_map WHERE ref = v_rec.ref),
      v_company_id,
      (SELECT id FROM _ref_map WHERE ref = v_rec.data->>'section_ref'),
      (v_rec.data->>'grid_row')::int,
      (v_rec.data->>'grid_col')::int,
      COALESCE((v_rec.data->>'grid_width')::int, 1),
      COALESCE((v_rec.data->>'grid_height')::int, 1),
      v_rec.data->>'label',
      v_rec.data->>'color',
      (v_rec.data->>'font_size')::int,
      COALESCE((v_rec.data->>'fill_style')::int, 1),
      COALESCE((v_rec.data->>'border_style')::int, 1),
      COALESCE((v_rec.data->>'shape')::table_shape, 'rectangle'::table_shape),
      v_now, v_now
    );
  END LOOP;

  -- ========================================================================
  -- STEP 9d: Categories
  -- ========================================================================
  FOR v_rec IN
    SELECT ref, data
    FROM seed_demo_data
    WHERE entity_type = 'categories'
      AND (locale = p_locale)
      AND (mode = p_mode)
    ORDER BY sort_order
  LOOP
    INSERT INTO categories (id, company_id, name, is_active, parent_id, client_created_at, client_updated_at)
    VALUES (
      (SELECT id FROM _ref_map WHERE ref = v_rec.ref),
      v_company_id,
      v_rec.data->>'name',
      true,
      CASE WHEN v_rec.data->>'parent_ref' IS NOT NULL
        THEN (SELECT id FROM _ref_map WHERE ref = v_rec.data->>'parent_ref')
        ELSE NULL
      END,
      v_now, v_now
    );
  END LOOP;

  -- ========================================================================
  -- STEP 9e: Suppliers
  -- ========================================================================
  FOR v_rec IN
    SELECT ref, data
    FROM seed_demo_data
    WHERE entity_type = 'suppliers'
      AND (locale = p_locale)
      AND (mode = p_mode)
    ORDER BY sort_order
  LOOP
    INSERT INTO suppliers (id, company_id, supplier_name, contact_person, email, phone, client_created_at, client_updated_at)
    VALUES (
      (SELECT id FROM _ref_map WHERE ref = v_rec.ref),
      v_company_id,
      v_rec.data->>'supplier_name',
      v_rec.data->>'contact_person',
      v_rec.data->>'email',
      v_rec.data->>'phone',
      v_now, v_now
    );
  END LOOP;

  -- ========================================================================
  -- STEP 9f: Manufacturers
  -- ========================================================================
  FOR v_rec IN
    SELECT ref, data
    FROM seed_demo_data
    WHERE entity_type = 'manufacturers'
      AND (locale = p_locale)
      AND (mode = p_mode)
    ORDER BY sort_order
  LOOP
    INSERT INTO manufacturers (id, company_id, name, client_created_at, client_updated_at)
    VALUES (
      (SELECT id FROM _ref_map WHERE ref = v_rec.ref),
      v_company_id,
      v_rec.data->>'name',
      v_now, v_now
    );
  END LOOP;

  -- ========================================================================
  -- STEP 10: Items
  -- ========================================================================
  FOR v_rec IN
    SELECT ref, data
    FROM seed_demo_data
    WHERE entity_type = 'items'
      AND (locale = p_locale)
      AND (mode = p_mode)
    ORDER BY sort_order
  LOOP
    INSERT INTO items (id, company_id, category_id, name, description, item_type, sku, unit_price,
                       sale_tax_rate_id, is_sellable, is_active, unit, alt_sku, purchase_price,
                       purchase_tax_rate_id, is_stock_tracked, min_quantity, manufacturer_id, supplier_id, parent_id,
                       client_created_at, client_updated_at)
    VALUES (
      (SELECT id FROM _ref_map WHERE ref = v_rec.ref),
      v_company_id,
      CASE WHEN v_rec.data->>'category_ref' IS NOT NULL
        THEN (SELECT id FROM _ref_map WHERE ref = v_rec.data->>'category_ref')
        ELSE NULL
      END,
      v_rec.data->>'name',
      v_rec.data->>'description',
      (v_rec.data->>'item_type')::item_type,
      v_rec.data->>'sku',
      (v_rec.data->>'unit_price')::int,
      CASE WHEN v_rec.data->>'sale_tax_rate_ref' IS NOT NULL
        THEN (SELECT id FROM _ref_map WHERE ref = v_rec.data->>'sale_tax_rate_ref')
        ELSE NULL
      END,
      COALESCE((v_rec.data->>'is_sellable')::boolean, true),
      true,
      (v_rec.data->>'unit')::unit_type,
      v_rec.data->>'alt_sku',
      (v_rec.data->>'purchase_price')::int,
      CASE WHEN v_rec.data->>'purchase_tax_rate_ref' IS NOT NULL
        THEN (SELECT id FROM _ref_map WHERE ref = v_rec.data->>'purchase_tax_rate_ref')
        ELSE NULL
      END,
      COALESCE((v_rec.data->>'is_stock_tracked')::boolean, false),
      (v_rec.data->>'min_quantity')::double precision,
      CASE WHEN v_rec.data->>'manufacturer_ref' IS NOT NULL
        THEN (SELECT id FROM _ref_map WHERE ref = v_rec.data->>'manufacturer_ref')
        ELSE NULL
      END,
      CASE WHEN v_rec.data->>'supplier_ref' IS NOT NULL
        THEN (SELECT id FROM _ref_map WHERE ref = v_rec.data->>'supplier_ref')
        ELSE NULL
      END,
      CASE WHEN v_rec.data->>'parent_ref' IS NOT NULL
        THEN (SELECT id FROM _ref_map WHERE ref = v_rec.data->>'parent_ref')
        ELSE NULL
      END,
      v_now, v_now
    );
  END LOOP;

  -- ========================================================================
  -- STEP 11: Modifier groups, modifier_group_items, item_modifier_groups, product_recipes
  -- ========================================================================

  -- Modifier groups
  FOR v_rec IN
    SELECT ref, data
    FROM seed_demo_data
    WHERE entity_type = 'modifier_groups'
      AND (locale = p_locale)
      AND (mode = p_mode)
    ORDER BY sort_order
  LOOP
    INSERT INTO modifier_groups (id, company_id, name, min_selections, max_selections, sort_order, client_created_at, client_updated_at)
    VALUES (
      (SELECT id FROM _ref_map WHERE ref = v_rec.ref),
      v_company_id,
      v_rec.data->>'name',
      COALESCE((v_rec.data->>'min_selections')::int, 0),
      (v_rec.data->>'max_selections')::int,  -- NULL if jsonb null
      COALESCE((v_rec.data->>'sort_order')::int, 0),
      v_now, v_now
    );
  END LOOP;

  -- Modifier group items
  FOR v_rec IN
    SELECT ref, data
    FROM seed_demo_data
    WHERE entity_type = 'modifier_group_items'
      AND (locale = p_locale)
      AND (mode = p_mode)
    ORDER BY sort_order
  LOOP
    INSERT INTO modifier_group_items (id, company_id, modifier_group_id, item_id, sort_order, is_default, client_created_at, client_updated_at)
    VALUES (
      (SELECT id FROM _ref_map WHERE ref = v_rec.ref),
      v_company_id,
      (SELECT id FROM _ref_map WHERE ref = v_rec.data->>'modifier_group_ref'),
      (SELECT id FROM _ref_map WHERE ref = v_rec.data->>'item_ref'),
      COALESCE((v_rec.data->>'sort_order')::int, 0),
      COALESCE((v_rec.data->>'is_default')::boolean, false),
      v_now, v_now
    );
  END LOOP;

  -- Item modifier groups
  FOR v_rec IN
    SELECT ref, data
    FROM seed_demo_data
    WHERE entity_type = 'item_modifier_groups'
      AND (locale = p_locale)
      AND (mode = p_mode)
    ORDER BY sort_order
  LOOP
    INSERT INTO item_modifier_groups (id, company_id, item_id, modifier_group_id, sort_order, client_created_at, client_updated_at)
    VALUES (
      (SELECT id FROM _ref_map WHERE ref = v_rec.ref),
      v_company_id,
      (SELECT id FROM _ref_map WHERE ref = v_rec.data->>'item_ref'),
      (SELECT id FROM _ref_map WHERE ref = v_rec.data->>'modifier_group_ref'),
      COALESCE((v_rec.data->>'sort_order')::int, 0),
      v_now, v_now
    );
  END LOOP;

  -- Product recipes
  FOR v_rec IN
    SELECT ref, data
    FROM seed_demo_data
    WHERE entity_type = 'product_recipes'
      AND (locale = p_locale)
      AND (mode = p_mode)
    ORDER BY sort_order
  LOOP
    INSERT INTO product_recipes (id, company_id, parent_product_id, component_product_id, quantity_required, client_created_at, client_updated_at)
    VALUES (
      (SELECT id FROM _ref_map WHERE ref = v_rec.ref),
      v_company_id,
      (SELECT id FROM _ref_map WHERE ref = v_rec.data->>'parent_ref'),
      (SELECT id FROM _ref_map WHERE ref = v_rec.data->>'component_ref'),
      (v_rec.data->>'quantity')::double precision,
      v_now, v_now
    );
  END LOOP;

  -- ========================================================================
  -- STEP 12: Customers
  -- ========================================================================
  FOR v_rec IN
    SELECT ref, data
    FROM seed_demo_data
    WHERE entity_type = 'customers'
      AND (locale = p_locale)
      AND (mode = '_all' OR mode = p_mode)
    ORDER BY sort_order
  LOOP
    INSERT INTO customers (id, company_id, first_name, last_name, email, phone, address,
                           points, credit, total_spent, birthdate,
                           client_created_at, client_updated_at)
    VALUES (
      (SELECT id FROM _ref_map WHERE ref = v_rec.ref),
      v_company_id,
      v_rec.data->>'first_name',
      v_rec.data->>'last_name',
      v_rec.data->>'email',
      v_rec.data->>'phone',
      v_rec.data->>'address',
      0, 0, 0,
      (v_rec.data->>'birthdate')::date,
      v_now, v_now
    );
  END LOOP;

  -- ========================================================================
  -- STEP 13: Vouchers
  -- ========================================================================
  FOR v_rec IN
    SELECT ref, data
    FROM seed_demo_data
    WHERE entity_type = 'vouchers'
      AND (locale = p_locale)
      AND (mode = '_all' OR mode = p_mode)
    ORDER BY sort_order
  LOOP
    INSERT INTO vouchers (id, company_id, code, type, status, value,
                          discount_type, discount_scope,
                          category_id, customer_id,
                          expires_at, created_by_user_id, note,
                          client_created_at, client_updated_at)
    VALUES (
      (SELECT id FROM _ref_map WHERE ref = v_rec.ref),
      v_company_id,
      lpad((floor(random() * 10000))::int::text, 4, '0') || '-' || lpad((floor(random() * 10000))::int::text, 4, '0'),
      (v_rec.data->>'type')::voucher_type,
      (v_rec.data->>'status')::voucher_status,
      (v_rec.data->>'value')::int,
      (v_rec.data->>'discount_type')::discount_type,
      (v_rec.data->>'discount_scope')::voucher_discount_scope,
      CASE WHEN v_rec.data->>'category_ref' IS NOT NULL
        THEN (SELECT id FROM _ref_map WHERE ref = v_rec.data->>'category_ref')
        ELSE NULL
      END,
      CASE WHEN v_rec.data->>'customer_ref' IS NOT NULL
        THEN (SELECT id FROM _ref_map WHERE ref = v_rec.data->>'customer_ref')
        ELSE NULL
      END,
      CASE WHEN (v_rec.data->>'expires_days_ago') IS NOT NULL
        THEN v_now - ((v_rec.data->>'expires_days_ago')::int || ' days')::interval
        ELSE CASE WHEN (v_rec.data->>'status') = 'active' THEN v_now + interval '90 days' ELSE NULL END
      END,
      v_admin_user_id,
      v_rec.data->>'note',
      CASE WHEN (v_rec.data->>'created_days_back') IS NOT NULL
        THEN v_now - ((v_rec.data->>'created_days_back')::int || ' days')::interval
        ELSE v_now
      END,
      CASE WHEN (v_rec.data->>'created_days_back') IS NOT NULL
        THEN v_now - ((v_rec.data->>'created_days_back')::int || ' days')::interval
        ELSE v_now
      END
    );
  END LOOP;

  -- ========================================================================
  -- STEP 14: Register
  -- ========================================================================
  INSERT INTO registers (id, company_id, code, name, register_number, is_main, is_active, type,
                         allow_cash, allow_card, allow_transfer, allow_credit, allow_voucher, allow_refunds,
                         grid_rows, grid_cols, sell_mode,
                         client_created_at, client_updated_at)
  VALUES (
    v_register_id,
    v_company_id,
    'REG-001',
    CASE p_locale WHEN 'cs' THEN 'Hlavní pokladna' ELSE 'Main Register' END,
    1,
    true,
    true,
    'local'::hardware_type,
    true, true, true, true, true, true,
    v_grid_rows, v_grid_cols,
    CASE p_mode WHEN 'retail' THEN 'retail' ELSE 'gastro' END,
    v_now, v_now
  );

  -- ========================================================================
  -- STEP 15: Display device
  -- ========================================================================
  v_display_id := gen_random_uuid()::text;
  INSERT INTO display_devices (id, company_id, parent_register_id, code, name,
                               welcome_text, type, is_active,
                               client_created_at, client_updated_at)
  VALUES (
    v_display_id,
    v_company_id,
    v_register_id,
    '100001',
    CASE p_locale WHEN 'cs' THEN 'Zákaznický displej' ELSE 'Customer Display' END,
    CASE p_locale WHEN 'cs' THEN 'Vítejte!' ELSE 'Welcome!' END,
    'customerDisplay'::display_device_type,
    false,
    v_now, v_now
  );

  -- ========================================================================
  -- STEP 16: Layout items (5x8 grid)
  -- ========================================================================
  DECLARE
    v_cat_refs    text[];
    v_cat_id_cur  text;
    v_page_counter int := 1;
    v_sellable_items text[];
    v_c          int;
    v_r          int;
    v_li_idx     int;
    v_start_col  int;
  BEGIN
    -- Collect category refs that have sellable items, in sort_order
    SELECT array_agg(ref ORDER BY sort_order)
    INTO v_cat_refs
    FROM seed_demo_data
    WHERE entity_type = 'categories'
      AND locale = p_locale
      AND mode = p_mode;

    IF v_cat_refs IS NOT NULL THEN
      FOR v_idx IN 1..array_length(v_cat_refs, 1)
      LOOP
        v_cat_id_cur := (SELECT id FROM _ref_map WHERE ref = v_cat_refs[v_idx]);

        -- Get sellable items for this category
        SELECT array_agg(i.id ORDER BY sd.sort_order)
        INTO v_sellable_items
        FROM items i
        JOIN _ref_map rm ON rm.id = i.id
        JOIN seed_demo_data sd ON sd.ref = rm.ref
          AND sd.entity_type = 'items'
          AND sd.locale = p_locale
          AND sd.mode = p_mode
        WHERE i.company_id = v_company_id
          AND i.category_id = v_cat_id_cur
          AND i.is_sellable = true
          AND i.item_type != 'modifier';

        -- Page 0: category at (row, 0)
        INSERT INTO layout_items (id, company_id, register_id, page, grid_row, grid_col, type, category_id, client_created_at, client_updated_at)
        VALUES (gen_random_uuid()::text, v_company_id, v_register_id, 0, v_idx - 1, 0, 'category'::layout_item_type, v_cat_id_cur, v_now, v_now);

        -- Page 0: items at (row, 1..7)
        IF v_sellable_items IS NOT NULL THEN
          FOR v_c IN 1..least(v_grid_cols - 1, array_length(v_sellable_items, 1))
          LOOP
            INSERT INTO layout_items (id, company_id, register_id, page, grid_row, grid_col, type, item_id, client_created_at, client_updated_at)
            VALUES (gen_random_uuid()::text, v_company_id, v_register_id, 0, v_idx - 1, v_c, 'item'::layout_item_type, v_sellable_items[v_c], v_now, v_now);
          END LOOP;

          -- Subpage: category at (0,0), then all items
          IF array_length(v_sellable_items, 1) > 0 THEN
            INSERT INTO layout_items (id, company_id, register_id, page, grid_row, grid_col, type, category_id, client_created_at, client_updated_at)
            VALUES (gen_random_uuid()::text, v_company_id, v_register_id, v_page_counter, 0, 0, 'category'::layout_item_type, v_cat_id_cur, v_now, v_now);

            v_li_idx := 1;  -- 1-based index into v_sellable_items
            FOR v_r IN 0..v_grid_rows - 1
            LOOP
              v_start_col := CASE WHEN v_r = 0 THEN 1 ELSE 0 END;
              FOR v_c IN v_start_col..v_grid_cols - 1
              LOOP
                EXIT WHEN v_li_idx > array_length(v_sellable_items, 1);
                INSERT INTO layout_items (id, company_id, register_id, page, grid_row, grid_col, type, item_id, client_created_at, client_updated_at)
                Values (gen_random_uuid()::text, v_company_id, v_register_id, v_page_counter, v_r, v_c, 'item'::layout_item_type, v_sellable_items[v_li_idx], v_now, v_now);
                v_li_idx := v_li_idx + 1;
              END LOOP;
            END LOOP;
            v_page_counter := v_page_counter + 1;
          END IF;
        END IF;
      END LOOP;
    END IF;
  END;

  -- ========================================================================
  -- STEP 17: Company currencies
  -- ========================================================================
  IF p_currency_code = 'CZK' THEN
    v_foreign_cur_id := (SELECT id FROM currencies WHERE code = 'EUR');
    INSERT INTO company_currencies (id, company_id, currency_id, exchange_rate, is_active, sort_order, client_created_at, client_updated_at)
    VALUES (gen_random_uuid()::text, v_company_id, v_foreign_cur_id, 25.50, true, 0, v_now, v_now);
  ELSIF p_currency_code = 'EUR' THEN
    v_foreign_cur_id := (SELECT id FROM currencies WHERE code = 'CZK');
    INSERT INTO company_currencies (id, company_id, currency_id, exchange_rate, is_active, sort_order, client_created_at, client_updated_at)
    VALUES (gen_random_uuid()::text, v_company_id, v_foreign_cur_id, 0.039, true, 0, v_now, v_now);
  ELSE
    -- For other currencies, add EUR as alternative
    v_foreign_cur_id := (SELECT id FROM currencies WHERE code = 'EUR');
    INSERT INTO company_currencies (id, company_id, currency_id, exchange_rate, is_active, sort_order, client_created_at, client_updated_at)
    VALUES (gen_random_uuid()::text, v_company_id, v_foreign_cur_id, 1.0, true, 0, v_now, v_now);
  END IF;

  -- ========================================================================
  -- STEP 18: Process schedule — THE BIG LOOP
  -- ========================================================================

  -- Load schedule (mode-aware: retail uses schedule:retail, gastro uses schedule:default)
  SELECT data INTO v_schedule
  FROM seed_demo_data
  WHERE entity_type = '_schedule'
    AND ref = CASE p_mode WHEN 'retail' THEN 'schedule:retail' ELSE 'schedule:default' END
  LIMIT 1;

  IF v_schedule IS NULL THEN
    RAISE EXCEPTION 'Schedule not found for mode %', p_mode;
  END IF;

  v_days_back    := (v_schedule->>'days_back')::int;
  v_work_days    := v_schedule->'work_days';
  v_week_pattern := v_schedule->'week_pattern';
  v_overrides    := v_schedule->'overrides';

  -- Load all day templates into a jsonb map
  FOR v_rec IN
    SELECT ref, data
    FROM seed_demo_data
    WHERE entity_type = '_day_template'
  LOOP
    v_day_templates := v_day_templates || jsonb_build_object(v_rec.ref, v_rec.data);
  END LOOP;

  -- Main day loop
  FOR v_day_idx IN REVERSE v_days_back..0
  LOOP
    v_day_date := CURRENT_DATE - v_day_idx;
    v_is_today := (v_day_idx = 0);

    -- Day of week
    v_day_dow := CASE extract(dow FROM v_day_date)::int
      WHEN 0 THEN 'sun'
      WHEN 1 THEN 'mon'
      WHEN 2 THEN 'tue'
      WHEN 3 THEN 'wed'
      WHEN 4 THEN 'thu'
      WHEN 5 THEN 'fri'
      WHEN 6 THEN 'sat'
    END;

    -- Skip if not a work day (Sunday)
    IF NOT v_work_days ? v_day_dow THEN
      CONTINUE;
    END IF;

    -- Determine day template: check overrides first, then week_pattern
    IF v_overrides ? v_day_idx::text THEN
      v_day_ref := v_overrides->>v_day_idx::text;
    ELSE
      -- Find work-day index within the week for the week_pattern
      DECLARE
        v_wd_index int := 0;
        v_wd text;
      BEGIN
        FOR v_wd IN SELECT wd FROM jsonb_array_elements_text(v_work_days) AS wd
        LOOP
          EXIT WHEN v_wd = v_day_dow;
          v_wd_index := v_wd_index + 1;
        END LOOP;
        v_day_ref := v_week_pattern->>v_wd_index;
      END;
    END IF;

    -- Get day template
    v_day_tpl := v_day_templates->v_day_ref;
    IF v_day_tpl IS NULL THEN
      CONTINUE;
    END IF;

    -- Extract day template fields
    v_shift_pattern := v_day_tpl->>'shift_pattern';
    v_opening_cash  := (v_day_tpl->>'opening_cash')::int;
    v_has_foreign   := COALESCE((v_day_tpl->>'has_foreign_currency')::boolean, false);

    -- Session open time
    v_session_open := v_day_date + ((v_day_tpl->>'session_open_minutes')::int || ' minutes')::interval;
    -- Cap today's session open time to now (avoid future opened_at for non-UTC timezones)
    IF v_is_today THEN
      v_session_open := least(v_session_open, v_now);
    END IF;
    v_session_cash := v_opening_cash;

    -- Create register session
    v_session_id := gen_random_uuid()::text;

    -- Resolve morning user
    v_morning_user := (SELECT id FROM _ref_map WHERE ref = v_day_tpl->>'morning_user_ref');

    INSERT INTO register_sessions (id, company_id, register_id, opened_by_user_id, opened_at,
                                   opening_cash, bill_counter, order_counter,
                                   client_created_at, client_updated_at)
    VALUES (v_session_id, v_company_id, v_register_id, v_morning_user, v_session_open,
            v_opening_cash, 0, 0,
            v_session_open, v_session_open);

    -- Create shifts
    v_morning_shift_id := gen_random_uuid()::text;
    INSERT INTO shifts (id, company_id, register_session_id, user_id, login_at, client_created_at, client_updated_at)
    VALUES (v_morning_shift_id, v_company_id, v_session_id, v_morning_user, v_session_open, v_session_open, v_session_open);

    v_evening_shift_id := NULL;
    IF v_shift_pattern = 'two_users' AND v_day_tpl->>'evening_user_ref' IS NOT NULL THEN
      v_evening_user := (SELECT id FROM _ref_map WHERE ref = v_day_tpl->>'evening_user_ref');
      v_evening_shift_id := gen_random_uuid()::text;
      -- Evening user starts ~halfway
      INSERT INTO shifts (id, company_id, register_session_id, user_id, login_at, client_created_at, client_updated_at)
      VALUES (v_evening_shift_id, v_company_id, v_session_id, v_evening_user,
              v_session_open + interval '4 hours',
              v_session_open + interval '4 hours',
              v_session_open + interval '4 hours');
    ELSE
      v_evening_user := NULL;
    END IF;

    -- ----------------------------------------------------------------
    -- Process cash movements
    -- ----------------------------------------------------------------
    FOR v_idx IN 0..jsonb_array_length(COALESCE(v_day_tpl->'cash_movements', '[]'::jsonb)) - 1
    LOOP
      v_cm := v_day_tpl->'cash_movements'->v_idx;

      -- Skip future cash movements on today's session
      IF v_is_today AND v_session_open + ((v_cm->>'time_offset_minutes')::int || ' minutes')::interval > v_now THEN
        CONTINUE;
      END IF;

      v_cm_type := v_cm->>'type';
      v_cm_amount := (v_cm->>'amount')::int;

      INSERT INTO cash_movements (id, company_id, register_session_id, user_id, type, amount,
                                  reason, client_created_at, client_updated_at)
      VALUES (
        gen_random_uuid()::text,
        v_company_id,
        v_session_id,
        (SELECT id FROM _ref_map WHERE ref = v_cm->>'user_ref'),
        v_cm_type::cash_movement_type,
        v_cm_amount,
        CASE p_locale
          WHEN 'cs' THEN v_cm->>'reason_cs'
          ELSE v_cm->>'reason_en'
        END,
        v_session_open + ((v_cm->>'time_offset_minutes')::int || ' minutes')::interval,
        v_session_open + ((v_cm->>'time_offset_minutes')::int || ' minutes')::interval
      );

      -- Update running cash
      IF v_cm_type = 'deposit' THEN
        v_session_cash := v_session_cash + v_cm_amount;
      ELSIF v_cm_type IN ('withdrawal', 'expense') THEN
        v_session_cash := v_session_cash - v_cm_amount;
      END IF;
    END LOOP;

    -- ----------------------------------------------------------------
    -- Process bills
    -- ----------------------------------------------------------------
    v_foreign_cash := 0;  -- track foreign currency cash for session

    FOR v_idx IN 0..jsonb_array_length(COALESCE(v_day_tpl->'bills', '[]'::jsonb)) - 1
    LOOP
      v_bill := v_day_tpl->'bills'->v_idx;
      v_bill_status := v_bill->>'status';
      v_bill_user_ref := v_bill->>'user_ref';
      v_bill_time := v_session_open + ((v_bill->>'time_offset_minutes')::int || ' minutes')::interval;

      -- Skip future bills on today's session (demo created before session_open_minutes)
      IF v_is_today AND v_bill_time > v_now THEN
        CONTINUE;
      END IF;

      v_is_takeaway := COALESCE((v_bill->>'is_takeaway')::boolean, false);
      v_guests := COALESCE((v_bill->>'guests')::int, 1);

      -- Resolve table and section
      v_table_ref := v_bill->>'table_ref';
      IF v_table_ref IS NOT NULL THEN
        v_table_id := (SELECT id FROM _ref_map WHERE ref = v_table_ref);
        SELECT section_id INTO v_section_id FROM tables WHERE id = v_table_id;
      ELSE
        v_table_id := NULL;
        -- For takeaway, use the default section
        SELECT id INTO v_section_id FROM sections WHERE company_id = v_company_id AND is_default = true LIMIT 1;
      END IF;

      -- Resolve customer
      v_customer_ref := v_bill->>'customer_ref';
      IF v_customer_ref IS NOT NULL THEN
        v_customer_id := (SELECT id FROM _ref_map WHERE ref = v_customer_ref);
      ELSE
        v_customer_id := NULL;
      END IF;

      -- Bill-level discount
      v_bill_discount_pct := (v_bill->>'bill_discount_percent')::int;
      v_bill_discount_amt := (v_bill->>'bill_discount_amount')::int;

      -- Increment bill counter
      v_bill_counter := v_bill_counter + 1;
      v_bill_id := gen_random_uuid()::text;

      -- ----------------------------------------------------------------
      -- Process orders for this bill and accumulate totals
      -- ----------------------------------------------------------------
      v_subtotal_gross := 0;
      v_subtotal_net := 0;
      v_tax_total := 0;

      v_orders := v_bill->'orders';
      FOR v_idx2 IN 0..jsonb_array_length(COALESCE(v_orders, '[]'::jsonb)) - 1
      LOOP
        v_order := v_orders->v_idx2;
        v_order_counter := v_order_counter + 1;
        v_order_id := gen_random_uuid()::text;
        v_order_number := 'O-' || lpad(v_order_counter::text, 4, '0');
        v_prep_status := COALESCE(v_order->>'prep_status', 'delivered');

        v_order_gross := 0;
        v_order_net := 0;
        v_order_tax := 0;
        v_order_count := 0;

        -- Resolve the user for this order
        v_order_user := (SELECT id FROM _ref_map WHERE ref = v_bill_user_ref);

        v_items := v_order->'items';
        <<items_loop>>
        FOR v_c IN 0..jsonb_array_length(COALESCE(v_items, '[]'::jsonb)) - 1
        LOOP
          v_item := v_items->v_c;
          v_item_ref := v_item->>'item_ref';
          v_item_id := (SELECT id FROM _ref_map WHERE ref = v_item_ref);
          IF v_item_id IS NULL THEN CONTINUE items_loop; END IF;
          v_qty := (v_item->>'qty')::int;
          v_unit_price := (v_item->>'unit_price')::int;

          -- Get item name and tax rate from the items table
          SELECT i.name, i.unit, i.sale_tax_rate_id INTO v_item_name, v_item_unit, v_tax_rate_id
          FROM items i WHERE i.id = v_item_id;

          -- Get tax rate value
          SELECT tr.rate INTO v_tax_rate
          FROM tax_rates tr WHERE tr.id = v_tax_rate_id;

          -- Item-level discount
          v_item_disc_pct := (v_item->>'discount_percent')::int;
          v_item_disc_amt := (v_item->>'discount_amount')::int;

          -- Item status (default to 'delivered' unless voided)
          DECLARE
            v_item_status text;
          BEGIN
            v_item_status := COALESCE(v_item->>'status', v_prep_status);

            -- Calculate totals
            v_item_gross := v_unit_price::bigint * v_qty;
            v_item_discount := 0;

            IF v_item_disc_pct IS NOT NULL AND v_item_disc_pct > 0 THEN
              v_item_discount := (v_item_gross * v_item_disc_pct) / 10000;
            ELSIF v_item_disc_amt IS NOT NULL AND v_item_disc_amt > 0 THEN
              v_item_discount := v_item_disc_amt::bigint * v_qty;
            END IF;

            v_item_after := v_item_gross - v_item_discount;

            IF v_tax_rate IS NOT NULL AND v_tax_rate > 0 THEN
              v_item_tax := v_item_after - (v_item_after * 10000 / (10000 + v_tax_rate));
            ELSE
              v_item_tax := 0;
            END IF;
            v_item_net := v_item_after - v_item_tax;

            -- Create order_item
            v_oi_id := gen_random_uuid()::text;
            INSERT INTO order_items (id, company_id, order_id, item_id, item_name, quantity,
                                     sale_price_att, sale_tax_rate_att, sale_tax_amount, unit,
                                     discount, discount_type, notes,
                                     status,
                                     prep_started_at, ready_at, delivered_at,
                                     client_created_at, client_updated_at)
            VALUES (
              v_oi_id, v_company_id, v_order_id, v_item_id, v_item_name, v_qty,
              v_unit_price, v_tax_rate, v_item_tax::int, v_item_unit::unit_type,
              CASE
                WHEN v_item_disc_pct IS NOT NULL AND v_item_disc_pct > 0 THEN v_item_disc_pct
                WHEN v_item_disc_amt IS NOT NULL AND v_item_disc_amt > 0 THEN v_item_disc_amt
                ELSE 0
              END,
              CASE
                WHEN v_item_disc_pct IS NOT NULL AND v_item_disc_pct > 0 THEN 'percent'::discount_type
                WHEN v_item_disc_amt IS NOT NULL AND v_item_disc_amt > 0 THEN 'absolute'::discount_type
                ELSE NULL
              END,
              v_item->>'notes',
              v_item_status::prep_status,
              CASE WHEN v_item_status IN ('delivered', 'ready') THEN v_bill_time ELSE NULL END,
              CASE WHEN v_item_status IN ('delivered', 'ready') THEN v_bill_time ELSE NULL END,
              CASE WHEN v_item_status = 'delivered' THEN v_bill_time ELSE NULL END,
              v_bill_time, v_bill_time
            );

            -- Only count non-voided items in totals
            IF v_item_status != 'voided' THEN
              v_order_gross := v_order_gross + v_item_after;
              v_order_net   := v_order_net + v_item_net;
              v_order_tax   := v_order_tax + v_item_tax;
              v_order_count := v_order_count + v_qty;

            END IF;

            -- Process modifiers for this item
            v_modifiers := v_item->'modifiers';
            IF v_modifiers IS NOT NULL AND jsonb_array_length(v_modifiers) > 0 THEN
              <<modifiers_loop>>
              FOR v_r IN 0..jsonb_array_length(v_modifiers) - 1
              LOOP
                v_modifier := v_modifiers->v_r;
                v_mod_ref := v_modifier->>'ref';
                v_mod_item_id := (SELECT id FROM _ref_map WHERE ref = v_mod_ref);
                IF v_mod_item_id IS NULL THEN CONTINUE modifiers_loop; END IF;
                v_mod_qty := (v_modifier->>'qty')::int;
                v_mod_unit_price := (v_modifier->>'unit_price')::int;

                -- Get modifier item name and tax rate
                SELECT mi.name, mi.sale_tax_rate_id INTO v_mod_item_name, v_mod_tax_rate_id
                FROM items mi WHERE mi.id = v_mod_item_id;

                SELECT tr.rate INTO v_mod_tax_rate
                FROM tax_rates tr WHERE tr.id = v_mod_tax_rate_id;

                v_mod_gross := v_mod_unit_price::bigint * v_mod_qty * v_qty;

                IF v_mod_tax_rate IS NOT NULL AND v_mod_tax_rate > 0 THEN
                  v_mod_tax := v_mod_gross - (v_mod_gross * 10000 / (10000 + v_mod_tax_rate));
                ELSE
                  v_mod_tax := 0;
                END IF;

                -- Find the modifier_group_id for this item+modifier combo
                DECLARE
                  v_mod_group_id text;
                BEGIN
                  SELECT img.modifier_group_id INTO v_mod_group_id
                  FROM item_modifier_groups img
                  JOIN modifier_group_items mgi ON mgi.modifier_group_id = img.modifier_group_id
                  WHERE img.company_id = v_company_id
                    AND mgi.item_id = v_mod_item_id
                  LIMIT 1;

                  INSERT INTO order_item_modifiers (id, company_id, order_item_id, modifier_item_id, modifier_group_id,
                                                    modifier_item_name, quantity, unit_price, tax_rate, tax_amount,
                                                    client_created_at, client_updated_at)
                  VALUES (
                    gen_random_uuid()::text, v_company_id, v_oi_id, v_mod_item_id, v_mod_group_id,
                    v_mod_item_name, v_mod_qty * v_qty, v_mod_unit_price, v_mod_tax_rate, v_mod_tax::int,
                    v_bill_time, v_bill_time
                  );
                END;

                -- Add modifier totals (only if parent item not voided)
                IF v_item_status != 'voided' THEN
                  v_order_gross := v_order_gross + v_mod_gross;
                  v_order_net   := v_order_net + (v_mod_gross - v_mod_tax);
                  v_order_tax   := v_order_tax + v_mod_tax;
                END IF;
              END LOOP;
            END IF;
          END;
        END LOOP;

        -- Insert order
        INSERT INTO orders (id, company_id, bill_id, register_id, created_by_user_id, order_number,
                            status, item_count, subtotal_gross, subtotal_net, tax_total,
                            prep_started_at, ready_at, delivered_at,
                            client_created_at, client_updated_at)
        VALUES (
          v_order_id, v_company_id, v_bill_id, v_register_id, v_order_user, v_order_number,
          (CASE WHEN v_bill_status = 'cancelled' THEN 'cancelled' ELSE v_prep_status END)::prep_status,
          v_order_count, v_order_gross::int, v_order_net::int, v_order_tax::int,
          CASE WHEN v_prep_status IN ('delivered', 'ready', 'created') THEN v_bill_time ELSE NULL END,
          CASE WHEN v_prep_status IN ('delivered', 'ready') THEN v_bill_time + interval '5 minutes' ELSE NULL END,
          CASE WHEN v_prep_status = 'delivered' THEN v_bill_time + interval '10 minutes' ELSE NULL END,
          v_bill_time, v_bill_time
        );

        -- Accumulate bill totals
        v_subtotal_gross := v_subtotal_gross + v_order_gross;
        v_subtotal_net   := v_subtotal_net + v_order_net;
        v_tax_total      := v_tax_total + v_order_tax;
      END LOOP;

      -- Apply bill-level discount
      v_discount_total := 0;
      v_total_gross := v_subtotal_gross;

      IF v_bill_discount_pct IS NOT NULL AND v_bill_discount_pct > 0 THEN
        v_discount_total := (v_subtotal_gross * v_bill_discount_pct) / 10000;
        v_total_gross := v_subtotal_gross - v_discount_total;
        -- Scale tax proportionally to the discount
        IF v_subtotal_gross > 0 THEN
          v_tax_total := (v_tax_total * v_total_gross) / v_subtotal_gross;
        END IF;
        v_subtotal_net := v_total_gross - v_tax_total;
      ELSIF v_bill_discount_amt IS NOT NULL AND v_bill_discount_amt > 0 THEN
        v_discount_total := v_bill_discount_amt;
        v_total_gross := v_subtotal_gross - v_discount_total;
        -- Scale tax proportionally
        IF v_subtotal_gross > 0 THEN
          v_tax_total := (v_tax_total * v_total_gross) / v_subtotal_gross;
        END IF;
        v_subtotal_net := v_total_gross - v_tax_total;
      END IF;

      -- Calculate paid amount and tips
      v_paid_amount := 0;
      v_tip_total := 0;
      v_payments := v_bill->'payments';
      FOR v_c IN 0..jsonb_array_length(COALESCE(v_payments, '[]'::jsonb)) - 1
      LOOP
        v_payment := v_payments->v_c;
        v_paid_amount := v_paid_amount + COALESCE((v_payment->>'amount')::int, 0);
        v_tip_total := v_tip_total + COALESCE((v_payment->>'tip')::int, 0);
      END LOOP;

      -- Loyalty & voucher calculations
      v_loyalty_discount_amount := COALESCE((v_bill->>'loyalty_points_used')::int, 0) * 100;
      v_voucher_discount_amount := COALESCE((v_bill->>'voucher_discount_amount')::int, 0);
      IF v_bill_status = 'paid' AND v_customer_id IS NOT NULL THEN
        v_loyalty_points_earned := (v_total_gross / 1000)::int;
      ELSE
        v_loyalty_points_earned := 0;
      END IF;

      -- Insert bill
      INSERT INTO bills (id, company_id, customer_id, customer_name, section_id, table_id,
                         register_id, last_register_id, register_session_id, opened_by_user_id,
                         bill_number, number_of_guests, is_takeaway, status, currency_id,
                         subtotal_gross, subtotal_net, discount_amount, discount_type,
                         tax_total, total_gross, paid_amount,
                         loyalty_points_used,
                         loyalty_discount_amount, voucher_discount_amount, loyalty_points_earned,
                         voucher_id,
                         opened_at, closed_at,
                         client_created_at, client_updated_at)
      VALUES (
        v_bill_id, v_company_id, v_customer_id,
        CASE WHEN v_customer_id IS NOT NULL THEN (SELECT first_name || ' ' || last_name FROM customers WHERE id = v_customer_id) ELSE NULL END,
        v_section_id, v_table_id,
        v_register_id, v_register_id, v_session_id, v_order_user,
        'B-' || lpad(v_bill_counter::text, 4, '0'),
        v_guests, v_is_takeaway,
        v_bill_status::bill_status,
        v_currency_id,
        v_subtotal_gross::int, v_subtotal_net::int,
        CASE WHEN v_discount_total > 0 THEN v_discount_total::int ELSE 0 END,
        CASE
          WHEN v_bill_discount_pct IS NOT NULL AND v_bill_discount_pct > 0 THEN 'percent'::discount_type
          WHEN v_bill_discount_amt IS NOT NULL AND v_bill_discount_amt > 0 THEN 'absolute'::discount_type
          ELSE NULL
        END,
        v_tax_total::int, v_total_gross::int,
        CASE WHEN v_bill_status IN ('paid', 'refunded') THEN v_paid_amount::int ELSE 0 END,
        COALESCE((v_bill->>'loyalty_points_used')::int, 0),
        v_loyalty_discount_amount, v_voucher_discount_amount, v_loyalty_points_earned,
        CASE WHEN v_bill->>'voucher_ref' IS NOT NULL
          THEN (SELECT id FROM _ref_map WHERE ref = v_bill->>'voucher_ref')
          ELSE NULL
        END,
        v_bill_time,
        CASE WHEN v_bill_status IN ('paid', 'cancelled', 'refunded') THEN v_bill_time + interval '2 minutes' ELSE NULL END,
        v_bill_time, v_bill_time
      );

      -- Update voucher if bill references one
      v_voucher_ref := v_bill->>'voucher_ref';
      IF v_voucher_ref IS NOT NULL THEN
        v_voucher_id := (SELECT id FROM _ref_map WHERE ref = v_voucher_ref);
        IF v_voucher_id IS NOT NULL THEN
          UPDATE vouchers SET
            used_count = used_count + 1,
            redeemed_at = CASE WHEN used_count + 1 >= max_uses THEN v_bill_time ELSE redeemed_at END,
            redeemed_on_bill_id = v_bill_id,
            status = CASE WHEN used_count + 1 >= max_uses THEN 'redeemed'::voucher_status ELSE status END,
            client_updated_at = v_bill_time
          WHERE id = v_voucher_id;
        END IF;
      END IF;

      -- ----------------------------------------------------------------
      -- Stock movements from sales (outbound for stock-tracked items)
      -- ----------------------------------------------------------------
      INSERT INTO stock_movements (id, company_id, bill_id, item_id,
                                   quantity, direction,
                                   client_created_at, client_updated_at)
      SELECT gen_random_uuid()::text, v_company_id, v_bill_id, oi.item_id,
             oi.quantity::double precision, 'outbound'::stock_movement_direction,
             v_bill_time, v_bill_time
      FROM order_items oi
      JOIN orders o ON o.id = oi.order_id
      JOIN items i ON i.id = oi.item_id
      WHERE o.bill_id = v_bill_id
        AND oi.status != 'voided'
        AND i.is_stock_tracked = true;

      -- ----------------------------------------------------------------
      -- Payments
      -- ----------------------------------------------------------------
      IF v_bill_status IN ('paid', 'refunded') AND v_payments IS NOT NULL THEN
        FOR v_c IN 0..jsonb_array_length(v_payments) - 1
        LOOP
          v_payment := v_payments->v_c;
          v_pay_method_ref := v_payment->>'method_ref';
          v_pay_method_id := (SELECT id FROM _ref_map WHERE ref = v_pay_method_ref);
          v_pay_amount := (v_payment->>'amount')::int;
          v_pay_tip := COALESCE((v_payment->>'tip')::int, 0);

          v_pay_id := gen_random_uuid()::text;
          INSERT INTO payments (id, company_id, bill_id, register_id, register_session_id, user_id,
                                payment_method_id, amount, paid_at, currency_id,
                                tip_included_amount,
                                foreign_currency_id, foreign_amount, exchange_rate,
                                card_last4, transaction_id, payment_provider, authorization_code,
                                client_created_at, client_updated_at)
          VALUES (
            v_pay_id, v_company_id, v_bill_id, v_register_id, v_session_id, v_order_user,
            v_pay_method_id, v_pay_amount,
            v_bill_time + interval '1 minute',
            v_currency_id,
            v_pay_tip,
            CASE WHEN v_payment->>'foreign_currency' IS NOT NULL
              THEN (SELECT id FROM currencies WHERE code = v_payment->>'foreign_currency')
              ELSE NULL
            END,
            (v_payment->>'foreign_amount')::int,
            (v_payment->>'exchange_rate')::double precision,
            CASE WHEN v_pay_method_ref = 'pm:card' THEN lpad((floor(random() * 10000))::int::text, 4, '0') ELSE NULL END,
            CASE WHEN v_pay_method_ref = 'pm:card' THEN 'TXN-' || upper(substr(md5(v_pay_id), 1, 8)) ELSE NULL END,
            CASE WHEN v_pay_method_ref = 'pm:card' THEN 'SumUp' ELSE NULL END,
            CASE WHEN v_pay_method_ref = 'pm:card' THEN upper(substr(md5(v_pay_id || 'auth'), 1, 6)) ELSE NULL END,
            v_bill_time + interval '1 minute',
            v_bill_time + interval '1 minute'
          );

          -- Update running cash (cash payments only, for non-refunded bills)
          IF v_pay_method_ref = 'pm:cash' THEN
            IF v_bill_status = 'paid' THEN
              v_session_cash := v_session_cash + v_pay_amount;
            ELSIF v_bill_status = 'refunded' THEN
              v_session_cash := v_session_cash - v_pay_amount;
            END IF;
          END IF;

          -- Track foreign currency cash
          IF v_payment->>'foreign_currency' IS NOT NULL AND v_pay_method_ref = 'pm:cash' THEN
            v_foreign_cash := v_foreign_cash + COALESCE((v_payment->>'foreign_amount')::int, 0);
          END IF;
        END LOOP;
      END IF;
    END LOOP;  -- end bills loop

    -- ----------------------------------------------------------------
    -- Stock documents + stock movements
    -- ----------------------------------------------------------------
    v_stock_docs := v_day_tpl->'stock_documents';
    FOR v_idx IN 0..jsonb_array_length(COALESCE(v_stock_docs, '[]'::jsonb)) - 1
    LOOP
      v_sdoc := v_stock_docs->v_idx;

      -- Skip future stock documents on today's session
      IF v_is_today AND v_session_open + ((v_sdoc->>'time_offset_minutes')::int || ' minutes')::interval > v_now THEN
        CONTINUE;
      END IF;

      v_sdoc_type := v_sdoc->>'type';
      v_stock_doc_counter := v_stock_doc_counter + 1;
      v_sdoc_id := gen_random_uuid()::text;

      -- Direction based on type
      v_sm_direction := CASE v_sdoc_type
        WHEN 'receipt'    THEN 'inbound'
        WHEN 'waste'      THEN 'outbound'
        WHEN 'inventory'  THEN 'inbound'   -- inventory adjustments
        WHEN 'correction' THEN 'inbound'
        ELSE 'inbound'
      END;

      -- Calculate total amount
      DECLARE
        v_sdoc_total bigint := 0;
        v_si_idx int;
      BEGIN
        FOR v_si_idx IN 0..jsonb_array_length(COALESCE(v_sdoc->'items', '[]'::jsonb)) - 1
        LOOP
          v_sitem := v_sdoc->'items'->v_si_idx;
          -- Skip items whose ref is not in _ref_map (wrong mode)
          IF (SELECT id FROM _ref_map WHERE ref = v_sitem->>'item_ref') IS NULL THEN
            CONTINUE;
          END IF;
          v_sdoc_total := v_sdoc_total + (COALESCE((v_sitem->>'qty')::numeric, 0) * COALESCE((v_sitem->>'unit_price')::int, 0))::bigint;
        END LOOP;

        INSERT INTO stock_documents (id, company_id, warehouse_id, supplier_id, user_id,
                                     document_number, type, note, total_amount, document_date,
                                     client_created_at, client_updated_at)
        VALUES (
          v_sdoc_id, v_company_id, v_warehouse_id,
          CASE WHEN v_sdoc->>'supplier_ref' IS NOT NULL
            THEN (SELECT id FROM _ref_map WHERE ref = v_sdoc->>'supplier_ref')
            ELSE NULL
          END,
          v_morning_user,
          upper(v_sdoc_type) || '-' || lpad(v_stock_doc_counter::text, 3, '0'),
          v_sdoc_type::stock_document_type,
          CASE p_locale WHEN 'cs' THEN v_sdoc->>'note_cs' ELSE v_sdoc->>'note_en' END,
          v_sdoc_total::int,
          v_day_date,
          v_session_open + ((v_sdoc->>'time_offset_minutes')::int || ' minutes')::interval,
          v_session_open + ((v_sdoc->>'time_offset_minutes')::int || ' minutes')::interval
        );

        -- Stock movements for each item
        <<stock_items_loop>>
        FOR v_si_idx IN 0..jsonb_array_length(COALESCE(v_sdoc->'items', '[]'::jsonb)) - 1
        LOOP
          v_sitem := v_sdoc->'items'->v_si_idx;
          -- Skip items whose ref is not in _ref_map (wrong mode)
          IF (SELECT id FROM _ref_map WHERE ref = v_sitem->>'item_ref') IS NULL THEN
            CONTINUE stock_items_loop;
          END IF;

          INSERT INTO stock_movements (id, company_id, stock_document_id, item_id,
                                       quantity, purchase_price, direction,
                                       client_created_at, client_updated_at)
          VALUES (
            gen_random_uuid()::text, v_company_id, v_sdoc_id,
            (SELECT id FROM _ref_map WHERE ref = v_sitem->>'item_ref'),
            (v_sitem->>'qty')::double precision,
            (v_sitem->>'unit_price')::int,
            v_sm_direction::stock_movement_direction,
            v_session_open + ((v_sdoc->>'time_offset_minutes')::int || ' minutes')::interval,
            v_session_open + ((v_sdoc->>'time_offset_minutes')::int || ' minutes')::interval
          );
        END LOOP;
      END;
    END LOOP;

    -- ----------------------------------------------------------------
    -- Reservations
    -- ----------------------------------------------------------------
    v_reservations := v_day_tpl->'reservations';
    FOR v_idx IN 0..jsonb_array_length(COALESCE(v_reservations, '[]'::jsonb)) - 1
    LOOP
      v_resv := v_reservations->v_idx;
      v_resv_id := gen_random_uuid()::text;

      DECLARE
        v_resv_customer_id text;
        v_resv_customer_name text;
        v_resv_customer_phone text;
      BEGIN
        IF v_resv->>'customer_ref' IS NOT NULL THEN
          v_resv_customer_id := (SELECT id FROM _ref_map WHERE ref = v_resv->>'customer_ref');
          SELECT first_name || ' ' || last_name, phone
          INTO v_resv_customer_name, v_resv_customer_phone
          FROM customers WHERE id = v_resv_customer_id;
        ELSE
          v_resv_customer_id := NULL;
          v_resv_customer_name := NULL;
          v_resv_customer_phone := NULL;
        END IF;

        INSERT INTO reservations (id, company_id, customer_id, customer_name, customer_phone,
                                  reservation_date, party_size, duration_minutes, table_id, notes, status,
                                  client_created_at, client_updated_at)
        VALUES (
          v_resv_id, v_company_id, v_resv_customer_id, v_resv_customer_name, v_resv_customer_phone,
          v_session_open + ((v_resv->>'time_offset_minutes')::int || ' minutes')::interval,
          (v_resv->>'guests')::int,
          COALESCE((v_resv->>'duration_minutes')::int, 90),
          CASE WHEN v_resv->>'table_ref' IS NOT NULL
            THEN (SELECT id FROM _ref_map WHERE ref = v_resv->>'table_ref')
            ELSE NULL
          END,
          CASE p_locale WHEN 'cs' THEN v_resv->>'note_cs' ELSE v_resv->>'note_en' END,
          (v_resv->>'status')::reservation_status,
          v_session_open + ((v_resv->>'time_offset_minutes')::int || ' minutes')::interval,
          v_session_open + ((v_resv->>'time_offset_minutes')::int || ' minutes')::interval
        );
      END;
    END LOOP;

    -- ----------------------------------------------------------------
    -- Customer transactions
    -- ----------------------------------------------------------------
    v_ctxns := v_day_tpl->'customer_transactions';
    FOR v_idx IN 0..jsonb_array_length(COALESCE(v_ctxns, '[]'::jsonb)) - 1
    LOOP
      v_ctx := v_ctxns->v_idx;

      -- Skip future customer transactions on today's session
      IF v_is_today AND v_session_open + ((v_ctx->>'time_offset_minutes')::int || ' minutes')::interval > v_now THEN
        CONTINUE;
      END IF;

      v_ctx_id := gen_random_uuid()::text;

      INSERT INTO customer_transactions (id, company_id, customer_id,
                                         points_change, credit_change,
                                         processed_by_user_id,
                                         client_created_at, client_updated_at)
      VALUES (
        v_ctx_id, v_company_id,
        (SELECT id FROM _ref_map WHERE ref = v_ctx->>'customer_ref'),
        COALESCE((v_ctx->>'points')::int, 0),
        COALESCE((v_ctx->>'credit')::int, 0),
        v_morning_user,
        v_session_open + ((v_ctx->>'time_offset_minutes')::int || ' minutes')::interval,
        v_session_open + ((v_ctx->>'time_offset_minutes')::int || ' minutes')::interval
      );
    END LOOP;

    -- ----------------------------------------------------------------
    -- Session currency cash (for foreign currency days)
    -- ----------------------------------------------------------------
    IF v_has_foreign AND v_foreign_cur_id IS NOT NULL THEN
      v_scc_id := gen_random_uuid()::text;
      INSERT INTO session_currency_cash (id, company_id, register_session_id, currency_id,
                                         opening_cash, closing_cash, expected_cash, difference,
                                         client_created_at, client_updated_at)
      VALUES (
        v_scc_id, v_company_id, v_session_id, v_foreign_cur_id,
        0,
        CASE WHEN NOT v_is_today THEN v_foreign_cash::int ELSE NULL END,
        CASE WHEN NOT v_is_today THEN v_foreign_cash::int ELSE NULL END,
        CASE WHEN NOT v_is_today THEN 0 ELSE NULL END,
        v_session_open, v_session_open
      );
    END IF;

    -- ----------------------------------------------------------------
    -- Close session (skip for today/open)
    -- ----------------------------------------------------------------
    IF NOT v_is_today AND (v_day_tpl->>'session_close_minutes') IS NOT NULL THEN
      v_session_close := v_day_date + ((v_day_tpl->>'session_close_minutes')::int || ' minutes')::interval;

      -- Close morning shift
      UPDATE shifts SET
        logout_at = CASE
          WHEN v_evening_shift_id IS NOT NULL THEN v_session_open + interval '8 hours'
          ELSE v_session_close
        END,
        client_updated_at = v_session_close
      WHERE id = v_morning_shift_id;

      -- Close evening shift
      IF v_evening_shift_id IS NOT NULL THEN
        UPDATE shifts SET
          logout_at = v_session_close,
          client_updated_at = v_session_close
        WHERE id = v_evening_shift_id;
      END IF;

      -- Calculate expected cash
      v_expected_cash := v_session_cash;

      -- Count open bills at close (should be 0 for past days)
      UPDATE register_sessions SET
        closed_at = v_session_close,
        closing_cash = v_session_cash::int,
        expected_cash = v_expected_cash::int,
        difference = 0,
        bill_counter = v_bill_counter,
        order_counter = v_order_counter,
        open_bills_at_close_count = 0,
        open_bills_at_close_amount = 0,
        client_updated_at = v_session_close
      WHERE id = v_session_id;
    ELSE
      -- Today's open session — just update counters
      UPDATE register_sessions SET
        bill_counter = v_bill_counter,
        order_counter = v_order_counter,
        client_updated_at = v_now
      WHERE id = v_session_id;

      -- Update register active_bill_id to the last open bill
      UPDATE registers SET
        active_bill_id = (
          SELECT id FROM bills
          WHERE register_session_id = v_session_id AND status = 'opened'
          ORDER BY opened_at DESC LIMIT 1
        ),
        client_updated_at = v_now
      WHERE id = v_register_id;
    END IF;

  END LOOP;  -- end day loop

  -- ========================================================================
  -- STEP 19: Update stock_levels
  -- ========================================================================
  INSERT INTO stock_levels (id, company_id, warehouse_id, item_id, quantity, client_created_at, client_updated_at)
  SELECT
    gen_random_uuid()::text,
    v_company_id,
    v_warehouse_id,
    sm.item_id,
    SUM(CASE WHEN sm.direction = 'inbound' THEN sm.quantity ELSE -sm.quantity END),
    v_now, v_now
  FROM stock_movements sm
  WHERE sm.company_id = v_company_id
  GROUP BY sm.item_id
  HAVING SUM(CASE WHEN sm.direction = 'inbound' THEN sm.quantity ELSE -sm.quantity END) != 0;

  -- Also add initial stock for stock-tracked items that have no stock movements yet
  -- (they were sold but never received — give them a reasonable starting quantity)
  INSERT INTO stock_levels (id, company_id, warehouse_id, item_id, quantity, client_created_at, client_updated_at)
  SELECT
    gen_random_uuid()::text,
    v_company_id,
    v_warehouse_id,
    i.id,
    100,  -- default starting quantity for items without stock docs
    v_now, v_now
  FROM items i
  WHERE i.company_id = v_company_id
    AND i.is_stock_tracked = true
    AND NOT EXISTS (
      SELECT 1 FROM stock_levels sl WHERE sl.company_id = v_company_id AND sl.item_id = i.id
    );

  -- ========================================================================
  -- STEP 20: Update customer denormalized totals
  -- ========================================================================
  UPDATE customers c SET
    points = COALESCE(ct_agg.total_points, 0),
    credit = COALESCE(ct_agg.total_credit, 0),
    total_spent = COALESCE(bill_agg.total_spent, 0),
    last_visit_date = bill_agg.last_visit,
    client_updated_at = v_now
  FROM (
    SELECT customer_id,
           SUM(points_change) AS total_points,
           SUM(credit_change) AS total_credit
    FROM customer_transactions
    WHERE company_id = v_company_id
    GROUP BY customer_id
  ) ct_agg
  FULL OUTER JOIN (
    SELECT customer_id,
           SUM(total_gross) AS total_spent,
           MAX(closed_at) AS last_visit
    FROM bills
    WHERE company_id = v_company_id
      AND status = 'paid'
      AND customer_id IS NOT NULL
    GROUP BY customer_id
  ) bill_agg ON ct_agg.customer_id = bill_agg.customer_id
  WHERE c.id = COALESCE(ct_agg.customer_id, bill_agg.customer_id)
    AND c.company_id = v_company_id;

  -- ========================================================================
  -- STEP 21: Return result
  -- ========================================================================
  RETURN jsonb_build_object(
    'company_id', v_company_id,
    'register_id', v_register_id
  );
END;
$$;

-- Grant execution to authenticated users (will be called via edge function with service_role)
GRANT EXECUTE ON FUNCTION create_demo_company(uuid, text, text, text, text) TO service_role;
