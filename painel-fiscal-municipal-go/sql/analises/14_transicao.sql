-- Matriz de transição de status entre anos consecutivos
WITH t AS (
  SELECT cod_ibge, exercicio, status_final,
    LAG(status_final) OVER (PARTITION BY cod_ibge ORDER BY exercicio) AS st_ant
  FROM vw_pessoal_qualidade
)
SELECT exercicio, st_ant AS de, status_final AS para, COUNT(*) AS n
FROM t WHERE st_ant IS NOT NULL
GROUP BY 1,2,3 ORDER BY 1,2,3;
