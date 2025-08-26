#!/bin/bash

echo "Iniciando proceso de inferencia génica con PrediXcan"
echo "========================= CONFIGURACIÓN INICIAL ========================="

ZIP_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputacion/Proyecto/VCF_finales"
MODEL_DB="/home/garauzaguir/TFM_Jafet_Arauz/Reference_Data/GTEx_Models/Breast_Mammary_Tissue.db"
#MODEL_DB="/home/garauzaguir/TFM_Jafet_Arauz/Reference_Data/GTEx_Models/Whole_Blood.db"
PREDICT_SCRIPT="/home/garauzaguir/TFM_Jafet_Arauz/Programas/MetaXcan/software/Predict.py"
OUT_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/PrediXcan_Output/Tejido_mamario"
LOG_FILE="$OUT_DIR/procesamiento.log"

mkdir -p "$OUT_DIR"
echo "Log guardado en: $LOG_FILE"
echo "" > "$LOG_FILE"

echo "========================= VERIFICACIONES ========================="

# Verificar que el modelo existe
if [[ ! -f "$MODEL_DB" ]]; then
    echo "ERROR: El modelo GTEx no se encuentra en $MODEL_DB" | tee -a "$LOG_FILE"
    exit 1
fi

# Verificar que el script Predict.py existe
if [[ ! -f "$PREDICT_SCRIPT" ]]; then
    echo "ERROR: El script Predict.py no se encuentra en $PREDICT_SCRIPT" | tee -a "$LOG_FILE"
    exit 1
fi

# Verificar que tabix está disponible
if ! command -v tabix &> /dev/null; then
    echo "ERROR: tabix no está instalado o no está en el PATH" | tee -a "$LOG_FILE"
    exit 1
fi

echo "========================= PROCESAMIENTO =========================" | tee -a "$LOG_FILE"

export PYTHONPATH="/home/garauzaguir/TFM_Jafet_Arauz/Programas/MetaXcan/software:${PYTHONPATH:-}"

for CHR in {1..22} X; do
    echo "Procesando cromosoma $CHR..." | tee -a "$LOG_FILE"

    VCF_ORIG="$ZIP_DIR/chr${CHR}.rsID.vcf.gz"
    VCF_FIXED="$ZIP_DIR/chr${CHR}.rsID.DS.vcf.gz"
    TBI_FIXED="$VCF_FIXED.tbi"

    if [[ ! -f "$VCF_ORIG" ]]; then
        echo "AVISO: VCF $VCF_ORIG no encontrado. Cromosoma omitido." | tee -a "$LOG_FILE"
        continue
    fi

    echo "Corrigiendo campo LDS a DS..." | tee -a "$LOG_FILE"
    # Activar entorno para bcftools
    source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
    conda activate GenoNexus_Env

    bcftools view "$VCF_ORIG" | sed 's/GT:LDS/GT:DS/g' | bgzip -c > "$VCF_FIXED"
    tabix -p vcf "$VCF_FIXED"

    if [[ ! -f "$VCF_FIXED" || ! -f "$TBI_FIXED" ]]; then
        echo "ERROR: Fallo al generar el VCF corregido para chr${CHR}" | tee -a "$LOG_FILE"
        continue
    fi

    # Activar entorno para PrediXcan
    conda deactivate
    conda activate GenExpress_env

    echo "Ejecutando PrediXcan..." | tee -a "$LOG_FILE"
    python "$PREDICT_SCRIPT" \
        --model_db_path "$MODEL_DB" \
        --vcf_genotypes "$VCF_FIXED" \
        --vcf_mode imputed \
        --skip_palindromic \
        --prediction_output "$OUT_DIR/predicted_expression_chr${CHR}.txt" \
        --prediction_summary_output "$OUT_DIR/predicted_summary_chr${CHR}.txt" \
        > "$OUT_DIR/predixcan_chr${CHR}.log" 2>&1

    if [[ $? -ne 0 ]]; then
        echo "ERROR: PrediXcan falló en chr_${CHR}. Ver log: predixcan_chr${CHR}.log" | tee -a "$LOG_FILE"
    else
        echo "Cromosoma $CHR completado correctamente." | tee -a "$LOG_FILE"
    fi

    # Limpieza opcional de archivos corregidos
    rm -f "$VCF_FIXED" "$TBI_FIXED"

done

echo "======= Fusión de resultados =======" | tee -a "$LOG_FILE"

OUT_ALL="$OUT_DIR/predicted_expression_all.txt"
echo "Unificando resultados en: $OUT_ALL" | tee -a "$LOG_FILE"

head -n 1 "$OUT_DIR/predicted_expression_chr1.txt" > "$OUT_ALL"
for CHR in {1..22} X; do
    if [[ -f "$OUT_DIR/predicted_expression_chr${CHR}.txt" ]]; then
        tail -n +2 "$OUT_DIR/predicted_expression_chr${CHR}.txt" >> "$OUT_ALL"
    fi
done

echo "Matriz unificada creada: $OUT_ALL" | tee -a "$LOG_FILE"

echo "Limpiando archivos intermedios por cromosoma..." | tee -a "$LOG_FILE"
for CHR in {1..22} X; do
    rm -f "$OUT_DIR/predicted_expression_chr${CHR}.txt"
    rm -f "$OUT_DIR/predicted_summary_chr${CHR}.txt"
done

conda deactivate

echo "======= Proceso completado con éxito =======" | tee -a "$LOG_FILE"
echo "======= Elaborado por Jafet Arauz ==========" | tee -a "$LOG_FILE"

