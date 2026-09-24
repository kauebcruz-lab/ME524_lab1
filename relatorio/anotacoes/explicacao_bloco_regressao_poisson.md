# Entendimento das funções

## tratar_dados

A função utiliza a técnica de [[Embracing]].

Ela basicamente filtra dados nulos e faz um pivot_longer para que so exista uma coluna de time sem a diferenciação entre mandante e visitante junto com informações de rodada e gols.

A função é aplicada aos dados resultando em um df de 492 linhas.
## extrair_jogos_futuros

A função também utiliza embracing.

Ela pega o dados e filtra os jogos que ainda não aconteceram, mantendo somente as colunas rodada, time_mandante e time_visitante.

A função é aplicada aos dados

## calcula_medias

A função agrupa os dados por time e depois traz as médias de gols mercados como $\theta$ e a média de gols sofridos como $\phi$.

Em seguida a função é aplicada aos dados tratados.

## Classificar times

A função pega os dados e cria as coluna pontos como 3, se os gols marcados é maior que os gols sofridos, 1 se são iguais e 0 caso contrário. 

Em seguida a coluna de vitória como o inteiro de gols marcados em cima de gols sofridos. 

Depois os times são agrupados e é somado os pontos, vitórias, gols sofridos e marcados. 

Então, a coluna `saldo_gols` é criada como a diferença de gols marcados e sofridos, então os dados são organizados respectivamente por pontos, vitórias, saldo de gols e gols marcados em ordem decrescente, respeitando a ordem de critérios de desempate do campeonato. 

A classificação é pega como a ordem da linha e, por fim, é retornada a classificação, o time, número de vitórias, saldo de gols, gols marcados e sofridos e número de jogos feitos.

A função é aplicada nos dados tratados.


## monte_carlo_campeonato()

A função tem como argumentos:
- `dados_tratados`: Jogos que já ocorreram, com uma linha para visão mandante e outra para visão visitante.
- `jogos_futuros`: jogos futuros com informações de times e rodada somente.
- `parametros`: Lista de parâmetros que o modelo do simulador utiliza.
- `dados_completos`: dados crus do lab.
- `B`: Número de simulações para utilizar no monte  carlo.
- `seed`: Semente aleatória para reprodutibilidade.
- `n_cores`: Número de cores utilizado para o processamento paralelo das simulações.
- `simulador`:  Recebe uma função que simula os gols de cada time nos jogos futuros.
- `objetos_worker`: Recebe um vetor de strings com os nomes dos objetos que cada worker paralelo precisa receber para realizar as simulações.

Primeiro a função avalia se o número de simulações e número de cores são aceitáveis.

Depois designa como número de cores o mínimo entre simulações e número de cores.

Depois armazena em `repeticoes_por_bloco` o número inicial de simulações que cada worker recebe como a divisão inteira entre número de simulações e número de cores.

Depois para que todas simulações sejam contempladas, o número de repetições é incrementado em 1 para os primeiros workers, segundo o resto da divisão entre número de simulações e números cores. É garantido que esse valor menor que o número de cores.

Depois é criada uma função interna `executar_bloco(n_repeticoes)` que primeiro da início aos acumuladores com `inicializar_acumuladores()` criando a lista nomeada com estatísticas que são atualizadas nas simulações e ajudam a responder as questões do lab. Em seguida, realiza um `for loop` que itera `b` nas `n_repeticoes`.
Em cada repetição, é simulado os jogos que ainda não foram feitos com o `simulador(jogos_futuros)` e armazena o resultado em `jogos_simulados`. Em seguida, `temporada_completa` armazena a junção de `jogos_tratados` e `jogos_simulados`, `classificacao_simulada` armazena a classificação dos times obtidas de `classificar_times(temporada_completa)` e, então o acumulador é atualizado com `atualizar_acumuladores`.
Finalmente, a função retorna o `acumuladores` com estatísticas de todos jogos simulados.

