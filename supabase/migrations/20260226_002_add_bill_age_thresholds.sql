-- Add configurable bill age color thresholds to company_settings.
-- These control the bill circle outline color on the floor map
-- and the relative-time text color in the bills list view.
ALTER TABLE company_settings
  ADD COLUMN bill_age_warning_minutes  integer NOT NULL DEFAULT 15,
  ADD COLUMN bill_age_danger_minutes   integer NOT NULL DEFAULT 30,
  ADD COLUMN bill_age_critical_minutes integer NOT NULL DEFAULT 45;
