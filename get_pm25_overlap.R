library("terra")
library("tidyverse")

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
    int<-crop(raster_project, agg,
          snap="in",
          mask=TRUE)
    
    cntrl_df<-terra::extract(int, agg, fun="mean", na.rm=TRUE)
    names(cntrl_df)<-c("city_num","pm25")
    output <- as.data.frame(c("date"=days[d], cntrl_df))
    days_output<-rbind(days_output, output)
    
  }
  write.csv(days_output, 
            paste0("PM25_daily/myrtle_socastee_",
                   months[m],
                   ".csv")
            , row.names = F)
  
}







