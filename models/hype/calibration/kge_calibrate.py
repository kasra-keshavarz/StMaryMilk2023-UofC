#!/usr/bin/env python
# coding: utf-8

# Note: make top line #!/usr/bin/env python

# In[ ]:


import subprocess
import os
import pandas as pd
import numpy as np
from typing import Tuple


# In[ ]:


# In[2]:
cwd = os.getcwd()
print(f'Here: {cwd}')


# In[ ]:


def remove_invalid_values(simulated, observed):
    valid_indices = np.where((observed != -9999) & (simulated != -9999))
    return simulated[valid_indices], observed[valid_indices]


# In[ ]:


def remove_nan_rows(
    array1: np.ndarray, 
    array2: np.ndarray
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Removes rows from two arrays where either array has NaN values.
    Retains the first row if it doesn't have any NaN values.
    
    Arguments:
    array1: np.ndarray:
        First input array
    array2: np.ndarray
        Second input array
    
    Returns:
    cleaned_array1: : np.ndarray
        Cleaned array1 without NaN rows
    cleaned_array2: np.ndarray
        Cleaned array2 without NaN rows
    """
    # checks for and removes any rows where either array has a value of NaN at a corresponding row 
    # including the first one
    
    mask = np.logical_and(~np.isnan(array1), ~np.isnan(array2))
    if not np.isnan(array1[0]) and not np.isnan(array2[0]):
        mask[0] = True
    cleaned_array1 = array1[mask]
    cleaned_array2 = array2[mask]
    return cleaned_array1, cleaned_array2


# In[ ]:


def compute_kge(simulated_array, observed_array):
    """
    Computes KGE (Kling-Gupta Efficiency) between observed and simulated values.

    Parameters:
        observed_array (numpy.ndarray): Array of observed values.
        simulated_array (numpy.ndarray): Array of simulated values.

    Returns:
        float: KGE value.
    """
    
    # Calculate Pearson correlation coefficient
    correlation_coefficient = np.corrcoef(observed_array, simulated_array)[0, 1]
    
    # Calculate standard deviation ratio
    std_observed = np.std(observed_array)
    std_simulated = np.std(simulated_array)
    std_ratio = std_simulated / std_observed
    
    # Calculate bias ratio
    mean_observed = np.mean(observed_array)
    mean_simulated = np.mean(simulated_array)
    bias_ratio = mean_simulated / mean_observed
    
    # Calculate KGE
    kge = 1 - np.sqrt((correlation_coefficient - 1)**2 + (std_ratio - 1)**2 + (bias_ratio - 1)**2)
    return -kge


# In[ ]:


# run hype
hype_command  = './data/hype'
subprocess.run([hype_command, './data/'])


# In[ ]:


# Create an empty list to store total KGE values for each file
total_kge_values = []


# In[ ]:


file_names = []


# In[ ]:


# Directory where Hype outputs are saved
output_directory = os.path.join(os.getcwd(), 'data')
print('Output directory is: ', output_directory)


# In[ ]:


year_ranges = [('1981-01-01', '1984-12-31'),
               ('1990-01-01', '1998-12-31'),
               ('2004-01-01', '2007-12-31'),
               ('2013-01-01', '2015-12-31')]


# In[ ]:


# Iterate through files in the output directory
for filename in os.listdir(output_directory):
    if filename.endswith(".txt") and filename.startswith("00"):  # Process files with prefix '00' and end with '.txt'
        filepath = os.path.join(output_directory, filename)

        # Create empty lists to store observed and simulated data for each year range
        simulated_data = []
        observed_data = []

        # Read tab-separated file into DataFrame
        df = pd.read_csv(filepath, sep='\t', index_col=0)
        df = df.iloc[1:]  # Drop the first row

        # Convert the index to datetime if it's not already in datetime format
        if not isinstance(df.index, pd.DatetimeIndex):
            df.index = pd.to_datetime(df.index)

        # Process and filter DataFrame based on each year range
        for start_date, end_date in year_ranges:
            trimmed_df = df.loc[start_date:end_date]
            simulated_data.append(trimmed_df['cout'].values.astype(float))  # Convert to float array
            observed_data.append(trimmed_df['rout'].values.astype(float))  # Convert to float array

        # Concatenate the lists of arrays into NumPy arrays
        simulated_array = np.concatenate(simulated_data)
        observed_array = np.concatenate(observed_data)
        
        # Remove invalid values (-9999) after concatenating arrays
        simulated_array, observed_array = remove_invalid_values(simulated_array, observed_array)
        
        # check for and remove rows with nan
        simulated_array, observed_array= remove_nan_rows(simulated_array, observed_array)
        
        # Check if both arrays have the same length
        if len(observed_array) != len(simulated_array):
            raise ValueError(f"Observed and simulated data arrays for file {filename} have different lengths!")

        # Calculate KGE and bias for the current file
        total_lognse = compute_kge(simulated_array, observed_array)

        # Save total KGE to the list
        total_kge_values.append(total_lognse)


# In[ ]:


# Calculate the average KGE
average_lognse = np.mean(total_kge_values)


# In[ ]:


# Output the average KGE to a text file
output_file_path = './average_kge.txt'
with open(output_file_path, 'w') as file:
    file.write(str(average_lognse))


# In[ ]:




