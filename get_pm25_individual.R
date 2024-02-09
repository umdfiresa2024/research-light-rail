library("terra")
library("tidyverse")

cities<-read.csv("allcities_latlon.csv")

df<-cities |>
  filter(is.na(joint_address) | 
           joint_address=="Beloit, WI-IL" | 
           joint_address=="Phoenix-Mesa, AZ" |
           joint_address=="Duluth, MN-WI" |
           joint_address=="Denton-Lewisville, TX") 
write.csv(df, "nonoverlap_cities.csv")

df2<-df |>
  select(lon, lat)

x <- vect(df2, geom=c("lon", "lat"), crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
pts_buffer<-buffer(x, width = 10000)

#get pm2.5 data for one month
path<-"G:/Shared drives/2023 FIRE-SA PRM/Spring Research/Light Rails/DATA/PM25/"
months<-dir(path)
# for each month
for (m in 1:length(months)) {
  print(months[m])
  #for (m in 1:2) {
  days<-dir(paste0(path,months[m]))
  
  # for each day in this month
  days_output<-c()
  for (d in 1:length(days)) {
    #for (d in 1:2) {
    
    print(days[d])
    r<-rast(paste0(path, months[m], "/", days[d]))
    raster_project <- terra::project(r,  "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
    int<-crop(raster_project, pts_buffer,
              snap="in",
              mask=TRUE)
    
    cntrl_df<-terra::extract(int, pts_buffer, fun="mean", na.rm=TRUE)
    names(cntrl_df)<-c("city_num","pm25")
    output <- as.data.frame(c("date"=days[d], cntrl_df))
    days_output<-rbind(days_output, output)
    
  }
  write.csv(days_output, 
            paste0("PM25_daily/",
                   months[m],
                   ".csv")
            , row.names = F)
  
}
