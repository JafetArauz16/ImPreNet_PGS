#!/bin/bash

# ========================
# Configuración inicial
# ========================

if [ -z "$BASE_PATH" ]; then
  echo "ERROR: BASE_PATH is not defined. Please run:"
  echo "  export BASE_PATH=/path/to/ImPreNet_PGS"
  exit 1
fi


# Cargar Nextflow
module load Nextflow/25.04.6
module load Java/17.0.6



# Definir variables
WORKDIR="${BASE_PATH}/Programas/Poligenic_score/pgsc_calc"
OUTDIR="${BASE_PATH}/Results/PGS_Results"
SAMPLESHEET="${BASE_PATH}/Results/PGS_prep/samplesheet.csv"
WORKDIR_NEXTFLOW=$OUTDIR/work
RUNNAME="PGS000001_run_$(date +%Y%m%d_%H%M%S)"
FINAL_OUTDIR=$OUTDIR/$RUNNAME


mkdir -p "$FINAL_OUTDIR"


# Crear carpeta de logs si no existe
mkdir -p $OUTDIR/logs

# Ejecutar el análisis
nextflow run $WORKDIR/main.nf \
  -profile apptainer \
  -process.scratch=true \
  --input $SAMPLESHEET \
  --scorefile $BASE_PATH/Reference_Data/PGS_score_file/PGS000335.txt.gz \
  --target_build GRCh38 \
  --outdir $FINAL_OUTDIR \
  --max_cpus 16 \
  --max_memory '32 GB' \
  -work-dir $FINAL_OUTDIR/work \
  -resume \
  -name "$RUNNAME"

echo "============================"
echo "Proceso terminado con éxito"
echo "Elaborado por Jafet Arauz"
echo "============================"
