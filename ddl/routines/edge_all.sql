CREATE OR REPLACE FUNCTION public.edge_all()
RETURNS TABLE(pid bigint, cid bigint)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $function$
SELECT pid, cid
FROM public.edges
ORDER BY pid, cid
LIMIT 100000;
$function$;

COMMENT ON FUNCTION public.edge_all() IS
$comment$
run: SELECT * FROM public.edge_all();
Рёбра по pid и cid, не больше 100000.
$comment$;

GRANT EXECUTE ON FUNCTION public.edge_all() TO anon;
