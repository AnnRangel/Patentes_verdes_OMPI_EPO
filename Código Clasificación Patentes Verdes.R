#install.packages("data.table")
library(data.table)
library(tidyverse)
library(openxlsx)
library(stringr)
library(readxl)
library(dplyr)

#**\\\CARGA DE DATOS\\\**

data2007 <- read_xlsx('C:\\Users\\Ana\\Downloads\\Patentes otorgadas concentrado.xlsx', sheet = '2007',col_names = TRUE)
data2008 <- read_xlsx('C:\\Users\\Ana\\Downloads\\Patentes otorgadas concentrado.xlsx', sheet = '2008',col_names = TRUE)
data2009 <- read_xlsx('C:\\Users\\Ana\\Downloads\\Patentes otorgadas concentrado.xlsx', sheet = '2009',col_names = TRUE)
data2010 <- read_xlsx('C:\\Users\\Ana\\Downloads\\Patentes otorgadas concentrado.xlsx', sheet = '2010',col_names = TRUE)
data2011 <- read_xlsx('C:\\Users\\Ana\\Downloads\\Patentes otorgadas concentrado.xlsx', sheet = '2011',col_names = TRUE)
data2012 <- read_xlsx('C:\\Users\\Ana\\Downloads\\Patentes otorgadas concentrado.xlsx', sheet = '2012',col_names = TRUE)
data2013 <- read_xlsx('C:\\Users\\Ana\\Downloads\\Patentes otorgadas concentrado.xlsx', sheet = '2013',col_names = TRUE)
data2014 <- read_xlsx('C:\\Users\\Ana\\Downloads\\Patentes otorgadas concentrado.xlsx', sheet = '2014',col_names = TRUE)
data2015 <- read_xlsx('C:\\Users\\Ana\\Downloads\\Patentes otorgadas concentrado.xlsx', sheet = '2015',col_names = TRUE)
data2016 <- read_xlsx('C:\\Users\\Ana\\Downloads\\Patentes otorgadas concentrado.xlsx', sheet = '2016',col_names = TRUE)
data2017 <- read_xlsx('C:\\Users\\Ana\\Downloads\\Patentes otorgadas concentrado.xlsx', sheet = '2017',col_names = TRUE)
data2018 <- read_xlsx('C:\\Users\\Ana\\Downloads\\Patentes otorgadas concentrado.xlsx', sheet = '2018',col_names = TRUE)
data2019 <- read_xlsx('C:\\Users\\Ana\\Downloads\\Patentes otorgadas concentrado.xlsx', sheet = '2019',col_names = TRUE)
data2020 <- read_xlsx('C:\\Users\\Ana\\Downloads\\Patentes otorgadas concentrado.xlsx', sheet = '2020',col_names = TRUE)
data2021 <- read_xlsx('C:\\Users\\Ana\\Downloads\\Otorgadas 2021.xlsx',col_names = TRUE)
data2022 <- read_xlsx('C:\\Users\\Ana\\Downloads\\Otorgadas 2022.xlsx',col_names = TRUE)




#*ELIMINAR COLUMNAS*
data2008 <- data2008[,!names(data2008) %in% c('Observaciones')]
data2011 <- data2011[,!names(data2011) %in% c('Observaciones')]
data2012 <- data2012[,!names(data2012) %in% c('Error')]
data2015 <- data2015[,!names(data2015) %in% c('Error')]
data2018 <- data2018[,!names(data2018) %in% c('Error')]


#*HOMOLOGACIÓN NOMBRES*
colnames(data2008) <- colnames(data2007)
colnames(data2009) <- colnames(data2007)
colnames(data2010) <- colnames(data2007)
colnames(data2011) <- colnames(data2007)
colnames(data2012) <- colnames(data2007)
colnames(data2013) <- colnames(data2007)
colnames(data2014) <- colnames(data2007)
colnames(data2015) <- colnames(data2007)
colnames(data2016) <- colnames(data2007)
colnames(data2017) <- colnames(data2007)
colnames(data2018) <- colnames(data2007)
colnames(data2019) <- colnames(data2007)
colnames(data2020) <- colnames(data2007)
colnames(data2021) <- colnames(data2007)
colnames(data2022) <- colnames(data2007)


