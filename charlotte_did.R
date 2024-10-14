library("lfe")
library("tidyverse")

trt_pm<-read.csv("daily roads/pm25_daily_roads.csv") |>
  mutate(date=as.Date(substr(date, 1,8), "%Y%m%d"))

cntrl_pm<-read.csv("daily roads/pm25_daily_roads_cntrl.csv") |>
  select(-city_num, -year, -month, -day) |>
  mutate(date=as.Date(substr(date, 1,8), "%Y%m%d")) 

trt_met<-read.csv("daily roads/met_charlotte.csv") |>
  select(-X, -date) |>
  rename(date=formatted_date) |>
  mutate(Address="Charlotte, NC") |>
  mutate(date=as.Date(date))

cntrl_met<-read.csv("daily roads/met_daily_cntrls.csv") |>
  mutate(date=as.Date(substr(date, 1,8), "%Y%m%d"))

trt<-merge(trt_met, trt_pm, by=c("Address", "date"))

cntrl<-merge(cntrl_pm, cntrl_met, by=c("Address", "date")) |>
  filter(!is.na(TWS_tavg))

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

df_month<-df |>
  group_by(month, year, Address) |>
  summarise(pm25=mean(pm25))
