# Painel fiscal dos municípios de Goiás

Projeto de portfólio: pipeline de dados (Python + SQL com DuckDB) e painel (Power BI, em desenvolvimento) sobre a situação fiscal dos 246 municípios goianos, a partir dos dados abertos do Tesouro Nacional (Siconfi).

**Status:** em desenvolvimento. Concluído: despesa com pessoal frente aos limites da LRF (2022 a 2025). Em andamento: receitas e despesa por função (DCA), modelo estrela e painel no Power BI.

## Perguntas que o projeto responde

- Quais municípios estão em alerta, no limite prudencial ou acima do limite de despesa com pessoal da LRF (alerta em 90%, prudencial em 95% e máximo de 54% da RCL ajustada para o Poder Executivo)?
- A situação melhora ou piora ao longo do tempo? A mudança vem da folha ou da receita?
- Como cada município se compara a pares de porte semelhante?
- (Em construção) Dependência de transferências e participação de saúde, educação e assistência social na despesa.

## Dados

- **Fonte:** API de dados abertos do Siconfi (apidatalake.tesouro.gov.br), endpoints `entes`, `rgf`, `dca` e `extrato_entregas`.
- **RGF (Relatório de Gestão Fiscal):** Anexo 01 para os municípios com relatório padrão e Anexo 06 (simplificado) conferido para os municípios com menos de 50 mil habitantes que optaram pelo formato simplificado.
- **Cobertura:** 246 municípios, exercícios de 2022 a 2025, fechamento do ano (3º quadrimestre; 2º semestre no formato simplificado). Apenas Poder Executivo.
- **DCA (Declaração de Contas Anuais):** coletado para 2025 (246 municípios); 2022 a 2024 em andamento.

## Arquitetura

Python (coleta pela API) -> arquivos Parquet -> DuckDB (modelagem em SQL) -> Power BI (em desenvolvimento).

    src/siconfi.py      coleta (paginação, tentativas, retomada por lote)
    src/build_db.py     executa os scripts sql/NN_*.sql in ordem
    sql/                staging, dimensão de município e views
    sql/analises/       consultas analíticas (não fazem parte do build)

## Como reproduzir

Testado no Google Colab.

    pip install -r requirements.txt
    # 1) coletar: funções em src/siconfi.py (get_all, municipios_go, coletar_rgf, coletar_rgf_simplificado, coletar_dca)
    # 2) salvar a lista de municípios de GO em RAW_DIR/entes_go.parquet
    # 3) montar o banco:
    #    from src.build_db import build; con = build(raw_dir="data/raw")

## Qualidade dos dados

Os dados são autodeclarados pelos municípios. O projeto sinaliza, e não corrige nem exclui, os casos atípicos.

- **Dados atípicos:** 7 casos (de 984 pares município-ano) tinham RCL ajustada incompatível, com despesa de pessoal acima de 100% da RCL. Ficam no status "A revisar (dado atípico)".
- **Validação contra uma segunda fonte:** nesses casos, a razão entre a RCL declarada no RGF e a receita corrente líquida estimada a partir do DCA fica entre 0,16 e 0,39. Nos mesmos municípios em anos normais, fica entre 0,88 e 1,00. Conclusão: o problema está na RCL declarada no RGF, e não na receita do município.
- **Conferência interna:** nos municípios do formato simplificado, o percentual de pessoal do Anexo 01 e o do Anexo 06 coincidem em 43 de 44 comparações (a outra difere em 0,11 ponto percentual).
- **Cobertura:** 9 a 13 municípios por ano entregam o RGF simplificado (municípios com menos de 50 mil habitantes). Foram coletados em endpoint e anexo próprios.

## Resultados preliminares (serão atualizados)

- **Situação em 2025 (246 municípios):** 167 regulares, 34 em alerta, 23 em prudencial, 19 acima do limite declarado e 3 a revisar. Em 2024 eram 191, 29, 15, 9 e 2.
- **Quem piorou:** dos 19 acima do limite em 2025, 13 estavam regulares ou em alerta em 2024; só 1 já estava acima.
- **Folha versus receita:** entre 18 municípios acima do limite in 2025 (excluindo um dado atípico), a despesa de pessoal subiu 25% ou mais em 13. Dois casos têm queda de RCL e merecem checagem contra o DCA.
- **Variação mediana anual (calculada antes de incluir os municípios do RGF simplificado):** 2023, RCL +8,9% e folha +13,5%; 2024, RCL +15,2% e folha +8,5%; 2025, RCL +10,9% e folha +14,5%.
- **Reincidência:** 6 municípios ficaram acima do limite declarado em 2 ou mais anos.

## Limitações

- Dados autodeclarados; a mesma fonte pode ter versões retificadas, e a versão usada não foi identificada.
- Valores nominais, sem correção pela inflação.
- O critério de dados atípicos é provisório (percentual acima de 100% ou RCL abaixo de 60% da mediana do município) e ainda não foi validado para os 246 municípios com o DCA.
- "Acima do limite" significa acima do limite **declarado** pelo município. Não é parecer de auditoria.

## Próximos passos

- Coletar o DCA de 2022 a 2024.
- Regra de qualidade com a razão RGF/DCA para todos os municípios.
- Views de receita por tipo, despesa por função e dependência de transferências.
- Modelo estrela e painel no Power BI.
- Incluir 2026.

## Licença e fonte

Dados públicos do Tesouro Nacional (Siconfi). Licença do código a definir.
