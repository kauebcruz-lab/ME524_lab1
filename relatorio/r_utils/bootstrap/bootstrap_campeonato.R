bootstrap_campeonato <- function(
    dados_tratados,
    parametros,
    B,
    nivel = 0.95
) {
  
  # Separa os dados uma única vez por time
  dados_por_time <- split(
    dados_tratados,
    dados_tratados$time
  )
  
  times <- names(dados_por_time)
  
  # Facilita a busca das estimativas originais
  theta_estimado <- setNames(
    parametros$theta,
    parametros$time
  )
  
  phi_estimado <- setNames(
    parametros$phi,
    parametros$time
  )
  
  # Pré-aloca a lista de resultados
  resultados <- vector(
    "list",
    length(times)
  )
  
  for (i in seq_along(times)) {
    
    time_atual <- times[i]
    
    # B replicações bootstrap para o time atual
    bootstrap <- bootstrap_time(
      dados_time = dados_por_time[[time_atual]],
      B = B
    )
    
    # IC e medidas de variabilidade
    resumo <- resumir_bootstrap(
      bootstrap = bootstrap,
      theta_estimado = theta_estimado[[time_atual]],
      phi_estimado = phi_estimado[[time_atual]],
      nivel = nivel
    )
    
    resumo$time <- time_atual
    
    resultados[[i]] <- resumo
  }
  
  bind_rows(resultados) %>%
    select(
      time,
      everything()
    )
}