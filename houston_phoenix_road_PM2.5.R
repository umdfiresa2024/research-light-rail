library("tidyverse")
library("terra")
library("maptiles")

cities<-read.csv("allcities_latlon.csv")

df<-cities |>
  filter(joint_address=="Phoenix-Mesa, AZ" | Address == "Houston, TX") |>
  select(lon, lat)

#converts df into a spatvector
x <- vect(df, geom=c("lon", "lat"), crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

#create a 30 km (30,000 meter) buffer (radius)
pts_buffer<-buffer(x, width = 30000)

hbuff <- vect("houston_road_1km_buff/houston_road_1km_buff.shp")
pbuff <- vect("phoenix_lr_1km_buff/phoenix_lr_1km_buff.shp")
totbuff <- union(hbuff, pbuff)

#pts_proj<-project(pts_buffer, crs(r))
bg <- get_tiles(ext(totbuff))
plot(bg)
lines(totbuff, col="red")

path<-"/Users/landonthomas/Library/CloudStorage/GoogleDrive-landonct@terpmail.umd.edu/Shared drives/2024 FIRE Light Rail/DATA/PM25/"
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
    buff_proj <- terra::project(totbuff,  crs(r))
    int<-crop(r, buff_proj,
              snap="in",
              mask=TRUE)
    
    treat_df<-terra::extract(int,  buff_proj, fun="mean", na.rm=TRUE)
    names(treat_df)<-c("city_num","pm25")
    output <- as.data.frame(c("date"=days[d], treat_df))
    days_output<-rbind(days_output, output)
    
  }
  write.csv(days_output, 
            paste0("PM25_daily/treat_highways",
                   months[m],
                   ".csv")
            , row.names = F)
}

folder_path <- "PM25_daily"
for (year in 2000:2016) {
  # Iterate through each month
  for (month in 1:12) {
    # Construct the old and new filenames
    old_filename <- sprintf("%s/cntrl_highways%d_%02d.csv", folder_path, year, month)
    new_filename <- sprintf("%s/treat_highways%d_%02d.csv", folder_path, year, month)
    
    # Check if the old filename exists before renaming
    if (file.exists(old_filename)) {
      print(paste("Found", old_filename))
      file.rename(old_filename, new_filename)
      cat(sprintf("Renamed: %s to %s\n", old_filename, new_filename))
    }
  }
}

