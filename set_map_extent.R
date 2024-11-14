library("tidyverse")
library("terra")
library("maptiles")

#city centroid
cities<-read.csv("allcities_latlon.csv")

#get coordinate for city
df<-cities |>
  filter(Address=="Houston, TX") |>
  select(lon, lat)

#convert coordinates into a point shapefile
x <- vect(df, geom=c("lon", "lat"), crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

#light rail centroid
Transit_Map_GEO <- vect("National_Transit_Map_Routes/National_Transit_Map_Routes.shp")

trans <- subset(Transit_Map_GEO, Transit_Map_GEO$route_long == "METRORAIL RED LINE")

char_lr<-aggregate(trans, dissolve=TRUE)

lr_project<-project(char_lr, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
lr_buffer<-terra::buffer(lr_project, width = 2000) #2km buffer around light rail

u_buffer<-vect("houston_lr_buff_new/houston_lr_buff_new.shp")

bg <- get_tiles(ext(lr_buffer), provider = "Esri.WorldGrayCanvas")

######original map###############################################################
plot(bg)
lines(lr_project, col="yellow", lwd = 3)
lines(u_buffer, col = "black", lwd = 3)
legend("top", 
       legend = c("Light Rail Line", "Substitute Road Buffer"),  
       col = c("yellow", "black"),    
       lwd = 2,
       bty = "n")

######new map###############################################################

#print original extent
e1<-ext(lr_buffer)

#set square extent manually
yrange<-e1[4]-e1[3]
xrange<-e1[2]-e1[1]
maxrange<-max(yrange, xrange)

e2<-ext(c(e1[1]-0.1, e1[1]+maxrange+0.1, e1[3]-0.1, e1[3]+maxrange+0.1))
bg <- get_tiles(ext(e2), provider = "Esri.WorldGrayCanvas")

plot(e2)
plot(bg, add=TRUE)
lines(lr_project, col="#ffd200", lwd = 3)
lines(u_buffer, col = "black", lwd = 3)
legend("top", 
       legend = c("Light Rail Line", "Substitute Road Buffer"),  
       col = c("#ffd200", "black"),    
       lwd = 2,
       bty = "n")

#save plot as png

png("houston_treat.png", width=5, height=5, units="in",res=500)
plot(e2)
plot(bg, add=TRUE)
lines(lr_project, col="#ffd200", lwd = 3)
lines(u_buffer, col = "black", lwd = 3)
legend("top", 
       legend = c("Light Rail Line", "Substitute Road Buffer"),  
       col = c("#ffd200", "black"),    
       lwd = 2,
       bty = "n")
dev.off()