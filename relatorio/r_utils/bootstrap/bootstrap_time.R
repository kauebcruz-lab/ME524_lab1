bootstrap_time <- function(
    dados_time,
    B
) {
  
  n <- nrow(dados_time)
  
  gols_marcados <- dados_time$gols_marcados
  gols_sofridos <- dados_time$gols_sofridos
  
  pesos <- rmultinom(
    n = B,
    size = n,
    prob = rep(1 / n, n)
  )
  
  theta_boot <- drop(
    crossprod(
      gols_marcados,
      pesos
    )
  ) / n
  
  phi_boot <- drop(
    crossprod(
      gols_sofridos,
      pesos
    )
  ) / n
  
  cbind(
    theta = theta_boot,
    phi = phi_boot
  )
}