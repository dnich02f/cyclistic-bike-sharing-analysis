# # # # # # # # # # # # # # # # # # # # # # # 
# Install required packages
# # # # # # # # # # # # # # # # # # # # # # #  

install.packages("tidyverse")
install.packages("lubridate")
install.packages("ggplot")
install.packages("skimr")
install.packages("janitor")
library(tidyverse)  # helps transform/clean data
library(lubridate)  # helps wrangle/parse date attributes
library(ggplot2)    # helps visualize data
library(readr)      #
library(skimr)      #
library(janitor)    #
library(dplyr)      #
getwd() #displays the working directory
setwd("C:/Users/darryl.nichols/Documents/R/R Projects/Cyclistic Bike Sharing") #sets the working directory to simplify calls to data

#=====================
# COLLECT DATA
#=====================

# Upload Divvy datasets (csv files) here from the tidyverse package and readr library
q2_2019 <- read_csv("Divvy_Trips_2019_Q2.csv")
q3_2019 <- read_csv("Divvy_Trips_2019_Q3.csv")
q4_2019 <- read_csv("Divvy_Trips_2019_Q4.csv")
q1_2020 <- read_csv("Divvy_Trips_2020_Q1.csv")


#=====================
# PREVIEW DATAFRAMES
#=====================

skim_without_charts(q1_2020) #dyplr
glimpse(q1_2020) #dyplr
head(q1_2020)
q1_2020 %>%
  select(rideable_type) # Only view the specified columns in the dataframe from dyplr
# OR
table(q1_2020$rideable_type)



#====================================================
# WRANGLE DATA AND COMBINE INTO A SINGLE FILE
#====================================================

# Compare column names each of the files
# The names need to match perfectly before we can use the bind_rows command to join them into one file
colnames(q3_2019)
colnames(q4_2019)
colnames(q2_2019)
colnames(q1_2020)

# Rename columns to make them consistent with q1_2020 (this is the most recent table design) from the tidyverse package and *dyplr* library

(q4_2019 <- rename(q4_2019
                   ,ride_id = trip_id
                   ,rideable_type = bikeid 
                   ,started_at = start_time  
                   ,ended_at = end_time  
                   ,start_station_name = from_station_name 
                   ,start_station_id = from_station_id 
                   ,end_station_name = to_station_name 
                   ,end_station_id = to_station_id 
                   ,member_casual = usertype))

(q3_2019 <- rename(q3_2019
                   ,ride_id = trip_id
                   ,rideable_type = bikeid 
                   ,started_at = start_time  
                   ,ended_at = end_time  
                   ,start_station_name = from_station_name 
                   ,start_station_id = from_station_id 
                   ,end_station_name = to_station_name 
                   ,end_station_id = to_station_id 
                   ,member_casual = usertype))

(q2_2019 <- rename(q2_2019
                   ,ride_id = "01 - Rental Details Rental ID"
                   ,rideable_type = "01 - Rental Details Bike ID" 
                   ,started_at = "01 - Rental Details Local Start Time"  
                   ,ended_at = "01 - Rental Details Local End Time"  
                   ,start_station_name = "03 - Rental Start Station Name" 
                   ,start_station_id = "03 - Rental Start Station ID"
                   ,end_station_name = "02 - Rental End Station Name" 
                   ,end_station_id = "02 - Rental End Station ID"
                   ,member_casual = "User Type"))


# Check and clean column names post rename for characters, numbers, and underscores only with clean_names from the *janitor* package
clean_names(q2_2019)
clean_names(q3_2019)
clean_names(q4_2019)
clean_names(q1_2020)


# Inspect the dataframes and look for incongruencies
str(q1_2020)
str(q4_2019)
str(q3_2019)
str(q2_2019)


