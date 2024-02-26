library("raster")
library("ncdf4")
library("tidyverse")
library("terra")

#turn cities buffers into polygons
cities<-read.csv("allcities_latlon.csv")

df<-cities |>
  filter(is.na(joint_address) | 
           joint_address=="Beloit, WI-IL" | 
           joint_address=="Phoenix-Mesa, AZ" |
           joint_address=="Duluth, MN-WI" |
           joint_address=="Denton-Lewisville, TX") 

c <- vect(df, geom=c("lon", "lat"), 
          crs=crs(bs))
pts_buffer<-buffer(c, width = 10000)

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
#for (i in 1:length(files_list)) {
for (i in 110:length(files_list)) {
  print(files_list[i])
  
  b<-brick(paste0("G:/Shared drives/2024 FIRE Light Rail/DATA/MERRA/",files_list[i]), varname="PRECTOT")
  bs <- as(b, "SpatRaster")
  int<-crop(bs, pts_buffer,snap="in",mask=TRUE)
  intdf<-terra::extract(int, pts_buffer, fun="mean", na.rm=TRUE)
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

output1<-read.csv("merra_output_10km_200901.csv")
output2<-rbind(output1, output)

df2<-df |>
  mutate(city_num=row_number())

output3<-merge(output2, df2, by="city_num") |>
  arrange(city_num, file)

write.csv(output3, "merra_output_10km.csv", row.names = F)

##################find cities with NA values######################################
temp<-output3 |>
  filter(is.na(TLML))
table(temp$city_num)

df3<-df2 |>
  filter(city_num==10 | city_num==20)

c <- vect(df3, geom=c("lon", "lat"), 
          crs=crs(bs))
pts_buffer<-buffer(c, width = 40000)

output<-c()
for (i in 1:length(files_list)) {
  print(files_list[i])
  
  b<-brick(paste0("G:/Shared drives/2024 FIRE Light Rail/DATA/MERRA/",files_list[i]), varname="PRECTOT")
  bs <- as(b, "SpatRaster")
  int<-crop(bs, pts_buffer,snap="in",mask=TRUE)
  intdf<-terra::extract(int, pts_buffer, fun="mean", na.rm=TRUE)
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
output$city_num<-output$city_num*10
df4<-merge(output, df3, by="city_num")

write.csv(df4, "merra_output_40km.csv", row.names = F)
