############TD n2#########
####### Collecter des données en ligne ##################

install.packages(c("RCurl","XML," ))
install.packages(c("httr"))

library(RCurl)### récupérer des pages URL
library(XML) ### parser : parcourir un texte Html pour en extraire des éléments
library(httr)

scrape_page<-function(url){
#page<-getURL("https://www.snopes.com/fact-check/",ssl.verifypeer=F)

    page<-getURL(url)
   # print(page)
    page<-htmlParse(page)

  date<-xpathSApply(page,"//span[@class='article_date']",xmlValue)
  date


  content<-xpathSApply(page,"//span[@class='article_byline']",xmlValue)
  content

  titre<-xpathSApply(page,"//h3[@class='article_title']",xmlValue)
  titre
  
  
  url_intern<-xpathSApply(page,"//a[@class='outer_article_link_wrapper']", xmlGetAttr, "href")
  url_intern
  
  page_in<-getURL(url_intern)
  page_in<-htmlParse(page_in)
  
  rating<-xpathSApply(page_in,"//div[@class='rating_title_wrap']",xmlValue)
  rating 
  
  data<-data.frame(
    title = titre,
    Date = date,
    contents = content,
    Rating = rating
  )
  #article<-as.data.frame(cbind(titre,date,content))
  #View(article)
  
  return(data)
}

total_pages<-110

all_data<-list()

for (i in 38:total_pages){
  if (i==1){
    url <- "https://www.snopes.com/fact-check/"
  }
  else {
    url<-paste0("https://www.snopes.com/fact-check/?pagenum=",i)
  }
  all_data[[i]]<-scrape_page(url)
#  pause_duree <- runif(1, min = 1, max = 5)
#  Sys.sleep(pause_duree)
}



final_data<-do.call(rbind,all_data)

View(final_data)
print(final_data)

merged_df <- do.call(rbind, all_data)

# Afficher le data.frame fusionné
print(merged_df)

# Sauvegarder le data.frame fusionné en fichier CSV
write.csv(merged_df, file = "tableau_fusionne.csv", row.names = TRUE)
