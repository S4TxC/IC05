cat("\014")
rm(list = ls())
library(RCurl)
library(XML)
library(dplyr)
library(stringr)
library(tidyr)

#----------------------------- Espace de travail ------------------------------#

setwd("~/Cours/IC05/Projet/ic05/Politifact")

db<-read.csv("BasePolitifactNonNettoyée.csv",sep=",")

#-------------------------- Préparation du dataframe --------------------------#

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

colnames(transformed_db) <- c('Id', 'Titre', 'Verdict', 'Personne', 'Date', 'Plateforme', 'Auteur', 'href', 'Tags')

# Séparer les valeurs de la colonne X.Tags pour créer i lignes de tags
transformed_db <- transformed_db %>%
  separate_rows(Tags, sep = ", ") %>%
  rename(Tag = Tags)

#--------------------------- Nettoyage des titres ----------------------------#

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

#-------------------------- Nettoyage des verdicts ----------------------------#

# On adopte des mots-clés plus parlant
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

#-------------------------- Nettoyage des auteurs -----------------------------#

transformed_db <- transformed_db %>%
  mutate(Auteur = sub(" â€¢ .*", "", Auteur))

transformed_db$Auteur <- str_remove(transformed_db$Auteur, "By ")

transformed_db$Auteur <- str_replace_all(transformed_db$Auteur, "AarÃ³n Torres", "Aarón Torres")

transformed_db$Auteur <- str_replace_all(transformed_db$Auteur, "â€¢ August 4, 2013", "")

transformed_db$Auteur <- str_replace_all(transformed_db$Auteur, "â€¢ July 23, 2020", "")

transformed_db$Auteur <- str_replace_all(transformed_db$Auteur, "â€¢ July 27, 2013", "")

#--------------- Procédure de création des noeuds et des liens ----------------#

# Vecteurs des états des US  
us_states <- c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", 
               "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", 
               "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", 
               "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", 
               "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", 
               "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming")

# db_2024 <- transformed_db %>%
#   filter(grepl(", 2024$", Date))
# 
# db_2023 <- transformed_db %>%
#   filter(grepl(", 2023$", Date))

db_2024_2023 <- transformed_db %>%
  filter(grepl(", 2023$", Date) | grepl(", 2024$", Date))

# Ajout d'une colonne pour indiquer si le tag à un lien avec un état
db_2024_2023 <- db_2024_2023 %>%
  mutate(IsState = ifelse(Tag %in% us_states, Tag, NA))

# Liste des tags à exclure, sinon fausse énormément les noeuds
tags_to_exclude <- c("Facebook Fact-checks", "Facebook posts", "Instagram posts", "PolitiFact en EspaÃ±ol", "Threads posts", "TikTok posts", "Viral image", "X posts")

# Filtrage des tags ci-dessus
db_2024_2023 <- db_2024_2023 %>%
  filter(!(Tag %in% tags_to_exclude))

# Conserver toutes les lignes de tags tout en ajoutant une colonne indiquant si un tag est un état
db_2024_2023_states <- db_2024_2023 %>%
  group_by(Id, Titre, Verdict, Personne, Date, Plateforme, Auteur, href) %>%
  summarise(AllTags = paste(Tag, collapse = ", "),
            StateTags = paste(na.omit(IsState), collapse = ", ")) %>%
  ungroup()

# Une ligne par tag
db_2024_2023_states <- db_2024_2023_states %>%
  separate_rows(AllTags, sep = ", ") %>%
  rename(Tag = AllTags)

# Définir un poids pour chaque verdict pour discrimer
verdict_weights <- c(
  "False" = 10,
  "Flagrant falsehood" = 10,
  "Barely accurate" = 8,
  "Half accurate" = 6,
  "Mostly accurate" = 4,
  "Partial change of position" = 3,
  "Full change of position" = 2,
  "True" = 1
)

# Ajout d'une colonne poids par verdict
db_2024_2023 <- db_2024_2023 %>%
  mutate(Weight = verdict_weights[Verdict])

# Création du fichier noeuds
nodes <- db_2024_2023_states %>%
  select(Id, Label = Tag, Verdict, Titre, StateTags) %>%
  distinct()

write.csv(nodes, "nodes.csv", row.names = FALSE)

# Assurer que les verdicts sont bien stockés avant la jointure effectuée pour la création des liens
verdicts <- db_2024_2023 %>%
  select(Id, Verdict, Weight) %>%
  distinct()

# Création du fichier edges.csv
edges <- db_2024_2023 %>%
  select(Id, Tag) %>%
  inner_join(db_2024_2023 %>% select(Id, Tag), by = "Tag", suffix = c(".x", ".y")) %>%                                # Joindre la base de données avec elle-même sur la colonne Tag
  filter(Id.x != Id.y) %>%                                                                                            # Filtrer pour exclure les liens d'un nœud à lui-même
  left_join(verdicts, by = c("Id.x" = "Id")) %>%                                                                      # Joindre les verdicts avec les Id.x et Id.y
  rename(Verdict.x = Verdict, Weight.x = Weight) %>%
  left_join(verdicts, by = c("Id.y" = "Id")) %>%                                                                      # Joindre les verdicts avec les Id.y
  rename(Verdict.y = Verdict, Weight.y = Weight) %>%
  group_by(Id.x, Id.y) %>%
  # On calcule le nombre d'occurrences pour chaque paire de nœuds
  # On concaténe les tags uniques partagés par les nœuds
  # Pareil avec les verdicts 
  # Calculer le poids moyen basé sur les poids des verdicts (attention c'est déjà un premier choix qu'il faudra expliciter)
  summarise(Frequency = n(),
            TagsShared = paste(unique(Tag), collapse = ", "),
            VerdictPair = paste(unique(Verdict.x), "->", unique(Verdict.y), collapse = ", "),
            EdgeWeight = mean(c(Weight.x, Weight.y))) %>%
  ungroup() %>%
  mutate(Type = "Directed", Relation = TagsShared, Label = VerdictPair) %>%
  select(Source = Id.x, Target = Id.y, Type, Weight = EdgeWeight, Relation, Frequency, Label) %>%
  distinct()

write.csv(edges, "edges.csv", row.names = FALSE)