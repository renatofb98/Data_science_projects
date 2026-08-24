# Predição de Risco de Impedimento de Gestão no IGD-M — Municípios de Goiás

Modelo de classificação para identificar municípios de Goiás com risco de sofrer **impedimento no repasse do IGD-M** (Índice de Gestão Descentralizada do Bolsa Família) por falha de governança — especificamente, falta de aprovação/comprovação de gastos pelo conselho municipal (FMAS/CMAS) — com antecedência suficiente para permitir ação preventiva.

## Pergunta de negócio

O IGD-M financia a gestão municipal do Cadastro Único e do Bolsa Família. Quando um município falha em ritos de governança (aprovação ou comprovação de gastos pelo conselho), o repasse é impedido naquele mês. Esse projeto responde: **é possível prever, com base no histórico recente do próprio município, quais estão em risco de sofrer esse impedimento no mês seguinte?** Um modelo assim permite priorizar acompanhamento e suporte técnico antes que o problema aconteça, em vez de só reagir depois.

## Fontes de dados

- **API MISocial (SAGI/MDS)** — séries de taxas que compõem o IGD-M (atualização cadastral, acompanhamento de condicionalidades de saúde e educação), valores calculados e motivo de impedimento de repasse, por município e mês.
- **API SIDRA (IBGE)** — Tabela 6579, estimativa populacional municipal anual.

Recorte: 246 municípios de Goiás, série mensal de 2018 a 2024 (com uma lacuna estrutural explicada abaixo).

## Decisões metodológicas (e os problemas de dado que motivaram cada uma)

Esse projeto teve tanto trabalho de tratamento de dado quanto de modelagem — e as decisões abaixo são a parte que mais importa para avaliar o resultado.

**1. Definição do alvo evitando vazamento de dado.** A fonte registra vários motivos de impedimento de repasse, incluindo um baseado numa regra determinística (TAC < 0,55 — Taxa de Atualização Cadastral, que já é uma das variáveis preditoras do modelo). Usar "qualquer impedimento" como alvo faria o modelo apenas reaprender essa regra, sem generalizar. O alvo final (`teve_impedimento_gestao`) exclui explicitamente os casos motivados por TAC, isolando impedimentos por falha de governança (aprovação/comprovação de gastos).

**2. Correção de um buraco de calendário que invalidava as variáveis defasadas.** O programa Bolsa Família foi substituído pelo Auxílio Brasil entre nov/2021 e mar/2023, período em que o índice simplesmente não existe na fonte. Funções de janela (`LAG`, médias móveis) em SQL operam pela ordem das linhas, não pelo calendário — sem correção, o modelo trataria dez/2021 e mar/2023 como meses consecutivos. A query foi reescrita para validar a continuidade do calendário (`mes_idx`) antes de aceitar qualquer valor defasado, descartando (`NULL`) lags que atravessam a lacuna.

**3. Correção de outlier de escala.** Cerca de 300 registros de outubro/2024 continham taxas fora do intervalo [0,1] (ex: 91,67 em vez de 0,9167) — erro sistemático de escala percentual isolado naquele mês, corrigido dividindo por 100. Um segundo grupo de outliers (valores como 903, 984) em meses isolados (mai/jul 2023) não seguia esse padrão e foi tratado como erro não recuperável, convertido para nulo.

**4. Exclusão de 2018–2020 do treino.** Durante boa parte de 2020, o monitoramento de condicionalidades foi formalmente suspenso em razão da pandemia, gerando uma taxa de impedimento artificialmente próxima de zero que não reflete o regime atual do programa. O modelo foi treinado apenas com 2021 e 2023–2024, período que reflete as regras vigentes.

**5. Split temporal, não aleatório.** Como o problema é uma série temporal por município, um split aleatório misturaria passado e futuro do mesmo município entre treino e validação — outra forma de vazamento. Treino: 2021 + 2023 (3.444 observações, 159 positivos). Validação: 2024 (2.706 observações, 47 positivos).

**6. Apenas variáveis defasadas como preditor.** Os valores do mês corrente foram excluídos das features — apenas lag de 1 mês, média móvel de 3 meses e histórico de impedimento nos últimos 6 meses entram no modelo, para garantir que a previsão usa só informação disponível antes do evento.

## Modelagem

| Modelo | ROC-AUC | PR-AUC | Precision (threshold 0,5) | Recall (threshold 0,5) |
|---|---|---|---|---|
| Regressão Logística (3 features) | 0,715 | 0,078 | 0,10 | 0,57 |
| Regressão Logística + população (log) | 0,778 | 0,075 | 0,10 | 0,57 |
| **Random Forest** (mesmas 4 features) | 0,763 | **0,113** | 0,10 | 0,57 |

A taxa de positivo na validação é 1,74% — o baseline aleatório de PR-AUC. O Random Forest entrega PR-AUC **~6,5x acima do acaso**, a melhor métrica entre os modelos testados para esse tipo de problema desbalanceado.

**Feature mais importante, de longe:** histórico de impedimento nos últimos 6 meses. Risco de falha de governança é majoritariamente reincidente, não um evento aleatório — achado confirmado tanto pelo coeficiente da regressão logística (2,82, muito acima das demais) quanto pelos valores SHAP.

**Achado secundário (SHAP):** a relação entre população e risco não é linear. Municípios muito pequenos são mais protegidos; um pico de risco aparece em municípios pequeno-médios; e municípios grandes (região metropolitana de Goiânia) mostram risco elevado mesmo sem histórico recente de impedimento — sugerindo um componente de risco estrutural (maior volume de processos administrativos) independente de reincidência.

## Threshold de decisão

Com o problema fortemente desbalanceado, o ponto de corte de 0,5 (padrão) não é o mais útil operacionalmente. Testando outros pontos:

| Threshold | Precision | Recall | Alertas gerados |
|---|---|---|---|
| 0,10 | 0,020 | 0,957 | 2.222 |
| 0,20 | 0,024 | 0,851 | 1.638 |
| **0,30** | **0,032** | **0,702** | **324** |
| 0,40 | 0,094 | 0,574 | 287 |
| 0,50 | 0,102 | 0,574 | 266 |

0,30 foi escolhido como ponto de operação: captura 70% dos casos reais de impedimento com um volume de alertas (324, de 2.706 município-mês) viável para revisão manual — dado o custo assimétrico do problema (deixar passar um caso de risco é mais custoso do que revisar um alerta que não se confirma).

## Limitações conhecidas

- Interpolação linear foi usada para estimar população em 2023 (ano sem estimativa direta do IBGE, por transição do Censo 2022), o que introduz alguma imprecisão.
- O recorte geográfico (Goiás) limita a generalização para outros estados sem revalidação.
- Com apenas 47 casos positivos no conjunto de validação, as métricas têm variância considerável — o resultado deve ser lido como direção, não como precisão estatística fina.

## Próximos passos

- Validar o modelo em escala nacional.
- Testar features socioeconômicas adicionais (PIB per capita, IDH).
- Empacotar como dashboard de acompanhamento mensal.

## Stack

Python (pandas, scikit-learn, SHAP), SQL (SQLite, funções de janela), dados públicos via API REST (SAGI/MDS, IBGE/SIDRA).
