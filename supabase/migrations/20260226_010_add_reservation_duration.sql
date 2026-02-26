ALTER TABLE reservations
  ADD COLUMN duration_minutes integer NOT NULL DEFAULT 90;
