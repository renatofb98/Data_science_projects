-- Qualidade: valida a RCL do RGF contra a receita do DCA (segunda fonte). Sinaliza, não exclui.
-- "A revisar": razão RGF/DCA fora de 0,75-1,20 ou pessoal > 100% da RCL. Cortes provisórios.
-- atencao_qualidade: desvio > 15% da razão mediana do município (não altera o status).
CREATE OR REPLACE VIEW vw_pessoal_qualidade AS
WITH base AS (
  SELECT p.*, r.rcl_dca_estimada,
    p.rcl_ajustada / NULLIF(r.rcl_dca_estimada, 0) AS razao_rgf_dca
  FROM vw_pessoal_status p
  LEFT JOIN vw_receitas r ON r.cod_ibge = p.cod_ibge AND r.exercicio = p.exercicio
), b2 AS (
  SELECT *, MEDIAN(razao_rgf_dca) OVER (PARTITION BY cod_ibge) AS razao_mediana_mun FROM base
)
SELECT *,
  rcl_ajustada / populacao AS rcl_pc,
  razao_rgf_dca / NULLIF(razao_mediana_mun, 0) AS razao_rel,
  (razao_rgf_dca IS NULL) AS sem_validacao_dca,
  (dtp_pct > 100) AS flag_pct_impossivel,
  (razao_rgf_dca < 0.75 OR razao_rgf_dca > 1.20) AS flag_razao_fora,
  (ABS(razao_rgf_dca / NULLIF(razao_mediana_mun, 0) - 1) > 0.15) AS atencao_qualidade,
  CASE WHEN dtp_pct > 100 THEN 'Pessoal acima de 100% da RCL'
       WHEN razao_rgf_dca < 0.75 THEN 'RCL do RGF muito abaixo da receita do DCA'
       WHEN razao_rgf_dca > 1.20 THEN 'RCL do RGF muito acima da receita do DCA'
  END AS motivo_revisao,
  CASE WHEN dtp_pct > 100 OR razao_rgf_dca < 0.75 OR razao_rgf_dca > 1.20
       THEN '0 - A revisar (dado atípico)' ELSE status END AS status_final
FROM b2;
