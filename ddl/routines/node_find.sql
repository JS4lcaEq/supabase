CREATE OR REPLACE FUNCTION public.node_find(p_mask varchar)
RETURNS TABLE(id bigint, nm varchar)
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
SET search_path = public
AS $function$
DECLARE
  v_mask varchar;
BEGIN
  IF p_mask IS NULL OR btrim(p_mask) = '' THEN
    RAISE EXCEPTION 'p_mask must be not null and not blank' USING ERRCODE = '22023';
  END IF;

  v_mask := replace(replace(replace(p_mask, '\', '\\'), '%', '\%'), '_', '\_');

  RETURN QUERY
  SELECT n.id, n.nm
  FROM public.nodes n
  WHERE n.nm LIKE ('%' || v_mask || '%')
  ORDER BY n.id
  LIMIT 50;
END;
$function$;

COMMENT ON FUNCTION public.node_find(varchar) IS
$comment$
run: SELECT * FROM public.node_find(p_mask => 'Node_0001');
Узлы, в имени которых есть образец; не больше 50, по id.
$comment$;

GRANT EXECUTE ON FUNCTION public.node_find(varchar) TO anon;
