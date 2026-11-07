-- Qualidade: sinaliza (sem excluir) dados atípicos. Critério provisório.
CREATE OR REPLACE VIEW vw_pessoal_qualidade AS
SELECT *,
  rcl_ajustada / populacao AS rcl_pc,
  MEDIAN(rcl_ajustada) OVER (PARTITION BY cod_ibge) AS rcl_mediana_mun,
  rcl_ajustada / NULLIF(MEDIAN(rcl_ajustada) OVER (PARTITION BY cod_ibge), 0) AS rcl_rel,
  (dtp_pct > 100) AS flag_pct_impossivel,
  (rcl_ajustada < 0.6 * MEDIAN(rcl_ajustada) OVER (PARTITION BY cod_ibge)) AS flag_rcl_queda,
  CASE WHEN dtp_pct > 100
         OR rcl_ajustada < 0.6 * MEDIAN(rcl_ajustada) OVER (PARTITION BY cod_ibge)
       THEN '0 - A revisar (dado atípico)' ELSE status END AS status_final
FROM vw_pessoal_status;
