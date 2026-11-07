-- Variação anual mediana: RCL ajustada x despesa com pessoal (exclui dados atípicos)
WITH x AS (
  SELECT cod_ibge, exercicio, rcl_ajustada, dtp_valor, status_final,
    LAG(exercicio)    OVER w AS ano_ant,
    LAG(rcl_ajustada) OVER w AS rcl_ant,
    LAG(dtp_valor)    OVER w AS dtp_ant,
    LAG(status_final) OVER w AS st_ant
  FROM vw_pessoal_qualidade
  WINDOW w AS (PARTITION BY cod_ibge ORDER BY exercicio)
)
SELECT exercicio, COUNT(*) AS n,
  ROUND(100*quantile_cont(rcl_ajustada/rcl_ant - 1, 0.5), 1) AS rcl_var_mediana_pct,
  ROUND(100*quantile_cont(dtp_valor/dtp_ant - 1, 0.5), 1)    AS dtp_var_mediana_pct
FROM x
WHERE ano_ant = exercicio - 1 AND status_final NOT LIKE '0%' AND st_ant NOT LIKE '0%'
GROUP BY 1 ORDER BY 1;
