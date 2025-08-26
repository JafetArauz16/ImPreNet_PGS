#!/bin/bash
#SBATCH --job-name=Filtrar_VCF_con_chr_pos_mama_nuevo
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/PrediXcan_prep/VCF_filtrado_nuevo/logs/filtrar_VCF_%j.log
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/PrediXcan_prep/VCF_filtrado_nuevo/logs/filtrar_VCF_%j.err
#SBATCH --partition=medium
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=4G
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es
#SBATCH --exclude=nodo01

# Ejecutar scrip

#bash /home/garauzaguir/TFM_Jafet_Arauz/Scrip/filter_rsID_model.sh

bash /home/garauzaguir/TFM_Jafet_Arauz/Scrip/filtrar_vcf_nuevo.sh