Depois, se o número de cores é 1, então é utilizado o plano sequencial e nenhum worker é aberto para executar `executar_bloco()`

Caso contrário, é criado um `n_cores` workers independentes, cada um com a sua sessão de do R.
Agenda o encerramento dos clusters para quando a função terminar ou houver erro.
Importa a biblioteca `dplyr` em cada uma das sessões que é necessária para executar `bind_rows()` de `executar_bloco()`
Copia uma série de objetos da sessão principal para cada worker, incluindo os passados em `objetos_worker` que é particular de cada abordagem.
Em seguida, cada worker recebe uma sequência aleatória diferente de acordo com seed, para reprodutibilidade e evitar que cada worker replique a mesma simulação.
Com a função `parLapply()` cada worker recebe o valor `n_repeticoes` respectivo e executa `executar_bloco(n_repeticoes)`. Cada acumulador de worker é combinado com `combinar_acumuladores()` e salvo em `acumuladores`.

Por fim, é retornado o resultado de `formatar_resultados(acumuladores, B)` que retorna em uma lista nomeada dois tibbles e 4 números, que são as estatísticas pedidas do lab1 obtidas por Monte Carlo.

### formatar_resultados(acumuladores, B)

A função tem como argumentos:
- `acumuladores`: lista nomeada com estatísticas acumuladas que serão utilizadas para calcular as probabilidades de interesse do lab.
- `B`: número de simulações realizadas para utilização de Monte Carlo.
- `limite_campao`: configurado como 0.9, é o limiar de probabilidade da questão 5.
- `limite_nao_rebaixado`: configurado como 0.95, é o limiar de probabilidade da questão 6.

A função pega as estatísticas dos acumuladores e calcula as estatísticas de interesse do lab.

Primeiro as respostas da questão 1 e 2:
É armazenado em `probabilidades_times` um tibble com 3 colunas, `time`, `prob_campeao` e ``
`prob_rebaixamento`. As probabilidades são calculadas com as listas  `titulos_por_time` e `rebaixamentos_por_time` do acumulador dividido por `B`.

Depois a resposta da questão 3:
`prob_desempate` armazena o `numero_desempates` do acumulador e divide por `B`.

Em seguida, a questão 4 é respondida:
Em `media_pontos_campeao` é armazenado o `soma_pontos_campeao` dividido por `B`.

Por fim, as questões 5 e 6 são respondidas:
Com `total_por_pontos`, `campeoes_por_pontos` e `nao_rebaixados_por_pontos` do acumulador um tibble, `resultado_por_pontos` armazenando em `pontos` todos os pontos possíveis no campeonato, em `frequência` quantos times acabaram o campeonato com cada pontuação possível, quantos times foram campeões em `frequencia_campeao` e quantos times não forma rebaixados em `frequencia_nao_rebaixado` para cada pontuação possível.

`prob_campeao` é uma lista nomeada por ponto possível com a divisão de `frequencia_campeao` por `frequencia` caso pelo menos um time tenha acabado o campeonato com essa pontuação. E o mesmo é feito com `prob_nao_rebaixado`, utilizando `frequencia_nao_rebaixado`.

Então são construídas duas listas nomeadas, `candidato_campeao` e `candidatos_nao_rebaixado` pegando a coluna de `pontos` do tibble `resultado_por_pontos` e filtrando os pontos que não possuem probabilidades respectivas não nulas e maiores que os thresholds de probabilidade do exercício `limite_campeao` e `limite_nao_rebaixado`.

Então em `pontos_90_campeao` e `pontos_95_nao_rebaixado` é pego a menor quantidade de pontos de `candidato_campeao` e `candidatos_nao_rebaixado`.

Por fim é retornada uma lista nomeada com os seguintes itens:
- `probabilidades_times` que é um tibble.
- `prob_desempate` que é um número.
- `media_pontos_campeao` que é um número.
- `resultados_por_pontos` que é um tibble.
- `pontos_90_campeao` que é um número.
- `pontos_95_nao_rebaixado` que é um número.
### combinar_acumuladores()

