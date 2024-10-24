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
  mutate(open=as.Date("01/11/2007", format="%d/%m/%Y")) |>
  mutate(construction=as.Date("01/03/2005", format="%d/%m/%Y")) |>
  mutate(expansion=as.Date("01/12/2012", format="%d/%m/%Y")) |>
  
  #convert address to numeric
  filter(Address=="Winston-Salem, NC" | Address=="Greenville, SC" | 
           Address=="Columbia, SC" | Address=="Concord, NC" |
           Address=="Charlotte, NC") |>
  mutate(add_num=factor(Address)) |>
  mutate(add_num=as.numeric(add_num)) |>
  
  #remove construction years
  filter(date<construction | date>open) |>
  filter(date<expansion) |>
  
  #get day of the week
  mutate(dow=weekdays(date)) |>
  filter(dow=="Thursday") |>
  ungroup() |>
  
  #find average data for Thursdays in all months
  group_by(month, year, Address, add_num) |>
  reframe(pm25=mean(pm25), Rainf_tavg=mean(Rainf_tavg), Evap_tavg=mean(Evap_tavg)) |>
  #create time index
  mutate(date=as.Date(paste0(as.character(year), "-", as.character(month), "-01"))) |>
  mutate(time=interval(as.Date("2000-01-01"), date)/months(1)) |>
  arrange(add_num, time) |>
  filter(time>=46 & time<=142) |>
  mutate(time=ifelse(time>=94, time-32, time))

  #open time is 94

class(df)
df2<-as.data.frame(df)
class(df2)

table(df2$time)

#library("Synth")
#library("gsynth")

dataprep.out <-
  dataprep(
    df2,
    predictors            = c("Rainf_tavg", "Evap_tavg"), #add linear, square, cubic weather
    dependent             = "pm25",
    unit.variable         = "add_num",
    time.variable         = "time",
    unit.names.variable   = "Address",
    treatment.identifier  = 1 , #value in add_num column
    controls.identifier   = c(2:5), #value of other control cities
    time.predictors.prior = c(46:94),
    time.optimize.ssr     = c(46:95),
    time.plot             = c(46:110)
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

abline(v   = 62,
       lty = 2)

gaps.plot(synth.res    = synth.out,
          dataprep.res = dataprep.out,
          Ylab         = c("Gap"),
          Xlab         = c("Year"),
          Ylim         = c(-5, 5),
          Main         = ""
)

abline(v   = 62,
       lty = 2)
