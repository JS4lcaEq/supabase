CREATE OR REPLACE FUNCTION public.node_list(p_pid bigint)
RETURNS TABLE(id bigint, nm character varying)
LANGUAGE plpgsql
STABLE
SET search_path = public
AS $function$
BEGIN
  IF p_pid IS NULL THEN
    RETURN QUERY
    SELECT n.id, n.nm
    FROM public.nodes n
    WHERE NOT EXISTS (
      SELECT 1 FROM public.edges e WHERE e.cid = n.id
    )
    ORDER BY n.id;
  ELSE
    RETURN QUERY
    SELECT n.id, n.nm
    FROM public.nodes n
    JOIN public.edges e ON e.cid = n.id
    WHERE e.pid = p_pid
    ORDER BY n.id;
  END IF;
END;
$function$;

COMMENT ON FUNCTION public.node_list(bigint) IS
$comment$
run: SELECT * FROM public.node_list(p_pid => NULL);
Прямые дети узла по pid; если pid равен null, корни.
$comment$;

GRANT EXECUTE ON FUNCTION public.node_list(bigint) TO anon;
