#!/bin/bash

# Activar entorno
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env

# Definir variables
BFILE="/home/garauzaguir/TFM_Jafet_Arauz/Results/Correcciones_Raw_data/nhs_subjects_hg19_final"
OUT_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/PCA_results"

# Crear carpeta de salida si no existe
mkdir -p "$OUT_DIR"

# Ejecutar PCA con PLINK
plink --bfile "$BFILE" --pca --out "$OUT_DIR/nhs_subjects_hg19_final_PCA"

echo "PCA completado. Resultados guardados en $OUT_DIR"

echo "======================================"
echo "   Elaborado por Jafet Arauz  "
echo "======================================"