Utilizando a função `reduce()`, uma função interna é definida que faz a combinação de dois acumuladores, somando cada item da lista de um acumulador com o do outro e registrando o resultado em um item de mesmo nome que estará na saída da função. Os itens dos acumuladores são listas nomeadas por time, por pontos possíveis ou são números, e possuem a mesma dimensão para ambos acumuladores, portanto o resultado é um objeto de mesma dimensão e nomes com a soma das estatísticas armazenadas de cada acumulador

A função` reduce()` permite definir uma função que que recebe dois argumentos e, caso seja submetida a uma lista por exemplo, a combinação de 3 argumentos passa a ser o resultado da combinação de dois elementos combinado com o terceiro e assim por diante.
### atualizar_acumuladores

Atualiza os acumuladores com as estatísticas de uma simulação, recebendo como argumento:
- `acumuladores`
- `classificacao`

`campeao` armazena o time que ficou em primeiro na `classificao`

`rebaixados` traz um vetor dos times que ficaram nas 4 últimas posições do campeonato.

`pontos_campeao` traz o número de pontos do primeiro colocado

`titulos_por_time` do `campeao` é incrementado em 1 nos acumuladores.

`rebaixamento_por_time` dos `rebaixados` é incrementado em 1 nos acumuladores.

É avaliado o número de times que empataram nas primeiras colocações por pontos, em seguida, se esse número é maior ou igual a 2, o `numero_desempates` do acumulador é incrementado em 1.

No acumulador a `soma_pontos_campeao` é incrementada pelo número de pontos do campeão.

é pego como máximo de pontos o tamanho da lista nomeada em `total_por_pontos` - 1 do acumulador, porque um time também pode fazer 0 pontos, então o tamanho da lista é o `max_pontos` + 1.

em `contagem_pontos` é armazenado um vetor com tamanho do `max_pontos` + 1, e em cada posição desse vetor tem a quantidade de times que terminou com essa pontuação - 1 no campeonato. É feita essa subtração porque os times tem que ser postos em uma posição acima por conta do 0 como uma das possibilidades de se terminar o campeonato. Isso é feito com `tabulate()`.

Então o `total_por_pontos` do acumulador é atualizado com esse vetor `contagem_pontos`.

`pontos_nao_rebaixados` é o vetor de pontos dos times que não foram rebaixados no campeonato, ou seja, que ficaram nas primeiras 16 classificações.

Novamente, com `tabulate()` é criado um vetor com tamanho igual ao `max_pontos` + 1 e com o número de de times que não foi rebaixado com x pontos na posição x+1 desse vetor.

Então, `nao_rebaixados_por_pontos` do acumulador é incremento por esse vetor, atualizando o número de times que terminou com cada uma das pontuações possíveis e não foi rebaixado.

Finalmente, o acumulador atualizado é retornado.

### Inicializar_acumuladores()

Tem como argumento `times` e `max_pontos` que é número máximo de pontos que um time pode conseguir no campeonato.

A função retorna uma lista nomeada com: `titulos_por_time`, `rebaixamentos_por_time`, `numero_desempates`, `soma_pontos_campeao`, `total_por_pontos`, `campeos_por_pontos` e `nao_rebaixados_por_pontos`.

Os itens `titulos_por_time` e `rebaixamentos_por_time` recebem uma ista nomeadas por time com zeros.

Os itens `numero_desempates` e `soma_pontos_campeao` recebe o número 0.

E os itens `total_pontos`, `campeoes_por_pontos` e `nao_rebaixados_por_pontos` recebem uma lista nomeada por pontos possíveis que começa com 0 em cada um dos pontos possíveis.

Esse acumulador é uma forma eficiente de guardar as estatísticas geradas pelas simulações que ajudarão a responder as questões do lab de simulação por monte carlo. E essa função inicializa ela.



