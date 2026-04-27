# ==============================================================================
# DATA MASTERS CHALLENGE OLYMPIAD 2026 - Task 1: Data Cleaning & Preprocessing
# ==============================================================================

setwd("C:\\Users\\rodat\\OneDrive\\Desktop\\MS Data Analytics\\Olympiad")

library(tidyverse)
library(janitor)
library(naniar)

# Load raw dataset
raw_data <- read_csv("milan_cortina_2026_athletes.csv", show_col_types = FALSE)

cat("=== RAW DATA DIMENSIONS ===\n")
print(dim(raw_data))

# ------------------------------------------------------------------------------
# 1.1 Missing Value Audit
# ------------------------------------------------------------------------------
missing_summary <- raw_data %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Missing_Count") %>%
  mutate(Missing_Pct = round(Missing_Count / nrow(raw_data) * 100, 2))

cat("\n=== 1.1 MISSING VALUE AUDIT ===\n")
print(missing_summary)

# Identify missingness patterns by sport
missing_by_sport <- raw_data %>%
  group_by(Sport) %>%
  summarise(across(c(Reaction_Time_ms, World_Cup_Points_Preseason), 
                   ~ round(mean(is.na(.)) * 100, 1))) %>%
  filter(Reaction_Time_ms > 0 | World_Cup_Points_Preseason > 0)

cat("\n=== MISSINGNESS BY SPORT ===\n")
print(missing_by_sport)
# Reaction_Time_ms and World_Cup_Points_Preseason show sport-specific missingness.

# ------------------------------------------------------------------------------
# 1.3 Duplicate Detection
# ------------------------------------------------------------------------------
cat("\n=== 1.3 DUPLICATE DETECTION ===\n")

dupe_by_id <- get_dupes(raw_data, Athlete_ID)
cat("Duplicates by Athlete_ID:\n")
print(dupe_by_id)

full_duplicates <- raw_data[duplicated(raw_data) | duplicated(raw_data, fromLast = TRUE), ]
cat("\nFull-row duplicates:\n")
print(full_duplicates)

cat("\nUnique Athlete_ID count:", length(unique(raw_data$Athlete_ID)), 
    "out of total rows:", nrow(raw_data), "\n")

# Remove duplicates based on Athlete_Name (col B) + Country (col C).
# The three duplicate records were assigned new Athlete_IDs during ingestion,
# so distinct(Athlete_ID) removes nothing — the dupes are invisible to ID-based dedup.
# Name + Country is the correct natural key here.
# Confirmed removed: MC26_1275 (Brandon Bernard/CHN), MC26_1356 (Trevor Martin/FRA),
#                    MC26_1383 (Lisa Martin/JPN)  ->  390 rows to 387
clean_data <- raw_data %>%
  distinct(Athlete_Name, Country, .keep_all = TRUE)

cat(paste("\nRows before/after duplicate removal:", nrow(raw_data), "→", nrow(clean_data), "\n"))

# ------------------------------------------------------------------------------
# 1.2 Planted Error Correction
# ------------------------------------------------------------------------------
cat("\n=== 1.2 ERROR AUDIT ===\n")

error_audit <- clean_data %>%
  filter(
    Age < 15 | Age > 50 |
      Training_Hours_Per_Week > 100 |
      VO2max < 0 |
      Body_Fat_Pct > 40
  )

print(error_audit %>% 
        select(Athlete_ID, Athlete_Name, Age, Training_Hours_Per_Week, 
               VO2max, Body_Fat_Pct, Sport))

# Correct the four impossible values
clean_data <- clean_data %>%
  mutate(
    # Age = 9 is impossible for an Olympian
    Age = case_when(
      Athlete_ID == "MC26_1170" ~ NA_real_,
      TRUE ~ Age
    ),
    
    # Training_Hours_Per_Week = 172 exceeds realistic training load
    Training_Hours_Per_Week = case_when(
      Training_Hours_Per_Week > 100 ~ NA_real_,
      TRUE ~ Training_Hours_Per_Week
    ),
    
    # Negative VO2max is physically impossible
    VO2max = case_when(
      VO2max < 0 ~ NA_real_,
      TRUE ~ VO2max
    ),
    
    # Body_Fat_Pct = 99.2 is impossible for an elite athlete
    Body_Fat_Pct = case_when(
      Body_Fat_Pct > 40 ~ NA_real_,
      TRUE ~ Body_Fat_Pct
    )
  )

