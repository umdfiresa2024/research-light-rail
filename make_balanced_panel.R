#combine data together
library("tidyverse")

#make balanced panel
cities<-read.csv("allcities_latlon.csv") |>
  mutate(add=ifelse(is.na(joint_address), Address, joint_address))

c<-unique(cities$add)

#merra
m1<-read.csv("merra_output_10km.csv") |>
  filter(!is.na(TLML)) |>
  mutate(add=ifelse(is.na(joint_address), Address, joint_address)) |>
  group_by(add, file) |>
  summarise(PRECTOT=mean(PRECTOT), PRECSNO=mean(PRECSNO), QSH=mean(QSH),
            RHOA=mean(RHOA), SPEED=mean(SPEED), TLML=mean(TLML))

m2<-read.csv("merra_output_40km.csv") |>
  mutate(add=ifelse(is.na(joint_address), Address, joint_address)) |>
  select(-city_num, -Address, -lon, -lat, -address, -joint_address)

m3<-read.csv("merra_output_overlap.csv") |>
  select(-city_num) |>
  rename(add=joint_address)

merra<-rbind(m1, m2, m3) |>
  mutate(year=substr(file, 1, 4)) |>
  mutate(month=substr(file, 5, 6)) |>
  mutate(date=as.Date(paste0("01/", month, "/", year), format="%d/%m/%Y"))

table(merra$add)

#pm2.5
f<-dir("PM25_daily", pattern="indv")
