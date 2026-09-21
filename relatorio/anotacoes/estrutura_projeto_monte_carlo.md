# Estrutura atual do projeto

## Objetivo

O projeto projeta o restante do Campeonato Brasileiro por simulação de Monte
Carlo. Em cada realização, os jogos futuros recebem placares simulados, são
somados aos jogos já observados e produzem uma classificação final hipotética.
As estatísticas de muitas realizações (`B`) são convertidas nas respostas do
laboratório.

O arquivo que integra o fluxo é `relatorio/lab1.Rmd`. As funções ficam em
`relatorio/r_utils/` e os arquivos de saída são gravados em
`data/resultados/`.

## Fluxo comum às abordagens

```text
dados brutos
  -> jogos realizados e jogos futuros
  -> modelo para prever/simular gols
  -> B temporadas simuladas em paralelo
  -> acumuladores combinados
  -> respostas, desempenho e tempo por abordagem
```

As funções de preparação são:

- `tratar_dados()`: elimina jogos ainda sem placar e converte cada partida
  realizada em duas linhas, uma para cada clube.
- `extrair_jogos_futuros()`: seleciona partidas cujo placar ainda é ausente.
- `classificar_times()`: calcula pontos, vitórias, gols, saldo e a posição
  final de uma tabela de jogos.
- `inicializar_acumuladores()`: cria contadores zerados para clubes e totais
  de pontos.
- `atualizar_acumuladores()`: atualiza esses contadores após uma temporada
  simulada.
- `formatar_resultados()`: transforma as contagens acumuladas em
  probabilidades, médias e limiares de pontos.

## Perguntas do laboratório e acumuladores

Em uma temporada hipotética, `atualizar_acumuladores()` registra:

1. títulos por time;
2. rebaixamentos por time;
3. ocorrência de empate na maior pontuação;
4. pontuação do campeão;
5. frequência de cada pontuação e frequência daquela pontuação entre campeões;
6. frequência de cada pontuação entre times que não foram rebaixados.

### Alteração: empate com mais de dois times

Antes, o empate no topo era identificado apenas comparando a pontuação do
primeiro e do segundo colocados. Agora o código conta todos os times com a
pontuação do campeão:

```r
times_no_topo <- sum(classificacao$pontos == pontos_campeao)
as.integer(times_no_topo >= 2)
```

Assim, empate duplo, triplo ou com mais clubes é contado como uma realização
com empate na pontuação máxima. A classificação ainda usa vitórias, saldo e
gols marcados para escolher o primeiro colocado entre os empatados em pontos.

## Reprodutibilidade e paralelização

`monte_carlo_campeonato()` recebe:

- `B`: total de temporadas hipotéticas;
- `seed`: semente opcional;
- `n_cores`: quantidade de processos paralelos;
- `simulador`: função que gera os jogos futuros para uma abordagem;
- `objetos_worker`: funções auxiliares que precisam ser enviadas aos workers.

A seed é configurada uma vez, não uma vez por iteração. O gerador de números
pseudoaleatórios avança a cada sorteio automaticamente. Na versão paralela,
`clusterSetRNGStream()` cria fluxos independentes para os workers. Para
reproduzir exatamente a execução paralela, mantenha iguais a seed e o número
de cores.

As `B` realizações são distribuídas em blocos entre os workers. Cada worker
mantém seu próprio acumulador. Ao final,
`combinar_acumuladores()` soma campo a campo os acumuladores parciais. Não há
compartilhamento concorrente de objetos entre os processos.

## Abordagem 1: Poisson combinada por time

Arquivos principais:

- `calcula_medias.R`;
- `calcular_lambdas_poisson_combinada.R`;
- `simular_jogos.R`;
- `avaliar_poisson_combinada.R`.

Para cada time, são calculados:

- `theta`: média de gols marcados por jogo;
- `phi`: média de gols sofridos por jogo.

Para uma partida, os parâmetros Poisson são:

```r
lambda_mandante = (theta_mandante + phi_visitante) / 2
lambda_visitante = (theta_visitante + phi_mandante) / 2
```

Os gols são então sorteados com `rpois()`. Esta abordagem não estima um
modelo por par de times: ela estima ataque e defesa por clube. Portanto, ainda
consegue prever confrontos mesmo que cada par se encontre apenas duas vezes no
campeonato.

O desempenho é avaliado temporalmente: as primeiras 80% das rodadas já
realizadas formam o treino e as rodadas posteriores formam o teste. A
simulação do campeonato, por outro lado, ajusta os parâmetros com todos os
jogos já observados, pois essa é a informação disponível no momento da
previsão da temporada restante.

## Abordagem 2: regressão Poisson por time

Arquivo novo: `regressao_poisson_por_time.R`.

Nesta abordagem é ajustada uma regressão Poisson separada para cada time, com
ligação canônica log:

