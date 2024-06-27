cat("\014")
rm(list = ls())
library(RCurl)
library(XML)
library(stringr)

# Liste des URLs à parcourir
urls <- c("https://checkyourfact.com/", paste0("https://checkyourfact.com/page/", 2:90, "/"))

donnees <- list()

for (url in urls) {
  
  cat("Traitement de la page :", url, "\n")
  
  page <- getURL(url, ssl.verifypeer = FALSE)
  page <- htmlParse(page)
  
  liens <- xpathSApply(page, path = "//section//articles//a", xmlAttrs)
  liens <- str_replace(liens, "href=", "")
  liens <- lapply(liens, function(x) {
    x <- paste0("https://checkyourfact.com", x)
    return(x)
  })
  
  for (lien in liens) {
    
    cat("  Traitement de l'article :", lien, "\n")
    
    article <- getURL(lien)
    article <- htmlParse(article)
    
    verdict <- xpathSApply(article, path = "//div[@id='ob-read-more-selector']//p//span[@style='color: #800000;']//strong", xmlValue)
    verdict <- ifelse(length(verdict) == 0, NA, verdict[1])
    
    titre <- xpathSApply(article, path = "//section[@id='main']//h1", xmlValue)
    titre <- ifelse(length(titre) == 0, NA, titre[1])
    
    date <- xpathSApply(article, path = "//section[@id='main']//time", xmlValue)
    date <- ifelse(length(date) == 0, NA, date[1])
    
    auteur <- xpathSApply(article, path = "//article//author//h1", xmlValue)
    auteur <- ifelse(length(auteur) == 0, NA, auteur[1])
    
    href <- xpathSApply(article, path = "//div[@id='ob-read-more-selector']//a", xmlAttrs)
    if (length(href) > 0) {
      liste_urls <- lapply(href, function(x) {
        str_extract(x, "https?://\\S+")
      })
      
      sources <- list()
      for (i in 1:length(liste_urls)) {
        if (!all(is.na(liste_urls[[i]]))) {
          sources <- c(sources, liste_urls[[i]])
        } else {
          sources <- c(sources, NA)
        }
      }
    } else {
      sources <- NA
    }
    
    data <- data.frame(
      titre = titre,
      verdict = verdict,
      date = date,
      auteur = auteur,
      sources = ifelse(length(sources) == 0, NA, paste(unlist(sources), collapse = ", ")),
      stringsAsFactors = FALSE
    )
    
    donnees <- append(donnees, list(data))
  }
}

donnees <- do.call(rbind, donnees)
print(donnees)

#write.csv(donnees, file = "DB2000rows.csv")
