
# Exploratory Data Analysis: Opioid- and Stimulant-related Harms in Canada
# Source: Public Health Agency of Canada (PHAC), Public Health Infobase
# URL: https://health-infobase.canada.ca/substance-related-harms/opioids-stimulants/
# Data coverage: January 2016 - September 2025
# Last updated: March 2026
# Riddhi Mandal


# 1. Install and Load Libraries 
install.packages(c("tidyverse", "ggplot2", "scales", "RColorBrewer"))
library(tidyverse)
library(ggplot2)
library(scales)
library(RColorBrewer)


# 2. Load the Data
df_raw <- read.csv("SubstanceHarmsData.csv", stringsAsFactors = FALSE)
cat("Rows:", nrow(df_raw), "\n")
cat("Columns:", ncol(df_raw), "\n")
print(head(df_raw, 3))


# 3. Check Missing Values
cat(" MISSING VALUES \n")
for (col in names(df_raw)) {
  missing_n <- sum(is.na(df_raw[[col]]) | df_raw[[col]] == "")
  pct <- round(100 * missing_n / nrow(df_raw), 1)
  cat(col, ":", missing_n, "missing (", pct, "%)\n")
}

cat("\nSuppressed values ('Suppr.'):", sum(df_raw$Value == "Suppr."), "\n")


# 4. Clean the Data
df <- df_raw

# 4a. Convert blank Aggregator/Disaggregator to proper NA
df$Aggregator[df$Aggregator == ""]     <- NA
df$Disaggregator[df$Disaggregator == ""] <- NA
cat("Step 1 - Blanks converted to NA\n")

# 4b. Convert Value to numeric (Suppr. becomes NA)
df$Value_num <- suppressWarnings(as.numeric(df$Value))
cat("Step 2 - Numeric conversion: ", sum(is.na(df$Value_num)), "NAs created\n")

# 4c. Flag suppressed rows
df$Suppressed <- df$Value == "Suppr."
cat("Step 3 - Suppressed flagged:", sum(df$Suppressed), "rows\n")

# 4d. Extract clean year from Year_Quarter
df$Year_clean <- as.numeric(sub("(\\d{4}).*", "\\1", df$Year_Quarter))
cat("Step 4 - Years extracted:", paste(sort(unique(df$Year_clean)), collapse=", "), "\n")

cat("\nCleaning complete!", nrow(df), "rows x", ncol(df), "columns\n")

# Verify NA is working correctly now
cat("NA in Aggregator after fix:", sum(is.na(df$Aggregator)), "\n")


# Provinces list
PROVINCES <- c("British Columbia", "Alberta", "Saskatchewan", "Manitoba",
               "Ontario", "Quebec", "New Brunswick", "Nova Scotia",
               "Prince Edward Island", "Newfoundland and Labrador",
               "Yukon", "Northwest Territories", "Nunavut")

# Colour palette
C_BLUE   <- "#2E75B6"
C_ORANGE <- "#ED7D31"
C_GREEN  <- "#70AD47"
C_RED    <- "#C00000"
C_PURPLE <- "#7030A0"

cat("Constants defined successfully!\n")
cat("Provinces:", length(PROVINCES), "\n")

#Create national_deaths dataset 
national_deaths <- df %>%
  filter(Source == "Deaths",
         Time_Period == "By year",
         Specific_Measure == "Overall numbers",
         Unit == "Number",
         Region == "Canada",
         is.na(Aggregator),
         Substance == "Opioids",
         Year_clean <= 2025) %>%
  arrange(Year_clean)

cat("Rows in national_deaths:", nrow(national_deaths), "\n")
print(national_deaths %>% select(Year_Quarter, Value_num))


#Figure 1: Data Quality Overview
quality_df <- data.frame(
  Category = c("Total Rows", 
               "Missing Aggregator/\nDisaggregator", 
               "Suppressed\n('Suppr.') Values", 
               "Total Non-numeric\nValues"),
  Count = c(nrow(df),
            sum(is.na(df$Aggregator)),
            sum(df$Suppressed),
            sum(is.na(df$Value_num)))
)

