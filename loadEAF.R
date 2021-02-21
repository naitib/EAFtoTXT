# Filemname: loadEAF.R
# Description: loads EAF into tibble, processes, outputs txtfile
# Author: Naiti Bhatt

# load packages
library(tidyverse)
library(here)
library(magick)
library(readr)
library(phonfieldwork)


# read in eaf file
df <- eaf_to_df("5959-0GS0.eaf")

# convert to tibble
d <- as_tibble(df)

# add in higher level tier
d_processed <- d %>% 
  mutate(super_tier = case_when(
    str_detect(tier_name, "CHI") ~ "CHI",
    str_detect(tier_name, "MA1") ~ "MA1",
    str_detect(tier_name, "FA1") ~ "FA1"
  ))

# add in add time elapsed, fix units of time
d_processed <- d_processed %>% 
  mutate(time_start = time_start*1000,
            time_end = time_end*1000,
         time_elapsed = time_end-time_start)

# make output df look like txt file, select relevant rows and arrange
d_output <- d_processed %>% 
  select(tier_name, super_tier, time_start, time_end, time_elapsed, content) %>% 
  arrange(tier_name)

write.table(d_output, "out.txt", sep="\t", row.names=FALSE, col.names = FALSE, quote=FALSE)