# Segunda abordagem

A segunda abordagem é uma Regressão de poisson por time que modela o número de gols do time com base em:
- `em_casa`: 1 para mandante e 0 para visitante;
- `gols_acumulados`: gols já marcados pelo próprio clube;
- `vitorias_acumuladas`: vitórias já obtidas pelo próprio clube;
- `rodada`: número da rodada;
- `defesa_adversario`: média de gols que o adversário sofreu por jogo até a
  rodada anterior.

[[Regressão de Poisson]]

Primeiro a função `ajustar_regressoes_por_times(dados)` é executada e é armazenado em `modelos_regressao` uma lista nomeada por time, em que cada item possui uma lista nomeada com o modelo de regressão de poisson em `ajuste` e média de gols do time em `media_gols`.

Em seguida, em `parametros_regressao` é armazenado um tibble com uma coluna de time, listando os 20 times que participam do campeonato. ?

Então, é armazenado em `context_regressao` a saída  de 
```r
criar_contexto_regressao_poisson(
  jogos_futuros = extrair_jogos_futuros(dados),
  dados_realizados = dados,
  modelos = modelos_regressao
)
```
, que retorna uma lista nomeada com `jogos_futuros`, `modelos`, `estado_inicial`. `jogos_futuros` traz um dataframe com os jogos que ainda não aconteceram e serão simulados, trazendo somente as colunas do time mandante, visitante e rodada. `modelo` traz a lista nomeada por time que cada item é uma lista nomeada com `ajuste` contendo o modelo de regressão de Poisson ajustada para esse time e `media_gols` a média de gols desse time e `estado_inicial` traz a lista nomeada com `gols_marcados`, `gols_sofridos`, `vitorias` e `jogos`, em que cada item possui a lista nomeada para cada time com a estatística dele de acordo com os jogos que já foram realizados.

Em seguida é armazenado em `resultado+abordagem_2` a execução de:

```r
executar_abordagem(
  nome_abordagem = "Regressão Poisson por time",
  dados_tratados = dados_tratados,
  jogos_futuros = contexto_regressao,
  parametros = parametros_regressao,
  dados_completos = dados,
  B = 10000,
  seed = 524,
  n_cores = max(1, parallel::detectCores() - 1),
  avaliador = avaliar_regressao_poisson_por_time,
  simulador = simular_jogos_regressao_poisson,
  objetos_worker = c(
    "simular_jogos_regressao_poisson",
    "prever_lambda_regressao",
    "criar_linha_regressao",
    "defesa_atual",
    "atualizar_estado_times"
  )
)
```

que traz um tibble com todos os resultados.

Os resultados dessa segunda abordagem é unido ao resultado da abordagem 1 com `bind_rows`.

E finalmente, os resultados são salvos em um tibble e um arquivo RDS chamados `resultados_abordagens_resumo.csv` e `resultado_abordagens.rds` no caminho `../data/resultados/`. O tibble traz os resultados que podem ser apresentados em uma tabela csv das questões, além de tempo de execução, nome da abordagem e desempenho dos modelos, já o .RDS traz os resultados da questão 1 e 2 do lab para ambas abordagens. É armazenado nesse formato por se tratar de diversos tibbles.

### Executar_abordagem()

A função tem como argumentos:
- `nome_abordagem`: Nome que será armazenado no data_frame de resultados para a abordagem.
- `dados_tratados`: Jogos que já ocorreram, com uma linha para visão mandante e outra para visão visitante.
- `jogos_futuros`: jogos futuros com informações de times e rodada somente.
- `parametros`: Essa abordagem de regressão de poisson não tem uma lista de parâmetros fixos como a abordagem 1, por essa razão recebe uma lista com nomes dos times que não é utilizada.
- `dados_completos`: dados crus do lab.
- `B`: Número de simulações para utilizar no monte  carlo.
- `seed`: Semente aleatória para reprodutibilidade.
- `n_cores`: Número de cores utilizado para o processamento paralelo das simulações.
- `avaliador`: Recebe função que avalia a capacidade preditiva do modelo.
- `simulador`:  Recebe uma função que simula os gols de cada time nos jogos futuros.
- `objetos_worker`: Recebe um vetor de strings com os nomes dos objetos que cada worker paralelo precisa receber para realizar as simulações.

