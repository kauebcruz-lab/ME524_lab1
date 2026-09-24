criar_estado_times <- function(times) {
  zeros <- setNames(rep(0, length(times)), times)
  list(
    gols_marcados = zeros,
    gols_sofridos = zeros,
    vitorias = zeros,
    jogos = zeros
  )
}
