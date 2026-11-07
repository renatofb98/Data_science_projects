-- Municípios com 2 ou mais anos acima do limite declarado
SELECT ente, porte, populacao,
  COUNT(*) FILTER (WHERE status_final LIKE '4%') AS anos_acima_limite,
  COUNT(*) FILTER (WHERE status_final LIKE '3%' OR status_final LIKE '4%') AS anos_prudencial_ou_pior
FROM vw_pessoal_qualidade
GROUP BY ente, porte, populacao
HAVING COUNT(*) FILTER (WHERE status_final LIKE '4%') >= 2
ORDER BY anos_acima_limite DESC;
