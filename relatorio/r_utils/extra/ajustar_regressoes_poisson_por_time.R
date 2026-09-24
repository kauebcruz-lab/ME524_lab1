ajustar_regressoes_poisson_por_time <- function(jogos) {
  painel <- construir_painel_regressao_poisson(jogos)
  paineis_por_time <- split(painel, painel$time)

  lapply(paineis_por_time, function(dados_time) {
    list(
      ajuste = glm(
        gols_marcados ~ em_casa + gols_acumulados + vitorias_acumuladas +
          rodada + defesa_adversario,
        data = dados_time,
        family = poisson(link = "log")
      ),
      media_gols = mean(dados_time$gols_marcados)
    )
  })
}
