#combine data together
library("tidyverse")

#make balanced panel
cities<-read.csv("allcities_latlon.csv") |>
  mutate(add=ifelse(is.na(joint_address), Address, joint_address))

c<-unique(cities$add)

##########################merra#################################################
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

cm<-table(merra$add)
table(merra$year)

write.csv(merra, "merra_allcities.csv", row.names = F)
##############################pm2.5#############################################
#remove month 5 year 2014 from month 6 year 2015 pm2.5 data
f<-dir("PM25_daily", pattern="indv")
i<-174
pdf<-read.csv(paste0("PM25_daily/",f[i])) |>
  filter(date!="20140501.tif")
write.csv(pdf, paste0("PM25_daily/",f[i]), row.names = F)

f<-dir("PM25_daily", pattern="overlap")
i<-174
pdf<-read.csv(paste0("PM25_daily/",f[i])) |>
  filter(date!="20140501.tif")
write.csv(pdf, paste0("PM25_daily/",f[i]), row.names = F)

################################################################################
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
    mutate(month=substr(date, 5, 6)) 

  pdf2<-merge(pdf, idv_cities, by="city_num") |>
    group_by(add, month, year) |>
    summarise(pm25=mean(pm25))
  
  p_indv<-rbind(p_indv, pdf2)
}

cp<-table(p_indv$add)
table(p_indv$year)
table(p_indv$month)

f<-dir("PM25_daily", pattern="overlap")

p_overlap<-c()
for (i in 1:length(f)) {
  print(i)
  pdf<-read.csv(paste0("PM25_daily/",f[i])) |>
    mutate(year=substr(date, 1, 4)) |>
    mutate(month=substr(date, 5, 6)) 
  
  pdf2<-pdf |>
    group_by(city_num, month, year) |>
    summarise(pm25=mean(pm25))
  
  p_overlap<-rbind(p_overlap, pdf2)
}

p_o2<-p_overlap |>
  ungroup() |>
  mutate(add=ifelse(city_num==1, "Myrtle Beach-Socastee, SC-NC", NA)) |>
  mutate(add=ifelse(city_num==2, "College Station-Bryan, TX", add)) |>
  mutate(add=ifelse(city_num==3, "Charleston-North Charleston, SC", add)) |>
  select(-city_num)

p<-rbind(p_o2, p_indv) |>
  mutate(date=as.Date(paste0("01/", month, "/", year), format="%d/%m/%Y")) 

write.csv(p, "pm25_allcities.csv", row.names = F)

#############pm2.5 around light rails for treated cities#########################
p<-read.csv("pm25_allcities.csv")
f<-dir("PM25_daily", pattern="lr_centroid")

p_indv<-c()
for (i in 1:length(f)) {
  print(f[i])
  pdf<-read.csv(paste0("PM25_daily/",f[i])) |>
    mutate(year=substr(date, 1, 4)) |>
    mutate(month=substr(date, 5, 6)) |>
    group_by(city_num, month, year) |>
    summarise(pm25=mean(pm25))
  
  p_indv<-rbind(p_indv, pdf)
}

p_i<-p_indv |>
  ungroup() |>
  mutate(add=ifelse(city_num==1, "Charlotte, NC", NA)) |>
  mutate(add=ifelse(city_num==2, "Houston, TX", add)) |>
  mutate(add=ifelse(city_num==3, "Minneapolis-St. Paul, MN", add)) |>
  mutate(add=ifelse(city_num==4, "Phoenix-Mesa, AZ", add)) |>
  select(-city_num)

treatc<-c("Charlotte, NC", "Houston, TX", "Minneapolis-St. Paul, MN", "Phoenix-Mesa, AZ")

pall<-p |>
  filter(!(add %in% treatc)) |>
  select(-date)

p2<-rbind(p_i, pall) |>
  mutate(date=as.Date(paste0("01/", month, "/", year), format="%d/%m/%Y")) 

write.csv(p2, "pm25_allcities_lrbuff.csv", row.names = F)

