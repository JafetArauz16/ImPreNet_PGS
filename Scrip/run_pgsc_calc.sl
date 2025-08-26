#!/bin/bash
#SBATCH --job-name=pgs_calc
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/PGS_Results/logs/pgs_calc_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/PGS_Results/logs/pgs_calc_%j.err
#SBATCH --time=08:00:00
#SBATCH --mem=24G
#SBATCH --cpus-per-task=4
#SBATCH --partition=medium
#SBATCH --nodelist=nodo12
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es


# ir a la carpeta de scrip
cd /home/garauzaguir/TFM_Jafet_Arauz/Scrip

# ejecutar el scrip

bash pgsc_calc.sh

