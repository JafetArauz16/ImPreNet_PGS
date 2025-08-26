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

OUTPUT_DIR="${BASE_PATH}/Results/Bim_Check/Resultados_Raw_data"
mkdir -p "$OUTPUT_DIR"

# Incluir ruta local donde está el módulo Perl instalado con cpanm
export PERL5LIB=~/perl5/lib/perl5:$PERL5LIB

# Check_bim a los archivos orginales
perl "${BASE_PATH}/Reference_Data/Bim_Check/HRC-1000G-check-bim.pl" \
  -b "${BASE_PATH}/Raw_Data/Matrix/nhs_subjects.bim" \
  -f "${BASE_PATH}/Raw_Data/Matrix/nhs_subjects_freq.frq" \
  -r "${BASE_PATH}/Reference_Data/Bim_Check/HRC.r1-1.GRCh37.wgs.mac5.sites.tab" \
  -h \
  > "${OUTPUT_DIR}/bimcheck_inicial.log" 2>&1


# Desactivar entorno
conda deactivate

# ============================
# Paso final: Mover archivos generados al subdirectorio organizado
# ============================	


echo "Moviendo archivos generados a: $OUTPUT_DIR"


# Mover todos los archivos generados por el script HRC
mv *.txt \
   "${BASE_PATH}/Results/Bim_Check/Resultados_Raw_data"
mv Run-plink.sh \
  "${BASE_PATH}/Results/Bim_Check/Resultados_Raw_data"

echo "Archivos organizados correctamente"

echo "============================"
echo "Proceso terminado con éxito"
echo "Elaborado por Jafet Arauz"
echo "============================"
