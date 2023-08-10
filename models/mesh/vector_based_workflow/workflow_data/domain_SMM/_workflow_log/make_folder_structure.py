#!/usr/bin/env python
# coding: utf-8

'''
MESH workflow: make folder structure
Makes the initial folder structure for a given control file. All other files in the workflow will look for the file `control_active.txt` during their execution. This script:
This script is adapted from the SUMMA workflow https://github.com/CH-Earth/CWARHM

1. Copies the specified control file into `control_active.txt`;
2. Prepares a folder structure using the settings in `control_active.txt`.
3. Creates a copy of itself to be stored in the new folder structure.

The destination folders are referred to as "domain folders".
'''

# Specify the control file to use
sourceFile  = 'control_SMM.txt'

# --- Do not change below this line.

# Modules
import os
from pathlib import Path
from shutil import copyfile
from datetime import datetime

# Easy access to control file folder
controlFolder = Path('../0_control_files')

# Store the name of the 'active' file in a variable
controlFile = 'control_active.txt'

copyfile( controlFolder/sourceFile, controlFolder/controlFile )

# --- Create the main domain folders
# Function to extract a given setting from the control file
def read_from_control( file, setting ):
    
    # Open 'control_active.txt' and ...
    with open(file) as contents:
        for line in contents:
            
            # ... find the line with the requested setting
            if setting in line and not line.startswith('#'):
                break
    
    # Extract the setting's value
    substring = line.split('|',1)[1]      # Remove the setting's name (split into 2 based on '|', keep only 2nd part)
    substring = substring.split('#',1)[0] # Remove comments, does nothing if no '#' is found
    substring = substring.strip()         # Remove leading and trailing whitespace, tabs, newlines
       
    # Return this value    
    return substring
    
# Find the path where the domain folders need to go
# Immediately store as a 'Path' to avoid issues with '/' and '\' on different operating systems
rootPath = Path( read_from_control(controlFolder/controlFile,'root_path') )

# Find the domain name
domainName = read_from_control(controlFolder/controlFile,'domain_name')

# Get the domain folder
domainFolder = 'domain_' + domainName


# --- Make the shapefile folders
# Find the catchment shapefile folder in 'control_active'
networkShapeFolder = read_from_control(controlFolder/controlFile,'river_network_shp_path')
riverBasinFolder =  read_from_control(controlFolder/controlFile,'river_basin_shp_path')

# Specify the default paths if required
if riverBasinFolder == 'default':
    riverBasinFolder = 'shapefiles/catchment'
if networkShapeFolder == 'default':
    networkShapeFolder = 'shapefiles/river_network'

# Try to make the shapefile folders; does nothing if the folder already exists
Path( rootPath / networkShapeFolder).mkdir(parents=True, exist_ok=True)
Path( rootPath / riverBasinFolder ).mkdir(parents=True, exist_ok=True)


# --- Make the simulation folders
# find the simulation folder in 'control_active'
simulationFolder = read_from_control(controlFolder/controlFile,'simulation_path')
#Specify the default path if required
if simulationFolder == 'default':
    simulationFolder = 'simulations'
#Try to make the simulation file folder; does nothing if the folder already exists
Path( rootPath / 'vector_based_workflow/workflow_data' / domainFolder / simulationFolder ).mkdir(parents=True, exist_ok=True)


# --- Make the visualization folder
# find the visualization folder in 'control_active'
visualizationFolder = read_from_control(controlFolder/controlFile,'visualization_folder')
#Specify the default path if required
if visualizationFolder == 'default':
    visualizationFolder = 'visualizations'
#Try to make the visualization file folder; does nothing if the folder already exists
Path( rootPath / 'vector_based_workflow/workflow_data' / domainFolder / visualizationFolder ).mkdir(parents=True, exist_ok=True)

# --- Make the forcing folder
# find the forcing folder in 'control_active'
forcingFolder = read_from_control(controlFolder/controlFile,'source_nc_path')
#Specify the default path if required
if forcingFolder == 'default':
    forcingFolder = 'forcing'
#Try to make the forcing file folder; does nothing if the folder already exists
Path( rootPath / forcingFolder ).mkdir(parents=True, exist_ok=True)

# --- Make the installs folder
installsFolder = read_from_control(controlFolder/controlFile,'install_path_MESH')
if installsFolder == 'default':
    installsFolder = 'installs'
Path( rootPath / installsFolder ).mkdir(parents=True, exist_ok=True)

# --- Make the parameter folders
# find the parameter folders in 'control_active'
drainageDatabaseFolder  = read_from_control(controlFolder/controlFile,'DDB_output_dir')
networkTopologyFolder   = read_from_control(controlFolder/controlFile,'settings_routing_path')
zonalStatisticsFolder   = read_from_control(controlFolder/controlFile,'input_lc_zh_path')

#Specify the default paths if required
if drainageDatabaseFolder   == 'default':
    drainageDatabaseFolder = 'drainagedatabase'
if networkTopologyFolder    == 'default':
    networkTopologyFolder   = 'topology'
if zonalStatisticsFolder    == 'default':
    zonalStatisticsFolder   = 'zonalhist'



#Try to make the parameter file folders; does nothing if the folder already exists
Path( rootPath / 'vector_based_workflow/workflow_data' / domainFolder / drainageDatabaseFolder  ).mkdir(parents=True, exist_ok=True)
Path( rootPath / 'vector_based_workflow/workflow_data' / domainFolder / networkTopologyFolder   ).mkdir(parents=True, exist_ok=True)
Path( rootPath / 'vector_based_workflow/workflow_data' / domainFolder / zonalStatisticsFolder   ).mkdir(parents=True, exist_ok=True)


# --- Code provenance
# Generates a basic log file in the domain folder and copies the control file and itself there.
# Create a log folder
logFolder = '_workflow_log'
Path( rootPath / 'vector_based_workflow/workflow_data' / domainFolder / logFolder ).mkdir(parents=True, exist_ok=True)

# Create a log folder
logFolder = '_workflow_log'
Path( rootPath / 'vector_based_workflow/workflow_data' / domainFolder / logFolder ).mkdir(parents=True, exist_ok=True)

# Copy this script
thisFile = 'make_folder_structure.py'
copyfile(thisFile, rootPath / 'vector_based_workflow/workflow_data' / domainFolder / logFolder / thisFile);

# Get current date and time
now = datetime.now()

# Create a log file 
logFile = now.strftime('%Y%m%d') + '_log.txt'
with open(rootPath / 'vector_based_workflow/workflow_data' / domainFolder / logFolder / logFile, 'w') as file:
    
    lines = ['Log generated by ' + thisFile + ' on ' + now.strftime('%Y/%m/%d %H:%M:%S') + '\n',
             'Generated folder structure using ' + sourceFile]
    for txt in lines:
        file.write(txt)  
