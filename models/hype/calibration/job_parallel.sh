#!/bin/bash
#SBATCH --account=rpp-kshook
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --mem=128G
#SBATCH --time=72:00:00    # time (DD-HH:MM)
#SBATCH --job-name=seperated_SMM
#SBATCH --error=seperated_SMM

module load netcdf openmpi
module restore easymore
mpirun -n 32 ./OstrichMPI
