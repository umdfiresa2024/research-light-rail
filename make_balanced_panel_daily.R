library("tidyverse")

idv_cities<-read.csv("nonoverlap_cities.csv") |>
  mutate(add=ifelse(is.na(joint_address), Address, joint_address)) |>
  select(X, add) |>
  rename(city_num=X)

f<-dir("PM25_daily", pattern="indv")

p_indv<-c()
for (i in 1:length(f)) {
  print(f[i])
  pdf<-read.csv(paste0("PM25_daily/",f[i])) |>
    mutate(year=substr(date, 1, 4)) |>
    mutate(month=substr(date, 5, 6)) |>
    mutate(day=substr(date, 7,8))

  p_indv<-rbind(p_indv, pdf)
}

#find the average between phoenix-mesa
pi<-merge(p_indv, idv_cities, by="city_num") |>
  group_by(year, month, day, add) |>
  summarize(pm25_city=mean(pm25))

#select treated cities to merge with highway data
pi_trt<-pi |>
  filter(add=="Phoenix-Mesa, AZ" |
           add=="Charlotte, NC" |
           add=="Minneapolis-St. Paul, MN" |
           add=="Houston, TX") |>
  mutate(month=as.numeric(month), year=as.numeric(year), day=as.numeric(day)) 

ph<-read.csv("pm25_highway_daily.csv") 

ph2<-ph |>
  mutate(add=ifelse(address=="twin cities, mn, usa", "Minneapolis-St. Paul, MN", NA)) |>
  mutate(add=ifelse(address=="houston, tx, usa", "Houston, TX", add)) |>
  mutate(add=ifelse(address=="phoenix, az, usa", "Phoenix-Mesa, AZ", add)) |>
  mutate(add=ifelse(address=="charlotte, nc, usa", "Charlotte, NC", add)) |>
  filter(!is.na(add)) |>
  select(pm25, year, month, day, add) |>
  rename(pm25_highway=pm25)

p<-merge(ph2, pi_trt, by=c("add", "day", "month", "year"))

write.csv(p, "pm25_daily.csv", row.names=F)
