####### Collecter des donn�es en ligne ##################

library(RCurl)### r�cup�rer des pages URL
library(XML) ### parser : parcourir un texte Html pour en extraire des �l�ments
library(stringr)
pages = c()
for (i in 1:819) {
  # Ajoute chaque valeur à la liste
  pages <- c(pages,paste0("https://www.politifact.com/factchecks/list/?page=",paste0(i, "&")))
}
infos <- c()
liens =c()
data<-data.frame("Citation","Rating", "Personne", "Date","Platform","Author", "Href", "Tags")
for (page in pages){
  page<-getURL(page, ssl.verifypeer=FALSE)
  page<-htmlParse(page)
  datapage<-data.frame("Citation","Rating", "Personne", "Date", "Platform", "Author", "Href", "Tags")
  for(i in 1:30){
    xpath_citation<-paste0("/html/body/div[2]/main/section[3]/article/section/div/article/ul/li[",paste0(i,"]/article/div[2]/div/div[1]/div/a"))
    citation<-xpathSApply(page, xpath_citation, xmlValue)
    
    xpath_rating<-paste0("/html/body/div[2]/main/section[3]/article/section/div/article/ul/li[",paste0(i,"]/article/div[2]/div/div[2]/div/picture/img"))
    rating<-xpathSApply(page, xpath_rating, xmlGetAttr, "alt")
    
    xpath_personne<-paste0("/html/body/div[2]/main/section[3]/article/section/div/article/ul/li[",paste0(i,"]/article/div[1]/div[2]/a"))
    personne<-xpathSApply(page, xpath_personne, xmlValue)
    
    xpath_date<-paste0("/html/body/div[2]/main/section[3]/article/section/div/article/ul/li[",paste0(i,"]/article/div[1]/div[2]/div"))
    date<-xpathSApply(page, xpath_date, xmlValue)
    date_pattern <- "\\b[A-Za-z]+ \\d{1,2}, \\d{4}\\b"
    platform_pattern <- "(\\w+):"
    platform <- str_match(date, platform_pattern)[,2]
    date <- str_extract(date, date_pattern)
    
    xpath_author<-paste0("/html/body/div[2]/main/section[3]/article/section/div/article/ul/li[",paste0(i,"]/article/div[2]/div/footer"))
    author<-xpathSApply(page, xpath_author, xmlValue)

    xpath_href<-xpath_citation
    href<-xpathSApply(page, xpath_href, xmlGetAttr,"href")
    
    lien <- paste0("https://www.politifact.com",href)
    article<-getURL(lien, ssl.verifypeer=FALSE)
    article<-htmlParse(article)
    
    tags <- xpathSApply(article, "/html/body/div[2]/main/section[3]/div/article/div[2]/div/ul/li/a/span", xmlValue)
    tags <- paste(tags, collapse = ", ")
    
    
    datapage = rbind(datapage, list(citation,rating, personne,date, platform, author,href,tags))
  }
  data = rbind(data,datapage)
  write.csv(data, file="politifact.csv",row.names = TRUE)
}


  

