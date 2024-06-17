cat("\014")
rm(list = ls())
library(RCurl)
library(XML)
library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)
library(stringr)
library(ggrepel)
library(quanteda)
library(quanteda.textstats)
library(wordcloud)
library(wordcloud2)
library(RColorBrewer)
library(stopwords)

#______________________________________________________________________________
# Préparer le dataframe

setwd("~/Cours/IC05/Projet/ic05/Politifact")

db<-read.csv("politifactNonNettoyée.csv",sep=",")

# Virer la 1ère colonne d'ID qui gêne avant le traitement sur les lignes ayant les valeurs des titres de colonnes
transformed_db <- db %>%
  select(X.Citation., X.Rating., X.Personne., X.Date., X.Platform., X.Author., X.Href., X.Tags.)

# Virer les lignes indésirables
transformed_db <- transformed_db %>%
  filter(X.Citation. != "Citation")

# Select de ttes les lignes sauf la 1ère car encore création d'un ID.
transformed_db <- transformed_db %>%
  select(X.Citation., X.Rating., X.Personne., X.Date., X.Platform., X.Author., X.Href., X.Tags.)

# Création de l'ID
transformed_db <- transformed_db %>%
  mutate(Id = row_number())

# ID devient 1ère colonne
transformed_db <- transformed_db %>%
  select(Id, everything())
#______________________________________________________________________________
# Renommer les colonnes

colnames(transformed_db) <- c('Id', 'Titre', 'Verdict', 'Personne', 'Date', 'Plateforme', 'Auteur', 'href', 'Tags')

# Séparer les valeurs de la colonne X.Tags pour créer i lignes de tags
transformed_db <- transformed_db %>%
  separate_rows(Tags, sep = ", ") %>%
  rename(Tag = Tags)

#______________________________________________________________________________
#Nettoyage titre

# Fonctions suivantes pour le traitement de l'encodage
clean_title <- function(text){
  if (!is.na(text)){
    text <- iconv(text, from = "UTF-8", to = "latin1", sub = "")
    return(text)
  }
  return(text)
}

clean_title2 <- function(text){
  if (!is.na(text)){
    cleaned_text <- gsub("[^[:alnum:] ]", "", text)
    return(cleaned_text)
  }
  return(text)
}

clean_title3 <- function(text){
  if (!is.na(text)){
    text <- iconv(text, from = "latin1", to = "UTF-8", sub = "")
    cleaned_text <- gsub("[^[:alnum:][:space:]]", "", text)
    return(cleaned_text)
  }
  return(text)
}

clean_title4 <- function(text) {
  if (!is.na(text)) {
    text <- iconv(text, from = "UTF-8", to = "ASCII", sub = "")
    cleaned_text <- gsub("[^[:alnum:][:space:]]", "", text)
    return(cleaned_text)
  }
  return(text)
}

transformed_db$Titre <- sapply(transformed_db$Titre, clean_title)

transformed_db$Titre <- sapply(transformed_db$Titre, clean_title2)

transformed_db$Titre <- str_remove_all(transformed_db$Titre, "â")

transformed_db$Titre <- str_remove_all(transformed_db$Titre, "Â")

transformed_db$Titre <- iconv(transformed_db$Titre, from = "latin1", to = "UTF-8")

transformed_db$Titre <- sapply(transformed_db$Titre, clean_title3)

transformed_db$Titre <- sapply(transformed_db$Titre, clean_title4)

#______________________________________________________________________________
# Nettoyage des verdicts 

# On adapte des mots clés plus explicites
transformed_db <- transformed_db %>%
  mutate(Verdict = recode(Verdict,
                          "barely-true" = "Barely accurate",
                          "true" = "True",
                          "pants-fire" = "Flagrant falsehood",
                          "false" = "False",
                          "half-flip" = "Partial change of position",
                          "mostly-true" = "Mostly accurate",
                          "no-flip" = "Consistent",
                          "full-flop" = "Full change of position",
                          "half-true" = "Half accurate"))

#______________________________________________________________________________
# Nettoyage des auteurs

transformed_db <- transformed_db %>%
  mutate(Auteur = sub(" â€¢ .*", "", Auteur))

transformed_db$Auteur <- str_remove(transformed_db$Auteur, "By ")

transformed_db$Auteur <- str_replace_all(transformed_db$Auteur, "AarÃ³n Torres", "Aarón Torres")

transformed_db$Auteur <- str_replace_all(transformed_db$Auteur, "â€¢ August 4, 2013", "")

transformed_db$Auteur <- str_replace_all(transformed_db$Auteur, "â€¢ July 23, 2020", "")

transformed_db$Auteur <- str_replace_all(transformed_db$Auteur, "â€¢ July 27, 2013", "")

#______________________________________________________________________________
# Écrire le résultat dans un CSV
write.csv(transformed_db, "baseTags.csv")

# Créer les data frames pour les noeuds
a <- unique(transformed_db$Tag)
b <- unique(transformed_db$Title)
c <- rep("Tag", length(a))
d <- rep("Fiction", length(b))
tag <- as.data.frame(cbind(a, c))
colnames(tag) <- c("Id", "Type")
fiction <- as.data.frame(cbind(b, d))
colnames(fiction) <- c("Id", "Type")

# Combiner les deux data frames
result <- rbind(fiction, tag)

# Écrire le résultat dans un CSV
write.csv(result, "noeuds.csv")