#*JUNTAR*
patentes <- rbind(data2007, data2008, data2009, data2010, 
                  data2011, data2012, data2013, data2014, 
                  data2015, data2016, data2017, data2018,
                  data2019, data2020, data2021, data2022)


#*CONVERTIR LA , QUE SEPARA LOS VALORES DE LAS LISTAS POR ;*
patentes$`CIP - IPC` <- gsub(",", ";", patentes$`CIP - IPC`)
patentes$`CPC - PATENTSCOPE` <- gsub(",", ";", patentes$`CPC - PATENTSCOPE`)

#*QUITA ESPACIOS QUE NO SEAN NECESARIOS*
patentes$`CIP - IPC` <- gsub(" ", "", patentes$`CIP - IPC`)
patentes$`CPC - PATENTSCOPE` <- gsub("", "", patentes$`CPC - PATENTSCOPE`)

#*VUELVE UN NÚMERO LOS VALORES DENTRO DE ESTAS COLUMNAS*
patentes <- patentes%>%
  mutate(`Solo Hombres` = as.numeric(`Solo Hombres`),
         `Solo Mujeres` = as.numeric(`Solo Mujeres`))

#*QUITA LOS NA/. NA/.NA QUE EXISTAN COMO TEXTO Y LOS VUELVE VALORES NUELOS*
patentes$`CPC - PATENTSCOPE`[patentes$`CPC - PATENTSCOPE` == "NA"] <- NA
patentes$`CPC - PATENTSCOPE`[patentes$`CPC - PATENTSCOPE` == ". NA"] <- NA
patentes$`CPC - PATENTSCOPE`[patentes$`CPC - PATENTSCOPE` == ".NA"] <- NA

patentes$`CIP - IPC`[patentes$`CIP - IPC` == "NA"] <- NA
patentes$`CIP - IPC`[patentes$`CIP - IPC` == ". NA"] <- NA
patentes$`CIP - IPC`[patentes$`CIP - IPC` == ".NA"] <- NA


#**\\\CARGA DE ETIQUETAS\\\**

WIPO <- read_xlsx(file.choose(), sheet = 'verdes WIPO', col_names = TRUE) #Lista clases verdes de la WIPO
EU <- read_xlsx(file.choose(), sheet = 'verdes EU', col_names = TRUE) #Lista clases verdes de la EU



#**\\\LIMPIEZA DE COLUMNAS A DIAGNOSTICAR\\\**
#*DEJAR LAS COLUMNAS DE '(IPC) `, "(CPC)","IPC Clases", #*"CPC clases","Total green inventions"
#*CON VALORES NA PARA LOS TEXTOS Y 0 PARA LOS NUM Y QUE ASÍ NO ALTERE EL RESULTADO
patentes$`(IPC) ` <- 0
patentes$`(CPC)` <- 0
patentes$`IPC Clases` <- NA
patentes$`CPC clases` <- NA
patentes$`Total green inventions`<- 0


patentesCPC <- patentes%>%
  select(-`(IPC) `,-`IPC Clases`)

patentesIPC <- patentes%>%
  select(-`(CPC)`,-`CPC clases`)


#**\\\CLASIFICACIÓN DE WIPO CON SEPARADOR , \\\**
#*\\ WIPO \\*
#*\ IPC \*
#*FUNCIÓN DE ASIGNACIÓN, CHECA AMBAS BASES Y SI COINCIDEN PONE 1 Y EXTRAE EL VALOR COINCIDENTE EN OTRA COLUMNA*
ipcWIPO <- function(patentesIPC, WIPO) {
  patentesIPC$`(IPC) ` <- 0
  
  for (i in 1:nrow(patentesIPC)) {
    IPC <- str_split(patentesIPC$`CIP - IPC`[i], "; ")[[1]]
    
    # verificar si algún valor de `CIP - IPC` coincide con algún valor de WIPO
    if (!any(is.na(IPC)) && any(str_detect(IPC, paste(WIPO$TOPIC, collapse = "|")))) {
      patentesIPC$`(IPC) `[i] <- 1
      
      # obtener los valores de WIPO que coinciden con los valores de `CIP - IPC`
      IPC_Clases <- IPC[str_detect(IPC, paste(WIPO$TOPIC, collapse = "|"))]
      patentesIPC$'IPC Clases'[i] <- paste(IPC_Clases, collapse = "; ")
    }
  }
  
  return(patentesIPC)
}


