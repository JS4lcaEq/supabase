CREATE OR REPLACE FUNCTION public.api_edge_delete(p_pid bigint, p_cid bigint)
RETURNS void
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
  v_pid bigint;
BEGIN
  IF p_pid IS NULL OR p_cid IS NULL THEN
    RAISE EXCEPTION 'p_pid and p_cid must be not null' USING ERRCODE = '22023';
  END IF;

  DELETE FROM public.edges
  WHERE edges.pid = p_pid
    AND edges.cid = p_cid
  RETURNING edges.pid INTO v_pid;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'edge %-% not found', p_pid, p_cid USING ERRCODE = '22023';
  END IF;
END;
$function$;

COMMENT ON FUNCTION public.api_edge_delete(bigint, bigint) IS
$comment$
WRITE
run: SELECT public.api_edge_delete(p_pid => 1, p_cid => 2);
Удаляет ребро по pid и cid; узлы не трогает.
$comment$;

GRANT EXECUTE ON FUNCTION public.api_edge_delete(bigint, bigint) TO anon;
