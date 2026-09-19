extrair_jogos_futuros <- function(
    dataframe,
    coluna_rodada = rodada,
    coluna_time_mandante = time_mandante,
    coluna_gols_mandante = gols_mandante,
    coluna_time_visitante = time_visitante,
    coluna_gols_visitante = gols_visitante
) {
  
  dataframe %>%
    filter(
      is.na({{ coluna_gols_mandante }}),
      is.na({{ coluna_gols_visitante }})
    ) %>%
    transmute(
      rodada = {{ coluna_rodada }},
      time_mandante = {{ coluna_time_mandante }},
      time_visitante = {{ coluna_time_visitante }}
    )
}