library("tidyverse")
library("terra")

hbuff <- vect("houston_lr_buff_new/houston_lr_buff_new.shp")
#pbuff <- vect("phoenix_lr_buff_new/phoenix_lr_buff_new.shp")
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

# folder_path <- "PM25_daily"
# for (year in 2000:2016) {
#   # Iterate through each month
#   for (month in 1:12) {
#     # Construct the old and new filenames
#     old_filename <- sprintf("%s/cntrl_highways%d_%02d.csv", folder_path, year, month)
#     new_filename <- sprintf("%s/treat_highways%d_%02d.csv", folder_path, year, month)
#     
#     # Check if the old filename exists before renaming
#     if (file.exists(old_filename)) {
#       print(paste("Found", old_filename))
#       file.rename(old_filename, new_filename)
#       cat(sprintf("Renamed: %s to %s\n", old_filename, new_filename))
#     }
#   }
# }
