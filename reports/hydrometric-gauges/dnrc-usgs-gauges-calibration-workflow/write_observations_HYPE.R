# Milk-St Mary River Watershed Project
# This script finds the intersection coordinates between the watershed shapefile 
# and streamflow gauges (hydat and USGS) within the watershed and writes rvt files
# Written by Madeline Tucker
# Last updated 2023-11-02

library(tidyverse)
library(sf)
library(tidyhydat)
library(dataRetrieval)
library(lubridate)
library(RColorBrewer)
library(RavenR)
library(xts)
library(readr)
library(dplyr)
library(RSQLite)


# read in naturalized USGS gauge files
# first read in csv with a summary of all gauge file names
nat_summary <- read.csv("../../tables/naturalized_flows_summary.csv")
nat_summary$subbasin_id <- as.numeric(nat_summary$subbasin_id)
nat_summary$USGS_code <- as.numeric(nat_summary$USGS_code)


lapply(unique(nat_summary$subbasin_id),function(sbid){
  df = read_csv(paste0("../../inputs/nat_gauges/",nat_summary$filename[nat_summary$subbasin_id==sbid],"")) # read in DNRC naturalized flow data
  
  #check make real date format in case excel messed up auto date file
  df <- df %>%
    mutate(Date = as.Date(paste(Year, Month, Day, sep = '-')),
           Flow = Flow*0.0283168, # convert from ft3/s to m3/s
           Flow = ifelse(is.na(Flow), -9999, Flow)) # replace NA flows with -1.2345 as per Raven manual
  
  # read in USGS measured data for each naturalized gauge
  if (sbid==113884){
    # pg. 21 of the natural flow report mentions that for RKCMO, measured data was based on gauge 06169500 instead of gauge 06171000
    USGS <- read.csv(paste0('../../inputs/nat_gauges/USGS/06169500.csv')) 
  }else if (sbid==113827){
    # pg. 13 of the natural flow report mentions that for BCBMO, measured data was based on gauge 06166000 instead of gauge 06167500
    USGS <- read.csv(paste0('../../inputs/nat_gauges/USGS/06166000.csv'))
  }else{
    USGS <- read.csv(paste0('../../inputs/nat_gauges/USGS/0',nat_summary$USGS_code[nat_summary$subbasin_id %in% sbid],'.csv'))
  }
  USGS$DATE <- as.Date(USGS$DATE) # change date object type
  
  # filter DNRC gauge data by USGS period of record
  df_mod <- df %>%
    filter(Date %in% USGS$DATE)
  
  # remove DNRC gauges that do not overlap with USGS data period
  if (nrow(df_mod)==0){
    rm(df_mod)
  }else{
    if (df_mod$Date[nrow(df_mod)]==as.Date("2015-12-31")){ # check to see if the Raven simulation period is complete
      df_mod <-  df_mod
    }else{
      df_mod <-  df_mod %>%
        add_row(Date=as.Date("2015-12-31"),Year=2015,Month=12,Day=31,Flow=NA) # add last date of Raven simulation to end of dataframe
    }
    
    # infill data gaps with NA values
    df_mod_infill <- xts(df_mod$Flow, order.by=df_mod$Date) # convert dataframe to timeseries object
    df_mod_infill <- rvn_ts_infill(df_mod_infill) # use RavenR package to assign NA values for data gaps
    
    if (sbid==114119){ # NFKMR gauge has winter values set to zero
      df_mod_infill <- replace(df_mod_infill,df_mod_infill==0,-9999) # replace winter zero values with -1.2345
      df_mod_infill[is.na(df_mod_infill)] <- -9999 # replace NA flows with -9999 as per Raven manual
    }else{
      df_mod_infill[is.na(df_mod_infill)] <- -9999 # replace NA flows with -9999 as per Raven manual
    } 
    
    # write rvt files
    fc = file(paste0('../../HYPE_nat/0',nat_summary$USGS_code[nat_summary$subbasin_id==sbid],'.txt'), open = "w+") # open file connection, "w+" = write and append
    hours = '00:00:00'
    timestep = 1
    N = length(df_mod$Flow) # number of observations
    
    writeLines(paste0("date ",'flow(m3/s)'),fc)

    
    # Convert the time index to "YYYY-MM-DD" format
    time_index <- format(index(df_mod_infill), "%Y-%m-%d")
    
    # Write time index and values in the ts column to file
    write.table(cbind(time_index, coredata(df_mod_infill)), file = fc, sep = "\t", col.names = FALSE, row.names = FALSE, quote = FALSE, append = TRUE)
    
    close(fc) # close file connection
  }
})


