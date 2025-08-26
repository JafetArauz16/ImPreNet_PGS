#!/bin/bash

# ========================
# Configuración inicial
# ========================

if [ -z "$BASE_PATH" ]; then
  echo "ERROR: BASE_PATH is not defined. Please run:"
  echo "  export BASE_PATH=/path/to/ImPreNet_PGS"
  exit 1
fi


# Activar entorno
source "${BASE_PATH}/Programas/Miniconda3/etc/profile.d/conda.sh"
conda activate GenoNexus_Env

# Definir variables
BFILE="${BASE_PATH}/Results/Correcciones_Raw_data/nhs_subjects_hg19_final"
OUT_DIR="${BASE_PATH}/Results/PCA_results"

# Crear carpeta de salida si no existe
mkdir -p "$OUT_DIR"

# Ejecutar PCA con PLINK
plink --bfile "$BFILE" --pca --out "$OUT_DIR/nhs_subjects_hg19_final_PCA"

echo "PCA completado. Resultados guardados en $OUT_DIR"

echo "======================================"
echo "   Elaborado por Jafet Arauz  "
echo "======================================"

