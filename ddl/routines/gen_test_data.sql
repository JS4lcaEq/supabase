CREATE OR REPLACE PROCEDURE public.gen_test_data(IN p_deep integer, IN p_length integer)
LANGUAGE plpgsql
AS $procedure$
DECLARE
  v_lvl int;
  v_from bigint;
  v_to bigint;
  v_count bigint;
BEGIN
  IF p_deep IS NULL OR p_length IS NULL THEN
    RAISE EXCEPTION 'p_deep and p_length must be not null'
      USING ERRCODE = '22023';
  END IF;
  IF p_deep < 1 OR p_length < 1 THEN
    RAISE EXCEPTION 'p_deep (%) and p_length (%) must be >= 1', p_deep, p_length
      USING ERRCODE = '22023';
  END IF;

  TRUNCATE TABLE edges, nodes RESTART IDENTITY;

  INSERT INTO nodes (nm)
  SELECT 'Node_' || lpad(g::text, 6, '0')
  FROM generate_series(1, p_length) AS g;

  v_from := 1;
  v_to := p_length;

  FOR v_lvl IN 2..p_deep LOOP
    v_count := (v_to - v_from + 1) * p_length;

    INSERT INTO nodes (nm)
    SELECT 'Node_' || lpad((v_to + g)::text, 6, '0')
    FROM generate_series(1, v_count) AS g;

    INSERT INTO edges (pid, cid)
    SELECT p.id, v_to + (p.id - v_from) * p_length + c
    FROM nodes p
    CROSS JOIN generate_series(1, p_length) AS c
    WHERE p.id BETWEEN v_from AND v_to;

    v_from := v_to + 1;
    v_to := v_to + v_count;
  END LOOP;
END;
$procedure$;

COMMENT ON PROCEDURE public.gen_test_data(integer, integer) IS
$comment$
WRITE
run: CALL gen_test_data(p_deep => 3, p_length => 3);
Строит дерево узлов и рёбер и заменяет текущие данные.
$comment$;

CREATE OR REPLACE PROCEDURE public.gen_test_data(IN p_deep integer, IN p_length integer, IN p_start bigint)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $procedure$
DECLARE
  v_lvl integer;
  v_parents bigint[];
  v_next bigint[];
  v_parent bigint;
  v_child bigint;
  v_i integer;
BEGIN
  IF p_deep IS NULL OR p_length IS NULL THEN
    RAISE EXCEPTION 'p_deep and p_length must be not null'
      USING ERRCODE = '22023';
  END IF;
  IF p_deep < 1 OR p_length < 1 THEN
    RAISE EXCEPTION 'p_deep (%) and p_length (%) must be >= 1', p_deep, p_length
      USING ERRCODE = '22023';
  END IF;
  IF p_start IS NULL THEN
    RAISE EXCEPTION 'p_start must be not null'
      USING ERRCODE = '22023';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.nodes n WHERE n.id = p_start) THEN
    RAISE EXCEPTION 'p_start (%) not found', p_start
      USING ERRCODE = '22023';
  END IF;

  WITH RECURSIVE tree AS (
    SELECT e.cid AS node_id, ARRAY[p_start, e.cid] AS id_path
    FROM public.edges e
    WHERE e.pid = p_start
    UNION ALL
    SELECT e.cid, t.id_path || e.cid
    FROM tree t
    JOIN public.edges e ON e.pid = t.node_id
    WHERE NOT (e.cid = ANY (t.id_path))
  )
  DELETE FROM public.nodes n
  USING (SELECT DISTINCT node_id FROM tree) d
  WHERE n.id = d.node_id;

  PERFORM setval(
    pg_get_serial_sequence('public.nodes', 'id'),
    COALESCE((SELECT max(id) FROM public.nodes), 0) + 1,
    false
  );

  v_parents := ARRAY[p_start];

  FOR v_lvl IN 2..p_deep LOOP
    v_next := ARRAY[]::bigint[];
    FOREACH v_parent IN ARRAY v_parents LOOP
      FOR v_i IN 1..p_length LOOP
        INSERT INTO public.nodes (nm)
        VALUES ('')
        RETURNING id INTO v_child;

        UPDATE public.nodes
        SET nm = 'Node_' || lpad(v_child::text, 6, '0')
        WHERE id = v_child;

        INSERT INTO public.edges (pid, cid)
        VALUES (v_parent, v_child);

        v_next := v_next || v_child;
      END LOOP;
    END LOOP;
    v_parents := v_next;
  END LOOP;
END;
$procedure$;

COMMENT ON PROCEDURE public.gen_test_data(integer, integer, bigint) IS
$comment$
WRITE
run: CALL public.gen_test_data(p_deep => 2, p_length => 2, p_start => 1);
Чистит КАСКАДНО ВСЕХ потомков узла p_start и строит от него новое поддерево тестовых данных; старые данные ближе к корню от этого узла не трогает.
$comment$;

GRANT EXECUTE ON PROCEDURE public.gen_test_data(integer, integer, bigint) TO anon;
