criar_linha_regressao <- function(estado, time, adversario, rodada, em_casa) {
  tibble(
    em_casa = as.integer(em_casa),
    gols_acumulados = unname(estado$gols_marcados[time]),
    vitorias_acumuladas = unname(estado$vitorias[time]),
    rodada = rodada,
    defesa_adversario = unname(defesa_atual(estado, adversario))
  )
}
