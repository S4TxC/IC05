library(ggplot2)

db<-read.csv("BaseNettoyéePolitifact.csv",sep=",")

us_states <- c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", 
               "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", 
               "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", 
               "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", 
               "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", 
               "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming")


db_faux <- db[!(db$Verdict %in% c("True", "Mostly accurate")), ]
count_faux <- as.data.frame(table(db_faux$Tag))
colnames(count_faux) <- c("tag", "count")
#count_faux_filtered <- subset(count_faux, count> 50)
count_faux_states <- subset(count_faux, tag %in% us_states)

ggplot(count_faux_states, aes(x = tag, y = count)) +
  geom_bar(stat = "identity") +
  labs(title = "Nombre d'articles faux par tag", x = "Tag", y = "Nombre d'articles faux") +
  theme_minimal()

db_states <- db[db$Tag %in% us_states, ]

ggplot(db_states, aes(x = Verdict, fill = Tag)) +
  geom_bar() +
  labs(title = "Nombre d'articles par verdict et par État", x = "Verdict", y = "Nombre d'articles", fill = "État") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

