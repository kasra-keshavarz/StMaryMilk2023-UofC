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
# 
# # set working directory
#setwd("C:/Users/mgtucker/Documents/GitHub/SMM_Raven_hydro/")
# 
# # Extract stations within watershed boundary ------------------------------
# # read in watershed boundary and subbasin shapefiles and convert to simple feature
# # change directories as required
# x <- read_sf("Shapefiles/SMM_outer_Boundary.shp") %>% st_transform(.,crs=4326) # outer boundary shapefile
# x1 <- read_sf("Shapefiles/smm_subbasins.shp") %>% st_transform(.,crs=4326) # subbasins shapefile
# 
# # create bounding box for shapefile - these coordinates are required to pull USGS stations
# bounding_box <- as.numeric(st_bbox(x,crs=4326))
# 
# # pull active hydat stations
# # uncomment next line and change pathway first time running this script
# #download_hydat(dl_hydat_here = "Shapefiles/hydat")
# stations_hydat <- as.data.frame(hy_stations(hydat_path = "Shapefiles/hydat/Hydat.sqlite3"))%>%
#   filter(HYD_STATUS == "ACTIVE") 
# 
# # pull USGS gauges within watershed bounding box
# # use dataRetrieval::parameterCdFile to see list of available USGS parameter codes
# # streamflow parameter codes are used here
# # note: bBox coordinates are the same as the object "bounding_box" but function did not work
# # using the variable name - manual entry of coordinates as shown is required.
# sampling_location <- c("ST","ST-CA","ST-DCH","LK","SP")
# stations_USGS <- dataRetrieval::whatNWISsites(bBox=c(-113.7738,47.8015,-106.0970,49.7392),parameterCd=c("00059","00060","00061"))%>%
#   filter(site_tp_cd %in% sampling_location)
# 
# # create USGS gauge data frame selecting site number, lat, and lon and create new column for source
# USGS_bind <- stations_USGS %>%  
#   select(c("site_no","dec_lat_va","dec_long_va"))%>%
#   mutate(source="USGS")
# names(USGS_bind) = c("STATION_NUMBER","LATITUDE","LONGITUDE","SOURCE") # rename columns
# 
# # create new data frame containing all gauges within bounding box
# stations <- stations_hydat %>%
#   select(c("STATION_NUMBER","LATITUDE","LONGITUDE")) %>%
#   mutate(SOURCE="hydat")%>%
#   rbind(USGS_bind)
# stations <- sf::st_as_sf(stations,coords=c("LONGITUDE","LATITUDE"),crs=4326)
# rm(USGS_bind)
# 
# # intersect watershed boundary with station points - keep gauge points within watershed boundary
# stations_int <- st_intersection(stations,x,crs=4326)
# stations_int <- st_intersection(stations_int,x1,crs=4326)
# 
# # clean up data frames
# rm(stations)
# rm(stations_hydat)
# rm(stations_USGS)
# gc()
# 
# # write intersected station points as a shapefile
# st_write(stations_int,"Shapefiles/output/stations.shp", crs=4326)
# 
# # Pull data for each station ----------------------------------------------
# hydat_data <- tidyhydat::hy_daily_flows(stations_int$STATION_NUMBER[stations_int$SOURCE=="hydat"])
# USGS_data <- readNWISdv(stations_int$STATION_NUMBER[stations_int$SOURCE=="USGS"], parameterCd = "00060")
# USGS_data <- renameNWISColumns(USGS_data)
# 
# # create single data frame containing all stations from all sources and corresponding data
# USGS_bind <- USGS_data %>%
#   select(c('site_no','Date','Flow'))%>%
#   mutate(source="USGS")
# names(USGS_bind) = c('STATION_NUMBER','DATE','VALUE','SOURCE') # rename columns
# USGS_bind$VALUE <- USGS_bind$VALUE*0.0283168
# 
# hydat_bind <- hydat_data %>%
#   select(c('STATION_NUMBER','Date','Value'))%>%
#   mutate(source='hydat')
# names(hydat_bind) <- c('STATION_NUMBER','DATE','VALUE','SOURCE') # rename columns
# 
# all_data <- rbind(hydat_bind,USGS_bind) 
# 
# # determine which subbasins have more than one gauge
# stations_multiples <- readxl::read_xlsx("Input/multiple_stations_in_subbasins.xlsx") # excel sheet created in ArcGIS
# stations_multiples$STATION <-  as.character(stations_multiples$STATION)
# stations_subset <- stations_int %>%
#   filter(STATION_NUMBER %in% stations_multiples$STATION)%>%
#   select(STATION_NUMBER,SOURCE,hru_nhm,hru_id,geometry)
# 
# # append drainage area to data frame for sorting
# stations_subset$DRAINAGE_AREA = 0
# pb = txtProgressBar(min=0,max=nrow(stations_subset),style=3)
# 
# # hydat drainage area is in km^2, USGS drainage area is in mi^2
# for(i in 1:nrow(stations_subset)){
#   setTxtProgressBar(pb,i)
#   if(stations_subset$SOURCE[i]!='USGS'){
#     stations_subset$DRAINAGE_AREA[i] = hy_stations(station_number=stations_subset$STATION_NUMBER[i])%>%select(.,DRAINAGE_AREA_GROSS)%>%
#       as.numeric()
#   }else{
#     stations_subset$DRAINAGE_AREA[i] = readNWISsite(stations_subset$STATION_NUMBER[i]) %>% select(.,drain_area_va)%>%
#       as.numeric()
#     stations_subset$DRAINAGE_AREA[i] = stations_subset$DRAINAGE_AREA[i]*2.589 # conversion from mi^2 to km^2
#   }
# }
# close(pb)
# 
# # add drainage areas to data frame
# all_data$DRAINAGE_AREA <- stations_subset$DRAINAGE_AREA[match(all_data$STATION_NUMBER,stations_subset$STATION_NUMBER)]
# 
# # remove unnecessary data
# rm(hydat_data)
# rm(USGS_data)
# rm(hydat_bind)
# rm(USGS_bind)
# 
# # Record plots ------------------------------------------------------------
# # assess data availability based on number of years of observations 
# source = 'USGS' # change source to either hydat or USGS
# 
# if(source=='hydat'){
#   data_years <- all_data %>%
#     filter(SOURCE=='hydat') %>%
#     mutate(YEAR = year(DATE)) %>%
#     select(c("STATION_NUMBER","YEAR","VALUE","SOURCE"))%>%
#     group_by(STATION_NUMBER) %>%
#     summarise("YEAR"=unique(YEAR),"Mean"=mean(VALUE,na.rm=TRUE))
#   #filter(YEAR>=1980)
# }else{
#   data_years <- all_data %>%
#     filter(SOURCE=='USGS') %>%
#     mutate(YEAR = year(DATE)) %>%
#     select(c("STATION_NUMBER","YEAR","VALUE","SOURCE"))%>%
#     group_by(STATION_NUMBER) %>%
#     summarise("YEAR"=unique(YEAR),"Mean"=mean(VALUE,na.rm=TRUE))
#   #filter(YEAR>=1980)
# }
# 
# # plot data availability by station
# ggplot(data=data_years)+
#   geom_point(aes(x=YEAR,y=STATION_NUMBER,color=Mean),size=3,shape=15)+
#   ggtitle('Station Record Periods', subtitle = paste0(source, ' gauges'))+ylab("Station Number")+
#   theme_bw()+ scale_color_continuous(name=bquote("Record-average flow ("~m^3~"/s)"),low = "#56B4E9", high = "#D55E00")+
#   theme(plot.title=element_text(hjust=0.5),plot.subtitle=element_text(hjust = 0.5),legend.position="bottom")
# 
# # condense data frame to count by year
# condensed_count = data_years %>% ungroup() %>% group_by(Year) %>% count() %>% mutate(type="stream gauges")
# ggplot(condensed_count,aes(x=YEAR,y=type,color=n))+
#   geom_point(shape=15,size=3)+
#   theme_bw()+scale_color_viridis_b()+
#   ggtitle('Station record density by year',subtitle=paste0(source, ' gauges'))+
#   theme(plot.title=element_text(hjust=0.5),plot.subtitle=element_text(hjust = 0.5),
#         legend.position="bottom",axis.title.y=element_blank())
# 
# # Gauge station drainage area comparison ------------------------------------------------
# # compare drainage areas in cases where multiple stations are in a single subbasin
# stations_na <- stations_subset[is.na(stations_subset$DRAINAGE_AREA),]
# stations_compare <- stations_subset[!is.na(stations_subset$DRAINAGE_AREA),]
# 
# stations_compare <- do.call(rbind,lapply(unique(stations_compare$hru_nhm),function(hid){
#   selection = stations_compare[stations_compare$hru_nhm == hid,] # drainage areas with common subbasins
#   stations_compare = selection[selection$DRAINAGE_AREA == max(selection$DRAINAGE_AREA),]
#   return(stations_compare)
# }))
# 
# st_write(stations_compare,"Shapefiles/output/stations_compare.shp", crs=4326)
# st_write(stations_na,"Shapefiles/output/stations_na.shp", crs=4326)
# 
# # read in filtered gauge points after comparing drainage areas and removing multiple gauges within subbasins
# # for filtering criteria and methodology, see write-up
# stations_filtered <- read_sf("Shapefiles/output/stations_filtered_2.shp") %>% st_transform(.,crs=4326)%>%
#   select(c('STATION','SOURCE','hru_nhm','hru_id'))
# names(stations_filtered) <- c('STATION_NUMBER','SOURCE','hru_nhm','hru_id','geometry')
# 
# # Write rvt files ---------------------------------------------------------
# # filter data to include data from 1980 and onward
# data_filter <- all_data %>%  
#   filter(DATE>=as.Date('1980-01-01'))
# data_filter <- data_filter[data_filter$STATION_NUMBER %in% stations_filtered$STATION_NUMBER,]
# data_filter$VALUE[is.na(data_filter$VALUE)] <- -1.2345 # replace NA flows with -1.2345 as per Raven manual
# 
# # create text file for redirect to file names
# fc = file(paste0('Scripts/Output/redirect.rvt'), open = "w+")
# writeLines(paste0(":RedirectToFile obs/st_",stations_filtered$STATION_NUMBER,'.rvt'),fc,sep='\n')
# close(fc) # close file connection
# 
# # create rvt files
# lapply(unique(stations_filtered$STATION_NUMBER), function(sid){
#   if ('hydat' %in% stations_filtered$SOURCE[stations_filtered$STATION_NUMBER==sid]==TRUE){
#     fc = file(paste0('Scripts/Output/hydat/st_',sid,'.rvt'), open = "w+") # open file connection, "w+" = write and append
#     hours = '00:00:00'
#     timestep = 1
#     N = length(data_filter$VALUE[grep(sid,data_filter$STATION_NUMBER)]) # number of observations
#     
#     writeLines(paste0(":ObservationData HYDROGRAPH ",stations_filtered$hru_nhm[grep(sid,stations_filtered$STATION_NUMBER)],' m3/s'),fc)
#     writeLines(paste(data_filter$DATE[grep(sid, data_filter$STATION_NUMBER)][1],hours,timestep,N),fc)
#     writeLines(paste0(data_filter$VALUE[grep(sid,data_filter$STATION_NUMBER)]),fc,sep='\n')
#     writeLines(':EndObservationData', fc,sep='\n')
#     
#     close(fc) # close file connection
#     
#   }else{
#     fc = file(paste0('Scripts/Output/USGS/st_',sid,'.rvt'), open = "w+") # open file connection, "w+" = write and append
#     hours = '00:00:00'
#     timestep = 1
#     N = length(data_filter$VALUE[grep(sid,data_filter$STATION_NUMBER)]) # number of observations
#     
#     writeLines(paste0(":ObservationData HYDROGRAPH ",stations_filtered$hru_nhm[grep(sid,stations_filtered$STATION_NUMBER)],' ft3/s'),fc)
#     writeLines(paste(data_filter$DATE[grep(sid, data_filter$STATION_NUMBER)][1],hours,timestep,N),fc)
#     writeLines(paste0(data_filter$VALUE[grep(sid,data_filter$STATION_NUMBER)]),fc,sep='\n')
#     writeLines(':EndObservationData', fc,sep='\n')
#     
#     close(fc) # close file connection
#   }
# })
# 
# # naturalized flow rvt files using naturalized flow data provided by Prabin
# # eastern gauge = 11AA031, western gauge = 11AA025, IB (International Boundary) gauge = 11AA001, milkR gauge = 11AA005
# nat_gauges <- readxl::read_excel("Scripts/Input/Milk_R_Nat_Flows_Eastern_Crossing.xlsx",sheet='Milk_R_at_Eastern_Crossing',
#                                  range='D5:D21555', col_names=TRUE) %>% as.data.frame()
# nat_gauges$eastern <- readxl::read_xlsx("Scripts/Input/Milk_R_Nat_Flows_Eastern_Crossing.xlsx",sheet='Milk_R_at_Eastern_Crossing',
#                                         range='G6:G21555', col_names = FALSE)%>% unlist() %>% as.vector()
# nat_gauges$western <- readxl::read_xlsx("Scripts/Input/Milk_R_Nat_Flows_Eastern_Crossing.xlsx",sheet='Milk_R_at_Western_Crossing',
#                                         range='B7:B21556', col_names = FALSE)%>% unlist() %>% as.vector()
# nat_gauges$IB <- readxl::read_xlsx("Scripts/Input/Milk_R_Nat_Flows_Eastern_Crossing.xlsx",sheet='NF_Milk_R_at_IB',
#                                    range='B7:B21556', col_names = FALSE)%>% unlist() %>% as.vector()
# 
# nat_gauges$milkR <- all_data$VALUE[all_data$STATION_NUMBER %in% '11AA005' & all_data$DATE >= as.Date('1959-01-01')&
#                                      all_data$DATE <= as.Date('2017-12-31')]
# 
# # convert units from ft3/s to m3/s
# nat_gauges$eastern <-nat_gauges$eastern*0.0283168
# nat_gauges$western <- nat_gauges$western*0.0283168
# nat_gauges$IB <- nat_gauges$IB*0.0283168
# 
# # specify subbasins for each gauge
# nat_subbasin <- as.data.frame(c(stations_int$hru_nhm[stations_int$STATION_NUMBER %in% '11AA031'],
#                                 stations_int$hru_nhm[stations_int$STATION_NUMBER %in% '11AA025'],
#                                 stations_int$hru_nhm[stations_int$STATION_NUMBER %in% '11AA001'],
#                                 stations_int$hru_nhm[stations_int$STATION_NUMBER %in% '11AA005']))
# nat_subbasin$location <-  c('eastern','western','IB','milkR')
# nat_subbasin$gauge <- c('11AA031','11AA025','11AA001','11AA005')
# names(nat_subbasin) <- c('subbasin','location','gauge')
# 
# # format data frame
# nat_gauges_long <- nat_gauges %>%
#   pivot_longer(c(eastern,western,IB,milkR), names_to = 'location',values_to = 'flow') %>%
#   cbind('subbasin' = nat_subbasin$subbasin)%>%
#   cbind('gauge' = nat_subbasin$gauge)
# nat_gauges_long$Date = as.Date(nat_gauges_long$Date)
# 
# 
# # write rvt files for hydat naturalized gauges
# lapply(unique(nat_gauges_long$gauge), function(sid){
#   fc = file(paste0('Scripts/Output/naturalized/st_',sid,'.rvt'), open = "w+") # open file connection, "w+" = write and append
#   hours = '00:00:00'
#   timestep = 1
#   N = length(nat_gauges_long$flow[grep(sid,nat_gauges_long$gauge)]) # number of observations
#   
#   writeLines(paste0(":ObservationData HYDROGRAPH ",unique(nat_gauges_long$subbasin[grep(sid,nat_gauges_long$gauge)]),' m3/s'),fc)
#   writeLines(paste(nat_gauges_long$Date[grep(sid, nat_gauges_long$gauge)][1],hours,timestep,N),fc)
#   writeLines(paste0(nat_gauges_long$flow[grep(sid,nat_gauges_long$gauge)]),fc,sep='\n')
#   writeLines(':EndObservationData', fc,sep='\n')
#   
#   close(fc) # close file connection
# })



