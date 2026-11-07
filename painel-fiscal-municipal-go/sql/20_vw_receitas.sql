-- Receitas por categoria (valores brutos realizados) e dependência de transferências
CREATE OR REPLACE VIEW vw_receitas AS
WITH b AS (
  SELECT cod_ibge, exercicio,
    MAX(CASE WHEN cod_conta='ReceitasExcetoIntraOrcamentarias' AND coluna='Receitas Brutas Realizadas' THEN valor END) AS receita_total_bruta,
    MAX(CASE WHEN cod_conta='RO1.0.0.0.00.0.0' AND coluna='Receitas Brutas Realizadas' THEN valor END) AS rec_corrente_bruta,
    SUM(CASE WHEN cod_conta='RO1.0.0.0.00.0.0' AND coluna<>'Receitas Brutas Realizadas' THEN ABS(valor) END) AS rec_corrente_deducoes,
    MAX(CASE WHEN cod_conta='RO1.1.0.0.00.0.0' AND coluna='Receitas Brutas Realizadas' THEN valor END) AS rec_tributaria_bruta,
    MAX(CASE WHEN cod_conta='RO1.2.0.0.00.0.0' AND coluna='Receitas Brutas Realizadas' THEN valor END) AS contribuicoes_bruta,
    MAX(CASE WHEN cod_conta='RO1.7.0.0.00.0.0' AND coluna='Receitas Brutas Realizadas' THEN valor END) AS transf_correntes_bruta,
    MAX(CASE WHEN cod_conta='RO2.0.0.0.00.0.0' AND coluna='Receitas Brutas Realizadas' THEN valor END) AS rec_capital_bruta,
    MAX(CASE WHEN cod_conta='RO2.4.0.0.00.0.0' AND coluna='Receitas Brutas Realizadas' THEN valor END) AS transf_capital_bruta
  FROM stg_dca WHERE anexo='DCA-Anexo I-C'
  GROUP BY cod_ibge, exercicio
)
SELECT b.*, m.ente, m.populacao, m.porte,
  rec_corrente_bruta - COALESCE(rec_corrente_deducoes, 0) AS rcl_dca_estimada,
  (COALESCE(transf_correntes_bruta,0) + COALESCE(transf_capital_bruta,0)) / NULLIF(receita_total_bruta,0) AS dependencia_transf,
  rec_tributaria_bruta / NULLIF(receita_total_bruta,0) AS peso_tributaria
FROM b JOIN dim_municipio m USING (cod_ibge);
