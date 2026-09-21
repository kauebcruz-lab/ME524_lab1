inicializar_acumuladores <- function(
    times,
    max_pontos = 114
) {
  
  pontos_possiveis <- 0:max_pontos
  
  zeros_times <- setNames(
    rep(0, length(times)),
    times
  )
  
  zeros_pontos <- setNames(
    rep(0, length(pontos_possiveis)),
    pontos_possiveis
  )
  
  list(
    titulos_por_time = zeros_times,
    rebaixamentos_por_time = zeros_times,
    numero_desempates = 0,
    soma_pontos_campeao = 0,
    total_por_pontos = zeros_pontos,
    campeoes_por_pontos = zeros_pontos,
    nao_rebaixados_por_pontos = zeros_pontos
  )
}