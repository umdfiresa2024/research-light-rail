library("tidyverse")
library("terra")
library("maptiles")

lon<- -77.0456
lat<- 38.9178
df<-as.data.frame(cbind(lon, lat))

x <- vect(df, geom=c("lon", "lat"), crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

pl<- vect("Presentation/Purple Line/PurpleLineAlignment.shp")

pl_project<-project(pl, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

e<-ext(c(-77.0949795115568, -76.8708509506637, 38.9, 39.0036747379653))

bg <- get_tiles(e, provider = "Esri.WorldGrayCanvas")

png("Presentation/images/purpleline.png", 
    res=500, width=7, height=5, units="in")

plot(e)
plot(bg, add=TRUE)
plot(pl_project, col="purple4", add=TRUE, lwd=2)
plot(x, pch=17, cex=2, add=TRUE)

dev.off()