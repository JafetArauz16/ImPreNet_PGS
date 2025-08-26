#!/bin/bash
##SBATCH --job-name=Descomprimir_zip
##SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputacion_TOPMed/logs/Descomprimir_zip_%j.out
##SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputacion_TOPMed/logs/Descomprimir_zip_%j.err
#SBATCH --job-name=Unificar_vcf_hg38
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputacion_TOPMed/VCF_Procesados/log/unificar_vcf_hg38_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputacion_TOPMed/VCF_Procesados/log/unificar_vcf_hg38_%j.err

#SBATCH --ntasks=1
#SBATCH --time=48:00:00
#SBATCH --mem=8G
#SBATCH --partition=medium
#SBATCH --cpus-per-task=2
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es


# Ejecutar script principal
#bash /home/garauzaguir/TFM_Jafet_Arauz/Scrip/descomprimir_zip.sh


bash /home/garauzaguir/TFM_Jafet_Arauz/Scrip/Unificar_vcf.sh


#bash /home/garauzaguir/TFM_Jafet_Arauz/Scrip/descomprimir_zip_hg38.sh
