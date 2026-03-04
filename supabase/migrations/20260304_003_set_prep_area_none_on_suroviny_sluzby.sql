-- ============================================================================
-- Migration: 20260304_003_set_prep_area_none_on_suroviny_sluzby
-- Description: Set prep_area to "none" on cat:suroviny and cat:sluzby seed data
--              so their items don't route to kitchen/bar prep areas.
-- ============================================================================

-- cs/gastro
UPDATE seed_demo_data SET data = jsonb_set(data::jsonb, '{prep_area}', '"none"')
  WHERE mode = 'gastro' AND ref IN ('cat:suroviny', 'cat:sluzby') AND locale = 'cs';

-- en/gastro
UPDATE seed_demo_data SET data = jsonb_set(data::jsonb, '{prep_area}', '"none"')
  WHERE mode = 'gastro' AND ref IN ('cat:suroviny', 'cat:sluzby') AND locale = 'en';
