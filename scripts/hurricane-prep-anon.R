# Sept. 8, 2024 JRM
# Prep dataset for sharing with students

root <- "path"

## Read SPSS
data <- read.spss(paste0(root, "_data/30118_sample_plus_survey_weighted_completed_n1130_plus_clusters_latlong.sav", reencode="utf-8",to.data.frame=TRUE,use.missings=F))


### Select and rename variables
data <- data[, c(names(data)[1:7], 'Q1', 'Q2', 'Q3', 'Q4', 'Q5', 'Q6', 'Q8', 'Q10', 'Q11', 'Q14', 'Q18', 'Q20_1', 'Q20_2', 'Q50', 'Q51', 'Q55', 'Q56', 'Q58', 'Q59', 'Q61_1', 'Q61_2', 'Q61_3', 'Q61_4', 'Q61_5', 'Q61_6', 'Q62')] %>%
  rename(pin = PIN, household_id = HHID, zipcode = ZIP_Code, blockgroup = Block_Grou, lat = Latitude, lon = Longitude, zone = Zone, liveyearround = Q1, liveparttime = Q2, everhit = Q3, howmanyhits = Q4, worry = Q5, timesevac = Q6, expectedmoreorless = Q8, evacuated = Q10, whenleft = Q11, advisedtogo = Q14, samechoice = Q18, evacpwithnote = Q20_1, evacpwithoutnote = Q20_2, yearborn = Q50, sex = Q51, hispanic = Q55, race = Q56, edu = Q58, income = Q59, party_rep = Q61_1, party_dem = Q61_2, party_ind = Q61_3, party_other = Q61_4, party_none = Q61_5, party_unsure = Q61_6, ideology = Q62)

### Remove people who do not live in coastal CT during hurricane season
data <- data %>%
  mutate(resident = ifelse((liveyearround == "Yes") |
                             (liveyearround == "No" & liveparttime == "Yes"), "Yes", 
                           ifelse((is.na(liveyearround) & is.na(liveparttime)), "No", "No")))


# Filter to residents only
data <- data %>% filter(resident == "Yes")
data$liveparttime <- NULL
data$liveyearround <- NULL

#### Merge in distance data
data$pin <- trimws(as.character(data$pin))
data_gis <- read_csv(paste0(root, 'output/hurricanect_data.csv'))
data_gis$pin <- as.character(data_gis$pin)
data <- left_join(data, data_gis[, c('pin', 'elevation', 'milestocoast')], join_by(pin == pin))

View(data[, c('pin', 'resident', 'elevation', 'milestocoast')])

#### Anonymize
data$lat <- NULL
data$lon <- NULL

#### Output data-frame for safe-keeping
write_csv(data, paste0(root, '/_data/hurricanect_anon.csv'))