cat("\nFour impossible values corrected to NA.\n")

# ------------------------------------------------------------------------------
# 1.4 Outlier Analysis
# ------------------------------------------------------------------------------
cat("\n=== 1.4 OUTLIER ANALYSIS ===\n")

age_outliers <- clean_data %>%
  filter(Age < quantile(Age, 0.25, na.rm = TRUE) - 1.5 * IQR(Age, na.rm = TRUE) |
           Age > quantile(Age, 0.75, na.rm = TRUE) + 1.5 * IQR(Age, na.rm = TRUE))

print(age_outliers %>% select(Athlete_ID, Athlete_Name, Age, Sport, Medal))
# High age values retained as they align with known veteran athletes in the dataset.

# ------------------------------------------------------------------------------
# 1.5 Imputation and Feature Engineering
# ------------------------------------------------------------------------------
# Impute numeric variables using median by Sport and Gender
clean_data <- clean_data %>%
  group_by(Sport, Gender) %>%
  mutate(
    # Age was corrected to NA for MC26_1170 (Age = 9) above — impute it here
    Age                     = coalesce(Age,                     median(Age, na.rm = TRUE)),
    Training_Hours_Per_Week = coalesce(Training_Hours_Per_Week, median(Training_Hours_Per_Week, na.rm = TRUE)),
    Altitude_Training_m     = coalesce(Altitude_Training_m,     median(Altitude_Training_m, na.rm = TRUE)),
    Body_Fat_Pct            = coalesce(Body_Fat_Pct,            median(Body_Fat_Pct, na.rm = TRUE)),
    VO2max                  = coalesce(VO2max,                  median(VO2max, na.rm = TRUE))
  ) %>%
  ungroup()

# Add indicators for MNAR variables before any modification
# (flag = TRUE means value was originally absent for this athlete)
clean_data <- clean_data %>%
  mutate(
    Reaction_Time_Missing   = is.na(Reaction_Time_ms),
    WorldCup_Points_Missing = is.na(World_Cup_Points_Preseason)
  )

# Zero-fill MNAR columns: imputing with medians would fabricate data that
# structurally cannot exist for Curling/Figure Skating/Cross-Country/Ice Hockey.
# Setting to 0 signals "not applicable" while keeping the dataset complete for modeling.
clean_data <- clean_data %>%
  mutate(
    Reaction_Time_ms           = replace_na(Reaction_Time_ms, 0),
    World_Cup_Points_Preseason = replace_na(World_Cup_Points_Preseason, 0)
  )

# Create new features
clean_data <- clean_data %>%
  mutate(
    # Cumulative experience metric
    Experience_Index = Previous_Olympics * Training_Hours_Per_Week,
    
    # Physiological efficiency ratio
    VO2max_BodyFat_Efficiency = ifelse(Body_Fat_Pct > 0, VO2max / Body_Fat_Pct, NA_real_),
    
    # National resource and tradition composite
    GDP_Tradition_Composite = Country_GDP_per_capita * Winter_Sport_Tradition_Index / 10000
  )

# Prepare target variable
clean_data <- clean_data %>%
  mutate(
    # Replace NA with "None" first — 286 non-medalists are stored as NA, not missing.
    # Without this, factor() silently drops them and the class balance is wrong.
    Medal        = replace_na(Medal, "None"),
    Medal_Binary = ifelse(Medal %in% c("Gold", "Silver", "Bronze"), "Medal", "None"),
    Medal        = factor(Medal, levels = c("None", "Bronze", "Silver", "Gold"))
  )

# Export cleaned dataset
write_csv(clean_data, "milan_cortina_2026_cleaned_Final.csv")

cat("\n=== TASK 1 COMPLETE ===\n")
print(data.frame(
  Stage = c("Raw", "Cleaned"),
  Rows = c(nrow(raw_data), nrow(clean_data)),
  Columns = c(ncol(raw_data), ncol(clean_data))
))

cat("Cleaned file saved as milan_cortina_2026_cleaned_Final.csv\n")




