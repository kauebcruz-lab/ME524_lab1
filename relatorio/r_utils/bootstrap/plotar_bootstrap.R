plotar_bootstrap <- function(
    resultados_bootstrap
) {
  
  colunas_necessarias <- c(
    "time",
    "parametro",
    "estimativa",
    "ic_inferior",
    "ic_superior"
  )
  
  if (!all(colunas_necessarias %in% names(resultados_bootstrap))) {
    stop("resultados_bootstrap não possui todas as colunas necessárias.")
  }
  
  resultados_bootstrap %>%
    mutate(
      parametro = factor(
        parametro,
        levels = c("theta", "phi"),
        labels = c(
          "Gols marcados (theta)",
          "Gols sofridos (phi)"
        )
      )
    ) %>%
    ggplot(
      aes(
        x = time,
        y = estimativa
      )
    ) +
    geom_errorbar(
      aes(
        ymin = ic_inferior,
        ymax = ic_superior
      ),
      width = 0.2
    ) +
    geom_point(
      size = 2
    ) +
    facet_wrap(
      ~ parametro,
      ncol = 2
    ) +
    coord_flip() +
    labs(
      x = NULL,
      y = "Média de gols por partida",
      title = "Intervalos de confiança bootstrap por equipe",
      subtitle = "Estimativas das médias de gols marcados e sofridos"
    ) +
    theme_minimal()
}