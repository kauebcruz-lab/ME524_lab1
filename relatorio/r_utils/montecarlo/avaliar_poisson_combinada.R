avaliar_poisson_combinada <- function(dados, proporcao_treino = 0.80) {
  jogos_realizados <- dados %>% filter(!is.na(gols_mandante), !is.na(gols_visitante))
  rodadas <- sort(unique(jogos_realizados$rodada))
  n_rodadas_treino <- floor(length(rodadas) * proporcao_treino)
  if (n_rodadas_treino < 1 || n_rodadas_treino >= length(rodadas)) {
    stop("São necessárias rodadas realizadas para treino e para teste.")
  }
  rodada_final_treino <- rodadas[n_rodadas_treino]
  treino <- jogos_realizados %>% filter(rodada <= rodada_final_treino)
  teste <- jogos_realizados %>% filter(rodada > rodada_final_treino)
  parametros <- estimar_parametros(tratar_dados(treino))
  previsoes <- calcular_lambdas_poisson_combinada(teste, parametros)
  erros_quadrados <- c(
    (previsoes$gols_mandante - previsoes$lambda_mandante)^2,
    (previsoes$gols_visitante - previsoes$lambda_visitante)^2
  )
  nll <- -c(
    dpois(previsoes$gols_mandante, previsoes$lambda_mandante, log = TRUE),
    dpois(previsoes$gols_visitante, previsoes$lambda_visitante, log = TRUE)
  )
  tibble(sqe_medio = mean(erros_quadrados), nll_medio = mean(nll),
         jogos_treino = nrow(treino), jogos_teste = nrow(teste),
         rodada_final_treino = rodada_final_treino)
}
