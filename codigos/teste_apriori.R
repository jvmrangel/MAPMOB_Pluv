library(arules)
library(arulesViz)

teste_categorico = df_merge

teste_categorico <- teste_categorico %>% 
  select(-c(Dia:SPEED,min_15:h_96))

#head(df_merge_info_chuva)


teste_categorico$nome <- as.factor(teste_categorico$nome)
teste_categorico$categoria_chuva <- as.factor(teste_categorico$categoria_chuva)
teste_categorico$categoria_dia <- as.factor(teste_categorico$categoria_dia)
teste_categorico$categoria_velocidade <- as.factor(teste_categorico$categoria_velocidade)

head(teste_categorico)
summary(teste_categorico)

apri_sem_chuva =teste_categorico[teste_categorico$categoria_chuva != "Sem Chuva",]
#apri_sem_chuva =apri_sem_chuva[apri_sem_chuva$categoria_velocidade != "Parado",]

regras = apriori(apri_sem_chuva, parameter = list(sup=0.01, conf=0.39))


inspect(sort(regras, by = "confidence"))
plot(regras)


#TESTES ABAIXO:
#=========================================================================================


write(regras,
      file = "regras_sem_chuva.csv",
      sep = ",",
      quote = TRUE,
      row.names = FALSE)

regras_df <- as.data.frame(regras)
regras_sem_chuva.csv(regras_df, file = "~/Code/MAPMOB_Pluv/outros arquivos/", row.names = FALSE)

head(regras)



#=========================================================================================

apri_sem_dia <- teste_categorico %>% 
  select(-c(categoria_dia))


regras = apriori(apri_sem_chuva, parameter = list(sup=0.01, conf=0.4))

inspect(sort(regras, by = "confidence"))
plot(regras)

#========================================================================================
regras_df <- as.data.frame(teste_categorico)
write.csv(df_merge_info_chuva, file = "~/Code/MAPMOB_Pluv/outros arquivos/dados_categoricos.csv", row.names = TRUE)



write(df_merge_info_chuva,
      file = "dados_categoricos.csv",
      sep = ",",
      quote = TRUE,
      row.names = TRUE)


summary(teste_categorico)
