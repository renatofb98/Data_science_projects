-- Fato: despesa com pessoal por município e ano, com qualidade e comparação com pares do mesmo porte
-- Pares: mediana e posição percentual calculadas sem os casos marcados como "A revisar"
CREATE OR REPLACE TABLE fato_pessoal AS
WITH v AS (
  SELECT cod_ibge, exercicio, porte, dtp_pct
  FROM vw_pessoal_qualidade WHERE status_final NOT LIKE '0%'
), r AS (
  SELECT cod_ibge, exercicio,
    PERCENT_RANK() OVER (PARTITION BY exercicio, porte ORDER BY dtp_pct) AS pct_rank_porte,
    MEDIAN(dtp_pct) OVER (PARTITION BY exercicio, porte) AS mediana_pares_dtp_pct,
    COUNT(*) OVER (PARTITION BY exercicio, porte) AS n_pares
  FROM v
)
SELECT q.cod_ibge, q.exercicio,
  CAST(LEFT(q.status_final, 1) AS INTEGER) AS status_cod,
  CAST(LEFT(q.status, 1) AS INTEGER)       AS status_declarado_cod,
  q.tipo_relatorio, q.periodicidade,
  q.rcl_ajustada, q.dtp_valor, q.dtp_pct,
  CASE WHEN q.status_final NOT LIKE '0%' THEN q.dtp_pct END AS dtp_pct_valido,
  q.alerta_pct, q.prudencial_pct, q.maximo_pct, q.maximo_valor, q.folga_rs,
  q.bruta_12m, q.inativos_12m, q.peso_inativos,
  q.rcl_dca_estimada, q.razao_rgf_dca, q.razao_mediana_mun,
  q.atencao_qualidade, q.motivo_revisao,
  r.pct_rank_porte, r.mediana_pares_dtp_pct, r.n_pares
FROM vw_pessoal_qualidade q
LEFT JOIN r ON r.cod_ibge = q.cod_ibge AND r.exercicio = q.exercicio;
