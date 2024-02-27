library("terra")
library("tidyverse")

#charlotte
char_lr <- vect("G:/Shared drives/2022 FIRE-SA/ARCHIVED - SUMMER INTERNSHIP/Light Rail/DATA/LYNX_Blue_Line_Route/LYNX_Blue_Line_Route.shp")
char_lr<-aggregate(char_lr, dissolve=TRUE)
lr_project<-project(char_lr, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
lrc<-centroids(lr_project, inside=FALSE)
pts_buffer1<-buffer(lrc, width = 10000)

#houston
Transit_Map_GEO <- vect("G:/Shared drives/2022 FIRE-SA/ARCHIVED - SUMMER INTERNSHIP/Light Rail/DATA/National_Transit_Map_Routes/National_Transit_Map_Routes.shp")
trans <- subset(Transit_Map_GEO, Transit_Map_GEO$route_long == "METRORAIL RED LINE")
char_lr<-aggregate(trans, dissolve=TRUE)
lr_project<-project(char_lr, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
lrc<-centroids(lr_project, inside=FALSE)
pts_buffer2<-buffer(lrc, width = 10000)

#mn
Transit_Map_GEO <- vect("G:/Shared drives/2022 FIRE-SA/ARCHIVED - SUMMER INTERNSHIP/Light Rail/DATA/National_Transit_Map_Routes/National_Transit_Map_Routes.shp")
trans <- subset(Transit_Map_GEO, Transit_Map_GEO$route_url == "https://www.metrotransit.org/route/blue" | 
                  Transit_Map_GEO$route_url == "https://www.metrotransit.org/route/green")
char_lr<-aggregate(trans, dissolve=TRUE)
lr_project<-project(char_lr, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
lrc<-centroids(lr_project, inside=FALSE)
pts_buffer3<-buffer(lrc, width = 10000)

#phoenix-mesa
Transit_Map_GEO <- vect("G:/Shared drives/2022 FIRE-SA/ARCHIVED - SUMMER INTERNSHIP/Light Rail/DATA/Valley_Metro_Light_Rail/LightRailLine.shp")
trans <- subset(Transit_Map_GEO, Transit_Map_GEO$SYMBOLOGY=="METRO")
char_lr<-aggregate(trans, dissolve=TRUE)
lr_project<-project(char_lr, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
lrc<-centroids(lr_project, inside=FALSE)
pts_buffer4<-buffer(lrc, width = 10000)

pts_buffer<-rbind(pts_buffer1, pts_buffer2, pts_buffer3, pts_buffer4)

plot(pts_buffer)

#get pm2.5 data for one month
path<-"G:/Shared drives/2023 FIRE-SA PRM/Spring Research/Light Rails/DATA/PM25/"
months<-dir(path)
# for each month
for (m in 175:length(months)) {
  print(months[m])
  days<-dir(paste0(path,months[m]))
  
  # for each day in this month
  days_output<-c()
  for (d in 1:length(days)) {
    
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
            paste0("PM25_daily/lr_centroid_",
                   months[m],
                   ".csv")
            , row.names = F)
  
}

write.csv(days_output, 
          paste0("PM25_daily/lr_centroid_20140712",
                 months[m],
                 ".csv")
          , row.names = F)
