#!/bin/bash

# ================================
# Script para filtrar VCF por CHR:POS del modelo
# ================================

set -euo pipefail

#  Activar entorno
echo "[INFO] Activando entorno..."
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env

# Configuración global
MODEL_NAME="sangre"
VCF_IN="/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputacion_TOPMed/VCF_Procesados/nhs_subjects_hg38.vcf.gz"
POS_FILE="/home/garauzaguir/TFM_Jafet_Arauz/Reference_Data/GTEx_Models/whole_blood_model_chr_pos.tsv"
OUTDIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/PrediXcan_prep/VCF_filtrado"
VCF_OUT="${OUTDIR}/nhs_subjects_hg38_chrRenamed_filtrado_${MODEL_NAME}_CHRPOS.vcf.gz"
BED_FILE="${OUTDIR}/model_chr_pos.bed"

mkdir -p "$OUTDIR"

echo "========================================"
echo "Filtrado de VCF por CHR:POS del modelo: $MODEL_NAME"
echo "VCF de entrada: $VCF_IN"
echo "Archivo de CHR:POS: $POS_FILE"
echo "VCF de salida: $VCF_OUT"
echo "========================================"

# Convertir a BED
echo "[1/3] Generando archivo BED..."
awk 'BEGIN{OFS="\t"} {print $1, $2-1, $2}' "$POS_FILE" > "$BED_FILE"

# Filtrado
echo "[2/3] Filtrando VCF..."
bcftools view --threads 16 \
  -R "$BED_FILE" \
  -Oz -o "$VCF_OUT" "$VCF_IN"

tabix -p vcf "$VCF_OUT"

# Métricas
echo "[3/3] Cálculo de métricas..."
POS_EXPECTED=$(wc -l < "$POS_FILE")
POS_OBTENIDOS=$(bcftools view -H "$VCF_OUT" | wc -l)

echo "========================================"
echo "Modelo utilizado:        $MODEL_NAME"
echo "Posiciones esperadas:    $POS_EXPECTED"
echo "SNPs obtenidos en VCF:   $POS_OBTENIDOS"
echo "VCF final:               $VCF_OUT"
echo "========================================"

echo ".....Filtrado completado exitosamente....."
echo ".....Elaborado por Jafet Arauz....."
