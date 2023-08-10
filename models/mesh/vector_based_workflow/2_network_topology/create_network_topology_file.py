#!/usr/bin/env python
# coding: utf-8

# # Create Network Topology

# The network topology file will contain geophysical parameters such as unique indices of stream segments, routing parameters – such as channel length, slope, and basin area – and other required information from the catchment and river network shapefiles for the domain of interest.

# ### Load Modules

# In[1]:


import os
import pandas as pd
import netCDF4 as nc4
import geopandas as gpd
import numpy as np
import xarray as xs
from   pathlib import Path
from   shutil import copyfile
from   datetime import datetime
import warnings


# ### Control File Handling
# The purpose of the control file is to provide all inputs to the scripts in the vector-based workflow to eliminate the need to alter the workflow scripts themselves. The following cells will retrieve settings from 'control_active.txt' and provide them as inputs to this script.

# ##### Access to the control file folder

# In[2]:


controlFolder = Path('../0_control_files')


# ##### Store the name of the 'active' file in a variable

# In[3]:


controlFile = 'control_active.txt'


# ##### Function to extract a given setting from the control file

# In[4]:


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


# ##### Function to specify a default path

# In[5]:


def make_default_path(suffix):
     
    # Get the root path
    rootPath = Path( read_from_control(controlFolder/controlFile,'root_path') )
     
    # Specify the forcing path
    #defaultPath = rootPath / domainFolder / suffix
    defaultPath = rootPath / suffix 
    return defaultPath


# ##### Get the domain folder

# In[6]:


domain_name = read_from_control(controlFolder/controlFile,'domain_name')
domainFolder = 'domain_' + domain_name


# ##### Find location of river network shapefile

# In[7]:


river_network_path = read_from_control(controlFolder/controlFile,'river_network_shp_path')
river_network_name = read_from_control(controlFolder/controlFile,'river_network_shp_name')
 
# Specify default path if needed
if river_network_path == 'default':
    river_network_path = make_default_path('shapefiles/river_network/') # outputs a Path()
else:
    river_network_path = Path(river_network_path) # make sure a user-specified path is a Path()


# ##### Find location of river basin shapefile

# In[8]:


river_basin_path = read_from_control(controlFolder/controlFile,'river_basin_shp_path')
river_basin_name = read_from_control(controlFolder/controlFile,'river_basin_shp_name')
 
#Specify default path if needed
if river_basin_path == 'default':
    river_basin_path = make_default_path('shapefiles/catchment/') # outputs a Path()
else:
    river_basin_path = Path(river_basin_path) # make sure a user-specified path is a Path()


# ##### Find where the topology file needs to go

# In[9]:


topology_path = read_from_control(controlFolder/controlFile,'settings_routing_path')
topology_name = read_from_control(controlFolder/controlFile,'settings_routing_topology')
 
#Specify default path if needed
if topology_path == 'default':
    topology_path = make_default_path('vector_based_workflow/workflow_data/domain_'+domain_name+'/topology/') # outputs a Path()
else:
    topology_path = Path(topology_path) # make sure a user-specified path is a Path()

# Make the folder if it doesn't exist
topology_path.mkdir(parents=True, exist_ok=True)


# ##### Find the field names we're after

# In[10]:


basin_hru_id     = read_from_control(controlFolder/controlFile,'river_basin_shp_rm_hruid')
basin_hru_area   = read_from_control(controlFolder/controlFile,'river_basin_shp_area')
basin_hru_to_seg = read_from_control(controlFolder/controlFile,'river_basin_shp_hru_to_seg')
river_seg_id      = read_from_control(controlFolder/controlFile,'river_network_shp_segid')
river_down_seg_id = read_from_control(controlFolder/controlFile,'river_network_shp_downsegid')
river_slope       = read_from_control(controlFolder/controlFile,'river_network_shp_slope')
river_length      = read_from_control(controlFolder/controlFile,'river_network_shp_length')
include_IAK       = read_from_control(controlFolder/controlFile,'include_IAK')
river_order       = read_from_control(controlFolder/controlFile,'river_order')

