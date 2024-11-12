library("tidyverse")

###Phoenix-Mesa#######################################

f<-dir("Phoenix_TA_PM25/")

p_indv<-c()
for (i in 1:length(f)) {
  print(f[i])
  pdf<-read.csv(paste0("Phoenix_TA_PM25/",f[i])) |>
    mutate(year=substr(date, 1, 4)) |>
    mutate(month=substr(date, 5, 6)) |>
    mutate(day=substr(date, 7,8))
  
  p_indv<-rbind(p_indv, pdf)
}
p_nc<-p_indv

p_az2<-p_nc |>
  mutate(Address="Phoenix=Mesa, AZ")
###Houston#######################################

f<-dir("Houston_TA_PM25/")

p_indv<-c()
for (i in 1:length(f)) {
  print(f[i])
  pdf<-read.csv(paste0("Houston_TA_PM25/",f[i])) |>
    mutate(year=substr(date, 1, 4)) |>
    mutate(month=substr(date, 5, 6)) |>
    mutate(day=substr(date, 7,8))
  
  p_indv<-rbind(p_indv, pdf)
}
p_nc<-p_indv

p_tx2<-p_nc |>
  mutate(Address="Houston, TX")

##############################################

f<-dir("Charlotte_TA_PM25/")

p_indv<-c()
for (i in 1:length(f)) {
  print(f[i])
  pdf<-read.csv(paste0("Charlotte_TA_PM25/",f[i])) |>
    mutate(year=substr(date, 1, 4)) |>
    mutate(month=substr(date, 5, 6)) |>
    mutate(day=substr(date, 7,8))
  
  p_indv<-rbind(p_indv, pdf)
}
p_nc<-p_indv

p_nc2<-p_nc |>
  mutate(Address="Charlotte, NC")

###mn######################################

f<-dir("Twin_Cities_TA_PM25/")

p_indv<-c()
for (i in 1:length(f)) {
  print(f[i])
  pdf<-read.csv(paste0("Twin_Cities_TA_PM25/",f[i])) |>
    mutate(year=substr(date, 1, 4)) |>
    mutate(month=substr(date, 5, 6)) |>
    mutate(day=substr(date, 7,8))
  
  p_indv<-rbind(p_indv, pdf)
}
p_mn<-p_indv

p_mn2<-p_mn |>
  mutate(Address="Minneapolis-St. Paul, MN")

p_trt<-bind_rows(p_mn2, p_nc2, p_tx2, p_az2) |>
  select(-city_num)

write.csv(p_trt, "daily roads/pm25_daily_roads.csv", row.names=F)

####PM2.5 around control highways##############################################
cgroup<-read.csv("cntrl_road_cities.csv") |>
  rename(city_num=X) |>
  select(city_num, Address)

f<-dir("PM25_daily", pattern="cntrl_highways")

p_indv<-c()
for (i in 1:length(f)) {
  print(f[i])
  pdf<-read.csv(paste0("PM25_daily/",f[i])) |>
    mutate(year=substr(date, 1, 4)) |>
    mutate(month=substr(date, 5, 6)) |>
    mutate(day=substr(date, 7,8))
  
  p_indv<-rbind(p_indv, pdf)
}

p_cntrl<-p_indv

p_cntrl2<-merge(p_cntrl, cgroup, by="city_num")

#get new mexico cities
f<-dir("PM25_daily", pattern="nm")

p_indv<-c()
for (i in 1:length(f)) {
  print(f[i])
  pdf<-read.csv(paste0("PM25_daily/",f[i])) |>
    mutate(year=substr(date, 1, 4)) |>
    mutate(month=substr(date, 5, 6)) |>
    mutate(day=substr(date, 7,8))
  
  p_indv<-rbind(p_indv, pdf)
}

p_indv2<-p_indv |>
  mutate(Address=ifelse(city_num==1, "Las Cruces, NM", "Santa Fe, NM"))

p_cntrl3<-rbind(p_cntrl2, p_indv2)  

write.csv(p_cntrl3, "daily roads/pm25_daily_roads_cntrl.csv", row.names=F)

######met#########################################################

