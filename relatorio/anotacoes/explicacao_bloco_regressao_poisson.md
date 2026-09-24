Primeiro a função `ajustar_regressoes_por_times(dados)` é executada e é armazenado em `modelos_regressao` uma lista nomeada por time, em que cada item possui uma lista nomeada com o modelo de regressão de poisson em `ajuste` e média de gols do time em `media_gols`.

Em seguida, em `parametros_regressao` é armazenado um tibble com uma coluna de time, listando os 20 times que participam do campeonato.

Então, é armazenado em `context_regressao` a saída  de 
```r
criar_contexto_regressao_poisson(
  jogos_futuros = extrair_jogos_futuros(dados),
  dados_realizados = dados,
  modelos = modelos_regressao
)
```
, que é 
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

