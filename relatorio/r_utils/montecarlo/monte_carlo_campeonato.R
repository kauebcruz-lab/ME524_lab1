monte_carlo_campeonato <- function(
    dados_tratados,
    jogos_futuros,
    parametros,
    B,
    seed = NULL,
    n_cores = 1,
    simulador = simular_jogos,
    objetos_worker = character()
) {
  if (B < 1) stop("B deve ser maior ou igual a 1.")
  if (n_cores < 1) stop("n_cores deve ser maior ou igual a 1.")

  n_cores <- min(as.integer(n_cores), B)
  repeticoes_por_bloco <- rep(B %/% n_cores, n_cores)
  
  # Seleciona os primeiros B %% n_cores elementos e adiciona 1 a cada um deles.
  repeticoes_por_bloco[seq_len(B %% n_cores)] <-
    repeticoes_por_bloco[seq_len(B %% n_cores)] + 1

  executar_bloco <- function(n_repeticoes) {
    acumuladores <- inicializar_acumuladores(parametros$time)

    for (b in seq_len(n_repeticoes)) {
      jogos_simulados <- simulador(jogos_futuros)
      temporada_completa <- bind_rows(dados_tratados, jogos_simulados)
      classificacao_simulada <- classificar_times(temporada_completa)
      acumuladores <- atualizar_acumuladores(
        acumuladores, classificacao_simulada
      )
    }

    acumuladores
  }

  if (n_cores == 1) {
    if (!is.null(seed)) set.seed(seed)
    acumuladores <- executar_bloco(B)
  } else {
    cluster <- parallel::makeCluster(n_cores)
    on.exit(parallel::stopCluster(cluster), add = TRUE)

    parallel::clusterEvalQ(cluster, library(dplyr))
    parallel::clusterExport(
      cluster,
      c(
        "dados_tratados", "jogos_futuros", "parametros", "simulador",
        "classificar_times", "inicializar_acumuladores",
        "atualizar_acumuladores", "executar_bloco", objetos_worker
      ),
      envir = environment()
    )

    # Fluxos aleatórios independentes e repetíveis para a mesma seed e n_cores.
    parallel::clusterSetRNGStream(cluster, iseed = seed)
    acumuladores <- combinar_acumuladores(
      parallel::parLapply(cluster, repeticoes_por_bloco, executar_bloco)
    )
  }

  formatar_resultados(acumuladores, B)
}
