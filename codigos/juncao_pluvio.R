# Pasta contendo os arquivos CSV
pasta <- "~/pp-tema2-main/pluviometricos_tratados/"

# Lista de arquivos na pasta
arquivos <- list.files(path = pasta, pattern = "*.csv", full.names = TRUE)


#criando df:
df_pluviometrico <- data.frame()

for (arquivo in arquivos) {
  df_pluv <- read.csv(arquivo, header = TRUE, stringsAsFactors = FALSE)
  
  #pegando n pluviometrico a partir do nome do arquivo e colocando  
  #em coluna para fins de depara
  n_pluv_raw <- strsplit(arquivo,"//")[[1]][2]
  numero_pluv = strsplit(n_pluv_raw,"_")[[1]][1]
  df_pluv["cod_pluv"]=numero_pluv
  
  df_pluviometrico <- rbind(df_pluviometrico, df_pluv)
}
#print(df_final)

library(dplyr)

df_pluviometrico$timestamp <- as.POSIXct(paste(df_pluviometrico$Data, df_pluviometrico$Hora),
                                     format = "%d/%m/%Y %H:%M:%S")

df_pluviometrico$newdata <- strptime(as.character(df_pluviometrico$Data), "%d/%m/%Y")

