criar_estado_times <- function(times) {
  zeros <- setNames(rep(0, length(times)), times)
  list(
    gols_marcados = zeros,
    gols_sofridos = zeros,
    vitorias = zeros,
    jogos = zeros
  )
}

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

defesa_atual <- function(estado, time) {
  if (estado$jogos[time] == 0) return(1)
  estado$gols_sofridos[time] / estado$jogos[time]
}

criar_linha_regressao <- function(estado, time, adversario, rodada, em_casa) {
  tibble(
    em_casa = as.integer(em_casa),
    gols_acumulados = unname(estado$gols_marcados[time]),
    vitorias_acumuladas = unname(estado$vitorias[time]),
    rodada = rodada,
    defesa_adversario = unname(defesa_atual(estado, adversario))
  )
}

construir_painel_regressao_poisson <- function(jogos) {
  jogos <- jogos %>%
    filter(!is.na(gols_mandante), !is.na(gols_visitante)) %>%
    arrange(rodada)
  times <- sort(unique(c(jogos$time_mandante, jogos$time_visitante)))
  estado <- criar_estado_times(times)
  linhas <- list()
  indice <- 1

  for (rodada_atual in sort(unique(jogos$rodada))) {
    jogos_rodada <- jogos %>% filter(rodada == rodada_atual)

    for (i in seq_len(nrow(jogos_rodada))) {
      mandante <- as.character(jogos_rodada$time_mandante[i])
      visitante <- as.character(jogos_rodada$time_visitante[i])
      linhas[[indice]] <- criar_linha_regressao(
        estado, mandante, visitante, rodada_atual, TRUE
      ) %>% mutate(time = mandante, gols_marcados = jogos_rodada$gols_mandante[i])
      indice <- indice + 1
      linhas[[indice]] <- criar_linha_regressao(
        estado, visitante, mandante, rodada_atual, FALSE
      ) %>% mutate(time = visitante, gols_marcados = jogos_rodada$gols_visitante[i])
      indice <- indice + 1
    }

    # Os preditores de uma rodada usam somente informações até a rodada anterior.
    estado <- atualizar_estado_times(estado, jogos_rodada)
  }

  bind_rows(linhas)
}

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

prever_lambda_regressao <- function(modelo, linha) {
  lambda <- suppressWarnings(
    predict(modelo$ajuste, newdata = linha, type = "response")
  )
  if (is.na(lambda) || !is.finite(lambda)) lambda <- modelo$media_gols
  max(as.numeric(lambda), 1e-8)
}

criar_contexto_regressao_poisson <- function(jogos_futuros, dados_realizados,
                                               modelos) {
  times <- names(modelos)
  estado <- criar_estado_times(times)

  dados_observados <- dados_realizados %>%
    filter(!is.na(gols_mandante), !is.na(gols_visitante)) %>%
    select(rodada, time_mandante, gols_mandante, time_visitante, gols_visitante)

  list(
    jogos_futuros = jogos_futuros,
    modelos = modelos,
    estado_inicial = atualizar_estado_times(estado, dados_observados)
  )
}

simular_jogos_regressao_poisson <- function(contexto) {
  jogos_futuros <- contexto$jogos_futuros %>% arrange(rodada)
  estado <- contexto$estado_inicial
  modelos <- contexto$modelos
  resultados <- list()
  indice <- 1

  for (rodada_atual in sort(unique(jogos_futuros$rodada))) {
    jogos_rodada <- jogos_futuros %>% filter(rodada == rodada_atual)
    jogos_simulados_rodada <- jogos_rodada

    for (i in seq_len(nrow(jogos_rodada))) {
      mandante <- as.character(jogos_rodada$time_mandante[i])
      visitante <- as.character(jogos_rodada$time_visitante[i])
      lambda_mandante <- prever_lambda_regressao(
        modelos[[mandante]],
        criar_linha_regressao(estado, mandante, visitante, rodada_atual, TRUE)
      )
      lambda_visitante <- prever_lambda_regressao(
        modelos[[visitante]],
        criar_linha_regressao(estado, visitante, mandante, rodada_atual, FALSE)
      )
      jogos_simulados_rodada$gols_mandante[i] <- rpois(1, lambda_mandante)
      jogos_simulados_rodada$gols_visitante[i] <- rpois(1, lambda_visitante)
    }

    estado <- atualizar_estado_times(estado, jogos_simulados_rodada)
    resultados[[indice]] <- jogos_simulados_rodada
    indice <- indice + 1
  }

  jogos <- bind_rows(resultados)
  bind_rows(
    jogos %>% transmute(rodada, time = time_mandante,
                         gols_marcados = gols_mandante, gols_sofridos = gols_visitante),
    jogos %>% transmute(rodada, time = time_visitante,
                         gols_marcados = gols_visitante, gols_sofridos = gols_mandante)
  ) %>% arrange(rodada, time)
}

avaliar_regressao_poisson_por_time <- function(dados, proporcao_treino = 0.80) {
  realizados <- dados %>% filter(!is.na(gols_mandante), !is.na(gols_visitante))
  rodadas <- sort(unique(realizados$rodada))
  fim_treino <- rodadas[floor(length(rodadas) * proporcao_treino)]
  treino <- realizados %>% filter(rodada <= fim_treino)
  teste <- realizados %>% filter(rodada > fim_treino)
  modelos <- ajustar_regressoes_poisson_por_time(treino)

  estado <- criar_estado_times(names(modelos))
  estado <- atualizar_estado_times(estado, treino)
  previsoes <- list()
  indice <- 1

  for (rodada_atual in sort(unique(teste$rodada))) {
    jogos_rodada <- teste %>% filter(rodada == rodada_atual)
    for (i in seq_len(nrow(jogos_rodada))) {
      mandante <- as.character(jogos_rodada$time_mandante[i])
      visitante <- as.character(jogos_rodada$time_visitante[i])
      previsoes[[indice]] <- tibble(
        gols_mandante = jogos_rodada$gols_mandante[i],
        gols_visitante = jogos_rodada$gols_visitante[i],
        lambda_mandante = prever_lambda_regressao(
          modelos[[mandante]],
          criar_linha_regressao(estado, mandante, visitante, rodada_atual, TRUE)
        ),
        lambda_visitante = prever_lambda_regressao(
          modelos[[visitante]],
          criar_linha_regressao(estado, visitante, mandante, rodada_atual, FALSE)
        )
      )
      indice <- indice + 1
    }
    estado <- atualizar_estado_times(estado, jogos_rodada)
  }

  previsoes <- bind_rows(previsoes)
  erros <- c(
    (previsoes$gols_mandante - previsoes$lambda_mandante)^2,
    (previsoes$gols_visitante - previsoes$lambda_visitante)^2
  )
  nll <- -c(
    dpois(previsoes$gols_mandante, previsoes$lambda_mandante, log = TRUE),
    dpois(previsoes$gols_visitante, previsoes$lambda_visitante, log = TRUE)
  )
  tibble(sqe_medio = mean(erros), nll_medio = mean(nll),
         jogos_treino = nrow(treino), jogos_teste = nrow(teste),
         rodada_final_treino = fim_treino)
}
