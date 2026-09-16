atualizar_acumuladores <- function(
    acumuladores,
    classificacao
) {
  
  campeao <- classificacao$time[1]
  
  rebaixados <- classificacao$time[
    classificacao$classificacao %in% 17:20
  ]
  
  pontos_campeao <- classificacao$pontos[1]
  
  # Pergunta 1
  acumuladores$titulos_por_time[campeao] <-
    acumuladores$titulos_por_time[campeao] + 1
  
  # Pergunta 2
  acumuladores$rebaixamentos_por_time[rebaixados] <-
    acumuladores$rebaixamentos_por_time[rebaixados] + 1
  
  # Pergunta 3
  acumuladores$numero_desempates <-
    acumuladores$numero_desempates +
    as.integer(
      classificacao$pontos[1] ==
        classificacao$pontos[2]
    )
  
  # Pergunta 4
  acumuladores$soma_pontos_campeao <-
    acumuladores$soma_pontos_campeao +
    pontos_campeao
  
  # Perguntas 5 e 6
  max_pontos <-
    length(acumuladores$total_por_pontos) - 1
  
  contagem_pontos <- tabulate(
    classificacao$pontos + 1,
    nbins = max_pontos + 1
  )
  
  acumuladores$total_por_pontos[] <-
    acumuladores$total_por_pontos +
    contagem_pontos
  
  acumuladores$campeoes_por_pontos[
    pontos_campeao + 1
  ] <-
    acumuladores$campeoes_por_pontos[
      pontos_campeao + 1
    ] + 1
  
  pontos_nao_rebaixados <-
    classificacao$pontos[
      classificacao$classificacao <= 16
    ]
  
  contagem_nao_rebaixados <- tabulate(
    pontos_nao_rebaixados + 1,
    nbins = max_pontos + 1
  )
  
  acumuladores$nao_rebaixados_por_pontos[] <-
    acumuladores$nao_rebaixados_por_pontos +
    contagem_nao_rebaixados
  
  acumuladores
}