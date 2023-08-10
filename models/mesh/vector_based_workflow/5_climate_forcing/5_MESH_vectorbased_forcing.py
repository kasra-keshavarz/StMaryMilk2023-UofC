#!/usr/bin/env python
# coding: utf-8

# # EASYMORE Basin Subset
# EASYMORE: EArth SYstem MOdeling REmapper is a collection of functions that allows extraction of the data from a NetCDF file for a given shapefile such as a basin, catchment, points or lines. It can map gridded data or model output to any given shapefile and provide area average for a target variable.
# https://github.com/ShervanGharari/EASYMORE
# 
# ## Climate Forcing Reordering
# The purpose of this script is to extract vector-based forcing files remapped from easymore and reorder them based rank, then save them to a netcdf format that can be read by MESH model
# 
# #### **Programmer**
# Ala Bahrami
# 
# #### **Revision History**
# 2021/05/13 -- (1) Initial version created and posted online<br>
# 2022/06/26 -- (1) Instead of reading the shape file, the MeritHydro subbasin metadata is read as an input for reindexing forcing.<br> 
# 2022/06/26 -- (2) Changed variable names to match RDRSV2.1<br>
# 
# #### **See Also**
# easymore_extarct, create_MESH_drainage_database

# ### Loading Modules

# In[1]:


import numpy as np
import xarray as xs
import time 
from shutil import copyfile
from datetime import datetime
from pathlib import Path
import netCDF4


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


# ##### Get additional settings

# In[7]:


dataset     =  read_from_control(controlFolder/controlFile,'forcing_dataset')
startTime   = read_from_control(controlFolder/controlFile,'forcing_start')


# ##### Defining inputs

# In[8]:


forcing_dir  = Path(read_from_control(controlFolder/controlFile,'remapping_out'))
if forcing_dir == 'default':
    forcing_dir = Path(make_default_path('forcing')) # outputs a Path()
    
forcing_dataset = read_from_control(controlFolder/controlFile,'forcing_dataset')
forcing_name = '{}_{}_remapped_{}_unitchange.nc'.format(dataset,domain_name,startTime)
ddb_folder   = read_from_control(controlFolder/controlFile,'DDB_output_dir')
if ddb_folder == 'default':
    ddb_folder = make_default_path('vector_based_workflow/workflow_data/domain_{}/drainagedatabase'.format(domain_name)) # outputs a Path()


# ##### Reading input basin 
# *the segids are stored in the remapped forcing, so it is not necessary to read input shape file*

# ##### Reading the drainage database

# In[9]:


start_time = time.time()
db = xs.open_dataset(ddb_folder / '{}_MESH_drainage_database.nc'.format(domain_name))
db.close()
segid =  db.variables['hruid'].values
# reading for control check 
lon = db.variables['lon'].values
lat = db.variables['lat'].values


# ##### Reading the input forcing

# In[12]:


forc = xs.open_dataset(forcing_dir / forcing_name)
forc.close()
lon_ease = forc.variables['longitude'].values
lat_ease = forc.variables['latitude'].values


# ##### Extract indices of forcing ids based on the drainage database

# In[13]:


n = len(segid)
ind = []

for i in range(n):
    fid = np.where(np.int32(forc['ID'].values) == segid[i])[0]
    ind = np.append(ind, fid)

ind = np.int32(ind) 


# ##### Reorder input forcing
# ###### *Note : name of variables is hard coded and can be modified regarding the input forcing*

# In[14]:


forc_vec = xs.Dataset(
    {
        "RDRS_v2.1_A_PR0_SFC": (["subbasin", "time"], forc['RDRS_v2.1_A_PR0_SFC'].values[:,ind].transpose()),
    },
    coords={
        "time": forc['time'].values.copy(),
        "lon": (["subbasin"], lon),
        "lat": (["subbasin"], lat),
    }
    )

