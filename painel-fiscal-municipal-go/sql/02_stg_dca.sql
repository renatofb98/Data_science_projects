-- DCA (anexos I-C receitas, I-D despesas, I-E despesas por função), todos os exercícios coletados
CREATE OR REPLACE TABLE stg_dca AS
SELECT exercicio::INT AS exercicio, cod_ibge::INT AS cod_ibge, anexo, rotulo, coluna, cod_conta, conta, valor
FROM read_parquet('${RAW_DIR}/dca_20*.parquet');
