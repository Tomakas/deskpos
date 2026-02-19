ALTER TABLE registers
  ADD COLUMN IF NOT EXISTS sell_mode text NOT NULL DEFAULT 'gastro';
