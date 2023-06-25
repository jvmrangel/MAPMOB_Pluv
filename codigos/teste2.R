library(dplyr)
library(leaflet)
library(leaflet.extras)
library(hexbin)
library(plotly)

print(names(df_final))

# Mudar a ordem da coluna "ColunaDesejada" para a primeira posição
df_final <- df_final %>%
  select("ID", everything())

# Calcular a porcentagem de valores nulos por coluna
porcentagem_nulos <- colMeans(is.na(df_final)) * 100

# Exibir a porcentagem de valores nulos por coluna
print(porcentagem_nulos)

head(df_final)

#=============================================================================

df_subset <- subset(df_final, BUSID == "B63045")

# Criar o histograma
ggplot(df_final, aes(x = VELOCITY)) +
  geom_histogram(binwidth = 1, fill = "skyblue", color = "black") +
  labs(title = "Histograma de VELOCITY (Filtrado por BUSID)",
       x = "VELOCITY",
       y = "Contagem")
#=============================================================================

df_subset <- df_final %>%
  filter(LINE == "SV606")

# Criar o mapa
map <- leaflet(df_subset) %>%
  addTiles() %>%
  addCircleMarkers(lng = ~LONGITUDE, lat = ~LATITUDE, color = "black")

# Exibir o mapa
map

#============================================================================

df_subset <- df_final %>%
  filter(LINE == "665")

# Calcular a velocidade média por coordenadas
df_avg_speed <- df_subset %>%
  group_by(LONGITUDE, LATITUDE) %>%
  summarise(avg_velocity = mean(VELOCITY))

# Criar o mapa
map <- leaflet(df_subset) %>%
  addTiles() %>%
  #addCircleMarkers(lng = ~LONGITUDE, lat = ~LATITUDE, color = "white") %>%
  addHeatmap(data = df_avg_speed, lng = ~LONGITUDE, lat = ~LATITUDE, intensity = ~avg_velocity)

map

#=============================================================================

# Filtrar o dataframe com base na condição
df_subset <- df_final %>%
  filter(LINE == "665")

# Calcular a velocidade média por coordenadas
df_avg_speed <- df_subset %>%
  group_by(LONGITUDE, LATITUDE) %>%
  summarise(avg_velocity = mean(VELOCITY))

# Criar o mapa
map <- leaflet(df_subset) %>%
  addTiles() %>%
  addHeatmap(data = df_avg_speed, lng = ~LONGITUDE, lat = ~LATITUDE, intensity = ~avg_velocity) %>%
  addLegend(position = "bottomright", title = "Velocidade Média",
            colors = "viridis", labels = prettyNum(df_avg_speed$avg_velocity, big.mark = ",", scientific = FALSE))

map