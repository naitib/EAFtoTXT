# Filemname: loadEAF.R
# Description:  processes EAF file for txt output, helper for app.R
# Author: Naiti Bhatt

# load packages
library(tidyverse)
library(here)
library(magick)
library(readr)
library(phonfieldwork)

# input: EAF filename as string
# output: processed tibble with relevant categories for output txt
processEAF <- function(filename) {
  #load eaf as tibble
  df <- as_tibble(eaf_to_df(filename))
  
  # add higher level tier and fix time information (units and add time elapsed)
  d_processed <- df %>% 
    mutate(super_tier = case_when(
      str_detect(tier_name, "CHI") ~ "CHI",
      str_detect(tier_name, "MA1") ~ "MA1",
      str_detect(tier_name, "FA1") ~ "FA1"
    )) %>% 
    mutate(time_start = time_start*1000,
           time_end = time_end*1000,
           time_elapsed = time_end-time_start)
  
  # make output df look like txt file, select relevant rows and arrange to make it look better
  d_output <- d_processed %>% 
    select(tier_name, super_tier, time_start, time_end, time_elapsed, content) %>% 
    arrange(tier_name)
  
  return(d_output)
}
