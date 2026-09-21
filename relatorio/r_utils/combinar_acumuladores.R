combinar_acumuladores <- function(acumuladores_lista) {
  Reduce(
    function(acumulador_a, acumulador_b) {
      list(
        titulos_por_time = acumulador_a$titulos_por_time + acumulador_b$titulos_por_time,
        rebaixamentos_por_time = acumulador_a$rebaixamentos_por_time + acumulador_b$rebaixamentos_por_time,
        numero_desempates = acumulador_a$numero_desempates + acumulador_b$numero_desempates,
        soma_pontos_campeao = acumulador_a$soma_pontos_campeao + acumulador_b$soma_pontos_campeao,
        total_por_pontos = acumulador_a$total_por_pontos + acumulador_b$total_por_pontos,
        campeoes_por_pontos = acumulador_a$campeoes_por_pontos + acumulador_b$campeoes_por_pontos,
        nao_rebaixados_por_pontos = acumulador_a$nao_rebaixados_por_pontos + acumulador_b$nao_rebaixados_por_pontos
      )
    }, acumuladores_lista
  )
}
