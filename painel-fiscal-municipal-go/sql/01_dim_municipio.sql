-- Dimensão de município com faixa de porte (para comparação entre pares)
CREATE OR REPLACE TABLE dim_municipio AS
SELECT cod_ibge::INT AS cod_ibge, ente, regiao, uf, capital, populacao::INT AS populacao,
  CASE WHEN populacao::INT < 5000  THEN '1 - até 5 mil'
       WHEN populacao::INT < 10000 THEN '2 - 5 a 10 mil'
       WHEN populacao::INT < 20000 THEN '3 - 10 a 20 mil'
       WHEN populacao::INT < 50000 THEN '4 - 20 a 50 mil'
       ELSE '5 - acima de 50 mil' END AS porte
FROM read_parquet('${RAW_DIR}/entes_go.parquet');