# Added by MESH workflow
try:
    river_outlet_id   = float(read_from_control(controlFolder/controlFile,'river_network_shp_outlet_id'))
except ValueError:
    print ('The ID of the most downstream segment was not found')
    river_outlet_id = []


# ### Make the river network topology file

# ##### Open the shapefile

# In[11]:


shp_river = gpd.read_file(river_network_path/river_network_name)
shp_basin = gpd.read_file(river_basin_path/river_basin_name)


# ##### Sort basin to be consistent with river
# ###### *Added by MESH workflow*

# In[12]:


shp_basin = shp_basin.sort_values(by=basin_hru_id)


# ##### Convert area to m<sup>2</sup>
# ###### *Note: if area unit is already based on m<sup>2</sup>, it is not requried to covert m<sup>2</sup>*

# In[13]:


# shp_basin[basin_hru_area].values[:] = shp_basin[basin_hru_area].values[:]*10**6


# ##### Covert river_length to m
# ###### *Note: if length unit is already based on m, it is not requried to covert m*

# In[14]:


# shp_river[river_length].values[:]   = shp_river[river_length].values[:]*1000


# ##### Adding centroid of each subbasin
# ###### *Note: Use equal area projection for more accuracy*

# In[15]:


warnings.simplefilter('ignore') # silent the warning
shp_basin['lon'] = shp_basin.centroid.x
shp_basin['lat'] = shp_basin.centroid.y
warnings.simplefilter('default') # back to normal


# ##### Specifying other variables
# ###### *Note: the river width and manning is optional. The manning coefficient is specified in the MESH hydrology configuration file*

# In[16]:


shp_river['width']   = 50
shp_river['manning'] = 0.03


# ##### Find the number of segments and subbasins

# In[17]:


num_seg = len(shp_river)
num_hru = len(shp_basin)


# ##### Ensure the most downstream segment in the river network has a downstream_ID of 0
# This indicates to routing that this segment has no downstream segment attached to it
# ###### *Modified by MESH workflow*

# In[18]:


if (np.size(river_outlet_id)!= 0):
    shp_river.loc[shp_river[river_seg_id] == river_outlet_id, river_down_seg_id] = 0


# ##### Function to create new nc variables

# In[19]:


def create_and_fill_nc_var(ncid, var_name, var_type, dim, fill_val, fill_data, long_name, units):
     
    # Make the variable
    ncvar = ncid.createVariable(var_name, var_type, (dim,), fill_val)
     
    # Add the data
    ncvar[:] = fill_data   
     
    # Add meta data
    ncvar.long_name = long_name
    ncvar.unit = units
     
    return


# ### Taking care of Non-contributing areas

# In[20]:


# finding basins without a river network - Non-contributing areas
missing_seg = shp_basin[~shp_basin[river_seg_id].isin(shp_river[river_seg_id])]
missing_ids = missing_seg[basin_hru_id]
last_seg_id = shp_river[river_seg_id].astype(int).max()


# In[21]:


# assinging fictitious ids to river segements of NCA basins in the `shp_basin`
missing_seg_ids = range(last_seg_id + 1, last_seg_id + len(missing_ids) + 1)
shp_basin.loc[shp_basin[basin_hru_id].isin(missing_ids), river_seg_id] = missing_seg_ids


# In[22]:


# creating fictitious ids for river segments of the NCA basins in the `shp_river`
cols = shp_river.columns.to_list()
fict_seg = pd.DataFrame(data=[[0]*len(cols)]*len(missing_ids), columns=cols)
fict_seg[river_seg_id] = missing_seg_ids
shp_river = gpd.GeoDataFrame(pd.concat([shp_river, fict_seg]))


# In[23]:


# update num_seg
num_seg = len(shp_river[river_seg_id])


# ### Make the netcdf file

# In[26]:


