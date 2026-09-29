CREATE OR REPLACE FUNCTION public.tree_view(p_root_id bigint, p_from bigint, p_to bigint)
RETURNS TABLE(path character varying, level integer, node_id bigint, node_nm character varying, nn bigint, total bigint)
LANGUAGE plpgsql
STABLE
AS $function$
BEGIN
  IF p_from IS NULL OR p_to IS NULL THEN
    RAISE EXCEPTION 'p_from and p_to must be not null' USING ERRCODE = '22023';
  END IF;
  IF p_from < 1 OR p_to < p_from THEN
    RAISE EXCEPTION 'window p_from (%) .. p_to (%) is invalid', p_from, p_to USING ERRCODE = '22023';
  END IF;

  RETURN QUERY
  WITH RECURSIVE tree AS (
    SELECT n.id AS node_id, n.nm AS node_nm, 1 AS lvl,
      n.id::text::character varying AS path, ARRAY[n.id] AS id_path
    FROM public.nodes n
    WHERE (p_root_id IS NOT NULL AND n.id = p_root_id)
       OR (p_root_id IS NULL AND NOT EXISTS (SELECT 1 FROM public.edges e WHERE e.cid = n.id))
    UNION ALL
    SELECT c.id, c.nm, t.lvl + 1,
      (t.path || '|' || c.id::text)::character varying, t.id_path || c.id
    FROM tree t
    JOIN public.edges e ON e.pid = t.node_id
    JOIN public.nodes c ON c.id = e.cid
    WHERE NOT (c.id = ANY (t.id_path))
  ),
  numbered AS (
    SELECT tree.path, tree.lvl, tree.node_id, tree.node_nm,
      row_number() OVER (ORDER BY tree.path) AS rn,
      count(*) OVER () AS cnt
    FROM tree
  )
  SELECT numbered.path, numbered.lvl, numbered.node_id, numbered.node_nm, numbered.rn, numbered.cnt
  FROM numbered
  WHERE numbered.rn BETWEEN p_from AND p_to
  ORDER BY numbered.path;
END;
$function$;

COMMENT ON FUNCTION public.tree_view(bigint, bigint, bigint) IS
$comment$
run: SELECT * FROM public.tree_view(p_root_id => null, p_from => 1, p_to => 50);
Страница дерева по path, с номером строки и общим числом узлов.
$comment$;

CREATE OR REPLACE FUNCTION public.tree_view(p_root_id bigint, p_mask character varying, p_from bigint, p_to bigint)
RETURNS TABLE(path character varying, level integer, node_id bigint, node_nm character varying, nn bigint, total bigint)
LANGUAGE plpgsql
STABLE
AS $function$
BEGIN
  IF p_from IS NULL OR p_to IS NULL THEN
    RAISE EXCEPTION 'p_from and p_to must be not null' USING ERRCODE = '22023';
  END IF;
  IF p_from < 1 OR p_to < p_from THEN
    RAISE EXCEPTION 'window p_from (%) .. p_to (%) is invalid', p_from, p_to USING ERRCODE = '22023';
  END IF;

  RETURN QUERY
  WITH RECURSIVE
  matched AS (
    SELECT n.id AS node_id, n.nm AS node_nm
    FROM public.nodes n
    WHERE n.nm LIKE ('%' || p_mask || '%')
  ),
  up AS (
    SELECT m.node_id, m.node_nm, m.node_id AS seed, ARRAY[m.node_id] AS seen
    FROM matched m
    UNION ALL
    SELECT e.pid, p.nm, u.seed, u.seen || e.pid
    FROM up u
    JOIN public.edges e ON e.cid = u.node_id
    JOIN public.nodes p ON p.id = e.pid
    WHERE NOT (e.pid = ANY (u.seen))
      AND (p_root_id IS NULL OR u.node_id IS DISTINCT FROM p_root_id)
  ),
  valid_seed AS (
    SELECT DISTINCT u.seed FROM up u
    WHERE p_root_id IS NULL OR u.node_id = p_root_id
  ),
  include_ids AS (
    SELECT DISTINCT u.node_id FROM up u
    JOIN valid_seed v ON v.seed = u.seed
  ),
  tree AS (
    SELECT n.id AS node_id, n.nm AS node_nm, 1 AS lvl,
      n.id::text::character varying AS path, ARRAY[n.id] AS id_path
    FROM public.nodes n
    WHERE n.id IN (SELECT i.node_id FROM include_ids i)
      AND ((p_root_id IS NOT NULL AND n.id = p_root_id)
        OR (p_root_id IS NULL AND NOT EXISTS (SELECT 1 FROM public.edges e WHERE e.cid = n.id)))
    UNION ALL
    SELECT c.id, c.nm, t.lvl + 1,
      (t.path || '|' || c.id::text)::character varying, t.id_path || c.id
    FROM tree t
    JOIN public.edges e ON e.pid = t.node_id
    JOIN public.nodes c ON c.id = e.cid
    WHERE c.id IN (SELECT i.node_id FROM include_ids i)
      AND NOT (c.id = ANY (t.id_path))
  ),
  numbered AS (
    SELECT t.path, t.lvl, t.node_id, t.node_nm,
      row_number() OVER (ORDER BY t.path) AS rn,
      count(*) OVER () AS cnt
    FROM tree t
  )
  SELECT numbered.path, numbered.lvl, numbered.node_id, numbered.node_nm, numbered.rn, numbered.cnt
  FROM numbered
  WHERE numbered.rn BETWEEN p_from AND p_to
  ORDER BY numbered.path;
END;
$function$;

COMMENT ON FUNCTION public.tree_view(bigint, character varying, bigint, bigint) IS
$comment$
run: SELECT * FROM public.tree_view(p_root_id => null, p_mask => 'Node_1', p_from => 1, p_to => 50);
Страница путей к узлам, имя которых содержит маску.
$comment$;