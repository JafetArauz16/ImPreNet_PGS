#!/bin/bash


# Cargar Nextflow
module load Nextflow/24.04.2



# Definir variables
WORKDIR=/home/garauzaguir/TFM_Jafet_Arauz/Programas/Poligenic_score/pgsc_calc
OUTDIR=/home/garauzaguir/TFM_Jafet_Arauz/Results/PGS_Results
SAMPLESHEET=/home/garauzaguir/TFM_Jafet_Arauz/Results/PGS_prep/samplesheet.csv
WORKDIR_NEXTFLOW=$OUTDIR/work
RUNNAME="PGS000001_run_$(date +%Y%m%d_%H%M%S)"
FINAL_OUTDIR=$OUTDIR/$RUNNAME


mkdir -p "$FINAL_OUTDIR"


#Variables temporales
# Definir directorio temporal seguro en /home
TMPDIR_BASE="/home/garauzaguir/tmp_pgsc_$(date +%s)"
mkdir -p "$TMPDIR_BASE"

# Exportar variables para contenedores y Nextflow
export TMPDIR=$TMPDIR_BASE
export APPTAINERENV_TMPDIR=$TMPDIR_BASE
export APPTAINERENV_NXF_TASK_WORKDIR=$TMPDIR_BASE
export SINGULARITYENV_TMPDIR=$TMPDIR_BASE
export SINGULARITYENV_NXF_TASK_WORKDIR=$TMPDIR_BASE
export NXF_SINGULARITY_CACHEDIR=$TMPDIR_BASE
export SINGULARITY_CACHEDIR=$TMPDIR_BASE
export PGS_TMPDIR=$TMPDIR_BASE



# Nueva línea para forzar tmpdir dentro del contenedor
export PGS_TMPDIR=$TMPDIR_BASE


# Si Singularity no está, usar Apptainer (alias moderno)
if ! command -v singularity &> /dev/null && command -v apptainer &> /dev/null; then
    export NXF_SINGULARITY_RUNBIN=$(which apptainer)
    echo " No se encontró 'singularity', usando 'apptainer' en su lugar: $NXF_SINGULARITY_RUNBIN"
fi


# Activar entorno Conda con plink2
source ~/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate pgsc_env

unset JAVA_HOME
unset JAVA_CMD

# Crear carpeta de logs si no existe
mkdir -p $OUTDIR/logs


echo "Usando TMPDIR=$TMPDIR"
echo "Usando PGS_TMPDIR=$PGS_TMPDIR"

# Ejecutar el análisis
time nextflow run $WORKDIR/main.nf \
  -profile singularity \
  --input $SAMPLESHEET \
  --pgs_id PGS000001 \
  --target_build GRCh38 \
  --outdir $FINAL_OUTDIR \
  --max_cpus 16 \
  --max_memory '32 GB' \
  -work-dir $FINAL_OUTDIR/work \
  -resume \
  -name "$RUNNAME"

echo "Verificando si el contenedor sigue usando rutas no deseadas..."
find /beegfs* -maxdepth 1 -type d 2>/dev/null | grep matchtmp


# Eliminar archivos temporales después de ejecutar el análisis
echo "Limpiando archivos temporales..."
rm -rf "$TMPDIR_BASE"
