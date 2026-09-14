calcula_medias <- function(dataframe) 
{
  
    group_by(dataframe, time) %>%
    summarise(
      tetha = mean(gols_marcados),
      phi   = mean(gols_sofridos),
      
      .groups = "drop"
    )
}