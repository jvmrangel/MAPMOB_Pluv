library(gridExtra)

# Verificar o número de valores ausentes em cada coluna
valores_ausentes <- colSums(is.na(df_final))
print(valores_ausentes)

# Verificar a proporção de valores ausentes em cada coluna
proporcao_ausentes <- valores_ausentes / nrow(df_final)
print(proporcao_ausentes)

#============================================================
  

# Criar os boxplots usando ggplot2
boxplot_VELOCITY <- ggplot(df_final, aes(y = VELOCITY)) + geom_boxplot() + labs(title = "Boxplot - VELOCITY")
boxplot_ELEVATION <- ggplot(df_final, aes(y = ELEVATION)) + geom_boxplot() + labs(title = "Boxplot - ELEVATION")
boxplot_SPEED <- ggplot(df_final, aes(y = SPEED)) + geom_boxplot() + labs(title = "Boxplot - SPEED")
boxplot_DISTANCE <- ggplot(df_final, aes(y = DISTANCE)) + geom_boxplot() + labs(title = "Boxplot - DISTANCE")

# Organizar os gráficos em uma matriz de layout
grid.arrange(boxplot_VELOCITY, boxplot_ELEVATION, boxplot_SPEED, boxplot_DISTANCE, ncol = 2)









#=====================================================================



# Histograma da variável "VELOCITY"
hist(df_final$VELOCITY)




# Boxplot da variável "ELEVATION"
boxplot(df_sem_outliers$VELOCITY)

# Boxplot da variável "ELEVATION"
boxplot(df_sem_outliers$ELEVATION)

# Boxplot da variável "ELEVATION"
boxplot(df_sem_outliers$SPEED)

# Boxplot da variável "ELEVATION"
boxplot(df_sem_outliers$DISTANCE)



#===========================================================
# Gráfico de dispersão entre "VELOCITY" e "ELEVATION"
plot(df_final$VELOCITY, df_final$ELEVATION)

# Tabela de contingência entre "LINE" e "SWVERSION"
table(df_final$LINE, df_final$SWVERSION)


#============================================================
# Calcular os limites de remoção de outliers para cada coluna
limite_outliers <- function(col) {
  quartis <- quantile(col, c(0.25, 0.75), na.rm = TRUE)
  intervalo_interquartil <- quartis[2] - quartis[1]
  limite_inferior <- quartis[1] - 1.5 * intervalo_interquartil
  limite_superior <- quartis[2] + 1.5 * intervalo_interquartil
  list(limite_inferior = limite_inferior, limite_superior = limite_superior)
}

# Remover outliers das colunas especificadas
cols_outliers <- c("VELOCITY", "SPEED", "ELEVATION", "DISTANCE")
df_sem_outliers <- df_final
for (col in cols_outliers) {
  limites <- limite_outliers(df_final[[col]])
  df_sem_outliers <- df_sem_outliers[df_sem_outliers[[col]] >= limites$limite_inferior & 
                                       df_sem_outliers[[col]] <= limites$limite_superior, ]
}



rm(`df_outliers_removed`,`df_sem_outliers_velocity`, `df_sem_outliers_elevation`,`map`)
#==============================================================
# Remoção da coluna "SWVERSION"
df_sem_outliers <- df_sem_outliers[, -which(names(df_sem_outliers) == "SWVERSION")]

# Identificar as linhas com todas as colunas nulas
linhas_nulas <- complete.cases(df_sem_outliers)

# Filtrar o dataset mantendo apenas as linhas não nulas
df_sem_outliers <- df_sem_outliers[linhas_nulas, ]

print(summary(df_sem_outliers))






















#==============================================================
# Calcular os valores para cada categoria
sem_chuva <- 1
chuva_fraca <- quantile(df_sem_outliers$PLUVIOMETRICREG, 0.25, na.rm = TRUE)
chuva_moderada <- quantile(df_sem_outliers$PLUVIOMETRICREG, 0.5, na.rm = TRUE)
chuva_intensa <- quantile(df_sem_outliers$PLUVIOMETRICREG, 0.75, na.rm = TRUE)

# Definir as categorias com base nos valores calculados
df_sem_outliers$INTENSIDADE_CHUVA <- NA
df_sem_outliers$INTENSIDADE_CHUVA[df_sem_outliers$PLUVIOMETRICREG <= chuva_fraca] <- "Sem chuva"
df_sem_outliers$INTENSIDADE_CHUVA[df_sem_outliers$PLUVIOMETRICREG > chuva_fraca & df_sem_outliers$PLUVIOMETRICREG <= chuva_moderada] <- "Chuva fraca"
df_sem_outliers$INTENSIDADE_CHUVA[df_sem_outliers$PLUVIOMETRICREG > chuva_moderada & df_sem_outliers$PLUVIOMETRICREG <= chuva_intensa] <- "Chuva moderada"
df_sem_outliers$INTENSIDADE_CHUVA[df_sem_outliers$PLUVIOMETRICREG > chuva_intensa] <- "Chuva intensa"




