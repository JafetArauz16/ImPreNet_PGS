#!/bin/bash

# ========================
# Configuración inicial
# ========================

if [ -z "$BASE_PATH" ]; then
  echo "ERROR: BASE_PATH is not defined. Please run:"
  echo "  export BASE_PATH=/path/to/ImPreNet_PGS"
  exit 1
fi

echo "============================="
echo "Iniciando corrección completa del bim-check"
echo "============================="

set -euo pipefail
set -x

# Activar entorno Conda
source "${BASE_PATH}/Programas/Miniconda3/etc/profile.d/conda.sh"
conda activate GenoNexus_Env

# === Rutas ===
INPUT_PREFIX="${BASE_PATH}/Raw_Data/Matrix/nhs_subjects"
CORR_DIR="${BASE_PATH}/Results/Bim_Check/Resultados_Raw_data"
OUTPUT_PREFIX="${BASE_PATH}/Results/Correcciones_Raw_data/nhs_subjects_hg19_QC_passed_HRC_corrected"
TMP_PREFIX="${BASE_PATH}/Results/Correcciones_Raw_data/TEMP_CORR"

mkdir -p "$(dirname "$TMP_PREFIX")"

# Verificación de archivos PLINK
check_plink_files() {
  for ext in bed bim fam; do
    if [ ! -f "$1.$ext" ]; then
      echo "ERROR: No se generó $1.$ext"
      exit 1
    fi
  done
}

# Paso 1: Copiar archivos originales
plink --bfile "$INPUT_PREFIX" --make-bed --out "${TMP_PREFIX}1"
check_plink_files "${TMP_PREFIX}1"
original_snps=$(wc -l < "${TMP_PREFIX}1.bim")

# Paso 2: Corregir cromosomas
plink --bfile "${TMP_PREFIX}1" \
      --update-map "${CORR_DIR}/Chromosome-nhs_subjects-HRC.txt" \
      --update-chr \
      --make-bed \
      --out "${TMP_PREFIX}2"
check_plink_files "${TMP_PREFIX}2"
snps_chr=$(wc -l < "${TMP_PREFIX}2.bim")
echo "Corrección aplicada: actualización de cromosomas - SNPs corregidos: $((original_snps - snps_chr))"

# Paso 3: Corregir posiciones
plink --bfile "${TMP_PREFIX}2" \
      --update-map "${CORR_DIR}/Position-nhs_subjects-HRC.txt" \
      --make-bed \
      --out "${TMP_PREFIX}3"
check_plink_files "${TMP_PREFIX}3"
snps_pos=$(wc -l < "${TMP_PREFIX}3.bim")
echo "Corrección aplicada: actualización de posiciones - SNPs corregidos: $((snps_chr - snps_pos))"

# Paso 4: Flip de alelos
plink --bfile "${TMP_PREFIX}3" \
      --flip "${CORR_DIR}/Strand-Flip-nhs_subjects-HRC.txt" \
      --make-bed \
      --out "${TMP_PREFIX}4"
check_plink_files "${TMP_PREFIX}4"
snps_flip=$(wc -l < "${TMP_PREFIX}4.bim")
echo "Corrección aplicada: flip de strand - SNPs corregidos: $((snps_pos - snps_flip))"

# Paso 5: Corregir alelo de referencia con --a2-allele
plink --bfile "${TMP_PREFIX}4" \
      --a2-allele "${CORR_DIR}/Force-Allele1-nhs_subjects-HRC.txt" 2 1 \
      --make-bed \
      --out "$OUTPUT_PREFIX"
check_plink_files "$OUTPUT_PREFIX"
snps_a2=$(wc -l < "$OUTPUT_PREFIX.bim")
echo "Corrección aplicada: alineación forzada de alelo A2 - SNPs corregidos: $((snps_flip - snps_a2))"

# Paso 6: Inferencia de sexo
plink --bfile "$OUTPUT_PREFIX" \
      --impute-sex \
      --keep-allele-order \
      --make-bed \
      --out "${OUTPUT_PREFIX}_sex"
check_plink_files "${OUTPUT_PREFIX}_sex"
sex0=$(awk '$6 == 0' "${OUTPUT_PREFIX}_sex.fam" | wc -l)
echo "Paso de inferencia de sexo completado - muestras sin sexo inferido: $sex0"

# Paso 7: Control de calidad
plink --bfile "${OUTPUT_PREFIX}_sex" \
      --geno 0.10 \
      --mind 0.10 \
      --hwe 1e-6 \
      --allow-no-sex \
      --keep-allele-order \
      --make-bed \
      --out "${OUTPUT_PREFIX}_final"
check_plink_files "${OUTPUT_PREFIX}_final"
snps_final=$(wc -l < "${OUTPUT_PREFIX}_final.bim")
echo "Control de calidad aplicado - SNPs eliminados por QC: $((snps_a2 - snps_final))"

# Paso 8: Frecuencias finales
plink --bfile "${OUTPUT_PREFIX}_final" \
      --freq \
      --keep-allele-order \
      --out "${OUTPUT_PREFIX}_final"
echo "Archivo de frecuencias final generado"

# Limpieza
rm -f "${TMP_PREFIX}"[1-4].* "${OUTPUT_PREFIX}_sex".*
echo "Limpieza de archivos temporales completada"

# Resumen final
echo "============================="
echo "Corrección y QC finalizados"
echo "SNPs iniciales: $original_snps"
echo "SNPs tras correcciones y QC: $snps_final"
echo "Muestras sin sexo inferido (removidas): $sex0"
echo "Archivos finales: ${OUTPUT_PREFIX}_final.{bed,bim,fam,frq}"
echo "=============================" 