# Convert ride_id and rideable_type to character using mutate from the dyplr library so that they can stack correctly in the new dataframe
q4_2019 <-  mutate(q4_2019, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type)) 
q3_2019 <-  mutate(q3_2019, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type)) 
q2_2019 <-  mutate(q2_2019, ride_id = as.character(ride_id)



# Stack individual quarter's data frames into one big data frame using bind_rows from tidyverse package and dyplr library
all_trips <- bind_rows(q2_2019, q3_2019, q4_2019, q1_2020)


# Check structure of new table
colnames(all_trips)
str(all_trips)
tibble(all_trips)


# Remove birthyear, tripduration, and gender fields as this data was dropped beginning in 2020
all_trips <- all_trips %>%  
  select(-c( birthyear, gender, "01 - Rental Details Duration In Seconds Uncapped", "05 - Member Details Member Birthday Year", "Member Gender", "tripduration"))


# Check structure of new table
glimpse(all_trips)
colnames(all_trips)
str(all_trips)
tibble(all_trips)




#======================================================
# CLEAN UP AND ADD DATA TO PREPARE FOR ANALYSIS
#======================================================



# Inspect the new table that has been created
clean_names(all_trips) # Clean column names post rename for characters, numbers, and underscores only with clean_names from the *janitor* package
colnames(all_trips)  # List of column names
nrow(all_trips)  # How many rows are in data frame?
dim(all_trips)  # Dimensions of the data frame?
head(all_trips)  # See the first 6 rows of data frame
str(all_trips)  # See list of columns and data types (numeric, character, etc)
summary(all_trips)  # Statistical summary of data. Mainly for numeric values


# There are a few issues to address:

# In the "member_casual" column, there are two names for members ("member" and "Subscriber") and two names for casual riders ("Customer" and "casual"). We will consolidate that from four to two labels and use the same structure as  q1_2020.
# The data can only be aggregated at the ride-level, which is very granular. We need to add some additional columns of data -- such as day, month, year -- that we can derive from "started_at" and "ended_at", to provide additional opportunities to aggregate the data for analysis.
# We will want to add a calculated field for length of ride since the q1_2020 data did not have the "tripduration" column. We will add "ride_length" to the entire dataframe for consistency using "started_at" and "ended_at".
# There are some rides where tripduration shows up as negative, including several hundred rides where we are making the asumption that Divvy took bikes out of circulation for Quality Assurance reasons. We will want to delete these rides.
# In the "member_casual" column, replace "Subscriber" with "member", and "Customer" with "casual"
# Before 2020, Divvy used different labels for these two types of riders ... we will want to make our dataframe consistent with their current nomenclature
# N.B.: "Level" is a special property of a column that is retained even if a subset does not contain any values from a specific level

# Begin by seeing how many observations fall under each usertype
table(all_trips$member_casual)

# Reassign to the desired values (using the q1_2020 labels)
all_trips <-  all_trips %>% 
  mutate(member_casual = recode(member_casual
                                ,"Subscriber" = "member"
                                ,"Customer" = "casual"))

# Verify that the proper number of observations were reassigned
table(all_trips$member_casual)

# Add columns that list the date, month, day, year, and hour of each ride
# This will allow us to aggregate ride data for each month, day, or year
all_trips$date <- as.Date(all_trips$started_at) #The default format is yyyy-mm-dd
tibble(all_trips$date)
all_trips$month <- format(as.Date(all_trips$date), "%m")
head(all_trips$month)
all_trips$day <- format(as.Date(all_trips$date), "%d")
glimpse(all_trips$day)
all_trips$year <- format(as.Date(all_trips$date), "%Y")
head(all_trips$year)
all_trips$day_of_week <- format(as.Date(all_trips$date), "%A")
glimpse(all_trips$day_of_week)
all_trips$hour_of_day <- hour(all_trips$started_at)
head(all_trips$hour_of_day)



# Add a "ride_length" calculation to all_trips (in seconds)
all_trips$ride_length <- difftime(all_trips$ended_at,all_trips$started_at)

# Inspect the structure of the columns
str(all_trips)

# Convert "ride_length" from Factor to numeric to run calculations on the data
is.factor(all_trips$ride_length)
all_trips$ride_length <- as.numeric(as.character(all_trips$ride_length))
is.numeric(all_trips$ride_length)

# Remove "incomplete/bad" data
# The dataframe includes a few hundred entries when bikes were taken out of docks and checked for quality by Divvy or ride_length was negative
# Create a new version of the dataframe (v2) since data is being removed/dropped
all_trips_v2 <- all_trips[!(all_trips$start_station_name == "HQ QR" | all_trips$ride_length<0),]


#=====================================
# CONDUCT DESCRIPTIVE ANALYSIS
#=====================================



# Summary Statistics/Descriptive analysis on ride_length (all figures in seconds)
mean(all_trips_v2$ride_length) #average (total ride length / rides)
median(all_trips_v2$ride_length) #midpoint number in the ascending array of ride lengths
max(all_trips_v2$ride_length) #longest ride
min(all_trips_v2$ride_length) #shortest ride

# Alternatively, use summary() on the specific attribute
summary(all_trips_v2$ride_length)

# Compare members and casual users
all_trips_v2 %>% group_by(member_casual) %>% summarize(mean_ride_length = mean(ride_length))
all_trips_v2 %>% group_by(member_casual) %>% summarize(mode_ride_length = mode(ride_length))
all_trips_v2 %>% group_by(member_casual) %>% summarize(max_ride_length = max(ride_length))
all_trips_v2 %>% group_by(member_casual) %>% summarize(min_ride_length = min(ride_length))

all_trips_v2 %>% group_by(member_casual) %>% summarize(mean_ride_length = mean(ride_length)
                                                       ,mode_ride_length = mode(ride_length)
                                                       ,max_ride_length = max(ride_length)
                                                       ,min_ride_length = min(ride_length))

# Observe the average ride time by each day for members vs casual users
all_trips_v2 %>% group_by(member_casual, day_of_week) %>% summarize(mean_ride_length = mean(ride_length))

# Order the days of the week
all_trips_v2$day_of_week <- ordered(all_trips_v2$day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

# Observe the average ride time by each day for members vs casual users with ordered week
all_trips_v2 %>% group_by(member_casual, day_of_week) %>% summarize(mean_ride_length = mean(ride_length))

# analyze ridership data by type and weekday
all_trips_v2 %>% 
  group_by(member_casual, day_of_week) %>%                #groups by usertype and weekday
  summarize(number_of_rides = n()					            		#calculates the number of rides and average duration 
            ,avg_ride_length = mean(ride_length)) %>% 		# calculates the average duration
  arrange(member_casual, day_of_week)							      	# sorts

# analyze riders by time of day
all_trips_v2 %>% 
  group_by(member_casual, hour_of_day) %>% 
  summarize(number_of_rides = n()
            ,avg_ride_length = mean(ride_length)) %>% 
  arrange(member_casual, hour_of_day)
  
# Viz for the number of rides by rider type - bar
all_trips_v2 %>% 
  group_by(member_casual, day_of_week) %>% 
  summarize(number_of_rides = n()
            ,avg_ride_length = mean(ride_length)) %>% 
  arrange(member_casual, day_of_week)  %>% 
  ggplot(aes(x = day_of_week, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge")

# Viz for the avg ride length - bar
all_trips_v2 %>% 
  group_by(member_casual, day_of_week) %>% 
  summarize(number_of_rides = n()
            ,avg_ride_length = mean(ride_length)) %>% 
  arrange(member_casual, day_of_week)  %>% 
  ggplot(aes(x = day_of_week, y = avg_ride_length, fill = member_casual)) +
  geom_col(position = "dodge")

# Viz for number of riders by rider type and hour of day - bar
all_trips_v2 %>% 
  group_by(member_casual, hour_of_day) %>% 
  summarize(number_of_rides = n()
            ,avg_ride_length = mean(ride_length)) %>% 
  arrange(member_casual, hour_of_day) %>% 
  ggplot(aes(x = hour_of_day, y = number_of_rides, fill = member_casual)) + 
  geom_col(position = "dodge")

# Viz by seasonality - bar
all_trips_v2 %>% 
  group_by(member_casual, month) %>% 
  summarize(number_of_rides = n()
            ,avg_ride_length = mean(ride_length)) %>% 
  arrange(member_casual, month) %>% 
  ggplot(aes(x = month, y = number_of_rides, fill = member_casual)) + 
  geom_col(position = "dodge")

ggplot(data = all_trips_v2) +
  geom_point(mapping = aes(x = month, y = ride_length))

#=================================================
# STEP 5: EXPORT SUMMARY FILE FOR FURTHER ANALYSIS
#=================================================
# Create a csv file
write_csv(x = all_trips_v2, "C:/Users/darryl.nichols/Documents/R/R Projects/Cyclistic Bike Sharing/all_trips_v2.csv")


