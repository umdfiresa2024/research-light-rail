library("tidyverse")

p<-read.csv("pm25_allcities.csv")
m<-read.csv("merra_allcities.csv")

df<-merge(p, m, by=c("date", "add", "month", "year"))

cgroup<-c("Phoenix-Mesa, AZ", "Flagstaff, AZ", "Sierra Vista, AZ", "Tucson, AZ")

df2<-df |>
  filter(add %in% cgroup) |>
  mutate(start=as.Date("01/12/2004", format="%d/%m/%Y")) |>
  mutate(open=as.Date("01/12/2008", format="%d/%m/%Y")) |>
  mutate(opentime=ifelse(as.Date(date)>open,1,0)) |>
  mutate(treatcity=ifelse(add=="Phoenix-Mesa, AZ",1,0)) |>
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
  mutate(start=as.Date("01/12/2004", format="%d/%m/%Y")) |>
  mutate(open=as.Date("01/12/2008", format="%d/%m/%Y")) |>
  mutate(treat=ifelse(add=="Phoenix-Mesa, AZ" & date>=open, 1, 0)) |>
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
    controls.identifier   = c(2:4),
    time.predictors.prior = c(-59:48),
    time.optimize.ssr     = c(-59:12),
    time.plot             = c(-59:96)
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
          Ylim         = c(-10, 10),
          Main         = ""
)

abline(v   = 48,
       lty = 2)

