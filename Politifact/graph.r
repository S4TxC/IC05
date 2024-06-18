library(ggplot2)
library(RColorBrewer)

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
count_faux_filtered <- subset(count_faux, count> 100)
count_faux_filtered <- count_faux_filtered[!(count_faux_filtered$tag %in% us_states), ]
count_faux_states <- subset(count_faux, tag %in% us_states)

ggplot(count_faux_states, aes(x = tag, y = count)) +
  geom_bar(stat = "identity") +
  labs(title = "Nombre d'articles faux par Etat", x = "Tag", y = "Nombre d'articles faux") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(count_faux_filtered, aes(x = tag, y = count)) +
  geom_bar(stat = "identity") +
  labs(title = "Nombre d'articles faux par Tag", x = "Tag", y = "Nombre d'articles faux") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

db_states <- db[db$Tag %in% us_states, ]

palette <- c(
  "California" = "#1f77b4", "Texas" = "#ff7f0e", "Florida" = "#2ca02c", "New York" = "#a63730",
  "Alaska" = "#9467bd", "Alabama" = "#8c564b", "Arizona" = "#e377c2", "Arkansas" = "#7f7f7f",
  "Colorado" = "#bcbd22", "Connecticut" = "#17becf", "Delaware" = "#aec7e8", "Georgia" = "#ffbb78",
  "Hawaii" = "#98df8a", "Idaho" = "#ff9896", "Illinois" = "#c5b0d5", "Indiana" = "#c49c94",
  "Iowa" = "#f7b6d2", "Kansas" = "#c7c7c7", "Kentucky" = "#dbdb8d", "Louisiana" = "#9edae5",
  "Maine" = "#1f77b4", "Maryland" = "#ff7f0e", "Massachusetts" = "#2ca02c", "Michigan" = "#d62728",
  "Minnesota" = "#9467bd", "Mississippi" = "#8c564b", "Missouri" = "#e377c2", "Montana" = "#7f7f7f",
  "Nebraska" = "#bcbd22", "Nevada" = "#17becf", "New Hampshire" = "#aec7e8", "New Jersey" = "#ffbb78",
  "New Mexico" = "#98df8a", "North Carolina" = "#ff9896", "North Dakota" = "#c5b0d5", "Ohio" = "#c49c94",
  "Oklahoma" = "#f7b6d2", "Oregon" = "#c7c7c7", "Pennsylvania" = "#dbdb8d", "Rhode Island" = "#9edae5",
  "South Carolina" = "#1f77b4", "South Dakota" = "#ff7f0e", "Tennessee" = "#8ca02c", "Utah" = "#d62728",
  "Vermont" = "#9467bd", "Virginia" = "#8c564b", "Washington" = "#e377c2", "West Virginia" = "#7f7f7f",
  "Wisconsin" = "#bcbd22", "Wyoming" = "#17becf"
)

db_states$Verdict <- factor(db_states$Verdict, levels = c(
  "True", "Mostly accurate", "Half accurate", "Barely accurate", 
  "False", "Flagrant falsehood", "Full change of position", 
  "Partial change of position", "Consistent"
))

ggplot(db_states, aes(x = Verdict, fill = Tag)) +
  geom_bar() +
  scale_fill_manual(values = palette) +
  labs(title = "Nombre d'articles par véracité et selon les états", x = "Verdict", y = "Nombre d'articles", fill = "État") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

