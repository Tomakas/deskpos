ALTER TABLE stock_movements ADD COLUMN bill_id text REFERENCES bills(id);
CREATE INDEX idx_stock_movements_bill ON stock_movements(bill_id);
