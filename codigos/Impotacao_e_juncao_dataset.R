# Carregar pacotes
library(arrow)
library(dplyr)
library(ggplot2)

#df <- arrow::read_parquet("pp-tema2-main/DST-A/G1-2022-02-10.parquet")

# Definir vetor com os nomes das pastas
pastas <- c("DST-A", "DST-B", "DST-C", "DST-D", "DST-E")

# Criar uma lista vazia para armazenar os datasets
datasets <- list()

# Loop para cada pasta
for (pasta in pastas) {
  # Criar vetor com os nomes dos arquivos na pasta atual
  arquivos <- sprintf("~/pp-tema2-main/%s/G1-2022-02-%02d.parquet", pasta, 10:19)
  
  # Criar uma lista vazia para armazenar os dados
  dados <- list()
  
  # Loop para ler cada arquivo e armazenar os dados na lista
  for (arquivo in arquivos) {
    # Ler arquivo Parquet
    df <- arrow::read_parquet(arquivo)
    
    # Armazenar dados na lista
    dados[[arquivo]] <- df
  }
  
  # Combina todos os arquivos em um único dataframe
  df <- dplyr::bind_rows(dados)
  
  # Adicionar coluna com IDs sequenciais
  df <- df %>%
    mutate(ID = row_number() - 1)
  
  # Salvar o dataframe na lista de datasets
  nome_variavel <- paste("dt_", pasta, sep = "")
  datasets[[nome_variavel]] <- df
}

# Juntar os datasets em um só utilizando a coluna "ID" como chave identificadora
df_final <- Reduce(full_join, datasets)
 
# Remove os dataset base
rm(`dt_DST-0`,`dt_DST-A`,`dt_DST-B`,`dt_DST-C`,`dt_DST-D`,`dt_DST-E`,`df`,`dados`,`datasets`)

# Verificar o resultado
print(nrow(df_dst0))
head(df_final)
print(max(df_dst0$ID))

print(summary(df_final))

head(df)
