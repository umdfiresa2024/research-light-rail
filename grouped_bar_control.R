library(tidyverse)

# Read the CSV file
ntd_data <- read.csv("ntd_by_year.csv")

# Define treatment and control cities
treatment_city <- c("Phoenix-Mesa, AZ", "Charlotte, NC")
control_cities <- c("Tucson, AZ", "El Paso, TX-NM", "Asheville, NC", "Charleston, SC", 
                    "Columbia, SC", "Durham, NC", "Fayetteville, NC",
                    "Greenville, SC", "Myrtle Beach, SC", "Socastee, SC", "Winston-Salem, NC")

azg<-c("Phoenix-Mesa, AZ", "Tucson, AZ", "El Paso, TX-NM")
ncg<-c("Charlotte, NC", "Asheville, NC", "Charleston, SC", 
      "Columbia, SC", "Durham, NC", "Fayetteville, NC",
      "Greenville, SC", "Myrtle Beach, SC", "Socastee, SC", 
      "Wilmington, NC", "Winston-Salem, NC")

# Filter data for treatment city and control cities, and separate by year range
filtered_data <- ntd_data %>%
  filter(Urbanized.Area %in% c(treatment_city, control_cities)) %>%
  filter(year <= 2004) %>%
  rename(taxis=cars) %>%
  mutate(
    group = ifelse(Urbanized.Area %in% azg, "Phoenix-Mesa, AZ Group", "Charlotte, NC Group"))

# Ensure 'Urbanized.Area' is a factor with Phoenix-Mesa first
filtered_data <- filtered_data %>%
  mutate(Urbanized.Area = factor(Urbanized.Area, levels = c(treatment_city, setdiff(unique(Urbanized.Area), treatment_city))))

# Gather the data for transportation modes
average_data <- filtered_data %>%
  gather(key = "transportation", value = "people", bus, taxis, oth, LR) %>%
  group_by(Urbanized.Area, group, transportation) %>%
  summarise(average_people = mean(people, na.rm = TRUE), .groups = "drop")

nc_data<-average_data |>
  filter(group=="Charlotte, NC Group") |>
  mutate(Urbanized.Area=str_replace(Urbanized.Area, ", ", "\n")) |>
  mutate(Urbanized.Area=ifelse(str_detect(Urbanized.Area, "Winston"), "Win-Salem\nNC", Urbanized.Area))


az_data<-average_data |>
  filter(group=="Phoenix-Mesa, AZ Group")

nc<-ggplot(nc_data, aes(x = Urbanized.Area, y = average_people/1000, fill = transportation)) +
  geom_bar(stat = "identity") +
  theme_bw() +
  ylim(0,30)+
  labs(
    title = "Trips in NC and SC before Construction",
    x = "",
    y = "Annual Average Trips (in Thousands)",
    fill = "Public \nTrans \nMode"
  ) +
  theme(axis.text.x = element_text(angle = 0)) +
  scale_fill_manual(values = c("bus" = '#7f7f7f', "taxis" = '#ffd200', "oth" = '#ad7231', "LR" = '#e21833')) +
  scale_x_discrete(labels = function(x) gsub(",", ", ", x))   # Clean up city names for display

az<-ggplot(az_data, aes(x = Urbanized.Area, y = average_people/1000, fill = transportation)) +
  geom_bar(stat = "identity") +
  theme_bw() +
  ylim(0,80)+
  labs(
    title = "Trips in AZ and TX before Construction",
    x = "",
    y = "Annual Average Trips (in Thousands)",
    fill = "Public \nTrans \nMode"
  ) +
  theme(axis.text.x = element_text(angle = 0)) +
  scale_fill_manual(values = c("bus" = '#7f7f7f', "taxis" = '#ffd200', "oth" = '#ad7231', "LR" = '#e21833')) +
  scale_x_discrete(labels = function(x) gsub(",", ", ", x))   # Clean up city names for display

library(ggpubr)

png("Presentation/images/ntd_control.png", 
    res=500, width=12, height=5, units="in")

ggarrange(nc, az, ncol=2, nrow=1, common.legend = TRUE, legend="bottom")

dev.off()

#####################after#######################################################

# Filter data for treatment city and control cities, and separate by year range
filtered_data <- ntd_data %>%
  filter(Urbanized.Area %in% c(treatment_city, control_cities)) %>%
  filter(year >= 2008) %>%
  rename(taxis=cars) %>%
  mutate(
    group = ifelse(Urbanized.Area %in% azg, "Phoenix-Mesa, AZ Group", "Charlotte, NC Group"))

# Ensure 'Urbanized.Area' is a factor with Phoenix-Mesa first
filtered_data <- filtered_data %>%
  mutate(Urbanized.Area = factor(Urbanized.Area, levels = c(treatment_city, setdiff(unique(Urbanized.Area), treatment_city))))

# Gather the data for transportation modes
average_data <- filtered_data %>%
  gather(key = "transportation", value = "people", bus, taxis, oth, LR) %>%
  group_by(Urbanized.Area, group, transportation) %>%
  summarise(average_people = mean(people, na.rm = TRUE), .groups = "drop")

nc_data<-average_data |>
  filter(group=="Charlotte, NC Group")  |>
  mutate(Urbanized.Area=str_replace(Urbanized.Area, ", ", "\n")) |>
  mutate(Urbanized.Area=ifelse(str_detect(Urbanized.Area, "Winston"), "Win-Salem\nNC", Urbanized.Area))


az_data<-average_data |>
  filter(group=="Phoenix-Mesa, AZ Group")

nc2<-ggplot(nc_data, aes(x = Urbanized.Area, y = average_people/1000, fill = transportation)) +
  geom_bar(stat = "identity") +
  theme_bw() +
  ylim(0,30)+
  labs(
    title = "Trips in NC and SC after Opening",
    x = "",
    y = "Annual Average Trips (in Thousands)",
    fill = "Public \nTrans \nMode"
  ) +
  theme(axis.text.x = element_text(angle = 0)) +
  scale_fill_manual(values = c("bus" = '#7f7f7f', "taxis" = '#ffd200', "oth" = '#ad7231', "LR" = '#e21833')) +
  scale_x_discrete(labels = function(x) gsub(",", ", ", x))   # Clean up city names for display

az2<-ggplot(az_data, aes(x = Urbanized.Area, y = average_people/1000, fill = transportation)) +
  geom_bar(stat = "identity") +
  theme_bw() +
  ylim(0,80)+
  labs(
    title = "Trips in AZ and TX  after Opening",
    x = "",
    y = "Annual Average Trips (in Thousands)",
    fill = "Public \nTrans \nMode"
  ) +
  theme(axis.text.x = element_text(angle = 0)) +
  scale_fill_manual(values = c("bus" = '#7f7f7f', "taxis" = '#ffd200', "oth" = '#ad7231', "LR" = '#e21833')) +
  scale_x_discrete(labels = function(x) gsub(",", ", ", x))   # Clean up city names for display

png("Presentation/images/ntd_before_after.png", 
    res=500, width=12, height=8, units="in")

ggarrange(nc, nc2, az, az2, ncol=2, nrow=2, common.legend = TRUE, legend="right")

dev.off()
