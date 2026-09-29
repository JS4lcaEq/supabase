CREATE OR REPLACE FUNCTION public.node_get(p_id bigint)
RETURNS TABLE(id bigint, nm character varying)
LANGUAGE plpgsql
STABLE
SET search_path = public
AS $function$
BEGIN
  RETURN QUERY
  SELECT n.id, n.nm
  FROM public.nodes n
  WHERE n.id = p_id;
END;
$function$;

COMMENT ON FUNCTION public.node_get(bigint) IS
$comment$
run: SELECT * FROM public.node_get(p_id => 1);
Один узел по id.
$comment$;

GRANT EXECUTE ON FUNCTION public.node_get(bigint) TO anon;
