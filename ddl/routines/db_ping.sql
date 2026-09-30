DROP FUNCTION IF EXISTS public.db_ping();

CREATE FUNCTION public.db_ping()
RETURNS integer
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$ SELECT extract(epoch FROM now())::integer; $$;

COMMENT ON FUNCTION public.db_ping() IS
'run: SELECT public.db_ping();
Текущее время базы в секундах.';

GRANT EXECUTE ON FUNCTION public.db_ping() TO anon;
