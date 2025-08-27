#!/bin/bash
#SBATCH --job-name=descarga_imputacion
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/ImPreNet_PGS/Results/Imputacion_TOPMed/log/descarga_imputacion_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/ImPreNet_PGS/Results/Imputacion_TOPMed/log/descarga_imputacion_%j.err
#SBATCH --ntasks=1
#SBATCH --time=144:00:00
#SBATCH --mem=1G
#SBATCH --partition=medium
#SBATCH --cpus-per-task=2
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es


# Ir al directorio del script
cd "$BASE_PATH/Scrip"

# Ejecutar el script
bash descargar_imputacion.sh