############################################3
#JWT generalize to run across all project
# read in naturalized USGS gauge files
# first read in csv with a summary of all gauge file names
nat_summary <- read.csv("../../tables/naturalized_flows_summary.csv")
nat_summary$subbasin_id <- as.numeric(nat_summary$subbasin_id)
nat_summary$USGS_code <- as.numeric(nat_summary$USGS_code)
nat_summary

# MGT edits: add USGS measured data
#load("./measured_data.RData")
# 
# # write csv file that contains USGS data for selected DNRC gauges
#lapply(paste0("0",unique(nat_summary$USGS_code)),function(sid){
#all_data <- all_data[all_data$STATION_NUMBER %in% sid,]
# write.csv(all_data, paste0('../../inputs/nat_gauges/USGS/',sid,'.csv'))
#})
#all_data
# loop through flow gauge files and write rvts
lapply(unique(nat_summary$subbasin_id),function(sbid){
  df = read_csv(paste0("../../inputs/nat_gauges/",nat_summary$filename[nat_summary$subbasin_id==sbid],"")) # read in DNRC naturalized flow data
  
  #check make real date format in case excel messed up auto date file
  df <- df %>%
    mutate(Date = as.Date(paste(Year, Month, Day, sep = '-')),
           Flow = Flow*0.0283168, # convert from ft3/s to m3/s
           Flow = ifelse(is.na(Flow), -1.2345, Flow)) # replace NA flows with -1.2345 as per Raven manual
  
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
      df_mod_infill <- replace(df_mod_infill,df_mod_infill==0,-1.2345) # replace winter zero values with -1.2345
      df_mod_infill[is.na(df_mod_infill)] <- -1.2345 # replace NA flows with -1.2345 as per Raven manual
    }else{
      df_mod_infill[is.na(df_mod_infill)] <- -1.2345 # replace NA flows with -1.2345 as per Raven manual
    } 
    
    # write rvt files
    fc = file(paste0('../../model/obs/naturalized/st_0',nat_summary$USGS_code[nat_summary$subbasin_id==sbid],'.rvt'), open = "w+") # open file connection, "w+" = write and append
    hours = '00:00:00'
    timestep = 1
    N = length(df_mod$Flow) # number of observations
    
    writeLines(paste0(":ObservationData HYDROGRAPH ",unique(sbid),' m3/s'),fc)
    writeLines(paste(df_mod$Date[1],hours,timestep,N),fc)
    writeLines(paste0(df_mod_infill),fc,sep='\n')
    writeLines(':EndObservationData', fc,sep='\n')
    
    close(fc) # close file connection
  }
})

