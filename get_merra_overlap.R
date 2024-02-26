library("raster")
library("ncdf4")
library("tidyverse")
library("terra")

#turn cities buffers into polygons
cities<-read.csv("allcities_latlon.csv")

#test which joint_address cities have overlapping 10km buffer radius
az<-cities |>
  filter(joint_address=="Myrtle Beach-Socastee, SC-NC") |>
  select(lon, lat)

x <- vect(az, geom=c("lon", "lat"), crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
pts_buffer<-buffer(x, width = 10000)
plot(pts_buffer)
agg<-aggregate(pts_buffer)
plot(agg)

az<-cities |>
  filter(joint_address=="College Station-Bryan, TX") |>
  select(lon, lat)

x <- vect(az, geom=c("lon", "lat"), crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
pts_buffer<-buffer(x, width = 20000)
plot(pts_buffer)
agg2<-aggregate(pts_buffer)
plot(agg2)

az<-cities |>
  filter(joint_address=="Charleston-North Charleston, SC") |>
  select(lon, lat)

x <- vect(az, geom=c("lon", "lat"), crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
pts_buffer<-buffer(x, width = 10000)
plot(pts_buffer)
agg3<-aggregate(pts_buffer)
plot(agg3)

pts_buffer<-rbind(agg, agg2, agg3)
plot(pts_buffer)


#loop through merra files
#PRECTOT total precipitation from atm model physics(kg/m^2 s)
#QLML surface specific humidity (1)
#QSH effective surface specific humidity (kg/kg)
#RHOA air density at surface (kg/m^3)
#SPEED surface wind speed (m/s)
#TLML surface air temperature (K)
#ULML surface surface eastward wind 
#VLML surface northward wind 
#PRECSNO snowfall (kg/m^2 s)

files_list<-dir("G:/Shared drives/2024 FIRE Light Rail/DATA/MERRA")

output<-c()
for (i in 1:length(files_list)) {
  print(files_list[i])
  
  b<-brick(paste0("G:/Shared drives/2024 FIRE Light Rail/DATA/MERRA/",files_list[i]), varname="PRECTOT")
  bs <- as(b, "SpatRaster")
  int<-crop(bs, pts_buffer ,snap="in",mask=TRUE)
  intdf<-terra::extract(int, pts_buffer , fun="mean", na.rm=TRUE)
  names(intdf)<-c("city_num","PRECTOT")
  vardf<-intdf

  vars<-c("PRECSNO", "QSH", "RHOA", "SPEED", "TLML")
  for (j in 1:length(vars)) {
    b<-brick(paste0("G:/Shared drives/2024 FIRE Light Rail/DATA/MERRA/",files_list[i]), varname=vars[j])
    bs <- as(b, "SpatRaster")
    int<-crop(bs, pts_buffer,snap="in",mask=TRUE)
    intdf<-terra::extract(int, pts_buffer, fun="mean", na.rm=TRUE)
    names(intdf)<-c("city_num",vars[j])
    vardf<-merge(vardf, intdf, by="city_num")
    }

  vardf$file<-files_list[i]
  output<-rbind(output, vardf)
}

df<-cities |>
  filter(joint_address=="Myrtle Beach-Socastee, SC-NC" |
           joint_address=="College Station-Bryan, TX" |
           joint_address=="Charleston-North Charleston, SC") |>
  group_by(joint_address) |>
  tally() |>
  arrange(desc(joint_address)) |>
  mutate(city_num=row_number()) |>
  select(-n)

output2<-merge(output, df, by="city_num") |>
  arrange(city_num, file)

write.csv(output2, "merra_output_overlap.csv", row.names = F)

