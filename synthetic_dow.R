library("tidyverse")

###clean data for charlotte###################################################3
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
  mutate(date=as.Date(date)) |>
  mutate(start=as.Date("01/12/2003", format="%d/%m/%Y")) |>
  mutate(open=as.Date("01/11/2007", format="%d/%m/%Y")) |>
  mutate(opentime=ifelse(date>open,1,0)) |>
  mutate(treatcity=ifelse(Address=="Charlotte, NC",1,0)) |>
  mutate(time=interval(start, date)/days(1)) |>
  mutate(add_num=factor(Address)) |>
  mutate(add_num=as.numeric(add_num)) |>
  #remove construction years
  filter(year!=2005 & year!=2007 & year!=2006 & year<2013) |> 
  mutate(dow=weekdays(date)) |>
  mutate(dow_month=paste0(dow, "-", as.character(month))) |>
  mutate(dow_my=paste0(dow, "-", as.character(month), "-", as.character(year)))

df2<-df |>
  filter(Address=="Winston-Salem, NC" | Address=="Greenville, SC" | 
           Address=="Columbia, SC" | Address=="Concord, NC" |
           Address=="Charlotte, NC") |>
  mutate(trtcity=ifelse(Address=="Charlotte, NC", 1, 0))

####clean data for each day of the week###############################

df3<-df |>
  filter(Address=="Winston-Salem, NC" | Address=="Greenville, SC" | 
           Address=="Columbia, SC" | Address=="Concord, NC" |
           Address=="Charlotte, NC") |>
  #create number representing each city
  mutate(add_num=factor(Address)) |>
  mutate(add_num=as.numeric(add_num)) |>
  mutate(trtcity=ifelse(Address=="Charlotte, NC", 1, 0)) |>
  filter(year!=2005 & year!=2007 & year!=2006 & year<2013) |> 
  mutate(date=as.Date(date)) |>
  mutate(dow=weekdays(date)) |>
  filter(dow=="Thursday") |>
  ungroup() |>
  group_by(month, Address, add_num, trtcity, year) |>
  reframe(pm25=mean(pm25), Rainf_tavg=mean(Rainf_tavg)) |>
  #create time index
  mutate(date=as.Date(paste0(as.character(year), "-", as.character(month), "-01"))) |>
  mutate(time=interval(as.Date("2000-01-01"), date)/months(1)) 

  #open time is 96

library("Synth")
library("gsynth")

dataprep.out <-
  dataprep(
    df3,
    predictors            = c("year"), #add linear, square, cubic weather
    dependent             = "pm25",
    unit.variable         = "add_num",
    time.variable         = "time",
    unit.names.variable   = "add",
    treatment.identifier  = 1 , #value in add_num column
    controls.identifier   = c(2:5), #value of other control cities
    time.predictors.prior = c(1:95),
    time.optimize.ssr     = c(1:95),
    time.plot             = c(1:155)
  )

is.data.frame(df3)
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

abline(v   = 48,
       lty = 2)