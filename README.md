Untangling strings (\#@%\*!!)
================
Erika Duan
2022-01-02

-   [Case Study](##The Case Study Scenario as provided by Google/Coursera)
-   [Creating a test dataset](#creating-a-test-dataset)
-   [Introduction to regular
    expressions](#introduction-to-regular-expressions)
    -   [Match characters](#match-characters)
    -   [Character anchors](#character-anchors)
    -   [Character classes and
        groupings](#character-classes-and-groupings)
    -   [Greedy versus lazy matches](#greedy-versus-lazy-matches)
    -   [Look arounds](#look-arounds)
-   [Improving comment field
    readability](#improving-comment-field-readability)
-   [Extracting topics of interest](#extracting-topics-of-interest)
-   [Extracting a machine learning friendly
    dataset](#extracting-a-machine-learning-friendly-dataset)
-   [Differences between base R and `stringr`
    functions](#differences-between-base-r-and-stringr-functions)
-   [Other resources](#other-resources)


## The Case Study Scenario as provided by Google/Coursera

"You are a data analyst working in the marketing analyst team at Cyclistic, a bike-share company in Chicago. The director of marketing believes the company’s future success depends on maximizing the number of annual memberships. Therefore, your team wants to understand how casual riders and annual members use Cyclistic bikes differently. From these insights, your team will design a new marketing strategy to convert casual riders into annual members. But first, Cyclistic executives must approve your recommendations, so they must be backed up with compelling data insights and professional data visualizations."


## Phase 1: Ask Questions to Make Data-Driven Decisions


Three questions will guide the future marketing program:
1. How do annual members and casual riders use Cyclistic bikes differently?
2. Why would casual riders buy Cyclistic annual memberships?
3. How can Cyclistic use digital media to influence casual riders to become members?


I have been assigned the first question to answer. 


Action Steps: Collaborate with stakeholders to define the business problem, establish communication preferences, view context of the problem, and establish expectations. Agree on Scope of Work.

Ask SMART Questions to develop business task and Scope of Work:

* Specific
* Measurable
* Action-Oriented
* Relevant
* Time-Bound


Business Task: How do annual members and casual riders use Cyclistic bikes differently?



## Phase 2: Prepare Data for Exploration



Action steps: Decide what data is necessary to address business task, locate the data, create any security measures to protect the data, and decide on key metrics to use when completing the business task.


Does the data ROCCC? Is the data...

* Reliable - At a glance, our data seems to unbiased and complete.
* Original - We are assuming that we (Cyclistic) have collected our own data and is First Party data.
* Comprehensive - The data contains information we need to answer the business question.
* Current- Yes. The data is from December 2021.
* Cited - This data is made available from Motivate International



* Download data and store it appropriately - Files were originally contained in zip files, then saved as .csv files. See *Collect Data*
* Identity how the data is organized - Data is organized into long data, observe data types and metadata, structure. See *Preview Data*
* Sort and filter data - there are many 00:00:00 (HH:MM:SS) values as well as negative values - more on the implications of this in the analyze phase.
* Determine the credibility of the data - as outlined above, this data ROCCC's.


#### Install required packages/Load Libraries
 

install.packages("tidyverse")
install.packages("lubridate")
install.packages("ggplot")
install.packages("skimr")
install.packages("janitor")

getwd()             #displays the working directory
setwd(...)        #sets the working directory to simplify calls to data

``` {r}
library(tidyverse)  # helps transform/clean data
library(lubridate)  # helps wrangle/parse date attributes
library(ggplot2)    # helps visualize data
library(readr)      #
library(skimr)      #
library(janitor)    #
library(dplyr)      #

```





#### COLLECT DATA

Upload Divvy datasets (csv files) here from the tidyverse package and readr library

```{r}
q2_2019 <- read_csv("Divvy_Trips_2019_Q2.csv")
q3_2019 <- read_csv("Divvy_Trips_2019_Q3.csv")
q4_2019 <- read_csv("Divvy_Trips_2019_Q4.csv")
q1_2020 <- read_csv("Divvy_Trips_2020_Q1.csv")
```




#### PREVIEW DATAFRAMES


Replace the file and column names as desired to preview all 4 dataframes.
```{r}
skim_without_charts(q3_2019) #dyplr
glimpse(q3_2019) #dyplr
head(q3_2019)
q3_2019 %>%
  select(trip_id) # Only view the specified columns in the dataframe from dyplr
# OR
tibble(q3_2019$trip_id)
```



## Phase 3: Process Data from Dirty to Clean



Action steps: Decide what tools to use for analysis, ensure data integrity, clean data, document cleaning, and verify that data is ready for analysis.

* Choose tools for cleaning - using R because it can handle large amounts of data in file, comes with useful cleaning packages.
* Check the data for errors - looking for duplicate data, inconsistent data types, incomplete data, and inaccurate/incorrect data
* Transform data - checking for spelling errors, changing the case of text, and remove unnecessary spaces/trim.
* Document cleaning process - documented using R Markdown



#### PREPARE DATA AND COMBINE INTO A SINGLE FILE


Compare column names each of the files
The names need to match perfectly before using the bind_rows command to join them into one file

```{r}
colnames(q3_2019)
colnames(q4_2019)
colnames(q2_2019)
colnames(q1_2020)
```


#### Rename columns to make them consistent with q1_2020 (this is the most recent table design) from the tidyverse package and *dyplr* library


```{r}
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
```


              
```{r}
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
```



```{r}
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
```


#### Check and clean column names post rename for characters, numbers, and underscores only with clean_names from the *janitor* package
```{r}
clean_names(q2_2019)
clean_names(q3_2019)
clean_names(q4_2019)
clean_names(q1_2020)
```



#### Inspect the dataframes and look for incongruencies
```{r}
str(q1_2020)
str(q4_2019)
str(q3_2019)
str(q2_2019)
```



#### Convert ride_id and rideable_type to character using mutate from the dyplr library so that they can stack correctly in the new dataframe
```{r}
q4_2019 <-  mutate(q4_2019, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type)) 
q3_2019 <-  mutate(q3_2019, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type)) 
q2_2019 <-  mutate(q2_2019, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type)) 
```


#### Stack individual quarter's data frames into one big data frame using bind_rows from tidyverse package and dyplr library
```{r}
all_trips <- bind_rows(q2_2019, q3_2019, q4_2019, q1_2020)
```


#### Check structure of new table
```{r}
colnames(all_trips)
str(all_trips)
tibble(all_trips)
```



#### Remove birthyear, tripduration, and gender fields as this data was dropped beginning in 2020
```{r}
all_trips <- all_trips %>%  
  select(-c( birthyear, gender, "01 - Rental Details Duration In Seconds Uncapped", "05 - Member Details Member Birthday Year", "Member Gender", "tripduration"))
```


#### Inspect the new table that has been created

```{r}
clean_names(all_trips) # Clean column names post rename for characters, numbers, and underscores only with clean_names from the *janitor* package
colnames(all_trips)  # List of column names
nrow(all_trips)  # How many rows are in data frame?
dim(all_trips)  # Dimensions of the data frame?
head(all_trips)  # See the first 6 rows of data frame
str(all_trips)  # See list of columns and data types (numeric, character, etc)
summary(all_trips)  # Statistical summary of data. Mainly for numeric values
```


#### Issues to address regarding the new dataframe:

In the "member_casual" column, there are two names for members ("member" and "Subscriber") and two names for casual riders ("Customer" and "casual"). I will consolidate the data from four to two labels and use the same structure as q1_2020, by replacing "Subscriber" with "member", and "Customer" with "casual".
In order to complete the business task effectively and compare members and casual riders, I need to add some additional columns of data (day, month, year, hour) that I can derive from "started_at" and "ended_at", to provide additional opportunities to aggregate the data for analysis.
I will add a column for length of ride since the q1_2020 data did not have the "tripduration" column. For consistency, I will add "ride_length" to the entire dataframe, using "started_at" and "ended_at".
There are some rides where tripduration shows up as negative, including several hundred rides where I am making the assumption that Divvy took bikes out of circulation for Quality Assurance reasons. I will delete these rides in our new file.


#### Preview how many observations fall under each usertype
```{r}
table(all_trips$member_casual)
```


#### Reassign to the desired values (using the q1_2020 labels)
```{r}
all_trips <-  all_trips %>% 
  mutate(member_casual = recode(member_casual
                                ,"Subscriber" = "member"
                                ,"Customer" = "casual"))
```


#### Verify that the proper number of observations were reassigned
```{r}
table(all_trips$member_casual)
```


#### Add columns that list the date, month, day, year, and hour of each ride
#### This will allow us to aggregate ride data for each month, day, or year
```{r}
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
```


#### Add a "ride_length" calculation to all_trips (in seconds)
```{r}
all_trips$ride_length <- difftime(all_trips$ended_at,all_trips$started_at)
```


#### Inspect the structure of the columns
```{r}
str(all_trips)
```


#### Convert "ride_length" from Factor to numeric to run calculations on the data
```{r}
is.factor(all_trips$ride_length)
all_trips$ride_length <- as.numeric(as.character(all_trips$ride_length))
is.numeric(all_trips$ride_length)
```


#### Remove "incomplete/bad" data
#### The dataframe includes a few hundred entries when bikes were taken out of docks and checked for quality by Divvy or ride_length was negative
#### Create a new version of the dataframe (v2) since data is being removed/dropped
```{r}
all_trips_v2 <- all_trips[!(all_trips$start_station_name == "HQ QR" | all_trips$ride_length<0),]
```



## Phase 4: Analyze Data to Answer Questions

#### Summary Statistics/Descriptive analysis on ride_length (all figures in seconds)
```{r}
mean(all_trips_v2$ride_length) #average (total ride length / rides)
median(all_trips_v2$ride_length) #midpoint number in the ascending array of ride lengths
max(all_trips_v2$ride_length) #longest ride
min(all_trips_v2$ride_length) #shortest ride
```

#### Alternatively, use summary() on the specific attribute
```{r}
summary(all_trips_v2$ride_length)
```

#### Compare members and casual users
```{r}
all_trips_v2 %>% group_by(member_casual) %>% summarize(mean_ride_length = mean(ride_length))
all_trips_v2 %>% group_by(member_casual) %>% summarize(mode_ride_length = mode(ride_length))
all_trips_v2 %>% group_by(member_casual) %>% summarize(max_ride_length = max(ride_length))
all_trips_v2 %>% group_by(member_casual) %>% summarize(min_ride_length = min(ride_length))
```

OR


```{r}
all_trips_v2 %>% group_by(member_casual) %>% summarize(mean_ride_length = mean(ride_length)
                                                       ,mode_ride_length = mode(ride_length)
                                                       ,max_ride_length = max(ride_length)
                                                       ,min_ride_length = min(ride_length))
```


#### Observe the average ride time by each day for members vs casual users
```{r}
all_trips_v2 %>% group_by(member_casual, day_of_week) %>% summarize(mean_ride_length = mean(ride_length))
```


#### Order the days of the week
```{r}
all_trips_v2$day_of_week <- ordered(all_trips_v2$day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
```


#### Observe the average ride time by each day for members vs casual users with ordered week
```{r}
all_trips_v2 %>% group_by(member_casual, day_of_week) %>% summarize(mean_ride_length = mean(ride_length))
```

#### analyze ridership data by type and weekday
```{r}
all_trips_v2 %>% 
  group_by(member_casual, day_of_week) %>%                #groups by usertype and weekday
  summarize(number_of_rides = n()					            		#calculates the number of rides and average duration 
            ,avg_ride_length = mean(ride_length)) %>% 		# calculates the average duration
  arrange(member_casual, day_of_week)							      	# sorts
```


#### analyze riders by time of day
```{r}
all_trips_v2 %>% 
  group_by(member_casual, hour_of_day) %>% 
  summarize(number_of_rides = n()
            ,avg_ride_length = mean(ride_length)) %>% 
  arrange(member_casual, hour_of_day)
```

#### Viz for the number of rides by rider type - bar
```{r}
all_trips_v2 %>% 
  group_by(member_casual, day_of_week) %>% 
  summarize(number_of_rides = n()
            ,avg_ride_length = mean(ride_length)) %>% 
  arrange(member_casual, day_of_week)  %>% 
  ggplot(aes(x = day_of_week, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge")
```



#### Viz for the avg ride length - bar
```{r}
all_trips_v2 %>% 
  group_by(member_casual, day_of_week) %>% 
  summarize(number_of_rides = n()
            ,avg_ride_length = mean(ride_length)) %>% 
  arrange(member_casual, day_of_week)  %>% 
  ggplot(aes(x = day_of_week, y = avg_ride_length, fill = member_casual)) +
  geom_col(position = "dodge")
  
```



#### Viz for number of riders by rider type and hour of day - bar

``` {r}
all_trips_v2 %>% 
  group_by(member_casual, hour_of_day) %>% 
  summarize(number_of_rides = n()
            ,avg_ride_length = mean(ride_length)) %>% 
  arrange(member_casual, hour_of_day) %>% 
  ggplot(aes(x = hour_of_day, y = number_of_rides, fill = member_casual)) + 
  geom_col(position = "dodge")

```


#### Viz by seasonality - bar
```{r}
all_trips_v2 %>% 
  group_by(member_casual, month) %>% 
  summarize(number_of_rides = n()
            ,avg_ride_length = mean(ride_length)) %>% 
  arrange(member_casual, month) %>% 
  ggplot(aes(x = month, y = number_of_rides, fill = member_casual)) + 
  geom_col(position = "dodge")
```


## EXPORT CSV FILE FOR FURTHER ANALYSIS/SHARE PHASE IN TABLEAU
Create a csv file





