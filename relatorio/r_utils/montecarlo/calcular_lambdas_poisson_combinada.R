calcular_lambdas_poisson_combinada <- function(jogos, parametros) {
  jogos %>%
    left_join(parametros %>% rename(time_mandante = time, theta_mandante = theta, phi_mandante = phi), by = "time_mandante") %>%
    left_join(parametros %>% rename(time_visitante = time, theta_visitante = theta, phi_visitante = phi), by = "time_visitante") %>%
    mutate(
      lambda_mandante = (theta_mandante + phi_visitante) / 2,
      lambda_visitante = (theta_visitante + phi_mandante) / 2
    )
}
