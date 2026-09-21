formatar_resultados <- function(
    acumuladores,
    B,
    limite_campeao = 0.90,
    limite_nao_rebaixado = 0.95
) {
  
  # Perguntas 1 e 2
  probabilidades_times <- tibble(
    time = names(acumuladores$titulos_por_time),
    
    prob_campeao =
      as.numeric(acumuladores$titulos_por_time) / B,
    
    prob_rebaixamento =
      as.numeric(
        acumuladores$rebaixamentos_por_time
      ) / B
  )
  
  # Pergunta 3
  prob_desempate <-
    acumuladores$numero_desempates / B
  
  # Pergunta 4
  media_pontos_campeao <-
    acumuladores$soma_pontos_campeao / B
  
  # Perguntas 5 e 6
  pontos <- as.integer(
    names(acumuladores$total_por_pontos)
  )
  
  frequencia <- as.integer(
    acumuladores$total_por_pontos
  )
  
  frequencia_campeao <- as.integer(
    acumuladores$campeoes_por_pontos
  )
  
  frequencia_nao_rebaixado <- as.integer(
    acumuladores$nao_rebaixados_por_pontos
  )
  
  resultados_por_pontos <- tibble(
    pontos = pontos,
    frequencia = frequencia,
    frequencia_campeao = frequencia_campeao,
    frequencia_nao_rebaixado =
      frequencia_nao_rebaixado,
    
    prob_campeao = if_else(
      frequencia > 0,
      frequencia_campeao / frequencia,
      NA_real_
    ),
    
    prob_nao_rebaixado = if_else(
      frequencia > 0,
      frequencia_nao_rebaixado / frequencia,
      NA_real_
    )
  )
  
  candidatos_campeao <-
    resultados_por_pontos$pontos[
      !is.na(resultados_por_pontos$prob_campeao) &
        resultados_por_pontos$prob_campeao >= limite_campeao
    ]
  
  candidatos_nao_rebaixado <-
    resultados_por_pontos$pontos[
      !is.na(
        resultados_por_pontos$prob_nao_rebaixado
      ) &
        resultados_por_pontos$prob_nao_rebaixado >=
        limite_nao_rebaixado
    ]
  
  pontos_90_campeao <-
    if (length(candidatos_campeao) > 0) {
      min(candidatos_campeao)
    } else {
      NA_integer_
    }
  
  pontos_95_nao_rebaixado <-
    if (length(candidatos_nao_rebaixado) > 0) {
      min(candidatos_nao_rebaixado)
    } else {
      NA_integer_
    }
  
  list(
    probabilidades_times = probabilidades_times,
    
    prob_desempate = prob_desempate,
    
    media_pontos_campeao = media_pontos_campeao,
    
    resultados_por_pontos = resultados_por_pontos,
    
    pontos_90_campeao = pontos_90_campeao,
    
    pontos_95_nao_rebaixado =
      pontos_95_nao_rebaixado
  )
}