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
echo " Iniciando bim-check FINAL post-corrección"
echo "============================="

# Activar entorno
source "${BASE_PATH}/Programas/Miniconda3/etc/profile.d/conda.sh"
conda activate GenoNexus_Env

# Incluir ruta local donde está el módulo Perl instalado con cpanm
export PERL5LIB=~/perl5/lib/perl5:$PERL5LIB

# === Rutas ===
BIM_FILE="${BASE_PATH}/Results/Correcciones_Raw_data/nhs_subjects_hg19_final.bim"
FRQ_FILE="${BASE_PATH}/Results/Correcciones_Raw_data/nhs_subjects_hg19_final.frq"
REF_FILE="${BASE_PATH}/Reference_Data/Bim_Check/HRC.r1-1.GRCh37.wgs.mac5.sites.tab"
OUT_DIR="${BASE_PATH}/Results/Bim_Check/Resultados_finales"
LOG_FILE="${BASE_PATH}/Results/Bim_Check/Resultados_finales/bimcheck_final.log"


# Crear carpeta de salida
mkdir -p "$OUT_DIR"

# Ejecutar bim-check
perl "${BASE_PATH}/Reference_Data/Bim_Check/version4.3/HRC-1000G-check-bim.pl" \
  -b "$BIM_FILE" \
  -f "$FRQ_FILE" \
  -r "$REF_FILE" \
  -h > "$LOG_FILE" 2>&1


# Mover solo los archivos de salida del bim-check (basado en nombre)
SRC_DIR="$(dirname "$BIM_FILE")"

# Lista de patrones de archivos generados por el script (v4.3 con sufijo -HRC.txt)
PATTERNS=(
  "Run-plink.sh"
  "Chromosome-*-HRC.txt"
  "Position-*-HRC.txt"
  "Exclude-*-HRC.txt"
  "FreqPlot-*-HRC.txt"
  "LOG-*-HRC.txt"
  "Strand-Flip-*-HRC.txt"
)

# Mover únicamente los archivos que coincidan con esos patrones
for pattern in "${PATTERNS[@]}"; do
  for file in "$SRC_DIR"/$pattern; do
    [ -e "$file" ] && mv "$file" "$OUT_DIR"
  done
done



echo "============================="
echo " bim-check FINAL completado."
echo " Resultados guardados en:"
echo "   $OUT_DIR"
echo "============================="