ggplot(quality_df, aes(x = Category, y = Count, fill = Category)) +
  geom_col(width = 0.55, show.legend = FALSE) +
  geom_text(aes(label = comma(Count)), vjust = -0.5, 
            fontface = "bold", size = 4) +
  scale_fill_manual(values = c(C_BLUE, C_ORANGE, C_RED, C_PURPLE)) +
  scale_y_continuous(labels = comma, 
                     expand = expansion(mult = c(0, 0.18))) +
  labs(title = "Figure 1: Dataset Overview and Data Quality Issues (Pre-Cleaning)",
       x = NULL, y = "Count") +
  theme_minimal(base_size = 11)

ggsave("fig1_data_quality.png", width = 9, height = 5, dpi = 150)
cat("Figure 1 saved!\n")


#Figure 2: National Opioid Deaths Trend
national_deaths_plot <- national_deaths %>%
  filter(Year_clean <= 2024)

ggplot(national_deaths_plot, aes(x = Year_clean, y = Value_num)) +
  annotate("rect", xmin = 2019.55, xmax = 2020.45,
           ymin = 0, ymax = Inf, alpha = 0.12, fill = "red") +
  annotate("text", x = 2020, y = 6600,
           label = "COVID-19\n(2020)", size = 3.2, color = "darkred") +
  geom_col(fill = C_BLUE, width = 0.7) +
  geom_line(color = C_RED, linewidth = 1.2) +
  geom_point(color = C_RED, size = 3) +
  geom_text(aes(label = comma(as.integer(Value_num))),
            vjust = -0.5, size = 3, fontface = "bold") +
  scale_x_continuous(breaks = 2016:2024) +
  scale_y_continuous(labels = comma,
                     expand = expansion(mult = c(0, 0.15))) +
  labs(title = "Figure 2: Apparent Opioid Toxicity Deaths in Canada, 2016-2024",
       x = "Year", y = "Number of Opioid Deaths") +
  theme_minimal(base_size = 11)

ggsave("fig2_national_deaths_trend.png", width = 9, height = 5, dpi = 150)
cat("Figure 2 saved!\n")

#Figure 3: Deaths by Province 2024
prov_2024 <- df %>%
  filter(Source == "Deaths",
         Time_Period == "By year",
         Specific_Measure == "Overall numbers",
         Unit == "Number",
         Year_Quarter == "2024",
         is.na(Aggregator),
         Region %in% PROVINCES,
         Substance == "Opioids") %>%
  drop_na(Value_num) %>%
  arrange(Value_num)

cat("Rows:", nrow(prov_2024), "\n")
print(prov_2024 %>% select(Region, Value_num) %>% arrange(desc(Value_num)))

ggplot(prov_2024, aes(x = reorder(Region, Value_num), y = Value_num,
                      fill = Value_num == max(Value_num))) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = comma(as.integer(Value_num))),
            hjust = -0.15, size = 3.2) +
  scale_fill_manual(values = c("FALSE" = C_BLUE, "TRUE" = C_RED)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.16))) +
  coord_flip() +
  labs(title = "Figure 3: Apparent Opioid Deaths by Province/Territory, 2024",
       x = NULL, y = "Number of Opioid Deaths") +
  theme_minimal(base_size = 11)

ggsave("fig3_deaths_by_province_2024.png", width = 8, height = 5.5, dpi = 150)
cat("Figure 3 saved!\n")

#Figure 4: Opioids vs Stimulants
both_trends <- df %>%
  filter(Source == "Deaths",
         Time_Period == "By year",
         Specific_Measure == "Overall numbers",
         Unit == "Number",
         Region == "Canada",
         is.na(Aggregator),
         Year_clean <= 2024) %>%
  drop_na(Value_num) %>%
  arrange(Year_clean)

cat("Rows:", nrow(both_trends), "\n")
print(both_trends %>% select(Substance, Year_Quarter, Value_num))

ggplot(both_trends, aes(x = Year_clean, y = Value_num,
                        color = Substance, shape = Substance)) +
  geom_line(linewidth = 1.8) +
  geom_point(size = 3.5) +
  scale_color_manual(values = c("Opioids" = C_BLUE, 
                                "Stimulants" = C_ORANGE)) +
  scale_x_continuous(breaks = 2016:2024) +
  scale_y_continuous(labels = comma) +
  labs(title = "Figure 4: Opioid vs. Stimulant Toxicity Deaths in Canada, 2016-2024",
       x = "Year", y = "Number of Deaths",
       color = "Substance", shape = "Substance") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")

