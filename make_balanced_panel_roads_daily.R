library("tidyverse")


####pm2.5 houston and phoenix#######################################

f<-dir("G:/Shared drives/2024 FIRE Light Rail/DATA/Houston & Phoenix")

p_indv<-c()
for (i in 1:length(f)) {
  print(f[i])
  pdf<-read.csv(paste0("G:/Shared drives/2024 FIRE Light Rail/DATA/Houston & Phoenix/",f[i])) |>
    mutate(year=substr(date, 1, 4)) |>
    mutate(month=substr(date, 5, 6)) |>
    mutate(day=substr(date, 7,8))
  
  p_indv<-rbind(p_indv, pdf)
}

p_tx_az<-p_indv

p_tx_az2<-p_tx_az |>
  mutate(Address=ifelse(city_num==1, "Phoenix-Mesa, AZ", "Houston, TX")) |>
  select(-city_num)

###charlotte#######################################

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

p_trt<-rbind(p_mn2, p_nc2, p_tx_az2)

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

write.csv(p_cntrl2, "daily roads/pm25_daily_roads_cntrl.csv", row.names=F)

######met#########################################################

f<-dir("G:/Shared drives/2024 FIRE Light Rail/DATA/cntrl_met_data")

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
  rename(city_num=ID)

p_met2<-merge(p_met, cgroup, by="city_num")

write.csv(p_met2, "daily roads/met_daily_cntrls.csv", row.names=F)

