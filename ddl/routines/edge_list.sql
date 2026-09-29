CREATE OR REPLACE FUNCTION public.edge_list(p_pid bigint)
RETURNS TABLE(pid bigint, cid bigint)
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
SET search_path = public
AS $function$
BEGIN
  IF p_pid IS NULL THEN
    RAISE EXCEPTION 'p_pid must be not null' USING ERRCODE = '22023';
  END IF;

  RETURN QUERY
  SELECT e.pid, e.cid
  FROM public.edges e
  WHERE e.pid = p_pid
  ORDER BY e.cid;
END;
$function$;

COMMENT ON FUNCTION public.edge_list(bigint) IS
$comment$
run: SELECT * FROM public.edge_list(p_pid => 1);
Прямые рёбра узла по pid.
$comment$;

GRANT EXECUTE ON FUNCTION public.edge_list(bigint) TO anon;