ggsave("fig4_opioid_vs_stimulant.png", width = 9, height = 5, dpi = 150)
cat("Figure 4 saved!\n")


#Figure 5: Deaths by Age Group
age_order <- c("0 to 19 years", "20 to 29 years", "30 to 39 years",
               "40 to 49 years", "50 to 59 years", "60 years or more")
age_colors <- c("#D9E1F2", "#9DC3E6", "#2E75B6", 
                "#ED7D31", "#C00000", "#7030A0")

age_data <- df %>%
  filter(Source == "Deaths",
         Specific_Measure == "Age group",
         Unit == "Percent",
         Region == "Canada",
         Substance == "Opioids",
         Time_Period == "By year",
         Year_clean <= 2024,
         Disaggregator %in% age_order) %>%
  drop_na(Value_num) %>%
  mutate(Disaggregator = factor(Disaggregator, levels = age_order))

cat("Rows:", nrow(age_data), "\n")
print(age_data %>% filter(Year_clean == 2024) %>% 
        select(Disaggregator, Value_num))

ggplot(age_data, aes(x = Year_clean, y = Value_num, 
                     fill = Disaggregator)) +
  geom_col(width = 0.7) +
  scale_fill_manual(values = age_colors, name = "Age Group") +
  scale_x_continuous(breaks = 2016:2024) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(title = "Figure 5: Opioid Deaths by Age Group (%) - Canada, 2016-2024",
       x = "Year", y = "% of Opioid Deaths") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "right")

ggsave("fig5_deaths_by_age.png", width = 9, height = 5, dpi = 150)
cat("Figure 5 saved!\n")

#Figure 6: Deaths by Sex
sex_data <- df %>%
  filter(Source == "Deaths",
         Specific_Measure == "Sex",
         Unit == "Percent",
         Region == "Canada",
         Substance == "Opioids",
         Time_Period == "By year",
         Year_clean <= 2024,
         Disaggregator %in% c("Male", "Female")) %>%
  drop_na(Value_num)

cat("Rows:", nrow(sex_data), "\n")
print(sex_data %>% filter(Year_clean == 2024) %>%
        select(Disaggregator, Value_num))

ggplot(sex_data, aes(x = Year_clean, y = Value_num,
                     fill = Disaggregator)) +
  geom_col(width = 0.7) +
  scale_fill_manual(values = c("Male" = C_BLUE, 
                               "Female" = C_ORANGE),
                    name = "Sex") +
  scale_x_continuous(breaks = 2016:2024) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(title = "Figure 6: Opioid Deaths by Sex (%) - Canada, 2016-2024",
       x = "Year", y = "% of Opioid Deaths") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "right")

ggsave("fig6_deaths_by_sex.png", width = 9, height = 5, dpi = 150)
cat("Figure 6 saved!\n")


#Figure 7: Fentanyl Involvement %
fent_data <- df %>%
  filter(Source == "Deaths",
         Specific_Measure == "Type of opioids",
         Unit == "Percent",
         Region == "Canada",
         Substance == "Opioids",
         Disaggregator == "Fentanyl",
         Year_clean <= 2024) %>%
  drop_na(Value_num) %>%
  arrange(Year_clean)

cat("Rows:", nrow(fent_data), "\n")
print(fent_data %>% select(Year_Quarter, Value_num))

ggplot(fent_data, aes(x = Year_clean, y = Value_num)) +
  geom_col(fill = C_RED, width = 0.7, alpha = 0.85) +
  geom_line(color = "#800000", linewidth = 1.2) +
  geom_point(color = "#800000", size = 3) +
  geom_text(aes(label = paste0(round(Value_num, 0), "%")),
            vjust = -0.5, fontface = "bold", size = 3.5) +
  scale_x_continuous(breaks = unique(fent_data$Year_clean)) +
  scale_y_continuous(limits = c(0, 110),
                     labels = function(x) paste0(x, "%")) +
  labs(title = "Figure 7: Opioid Deaths Involving Fentanyl - Canada, 2016-2024",
       x = "Year", 
       y = "% of Opioid Deaths Involving Fentanyl") +
  theme_minimal(base_size = 11)

