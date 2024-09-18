library("tidyverse")
library("terra")
library("maptiles")

#city centroid
cities<-read.csv("allcities_latlon.csv")

#get coordinate for city
df<-cities |>
  filter(Address=="Minneapolis-St. Paul, MN") |>
  select(lon, lat)

#convert coordinates into a point shapefile
x <- vect(df, geom=c("lon", "lat"), crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

#light rail centroid
Transit_Map_GEO <- vect("National_Transit_Map_Routes/National_Transit_Map_Routes.shp")
trans <- subset(
  Transit_Map_GEO, 
  Transit_Map_GEO$route_url == "https://www.metrotransit.org/route/blue" | 
    Transit_Map_GEO$route_url == "https://www.metrotransit.org/route/green")
char_lr<-aggregate(trans, dissolve=TRUE)
lr_project<-project(char_lr, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
lr_buffer<-terra::buffer(lr_project, width = 2000) #2km buffer around light rail

#get roads data
r<-vect("G:/Shared drives/2024 FIRE Light Rail/DATA/tl_2021_mnramsey_roads/tl_2021_27123_roads.shp")
r_project<-project(r, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
i<-subset(r_project, r_project$RTTYP=="I")
ic_buffer<-terra::buffer(i, width = 500)
c<-subset(r_project, r_project$RTTYP=="C")
m<-subset(r_project, r_project$RTTYP=="M")
o<-subset(r_project, r_project$RTTYP=="O")
s<-subset(r_project, r_project$RTTYP=="S")
sc_buffer<-terra::buffer(s, width = 500)

r2<-vect("G:/Shared drives/2024 FIRE Light Rail/DATA/tl_2021_mnhennepin_roads/tl_2021_27053_roads.shp")
r_project<-project(r2, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
i2<-subset(r_project, r_project$RTTYP=="I")
ic2_buffer<-terra::buffer(i2, width = 500)
c2<-subset(r_project, r_project$RTTYP=="C")
m2<-subset(r_project, r_project$RTTYP=="M")
o2<-subset(r_project, r_project$RTTYP=="O")
s2<-subset(r_project, r_project$RTTYP=="S")
sc2_buffer<-terra::buffer(s2, width = 500)

#make plot of light rail buffer
bg <- get_tiles(ext(lr_buffer)) #choose a number that will give a good picture of the light rail area
plot(bg)
lines(lr_project, col="blue")
lines(lr_buffer, col="black")
lines(ic_buffer, col="purple")
lines(sc_buffer, col="red")
lines(ic2_buffer, col="purple")
lines(sc2_buffer, col="red")

#crop s and i highways that are within 10 km of the light rail centroid
sint<-crop(sc_buffer, lr_buffer)
iint<-crop(ic_buffer, lr_buffer)
sint2<-crop(sc2_buffer, lr_buffer)
iint2<-crop(ic2_buffer, lr_buffer)
u<-aggregate(rbind(sint, iint, sint2, iint2), dissolve=TRUE)

#make a buffer around major roads but take out areas that overlap with the light rail
u_buffer<-terra::buffer(u, width = 1000)
plot(bg)
lines(u_buffer, col="purple", lwd = 5)
lines(lr_project, col="blue", lwd = 5)

writeVector(u_buffer, "Treatment Area Shapefiles/Twin_Cities_TA", overwrite=TRUE)
