#install.packages("vistime")
library("vistime")
library(RColorBrewer)

g<-brewer.pal(9, "Greys")

df <- data.frame(event = c("NC\nConstruction", "NC\nExpansion", "AZ\nConstruction", "AZ\nExpansion", "PM2.5 Data", "Operating=0", "Operating=1"),
                 start = c("2005-03-01", "2012-12-01", "2005-07-01", "2012-07-01", "2000-01-01", "2000-01-01", "2008-12-01"), 
                 end   = c("2007-11-01", "2016-12-01", "2008-12-01", "2016-12-01", "2016-12-01", "2005-03-01", "2012-07-01"),
                 group = c("NC", "NC", "AZ", "AZ", "Combined", "Combined", "Combined"),
                 color = c(g[3:6], "#e21833", "#ffd200", "#ffd200"))

gg_vistime(df, col.group="group", linewidth=50)

png("Presentation/images/timeline.png", 
    res=500, width=5, height=3, units="in")

gg_vistime(df, col.group="group", linewidth=20)

dev.off()

