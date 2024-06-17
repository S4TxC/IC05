library(dplyr)
library(tidyr)

dep<-read.csv("politifact.csv")
dep<-as.data.frame(dep)
dep$author<-str_remove_all(dep$author, "By ")
dep$author<-str_remove_all(dep$author, " • ")
dep$author<-str_remove_all(dep$author, "\\b[A-Za-z]+ \\d{1,2}, \\d{4}\\b")


colnames(dep)<-c('Title', 'Tags')
transformed_data <- dep %>%
separate_rows(Tags, sep = ", ") %>%
rename(Tag = Tags)
table<-as.data.frame(table(transformed_data$Tag))
colnames(transformed_data)<-c("Sourge", "Target")
write.csv(transformed_data,"politiTags.csv")

a<-unique(transformed_data$Target)
b<-unique(transformed_data$Sourge)
c<-rep("Tag",4104)
d<-rep("Fiction",500)
tag<-as.data.frame(cbind(a,c))
colnames(tag)<-c("Id","Type")
colnames(fiction)<-c("Id","Type")
fiction<-as.data.frame(cbind(b,d))
data<-rbind(fiction,tag)
write.csv(data,"noeuds.csv")
