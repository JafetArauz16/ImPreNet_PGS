#!/bin/bash

#SBATCH --job-name=Conversion_VCF
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/Correcciones_Raw_data/VCF_by_Chrom/logs/convert_to_vcf_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/Correcciones_Raw_data/VCF_by_Chrom/logs/convert_to_vcf_%j.err
#SBATCH --time=01:00:00
#SBATCH --mem=1G
#SBATCH --partition=short
#SBATCH --cpus-per-task=2
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es

# Ir al directorio del script
cd "$BASE_PATH/Scrip"

# Ejecutar el script que convierte a VCF, genera el .gz y el .tbi

bash convert_vcf.sh



