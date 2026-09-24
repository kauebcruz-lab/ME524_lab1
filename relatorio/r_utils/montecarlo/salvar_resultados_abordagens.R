# salvar_resultados_abordagens(
#   resultados_abordagens,
#   resultados_path
# )

salvar_resultados_abordagens <- function(resultados_abordagens, resultados_path) {
  dir.create(resultados_path, recursive = TRUE, showWarnings = FALSE)
  saveRDS(resultados_abordagens, file.path(resultados_path, "resultados_abordagens.rds"))
  readr::write_csv(
    resultados_abordagens %>%
      select(
        -q1_prob_campeao_por_time,
        -q2_prob_rebaixamento_por_time,
        -resultados_por_pontos
      ),
    file.path(resultados_path, "resultados_abordagens_resumo.csv")
  )
}
