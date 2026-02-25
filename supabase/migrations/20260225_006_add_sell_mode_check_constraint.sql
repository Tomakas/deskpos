ALTER TABLE registers
  ADD CONSTRAINT chk_sell_mode CHECK (sell_mode IN ('gastro', 'retail'));
