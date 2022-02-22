getwd()
setwd("C:/Users/Marcin Czarniecki/Documents/R_Project")
library(readxl)
sales <- read_excel("GlobalSales.xlsx")


# A glimpse for the data

sales
head(sales)
tail(sales)
str(sales)
summary(sales)

# Cleaning and converting data types.

head(sales[17:22])
sales$Sales_per_unit
sales$Sales_per_unit <- gsub("\\$", "", sales$Sales_per_unit)
sales$Sales_per_unit <-gsub(",", ".", sales$Sales_per_unit)
sales$Sales_per_unit <- as.numeric(sales$Sales_per_unit)
typeof(sales$Sales_per_unit)

sales$`Shipping Cost`
sales$`Shipping Cost` <-gsub("\\$", "", sales$`Shipping Cost`)
sales$`Shipping Cost` <-gsub(",", ".", sales$`Shipping Cost`)
sales$`Shipping Cost` <- as.numeric(sales$`Shipping Cost`)
typeof(sales$`Shipping Cost`)


sales$Quantity
sales$Quantity <-gsub(" unit", ".", sales$Quantity)
sales$Quantity <- as.numeric(sales$Quantity)
typeof(sales$Quantity)
str(sales)

# Looking at missing data


sales[!complete.cases(sales),]

sales$`Postal Code`

# Remove Postal Code column because most of the values are Nan's
# and is not needed for further analysis

library(dplyr)
select(sales, -`Postal Code`)
sales <- select(sales, -`Postal Code`)  
str(sales)

sales[!complete.cases(sales),]
sales[17:21][!complete.cases(sales),]


is.na(sales$`Shipping Cost`)
sales[is.na(sales$`Shipping Cost`),]



sales_backup <- sales # create backup in case of restore data


#Replacing Missing Data: Median Imputation Method 

  sales <-sales %>%
  group_by(Country) %>%
  mutate(`Shipping Cost` = ifelse(is.na(`Shipping Cost`), 
                                  median(`Shipping Cost`, na.rm = TRUE), 
                                  `Shipping Cost`))
                                    

sales[is.na(sales$`Shipping Cost`),]


# Compute Total sales and add new column to the dataset.

sales$TotalSales <- round(sales$Sales_per_unit, 2) * sales$Quantity
str(sales)




# Visualizations 


library(ggplot2)
library(viridis)


# Boxplots - Sales by product category

filter1 <- filter(sales, TotalSales <1000 )

b <- ggplot(data = filter1, aes(x=Category, y=TotalSales, colour=Category ))

boxplot <- b +  geom_boxplot(size= 1.5) 
boxplot +  scale_color_viridis(discrete = TRUE,option = "D") +
  ylab("Number of Sales")+
  xlab("") +
  ggtitle("Sales by Product Category") +
  theme(axis.title.x=element_text(size=13),
        axis.title.y = element_text(size = 13),
        axis.text.x = element_text(size = 11),
        axis.text.y = element_text(size = 11),
        legend.title = element_text(size = 12),
        legend.text =element_text(size=12),
        plot.title = element_text(size=15, face = "bold", hjust = 0.5),
        text = element_text (family = "mono")) 



# Bar plot - Shipping cost by region

filter2 <-sales %>%
  group_by(Region) %>%
  summarise_at(vars(`Shipping Cost`),
                    list(`Shipping Cost`=mean))



c <- ggplot(data=filter2, aes( y=reorder(Region,+`Shipping Cost`), x=`Shipping Cost`,))

column <- c  + geom_col(fill = "DarkGreen") 
column + 
  xlab("Shipping Cost") +
  ylab("Region") +
  ggtitle("Shipping Cost by Region") +
  theme(axis.title.x=element_text(size=13,face = "bold"),
        axis.title.y = element_text(size = 13, face = "bold"),
        axis.text.x = element_text(size = 11),
        axis.text.y = element_text(size = 11),
        legend.title = element_text(size = 12),
        legend.text =element_text(size=12),
        plot.title = element_text(size=15, face = "bold", hjust = 0.5),
        text = element_text (family = "mono"))



# Histogram - Sales Distribution by Client Segment

filter1 <- filter(sales, TotalSales <1000 )

a <- ggplot(data=filter1,aes(x=TotalSales ))

histogram <-a + geom_histogram(binwidth = 50, aes(fill=Segment), colour="Black") 

histogram + 
  scale_fill_viridis(discrete = TRUE,option = "D") +
  xlab("Sales") +
  ylab("Number of Sales") +
  ggtitle("Sales Distribution by Client Segment") +
  theme(axis.title.x=element_text(size=13,face = "bold"),
        axis.title.y = element_text(size = 13, face = "bold"),
        axis.text.x = element_text(size = 11),
        axis.text.y = element_text(size = 11),
        legend.title = element_text(size = 12),
        legend.text =element_text(size=12),
        plot.title = element_text(size=15, face = "bold", hjust = 0.5),
        text = element_text (family = "mono"))


# Histograms - Sales distribution by  Client Segment

histogram_facet_grid <- a + geom_histogram(binwidth = 50, aes(fill=Segment), colour="Black" ) +
  facet_grid(Segment~., scales = "free")

histogram_facet_grid +
  scale_fill_viridis(discrete = TRUE,option = "D") +
  xlab("Sales") +
  ylab("Number of Sales") +
  ggtitle("Sales Distribution by Segment") +
  theme(axis.title.x=element_text(size=13,face = "bold"),
        axis.title.y = element_text(size = 13, face = "bold"),
        axis.text.x = element_text(size = 11),
        axis.text.y = element_text(size = 11),
        legend.title = element_text(size = 12),
        legend.text =element_text(size=12),
        plot.title = element_text(size=15, face = "bold", hjust = 0.5),
        text = element_text (family = "mono"))



# Density chart - Sales distribution by Market

density <- a + geom_density(aes(fill=Market), position = "stack")

density + scale_fill_viridis(discrete = TRUE,option = "E") +
  xlab("Sales") +
  ggtitle("Sales Distribution by Market") +
  theme(axis.title.x=element_text(size=13,face = "bold"),
        axis.title.y = element_text(size = 13, face = "bold"),
        axis.text.x = element_text(size = 11),
        axis.text.y = element_text(size = 11),
        legend.title = element_text(size = 12),
        legend.text =element_text(size=12),
        plot.title = element_text(size=15, face = "bold", hjust = 0.5),
        text = element_text (family = "mono"))


































