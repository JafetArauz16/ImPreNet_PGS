#!/bin/bash
#SBATCH --job-name=Descomprimir_zip
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/ImPreNet_PGS/Results/Imputacion_TOPMed/logs/Descomprimir_zip_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/ImPreNet_PGS/Results/Imputacion_TOPMed/logs/Descomprimir_zip_%j.err
#SBATCH --ntasks=1
#SBATCH --time=48:00:00
#SBATCH --mem=8G
#SBATCH --partition=medium
#SBATCH --cpus-per-task=2
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es

# Ir al directorio del script
cd "$BASE_PATH/Scrip"

# Ejecutar script principal
bash descomprimir_zip.sh






