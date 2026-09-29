CREATE OR REPLACE VIEW public.bot_index AS
SELECT
  n.nspname AS schema,
  p.proname AS name,
  p.prokind AS kind,
  pg_get_function_identity_arguments(p.oid) AS args,
  b.writes,
  b.run,
  b.purpose
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
CROSS JOIN LATERAL public.bot_index_parse(obj_description(p.oid, 'pg_proc')) AS b
WHERE n.nspname = 'public'
  AND p.prokind IN ('f', 'p');