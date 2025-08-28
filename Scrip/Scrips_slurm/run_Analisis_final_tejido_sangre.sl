#!/bin/bash
#SBATCH --job-name=Analisis_final_tejido_sangre
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/ImPreNet_PGS/Figuras/logs/Analisis_final_tejido_sangre_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/ImPreNet_PGS/Figuras/logs/Analisis_final_tejido_sangre_%j.err

##SBATCH --job-name=PCA
##SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/ImPreNet_PGS/Results/PCA_results/logs/Analisis_PCA_%j.out
##SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/ImPreNet_PGS/Results/PCA_results/logs/Analisis_PCA_%j.err

#SBATCH --ntasks=2
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --partition=short
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es

# Ir al directorio del script
cd "$BASE_PATH/Scrip/R_scrips"

source "$BASE_PATH/Programas/Miniconda3/etc/profile.d/conda.sh"
conda activate r_genomics_analysis_env

# Ejecutar el script
Rscript Analisis_final_tejido_sangre.R
#Rscript PCA_analisis.R

conda deactivate
