#!/bin/bash

# ========================
# Configuración inicial
# ========================

if [ -z "$BASE_PATH" ]; then
  echo "ERROR: BASE_PATH is not defined. Please run:"
  echo "  export BASE_PATH=/path/to/ImPreNet_PGS"
  exit 1
fi


set -euo pipefail

echo "[INFO] Activando entorno..."
source "${BASE_PATH}/Programas/Miniconda3/etc/profile.d/conda.sh"
conda activate GenoNexus_Env

# ========= Configuración =========
MODEL_NAME="sangre"
VCF_IN="${BASE_PATH}/Results/Imputacion_TOPMed/VCF_Procesados/nhs_subjects_hg38.vcf.gz"
POS_FILE="${BASE_PATH}/Reference_Data/GTEx_Models/model_keys_${MODEL_NAME}.tsv"   
OUTDIR="${BASE_PATH}/Results/PrediXcan_prep/VCF_filtrado_nuevo"
VCF_OUT="${OUTDIR}/nhs_subjects_hg38_filtrado_${MODEL_NAME}.vcf.gz"
THREADS=16
# =================================

mkdir -p "$OUTDIR"
TMP_DIR="$(mktemp -d)"
ADJ_KEYS="${TMP_DIR}/model_keys_${MODEL_NAME}.adjusted.tsv"
BED_FILE="${TMP_DIR}/model_keys_${MODEL_NAME}.bed"

echo "========================================"
echo "Filtrado de VCF por CHR:POS del modelo: $MODEL_NAME"
echo "VCF de entrada: $VCF_IN"
echo "Archivo de claves del modelo: $POS_FILE"
echo "VCF de salida: $VCF_OUT"
echo "========================================"

# 0) Detectar estilo de contigs
echo "[0/4] Detectando estilo de contigs..."
if bcftools view -h "$VCF_IN" | grep -q '##contig=<ID=chr'; then
  VCF_HAS_CHR=1
else
  VCF_HAS_CHR=0
fi
if head -n1 "$POS_FILE" | grep -q '^chr'; then
  POS_HAS_CHR=1
else
  POS_HAS_CHR=0
fi

# 1) Ajustar prefijo 'chr' y ordenar/deduplicar claves (chr,pos)
echo "[1/4] Ajustando prefijo 'chr' y ordenando claves..."
if [[ $VCF_HAS_CHR -eq 1 && $POS_HAS_CHR -eq 0 ]]; then
  awk 'BEGIN{OFS="\t"} NF>=2{print "chr"$1,$2,$3,$4}' "$POS_FILE" \
  | sort -k1,1 -k2,2n -u > "$ADJ_KEYS"
elif [[ $VCF_HAS_CHR -eq 0 && $POS_HAS_CHR -eq 1 ]]; then
  sed 's/^chr//' "$POS_FILE" \
  | awk 'BEGIN{OFS="\t"} NF>=2{print $1,$2,$3,$4}' \
  | sort -k1,1 -k2,2n -u > "$ADJ_KEYS"
else
  awk 'BEGIN{OFS="\t"} NF>=2{print $1,$2,$3,$4}' "$POS_FILE" \
  | sort -k1,1 -k2,2n -u > "$ADJ_KEYS"
fi

# Sanidad: ¿hay claves?
POS_EXPECTED=$(wc -l < "$ADJ_KEYS")
if [[ "$POS_EXPECTED" -eq 0 ]]; then
  echo "[ERROR] La lista ajustada de posiciones está vacía. Revisa $POS_FILE y el prefijo 'chr'."
  exit 1
fi

# 2) Generar BED (0-based) y filtrar por regiones
echo "[2/4] Generando BED y filtrando VCF..."
awk 'BEGIN{OFS="\t"} {print $1, $2-1, $2}' "$ADJ_KEYS" > "$BED_FILE"

bcftools view --threads "$THREADS" -R "$BED_FILE" -Oz -o "$VCF_OUT" "$VCF_IN"
tabix -p vcf -f "$VCF_OUT"

# 3) Métricas
echo "[3/4] Métricas..."
POS_OBTENIDOS=$(bcftools view -H "$VCF_OUT" | wc -l)
PCT=$(awk -v a="$POS_OBTENIDOS" -v b="$POS_EXPECTED" 'BEGIN{if(b==0){print 0}else{printf "%.2f", (a*100.0)/b}}')

echo "========================================"
echo "Modelo utilizado:           $MODEL_NAME"
echo "Claves del modelo (uniq):   $POS_EXPECTED"
echo "SNPs obtenidos en VCF:      $POS_OBTENIDOS"
echo "Cobertura aproximada (%):   $PCT"
echo "VCF final:                  $VCF_OUT"
echo "========================================"

# 4) Aviso si no se recuperó nada
if [[ "$POS_OBTENIDOS" -eq 0 ]]; then
  echo "[WARN] 0 sitios recuperados. Posible mismatch de build o prefijo 'chr'."
fi

rm -rf "$TMP_DIR"
echo ".....Filtrado completado exitosamente....."
echo ".....Elaborado por Jafet Arauz....."
