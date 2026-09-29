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