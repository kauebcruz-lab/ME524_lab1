tratar_dados <- function(
  dataframe,
  coluna_rodada = rodada,
  coluna_time_mandante = time_mandante,
  coluna_gols_mandante = gols_mandante,
  coluna_time_visitante = time_visitante,
  coluna_gols_visitante = gols_visitante
) 
{
  # filtrando NAs
  dataframe <- filter(dataframe, !is.na({{ coluna_gols_mandante }}), !is.na({{ coluna_gols_visitante }}))
  
  # listando jogos em casa
  jogos_casa <- select(dataframe, 
                       rodada = {{ coluna_rodada }},
                       time = {{ coluna_time_mandante }}, 
                       gols_marcados = {{ coluna_gols_mandante }}, 
                       gols_sofridos = {{ coluna_gols_visitante }})
  
  # listando jogos fora de casa
  jogos_fora <- select(dataframe,
                       rodada = {{ coluna_rodada }},
                       time = {{ coluna_time_visitante }},
                       gols_marcados = {{ coluna_gols_visitante }},
                       gols_sofridos = {{ coluna_gols_mandante }})
  
  # unificando em uma única tabela e ordenando
  bind_rows(jogos_casa,jogos_fora) %>%
  arrange(rodada, time)
  
}
