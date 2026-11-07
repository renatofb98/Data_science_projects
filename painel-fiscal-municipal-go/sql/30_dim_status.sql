-- Dimensão de status (ordem e cor para o painel)
CREATE OR REPLACE TABLE dim_status AS
SELECT * FROM (VALUES
  (0, 'A revisar (dado atípico)', '#7F7F7F'),
  (1, 'Regular',         '#2E8B57'),
  (2, 'Alerta',          '#E0B000'),
  (3, 'Prudencial',      '#F28C28'),
  (4, 'Acima do limite', '#C0392B')
) AS t(status_cod, status_nome, cor_hex);