```r
gols_marcados ~ em_casa + gols_acumulados + vitorias_acumuladas +
  rodada + defesa_adversario
```

As variáveis são calculadas antes da rodada da partida:

- `em_casa`: 1 para mandante e 0 para visitante;
- `gols_acumulados`: gols já marcados pelo próprio clube;
- `vitorias_acumuladas`: vitórias já obtidas pelo próprio clube;
- `rodada`: número da rodada;
- `defesa_adversario`: média de gols que o adversário sofreu por jogo até a
  rodada anterior.

A defesa adversária entrou como medida numérica, e não como fator com um nível
para cada adversário. Isso evita coeficientes muito instáveis, pois cada time
tem poucas observações contra um oponente específico.

### Funções novas da abordagem 2

- `criar_estado_times()`: inicia gols, gols sofridos, vitórias e jogos por
  clube.
- `atualizar_estado_times()`: atualiza o estado após partidas reais ou
  simuladas.
- `defesa_atual()`: calcula a taxa atual de gols sofridos do adversário.
- `criar_linha_regressao()`: monta os preditores de uma observação.
- `construir_painel_regressao_poisson()`: cria o painel de treino sem vazar
  resultados da própria rodada para as covariáveis.
- `ajustar_regressoes_poisson_por_time()`: ajusta uma `glm()` Poisson por
  clube.
- `prever_lambda_regressao()`: calcula o `lambda` previsto a partir de uma
  regressão.
- `criar_contexto_regressao_poisson()`: combina modelos, estado observado e
  jogos futuros para uma realização Monte Carlo.
- `simular_jogos_regressao_poisson()`: simula os jogos futuros rodada a
  rodada.
- `avaliar_regressao_poisson_por_time()`: faz a avaliação temporal 80%/20%.

Na simulação, todos os jogos de uma rodada recebem seus lambdas com o estado
existente antes da rodada. Em seguida, os placares sorteados atualizam o
estado. Logo, gols e vitórias acumulados, bem como a defesa dos adversários,
passam a depender do cenário simulado nas rodadas seguintes.

Na avaliação, os modelos são treinados nas primeiras 80% das rodadas. As
previsões das rodadas de teste usam somente o histórico anterior; depois de
cada rodada de teste, os resultados reais são usados para atualizar o estado
para a próxima rodada. Isso representa previsão sequencial de curto prazo.

## Resultados e desempenho

`executar_abordagem()` mede o tempo de Monte Carlo com:

```r
system.time(...)["elapsed"]
```

`elapsed` é o tempo de relógio decorrido, em segundos, incluindo a espera
pelos workers paralelos.

O dataframe `resultados_abordagens` tem uma linha por abordagem. As respostas
por time são colunas-lista (`q1_prob_campeao_por_time` e
`q2_prob_rebaixamento_por_time`), pois uma única célula precisa preservar uma
tabela de probabilidades. As respostas escalares são `q3_prob_desempate`,
`q4_media_pontos_campeao`, `q5_pontos_90_campeao` e
`q6_pontos_95_nao_rebaixado`.

As métricas preditivas são:

- `sqe_medio`: média de `(gols observados - lambda previsto)^2`;
- `nll_medio`: média da log-verossimilhança negativa Poisson.

Em ambas, menor valor indica melhor desempenho. A NLL é particularmente útil
porque avalia diretamente a distribuição Poisson prevista, e não apenas sua
média.

`salvar_resultados_abordagens()` grava:

- `resultados_abordagens.rds`: preserva dataframe e colunas-lista;
- `resultados_abordagens_resumo.csv`: contém apenas as colunas planas,
  adequadas a CSV.

`RDS` é o formato nativo do R para salvar um objeto completo. Ele é lido com
`readRDS()`. O CSV não comporta corretamente tabelas dentro de uma célula.

A função de salvamento sobrescreve os dois arquivos com o dataframe inteiro;
ela não acrescenta uma linha automaticamente. Para salvar várias abordagens,
use `bind_rows()` antes de chamar a função de salvamento.

## Execução e sessões R

As funções devem ser carregadas antes da simulação. O erro
`objeto 'classificar_times' não encontrado` aparece quando se executa apenas o
chunk da Monte Carlo sem executar os `source()` anteriores. Ao renderizar o
Rmd desde o início, as funções são carregadas na ordem correta.

O Codex no VS Code edita os arquivos do projeto, mas não compartilha a sessão
R aberta no RStudio. Para executar testes também pelo terminal do VS Code,
`Rscript.exe` precisa estar disponível no `PATH`, por exemplo:

```text
C:\Program Files\R\R-4.5.2\bin
```

Depois de alterar o PATH, reinicie o VS Code/Codex e confirme com:

```powershell
Rscript --version
```