ggsave("fig7_fentanyl_trend.png", width = 9, height = 5, dpi = 150)
cat("Figure 7 saved!\n")


#Figure 8: All Four Harm Types Panel
four_harms <- df %>%
  filter(Time_Period == "By year",
         Specific_Measure == "Overall numbers",
         Unit == "Number",
         Region == "Canada",
         Substance == "Opioids",
         is.na(Aggregator),
         Year_clean <= 2024) %>%
  drop_na(Value_num)

source_labels <- c(
  "Deaths"                           = "Deaths",
  "Hospitalizations"                 = "Hospitalizations",
  "Emergency Department (ED) Visits" = "ED Visits",
  "Emergency Medical Services (EMS)" = "EMS Responses"
)

source_colors <- c(
  "Deaths"                           = C_RED,
  "Hospitalizations"                 = C_BLUE,
  "Emergency Department (ED) Visits" = C_ORANGE,
  "Emergency Medical Services (EMS)" = C_GREEN
)

cat("Rows:", nrow(four_harms), "\n")
print(four_harms %>% 
        group_by(Source) %>% 
        summarise(mean = round(mean(Value_num),0),
                  min  = min(Value_num),
                  max  = max(Value_num)))

ggplot(four_harms, aes(x = Year_clean, y = Value_num,
                       color = Source, fill = Source)) +
  geom_area(alpha = 0.2) +
  geom_line(linewidth = 1.5) +
  geom_point(size = 2.5) +
  facet_wrap(~ Source, scales = "free_y", nrow = 2,
             labeller = labeller(Source = source_labels)) +
  scale_color_manual(values = source_colors) +
  scale_fill_manual(values = source_colors) +
  scale_x_continuous(breaks = c(2016, 2018, 2020, 2022, 2024)) +
  scale_y_continuous(labels = comma) +
  labs(title = "Figure 8: Four Types of Opioid-Related Harms in Canada, 2016-2024",
       x = "Year", y = "Count") +
  theme_minimal(base_size = 10) +
  theme(legend.position = "none",
        strip.text = element_text(face = "bold"))

ggsave("fig8_four_harm_types.png", width = 11, height = 7, dpi = 150)
cat("Figure 8 saved!\n")


#Figure 9: Heatmap by Province and Year
rate_prov <- df %>%
  filter(Source == "Deaths",
         Time_Period == "By year",
         Specific_Measure == "Overall numbers",
         Unit == "Crude rate",
         is.na(Aggregator),
         Substance == "Opioids",
         Region %in% PROVINCES,
         Year_clean <= 2024) %>%
  drop_na(Value_num)

cat("Rows:", nrow(rate_prov), "\n")
print(rate_prov %>% 
        filter(Year_clean == 2024) %>%
        select(Region, Value_num) %>% 
        arrange(desc(Value_num)))

ggplot(rate_prov, aes(x = factor(Year_clean), 
                      y = Region, 
                      fill = Value_num)) +
  geom_tile(color = "white", linewidth = 0.4) +
  geom_text(aes(label = round(Value_num, 1),
                color = Value_num > quantile(Value_num, 0.6, 
                                             na.rm = TRUE)),
            size = 3) +
  scale_fill_gradient(low = "#FFF7EC", high = "#C00000",
                      name = "Rate per\n100,000",
                      na.value = "grey90") +
  scale_color_manual(values = c("TRUE" = "white", 
                                "FALSE" = "black"),
                     guide = "none") +
  labs(title = "Figure 9: Opioid Death Crude Rate per 100,000 - by Province and Year",
       x = "Year", y = NULL) +
  theme_minimal(base_size = 10) +
  theme(axis.text.y = element_text(size = 9),
        panel.grid = element_blank())

ggsave("fig9_heatmap_province_year.png", width = 11, 
       height = 6, dpi = 150)
cat("Figure 9 saved!\n")

#Figure 10: Histogram
hist_data <- df %>%
  filter(Source == "Deaths",
         Time_Period == "By year",
         Specific_Measure == "Overall numbers",
         Unit == "Number",
         is.na(Aggregator),
         Substance == "Opioids",
         Region %in% PROVINCES,
         Year_clean <= 2024) %>%
  drop_na(Value_num)

