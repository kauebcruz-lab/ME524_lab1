calcula_medias <- function(
  dados,
  coluna_time = time,
  coluna_gols_marcados = gols_marcados,
  coluna_gols_sofridos = gols_sofridos
) {
  dados %>%
    group_by({{ coluna_time }}) %>%
    summarise(
      theta = mean({{ coluna_gols_marcados }}),
      phi = mean({{ coluna_gols_sofridos }}),
      .groups = "drop"
    )
}
