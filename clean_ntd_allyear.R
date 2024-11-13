cities<-read.csv("cntrl_cities.csv")

cities2<-c(cities$x, 
           "Charlotte, NC", 
           "Phoenix-Mesa, AZ", 
           "Houston, TX", 
           "Minneapolis-St. Paul, MN", 
           "El Paso, TX-NM", 
           "Las Cruces, NM")

df<-read.csv("ntd_00to12.csv") 
  
df2<-df |>
  mutate(ID=as.numeric(substr(ID, 1,4))) 

id_ua <- read.csv("NTD/2013_Operating_Stats.csv") |>
  group_by(Urbanized.Area, ID) |>
  tally() |>
  select(-n) |>
  mutate(Urbanized.Area=ifelse(Urbanized.Area=="Charlotte, NC-SC", "Charlotte, NC", Urbanized.Area)) |>
  mutate(Urbanized.Area=ifelse(Urbanized.Area=="Minneapolis-St. Paul, MN-WI", "Minneapolis-St. Paul, MN", Urbanized.Area)) |>
  filter(Urbanized.Area %in% cities2)

c1<-as.data.frame(cbind(Urbanized.Area="Phoenix-Mesa, AZ", ID=9129)) |>
  mutate(ID=as.numeric(ID))

id2<-rbind(id_ua, c1)

temp<-id2 |>
  filter(Urbanized.Area=="Phoenix-Mesa, AZ")

cntrl<-merge(df2, id2, by="ID") |>
  group_by(Urbanized.Area, year) |>
  summarize(bus=sum(bus), LR=sum(LR), rail=sum(rail), cars=sum(cars), oth=sum(oth), total=sum(total),
            share_light=LR/total, 
            share_rail=rail/total,
            share_bus=bus/total, 
            share_oth=oth/total, 
            share_cars=cars/total) 

write.csv(cntrl, "ntd_by_year.csv", row.names = F)
