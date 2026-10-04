CREATE OR REPLACE FUNCTION public.api_edge_delete_end(p_id bigint)
RETURNS void
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = public
AS $function$
BEGIN
  IF p_id IS NULL THEN
    RAISE EXCEPTION 'p_id must be not null' USING ERRCODE = '22023';
  END IF;

  DELETE FROM public.edges
  WHERE pid = p_id
     OR cid = p_id;
END;
$function$;

COMMENT ON FUNCTION public.api_edge_delete_end(bigint) IS
$comment$
WRITE
run: SELECT public.api_edge_delete_end(p_id => 1);
Удаляет рёбра, где узел стоит как pid или cid.
$comment$;

GRANT EXECUTE ON FUNCTION public.api_edge_delete_end(bigint) TO anon;
