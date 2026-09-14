tratar_dados <- function(dataframe) 
{
  # filtrando NAs
  dataframe <- filter(dataframe, !is.na(gols_mandante), !is.na(gols_visitante))
  
  # listando jogos em casa
  jogos_casa <- select(dataframe, 
                       rodada,
                       time = time_mandante, 
                       gols_marcados = gols_mandante, 
                       gols_sofridos = gols_visitante)
  
  # listando jogos fora de casa
  jogos_fora <- select(dataframe,
                       rodada,
                       time = time_visitante,
                       gols_marcados = gols_visitante,
                       gols_sofridos = gols_mandante)
  
  # unificando em uma única tabela e ordenando
  bind_rows(jogos_casa,jogos_fora) %>%
  arrange(rodada, time)
  
}
