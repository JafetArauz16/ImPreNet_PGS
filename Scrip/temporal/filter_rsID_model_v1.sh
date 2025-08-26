#!/bin/bash

# ================================
# Script para filtrar VCF por rsID de un modelo
# ================================

set -euo pipefail

#  Activar entorno 
echo "[INFO] Activando entorno..."
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env

# Configuración global 
MODEL_NAME="mama"

VCF_IN="/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputacion_TOPMed/VCF_Procesados/nhs_subjects_hg38.vcf.gz"
RSID_FILE="/home/garauzaguir/TFM_Jafet_Arauz/Reference_Data/GTEx_Models/rsIDs_modelos/rsids_modelo_${MODEL_NAME}.txt"
OUTDIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/PrediXcan_prep/VCF_filtrado"
VCF_OUT="${OUTDIR}/nhs_subjects_hg38_chrRenamed_filtrado_${MODEL_NAME}.vcf.gz"

mkdir -p "$OUTDIR"

echo "========================================"
echo "Filtrado de VCF por rsID del modelo: $MODEL_NAME"
echo "VCF de entrada: $VCF_IN"
echo "Archivo de rsID: $RSID_FILE"
echo "VCF de salida: $VCF_OUT"
echo "========================================"

# Filtrado 
echo "[1/2] Filtrando VCF..."
bcftools view --threads 8 \
  -i "ID=@${RSID_FILE}" \
  -Oz -o "$VCF_OUT" "$VCF_IN"

tabix -p vcf "$VCF_OUT"

# Métricas
echo "[2/2] Cálculo de métricas..."
SNP_EXPECTED=$(sort -u "$RSID_FILE" | wc -l)
SNP_OBTENIDOS=$(bcftools view -H "$VCF_OUT" | wc -l)

echo "========================================"
echo "Modelo utilizado:        $MODEL_NAME"
echo "SNPs esperados en lista: $SNP_EXPECTED"
echo "SNPs obtenidos en VCF:   $SNP_OBTENIDOS"
echo "VCF final:               $VCF_OUT"
echo "========================================"

echo ".....Filtrado completado exitosamente....."
echo ".....Elaborado por Jafet Arauz....."
