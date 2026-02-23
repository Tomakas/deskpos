-- Add new values to the unit_type enum: kg, cl, l, mm, cm, min, h
ALTER TYPE unit_type ADD VALUE IF NOT EXISTS 'kg'  AFTER 'g';
ALTER TYPE unit_type ADD VALUE IF NOT EXISTS 'cl'  AFTER 'ml';
ALTER TYPE unit_type ADD VALUE IF NOT EXISTS 'l'   AFTER 'cl';
ALTER TYPE unit_type ADD VALUE IF NOT EXISTS 'mm'  AFTER 'l';
ALTER TYPE unit_type ADD VALUE IF NOT EXISTS 'cm'  AFTER 'mm';
ALTER TYPE unit_type ADD VALUE IF NOT EXISTS 'min' AFTER 'm';
ALTER TYPE unit_type ADD VALUE IF NOT EXISTS 'h'   AFTER 'min';
