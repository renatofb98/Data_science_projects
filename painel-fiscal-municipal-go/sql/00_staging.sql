-- RGF: une o padrão (Anexo 01) e o simplificado (municípios < 50 mil hab. que optaram)
CREATE OR REPLACE TABLE stg_rgf AS
SELECT *, 'Padrão' AS tipo_relatorio FROM read_parquet('${RAW_DIR}/rgf_20*.parquet')
UNION ALL BY NAME
SELECT *, 'Simplificado' AS tipo_relatorio FROM read_parquet('${RAW_DIR}/rgf_simpl_*.parquet')
WHERE anexo = 'RGF-Anexo 01';