with nc4.Dataset(topology_path/topology_name, 'w', format='NETCDF4') as ncid:
     
    # Set general attributes
    now = datetime.now()
    ncid.setncattr('Author', "Created by MESH vector-based workflow scripts")
    ncid.setncattr('History','Created ' + now.strftime('%Y/%m/%d %H:%M:%S'))
    ncid.setncattr('Purpose','Create a river network .nc file for WATROUTE routing')
     
    # Define the seg and hru dimensions
    # it can be renamed to 'subbasin'
    # Modified by MESH workflow
    ncid.createDimension('n', num_seg)
    # ncid.createDimension('hru', num_hru)
    # finished edit by MESH workflow
 
    # --- Variables
    # renaming variable and adding lat, lon, manning and width
    # Modified by MESH workflow                       
    create_and_fill_nc_var(ncid, 'seg_id', 'int', 'n', False,                            np.ndarray.round(shp_river[river_seg_id].values.astype(int)),                            'Unique ID of each stream segment', '-')                       
    # Modified by MESH workflow 
    create_and_fill_nc_var(ncid, 'tosegment', 'int', 'n', False,                            np.ndarray.round(shp_river[river_down_seg_id].values.astype(int)),                            'ID of the downstream segment', '-')
    create_and_fill_nc_var(ncid, 'slope', 'f8', 'n', False,                            shp_river[river_slope].values.astype(float),                            'Segment slope', '-')  
    # added by MESH workflow
    create_and_fill_nc_var(ncid, 'lon', 'f8', 'n', False,                            shp_basin['lon'].values.astype(float),                            'longitude', '-')     
    create_and_fill_nc_var(ncid, 'lat', 'f8', 'n', False,                            shp_basin['lat'].values.astype(float),                            'latitude', '-')
    # finished edit by MESH workflow  
    create_and_fill_nc_var(ncid, 'length', 'f8', 'n', False,                            shp_river[river_length].values.astype(float),                            'Segment length', 'm')
    create_and_fill_nc_var(ncid, 'hruid', 'int', 'n', False,                            shp_basin[basin_hru_id].values.astype(int),                            'Unique hru ID', '-')
    create_and_fill_nc_var(ncid, 'seg_hr_id', 'int', 'n', False,                            shp_basin[basin_hru_to_seg].values.astype(int),                            'ID of the stream segment to which the HRU discharges', '-')
    create_and_fill_nc_var(ncid, 'basin_area', 'f8', 'n', False,                            shp_basin[basin_hru_area].values.astype(float),                            'HRU area', 'm^2')   
    # added by MESH workflow
    create_and_fill_nc_var(ncid, 'width', 'f8', 'n', False,                            shp_river['width'].values.astype(float),                            'width', 'm')                      
    create_and_fill_nc_var(ncid, 'manning', 'f8', 'n', False,                            shp_river['manning'].values.astype(float),                            'manning', '-')
    if include_IAK == 'True':
        create_and_fill_nc_var(ncid, 'IAK', 'int', 'n', False,                             shp_river[river_order].values.astype(int),                             'River Order', '-')
    # finished edit by MESH workflow


# ### Code provenance
# Generates a basic log file in the domain folder and copies the control file and itself there.
# 

# In[28]:


# Set the log path and file name
logPath = topology_path
log_suffix = '_make_river_network_topology.txt'
 
# Create a log folder
logFolder = '_workflow_log'
Path( logPath / logFolder ).mkdir(parents=True, exist_ok=True)
 
# Copy this script
thisFile = 'create_network_topology.ipynb'
copyfile(thisFile, logPath / logFolder / thisFile);
 
# Get current date and time
now = datetime.now()
 
# Create a log file
logFile = now.strftime('%Y%m%d') + log_suffix
with open( logPath / logFolder / logFile, 'w') as file:
     
    lines = ['Log generated by ' + thisFile + ' on ' + now.strftime('%Y/%m/%d %H:%M:%S') + '\n',
             'Generated network topology .nc file.']
    for txt in lines:
        file.write(txt)

