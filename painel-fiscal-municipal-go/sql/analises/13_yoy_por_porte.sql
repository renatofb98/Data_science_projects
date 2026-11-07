-- % de municípios em que a folha cresceu mais que a RCL, por faixa de porte
WITH x AS (
  SELECT cod_ibge, exercicio, porte, rcl_ajustada, dtp_valor, status_final,
    LAG(exercicio) OVER w AS ano_ant, LAG(rcl_ajustada) OVER w AS rcl_ant,
    LAG(dtp_valor) OVER w AS dtp_ant, LAG(status_final) OVER w AS st_ant
  FROM vw_pessoal_qualidade
  WINDOW w AS (PARTITION BY cod_ibge ORDER BY exercicio)
)
SELECT exercicio, porte, COUNT(*) AS n,
  ROUND(100*AVG((dtp_valor/dtp_ant > rcl_ajustada/rcl_ant)::INT), 0) AS pct_folha_cresceu_mais
FROM x
WHERE ano_ant = exercicio - 1 AND status_final NOT LIKE '0%' AND st_ant NOT LIKE '0%'
GROUP BY 1,2 ORDER BY 1,2;
