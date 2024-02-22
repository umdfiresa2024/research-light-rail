library("raster")
library("ncdf4")
library("data.table")
library("tidyverse")
library("terra")

files_list<-dir("G:/Shared drives/2024 FIRE Light Rail/DATA/MERRA")

i<-1
df<-nc_open(paste0("G:/Shared drives/2024 FIRE Light Rail/DATA/MERRA/",files_list[i]))

lon<-as.vector(df$dim$lon$vals)
lat<-as.vector(df$dim$lat$vals)
d<-crossing(lon, lat)

x <- vect(d, geom=c("lon", "lat"),
          crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

cities<-read.csv("allcities_latlon.csv")

df<-cities |>
  filter(is.na(joint_address) | 
           joint_address=="Beloit, WI-IL" | 
           joint_address=="Phoenix-Mesa, AZ" |
           joint_address=="Duluth, MN-WI" |
           joint_address=="Denton-Lewisville, TX") 

df2<-df |>
  select(lon, lat)

i<-1
df
c <- vect(df2[i,], geom=c("lon", "lat"), 
          crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
pts_buffer<-buffer(c, width = 20000)
plot(pts_buffer)
plot(x, add=TRUE)

i <- relate(pts_buffer, x, "contains") |> which()

d2<-d[i,]
latidx<-which(lat == d2$lat)
lonidx<-which(lon == d2$lon)
