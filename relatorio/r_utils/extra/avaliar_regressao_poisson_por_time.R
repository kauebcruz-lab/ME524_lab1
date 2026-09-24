avaliar_regressao_poisson_por_time <- function(dados, proporcao_treino = 0.80) {
  realizados <- dados %>% filter(!is.na(gols_mandante), !is.na(gols_visitante))
  rodadas <- sort(unique(realizados$rodada))
  fim_treino <- rodadas[floor(length(rodadas) * proporcao_treino)]
  treino <- realizados %>% filter(rodada <= fim_treino)
  teste <- realizados %>% filter(rodada > fim_treino)
  modelos <- ajustar_regressoes_poisson_por_time(treino)

  estado <- criar_estado_times(names(modelos))
  estado <- atualizar_estado_times(estado, treino)
  previsoes <- list()
  indice <- 1

  for (rodada_atual in sort(unique(teste$rodada))) {
    jogos_rodada <- teste %>% filter(rodada == rodada_atual)
    for (i in seq_len(nrow(jogos_rodada))) {
      mandante <- as.character(jogos_rodada$time_mandante[i])
      visitante <- as.character(jogos_rodada$time_visitante[i])
      previsoes[[indice]] <- tibble(
        gols_mandante = jogos_rodada$gols_mandante[i],
        gols_visitante = jogos_rodada$gols_visitante[i],
        lambda_mandante = prever_lambda_regressao(
          modelos[[mandante]],
          criar_linha_regressao(estado, mandante, visitante, rodada_atual, TRUE)
        ),
        lambda_visitante = prever_lambda_regressao(
          modelos[[visitante]],
          criar_linha_regressao(estado, visitante, mandante, rodada_atual, FALSE)
        )
      )
      indice <- indice + 1
    }
    estado <- atualizar_estado_times(estado, jogos_rodada)
  }

  previsoes <- bind_rows(previsoes)
  erros <- c(
    (previsoes$gols_mandante - previsoes$lambda_mandante)^2,
    (previsoes$gols_visitante - previsoes$lambda_visitante)^2
  )
  nll <- -c(
    dpois(previsoes$gols_mandante, previsoes$lambda_mandante, log = TRUE),
    dpois(previsoes$gols_visitante, previsoes$lambda_visitante, log = TRUE)
  )
  tibble(sqe_medio = mean(erros), nll_medio = mean(nll),
         jogos_treino = nrow(treino), jogos_teste = nrow(teste),
         rodada_final_treino = fim_treino)
}
