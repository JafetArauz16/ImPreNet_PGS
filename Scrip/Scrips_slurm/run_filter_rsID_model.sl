#!/bin/bash
#SBATCH --job-name=Filtrar_VCF_con_chr_pos_sangre
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/PrediXcan_prep/VCF_filtrado_nuevo/logs/filtrar_VCF_sangre_%j.log
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/PrediXcan_prep/VCF_filtrado_nuevo/logs/filtrar_VCF_sangre_%j.err
#SBATCH --partition=medium
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=4G
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es
#SBATCH --exclude=nodo01


# Ir al directorio del script
cd "$BASE_PATH/Scrip"

# Ejecutar scrip

bash filtrar_vcf_nuevo.sh
