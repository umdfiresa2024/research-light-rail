
library("terra")

az<-vect("tl_2010_AZ_puma10/tl_2010_04_puma10.shp")

Transit_Map_GEO <- vect("Valley_Metro_Light_Rail/LightRailLine.shp")
trans <- subset(Transit_Map_GEO, Transit_Map_GEO$SYMBOLOGY=="METRO")
char_lr<-aggregate(trans, dissolve=TRUE)
lr_project<-project(char_lr, crs(az))

plot(az)
plot(lr_project,add=TRUE, col="#e21833", cex=2)

int<-intersect(az, lr_project)
pum_az<-int$PUMACE10

########################################################################

nc<-vect("tl_2010_NC_puma10/tl_2010_37_puma10.shp")

char_lr <- vect("G:/Shared drives/2024 FIRE Light Rail/DATA/LYNX_Blue_Line_Route")
char_lr<-aggregate(char_lr, dissolve=TRUE)
lr_project<-project(char_lr, crs(nc))

plot(nc)
plot(lr_project,add=TRUE, col="#e21833", cex=2)

mc<-subset(nc, str_detect(nc$NAMELSAD10, "Charlotte") | str_detect(nc$NAMELSAD10, "Mecklenburg"))

mc<-subset(nc, str_detect(nc$PUMACE10, "031"))
plot(mc, "NAMELSAD10")
plot(lr_project, col="white", cex=10, add=TRUE)

plot(int)
plot(mc, "NAMELSAD10", add=TRUE, alpha=0.5)

int<-intersect(nc, lr_project)
pum_nc<-int$PUMACE10

#######################################################################

library("tidyverse")

#https://data.census.gov/mdat/#/
acs_2012 <- read.csv("acs_by_puma/acs_lr_2012.csv", header=TRUE) |>
  mutate(year=2012)

acs_2005 <- read.csv("acs_by_puma/acs_lr_2005.csv", header=TRUE) |>
  mutate(year=2005)

#assumes that trolleycar + elevated subways are light rails

acs<-rbind(acs_2012, acs_2005) |>
  separate_wider_delim(Selected.Geographies, ", ", names=c("Unit", "State"), too_many = "merge") |>
  mutate(State=ifelse(str_detect(State, "North Carolina"), "North Carolina", State)) |>
  mutate(Others=Ferry.boat + Other + Railroad + Taxicab+Bicycle+Motorcycle) |>
  mutate(Light.Rail=Streetcar.or.trolley.car + Subway.or.elevated) |>
  select(-Ferry.boat, -Other, -Railroad, -Taxicab, -Bicycle, -Motorcycle, 
         -Streetcar.or.trolley.car, -Subway.or.elevated) 

acs_long<-pivot_longer(acs, cols=c(4:8, 10:11), names_to="Mode", values_to = "Count") |>
  mutate(Mode=ifelse(Mode=="Not.in.universe...missing", "Missing", Mode)) |>
  group_by(State, Mode, year) |>
  summarise(Count=sum(Count)) |>
  mutate(year=as.factor(year))

ggplot(acs_long) +
  geom_bar(aes(x = year, y = Count, fill = Mode),
           position = "stack",
           stat = "identity") +
  facet_grid(~ State) +
  theme_bw()

#######################################################################

#https://data.census.gov/mdat/#/
acs_2012 <- read.csv("acs_by_puma/acs_lr_2012.csv", header=TRUE) |>
  mutate(year=2012) |>
  filter(Selected.Geographies!=" -> Total")

#https://data.census.gov/mdat/#/
acs_2014 <- read.csv("acs_by_puma/acs_lr_2014.csv", header=TRUE) |>
  mutate(year=2014)|>
  filter(Selected.Geographies!=" -> Total")

#https://data.census.gov/mdat/#/
acs_2016 <- read.csv("acs_by_puma/acs_lr_2016.csv", header=TRUE) |>
  mutate(year=2016)|>
  filter(Selected.Geographies!=" -> Total")

#https://data.census.gov/mdat/#/
acs_2018 <- read.csv("acs_by_puma/acs_lr_2018.csv", header=TRUE) |>
  mutate(year=2018)|>
  filter(Selected.Geographies!=" -> Total")

acs<-rbind(acs_2012, acs_2014, acs_2016, acs_2018) |>
  separate_wider_delim(Selected.Geographies, ", ", names=c("Unit", "State"), too_many = "merge") |>
  mutate(State=ifelse(str_detect(State, "North Carolina"), "North Carolina", State)) |>
  mutate(Others=Ferry.boat + Other + Railroad + Taxicab+Bicycle+Motorcycle) |>
  mutate(Light.Rail=Streetcar.or.trolley.car + Subway.or.elevated) |>
  select(-Ferry.boat, -Other, -Railroad, -Taxicab, -Bicycle, -Motorcycle, 
         -Streetcar.or.trolley.car, -Subway.or.elevated) 

acs_long<-pivot_longer(acs, cols=c(4:8, 10:11), names_to="Mode", values_to = "Count") |>
  mutate(Mode=ifelse(Mode=="Not.in.universe...missing", "Missing", Mode)) |>
  group_by(State, Mode, year) |>
  summarise(Count=sum(Count)) |>
  mutate(year=as.factor(year)) |>
  mutate(State=ifelse(State=="Arizona", "Phoenix-Mesa, AZ", "Charlotte, NC"))

library(RColorBrewer)
pal<-brewer.pal(7, "Greys")
pal2<-c(pal[1:2], "#e21833", pal[3:6])

png("Presentation/images/acs.png", 
    res=500, width=8, height=5, units="in")

ggplot(acs_long) +
  geom_bar(aes(x = year, y = Count, fill = Mode),
           position = "stack",
           stat = "identity") +
  #scale_color_brewer("Greys") +
  scale_fill_manual(values=pal2) +
  facet_grid(~ State) +
  theme_bw() +
  labs(title = "Mode of Transportation to Work from 1-year ACS",
       subtitle = "Population-Weighted Estimates from PUMAs with Light Rail")

dev.off()
