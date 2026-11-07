-- Fato: despesa por função de governo (empenhada, liquidada e paga)
CREATE OR REPLACE TABLE fato_despesa_funcao AS
SELECT cod_ibge, exercicio, funcao_cod, empenhada, liquidada, paga FROM vw_despesa_funcao;
