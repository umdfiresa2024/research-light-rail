#city centroid
library("tidyverse")
library("terra")
library("maptiles")
library("ggmap") 

cities<-c("Las Cruces, NM", "Santa Fe, NM")
c<-as.data.frame(cities)

GoogleAPIKey<-"AIzaSyCA9_G1smyPrHEIa92k1IF0dwBsAGFCNXM"
register_google(key = GoogleAPIKey, write = TRUE)

addr.geo <- mutate_geocode(c, cities,
                           output = "latlona",
                           source = "google")

c2<-addr.geo |>
  rename(Address=cities) |>
  select(Address, lon, lat)

#converts df into a spatvector
x <- vect(c2, geom=c("lon", "lat"), crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

#create a 30 km (30,000 meter) buffer (radius)
pts_buffer<-buffer(x, width = 30000)

#primary roads in the US
r <- vect("G:/Shared drives/2024 FIRE Light Rail/DATA/tl_2016_us_primaryroads/tl_2016_us_primaryroads.shp")

#change projection system to match roads
pts_proj<-project(pts_buffer, crs(r))

plot(pts_proj)
lines(r, col="red")

#crop roads outside buffer areas
r_inside<-terra::intersect(r, pts_proj)

#create 1 km buffer around road segments
r_buff<-buffer(r_inside, width = 1000)

r_buff_agg<-aggregate(r_buff, by="Address")

#writeVector(r_buff_agg, "nm_buffers")

#################get pm2.5 data for one month##################################
path<-"G:/Shared drives/2024 FIRE Light Rail/DATA/PM25/"
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
    buff_proj <- terra::project(r_buff_agg,  crs(r))
    int<-crop(r, buff_proj,
              snap="in",
              mask=TRUE)
    
    cntrl_df<-terra::extract(int,  buff_proj, fun="mean", na.rm=TRUE)
    names(cntrl_df)<-c("city_num","pm25")
    output <- as.data.frame(c("date"=days[d], cntrl_df))
    days_output<-rbind(days_output, output)
    
  }
  write.csv(days_output, 
            paste0("PM25_daily/cntrl_nm",
                   months[m],
                   ".csv")
            , row.names = F)
}


