#!/bin/bash

git clone https://github.com/kasra-keshavarz/datatool # clone the repository

# Uncomment this section to install cdo and nco if working on a workstation machine. These packages are required. Must have sudo authority.
#sudo apt update
#sudo apt install cdo
#sudo apt install nco
# manually changed - needs to be automated
./datatool/extract-dataset.sh  --dataset=RDRS \
  --dataset-dir="/project/rpp-kshook/Model_Output/RDRSv2.1/" \
  --output-dir="/home/kasra545/scratch/mesh-smm/MESH-Scripts/MESH-Scripts/Model_Workflow/forcing" \
  --start-date="1980-01-01 00:00:00" \
  --end-date="2018-12-31 00:00:00" \
  --shape-file="/home/kasra545/scratch/mesh-smm/MESH-Scripts/Model_Workflow/shapefiles/catchment/smm_cat.shp" \
  --variable="RDRS_v2.1_P_P0_SFC,RDRS_v2.1_P_HU_09944,RDRS_v2.1_P_TT_09944,RDRS_v2.1_P_UVC_09944,RDRS_v2.1_A_PR0_SFC,RDRS_v2.1_P_FB_SFC,RDRS_v2.1_P_FI_SFC" \
  --prefix="rdrsv2.1_" \
  --email="kasra.keshavarz1@ucalgary.ca" \
  -j; # Remove this argument if not submitting to a scheduler on HPC cluster
  
