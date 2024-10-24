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

######met#########################################################

f<-dir("G:/Shared drives/2024 FIRE Light Rail/DATA/trt_met_data")

p_indv<-c()
for (i in 1:length(f)) {
  print(f[i])
  pdf<-read.csv(paste0("G:/Shared drives/2024 FIRE Light Rail/DATA/trt_met_data/",f[i])) |>
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

cntrl_met<-read.csv("daily roads/met_daily_cntrls.csv") |>
  mutate(date=as.Date(substr(date, 1,8), "%Y%m%d"))

trt<-merge(trt_met, trt_pm, by=c("Address", "date"))

cntrl<-merge(cntrl_pm, cntrl_met, by=c("Address", "date")) |>
  filter(!is.na(TWS_tavg))

df<-bind_rows(trt,cntrl) 
write.csv(df, "daily roads/panel.csv", row.names=FALSE)
  
###################################################################################
rm(trt_met, trt_pm, cntrl_pm, cntrl_met)


df<-bind_rows(trt,cntrl) |>
  select(-city_num) |>
  mutate(start=as.Date("01/12/2003", format="%d/%m/%Y")) |>
  mutate(open=as.Date("01/11/2007", format="%d/%m/%Y")) |>
  mutate(end=as.Date("01/11/2011", format="%d/%m/%Y")) |>
  mutate(opentime=ifelse(as.Date(date)>open,1,0)) |>
  mutate(treatcity=ifelse(Address=="Charlotte, NC",1,0)) |>
  mutate(time=interval(start, date)/days(1)) |>
  filter(Address!="Concord, NC") |>
  mutate(add_num=factor(Address)) |>
  mutate(add_num=as.numeric(add_num)) |>
  filter(date>=start & date<=end) |>
  mutate(dow=weekdays(date))

library("Synth")
library("gsynth")
  

dataprep.out <-
  dataprep(
    df,
    predictors            = names(df[c(3:35)]),
    dependent             = "pm25",
    unit.variable         = "add_num", #city number
    time.variable         = "time", 
    unit.names.variable   = "Address",
    treatment.identifier  = 7, #treatment city number
    controls.identifier   = c(1:6, 8:25),
    time.predictors.prior = c(0:1431),
    time.optimize.ssr     = c(0:1300), 
    time.plot             = c(1000:2500)
  )

synth.out <- synth(dataprep.out)

print(synth.tables   <- synth.tab(
  dataprep.res = dataprep.out,
  synth.res    = synth.out)
)

path.plot(synth.res    = synth.out,
          dataprep.res = dataprep.out,
          Ylab         = c("Y"),
          Xlab         = c("Months"),
          Legend       = c("Treated City","Synthetic City"),
          Legend.position = c("topleft")
)

abline(v   = 1432,
       lty = 2)

gaps.plot(synth.res    = synth.out,
          dataprep.res = dataprep.out,
          Ylab         = c("Gap"),
          Xlab         = c("Year"),
          Ylim         = c(-10, 10),
          Main         = ""
)

abline(v   = 1432,
       lty = 2)
  
synth_control = dataprep.out$Y0plot %*% synth.out$solution.w
