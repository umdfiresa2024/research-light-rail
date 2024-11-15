
library("terra")

az<-vect("tl_2010_AZ_puma10/tl_2010_04_puma10.shp")

Transit_Map_GEO <- vect("Valley_Metro_Light_Rail/LightRailLine.shp")
trans <- subset(Transit_Map_GEO, Transit_Map_GEO$SYMBOLOGY=="METRO")
char_lr<-aggregate(trans, dissolve=TRUE)
lr_project<-project(char_lr, crs(az))

plot(az)
plot(lr_project,add=TRUE, col="blue")

acs_2011 <- read.csv("acs_by_puma/acs_2011.csv", header=TRUE)

acs_2005 <- read.csv("acs_by_puma/acs_2005.csv", header=TRUE)
