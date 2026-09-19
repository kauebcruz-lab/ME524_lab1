monte_carlo_campeonato <- function(
    dados_tratados,
    jogos_futuros,
    parametros,
    B
) {
  
  acumuladores <- inicializar_acumuladores(
    parametros$time
  )
  
  for (b in seq_len(B)) {
    
    # Simula todos os jogos ainda não realizados
    jogos_simulados <- simular_jogos(
      jogos_futuros,
      parametros
    )
    
    # Passado observado + futuro simulado
    temporada_completa <- bind_rows(
      dados_tratados,
      jogos_simulados
    )
    
    # Classificação desta realização Monte Carlo
    classificacao_simulada <- classificar_times(
      temporada_completa
    )
    
    # Extrai apenas informações relevantes
    acumuladores <- atualizar_acumuladores(
      acumuladores,
      classificacao_simulada
    )
  }
  
  # Converte acumuladores nas respostas finais
  formatar_resultados(
    acumuladores,
    B
  )
}