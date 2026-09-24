defesa_atual <- function(estado, time) {
  if (estado$jogos[time] == 0) return(1)
  estado$gols_sofridos[time] / estado$jogos[time]
}
