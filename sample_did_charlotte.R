##########combine everything#####################################################
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
  mutate(start=as.Date("01/12/2003", format="%d/%m/%Y")) |> #start date of dataset
  mutate(open=as.Date("01/11/2007", format="%d/%m/%Y")) |>
  mutate(end=as.Date("01/11/2011", format="%d/%m/%Y")) |> #end date of dataset
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
#####################################################

#make plots comparing treated city with cntrl city
df2<-df |>
  filter(Address=="Winston-Salem, NC" | Address=="Greenville, SC" | Address=="Columbia, SC" |
           Address=="Charlotte, NC") |>
  mutate(trtcity=ifelse(Address=="Charlotte, NC", 1, 0))

ggplot(df2, aes(x=time, y=pm25, color=Address))+geom_line()


#run difference-in-differences
library("lfe")

summary(m1<-felm(pm25 ~ opentime:trtcity + opentime + trtcity + TWS_tavg + GWS_tavg 
                 | dow + month + year, data=df2))

summary(m1<-felm(log(pm25) ~ opentime:trtcity + opentime + trtcity + TWS_tavg + GWS_tavg 
                 | dow + month + year, data=df2))


###met files for other cities###################################################

met2<-read.csv("daily roads/met_houston.csv") |>
  mutate(date=as.Date(substr(date, 1,8), "%Y%m%d")) |>
  mutate(Address="Houston, TX")

met3<-read.csv("daily roads/met_phoenix_mesa.csv") |>
  mutate(date=as.Date(substr(date, 1,8), "%Y%m%d")) |>
  mutate(Address="Phoenix-Mesa, AZ")

met4<-read.csv("daily roads/met_twin_cities.csv") |>
  mutate(date=as.Date(substr(date, 1,8), "%Y%m%d")) |>
  mutate(Address="Minneapolis-St. Paul, MN") |>
  select(-X)
