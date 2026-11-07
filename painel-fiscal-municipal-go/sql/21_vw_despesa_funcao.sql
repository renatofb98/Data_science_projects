-- Despesa por função (nível função, não subfunção): empenhada, liquidada e paga
CREATE OR REPLACE VIEW vw_despesa_funcao AS
SELECT cod_ibge, exercicio,
  regexp_extract(conta, '^([0-9]{2}) - ', 1)      AS funcao_cod,
  regexp_extract(conta, '^[0-9]{2} - (.*)$', 1)   AS funcao_nome,
  MAX(CASE WHEN coluna='Despesas Empenhadas' THEN valor END) AS empenhada,
  MAX(CASE WHEN coluna='Despesas Liquidadas' THEN valor END) AS liquidada,
  MAX(CASE WHEN coluna='Despesas Pagas'      THEN valor END) AS paga
FROM stg_dca
WHERE anexo='DCA-Anexo I-E' AND regexp_matches(conta, '^[0-9]{2} - ')
GROUP BY cod_ibge, exercicio, funcao_cod, funcao_nome;