A função primeiro executa `monte_carlo_campeonato()` que realiza as simulações em paralelo utilizando `n_cores` workers de maneira reprodutiva, armazenando os resultados de interesse em acumuladores que depois são utilizados para formar as estatísticas de interesse do lab1. A saída é uma lista nomeada com dois tibbles e 4 números que são as respostas das questões do lab utilizando essa abordagem. As simulações feitas aqui foram feitas utilizando o `simular_jogos_regressao_poisson`.

Depois termina de medir o tempo de execução do processo que o armazena no objeto `tempo`.

Depois `desempenho` guarda desempenho do modelo determinado por `avaliar_regressao_poisson_por_time`, trazendo um tibble com `sqe_medio`, `nll_medio`, `jogos_treino`, `jogos_teste` e `rodada_final_treino`.

Depois todos resultados são organizados em tibble.

#### avaliar_regressao_poisson_por_time

recebe como argumentos `dados` com os dados originais do lab e `proporcao_treino` com o valor 0.8

`realizados` filtra os jogos que já foram realizados de `dados`
`rodadas` guarda as rodadas ordenadas de `realizados`
`fim_treino` pega a rodada que termina o conjunto de dados de treino como o floor do percentil 80% das rodadas.
`treino` são os dados realizados até a rodada `fim_treino`.
`teste` são os dados realizados após a rodada `fim_treino`.
`modelos` armazena o resultado de `ajustar_regressoes_poisson_por_time(treino)`

`estado` é criado com `criar_estado_times()` e então é atualizado com `atualizar_estado_times()`.

é iniciada uma lista vazia `previsoes` e `indice` é iniciado em 1.

Depois dos dois `for loops` terminarem de rodar, fazendo previsões com estado atualizado a cada rodada, com os dados reais, as `previsoes` são unidas com `bind_row()`.

para cada jogo de `previsoes` é calculado o erro quadrático para o time visitante e mandante e ambos são concatenados em um único vetor `erros`.  Aqui o erro é o número de gols que realmente ocorreu no jogo menos o `lambda` previsto.

Em `nll` é armazenada a log verossimilhança negativa, que é a concatenação da log verossimilhança de cada jogo de `previsoes` considerando os gols reais como o observado e os lambdas previstos como o $\lambda$ da distribuição de Poisson. Por fim, esse vetor é multiplicado por -1.

Finalmente, um tibble é retornado com:
- `sqe_medio` como a média de `erros`,
- `nll_medio` como a média de `nll`,
- `jogos_teste` como número de jogos em `teste`,
- `rodada_final_treino` como a rodada de fim do treino.

O tibble só tem uma linha, sendo uma linha de desempenho por rodada
##### for loop 1

É iniciado o `for loop 1` que itera `rodada_atual` sobre as rodadas ordenadas de `treino`

É filtrado de `teste` os jogos da `rodada_atual` e armazenados em `jogos_rodadas`

depois do `for loop 2` terminar, o `estado` é atualizado com `atualizar_estado_times` recebendo como argumento `jogos_rodadas`. Diferentemente das simulações, aqui o estado é atualizado com os dados reais, não com os dados amostrados.
###### for loop 2

É iniciado o `for loop 2` que itera `i` sobre o número de jogos de `jogos_rodada`.

É pego o time mandante e visitante do jogo `i` da `rodada_atual` e armazenados em `mandante` e `visitante`.

