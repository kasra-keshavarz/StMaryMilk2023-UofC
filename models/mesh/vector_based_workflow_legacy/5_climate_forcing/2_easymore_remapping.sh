#!/bin/bash
#SBATCH --account=rpp-kshook
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=32G
#SBATCH --time=24:00:00    # time (DD-HH:MM)
#SBATCH --job-name=nc_post_pro
#SBATCH --output=./nc_post_pro-out.txt
#SBATCH --error=./nc_post_pro-err.txt
#SBATCH --mail-user=kasra.keshavarz1@ucalgary.ca
#SBATCH --mail-type=BEGIN,END,FAIL

# load needed modules
module load StdEnv/2020 gcc/9.3.0 openmpi/4.0.3
module load gdal/3.5.1 libspatialindex/1.8.5
module load python/3.8.10 scipy-stack/2022a mpi4py/3.0.3

# create virtual env inside the job
virtualenv --no-download $SLURM_TMPDIR/env
source $SLURM_TMPDIR/env/bin/activate
pip install --no-index --upgrade pip
pip install --no-index easymore

# OR use your locally created virtual env in home directory (created as explained on log in node; above)
# source ~/easymore-env/bin/activate # when this is uncommneted, then commnet above (virtualenv ...)

# run python script that include easymore remapper
python 2_easymore_remapping.py
