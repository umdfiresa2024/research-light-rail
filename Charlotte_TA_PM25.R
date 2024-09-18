library("tidyverse")
library("ggmap")
library("terra")

path<-"G:/Shared drives/2024 FIRE Light Rail/DATA/PM25/"
months<-dir(path) #makes a vector of folder names
pts_buffer<-vect("Treatment Area Shapefiles/Charlotte_TA/Charlotte_TA.shp")
plot(pts_buffer)

for (m in 1:length(months)) {
  print(months[m])
  days<-dir(paste0(path,months[m])) #makes a vector of filenames within each folder
  
  
  days_output<-c()
  for (d in 1:length(days)) {
    print(days[d])
    
    #read tif file
    r<-rast(paste0(path, months[m], "/", days[d]))
    
    #changes the crs system
    buffer_project<-terra::project(pts_buffer,  crs(r))
    
    #pts_buffer is the buffer around stations
    #crops raster to contain only buffers around stations
    int<-crop(r, buffer_project,
              snap="in",
              mask=TRUE)
    
    #convert cropped raster into dataframe and fine average value
    cntrl_df<-terra::extract(int, buffer_project, fun="mean", na.rm=TRUE)
    
    #rename columns
    names(cntrl_df)<-c("station_num","pm25")
    
    #remove the "station_num" column
    cntrl_df <- cntrl_df %>% select(-station_num)
    
    #create a dataframe date, shape index, and pm25
    output <- as.data.frame(c("date"=days[d], cntrl_df))
    
    #combine output with previous loop
    days_output<-rbind(days_output, output)
  }
  
  write.csv(days_output, paste0("Charlotte_TA_PM25/", months[m],".csv"), row.names = F)
  
}
