-- Remove 'cancelled' from prep_status enum — use only 'voided' as terminal status.
-- Both statuses were treated identically in all reporting, totals, and sync.
-- Having two indistinguishable terminal states was confusing for users.

-- Step 1: Migrate existing cancelled → voided
UPDATE orders SET status = 'voided' WHERE status = 'cancelled';
UPDATE order_items SET status = 'voided' WHERE status = 'cancelled';

-- Step 2: Drop defaults before type swap
ALTER TABLE orders ALTER COLUMN status DROP DEFAULT;
ALTER TABLE order_items ALTER COLUMN status DROP DEFAULT;

-- Step 3: Replace PG enum type (cannot DROP VALUE from enum)
CREATE TYPE prep_status_new AS ENUM ('created', 'ready', 'delivered', 'voided');

ALTER TABLE orders ALTER COLUMN status TYPE prep_status_new
  USING status::text::prep_status_new;
ALTER TABLE order_items ALTER COLUMN status TYPE prep_status_new
  USING status::text::prep_status_new;

DROP TYPE prep_status;
ALTER TYPE prep_status_new RENAME TO prep_status;

-- Step 4: Restore defaults
ALTER TABLE orders ALTER COLUMN status SET DEFAULT 'created'::prep_status;
ALTER TABLE order_items ALTER COLUMN status SET DEFAULT 'created'::prep_status;

-- Step 5: Patch create_demo_company — replace 'cancelled' with 'voided' in prep_status CASE.
-- Uses pg_get_functiondef() to preserve the full signature, SET clauses, and body.
DO $$
DECLARE
  v_def text;
  v_oid oid;
BEGIN
  SELECT p.oid INTO v_oid
  FROM pg_proc p
  JOIN pg_namespace n ON n.oid = p.pronamespace
  WHERE p.proname = 'create_demo_company'
    AND n.nspname = 'public';

  IF v_oid IS NOT NULL THEN
    v_def := pg_get_functiondef(v_oid);
    v_def := replace(v_def, '''cancelled'' THEN ''cancelled''', '''cancelled'' THEN ''voided''');
    EXECUTE v_def;
  END IF;
END
$$;
