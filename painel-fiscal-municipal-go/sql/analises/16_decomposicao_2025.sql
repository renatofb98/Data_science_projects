-- Em 2025, os municípios acima do limite: a folha subiu ou a receita caiu?
WITH t AS (
  SELECT ente, exercicio, status_final, dtp_pct, rcl_ajustada, dtp_valor,
    LAG(status_final) OVER w AS st_ant, LAG(rcl_ajustada) OVER w AS rcl_ant,
    LAG(dtp_valor) OVER w AS dtp_ant, LAG(dtp_pct) OVER w AS pct_ant
  FROM vw_pessoal_qualidade
  WINDOW w AS (PARTITION BY cod_ibge ORDER BY exercicio)
)
SELECT ente, st_ant, ROUND(pct_ant,1) AS pct_ant, ROUND(dtp_pct,1) AS pct_2025,
  ROUND(100*(rcl_ajustada/rcl_ant-1),1) AS rcl_var_pct,
  ROUND(100*(dtp_valor/dtp_ant-1),1) AS folha_var_pct
FROM t WHERE exercicio = 2025 AND status_final LIKE '4%'
ORDER BY rcl_var_pct;
