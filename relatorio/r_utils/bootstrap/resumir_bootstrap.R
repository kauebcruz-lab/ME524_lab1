resumir_bootstrap <- function(
    bootstrap,
    theta_estimado,
    phi_estimado,
    nivel = 0.95
) {
  
  alpha <- 1 - nivel
  
  theta_inf <- quantile(
    bootstrap[, "theta"],
    alpha / 2,
    names = FALSE
  )
  
  theta_sup <- quantile(
    bootstrap[, "theta"],
    1 - alpha / 2,
    names = FALSE
  )
  
  phi_inf <- quantile(
    bootstrap[, "phi"],
    alpha / 2,
    names = FALSE
  )
  
  phi_sup <- quantile(
    bootstrap[, "phi"],
    1 - alpha / 2,
    names = FALSE
  )
  
  tibble(
    parametro = c("theta", "phi"),
    estimativa = c(
      theta_estimado,
      phi_estimado
    ),
    erro_padrao_boot = c(
      sd(bootstrap[, "theta"]),
      sd(bootstrap[, "phi"])
    ),
    ic_inferior = c(
      theta_inf,
      phi_inf
    ),
    ic_superior = c(
      theta_sup,
      phi_sup
    ),
    largura_ic = c(
      theta_sup - theta_inf,
      phi_sup - phi_inf
    )
  )
}