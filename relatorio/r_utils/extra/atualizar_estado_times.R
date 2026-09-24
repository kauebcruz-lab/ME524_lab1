atualizar_estado_times <- function(estado, jogos) {
  for (i in seq_len(nrow(jogos))) {
    mandante <- as.character(jogos$time_mandante[i])
    visitante <- as.character(jogos$time_visitante[i])
    gols_mandante <- jogos$gols_mandante[i]
    gols_visitante <- jogos$gols_visitante[i]

    estado$gols_marcados[mandante] <-
      estado$gols_marcados[mandante] + gols_mandante
    estado$gols_sofridos[mandante] <-
      estado$gols_sofridos[mandante] + gols_visitante
    estado$gols_marcados[visitante] <-
      estado$gols_marcados[visitante] + gols_visitante
    estado$gols_sofridos[visitante] <-
      estado$gols_sofridos[visitante] + gols_mandante
    estado$jogos[c(mandante, visitante)] <-
      estado$jogos[c(mandante, visitante)] + 1

    if (gols_mandante > gols_visitante) {
      estado$vitorias[mandante] <- estado$vitorias[mandante] + 1
    } else if (gols_visitante > gols_mandante) {
      estado$vitorias[visitante] <- estado$vitorias[visitante] + 1
    }
  }

  estado
}