#############merge data #########################################################

p<-read.csv("pm25_allcities.csv")
m<-read.csv("merra_allcities.csv")

df<-merge(p, m, by=c("date", "add", "month", "year"))

table(df$add)

#charlotte group#################################################################

cgroup<-c("Asheville, NC", "Charleston-North Charleston, SC", "Charlotte, NC",
     "Columbia, SC", "Concord, NC", "Durham, NC", "Fayetteville, NC", "Greenville, SC", 
     "Myrtle Beach-Socastee, SC-NC", "Wilmington, NC", "Winston-Salem, NC")

df2<-df |>
  filter(add %in% cgroup) |>
  mutate(start=as.Date("01/11/2003", format="%d/%m/%Y")) |>
  mutate(open=as.Date("01/11/2007", format="%d/%m/%Y")) |>
  mutate(treat=ifelse(add=="Charlotte, NC" & date>=open, 1, 0)) |>
  mutate(time=interval(start, as.Date(date))/months(1)) |>
  mutate(add_num=factor(add, levels=c("Charlotte, NC", "Asheville, NC", 
                                          "Charleston-North Charleston, SC", 
                                          "Columbia, SC", "Concord, NC", 
                                          "Durham, NC", "Fayetteville, NC", 
                                          "Greenville, SC", 
                                          "Myrtle Beach-Socastee, SC-NC", 
                                          "Wilmington, NC", "Winston-Salem, NC"))) |>
  mutate(add_num=as.numeric(add_num)) |>
  filter(time>=0 & time<=96)

#library("Synth")
#library("gsynth")

