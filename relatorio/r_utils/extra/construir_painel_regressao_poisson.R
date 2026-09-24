construir_painel_regressao_poisson <- function(jogos) {
  jogos <- jogos %>%
    filter(!is.na(gols_mandante), !is.na(gols_visitante)) %>%
    arrange(rodada)
  times <- sort(unique(c(jogos$time_mandante, jogos$time_visitante)))
  estado <- criar_estado_times(times)
  linhas <- list()
  indice <- 1

  for (rodada_atual in sort(unique(jogos$rodada))) {
    jogos_rodada <- jogos %>% filter(rodada == rodada_atual)

    for (i in seq_len(nrow(jogos_rodada))) {
      mandante <- as.character(jogos_rodada$time_mandante[i])
      visitante <- as.character(jogos_rodada$time_visitante[i])
      linhas[[indice]] <- criar_linha_regressao(
        estado, mandante, visitante, rodada_atual, TRUE
      ) %>% mutate(time = mandante, gols_marcados = jogos_rodada$gols_mandante[i])
      indice <- indice + 1
      linhas[[indice]] <- criar_linha_regressao(
        estado, visitante, mandante, rodada_atual, FALSE
      ) %>% mutate(time = visitante, gols_marcados = jogos_rodada$gols_visitante[i])
      indice <- indice + 1
    }

    # Os preditores de uma rodada usam somente informações até a rodada anterior.
    estado <- atualizar_estado_times(estado, jogos_rodada)
  }

  bind_rows(linhas)
}
