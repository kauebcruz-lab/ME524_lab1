simular_jogos_regressao_poisson <- function(contexto) {
  jogos_futuros <- contexto$jogos_futuros %>% arrange(rodada)
  estado <- contexto$estado_inicial
  modelos <- contexto$modelos
  resultados <- list()
  indice <- 1

  for (rodada_atual in sort(unique(jogos_futuros$rodada))) {
    jogos_rodada <- jogos_futuros %>% filter(rodada == rodada_atual)
    jogos_simulados_rodada <- jogos_rodada

    for (i in seq_len(nrow(jogos_rodada))) {
      mandante <- as.character(jogos_rodada$time_mandante[i])
      visitante <- as.character(jogos_rodada$time_visitante[i])
      lambda_mandante <- prever_lambda_regressao(
        modelos[[mandante]],
        criar_linha_regressao(estado, mandante, visitante, rodada_atual, TRUE)
      )
      lambda_visitante <- prever_lambda_regressao(
        modelos[[visitante]],
        criar_linha_regressao(estado, visitante, mandante, rodada_atual, FALSE)
      )
      jogos_simulados_rodada$gols_mandante[i] <- rpois(1, lambda_mandante)
      jogos_simulados_rodada$gols_visitante[i] <- rpois(1, lambda_visitante)
    }

    estado <- atualizar_estado_times(estado, jogos_simulados_rodada)
    resultados[[indice]] <- jogos_simulados_rodada
    indice <- indice + 1
  }

  jogos <- bind_rows(resultados)
  bind_rows(
    jogos %>% transmute(rodada, time = time_mandante,
                         gols_marcados = gols_mandante, gols_sofridos = gols_visitante),
    jogos %>% transmute(rodada, time = time_visitante,
                         gols_marcados = gols_visitante, gols_sofridos = gols_mandante)
  ) %>% arrange(rodada, time)
}
