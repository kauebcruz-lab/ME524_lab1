prever_lambda_regressao <- function(modelo, linha) {
  lambda <- suppressWarnings(
    predict(modelo$ajuste, newdata = linha, type = "response")
  )
  if (is.na(lambda) || !is.finite(lambda)) lambda <- modelo$media_gols
  max(as.numeric(lambda), 1e-8)
}
