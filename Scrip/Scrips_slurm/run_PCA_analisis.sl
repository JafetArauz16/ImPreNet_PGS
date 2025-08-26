#!/bin/bash
#SBATCH --job-name=Analisis_PCA
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/PCA_results/logs/PCA_analisis_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/PCA_results/logs/PCA_analisis_%j.err
#SBATCH --time=12:00:00
#SBATCH --mem=2G
#SBATCH --partition=short
#SBATCH --cpus-per-task=2
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es


# Ir al directorio del script
cd /home/garauzaguir/TFM_Jafet_Arauz/Scrip

# Ejecutar el script
bash PCA_analisis.sh
