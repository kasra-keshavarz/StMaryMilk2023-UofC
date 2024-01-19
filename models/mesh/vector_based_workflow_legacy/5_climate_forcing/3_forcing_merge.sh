#!/bin/bash
#SBATCH --account=rpp-kshook
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=60G
#SBATCH --time=01:00:00
#SBATCH --job-name=RDRS_merge
#SBATCH --output=output_merge
#SBATCH --error=errors_merge
#SBATCH --mail-user=kasra.keshavarz1@ucalgary.ca
#SBATCH --mail-type=BEGIN,END,FAIL

# load modules and combine forcing NetCDF
module load StdEnv/2020 gcc/9.3.0 openmpi/4.0.3 cdo/2.2.1 

# cd to datatool.sh output directory
path="$HOME/scratch/mesh-smm/MESH-Scripts/Model_Workflow/forcing/"
all_nc_dir="easymore/easymore-output/"
merged_file="RDRS_SMM_remapped_1980-01-01-13-00-00.nc"

# messages
echo "$(basename $0): Merging all .nc files in ${path}/${all_nc_dir} to make ${path}/${merged_file}"

# merge into one files
cdo -z zip -b F32 mergetime ${path}/${all_nc_dir}/*.nc ${path}/scratch/${merged_file}

