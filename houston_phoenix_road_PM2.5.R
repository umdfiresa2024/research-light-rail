library("tidyverse")
library("terra")

hbuff <- vect("houston_lr_buff_new/houston_lr_buff_new.shp")
pbuff <- vect("phoenix_lr_buff_new/phoenix_lr_buff_new.shp")
#totbuff <- union(hbuff, pbuff)

path<-"G:/Shared drives/2024 FIRE Light Rail/DATA/PM25/"
months<-dir(path)
# for each month
for (m in 1:length(months)) {
  days<-dir(paste0(path,months[m]))
  
  # for each day in this month
  days_output<-c()
  for (d in 1:length(days)) {
    
    print(days[d])
    
    r<-rast(paste0(path, months[m], "/", days[d]))
    buff_proj <- terra::project(hbuff,  crs(r))
    int<-crop(r, buff_proj,
              snap="in",
              mask=TRUE)
    
    treat_df<-terra::extract(int,  buff_proj, fun="mean", na.rm=TRUE)
    names(treat_df)<-c("city_num","pm25")
    output <- as.data.frame(c("date"=days[d], treat_df))
    days_output<-rbind(days_output, output)
    
  }
  write.csv(days_output, 
            paste0("Houston_TA_PM25/",
                   months[m],
                   ".csv")
            , row.names = F)
}

############################################################################

path<-"G:/Shared drives/2024 FIRE Light Rail/DATA/PM25/"
months<-dir(path)
# for each month
for (m in 1:length(months)) {
  days<-dir(paste0(path,months[m]))
  
  # for each day in this month
  days_output<-c()
  for (d in 1:length(days)) {
    
    print(days[d])
    
    r<-rast(paste0(path, months[m], "/", days[d]))
    buff_proj <- terra::project(pbuff,  crs(r))
    int<-crop(r, buff_proj,
              snap="in",
              mask=TRUE)
    
    treat_df<-terra::extract(int,  buff_proj, fun="mean", na.rm=TRUE)
    names(treat_df)<-c("city_num","pm25")
    output <- as.data.frame(c("date"=days[d], treat_df))
    days_output<-rbind(days_output, output)
    
  }
  write.csv(days_output, 
            paste0("Phoenix_TA_PM25/",
                   months[m],
                   ".csv")
            , row.names = F)
}

