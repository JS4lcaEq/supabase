CREATE OR REPLACE FUNCTION public.tree_view_perf_compare()
RETURNS TABLE(time_count_ms bigint, time_var_ms bigint)
LANGUAGE plpgsql
AS $function$
DECLARE
  v_t0 timestamptz;
  v_t1 timestamptz;
  v_dummy bigint;
  v_total bigint;
BEGIN
  PERFORM 1 FROM public.nodes LIMIT 1;
  PERFORM 1 FROM public.edges LIMIT 1;

  v_t0 := clock_timestamp();
  SELECT count(*) INTO v_dummy
  FROM (
    WITH RECURSIVE tree AS (
      SELECT n.id AS node_id, n.nm AS node_nm, 1 AS lvl,
        n.id::text::character varying AS path, ARRAY[n.id] AS id_path
      FROM public.nodes n
      WHERE NOT EXISTS (SELECT 1 FROM public.edges e WHERE e.cid = n.id)
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
    WHERE numbered.rn BETWEEN 50 AND 100
    ORDER BY numbered.path
  ) q;
  v_t1 := clock_timestamp();
  time_count_ms := greatest(0, (extract(epoch FROM (v_t1 - v_t0)) * 1000)::bigint);

  v_t0 := clock_timestamp();
  WITH RECURSIVE tree AS (
    SELECT n.id AS node_id, n.nm AS node_nm, 1 AS lvl,
      n.id::text::character varying AS path, ARRAY[n.id] AS id_path
    FROM public.nodes n
    WHERE NOT EXISTS (SELECT 1 FROM public.edges e WHERE e.cid = n.id)
    UNION ALL
    SELECT c.id, c.nm, t.lvl + 1,
      (t.path || '|' || c.id::text)::character varying, t.id_path || c.id
    FROM tree t
    JOIN public.edges e ON e.pid = t.node_id
    JOIN public.nodes c ON c.id = e.cid
    WHERE NOT (c.id = ANY (t.id_path))
  )
  SELECT count(*) INTO v_total FROM tree;

  SELECT count(*) INTO v_dummy
  FROM (
    WITH RECURSIVE tree AS (
      SELECT n.id AS node_id, n.nm AS node_nm, 1 AS lvl,
        n.id::text::character varying AS path, ARRAY[n.id] AS id_path
      FROM public.nodes n
      WHERE NOT EXISTS (SELECT 1 FROM public.edges e WHERE e.cid = n.id)
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
        row_number() OVER (ORDER BY tree.path) AS rn
      FROM tree
    )
    SELECT numbered.path, numbered.lvl, numbered.node_id, numbered.node_nm, numbered.rn, v_total
    FROM numbered
    WHERE numbered.rn BETWEEN 50 AND 100
    ORDER BY numbered.path
  ) q;
  v_t1 := clock_timestamp();
  time_var_ms := greatest(0, (extract(epoch FROM (v_t1 - v_t0)) * 1000)::bigint);
  RETURN NEXT;
END;
$function$;

COMMENT ON FUNCTION public.tree_view_perf_compare() IS
$comment$
run: SELECT * FROM public.tree_view_perf_compare();
Сравнивает время страницы 50-100 для count(*) OVER () и для v_total.
$comment$;