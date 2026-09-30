DROP FUNCTION IF EXISTS public.db_ping();

CREATE FUNCTION public.db_ping()
RETURNS timestamp
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
  SELECT now() AT TIME ZONE 'Europe/Moscow';
$$;

COMMENT ON FUNCTION public.db_ping() IS
'run: SELECT public.db_ping();
Текущее время базы.';

GRANT EXECUTE ON FUNCTION public.db_ping() TO anon;
