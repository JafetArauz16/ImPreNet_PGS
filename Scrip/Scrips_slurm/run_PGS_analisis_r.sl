#!/bin/bash
#SBATCH --job-name=PGS_analisis_R
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/ImPreNet_PGS/Figuras/logs/Analisis_PGS_R_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/ImPreNet_PGS/Figuras/logs/Analisis_PGS_R_%j.err
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=01:00:00
#SBATCH --partition=short
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es

# Ir al directorio del script
cd "$BASE_PATH/Scrip/R_scrips"

source "$BASE_PATH/Programas/Miniconda3/etc/profile.d/conda.sh"
conda activate r_genomics_analysis_env

# Ejecutar el script
Rscript PGS_analisis.R

conda deactivate
