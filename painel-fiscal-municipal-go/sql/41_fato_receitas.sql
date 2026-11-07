-- Fato: receitas por categoria, deduções e dependência de transferências
CREATE OR REPLACE TABLE fato_receitas AS
SELECT cod_ibge, exercicio, receita_total_bruta, rec_corrente_bruta, rec_corrente_deducoes,
  rec_tributaria_bruta, contribuicoes_bruta, transf_correntes_bruta, rec_capital_bruta, transf_capital_bruta,
  rcl_dca_estimada, dependencia_transf, peso_tributaria
FROM vw_receitas;
