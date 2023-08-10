#!/bin/bash
#SBATCH --account=rpp-kshook
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=40G
#SBATCH --time=01:00:00
#SBATCH --job-name=bow_subset
#SBATCH --error=errors_bow_subset
#SBATCH --mail-user=your.email@example.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END

# load modules
module load StdEnv/2020 gcc/9.3.0 openmpi/4.0.3
module load gdal/3.5.1 libspatialindex/1.8.5
module load python/3.8.10 scipy-stack/2022a mpi4py/3.0.3

# # create and activate virtual environment
rm -rf $HOME/MESH-env
virtualenv --no-download $HOME/MESH-env 
source $HOME/MESH-env/bin/activate 

pip install --no-index --upgrade pip
pip install --no-index geopandas
pip install --no-index easymore

python basin_subset.py 

echo "finished"
