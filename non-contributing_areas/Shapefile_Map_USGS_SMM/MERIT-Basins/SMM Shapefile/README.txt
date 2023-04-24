Author: Kasra Keshavarz, Research Scientist, University of Calgary

Link to MERIT-Basins dataset: https://www.reachhydro.org/home/params/merit-basins

Workflow of analysis: https://github.com/kasra-keshavarz/StMaryMilk2023-UofC/blob/main/non-contributing_areas/geofabric_analysis.ipynb

EASYMORE package v0.0.4 to extract sub-basins and river segments based on connectivity (get_all_upstream function): https://github.com/ShervanGharari/EASYMORE/releases/tag/V.0.0.4

Non-contributing Areas were separately extracted and found out to be sub-basins with "COMID" values of 74000629 and 74000612. Also, in MERIT-Basins, non-contributing areas are either "Coastal hillslopes" or have an invalid "NextDownID" value. Please note that if the river network and sub-basins are being subsetted based on up-/downstream connectivity, there is a chance that non-contributing areas will be missed, since, technically, they are not connected to the area where subsetting process is being implemented. 