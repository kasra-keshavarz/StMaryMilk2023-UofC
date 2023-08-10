#!/bin/bash
#SBATCH --account=rpp-kshook
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=10G
#SBATCH --time=00:30:00
#SBATCH --job-name=SMM_Units
#SBATCH --error=SMM_Units-errors
#SBATCH --output=SMM_Units-output
#SBATCH --mail-user=kasra.keshavarz1@ucalgary.ca
#SBATCH --mail-type=BEGIN,END,FAIL

######################
# Necessary modules
######################
module load StdEnv/2020 gcc/9.3.0 openmpi/4.0.3 cdo/2.2.1 

# input folder
infolder="/home/kasra545/scratch/mesh-smm/MESH-Scripts/Model_Workflow/forcing/easymore/"
fl="RDRS_SMM_remapped_1980-01-01-13-00-00.nc"
echo "File being changed: ${infolder}/${fl}"

vars=(
	RDRS_v2.1_P_HU_09944	#var1 
	RDRS_v2.1_A_PR0_SFC	#var2
	RDRS_v2.1_P_P0_SFC	#var3
	RDRS_v2.1_P_FB_SFC	#var4
	RDRS_v2.1_P_FI_SFC	#var5
	RDRS_v2.1_P_TT_09944	#var6
	RDRS_v2.1_P_UVC_09944	#var7
	latitude		#var8
	longitude		#var9
)

scale=(
	1	#var1
	0.277	#var2
	100	#var3
	1	#var4
	1	$var5
	1	#var6
	0.5144	#var7
	1	#var8
	1	#var9
)

offset=(
	0	#var1
	0	#var2
	0	#var3
	0	#var4
	0	#var5
	273.16	#var6
	0	#var7
	0	#var8
	0	#var9
)

# see if the length of all arrays are the same

## Adjust Units
## Pressure from "mb" to "Pa"
## Temperature from "deg_C" to "K"
## Wind speed from "knts" to "m/s"
## Precipitation from "m" over the hour to a rate "mm/s" = "kg m-2 s-1"
for idx in $(seq 0 $(( ${#vars[@]} - 1 )) ); do
  # creating unit change string for each variable, the term is in the
  # `ax+b` format, with `a` being the "scale" and `b` being the "offset"
  str+="${vars[$idx]}=${vars[$idx]}*${scale[$idx]} + ${offset[$idx]}; ";
done

# change units based on $offset, $scale, of $vars
name="$(echo $fl | cut -d '.' -f 1)"
eval cdo -s -f nc4c -z zip_1 expr,\'$str\' "${infolder}/${fl}" "${infolder}/${name}_unitchange.nc"

# --- Code Provenance
# Copy this script into the input folder/_workflow_log/
cp "$(basename $0)" "$infolder/../_workflow_log/"
# Create a log file
dt=$(date +'%Y%m%d')
echo "changed Pressure from 'mb' to 'Pa', Temperature from 'deg_C' to 'K', Wind speed from 'knts' to 'm/s', and Precipitation from 'm' over the hour to a rate 'mm/s' = 'kg m-2 s-1'" >> $infolder/_workflow_log/$dt"_change_unity.txt"

