# Instale a biblioteca arrow se ainda não estiver instalada
# install.packages("arrow")
install.packages("dplyr")

library(arrow)
library(dplyr)
library(stringr)

#lendo arquivos de chuva
df <- arrow::read_parquet("~/pp-tema2-main/Datasets/G1-2021-12-03.parquet")

#limpando linhas null na coluna pluvioreg
df <- df[complete.cases(df$PLUVIOMETRICREG), ]

#==============================================
library(dplyr)
library(stringr)

# Obter lista de arquivos txt na pasta
pasta <- "~/pp-tema2-main/dados_pluviometricos/"
arquivos <- list.files(path = pasta, pattern = "\\.txt$", full.names = TRUE)

# Função para ler e processar cada arquivo
ler_arquivo <- function(arquivo) {
  # Extrair o nome base do arquivo
  nome_base <- str_extract(arquivo, "\\d+_\\w+(?=_)")
  
  # Ler o arquivo de texto
  dados <- read.table(arquivo, header = FALSE, skip = 5, stringsAsFactors = FALSE)
  
  # Definir os nomes das colunas
  nomes_colunas <- c("Dia", "Hora", "15 min", "01 h", "04 h", "24 h", "96 h")
  
  # Definir o dataframe com os dados e nomes das colunas
  df <- data.frame(dados)
  colnames(df) <- nomes_colunas
  
  # Retornar o dataframe com o nome base
  return(list(nome_base = nome_base, df = df))
}

# Criar lista de dataframes
dataframes <- lapply(arquivos, ler_arquivo)

# Atribuir cada dataframe a uma variável separada
pasta_destino <- "~/pp-tema2-main/pluviometricos_tratados/"
for (i in 1:length(dataframes)) {
  nome_base <- dataframes[[i]]$nome_base
  df <- dataframes[[i]]$df
  
  # Salvar como arquivo CSV
  arquivo_destino <- paste0(pasta_destino, nome_base, ".csv")
  write.csv(df, file = arquivo_destino, row.names = FALSE)
  
  # Ou salvar como arquivo de texto separado por tabulação (sem cabeçalho)
  # arquivo_destino <- paste0(pasta_destino, nome_base, ".txt")
  # write.table(df, file = arquivo_destino, sep = "\t", col.names = FALSE, row.names = FALSE)
}


#teste df:


summary(df)


