install.packages("vistime")
library("vistime")

df <- data.frame(event = c("NC Construction", "NC Expansion", "AZ Construction", "AZ Expansion", "PM2.5 Data"),
                            start = c("2005-03-01", "2012-12-01", "2005-07-01", "2012-07-01", "2000-01-01"), 
                            end   = c("2007-11-01", "2013-12-01", "2008-12-01", "2013-12-01", "2013-12-01"),
                            group = "NC", "NC", "AZ", "AZ", "All")

png("Presentation/images/timeline.png", 
    res=500, width=5, height=5, units="in")

vistime(df)

dev.off()

