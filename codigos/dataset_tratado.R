# install.packages("arrow")

library(tidyverse)
library(lubridate)
library(arrow)
library(hms)
library(gridExtra)

# Dicionario Regiao ------------------------------------------------------------

dicionario_regiao <- tribble(
  ~code, ~nome,
  01,    "Vidigal",
  02,    "Urca",
  03,    "Rocinha",
  04,    "Tijuca",
  05,    "Santa Teresa",
  06,    "Copacabana",
  07,    "Grajaú",
  08,    "Ilha do Governador",
  09,    "Penha",
  10,    "Madureira",
  11,    "Irajá",
  12,    "Bangu",
  13,    "Piedade",
  14,    "Jacarepaguá/Tanque",
  15,    "Saúde",
  16,    "Jardim Botânico",
  17,    "Barra/Barrinha",
  18,    "Jacarepaguá/Cidade de Deus",
  19,    "Barra/Riocentro",
  20,    "Guaratiba",
  21,    "Est. Grajaú/Jacarepaguá",
  22,    "Santa Cruz",
  23,    "Grande Méier",
  24,    "Anchieta",
  25,    "Grota Funda",
  26,    "Campo Grande",
  27,    "Sepetiba",
  28,    "Alto da Boa Vista",
  29,    "Av. Brasil/Mendanha",
  30,    "Recreio dos Bandeirantes",
  31,    "Laranjeiras",
  32,    "São Cristóvão",
  33,    "Tijuca/Muda"
) %>% 
  mutate(code = as.character(code))

# ------------------------------------------------------------------------------
diretorio_busdata <- "~/Code/MAPMOB_Pluv/Datasets"
arquivo_escolhido <- "G1-2021-12-12.parquet"

df <- list.files(diretorio_busdata) %>%
  enframe(value = "arquivo") %>%
  rowwise() %>%
  mutate(
    conteudo = list(str_glue("{diretorio_busdata}/{arquivo}") %>% read_parquet())
  ) %>%
  unnest(conteudo)

quantile <- df %>% 
  filter(VELOCITY != 0)

quantile <- quantile(quantile$VELOCITY, probs = c(0, 0.25, 0.5, 0.75, 1))

df <- df %>% 
  #filter(arquivo == arquivo_escolhido) %>%  # Filtra Arquivo
  drop_na(PLUVIOMETRICREG) %>% 
  select(-c(name, arquivo))

# ---
pasta <- "~/Code/MAPMOB_Pluv/pluviometricos_tratados/"

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

# ------------------------------------------------------------------------------

df_ <- df %>% 
  mutate(
    Dia = format(as.Date(DATE), "%d/%m/%Y"),
    Hora = hour(DATE),
    id_min = lubridate::minute(DATE) %/% 15,
    PLUVIOMETRICREG = as.character(PLUVIOMETRICREG),
  ) %>% 
  relocate(Dia, Hora, id_min, PLUVIOMETRICREG) %>% 
  arrange(PLUVIOMETRICREG, Dia, Hora, id_min)
  

# TODO: olhar os valores "ND" passar pra 0
df_pluviometrico <- df_pluviometrico %>% 
  mutate(
    Hora = as_hms(Hora),
    id_min = (lubridate::minute(Hora) %/% 15) - 1,
    id_min = if_else(id_min == -1, 3, id_min),
    Hora = hour(Hora),
  ) %>% 
  relocate(cod_pluv, Dia, Hora, id_min) %>% 
  left_join(
    dicionario_regiao,
    by = c("cod_pluv" = "code")
  )


df_merge <- df_ %>% 
  left_join(
    df_pluviometrico,
    by = c("Dia", "Hora", "id_min", "PLUVIOMETRICREG" = "cod_pluv") 
  ) %>% 
  arrange(PLUVIOMETRICREG, Dia, Hora, id_min) %>% 
  mutate(
    min_15 = as.double(X15.min),
    h_01 = as.double(X01.h),
    h_04 = as.double(X04.h),
    h_24 = as.double(X24.h),
    h_96 = as.double(X96.h),
    Dia = dmy(Dia)
  ) %>% 
  select(-c(CODRA:CORREDOR, VSP:HC, X15.min:X96.h))

# ------------------------------------------------------------------------------

# # Calcular os limites de remoção de outliers para cada coluna
# limite_outliers <- function(col) {
#   quartis <- quantile(col, c(0.25, 0.75), na.rm = TRUE)
#   intervalo_interquartil <- quartis[2] - quartis[1]
#   limite_inferior <- quartis[1] - 1.5 * intervalo_interquartil
#   limite_superior <- quartis[2] + 1.5 * intervalo_interquartil
#   list(limite_inferior = limite_inferior, limite_superior = limite_superior)
# }
# 
# # Remover outliers das colunas especificadas
# cols_outliers <- c("VELOCITY", "SPEED", "ELEVATION", "DISTANCE")
# 
# df_sem_outliers <- df_merge
# 
# for (col in cols_outliers) {
#   limites <- limite_outliers(df_merge[[col]])
#   df_sem_outliers <- df_sem_outliers[df_sem_outliers[[col]] >= limites$limite_inferior & 
#                                        df_sem_outliers[[col]] <= limites$limite_superior, ]
# }
# 
# # Identificar as linhas com todas as colunas nulas
# linhas_nulas <- complete.cases(df_sem_outliers)
# 
# # Filtrar o dataset mantendo apenas as linhas não nulas
# df_sem_outliers <- df_sem_outliers[linhas_nulas, ]
# #TODO: Muda o nome df_sem_outliers para df_merge

# ------------------------------------------------------------------------------

# TODO: Tá fodido
info <- df_merge %>% # ctrl + shift + m
  group_by(PLUVIOMETRICREG) %>% 
  summarise(
    velocidade_media = mean(VELOCITY),
    mean_15 = mean(min_15), # Média
    sum_15 = sum(min_15) # Soma
  )

# ------------------------------------------------------------------------------

df_merge <- df_merge %>% 
  mutate(
    categoria_chuva = case_when(
      h_01 >= 01.1 & h_01 < 05.0 ~ "Chuva Fraca",
      h_01 >= 05.1 & h_01 < 25.0 ~ "Chuva Moderada",
      h_01 >= 25.1 & h_01 < 50.0 ~ "Chuva Forte",
      h_01 >= 50.1 ~ "Chuva Muito Forte",
      .default = "Sem Chuva"
    ),
    categoria_dia = case_when(
    Hora >= 00 & Hora < 06  ~ "Madrugada",
    Hora >= 06 & Hora < 12 ~ "Manhã",
    Hora >= 12 & Hora < 18 ~ "Tarde",
    Hora >= 18 & Hora < 24 ~ "Noite"
    ),
    categoria_velocidade = case_when(
      VELOCITY == 0 ~ "Parado",
      VELOCITY > 0 & VELOCITY <= quantile[[2]] ~ "Baixa",
      VELOCITY > quantile[[2]] & VELOCITY <= quantile[[3]] ~ "Média",
      VELOCITY > quantile[[3]] & VELOCITY <= quantile[[4]] ~ "Alta",
      VELOCITY > quantile[[4]] ~ "Muito Alta"
    )
  )

df_merge_info_chuva <- df_merge %>% 
  group_by(nome, categoria_chuva, categoria_dia, categoria_velocidade) %>% 
  summarise(qtd_bus = n())

























