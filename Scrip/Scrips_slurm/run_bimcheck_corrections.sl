#!/bin/bash
#SBATCH --job-name=corregir_HRC_final
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/Correcciones_Raw_data/Logs/corregir_HRC_final_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/Correcciones_Raw_data/Logs/corregir_HRC_final_%j.err
#SBATCH --time=00:30:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=2
#SBATCH --partition=short
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es


# Ir al directorio del script
cd "$BASE_PATH/Scrip"

# Ejecutar el script de corrección

#bash Correcciones_Raw_data.sh

bash Correcciones_finales.sh


