#!/bin/bash
#SBATCH --job-name=imputacion_plot
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Figuras/logs/imputacion_plot.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Figuras/logs/imputacion_plot.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --partition=medium
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es


source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env

# Ejecutar el script
Rscript /home/garauzaguir/TFM_Jafet_Arauz/Scrip/analisis_imputacion.R
