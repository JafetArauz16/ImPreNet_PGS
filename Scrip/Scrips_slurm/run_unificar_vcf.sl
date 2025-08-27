#!/bin/bash
#SBATCH --job-name=Unificar_vcf
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputacion_TOPMed/VCF_Procesados/log/unificar_vcf_hg38_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputacion_TOPMed/VCF_Procesados/log/unificar_vcf_hg38_%j.err
#SBATCH --ntasks=1
#SBATCH --time=48:00:00
#SBATCH --mem=8G
#SBATCH --partition=medium
#SBATCH --cpus-per-task=2
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es

# Ir al directorio del script
cd "$BASE_PATH/Scrip"

# Ejecutar script

bash Unificar_vcf.sh
