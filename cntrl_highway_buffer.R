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

#light raile route shapefile
Transit_Map_GEO <- vect("G:/Shared drives/2022 FIRE-SA/ARCHIVED - SUMMER INTERNSHIP/Light Rail/DATA/National_Transit_Map_Routes/National_Transit_Map_Routes.shp")
trans <- subset(Transit_Map_GEO, Transit_Map_GEO$route_long == "METRORAIL RED LINE")
char_lr<-aggregate(trans, dissolve=TRUE)
lr_project<-project(char_lr, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

#make 10 km buffer around light rail centroid
lrc<-centroids(lr_project, inside=FALSE)
#lrc_buff<-buffer(lrc, width = 10000)
#writeVector(lrc_buff, "Houston Shapefiles/lr_1km_buff", overwrite=TRUE)
lrc_buffer<-vect("Houston Shapefiles/lr_1km_buff")

#make 1 km buffer around light rail route 
#lr_buffer<-terra::buffer(lr_project, width = 1000)

#get roads data
r<-vect("G:/Shared drives/2024 FIRE Light Rail/DATA/tl_2021_txharris_roads/tl_2021_48201_roads.shp")
r_project<-project(r, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
i<-subset(r_project, r_project$RTTYP=="I")
c<-subset(r_project, r_project$RTTYP=="C")
m<-subset(r_project, r_project$RTTYP=="M")
o<-subset(r_project, r_project$RTTYP=="O")
s<-subset(r_project, r_project$RTTYP=="S")

#make plot of houston and light rail buffer
bg <- get_tiles(ext(lr_project)) #choose a number that will give a good picture of the light rail area
plot(bg)
lines(lr_project, col="blue")
#lines(lr_buffer, col="black")
lines(lrc_buffer, col="darkgreen")
lines(s, col="purple")
lines(i, col="red")

#crop s and i highways that are within 10 km of the light rail centroid
sint<-crop(s, lrc_buffer)
iint<-crop(i, lrc_buffer)
u<-aggregate(rbind(sint, iint), dissolve=TRUE)

#make a buffer around major roads but take out areas that overlap with the light rail
u_buffer<-terra::buffer(u, width = 1000)
u_nolr<-erase(u_buffer, lr_buffer)
  
bg <- get_tiles(ext(lrc_buffer)) #choose a number that will give a good picture of the light rail area
plot(bg)
lines(lr_project, col="blue")
lines(lr_buffer, col="black")
lines(lrc_buff, col="darkgreen")
lines(u_nolr, col="purple")


