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

# Incluir ruta local donde está el módulo Perl instalado con cpanm
export PERL5LIB=~/perl5/lib/perl5:$PERL5LIB

OUTPUT_DIR="${BASE_PATH}/Results/Bim_Check/Resultados_post_correciones"
mkdir -p "$OUTPUT_DIR"

# Este bim-check es post primeras correcciones
perl "${BASE_PATH}/Reference_Data/Bim_Check/HRC-1000G-check-bim.pl" \
  -b "${BASE_PATH}/Results/Correcciones_Raw_data/nhs_subjects_hg19_QC_passed_HRC_corrected_final.bim" \
  -f "${BASE_PATH}/Results/Correcciones_Raw_data/nhs_subjects_hg19_QC_passed_HRC_corrected_final.frq" \
  -r "${BASE_PATH}/Reference_Data/Bim_Check/HRC.r1-1.GRCh37.wgs.mac5.sites.tab" \
  -h \
  > "${OUTPUT_DIR}/bimcheck_postcorreccion.log" 2>&1

# Desactivar entorno
conda deactivate

# ============================
# Paso final: Mover archivos generados al subdirectorio organizado
# ============================

echo "Moviendo archivos generados a: $OUTPUT_DIR"


# Mover todos los archivos generados por el script HRC
mv *.txt \
   "${BASE_PATH}/Results/Bim_Check/Resultados_post_correciones"
mv Run-plink.sh \
  "${BASE_PATH}/Results/Bim_Check/Resultados_post_correciones"

echo "Archivos organizados correctamente"

echo "============================"
echo "Proceso terminado con éxito"
echo "Elaborado por Jafet Arauz"
echo "============================"
