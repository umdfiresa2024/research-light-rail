library("terra")
library("tidyverse")

cities<-read.csv("allcities_latlon.csv")

df<-cities |>
  filter(is.na(joint_address) | 
           joint_address=="Beloit, WI-IL" | 
           joint_address=="Phoenix-Mesa, AZ" |
           joint_address=="Duluth, MN-WI" |
           joint_address=="Denton-Lewisville, TX") 

df2<-df |>
  select(lon, lat)

#get sample raster for crs
r<-rast("G:/Shared drives/2023 FIRE-SA/FALL OUTPUT/Team Greenlight/NASAMODIS Data/2000.nc4")
crsr<-crs(r)

x <- vect(df2, geom=c("lon", "lat"), crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
pts_buffer<-buffer(x, width = 10000)
pts_project<-terra::project(pts_buffer,  crsr)

#test crop for year 2000
r_output<-c()

for (i in 1:length(names(r))) {
  print(time(r[[i]]))
  int<-crop(r[[i]], pts_project,snap="in",mask=TRUE)
  dfr<-terra::extract(int, pts_project, fun="mean", na.rm=TRUE) 
  names(dfr)<-c("ID", "NDVI")
  dfr$time<-time(r[[i]])
  r_output<-rbind(r_output, dfr)
  }

write.csv(r_output, "NDVI/indv_2000.csv", row.names = F)
  

