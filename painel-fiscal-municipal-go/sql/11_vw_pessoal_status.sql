-- Classificação conforme os limites declarados (alerta 90%, prudencial 95%, máximo)
CREATE OR REPLACE VIEW vw_pessoal_status AS
SELECT p.*, m.ente, m.populacao, m.porte,
  maximo_valor - dtp_valor AS folga_rs,
  inativos_12m / NULLIF(bruta_12m, 0) AS peso_inativos,
  CASE WHEN dtp_pct >= maximo_pct THEN '4 - Acima do limite'
       WHEN dtp_pct >= prudencial_pct THEN '3 - Prudencial'
       WHEN dtp_pct >= alerta_pct THEN '2 - Alerta'
       ELSE '1 - Regular' END AS status
FROM vw_pessoal p JOIN dim_municipio m USING (cod_ibge);
