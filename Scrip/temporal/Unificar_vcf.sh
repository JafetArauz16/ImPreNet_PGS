#!/bin/bash

# ==============================
# Script: Unificar archivos .dose.vcf.gz y generar VCF final
# ==============================

# Activar entorno
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env

# Rutas
BASE_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputacion_TOPMed"
VCF_DIR="$BASE_DIR/VCF_Procesados"
VCF_FINAL="nhs_subjects_hg38.vcf.gz"
#VCF_FINAL="nhs_subjects_hg38_autosome.vcf.gz"

# Crear carpeta si no existe
mkdir -p "$VCF_DIR"

echo "Moviendo archivos .dose.vcf.gz a $VCF_DIR..."
mv "$BASE_DIR"/chr*.dose.vcf.gz "$VCF_DIR"/ 2>/dev/null

cd "$VCF_DIR" || { echo "No se pudo acceder a $VCF_DIR"; exit 1; }

echo "Iniciando indexación de archivos individuales..."
echo "------------------------------------------------"

for vcf in chr*.dose.vcf.gz; do
  echo "Indexando $vcf..."
  tabix -f -p vcf "$vcf"
done

echo "------------------------------------------------"
echo "Concatenando archivos en $VCF_FINAL..."

# Concatenar usando bcftools
bcftools concat -a -Oz -o "$VCF_FINAL" chr*.dose.vcf.gz
#bcftools concat -a -Oz -o "$VCF_FINAL" chr{1..22}.dose.vcf.gz

# Indexar el archivo final
tabix -f -p vcf "$VCF_FINAL"

echo "VCF final creado en: $VCF_DIR/$VCF_FINAL"
echo ".....Elaborado por Jafet Arauz....."