# f<-dir("G:/Shared drives/2024 FIRE Light Rail/DATA/cntrl_met_data")
# 
# p_indv<-c()
# for (i in 1:length(f)) {
#   print(f[i])
#   pdf<-read.csv(paste0("G:/Shared drives/2024 FIRE Light Rail/DATA/cntrl_met_data/",f[i])) |>
#     mutate(year=substr(date, 1, 4)) |>
#     mutate(month=substr(date, 5, 6)) |>
#     mutate(day=substr(date, 7,8))
#   
#   p_indv<-rbind(p_indv, pdf)
# }
# p_met<-p_indv |>
#   rename(city_num=ID)
# 
# p_met2<-merge(p_met, cgroup, by="city_num")
# 
# write.csv(p_met2, "daily roads/met_daily_cntrls.csv", row.names=F)

p_met2<-read.csv("daily roads/met_daily_cntrls.csv")

#add nm cities

f<-dir("G:/Shared drives/2024 FIRE Light Rail/DATA/cntrl_met_data", pattern="nm")

p_indv<-c()
for (i in 1:length(f)) {
  print(f[i])
  pdf<-read.csv(paste0("G:/Shared drives/2024 FIRE Light Rail/DATA/cntrl_met_data/",f[i])) |>
    mutate(year=substr(date, 1, 4)) |>
    mutate(month=substr(date, 5, 6)) |>
    mutate(day=substr(date, 7,8))
  
  p_indv<-rbind(p_indv, pdf)
}
p_met<-p_indv |>
  rename(city_num=ID) |>
  mutate(Address=ifelse(city_num==1, "Las Cruces, NM", "Santa Fe, NM"))

p_met3<-rbind(p_met2, p_met)

write.csv(p_met3, "daily roads/met_daily_cntrls_withnm.csv", row.names=F)
######met#########################################################

f<-dir("G:/Shared drives/2024 FIRE Light Rail/DATA/trt_met_data_updated")

p_indv<-c()
for (i in 1:length(f)) {
  print(f[i])
  pdf<-read.csv(paste0("G:/Shared drives/2024 FIRE Light Rail/DATA/trt_met_data_updated/",f[i])) |>
    mutate(year=substr(date, 1, 4)) |>
    mutate(month=substr(date, 5, 6)) |>
    mutate(day=substr(date, 7,8))

  p_indv<-rbind(p_indv, pdf)
}
p_met<-p_indv |>
  rename(city_num=ID) |>
  mutate(Address=ifelse(city_num==1, "Charlotte, NC", NA)) |>
  mutate(Address=ifelse(city_num==2, "Minneapolis-St. Paul, MN", Address)) |>
  mutate(Address=ifelse(city_num==3, "Houston, TX", Address)) |>
  mutate(Address=ifelse(city_num==4, "Phoenix-Mesa, AZ", Address))

write.csv(p_met, "daily roads/met_daily_trt.csv", row.names=F)

##########combine everything#####################################################
library("tidyverse")

trt_pm<-read.csv("daily roads/pm25_daily_roads.csv") |>
  mutate(date=as.Date(substr(date, 1,8), "%Y%m%d"))

cntrl_pm<-read.csv("daily roads/pm25_daily_roads_cntrl.csv") |>
  select(-city_num, -year, -month, -day) |>
  mutate(date=as.Date(substr(date, 1,8), "%Y%m%d")) 

trt_met<-read.csv("daily roads/met_daily_trt.csv") |>
  mutate(date=as.Date(substr(date, 1,8), "%Y%m%d")) |>
  select(-c(year, month, day))

cntrl_met<-read.csv("daily roads/met_daily_cntrls_withnm.csv") |>
  mutate(date=as.Date(substr(date, 1,8), "%Y%m%d"))

trt<-merge(trt_met, trt_pm, by=c("Address", "date"))

cntrl<-merge(cntrl_pm, cntrl_met, by=c("Address", "date")) |>
  filter(!is.na(TWS_tavg))

df<-bind_rows(trt,cntrl) 
write.csv(df, "daily roads/panel_updated.csv", row.names=FALSE)
  
