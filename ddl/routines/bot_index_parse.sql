CREATE OR REPLACE FUNCTION public.bot_index_parse(p_comment text)
RETURNS TABLE(writes boolean, run text, purpose text)
LANGUAGE sql
IMMUTABLE
AS $function$
WITH lines AS (
  SELECT ARRAY(
    SELECT btrim(x)
    FROM unnest(string_to_array(coalesce(p_comment, ''), E'\n')) AS x
    WHERE btrim(x) <> ''
  ) AS ln
)
SELECT
  (ln[1] = 'WRITE') AS writes,
  CASE
    WHEN ln[1] = 'WRITE' THEN nullif(substring(ln[2] FROM '^run:[[:space:]]*(.*)$'), '')
    ELSE nullif(substring(ln[1] FROM '^run:[[:space:]]*(.*)$'), '')
  END AS run,
  CASE
    WHEN ln[1] = 'WRITE' THEN nullif(ln[3], '')
    WHEN ln[1] LIKE 'run:%' THEN nullif(ln[2], '')
    ELSE NULL
  END AS purpose
FROM lines;
$function$;

COMMENT ON FUNCTION public.bot_index_parse(text) IS
$comment$
run: SELECT * FROM public.bot_index_parse(p_comment => NULL);
Разбирает текст комментария на writes, run и purpose.
$comment$;