library("tidyverse")
library("terra")
library("maptiles")

#city centroid
cities<-read.csv("allcities_latlon.csv")

#get coordinate for city
df<-cities |>
  filter(Address=="Charlotte, NC") |>
  select(lon, lat)

#convert coordinates into a point shapefile
x <- vect(df, geom=c("lon", "lat"), crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

#light rail centroid
char_lr <- vect("G:/Shared drives/2024 FIRE Light Rail/DATA/LYNX_Blue_Line_Route/LYNX_Blue_Line_Route.shp")
char_lr<-aggregate(char_lr, dissolve=TRUE)
lr_project<-project(char_lr, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

lrc<-centroids(lr_project, inside=FALSE)
lrc_buff<-buffer(lrc, width = 15000)
lr_buffer<-terra::buffer(lr_project, width = 5000)
#writeVector(lr_buffer, "Charlotte Shapefiles/lr_1km_buff", overwrite=TRUE)

#get roads data
r<-vect("G:/Shared drives/2024 FIRE Light Rail/DATA/tl_2021_ncmecklenburg_roads/tl_2021_37119_roads.shp")
r_project<-project(r, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
i<-subset(r_project, r_project$RTTYP=="I")
ic_buffer<-terra::buffer(i, width = 1000)
c<-subset(r_project, r_project$RTTYP=="C")
m<-subset(r_project, r_project$RTTYP=="M")
o<-subset(r_project, r_project$RTTYP=="O")
s<-subset(r_project, r_project$RTTYP=="S")
oc_buffer<-terra::buffer(o, width = 1000)

#make plot of light rail buffer
bg <- get_tiles(ext(lrc_buff)) #choose a number that will give a good picture of the light rail area
plot(bg)
lines(lr_project, col="blue")
lines(lr_buffer, col="black")
lines(lrc_buff, col="darkgreen")
lines(ic_buffer, col="purple")
lines(sc_buffer, col="red")

#crop s and i highways that are within 10 km of the light rail centroid
oint<-crop(oc_buffer, lr_buffer)
iint<-crop(ic_buffer, lr_buffer)
u<-aggregate(rbind(oint, iint), dissolve=TRUE)

#make a buffer around major roads but take out areas that overlap with the light rail
u_buffer<-terra::buffer(u, width = 1000)
plot(bg)
lines(u_buffer, col="purple", lwd = 5)
lines(lr_project, col="blue", lwd = 5)

writeVector(u_buffer, "Treatment Area Shapefiles/Charlotte_TA", overwrite=TRUE)
