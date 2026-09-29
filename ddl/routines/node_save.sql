CREATE OR REPLACE FUNCTION public.node_save(p_id bigint, p_nm character varying)
RETURNS TABLE(id bigint, nm character varying)
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = public
AS $function$
BEGIN
  IF p_nm IS NULL OR btrim(p_nm) = '' THEN
    RAISE EXCEPTION 'p_nm must be not null and not blank' USING ERRCODE = '22023';
  END IF;

  IF p_id IS NULL THEN
    RETURN QUERY
    INSERT INTO public.nodes (nm)
    VALUES (p_nm)
    RETURNING nodes.id, nodes.nm;
    RETURN;
  END IF;

  RETURN QUERY
  UPDATE public.nodes
  SET nm = p_nm
  WHERE nodes.id = p_id
  RETURNING nodes.id, nodes.nm;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'node % not found', p_id USING ERRCODE = '22023';
  END IF;
END;
$function$;

COMMENT ON FUNCTION public.node_save(bigint, character varying) IS
$comment$
WRITE
run: SELECT * FROM public.node_save(p_id => NULL, p_nm => 'Node');
Вставляет узел, если id равен null, иначе меняет имя.
$comment$;

GRANT EXECUTE ON FUNCTION public.node_save(bigint, character varying) TO anon;
