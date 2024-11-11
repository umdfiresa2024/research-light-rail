library(tidyverse)

# Read the CSV file
ntd_data <- read.csv("ntd_by_year.csv")

# Define treatment and control cities
treatment_city <- "Charlotte, NC"
control_cities <- c(
  "Asheville, NC", "Charleston, SC", "Columbia, SC", "Durham, NC", "Fayetteville, NC",
  "Greenville, SC", "Myrtle Beach, SC", "Socastee, SC", "Wilmington, NC", "Winston-Salem, NC"
)

# Filter data for treatment city and control cities
filtered_data <- ntd_data %>%
  filter(Urbanized.Area %in% c(treatment_city, control_cities))

# Create a 'group' column to differentiate between treatment and control cities
filtered_data <- filtered_data %>%
  mutate(group = ifelse(Urbanized.Area == treatment_city, "Treatment City (Charlotte, NC)", "Control Cities"))

# Calculate the average number of people across all years for each city and transportation mode (bus, cars, oth)
average_data <- filtered_data %>%
  gather(key = "transportation", value = "people", bus, cars, oth) %>%
  group_by(Urbanized.Area, group, transportation) %>%
  summarise(average_people = mean(people, na.rm = TRUE), .groups = "drop")

# Plot the stacked bar chart with raw numbers (not proportions)
ggplot(average_data, aes(x = Urbanized.Area, y = average_people, fill = transportation)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(
    title = "Average Number of People Using Different Transportation Modes by City (2000-2012)",
    x = "City",
    y = "Average Number of People",
    fill = "Transportation Mode"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_manual(values = c("bus" = '#6AA84F', "cars" = '#F1C232', "oth" = '#E06666')) +
  scale_x_discrete(labels = function(x) gsub(",", ", ", x))  # Clean up city names for display
