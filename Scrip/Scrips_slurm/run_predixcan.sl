#!/bin/bash
#SBATCH --job-name=predixcan_tejido_sangre
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/ImPreNet_PGS/Results/PrediXcan_Output/logs/predixcan_tejido_sangre_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/ImPreNet_PGS/Results/PrediXcan_Output/logs/predixcan_tejido_sangre_%j.err
#SBATCH --ntasks=1
#SBATCH --time=01:30:00
#SBATCH --mem=64G
#SBATCH --partition=medium
#SBATCH --cpus-per-task=2
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es


# Ir al directorio del script
cd "$BASE_PATH/Scrip"

# Ejecutar script principal
bash predixcan.sh