#*\ CPC \*
#*FUNCIÓN DE ASIGNACIÓN, CHECA AMBAS BASES Y SI COINCIDEN PONE 1 Y EXTRAE EL VALOR COINCIDENTE EN OTRA COLUMNA*
cpcWIPO <- function(patentesCPC, WIPO) {
  patentesCPC$`(CPC)` <- 0
  
  for (i in 1:nrow(patentesCPC)) {
    CPC <- str_split(patentesCPC$`CPC - PATENTSCOPE` [i], "; ")[[1]]
    
    # verificar si algún valor de `CPC - PATENTSCOPE` coincide con algún valor de WIPO
    if (!any(is.na(CPC)) && any(str_detect(CPC, paste(WIPO$TOPIC, collapse = "|")))) {
      patentesCPC$`(CPC)`[i] <- 1
      
      # obtener los valores de WIPO que coinciden con los valores de `CPC - PATENTSCOPE`
      CPC_Clases <- CPC[str_detect(CPC, paste(WIPO$TOPIC, collapse = "|"))]
      patentesCPC$`CPC clases` [i] <- paste(CPC_Clases, collapse = "; ")
    }
  }
  
  return(patentesCPC)
}

#CLASIFICACIÓN WIPO IPC Y CPC
patentesWIPO1 <- ipcWIPO(patentesIPC, WIPO)
patentesWIPO2 <- cpcWIPO(patentesCPC, WIPO)

patentesWIPO <- merge(patentesWIPO1, patentesWIPO2, all= TRUE)

# WIPO TOTAL VERDES
patentesWIPO$`Total green inventions` <- ifelse(patentesWIPO$`(CPC)` =="1" | patentesWIPO$`(IPC) ` == "1", 1, 0)

#Reordenar
patentesWIPO <- patentesWIPO%>%
  select("Patente", "Año concesión", "Inventores", "Solicitante", "Tipo persona. Moral ó Física", "Fecha de presentación", 
         "Solo Hombres", "Solo Mujeres", "mixto", "Hombres", "Mujeres", "Estado", "Número de contacto de el o los inventores", 
         "Correo de contacto de los inventores", "Nombre o nombres de los apoderados", "Número de contacto de los apoderados", 
         "Correo de contacto de los apoderados", "CIP - IPC", "CPC - PATENTSCOPE", `(IPC) `, "(CPC)", "IPC Clases", "CPC clases", 
         "Total green inventions", "Nacionalidad", "Mujeres extranjeras", "Hombres extranjeros", "Mujeres y hombres extranjeros", 
         "Inteligencia Artificial", "Cockburn et al. IPC", "Cockburn et al. Keywords", "EU-JRC (keywords)", "Fujii and Managi", 
         "OECD STI - IPC", "Resumen")

#

