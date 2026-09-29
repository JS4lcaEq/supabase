CREATE OR REPLACE FUNCTION public.edge_add(p_pid bigint, p_cid bigint)
RETURNS TABLE(pid bigint, cid bigint)
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = public
AS $function$
BEGIN
  IF p_pid IS NULL OR p_cid IS NULL THEN
    RAISE EXCEPTION 'p_pid and p_cid must be not null' USING ERRCODE = '22023';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.edges e
    WHERE e.pid = p_pid
      AND e.cid = p_cid
  ) THEN
    RAISE EXCEPTION 'edge %-% already exists', p_pid, p_cid USING ERRCODE = '22023';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.nodes n WHERE n.id = p_pid) THEN
    RAISE EXCEPTION 'node % not found', p_pid USING ERRCODE = '22023';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.nodes n WHERE n.id = p_cid) THEN
    RAISE EXCEPTION 'node % not found', p_cid USING ERRCODE = '22023';
  END IF;

  RETURN QUERY
  INSERT INTO public.edges (pid, cid)
  VALUES (p_pid, p_cid)
  RETURNING edges.pid, edges.cid;
END;
$function$;

COMMENT ON FUNCTION public.edge_add(bigint, bigint) IS
$comment$
WRITE
run: SELECT * FROM public.edge_add(p_pid => 1, p_cid => 2);
Добавляет ребро pid-cid; повтор и null запрещены.
$comment$;

GRANT EXECUTE ON FUNCTION public.edge_add(bigint, bigint) TO anon;
