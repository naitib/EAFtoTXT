# Filemname: loadEAF.R
# Description: functionally processes EAF
# Author: Naiti Bhatt

# load packages
library(tidyverse)
library(here)
library(magick)
library(readr)
library(phonfieldwork)

# input: EAF filename as string
# output: none, writes txt file

processEAF <- function(filename) {
  #load eaf as tibble
  df <- as_tibble(eaf_to_df(filename))
  
  # add higher level tier and fix time information
  d_processed <- d %>% 
    mutate(super_tier = case_when(
      str_detect(tier_name, "CHI") ~ "CHI",
      str_detect(tier_name, "MA1") ~ "MA1",
      str_detect(tier_name, "FA1") ~ "FA1"
    )) %>% 
    mutate(time_start = time_start*1000,
           time_end = time_end*1000,
           time_elapsed = time_end-time_start)
  
  # make output df look like txt file, select relevant rows and arrange
  d_output <- d_processed %>% 
    select(tier_name, super_tier, time_start, time_end, time_elapsed, content) %>% 
    arrange(tier_name)
  
  write.table(d_output, "out.txt", sep="\t", row.names=FALSE, col.names = FALSE, quote=FALSE)
}