E então é criado um tibble que é adicionado a posição `indice` de `previsoes` com `gols_mandante` e `gols_visitante` com os valores dos gols que realmente aconteceram nesse jogo `i` da `rodada_atual` e também é pego `lambda_mandante` e `lambda_visitante` com o predito pelo modelo de cada time nesse jogo.

por fim o índice é incrementado em 1


### simular_jogos_regressao_poisson

Recebe como argumento `contexto_regressao` que foi posto no argumento `jogos_futuros` de `executar_abordagem`.

Em `jogos_futuros` é armazenado o item `jogos_futuros` de `contexto_regressao` ordenados por `rodada`

`estado` armazena o item `estado_inicial` de `contexto_regressao`

`modelos` armazena o item `modelos` de `contexto_regressao`

é iniciada uma lista vazia `resultados` e o `indice` começa em 1.

Ao final de todas rodadas e jogos serem simulados, `jogos` vira o dataframe resultante da junção dos itens de `resultados` com `bind_rows()`.

Finalmente, é retornado o dataframe com colunas `rodada`, `time`, `gols_marcados`, `gols_sofridos` para todos os jogos restantes com o resultado das simulações, tanto na visão mandante, quanto na visitante.

#### Pontos importantes

Os modelos preveem para determinada situação o número de gols esperados do time, `lambda`, e, então esse lambda é utilizado para amostrar de uma Poisson.

O estado (lista de estatísticas utilizadas para predição do modelo) não é estático, a partir de uma rodada simulada, ele é atualizado e utilizado na predição da próxima rodada, portanto ele muda de acordo a amostragem de número de gols de cada rodada. 

#### for loop 1

O primeiro `for loop` itera `rodada_atual` sobre as rodadas restantes dos jogos futuros ordenadas.

É armazenado em `jogos_rodada` os `jogos_futuros` filtrados para a `rodada_atual`

Então é armazenado em `jogos_simulados_rodada` o dataframe `jogos_rodada`.

Depois de todas iterações do `for loop 2` terem rodado para a `rodada_atual`, `estado` é atualizado com `atualizar_estado_times()` com `estado` e `jogos_simulados_rodada` de argumento.

`resultados` recebe na posição `indice` `jogos_simulados_rodada` e, então, o indice é incrementado em 1
##### for loop 2

O segundo `for loop` itera `i` sobre a quantidade de jogos da `rodada_atual`.

`mandante` é pego como o nome do time mandante do jogo `i` da rodada atual.
`visitante` é pego como o nome do time visitante do jogo `i` da rodada atual.

`lambda_mandante` é o resultado da função `prever_lambda_mandante` com o modelo do time mandante e linha criada a partir do `criar_linha_regressao` que pega o `estado`, time visitante e mandante, a `rodada_atual` e `em_casa = True` e retorna um tibble com uma linha utilizada para fazer a predição de `lambda` para o time mandante dados esses argumentos. Aqui `estado` é na primeira iteração o `estado` atualizado com todos os jogos que já ocorreram. 

`lambda_visitante` faz o mesmo, porém prevê o `lambda` para o time visitante, ou seja, passa para `prever_lambda_regressao()` o modelo do time visitante do jogo `i` da `rodada_atual`, inverte `mandante` e `visitante` nos argumentos de `criar_linha_regressao()` e passa `em_casa = False`.

Em seguida, `jogos_sumulados_rodada` recebe para as colunas `gol_mandante` e `gol_visitante` da linha `i`, ou seja do jogo `i` da `rodada_atual` a simulação de uma Poisson tendo respectivamente, `lambda_mandante` e `lambda_visitante` predito pelos modelos.

### prever_lambda_regressao

Tem como argumentos `modelo` e `linha`.

Primeiro `lambda` é previsto com a função `predict()` que pega o item `ajuste` de `modelo` que é a regressão de Poisson para o time específico, a nova `linha` a qual o `lambda` prevê e `response = True` garante que a resposta venha em escala normal e não em escala logarítmica da ligação canônica.

