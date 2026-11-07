-- Dimensão de exercício (grão anual)
CREATE OR REPLACE TABLE dim_ano AS
SELECT DISTINCT exercicio::INT AS exercicio, make_date(exercicio::INT, 12, 31) AS data_fim_exercicio
FROM stg_rgf;
