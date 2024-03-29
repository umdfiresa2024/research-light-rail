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

#make light rail route buffer
lr_buffer<-terra::buffer(lr_project, width = 1000)

bg <- get_tiles(ext(lr_project))
plot(bg)

lines(lr_project, col="blue")
