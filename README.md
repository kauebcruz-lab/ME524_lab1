# ME524 Computação aplicada à estatística LAB1

##

O relatório será feito em latex no Overleaf.
https://www.overleaf.com/2691596631jqpmmrsfnytt#d74564

O relatório também é versionado no GitHub, porém somente eu posso fazer o push.

## Estrutura de arquivos

Nos arquivos `R/*_utils.R` serão registradas as funções que utilizaremos na análise. A ideia é
fazer de forma modularizada o lab.

Dentro de `relatorio/lab1.rmd` será feita as análises principais do lab. Nessa mesma pasta outros 
`*.rmds` podem ser criados.

Dentro de `data/`está o conjunto de dados do projeto.

Os resultados das análises serão armazenados em `data/resultados/`

## Instruções para replicação do projeto

- Instalar ou ter instalado o R 4.5.2
- Instalar ou ter instalado git na máquina
- Em um terminal do RStudio, executar `git clone <repo>`para clonar o repositório
- Abrir me524_lab1.Rproj
- Instalar as dependências executando no console `renv::restore()`

### Incluir novas dependências

Depois de instalar novos pacotes no renv, para atualizar a lista de dependências, é necessário executar no console `renv::snapshot()` 
e atualizar esse arquivo no GitHub

## Estrutura do código

O código foi estruturado em funções armazenadas em arquivos .R, importadas em lab1.Rmd com o comando source. 

| # | Função | O que faz | Entrada | Saída |
|:-:|:--|:--|:--|:--|
| 1 | `tratar_dados()` | Remove os jogos ainda não realizados e reorganiza os realizados em formato longo | `dataframe`: tabela com todos os jogos do campeonato, uma linha por jogo; os gols ficam `NA` nos jogos não realizados | Tabela em formato longo apenas com os jogos realizados: **2 linhas por jogo** (uma para cada time), ordenada por rodada e time |
| 2 | `extrair_jogos_futuros()` | Separa os jogos que ainda não aconteceram (gols `NA` para os dois times) | `dataframe`: a mesma tabela de jogos recebida por `tratar_dados()` | Tabela com **1 linha por jogo não realizado**, informando a rodada e os times mandante e visitante (sem gols) |
| 3 | `calcula_medias()` | Calcula, para cada time, as médias de gols por jogo usadas como parâmetros do modelo | `dados`: saída de `tratar_dados()` | Tabela com **1 linha por time**: `theta` (média de gols marcados por jogo) e `phi` (média de gols sofridos por jogo) |
| 4 | `inicializar_acumuladores()` | Cria os contadores zerados, que guardam apenas o necessário para responder às perguntas (as temporadas simuladas não são guardadas) | • `times`: vetor com os nomes dos times (`parametros$time`)<br>• `max_pontos`: número inteiro, máximo de pontos possível (padrão `114`, ou seja, 38 jogos × 3 pontos) | Uma lista com 7 contadores, todos iniciados em 0:<br>• `titulos_por_time` e `rebaixamentos_por_time`: um contador para cada time<br>• `numero_desempates` e `soma_pontos_campeao`: um único número cada<br>• `total_por_pontos`, `campeoes_por_pontos` e `nao_rebaixados_por_pontos`: um contador para cada total de pontos possível, de 0 a `max_pontos` |
| 5 | `simular_jogos()` | Sorteia o placar de cada jogo futuro. Os gols dos dois times são independentes: `gols_mandante ~ Poisson((theta_mandante + phi_visitante) / 2)` e `gols_visitante ~ Poisson((theta_visitante + phi_mandante) / 2)` | • `jogos_futuros`: saída de `extrair_jogos_futuros()`<br>• `parametros`: saída de `calcula_medias()`; todos os times de `jogos_futuros` precisam constar aqui | Tabela em formato longo com os jogos simulados (**2 linhas por jogo**), no mesmo formato da saída de `tratar_dados()`, o que permite juntá-la aos jogos realizados |
| 6 | `classificar_times()` | Monta a tabela de classificação a partir dos resultados dos jogos | `dados`: resultados em formato longo. Pode conter só os jogos realizados (classificação atual) ou os realizados mais os simulados (classificação final de uma temporada simulada) | Tabela de classificação com **1 linha por time**, da 1ª posição até a última, com pontos, vitórias, saldo de gols, gols marcados, gols sofridos e número de jogos. Ordenada por pontos; em caso de empate, por vitórias, saldo de gols e gols marcados (nesta ordem); se ainda houver empate, ordem alfabética |
| 7 | `atualizar_acumuladores()` | Atualiza os contadores com o resultado de **uma** temporada simulada | • `acumuladores`: lista criada por `inicializar_acumuladores()`<br>• `classificacao`: classificação final de uma temporada simulada, saída de `classificar_times()`. Precisa estar ordenada da 1ª à última posição; assume 20 times, com os 4 últimos rebaixados | A mesma lista `acumuladores`, agora com mais uma simulação contada:<br>• título: +1 para o campeão<br>• rebaixamento: +1 para os times das posições 17 a 20<br>• desempate: +1 se o 1º e o 2º terminaram com os mesmos pontos<br>• pontos do campeão: somados ao total<br>• contagens por total de pontos: cada time é contado no seu total de pontos; o campeão e os times das posições 1 a 16 (não rebaixados) também são contados à parte |
| 8 | `formatar_resultados()` | Transforma as contagens finais em probabilidades e nas respostas das perguntas | • `acumuladores`: lista final, depois de todas as simulações<br>• `B`: número de simulações<br>• `limite_campeao`: probabilidade mínima usada na Pergunta 5 (padrão `0.90`)<br>• `limite_nao_rebaixado`: probabilidade mínima usada na Pergunta 6 (padrão `0.95`) | Uma lista com 6 resultados:<br>• `probabilidades_times`: para cada time, a probabilidade de ser campeão e a de ser rebaixado (Perguntas 1 e 2)<br>• `prob_desempate`: probabilidade de o título ser decidido pelos critérios de desempate (Pergunta 3)<br>• `media_pontos_campeao`: número esperado de pontos do campeão (Pergunta 4)<br>• `resultados_por_pontos`: tabela com uma linha para cada total de pontos possível, com quantas vezes ele apareceu, quantas vezes foi de um campeão ou de um time não rebaixado, e as proporções correspondentes (`NA` se o total nunca apareceu)<br>• `pontos_90_campeao`: menor total de pontos em que a proporção de campeões atinge `limite_campeao`, ou `NA` se nenhum atinge (Pergunta 5)<br>• `pontos_95_nao_rebaixado`: menor total de pontos em que a proporção de não rebaixados atinge `limite_nao_rebaixado`, ou `NA` se nenhum atinge (Pergunta 6) |
| 9 | `monte_carlo_campeonato()` | Roda a simulação completa: cria os contadores (4), repete `B` vezes (simular os jogos futuros (5), classificar (6) e atualizar os contadores (7)) e, no fim, formata os resultados (8) | • `dados_tratados`: saída de `tratar_dados()`<br>• `jogos_futuros`: saída de `extrair_jogos_futuros()`<br>• `parametros`: saída de `calcula_medias()`<br>• `B`: número de simulações | A mesma lista de 6 resultados devolvida por `formatar_resultados()` |
