#!/bin/bash

echo "============================="
echo " Iniciando bim-check FINAL post-corrección"
echo "============================="

# Activar entorno
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env

# Incluir ruta local donde está el módulo Perl instalado con cpanm
export PERL5LIB=~/perl5/lib/perl5:$PERL5LIB

# === Rutas ===
#BIM_FILE="/home/garauzaguir/TFM_Jafet_Arauz/Results/Correcciones_Raw_data/nhs_subjects_hg19_final.bim"
#FRQ_FILE="/home/garauzaguir/TFM_Jafet_Arauz/Results/Correcciones_Raw_data/nhs_subjects_hg19_final.frq"
#REF_FILE="/home/garauzaguir/TFM_Jafet_Arauz/Reference_Data/Bim_Check/HRC.r1-1.GRCh37.wgs.mac5.sites.tab"
#OUT_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/Bim_Check/Resultados_finales"
#LOG_FILE="/home/garauzaguir/TFM_Jafet_Arauz/Results/Bim_Check/Resultados_finales/bimcheck_final.log"

# === Rutas ===
BIM_FILE="/home/garauzaguir/TFM_Jafet_Arauz/Results/LiftOver_hg38/nhs_subjects_hg38_final.bim"
FRQ_FILE="/home/garauzaguir/TFM_Jafet_Arauz/Results/LiftOver_hg38/nhs_subjects_hg38_final.frq"
REF_FILE="/home/garauzaguir/TFM_Jafet_Arauz/Reference_Data/Bim_Check/version4.3/HRC_format_TOPMed_hg38.tab"
OUT_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/Bim_Check/Resultados_finales_hg38"
LOG_FILE="/home/garauzaguir/TFM_Jafet_Arauz/Results/Bim_Check/Resultados_finales_hg38/bimcheck_final.log"


# Crear carpeta de salida
mkdir -p "$OUT_DIR"

# Ejecutar bim-check
perl /home/garauzaguir/TFM_Jafet_Arauz/Reference_Data/Bim_Check/version4.3/HRC-1000G-check-bim.pl \
  -b "$BIM_FILE" \
  -f "$FRQ_FILE" \
  -r "$REF_FILE" \
  -h > "$LOG_FILE" 2>&1

# Mover los archivos de salida del bim-check a su carpeta
#mv *.txt *.log Run-plink.sh "$OUT_DIR"

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