# redirect file
#not using, just leave in main rvt
#fc = file(paste0('model/redirect.rvt'), open = "w+")
#writeLines(paste0(":RedirectToFile obs/naturalized/st_0",nat_summary$USGS_code,'.rvt'),fc,sep='\n')
#close(fc) # close file connection
###################################################################

# write rvt files for diversion gauges (St.Marys Canal)
# first read in diversion gauges
diversions <- read_sf("Shapefiles/output/stations_diversions.shp") %>% st_transform(.,crs=4326)%>%
  select(c('STATION','SOURCE','hru_nhm','hru_id'))
names(diversions) <- c('STATION_NUMBER','SOURCE','hru_nhm','hru_id','geometry')

# prepare data frames 
diversion_ids <- c('05018000','05019000','05018500') # St.Mary Canal diversions
diversions_subset <- diversions[diversions$STATION_NUMBER %in% diversion_ids,]
diversions_data <- all_data[all_data$STATION_NUMBER %in% diversion_ids,] %>%
  filter(DATE>=as.Date('1980-01-01')& DATE<=as.Date('2017-12-31'))%>%
  mutate('VALUE_NEG'= VALUE*-1*0.0283168)
diversions_data$VALUE = diversions_data$VALUE*0.0283168 # convert from ft3/s to m3/s
diversions_data$VALUE[is.na(diversions_data$VALUE)] <- -1.2345 # replace NA flows with -1.2345 as per Raven manual
diversions_data$VALUE_NEG[is.na(diversions_data$VALUE)] <- -1.2345 # replace NA flows with -1.2345 as per Raven manual

