simular_jogos <- function(
    jogos_futuros
) {
  
  jogos <- jogos_futuros %>%
    mutate(
      gols_mandante = rpois(
        n(),
        lambda_mandante
      ),
      
      gols_visitante = rpois(
        n(),
        lambda_visitante
      )
    )
  
  jogos_casa <- jogos %>%
    transmute(
      rodada,
      time = time_mandante,
      gols_marcados = gols_mandante,
      gols_sofridos = gols_visitante
    )
  
  jogos_fora <- jogos %>%
    transmute(
      rodada,
      time = time_visitante,
      gols_marcados = gols_visitante,
      gols_sofridos = gols_mandante
    )
  
  bind_rows(
    jogos_casa,
    jogos_fora
  ) %>%
    arrange(
      rodada,
      time
    )
}