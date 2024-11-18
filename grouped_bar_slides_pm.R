library(tidyverse)

# Read the CSV file
ntd_data <- read.csv("ntd_by_year.csv")

# Define treatment and control cities
treatment_city <- "Phoenix-Mesa, AZ"
control_cities <- c("Tucson, AZ", "El Paso, TX-NM")

# Filter data for treatment city and control cities, and separate by year range
filtered_data <- ntd_data %>%
  filter(Urbanized.Area %in% c(treatment_city, control_cities)) %>%
  filter(year <= 2012) %>%
  mutate(
    group = ifelse(Urbanized.Area == treatment_city, "Treatment City (Phoenix-Mesa, AZ)", "Control Cities"),
    period = case_when(
      year >= 2000 & year <= 2004 ~ "Before Construction",
      year >= 2008 & year <= 2012 ~ "After Opening",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(period))  # Remove rows where period is NA

# Ensure 'Urbanized.Area' is a factor with Phoenix-Mesa first
filtered_data <- filtered_data %>%
  mutate(Urbanized.Area = factor(Urbanized.Area, levels = c(treatment_city, setdiff(unique(Urbanized.Area), treatment_city))))

# Gather the data for transportation modes
average_data <- filtered_data %>%
  gather(key = "transportation", value = "people", bus, cars, oth, LR) %>%
  group_by(Urbanized.Area, group, transportation, period) %>%
  summarise(average_people = mean(people, na.rm = TRUE), .groups = "drop")

# Plot the stacked bar chart with raw numbers (not proportions)
ggplot(average_data, aes(x = Urbanized.Area, y = average_people/1000, fill = transportation)) +
  geom_bar(stat = "identity") +
  theme_bw() +
  labs(
    title = "Average Number of Trips by Transportation Modes",
    x = "",
    y = "Average Trips (in Thousands)",
    fill = "Mode"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_manual(values = c("bus" = '#6AA84F', "cars" = '#F1C232', "oth" = '#E06666', "LR" = '#5B9BD5')) +
  scale_x_discrete(labels = function(x) gsub(",", ", ", x)) +  # Clean up city names for display
  facet_wrap(~period)
  
  facet_wrap(~period, scales = "free_x", ncol = 2, labeller = label_both)  # Split by period

