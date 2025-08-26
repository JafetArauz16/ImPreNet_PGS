#!/bin/bash
#SBATCH --job-name=Bim_check_final
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/Bim_Check/logs/bim_check_final_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/Bim_Check/logs/bim_check_final_%j.err
#SBATCH --time=01:00:00
#SBATCH --mem=32G
#SBATCH --partition=short
#SBATCH --cpus-per-task=2
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es


# Ir al directorio del script
cd "$BASE_PATH/Scrip"

# Ejecutar el script
#bash check_bim_inicial.sh 
#bash check_bim_after_corrections.sh
bash check_bim_final.sh

