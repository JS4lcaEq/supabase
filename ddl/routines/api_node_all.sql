CREATE OR REPLACE FUNCTION public.api_node_all()
RETURNS TABLE(id bigint, nm character varying)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $function$
SELECT id, nm
FROM public.nodes
ORDER BY id
LIMIT 100000;
$function$;

COMMENT ON FUNCTION public.api_node_all() IS
$comment$
run: SELECT * FROM public.api_node_all();
Узлы по id, не больше 100000.
$comment$;

GRANT EXECUTE ON FUNCTION public.api_node_all() TO anon;