# identify subbasin that receives the diverted water
outflow_sbid <- '113510' # subbasin at start of diversion where water leaves the stream network
inflow_sbid <- '114128' # subbasin at end of St.Mary Canal where diversion water enters Milk River

# write rvt files to remove flows from subbasin 113510 and add flows to subbasin 114128
# remove flows using gauge 05018000
sid = '05018000'
fc = file(paste0('Scripts/Output/diversions/st_',sid,'out.rvt'), open = "w+") # open file connection, "w+" = write and append
hours = '00:00:00'
timestep = 1
N = length(diversions_data$VALUE_NEG[grep(sid,diversions_data$STATION_NUMBER)]) # number of observations

writeLines(paste0(":BasinInflowHydrograph2 ",outflow_sbid),fc)
writeLines(paste(diversions_data$DATE[grep(sid, diversions_data$STATION_NUMBER)][1],hours,timestep,N),fc)
writeLines(paste0(diversions_data$VALUE_NEG[grep(sid,diversions_data$STATION_NUMBER)]),fc,sep='\n')
writeLines(':EndBasinInflowHydrograph2', fc,sep='\n')
close(fc) # close file connection

# add flows using gauge 05018000
sid = '05018000'
fc = file(paste0('Scripts/Output/diversions/st_',sid,'in.rvt'), open = "w+") # open file connection, "w+" = write and append
hours = '00:00:00'
timestep = 1
N = length(diversions_data$VALUE[grep(sid,diversions_data$STATION_NUMBER)]) # number of observations

