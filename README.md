# ME524 Computação aplicada à estatística LAB1

##

O relatório será feito em latex no 

## Estrutura de arquivos

Nos arquivos `R/*_utils.R` serão registradas as funções que utilizaremos na análise. A ideia é
fazer de forma modularizada o lab.

Dentro de `relatorio/lab1.rmd` será feita as análises principais do lab. Nessa mesma pasta outros 
`*.rmds` podem ser criados.

Dentro de `data/`está o conjunto de dados do projeto.

Os resultados das análises serão armazenados em `data/resultados/`

## Instruções para replicação do projeto

- Instalar ou ter instalado o R 4.5.2
- Instalar ou ter instalado git na máquina
- Em um terminal do RStudio, executar `git clone <repo>`para clonar o repositório
- Abrir me524_lab1.Rproj
- Instalar as dependências executando no console `renv::restore()`

### Incluir novas dependências

Depois de instalar novos pacotes no renv, para atualizar a lista de dependências, é necessário executar no console `renv::snapshot()` 
e atualizar esse arquivo no GitHub