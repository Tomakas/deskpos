CREATE OR REPLACE FUNCTION public.lookup_display_device_by_code(lookup_code text)
RETURNS json
SECURITY DEFINER
SET search_path = public
LANGUAGE sql
AS $$
  SELECT to_json(t) FROM (
    SELECT company_id, name, welcome_text, type
    FROM display_devices
    WHERE code = lookup_code
      AND is_active = true
      AND deleted_at IS NULL
    LIMIT 1
  ) t;
$$;

GRANT EXECUTE ON FUNCTION public.lookup_display_device_by_code(text) TO anon;
GRANT EXECUTE ON FUNCTION public.lookup_display_device_by_code(text) TO authenticated;
