simular_jogos <- function(
    jogos_futuros,
    parametros
) {
  
  jogos <- jogos_futuros %>%
    left_join(
      parametros %>%
        rename(
          time_mandante = time,
          theta_mandante = theta,
          phi_mandante = phi
        ),
      by = "time_mandante"
    ) %>%
    left_join(
      parametros %>%
        rename(
          time_visitante = time,
          theta_visitante = theta,
          phi_visitante = phi
        ),
      by = "time_visitante"
    ) %>%
    mutate(
      lambda_mandante =
        (theta_mandante + phi_visitante) / 2,
      
      lambda_visitante =
        (theta_visitante + phi_mandante) / 2,
      
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