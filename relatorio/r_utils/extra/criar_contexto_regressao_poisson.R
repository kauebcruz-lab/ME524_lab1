criar_contexto_regressao_poisson <- function(jogos_futuros, dados_realizados,
                                               modelos) {
  times <- names(modelos)
  estado <- criar_estado_times(times)

  dados_observados <- dados_realizados %>%
    filter(!is.na(gols_mandante), !is.na(gols_visitante)) %>%
    select(rodada, time_mandante, gols_mandante, time_visitante, gols_visitante)

  list(
    jogos_futuros = jogos_futuros,
    modelos = modelos,
    estado_inicial = atualizar_estado_times(estado, dados_observados)
  )
}
