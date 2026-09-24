classificar_times <- function(
  dados,
  coluna_time = time,
  coluna_gols_marcados = gols_marcados,
  coluna_gols_sofridos = gols_sofridos
) {
  dados %>%
    mutate(
      pontos = case_when(
        {{ coluna_gols_marcados }} > {{ coluna_gols_sofridos }} ~ 3,
        {{ coluna_gols_marcados }} == {{ coluna_gols_sofridos }} ~ 1,
        TRUE ~ 0
      ),
      vitoria = as.integer(
        {{ coluna_gols_marcados }} > {{ coluna_gols_sofridos }}
      )
    ) %>%
    group_by({{ coluna_time }}) %>%
    summarise(
      pontos = sum(pontos),
      vitorias = sum(vitoria),
      gols_marcados = sum({{ coluna_gols_marcados }}),
      gols_sofridos = sum({{ coluna_gols_sofridos }}),
      jogos = n(),
      .groups = "drop"
    ) %>%
    mutate(
      saldo_gols = gols_marcados - gols_sofridos
    ) %>%
    arrange(
      desc(pontos),
      desc(vitorias),
      desc(saldo_gols),
      desc(gols_marcados)
    ) %>%
    mutate(
      classificacao = row_number()
    ) %>%
    select(
      classificacao,
      {{ coluna_time }},
      pontos,
      vitorias,
      saldo_gols,
      gols_marcados,
      gols_sofridos,
      jogos
    )
}