#**\\\CLASIFICACIÓN DE EU CON SEPARADOR , \\\**
#*\\ EU \\*
#*\ IPC \*
#*FUNCIÓN DE ASIGNACIÓN, CHECA AMBAS BASES Y SI COINCIDEN PONE 1 Y EXTRAE EL VALOR COINCIDENTE EN OTRA COLUMNA*
ipcEU <- function(patentesIPC, EU) {
  patentesIPC$`(IPC) ` <- 0
  
  for (i in 1:nrow(patentesIPC)) {
    IPC <- str_split(patentesIPC$`CIP - IPC`[i], "; ")[[1]]
    
    # verificar si algún valor de `CIP - IPC` coincide con algún valor de EU
    if (!any(is.na(IPC)) && any(str_detect(IPC, paste(EU$TOPIC, collapse = "|")))) {
      patentesIPC$`(IPC) `[i] <- 1
      
      # obtener los valores de EU que coinciden con los valores de `CIP - IPC`
      IPC_Clases <- IPC[str_detect(IPC, paste(EU$TOPIC, collapse = "|"))]
      patentesIPC$'IPC Clases'[i] <- paste(IPC_Clases, collapse = "; ")
    }
  }
  
  return(patentesIPC)
}


#*\ CPC \*
#*FUNCIÓN DE ASIGNACIÓN, CHECA AMBAS BASES Y SI COINCIDEN PONE 1 Y EXTRAE EL VALOR COINCIDENTE EN OTRA COLUMNA*
cpcEU <- function(patentesCPC, EU) {
  patentesCPC$`(CPC)` <- 0
  
  for (i in 1:nrow(patentesCPC)) {
    CPC <- str_split(patentesCPC$`CPC - PATENTSCOPE` [i], "; ")[[1]]
    
    # verificar si algún valor de `CPC - PATENTSCOPE` coincide con algún valor de EU
    if (!any(is.na(CPC)) && any(str_detect(CPC, paste(EU$TOPIC, collapse = "|")))) {
      patentesCPC$`(CPC)`[i] <- 1
      
      # obtener los valores de EU que coinciden con los valores de `CPC - PATENTSCOPE`
      CPC_Clases <- CPC[str_detect(CPC, paste(EU$TOPIC, collapse = "|"))]
      patentesCPC$`CPC clases` [i] <- paste(CPC_Clases, collapse = "; ")
    }
  }
  
  return(patentesCPC)
}

#CLASIFICACIÓN EU IPC Y CPC
patentesEU1 <- ipcEU(patentesIPC, EU)
patentesEU2 <- cpcEU(patentesCPC, EU)

patentesEU <- merge(patentesEU1, patentesEU2, all= TRUE)


# EU TOTAL VERDES
patentesEU$`Total green inventions` <- ifelse(patentesEU$`(CPC)` == "1" | patentesEU$`(IPC)` == "1", 1, 0)


#Reordenar
patentesEU <- patentesEU%>%
  select("Patente", "Año concesión", "Inventores", "Solicitante", "Tipo persona. Moral ó Física", "Fecha de presentación", 
         "Solo Hombres", "Solo Mujeres", "mixto", "Hombres", "Mujeres", "Estado", "Número de contacto de el o los inventores", 
         "Correo de contacto de los inventores", "Nombre o nombres de los apoderados", "Número de contacto de los apoderados", 
         "Correo de contacto de los apoderados", "CIP - IPC", "CPC - PATENTSCOPE", `(IPC) `, "(CPC)", "IPC Clases", "CPC clases", 
         "Total green inventions", "Nacionalidad", "Mujeres extranjeras", "Hombres extranjeros", "Mujeres y hombres extranjeros", 
         "Inteligencia Artificial", "Cockburn et al. IPC", "Cockburn et al. Keywords", "EU-JRC (keywords)", "Fujii and Managi", 
         "OECD STI - IPC", "Resumen")


#**ANTES DE DESCARGAR**

patentesEU <- patentesEU%>%
  mutate(`Solo Hombres` = as.numeric(`Solo Hombres`),
         `Solo Mujeres` = as.numeric(`Solo Mujeres`))

patentesWIPO <- patentesWIPO%>%
  mutate(`Solo Hombres` = as.numeric(`Solo Hombres`),
         `Solo Mujeres` = as.numeric(`Solo Mujeres`))




#**DESCARGA EXCEL**
write.xlsx(patentesWIPO,"PatentesVerdesWIPO.xlsx", rowNames = TRUE)
write.xlsx(patentesEU,"PatentesVerdesEU.xlsx", rowNames = TRUE)


