CREATE OR REPLACE FUNCTION public.edge_get(p_pid bigint, p_cid bigint)
RETURNS TABLE(pid bigint, cid bigint)
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
SET search_path = public
AS $function$
BEGIN
  IF p_pid IS NULL OR p_cid IS NULL THEN
    RAISE EXCEPTION 'p_pid and p_cid must be not null' USING ERRCODE = '22023';
  END IF;

  RETURN QUERY
  SELECT e.pid, e.cid
  FROM public.edges e
  WHERE e.pid = p_pid
    AND e.cid = p_cid;
END;
$function$;

COMMENT ON FUNCTION public.edge_get(bigint, bigint) IS
$comment$
run: SELECT * FROM public.edge_get(p_pid => 1, p_cid => 2);
Одно ребро по pid и cid.
$comment$;

GRANT EXECUTE ON FUNCTION public.edge_get(bigint, bigint) TO anon;
