library("tidyverse")

ntd<-read.csv("ntd_by_year.csv") |>
  mutate(State=substr(Urbanized.Area, nchar(Urbanized.Area)-1, nchar(Urbanized.Area))) |>
  mutate(County=ifelse(Urbanized.Area=="Asheville, NC", "Buncombe County", NA)) |>
  mutate(County=ifelse(Urbanized.Area=="Austin, TX", "Travis County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Beaumont, TX", "Jefferson County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Brownsville, TX", "Cameron County", County)) |>
  
  mutate(County=ifelse(Urbanized.Area=="Beloit, WI-IL", "Rock County", County)) |>
  mutate(County2=ifelse(Urbanized.Area=="Beloit, WI-IL", "Winnebago County", NA)) |>
  
  mutate(County=ifelse(Urbanized.Area=="Charleston-North Charleston, SC", "Charleston County", County)) |>
  mutate(County2=ifelse(Urbanized.Area=="Charleston-North Charleston, SC", "Berkeley County", County2)) |>
  
  mutate(County=ifelse(Urbanized.Area=="Charlotte, NC", "Mecklenburg County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="College Station-Bryan, TX", "Brazos County", County)) |>
  
  mutate(County=ifelse(Urbanized.Area=="Columbia, SC", "Richland County", County)) |>
  mutate(County2=ifelse(Urbanized.Area=="Columbia, SC", "Lexington County", County2)) |>
  
  mutate(County=ifelse(Urbanized.Area=="Concord, NC", "Cabarrus County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Corpus Christi, TX", "Nueces County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Denton-Lewisville, TX", "Denton County", County)) |>
  
  mutate(County=ifelse(Urbanized.Area=="Duluth, MN-WI", "St. Louis County", County)) |>
  mutate(County2=ifelse(Urbanized.Area=="Columbia, SC", "Douglas County", County2)) |>
  
  mutate(County=ifelse(Urbanized.Area=="Durham, NC", "Durham County", County)) |>
  
  mutate(County=ifelse(Urbanized.Area=="El Paso, TX-NM", "El Paso County", County)) |>
  mutate(County2=ifelse(Urbanized.Area=="El Paso, TX-NM", "Doña Ana County", County2)) |>  
  
  mutate(County=ifelse(Urbanized.Area=="Fayetteville, NC", "Cumberland County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Flagstaff, AZ", "Coconino County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Greenville, SC", "Greenville County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Houston, TX", "Harris County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Janesville, WI", "Rock County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Laredo, TX", "Webb County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Lubbock, TX", "Lubbock County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Madison, WI", "Dane County", County)) |>
  
  mutate(County=ifelse(Urbanized.Area=="Minneapolis-St. Paul, MN", "Travis County", County)) |>
  mutate(County2=ifelse(Urbanized.Area=="Minneapolis-St. Paul, MN", "Ramsey County", County2)) |>  
  
  mutate(County=ifelse(Urbanized.Area=="Myrtle Beach-Socastee, SC-NC", "Horry County", County)) |>
  mutate(County2=ifelse(Urbanized.Area=="Myrtle Beach-Socastee, SC-NC", "Brunswick County", County2)) |>  
  
  mutate(County=ifelse(Urbanized.Area=="Odessa, TX", "Ector County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Phoenix-Mesa, AZ", "Maricopa County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Rochester, MN", "Olmsted County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Racine, WI", "Racine County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="San Antonio, TX", "Bexar County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Sierra Vista, AZ", "Cochise County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Tucson, AZ", "Pima County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Waco, TX", "McLennan County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Wausau, WI", "Marathon County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Wilmington, NC", "New Hanover County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Winston-Salem, NC", "Forsyth County", County)) |>
  mutate(County=ifelse(Urbanized.Area=="Las Cruces, NM", "Dona Ana County", County)) |>
  group_by(Urbanized.Area, County, County2) |>
  tally() |>
  select(-n)
  
st<-c("IL", "MN", "WI", "TX", "AZ", "NM", "NC", "SC")
ct<-c(unique(ntd$County), unique(ntd$County2))

fac<-read.csv("G:/Shared drives/2024 FIRE Light Rail/DATA/facility-attributes.csv") |>
  filter(State %in% st) |>
  filter(County %in% ct) |>
  group_by(Facility.ID, State, County) |>
  tally() |>
  select(-n)

add_count<-merge(fac, ntd, by=c("County"), all.y=TRUE) |>
  dplyr::select(-County2)

ntd_temp<-ntd |>
  ungroup() |>
  select(-County) |>
  rename(County=County2) |>
  filter(!is.na(County))

add_count2<-merge(fac, ntd_temp, by=c("County")) 

add_count3<-bind_rows(add_count, add_count2)

write.csv(add_count3, "address_county.csv", row.names=F)

epa<-read.csv("G:/Shared drives/2024 FIRE Light Rail/DATA/EPA CAMPD.csv") 

epa2<-merge(epa, add_count3, by=c("Facility.ID"), all.y=TRUE) |>
  group_by(Urbanized.Area, Date) |>
  summarise(CO2=sum(CO2.Mass..short.tons., na.rm=TRUE), 
            SO2=sum(SO2.Mass..short.tons., na.rm=TRUE), 
            NOx=sum(NOx.Mass..short.tons., na.rm=TRUE)) 
Date<-unique(epa2$Date)
Urbanized.Area<-unique(epa2$Urbanized.Area)  
panel<-crossing(Urbanized.Area, Date)  

panel2<-merge(panel, epa2, by=c("Urbanized.Area", "Date"), all.x=TRUE) |>
  mutate_if(is.numeric, list(~replace_na(., 0)))

write.csv(panel2, "epa_by_day.csv", row.names=F)
