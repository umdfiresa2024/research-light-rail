#city centroid
library("tidyverse")
library("terra")
library("maptiles")

cities<-read.csv("allcities_latlon.csv")

cgroup<-c("Asheville, NC", "Charleston, SC", 
          "Columbia, SC", "Durham, NC", "Fayetteville, NC", 
          "Greenville, SC", 
          "Winston-Salem, NC")

c2<-cities |>
  filter(Address %in% cgroup) |>
  select(Address, lon, lat)

#converts df into a spatvector
x <- vect(c2, geom=c("lon", "lat"), crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

t<-cities |>
  filter(Address %in% "Charlotte, NC") |>
  select(Address, lon, lat)

#converts df into a spatvector
xt <- vect(t, geom=c("lon", "lat"), crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

#create a 30 km (30,000 meter) buffer (radius)
pts_buffer<-buffer(x, width = 30000)

#primary roads in the US
r <- vect("G:/Shared drives/2024 FIRE Light Rail/DATA/tl_2016_us_primaryroads/tl_2016_us_primaryroads.shp")

#change projection system to match roads
pts_proj<-project(pts_buffer, crs(r))

pts_t<-project(xt, crs(r))

bg <- get_tiles(ext(pts_buffer), provider = "Esri.WorldGrayCanvas")

png(filename="Presentation/images/charlotte_cntrl_roads.png", 
    res=500, width=9, height=6, units="in")

plot(bg, main="Untreated Areas for Charlotte, NC")
plot(pts_proj, col="#ffd200", alpha=0.5, add=TRUE)
plot(pts_t, col="#e21833", cex=2, add=TRUE)
lines(r, col="#7f7f7f", lwd=2)
legend("topright", 
       legend = c("Charlotte \nNC", "Untreated \nCities", "Interstate \nBuffers"),  
       col = c("#e21833", "#ffd200", "#7f7f7f"),
       pch = c(16, 16, 3),
       lwd = 2,
       bty = "n",
       y.intersp=1.5)

dev.off()

#crop roads outside buffer areas
r_inside<-terra::intersect(r, pts_proj)

#create 1 km buffer around road segments
r_buff<-buffer(r_inside, width = 1000)

r_buff_agg<-aggregate(r_buff, by="Address")

r_buff_df<-as.data.frame(r_buff_agg)

write.csv(r_buff_df, "cntrl_road_cities.csv")

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
            paste0("PM25_daily/cntrl_highways",
                   months[m],
                   ".csv")
            , row.names = F)
}


