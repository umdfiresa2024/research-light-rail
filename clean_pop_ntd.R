library("tidyverse")

add_county<-read.csv("address_county.csv") |>
  group_by(Urbanized.Area, County) |>
  tally() |>
  separate(Urbanized.Area, "\\,", into = c("city", "State"), remove=FALSE) |>
  separate(city, "-", into = c("city1", "city2")) |>
  mutate(city1=paste0(city1, " city")) |>
  mutate(city2=paste0(city2, " city")) |>
  separate(State, "-", into = c("State1", "State2")) |>
  mutate(STNAME=ifelse(State1==" TX", "Texas", NA)) |>
  mutate(STNAME=ifelse(State1==" NC", "North Carolina", STNAME)) |>
  mutate(STNAME=ifelse(State1==" AZ", "Arizona", STNAME)) |>
  mutate(STNAME=ifelse(State1==" SC", "South Carolina", STNAME)) |>
  mutate(STNAME=ifelse(State1==" MN", "Minnesota", STNAME)) |>
  mutate(STNAME=ifelse(State1==" WI", "Wisconsin", STNAME)) |>
  mutate(city1=ifelse(city1=="Winston city", "Winston-Salem city", city1)) |>
  select(Urbanized.Area, city1, County, STNAME)

add_county2<-read.csv("address_county.csv") |>
  group_by(Urbanized.Area, County) |>
  tally() |>
  separate(Urbanized.Area, "\\,", into = c("city", "State"), remove=FALSE) |>
  separate(city, "-", into = c("city1", "city2")) |>
  filter(!is.na(city2)) |>
  mutate(STNAME=ifelse(State==" TX", "Texas", NA)) |>
  mutate(STNAME=ifelse(State==" NC", "North Carolina", STNAME)) |>
  mutate(STNAME=ifelse(State==" AZ", "Arizona", STNAME)) |>
  mutate(STNAME=ifelse(State==" SC", "South Carolina", STNAME)) |>
  mutate(STNAME=ifelse(State==" MN", "Minnesota", STNAME)) |>
  mutate(STNAME=ifelse(State==" WI", "Wisconsin", STNAME)) |>
  mutate(STNAME=ifelse(city2=="Socastee", "North Carolina", STNAME)) |>
  select(Urbanized.Area, city2, County, STNAME) |>
  mutate(city2=paste0(city2, " city")) |>
  rename(city1=city2)

ac<-bind_rows(add_county, add_county2) |>
  rename(NAME=city1)

pop00<-read.csv("G:/Shared drives/2024 FIRE Light Rail/DATA/SUB-EST2000.csv") 

acpop<-merge(pop00, ac, by=c("NAME", "STNAME"), all.y=TRUE)

acpop2<-pivot_longer(acpop, cols=starts_with("POPESTIMATE", ), names_to="year", values_to="pop") |>
  mutate(year=as.numeric(substr(year, nchar(year)-3, nchar(year)))) |>
  group_by(NAME, STNAME, Urbanized.Area, year, pop) |>
  tally() |>
  filter(!is.na(pop)) |>
  group_by(Urbanized.Area, year) |>
  summarize(pop=sum(pop))
  
pop20<-read.csv("G:/Shared drives/2024 FIRE Light Rail/DATA/SUB-EST2020_ALL.csv") 

acpop<-merge(pop20, ac, by=c("NAME", "STNAME"), all.y=TRUE)
  
acpop20<-pivot_longer(acpop, cols=starts_with("POPESTIMATE", ), names_to="year", values_to="pop") |>
  mutate(year=as.numeric(substr(year, nchar(year)-3, nchar(year)))) |>
  group_by(NAME, STNAME, Urbanized.Area, year, pop) |>
  tally() |>
  filter(!is.na(pop)) |>
  group_by(Urbanized.Area, year) |>
  summarize(pop=sum(pop))

popall<-bind_rows(acpop2, acpop20)

ntd<-read.csv("ntd_by_year.csv")

all<-merge(popall, ntd, by=c("Urbanized.Area", "year"), all.y=TRUE)

write.csv(all, "pop_ntd_year.csv", row.names=F)
