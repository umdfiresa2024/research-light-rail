library("terra")
library("tidyverse")

# finding the mean pm2.5 inside the control circle

# path to the PM25 folder
path<-"G:/Shared drives/2023 FIRE-SA PRM/Spring Research/Light Rails/DATA/PM25/"
months<-dir(path)
#months_second<-months[58:204]
# Cincinnati - 1
# Greensboro: 36.0726, 79.7920 - 2
# Columbia: 34.000, 81.0348 - 3
# Ashville: 35.5951, 82.5515 - 4


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
    
    lon <- c(-84.5120,-79.7920,-81.0348,-82.5515)
    lat <- c(39.1031,36.0726,34.000,35.5951)
    df<-data.frame(cbind(lon, lat))
    x <- vect(df, geom=c("lon", "lat"), crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
    
    pts_buffer<-buffer(x, width = 10000)
    
    
    
    int<-crop(raster_project, pts_buffer,
              snap="in",
              mask=TRUE)
    
    cntrl_area<-terra::crop(int, pts_buffer, 
                            snap="in",
                            mask=TRUE)
    
    cntrl_df<-terra::extract(int, pts_buffer, fun="mean", na.rm=TRUE)
    names(cntrl_df)<-c("city_num","pm25")
    
    output <- as.data.frame(c("date"=days[d], cntrl_df))
    
    days_output<-rbind(days_output, output)
    
  }
  write.csv(days_output, 
            paste0("G:/Shared drives/2023 FIRE-SA PRM/Spring Research/Light Rails/DATA/cntrl_cities_PM25_daily/",
                   months[m],
                   ".csv")
            , row.names = F)
  
}

path<-"G:/Shared drives/2023 FIRE-SA PRM/Spring Research/Light Rails/DATA/cntrl_cities_PM25_daily/"
f<-dir(path)

output<-c()

for (i in 1:length(f)) {
  print(i)
  df<-read.csv(paste0(path,f[i])) %>%
    group_by(city_num) %>%
    summarize(pm25=mean(pm25)) %>%
    mutate(file=f[i])
  
  output<-rbind(output,df)
}

# Cincinnati - 1
# Greensboro: 36.0726, 79.7920 - 2
# Columbia: 34.000, 81.0348 - 3
# Ashville: 35.5951, 82.5515 - 4

name<-c("Cincinnati, OH", "Greensboro, NC", "Columbia, SC", "Asheville, NC")
o2<-cbind(output,name)
write.csv(o2, paste0(path, "pm25_allcities.csv"))