forc_vec['RDRS_v2.1_A_PR0_SFC'].encoding['coordinates'] = 'time lon lat'
forc_vec['RDRS_v2.1_A_PR0_SFC'].attrs["units"]          = forc['RDRS_v2.1_A_PR0_SFC'].units
forc_vec['RDRS_v2.1_A_PR0_SFC'].attrs["grid_mapping"]   = 'crs'

for n in ['RDRS_v2.1_P_FI_SFC','RDRS_v2.1_P_FB_SFC','RDRS_v2.1_P_TT_09944',
          'RDRS_v2.1_P_UVC_09944','RDRS_v2.1_P_P0_SFC','RDRS_v2.1_P_HU_09944']:
    forc_vec[n] = (("subbasin", "time"), forc[n].values[: , ind].transpose()) 
    forc_vec[n].coords["time"]          = forc['time'].values.copy()
    forc_vec[n].coords["lon"]           = (["subbasin"], lon)
    forc_vec[n].coords["lat"]           = (["subbasin"], lat)
    forc_vec[n].attrs["units"]          = forc[n].units
    forc_vec[n].attrs["grid_mapping"]   = 'crs'
    forc_vec[n].encoding['coordinates'] = 'time lon lat'

# %% update meta data attribuetes 
forc_vec.attrs['Conventions'] = 'CF-1.6'
forc_vec.attrs['License']     = 'The data were written by Ala Bahrami'
forc_vec.attrs['history']     = 'Created on June 07, 2021'
forc_vec.attrs['featureType'] = 'timeSeries'          

# editing lat attribute
forc_vec['lat'].attrs['standard_name'] = 'latitude'
forc_vec['lat'].attrs['units']         = 'degrees_north'
forc_vec['lat'].attrs['axis']          = 'Y'
 
# editing lon attribute
forc_vec['lon'].attrs['standard_name'] = 'longitude'
forc_vec['lon'].attrs['units']         = 'degrees_east'
forc_vec['lon'].attrs['axis']          = 'X'

# editing time attribute
forc_vec['time'].attrs['standard_name'] = 'time'
forc_vec['time'].attrs['axis']          = 'T'
forc_vec['time'].encoding['calendar']   = 'gregorian'
forc_vec.encoding.update(unlimited_dims = 'time')

# coordinate system
forc_vec['crs'] = db['crs'].copy()

# Define a variable for the points and set the 'timeseries_id' (required for some viewers).
forc_vec['subbasin'] = (['subbasin'], db['hruid'].values.astype(np.int32).astype('S20'))
forc_vec['subbasin'].attrs['cf_role'] = 'timeseries_id'

#%% save to netcdf 
comp = dict(zlib=True, complevel=6)
encoding = {var: comp for var in forc_vec.data_vars}
forc_vec.to_netcdf(forcing_dir / 'MESH_{}'.format(forcing_name),encoding=encoding)
print('--%s seconds--' %(time.time() - start_time))


# # Code Provenance
# Generates a basic log file in the domain folder and copies the control file and itself there.
# 

# In[ ]:


# Set the log path and file name
logPath = Path(forcing_dir)
log_suffix = '_MESH_vectorbased_forcing.txt'
 
# Create a log folder
logFolder = '_workflow_log'
Path( logPath / logFolder ).mkdir(parents=True, exist_ok=True)
 
# Copy this script
thisFile = '5_MESH_vectorbased_forcing.ipynb'
copyfile(thisFile, logPath / logFolder / thisFile);
 
# Get current date and time
now = datetime.now()
 
# Create a log file
logFile = now.strftime('%Y%m%d') + log_suffix
with open( logPath / logFolder / logFile, 'w') as file:
     
    lines = ['Log generated by ' + thisFile + ' on ' + now.strftime('%Y/%m/%d %H:%M:%S') + '\n',
             'Generated remapped climate forcing .nc file, reordered to MESH requirements.']
    for txt in lines:
        file.write(txt)

