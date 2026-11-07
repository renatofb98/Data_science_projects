-- Dimensão de função de governo
CREATE OR REPLACE TABLE dim_funcao AS
SELECT funcao_cod, MIN(funcao_nome) AS funcao_nome FROM vw_despesa_funcao GROUP BY funcao_cod;
