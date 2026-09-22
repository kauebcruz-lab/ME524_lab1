executar_abordagem <- function(nome_abordagem, dados_tratados, jogos_futuros,
                               parametros, dados_completos, B, seed = NULL,
                               n_cores = 1,
                               avaliador = avaliar_poisson_combinada,
                               simulador = simular_jogos,
                               objetos_worker = character()) {
  tempo <- system.time(
    resultados_mc <- monte_carlo_campeonato(
      dados_tratados, jogos_futuros, parametros, B, seed, n_cores,
      simulador, objetos_worker
    )
  )["elapsed"]
  desempenho <- avaliador(dados_completos)
  tibble(
    abordagem = nome_abordagem,
    q3_prob_desempate = resultados_mc$prob_desempate,
    q4_media_pontos_campeao = resultados_mc$media_pontos_campeao,
    q5_pontos_90_campeao = resultados_mc$pontos_90_campeao,
    q6_pontos_95_nao_rebaixado = resultados_mc$pontos_95_nao_rebaixado,
    tempo_execucao_segundos = unname(tempo),
    sqe_medio = desempenho$sqe_medio,
    nll_medio = desempenho$nll_medio,
    jogos_treino = desempenho$jogos_treino,
    jogos_teste = desempenho$jogos_teste,
    q1_prob_campeao_por_time = list(
      resultados_mc$probabilidades_times %>% select(time, prob_campeao)
    ),
    q2_prob_rebaixamento_por_time = list(
      resultados_mc$probabilidades_times %>%
        select(time, prob_rebaixamento)
    ),
    resultados_por_pontos = list(resultados_mc$resultados_por_pontos)
  )
}

# Para garamtir indempotência, a função sempre recria os objetos de resultados
# Para salvar todos resultados juntos executar com todos resultados:
# resultados_abordagens <- bind_rows(
#   resultados_abordagens,
#   resultado_abordagem_2
# )

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
