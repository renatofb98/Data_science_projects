-- Despesa com pessoal (LRF): pivota o formato longo do RGF em uma linha por município e período
CREATE OR REPLACE VIEW vw_pessoal AS
SELECT cod_ibge, exercicio, periodo, periodicidade, tipo_relatorio,
  MAX(CASE WHEN cod_conta='ReceitaCorrenteLiquidaAjustada' AND LOWER(coluna)='valor' THEN valor END) AS rcl_ajustada,
  MAX(CASE WHEN cod_conta='DespesaComPessoalTotal' AND LOWER(coluna)='valor' THEN valor END) AS dtp_valor,
  MAX(CASE WHEN cod_conta='DespesaComPessoalTotal' AND LOWER(coluna)='% sobre a rcl ajustada' THEN valor END) AS dtp_pct,
  MAX(CASE WHEN cod_conta='LimiteDeAlertaDespesaComPessoalTotal' AND LOWER(coluna)='% sobre a rcl ajustada' THEN valor END) AS alerta_pct,
  MAX(CASE WHEN cod_conta='LimitePrudencialDespesaComPessoalTotal' AND LOWER(coluna)='% sobre a rcl ajustada' THEN valor END) AS prudencial_pct,
  MAX(CASE WHEN cod_conta='LimiteMaximoDespesaComPessoalTotal' AND LOWER(coluna)='% sobre a rcl ajustada' THEN valor END) AS maximo_pct,
  MAX(CASE WHEN cod_conta='LimiteMaximoDespesaComPessoalTotal' AND LOWER(coluna)='valor' THEN valor END) AS maximo_valor,
  MAX(CASE WHEN cod_conta='DespesaComPessoalBruta' AND LOWER(coluna) LIKE 'total%' THEN valor END) AS bruta_12m,
  MAX(CASE WHEN cod_conta='DespesaComPessoalInativoEPensionistasBruta' AND LOWER(coluna) LIKE 'total%' THEN valor END) AS inativos_12m
FROM stg_rgf
GROUP BY cod_ibge, exercicio, periodo, periodicidade, tipo_relatorio;
