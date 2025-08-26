#!/bin/bash

echo "============================="
echo " Paso: Eliminación de SNPs conflictivos tras QC"
echo "============================="

# Activar entorno Conda
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env

# Variables
INPUT_PREFIX="/home/garauzaguir/TFM_Jafet_Arauz/Results/Correcciones_Raw_data/nhs_subjects_hg19_QC_passed_HRC_corrected_final"
EXCLUDE_LIST="/home/garauzaguir/TFM_Jafet_Arauz/Results/Bim_Check/Resultados_post_correciones/Exclude-nhs_subjects_hg19_QC_passed_HRC_corrected_final-HRC.txt"
FINAL_OUTPUT_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/Correcciones_Raw_data"
OUTPUT_PREFIX="${FINAL_OUTPUT_DIR}/nhs_subjects_hg19_final"

# Eliminar SNPs conflictivos y conservar el orden original de alelos
plink \
  --bfile "$INPUT_PREFIX" \
  --exclude "$EXCLUDE_LIST" \
  --keep-allele-order \
  --make-bed \
  --out "$OUTPUT_PREFIX"

# Verificación
echo "Archivos generados:"
ls -lh "${OUTPUT_PREFIX}".*


# Paso final para hace un ultimo check-bim

plink \
  --bfile "$OUTPUT_PREFIX" \
  --freq \
  --keep-allele-order \
  --out "${OUTPUT_PREFIX}"

echo "============================="
echo "   SNPs conflictivos eliminados correctamente"
echo "   Archivos finales: ${OUTPUT_PREFIX}.*"
echo "============================="

conda deactivate
