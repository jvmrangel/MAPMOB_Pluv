# Instale a biblioteca arrow se ainda não estiver instalada
# install.packages("arrow")

# Carregue a biblioteca arrow
library(arrow)

# Carregue a biblioteca dplyr
library(dplyr)

# Defina os nomes das pastas e arquivos
pastas <- c("~/pp-tema2-main/DST-A", "~/pp-tema2-main/DST-B", "~/pp-tema2-main/DST-C", "~/pp-tema2-main/DST-D", "~/pp-tema2-main/DST-E")
arquivo <- "G1-2022-02-10.parquet"

# Crie um vetor para armazenar os dados
dados <- vector("list", length = length(pastas))

# Leia os arquivos Parquet de cada pasta
for (i in seq_along(pastas)) {
  caminho <- file.path(pastas[i], arquivo)
  dados[[i]] <- arrow::read_parquet(caminho)
}

# Remova a coluna "SWVERSION" de cada data frame
dados <- lapply(dados, function(df) df[, !colnames(df) %in% "SWVERSION"])

# Junte os dados utilizando a coluna "ID" como chave principal
dados_juntos <- Reduce(function(x, y) full_join(x, y, by = "ID"), dados)

# Exiba os dados juntos
print(dados_juntos)
