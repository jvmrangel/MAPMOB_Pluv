library(dplyr)

# Converter os formatos de data e hora para classes apropriadas
df$DATE <- as.POSIXct(df$DATE, format = "%Y-%m-%d %H:%M:%S")
df_pluviometrico$Dia <- as.Date(df_pluviometrico$Dia, format = "%d-%m-%Y")
df_pluviometrico$Hora <- as.POSIXct(df_pluviometrico$Hora, format = "%H:%M:%S")

# Criar uma coluna auxiliar para a chave de junção
df$chave_juncao <- paste(format(df$DATE, "%Y-%m-%d"), format(df$DATE, "%H"), sep = " ")

# Realizar o left join entre os data frames usando as condições necessárias
df_final <- left_join(df, df_pluviometrico, by = c("chave_juncao" = "Dia", "PLUVIOMETRICREG" = "cod_pluv"))

# Realizar a interpolação dos valores de X15.min
df_final <- df_final %>%
  group_by(chave_juncao) %>%
  mutate(pluv_15 = approx(
    x = as.numeric(Hora),
    y = X15.min,
    xout = seq(min(as.numeric(Hora)), max(as.numeric(Hora)), by = 900)
  )$y)

# Remover a coluna auxiliar de junção
df_final <- df_final %>%
  select(-chave_juncao)

# Imprimir o resultado
print(df_final)
