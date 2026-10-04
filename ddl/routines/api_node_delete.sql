CREATE OR REPLACE FUNCTION public.api_node_delete(p_id bigint)
RETURNS void
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
  v_id bigint;
BEGIN
  DELETE FROM public.nodes
  WHERE nodes.id = p_id
  RETURNING nodes.id INTO v_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'node % not found', p_id USING ERRCODE = '22023';
  END IF;
END;
$function$;

COMMENT ON FUNCTION public.api_node_delete(bigint) IS
$comment$
WRITE
run: SELECT public.api_node_delete(p_id => 1);
Удаляет узел по id; рёбра уходят каскадом, дети остаются.
$comment$;

GRANT EXECUTE ON FUNCTION public.api_node_delete(bigint) TO anon;