Depois é verificado se lambda é nulo ou infinito, caso seja, é utilizada a média de gols do time.

E por fim, é um número bem pequeno configurado como o valor mínimo que `lambda` pode assumir.

`lambda` é retornado.

### criar_contexto_regressao_poisson(jogos_futuros, dados_realizados, modelos)

A função armazena em `times` uma lista com o nome dos times e `estado` o resultado de `criar_estado_times(times)` que cria o estado inicial para todos os times.

Em seguida, em `dados_observados` é feito de forma redundante o filtro de gols não nulos e a seleção de colunas do conjunto de dados que já vem nesse formato.

Por fim, é criada uma lista com os `jogos_futuros`, `modelos` e `estado_inicial` como o estado atualizado para os jogos atualizados.

### ajustar_regressoes_por_times(dados)

Na primeira linha é executado `construir_painel_regressao_poisson(dados)` que retorna um tibble com informações estruturadas para serem utilizados na regressão de poisson e esse tibble é armazenado em `painel`.

Em seguida, é armazenado em `paineis_por_time` o painel de cada time em uma lista nomeada pelos times. Ou seja, em cada item dessa lista nomeada, é filtrado o tibble com o `time` sendo o time desse índice.

Depois com lapply, sobre os dados de cada time da lista nomeada `paineis_por_time`, é executada uma função que armazena em uma lista nomeada o `ajuste` e a `media_gols`desse time. Em `ajuste` é armazenado o modelo de  regressão de Poisson treinado sobre os dados desse time e, em `media_gols` a média de gols do time. Como o lapply é aplicado sobre a lista nomeada por time `paineis_por_time`, então é armazenada nessa lista, em cada time, essa lista nomeada de dois itens, com modelo e média de gols.

lista nomeada por times, com lista nomeada de modelo e média de gols é retornada pela função

#### construir_painel_regressao_poisson(dados)

Filtra somente os jogos que aconteceram removendo valores nulos de gols_mandante e visitante e depois ordena os dados por rodada.

Armazena em times um vetor de combinações distintas de time mandante e visitante dos jogos que ocorreram

Armazena em `estado` o resultado de `criar_estado_times(times)`. Então ela recebe uma lista nomeada com os nomes: gols_marcados, sofridos, vitorias e jogos. Cada um desses itens é uma lista nomeada, em que cada nome é um time, recebendo valor 0.

cria em `linhas` uma lista vazia.

`indice` recebe o valor 1

É iniciado um primeiro `for loop`que itera a variável `rodada_atual` sobre as diferentes rodadas distintas ordenadas dos jogos que já ocorreram.

Depois, é iniciado o segundo `for loop` que itera `i` sobre o número de linhas dos jogos da rodada atual, ou seja, `i` representa cada jogo da rodada atual.

Finalmente, a lista `linhas` terá um índice para cada jogo e rodada dos jogos que aconteceram tanto para a visão mandante, quanto para a visão visitante que será utilizada nas regressões poisson de cada time, é unida por `bind_rows(linhas)`. Como cada índice da lista era um tibble com as mesmas colunas, o resultado é um tibble com o número de linhas sendo o número de jogos vezes 2, com valores estruturados para serem utilizados na regressão de poisson.
##### for loop 2

`mandante`armazena o nome do time mandante do jogo `i` da rodada atual.
`visitante` armazena o nome do time visitante do jogo `i` da rodada atual.

aramazena na lista `linhas` no índice `indice`a saída de `criar_linha_regressao(estado, mandante, visitante, rodada_atual, True)` que é um tibble com valores do `estado` atual com os valores que serão utilizados na regressão por esse time mandante, então ele traz todas as features que é a binária `em_casa`, `gols_acumulados`, `vitorias_acumuladas` e `defesa_adversario`. Depois cria a coluna `time` = `mandante` e `gols_marcados` = aos gols marcados pelo time mandante no jogo `i` da rodada atual que servirá de variável resposta na regressão.

