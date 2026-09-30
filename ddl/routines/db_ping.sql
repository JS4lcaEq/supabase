CREATE OR REPLACE FUNCTION public.db_ping()
RETURNS text
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $function$
  SELECT 'PostgreSQL ' || current_setting('server_version') || ' ' || to_char(now() AT TIME ZONE 'Europe/Moscow', 'YYYY-MM-DD HH24:MI:SS') || ' MSK';
$function$;

COMMENT ON FUNCTION public.db_ping() IS
$comment$
run: SELECT public.db_ping();
Версия базы и текущее время одной строкой.
$comment$;

GRANT EXECUTE ON FUNCTION public.db_ping() TO anon;
