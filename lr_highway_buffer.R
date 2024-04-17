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
lrc_buff<-buffer(lrc, width = 10000)

#make 1 km buffer around light rail route 
#lr_buffer<-terra::buffer(lr_project, width = 1000)
#writeVector(lr_buffer, "Houston Shapefiles/lr_1km_buff", overwrite=TRUE)
lr_buffer<-vect("Houston Shapefiles/lr_1km_buff")
  
#get roads data
r<-vect("G:/Shared drives/2024 FIRE Light Rail/DATA/tl_2021_txharris_roads/tl_2021_48201_roads.shp")
r_project<-project(r, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
i<-subset(r_project, r_project$RTTYP=="I")
c<-subset(r_project, r_project$RTTYP=="C")
m<-subset(r_project, r_project$RTTYP=="M")
o<-subset(r_project, r_project$RTTYP=="O")
s<-subset(r_project, r_project$RTTYP=="S")

#make plot of houston and light rail buffer
bg <- get_tiles(ext(lrc_buff)) #choose a number that will give a good picture of the light rail area
plot(bg)
lines(lr_project, col="blue")
lines(lr_buffer, col="black")
lines(lrc_buff, col="darkgreen")
lines(s, col="purple")
lines(i, col="red")

#crop s and i highways that are within 10 km of the light rail centroid
sint<-crop(s, lrc_buff)
iint<-crop(i, lrc_buff)
u<-aggregate(rbind(sint, iint), dissolve=TRUE)

#make a buffer around major roads but take out areas that overlap with the light rail
u_buffer<-terra::buffer(u, width = 1000)
plot(bg)
lines(u_buffer, col="purple")
lines(lr_project, col="blue")
writeVector(u_buffer, "Houston Shapefiles/roads_1km_buff", overwrite=TRUE)

l_nou<-erase(lr_buffer, u_buffer)
plot(l_nou)
writeVector(u_buffer, "Houston Shapefiles/lr_buff_noroads", overwrite=TRUE)

####Charlotte###################################################################

#get coordinate for city
df<-cities |>
  filter(Address=="Charlotte, NC") |>
  select(lon, lat)

#convert coordinates into a point shapefile
x <- vect(df, geom=c("lon", "lat"), crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

#light rail centroid
char_lr <- vect("G:/Shared drives/2022 FIRE-SA/ARCHIVED - SUMMER INTERNSHIP/Light Rail/DATA/LYNX_Blue_Line_Route/LYNX_Blue_Line_Route.shp")
char_lr<-aggregate(char_lr, dissolve=TRUE)
lr_project<-project(char_lr, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

lrc<-centroids(lr_project, inside=FALSE)
lrc_buff<-buffer(lrc, width = 15000)

lr_buffer<-terra::buffer(lr_project, width = 1000)
writeVector(lr_buffer, "ShapefilesOutput/nc_lr_1km_buff", overwrite=TRUE)
lr_buffer<-vect("ShapefilesOutput/nc_lr_1km_buff")

#get roads data
r<-vect("G:/Shared drives/2024 FIRE Light Rail/DATA/tl_2021_ncmecklenburg_roads/tl_2021_37119_roads.shp")
r_project<-project(r, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
i<-subset(r_project, r_project$RTTYP=="I")
c<-subset(r_project, r_project$RTTYP=="C")
m<-subset(r_project, r_project$RTTYP=="M")
o<-subset(r_project, r_project$RTTYP=="O")
s<-subset(r_project, r_project$RTTYP=="S")

#make plot of houston and light rail buffer
bg <- get_tiles(ext(lrc_buff)) #choose a number that will give a good picture of the light rail area
plot(bg)
lines(lr_project, col="blue")
lines(lr_buffer, col="black")
lines(lrc_buff, col="darkgreen")
lines(i, col="purple")