dataprep.out <-
  dataprep(
    df2,
    predictors            = c("PRECTOT", "PRECSNO", "QSH", "RHOA", "SPEED", "TLML"),
    dependent             = "pm25",
    unit.variable         = "add_num",
    time.variable         = "time",
    unit.names.variable   = "add",
    treatment.identifier  = 1,
    controls.identifier   = c(2:11),
    time.predictors.prior = c(0:48),
    time.optimize.ssr     = c(0:48),
    time.plot             = c(1:96)
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

dataprep.out <-
  dataprep(
    df2,
    predictors            = c("PRECTOT", "PRECSNO", "QSH", "RHOA", "SPEED", "TLML"),
    dependent             = "pm25",
    unit.variable         = "add_num",
    time.variable         = "time",
    unit.names.variable   = "add",
    treatment.identifier  = 1,
    controls.identifier   = c(2:11),
    time.predictors.prior = c(0:48),
    time.optimize.ssr     = c(0:36),
    time.plot             = c(1:96)
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

#houston group#################################################################

cgroup<-c("Houston, TX", "Austin, TX", "Beaumont, TX", "Brownsville, TX",
          "College Station-Bryan, TX", "Corpus Christi, TX", "Denton-Lewisville, TX", 
          "El Paso, TX-NM", "Laredo, TX", "Waco, TX",
          "Lubbock, TX", "Odessa, TX", "San Antonio, TX")

df2<-df |>
  filter(add %in% cgroup) |>  
  mutate(start=as.Date("01/01/2000", format="%d/%m/%Y")) |>
  mutate(open=as.Date("01/01/2004", format="%d/%m/%Y")) |>
  mutate(treat=ifelse(add=="Houston, TX" & date>=open, 1, 0)) |>
  mutate(time=interval(start, as.Date(date))/months(1)) |>
  mutate(add_num=factor(add, levels=cgroup)) |>
  mutate(add_num=as.numeric(add_num)) |>
  filter(time>=0 & time<=96)

table(df2$time)

dataprep.out <-
  dataprep(
    df2,
    predictors            = c("PRECTOT", "PRECSNO", "QSH", "RHOA", "SPEED", "TLML"),
    dependent             = "pm25",
    unit.variable         = "add_num",
    time.variable         = "time",
    unit.names.variable   = "add",
    treatment.identifier  = 1,
    controls.identifier   = c(2:13),
    time.predictors.prior = c(0:48),
    time.optimize.ssr     = c(0:48),
    time.plot             = c(1:96)
  )


synth.out <- synth(dataprep.out)

print(synth.tables   <- synth.tab(
  dataprep.res = dataprep.out,
  synth.res    = synth.out)
)

path.plot(synth.res    = synth.out,
          dataprep.res = dataprep.out,
          Ylab         = c("Y"),
          Xlab         = c("Year"),
          Legend       = c("State A","Synthetic State A"),
          Legend.position = c("topleft")
)

abline(v   = 48,
       lty = 2)

gaps.plot(synth.res    = synth.out,
          dataprep.res = dataprep.out,
          Ylab         = c("Gap"),
          Xlab         = c("Year"),
          Ylim         = c(-30, 30),
          Main         = ""
)

abline(v   = 48,
       lty = 2)

dataprep.out <-
  dataprep(
    df2,
    predictors            = c("PRECTOT", "PRECSNO", "QSH", "RHOA", "SPEED", "TLML"),
    dependent             = "pm25",
    unit.variable         = "add_num",
    time.variable         = "time",
    unit.names.variable   = "add",
    treatment.identifier  = 1,
    controls.identifier   = c(2:13),
    time.predictors.prior = c(0:48),
    time.optimize.ssr     = c(0:36),
    time.plot             = c(1:96)
  )


synth.out <- synth(dataprep.out)

print(synth.tables   <- synth.tab(
  dataprep.res = dataprep.out,
  synth.res    = synth.out)
)

path.plot(synth.res    = synth.out,
          dataprep.res = dataprep.out,
          Ylab         = c("Y"),
          Xlab         = c("Year"),
          Legend       = c("State A","Synthetic State A"),
          Legend.position = c("topleft")
)

abline(v   = 48,
       lty = 2)

gaps.plot(synth.res    = synth.out,
          dataprep.res = dataprep.out,
          Ylab         = c("Gap"),
          Xlab         = c("Year"),
          Ylim         = c(-30, 30),
          Main         = ""
)

abline(v   = 48,
       lty = 2)

#mn group#################################################################

cgroup<-c("Minneapolis-St. Paul, MN", "Beloit, WI-IL", "Duluth, MN-WI", "Janesville, WI",
          "Rochester, MN", "Wausau, WI")

df2<-df |>
  filter(add %in% cgroup) |>  
  mutate(start=as.Date("01/06/2000", format="%d/%m/%Y")) |>
  mutate(open=as.Date("01/06/2004", format="%d/%m/%Y")) |>
  mutate(treat=ifelse(add=="Minneapolis-St. Paul, MN" & date>=open, 1, 0)) |>
  mutate(time=interval(start, as.Date(date))/months(1)) |>
  mutate(add_num=factor(add, levels=cgroup)) |>
  mutate(add_num=as.numeric(add_num)) |>
  filter(time>=0 & time<=96)

table(df2$time)

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
    time.predictors.prior = c(0:48),
    time.optimize.ssr     = c(0:48),
    time.plot             = c(1:96)
  )


synth.out <- synth(dataprep.out)

print(synth.tables   <- synth.tab(
  dataprep.res = dataprep.out,
  synth.res    = synth.out)
)

path.plot(synth.res    = synth.out,
          dataprep.res = dataprep.out,
          Ylab         = c("Y"),
          Xlab         = c("Year"),
          Legend       = c("State A","Synthetic State A"),
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
    time.predictors.prior = c(0:48),
    time.optimize.ssr     = c(0:36),
    time.plot             = c(1:96)
  )


synth.out <- synth(dataprep.out)

print(synth.tables   <- synth.tab(
  dataprep.res = dataprep.out,
  synth.res    = synth.out)
)

path.plot(synth.res    = synth.out,
          dataprep.res = dataprep.out,
          Ylab         = c("Y"),
          Xlab         = c("Year"),
          Legend       = c("State A","Synthetic State A"),
          Legend.position = c("topleft")
)

abline(v   = 48,
       lty = 2)

gaps.plot(synth.res    = synth.out,
          dataprep.res = dataprep.out,
          Ylab         = c("Gap"),
          Xlab         = c("Year"),
          Ylim         = c(-30, 30),
          Main         = ""
)

abline(v   = 48,
       lty = 2)

#phoenix-mesa group#################################################################

cgroup<-c("Phoenix-Mesa, AZ", "Flagstaff, AZ", "Sierra Vista, AZ", "Tucson, AZ")

df2<-df |>
  filter(add %in% cgroup) |>  
  mutate(start=as.Date("01/12/2004", format="%d/%m/%Y")) |>
  mutate(open=as.Date("01/12/2008", format="%d/%m/%Y")) |>
  mutate(treat=ifelse(add=="Phoenix-Mesa, AZ" & date>=open, 1, 0)) |>
  mutate(time=interval(start, as.Date(date))/months(1)) |>
  mutate(add_num=factor(add, levels=cgroup)) |>
  mutate(add_num=as.numeric(add_num)) |>
  filter(time>=0 & time<=96)

table(df2$time)

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
    time.predictors.prior = c(0:48),
    time.optimize.ssr     = c(0:48),
    time.plot             = c(1:96)
  )


