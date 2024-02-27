library("tidyverse")

p<-read.csv("pm25_allcities.csv")
m<-read.csv("merra_allcities.csv")

df<-merge(p, m, by=c("date", "add", "month", "year"))

cgroup<-c("Minneapolis-St. Paul, MN", "Beloit, WI-IL", "Duluth, MN-WI", "Janesville, WI",
          "Rochester, MN", "Wausau, WI")

df2<-df |>
  filter(add %in% cgroup) |>
  mutate(start=as.Date("01/06/2000", format="%d/%m/%Y")) |>
  mutate(open=as.Date("01/06/2004", format="%d/%m/%Y")) |>
  mutate(opentime=ifelse(as.Date(date)>open,1,0)) |>
  mutate(treatcity=ifelse(add=="Minneapolis-St. Paul, MN",1,0)) |>
  mutate(time=interval(start, as.Date(date))/months(1)) |>
  mutate(add_num=factor(add, levels=cgroup)) |>
  mutate(add_num=as.numeric(add_num)) |>
  filter(time<=96)

#alltime periods
summary(m1<-lm(pm25 ~ opentime:treatcity + opentime + treatcity +
                 PRECTOT + PRECSNO + QSH + RHOA + SPEED + TLML + 
                 as.factor(month) + year, data=df2))

#take out construction time
df3<-df2 |>
  filter(!(time>12 & time<48))

summary(m2<-lm(pm25 ~ opentime:treatcity + opentime + treatcity +
                 PRECTOT + PRECSNO + QSH + RHOA + SPEED + TLML + 
                 as.factor(month) + year, data=df3))

df2<-df |>
  filter(add %in% cgroup) |>
  mutate(start=as.Date("01/06/2000", format="%d/%m/%Y")) |>
  mutate(open=as.Date("01/06/2004", format="%d/%m/%Y")) |>
  mutate(treat=ifelse(add=="Minneapolis-St. Paul, MN" & date>=open, 1, 0)) |>
  mutate(time=interval(start, as.Date(date))/months(1)) |>
  mutate(add_num=factor(add, levels=cgroup)) |>
  mutate(add_num=as.numeric(add_num)) |>
  filter(time<=96)

library("Synth")
library("gsynth")

dataprep.out <-
  dataprep(
    df2,
    predictors            = c("PRECTOT", "PRECSNO", "QSH", "RHOA", "SPEED", "TLML"),
    dependent             = "pm25",
    unit.variable         = "add_num",
    time.variable         = "time",
    unit.names.variable   = "add",
    treatment.identifier  = 1,
    controls.identifier   = c(2:6),
    time.predictors.prior = c(-5:48),
    time.optimize.ssr     = c(-5:12),
    time.plot             = c(-5:96)
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

abline(v   = 48,
       lty = 2)

gaps.plot(synth.res    = synth.out,
          dataprep.res = dataprep.out,
          Ylab         = c("Gap"),
          Xlab         = c("Year"),
          Ylim         = c(-5, 5),
          Main         = ""
)

abline(v   = 48,
       lty = 2)

