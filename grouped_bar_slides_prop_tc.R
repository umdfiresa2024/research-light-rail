library(tidyverse)

# Read the CSV file
ntd_data <- read.csv("ntd_by_year.csv")

# Define treatment and control cities
treatment_city <- "Minneapolis-St. Paul, MN"
control_cities <- c(
  "Beloit, WI-IL", "Duluth, MN-WI", "Rochester, MN", "Wausau, WI"
)

# Filter data for treatment city and control cities, and separate by year range
filtered_data <- ntd_data %>%
  filter(Urbanized.Area %in% c(treatment_city, control_cities)) %>%
  filter(year < 2012) %>%
  mutate(
    group = ifelse(Urbanized.Area == treatment_city, "Treatment City (Minneapolis-St. Paul, MN)", "Control Cities"),
    period = case_when(
      year >= 2000 & year <= 2003 ~ "2000-2003",
      year >= 2004 & year <= 2007 ~ "2004-2007",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(period))  # Remove rows where period is NA

# Ensure 'Urbanized.Area' is a factor with Twin Cities first
filtered_data <- filtered_data %>%
  mutate(Urbanized.Area = factor(Urbanized.Area, levels = c(treatment_city, setdiff(unique(Urbanized.Area), treatment_city))))

# Gather the data for transportation modes and calculate the total number of people
average_data <- filtered_data %>%
  gather(key = "transportation", value = "people", bus, cars, oth, LR) %>%
  group_by(Urbanized.Area, group, transportation, period) %>%
  summarise(average_people = sum(people, na.rm = TRUE), .groups = "drop") %>%
  # Calculate total number of people per city and period
  group_by(Urbanized.Area, group, period) %>%
  mutate(total_people = sum(average_people)) %>%
  ungroup() %>%
  # Calculate the proportion for each transportation mode
  mutate(proportion = average_people / total_people)

# Plot the stacked bar chart with proportions
ggplot(average_data, aes(x = Urbanized.Area, y = proportion, fill = transportation)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(
    title = "Proportion of People Using Different Transportation Modes by City (2000-2007)",
    x = "City",
    y = "Proportion of People",
    fill = "Transportation Mode"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_manual(values = c("bus" = '#6AA84F', "cars" = '#F1C232', "oth" = '#E06666', "LR" = '#5B9BD5')) +
  scale_x_discrete(labels = function(x) gsub(",", ", ", x)) +  # Clean up city names for display
  facet_wrap(~period, scales = "free_x", ncol = 2, labeller = label_both)  # Split by period