Em seguida, é adicionado 1 no `indice`

Agora é atribuido ao novo `indice` que foi incrementado em 1 na lista `linhas` o resultado da função `criar_linha_regressao(estado, visitante, mandante, rodada_atual, FALSE)`, ou seja, agora é criada a linha que será utilizada na regressão do time visitante referente ao jogo `i` da rodada atual, tendo a flag de `em_casa = FALSE`. Depois disso as colunas `time` e `gols_marcados` também são criados, mas dessa vez, armazenando o nome do time vistante e o número de gols marcados pelo time visitante que será a variável resposta da regressão.

Novamente, o `indice` é incrementado em 1. Ou seja para cada jogo da rodada atual, o índice é incrementado duas vezes e cria dois tibbles na lista `linhas` que irá compor a regressão de poisson, um para a do time mandante e outro para o time visitante.

###### criar_linha_regressao(estado, time, adversário, rodada, em_casa)

A função cria um tibble com colunas:
- `em_casa` como o indicador de o jogo foi em casa como inteiro.
- `gols_acumulados` como o valor aramazenado em `estado` no item `gols_marcados` para o `time`.
- `vitorias_acumuladas` como o valor em `estado` no item `vitorias` para o `time`
- `rodada` como a `rodada`
- `defesa_adversario` como o valor de `defesa_atual(estado, adversario)` que retorna a média de gols que o time adversário sofreu no estado atual.

A função traz as informações que serão utilizadas como variáveis explicativas na regressão dado o estado, times, rodadas etc.

##### for loop 1

É armazenado em `jogos_rodadas` os jogos da rodada atual

E é executado o `for loop 2` que itera `i` para cada jogo da rodada atual que, ao final de todos os jogos da rodada atual, terá criado em cada índice da lista `linhas` um tibble com informações que serão utilizadas para compor a regressão de poisson de cada time, tendo um índice para a visão visitante e outro para o mandante em cada jogo.

Depois de todos os jogos da rodada atual terem sido iterados no `for loop 2` o estado é atualizado com `atualizar_estado_times(estado, jogos_rodada)` que atualiza `estado` de acordo com os resultados do jogo, ou seja, atualiza para o time visitante e mandante no `estado` o número de gols marcados, sofridos, vitórias e jogos participados.

###### atualizar_estado_times(estado, jogos_rodada)

É iterado `i` sobre os jogos de `jogos_rodadas` que são os jogos da rodada_atual de uma iteração do `for loop 1`.

Em cada iteração é aramazenada nas seguintes variáveis, as seguintes informações:
- `mandante` como o nome do time_mandante do jogo `i` de `jogos_rodada`
- `visitante` como o nome do time_visitante do jogo `i` de `jogos_rodada`
- `gols_mandante` como os gols_mandante do jogo `i`
- `gols_visitante` como os gols_visitantes do jogo `i`

Em seguida os valores de gols sofridos e marcados são atualizados para o time mandante e visitante. Isso é feito acessando esses itens da lista nomeada que é o estado e depois dentro de cada item há uma lista de zeros com o nome de cada time.

Depois é incrementado em 1 o número de jogos que cada um desses times disputaram. Esses valores são armazenados na lista nomeado do item `jogos` do `estado`.

Em seguida são feito dois ifs para verificar qual time ganhou o time de acordo com o número de gols da partida. Dependendo de quem ganhou o numero vitórias acumuladas desse time do item `vitorias` de `estado` é incrementado em 1.

Finalmente, o estado atualizado é retornado pela função.
##### criar_estado_times(times)

Cria uma lista nomeada em `zeros` que é 0 para cada time

Depois cria uma lista que possui 4 valores: gols_marcados, gols_sofridos, vitorias e jogos que será utilizada de variável preditora para regressão de poisson. Cada um desses itens da lista recebe a lista nomeada de zeros para cada time.