cat("Rows:", nrow(hist_data), "\n")
cat("Min:", min(hist_data$Value_num), "\n")
cat("Max:", max(hist_data$Value_num), "\n")
cat("Mean:", round(mean(hist_data$Value_num), 1), "\n")
cat("Median:", median(hist_data$Value_num), "\n")

ggplot(hist_data, aes(x = Value_num)) +
  geom_histogram(bins = 20, fill = C_BLUE,
                 color = "white", alpha = 0.85) +
  geom_vline(xintercept = mean(hist_data$Value_num),
             color = C_RED, linewidth = 1.2,
             linetype = "dashed") +
  geom_vline(xintercept = median(hist_data$Value_num),
             color = C_ORANGE, linewidth = 1.2,
             linetype = "dashed") +
  annotate("text", x = mean(hist_data$Value_num) + 150,
           y = 18, label = paste0("Mean: ",
                                  round(mean(hist_data$Value_num), 0)),
           color = C_RED, fontface = "bold", size = 3.5) +
  annotate("text", x = median(hist_data$Value_num) + 150,
           y = 16, label = paste0("Median: ",
                                  round(median(hist_data$Value_num), 0)),
           color = C_ORANGE, fontface = "bold", size = 3.5) +
  scale_x_continuous(labels = comma) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(title = "Figure 10: Distribution of Annual Opioid Deaths by Province, 2016-2024",
       x = "Number of Opioid Deaths",
       y = "Frequency") +
  theme_minimal(base_size = 11)

ggsave("fig10_histogram_deaths.png", width = 9, height = 5, dpi = 150)
cat("Figure 10 saved!\n")


# Figure 11: Boxplot
box_data <- df %>%
  filter(Source == "Deaths",
         Time_Period == "By year",
         Specific_Measure == "Overall numbers",
         Unit == "Crude rate",
         is.na(Aggregator),
         Substance == "Opioids",
         Region %in% PROVINCES,
         Year_clean <= 2024) %>%
  drop_na(Value_num) %>%
  mutate(Region = fct_reorder(Region, Value_num, median))

ggplot(box_data, aes(x = Region, y = Value_num)) +
  geom_boxplot(fill = C_BLUE, alpha = 0.7,
               outlier.color = C_RED,
               outlier.size = 2,
               color = "gray30") +
  coord_flip() +
  labs(title = "Figure 11: Distribution of Opioid Death Rates by Province, 2016-2024",
       subtitle = "Crude rate per 100,000 — each box shows spread across 2016-2024",
       x = NULL,
       y = "Crude Rate per 100,000") +
  theme_minimal(base_size = 11)

ggsave("fig11_boxplot_provinces.png", width = 9, height = 6, dpi = 150)
cat("Figure 11 saved!\n")


#Figure 12 — Scatterplot
scatter_data <- df %>%
  filter(Time_Period == "By year",
         Specific_Measure == "Overall numbers",
         Unit == "Number",
         is.na(Aggregator),
         Substance == "Opioids",
         Region == "Canada",
         Year_clean <= 2024) %>%
  select(Year_clean, Source, Value_num) %>%
  drop_na(Value_num) %>%
  pivot_wider(names_from = Source, 
              values_from = Value_num) %>%
  rename(
    Deaths = Deaths,
    Hospitalizations = Hospitalizations
  )

ggplot(scatter_data, aes(x = Hospitalizations, y = Deaths)) +
  geom_point(color = C_BLUE, size = 4, alpha = 0.85) +
  geom_smooth(method = "lm", color = C_RED,
              se = TRUE, linewidth = 1.2) +
  geom_text(aes(label = Year_clean),
            vjust = -0.9, size = 3.2, 
            fontface = "bold") +
  scale_x_continuous(labels = comma) +
  scale_y_continuous(labels = comma) +
  labs(title = "Figure 12: Opioid Deaths vs Hospitalizations - Canada, 2016-2024",
       subtitle = "Each point = one year. Red line = linear trend.",
       x = "Number of Hospitalizations",
       y = "Number of Deaths") +
  theme_minimal(base_size = 11)

ggsave("fig12_scatterplot.png", width = 9, height = 5, dpi = 150)
cat("Figure 12 saved!\n")