synth.out <- synth(dataprep.out)

print(synth.tables   <- synth.tab(
  dataprep.res = dataprep.out,
  synth.res    = synth.out)
)

path.plot(synth.res    = synth.out,
          dataprep.res = dataprep.out,
          Ylab         = c("Y"),
          Xlab         = c("Year"),
          Legend       = c("State A","Synthetic State A"),
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
    time.predictors.prior = c(0:48),
    time.optimize.ssr     = c(0:36),
    time.plot             = c(1:96)
  )


synth.out <- synth(dataprep.out)

print(synth.tables   <- synth.tab(
  dataprep.res = dataprep.out,
  synth.res    = synth.out)
)

path.plot(synth.res    = synth.out,
          dataprep.res = dataprep.out,
          Ylab         = c("Y"),
          Xlab         = c("Year"),
          Legend       = c("State A","Synthetic State A"),
          Legend.position = c("topleft")
)

abline(v   = 48,
       lty = 2)

gaps.plot(synth.res    = synth.out,
          dataprep.res = dataprep.out,
          Ylab         = c("Gap"),
          Xlab         = c("Year"),
          Ylim         = c(-30, 30),
          Main         = ""
)

abline(v   = 48,
       lty = 2)

##################diff-in-diff###############################################

cgroup1<-c("Asheville, NC", "Charleston-North Charleston, SC", "Charlotte, NC",
          "Columbia, SC", "Concord, NC", "Durham, NC", "Fayetteville, NC", "Greenville, SC", 
          "Myrtle Beach-Socastee, SC-NC", "Wilmington, NC", "Winston-Salem, NC")

df1<-df |>
  filter(add %in% cgroup1) |>
  mutate(start=as.Date("01/11/2003", format="%d/%m/%Y")) |>
  mutate(open=as.Date("01/11/2007", format="%d/%m/%Y")) |>
  mutate(treat=ifelse(add=="Charlotte, NC" & date>=open, 1, 0)) |>
  mutate(time=interval(start, as.Date(date))/months(1)) |>
  mutate(add_num=factor(add, levels=cgroup1)) |>
  mutate(add_num=as.numeric(add_num)) |>
  filter(time>=0 & time<=96) |>
  mutate(group1=1, group2=0, group3=0, group4=0)

cgroup2<-c("Houston, TX", "Austin, TX", "Beaumont, TX", "Brownsville, TX",
          "College Station-Bryan, TX", "Corpus Christi, TX", "Denton-Lewisville, TX", 
          "El Paso, TX-NM", "Laredo, TX", "Waco, TX",
          "Lubbock, TX", "Odessa, TX", "San Antonio, TX")

