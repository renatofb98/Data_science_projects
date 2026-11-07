-- Participação de saúde, educação, assistência e administração na despesa liquidada total
CREATE OR REPLACE VIEW vw_funcoes_chave AS
WITH tot AS (
  SELECT cod_ibge, exercicio, MAX(CASE WHEN coluna='Despesas Liquidadas' THEN valor END) AS liquidada_total
  FROM stg_dca
  WHERE anexo='DCA-Anexo I-E' AND conta='Despesas Exceto Intraorçamentárias'
  GROUP BY cod_ibge, exercicio
), f AS (
  SELECT cod_ibge, exercicio,
    SUM(CASE WHEN funcao_cod='10' THEN liquidada END) AS saude,
    SUM(CASE WHEN funcao_cod='12' THEN liquidada END) AS educacao,
    SUM(CASE WHEN funcao_cod='08' THEN liquidada END) AS assistencia,
    SUM(CASE WHEN funcao_cod='04' THEN liquidada END) AS administracao
  FROM vw_despesa_funcao GROUP BY cod_ibge, exercicio
)
SELECT t.cod_ibge, t.exercicio, m.ente, m.porte, t.liquidada_total,
  f.saude, f.educacao, f.assistencia, f.administracao,
  f.saude / NULLIF(t.liquidada_total,0)         AS saude_pct,
  f.educacao / NULLIF(t.liquidada_total,0)      AS educacao_pct,
  f.assistencia / NULLIF(t.liquidada_total,0)   AS assistencia_pct,
  f.administracao / NULLIF(t.liquidada_total,0) AS administracao_pct
FROM tot t JOIN f USING (cod_ibge, exercicio) JOIN dim_municipio m USING (cod_ibge);