writeLines(paste0(":BasinInflowHydrograph2 ",inflow_sbid),fc)
writeLines(paste(diversions_data$DATE[grep(sid, diversions_data$STATION_NUMBER)][1],hours,timestep,N),fc)
writeLines(paste0(diversions_data$VALUE[grep(sid,diversions_data$STATION_NUMBER)]),fc,sep='\n')
writeLines(':EndBasinInflowHydrograph2', fc,sep='\n')
close(fc) # close file connection


# List all flow gauge stations --------------------------------------------
# remove stations in stations_int that were discarded
stations_final <- stations_int[!(stations_int$STATION_NUMBER %in% stations_subset$STATION_NUMBER),] %>%
  select(c('STATION_NUMBER','SOURCE','hru_nhm','hru_id'))%>%
  rbind(stations_filtered)%>%
  rbind(diversions)

# create station flags
naturalized_gauges <- c('11AA031','11AA025','11AA001','11AA005',paste0('0',nat_summary$USGS_code))

stations_final$CLASSIFICATION <- do.call('rbind',lapply(1:nrow(stations_final),function(i){
  if(stations_final$STATION_NUMBER[i] %in% naturalized_gauges==TRUE){
    x = 'naturalized'
  }else if(stations_final$STATION_NUMBER[i] %in% diversions$STATION_NUMBER==TRUE){
    x = 'diversion'
  }else{
    x = 'non-reference'
  }
  return(x)
}))

stations_final$CLASSIFICATION = as.vector(stations_final$CLASSIFICATION)

# write finalized stations as shapefile
st_write(stations_final,"Shapefiles/output/stations_final.shp", crs=4326)