df2<-df |>
  filter(add %in% cgroup2) |>  
  mutate(start=as.Date("01/01/2000", format="%d/%m/%Y")) |>
  mutate(open=as.Date("01/01/2004", format="%d/%m/%Y")) |>
  mutate(treat=ifelse(add=="Houston, TX" & date>=open, 1, 0)) |>
  mutate(time=interval(start, as.Date(date))/months(1)) |>
  mutate(add_num=factor(add, levels=cgroup)) |>
  mutate(add_num=as.numeric(add_num)) |>
  filter(time>=0 & time<=96) |>
  mutate(group1=0, group2=1, group3=0, group4=0)

cgroup3<-c("Minneapolis-St. Paul, MN", "Beloit, WI-IL", "Duluth, MN-WI", "Janesville, WI",
          "Rochester, MN", "Wausau, WI")

df3<-df |>
  filter(add %in% cgroup3) |>  
  mutate(start=as.Date("01/06/2000", format="%d/%m/%Y")) |>
  mutate(open=as.Date("01/06/2004", format="%d/%m/%Y")) |>
  mutate(treat=ifelse(add=="Minneapolis-St. Paul, MN" & date>=open, 1, 0)) |>
  mutate(time=interval(start, as.Date(date))/months(1)) |>
  mutate(add_num=factor(add, levels=cgroup)) |>
  mutate(add_num=as.numeric(add_num)) |>
  filter(time>=0 & time<=96) |>
  mutate(group1=0, group2=0, group3=1, group4=0)

cgroup4<-c("Phoenix-Mesa, AZ", "Flagstaff, AZ", "Sierra Vista, AZ", "Tucson, AZ")

df4<-df |>
  filter(add %in% cgroup) |>  
  mutate(start=as.Date("01/12/2004", format="%d/%m/%Y")) |>
  mutate(open=as.Date("01/12/2008", format="%d/%m/%Y")) |>
  mutate(treat=ifelse(add=="Phoenix-Mesa, AZ" & date>=open, 1, 0)) |>
  mutate(time=interval(start, as.Date(date))/months(1)) |>
  mutate(add_num=factor(add, levels=cgroup)) |>
  mutate(add_num=as.numeric(add_num)) |>
  filter(time>=0 & time<=96) |>
  mutate(group1=0, group2=0, group3=0, group4=1)

dfall<-rbind(df1, df2, df3, df4)

summary(m1<-lm(log(pm25) ~ treat + group1 + group2 + group3 + 
                 PRECTOT + PRECSNO + QSH + RHOA + SPEED + TLML + 
                 as.factor(month):group1 + as.factor(month):group2 +
         as.factor(month):group3 + as.factor(month) + year, data=dfall))

summary(m2<-lm(log(pm25) ~ treat + group1 + group2 + group3 + 
                 PRECTOT + PRECSNO + QSH + RHOA + SPEED + TLML + 
                 as.factor(month):group1 + as.factor(month):group2 +
                 as.factor(month):group3 + as.factor(month) + year + as.factor(add), data=dfall))

dfnocons1<-dfall |>
  filter(time<=36)

dfnocons2<-dfall |>
  filter(time>=48)

dfnocons<-rbind(dfnocons1, dfnocons2)

table(dfnocons$time)

summary(m3<-lm(log(pm25) ~ treat + group1 + group2 + group3 + 
                 PRECTOT + PRECSNO + QSH + RHOA + SPEED + TLML + 
                 as.factor(month):group1 + as.factor(month):group2 +
                 as.factor(month):group3 + as.factor(month) + year, data=dfnocons))

summary(m2<-lm(log(pm25) ~ treat + group1 + group2 + group3 + 
                 PRECTOT + PRECSNO + QSH + RHOA + SPEED + TLML + 
                 as.factor(month):group1 + as.factor(month):group2 +
                 as.factor(month):group3 + as.factor(month) + year + as.factor(add), data=dfnocons))

