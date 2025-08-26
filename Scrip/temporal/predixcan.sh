#!/bin/bash

# ===============================
# Script para ejecutar PrediXcan
# 
# ===============================

# === Activar entorno ===
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenExpress_env

# === Configuración ===
VCF_FILE="/home/garauzaguir/TFM_Jafet_Arauz/Results/PrediXcan_prep/VCF_filtrado_nuevo/nhs_subjects_hg38_filtrado_mama_fixed.vcf.gz"
OUT_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/PrediXcan_Output/Tejido_mama"
PREDICT_SCRIPT="/home/garauzaguir/TFM_Jafet_Arauz/Programas/MetaXcan/software/Predict.py"
MODEL_DB="/home/garauzaguir/TFM_Jafet_Arauz/Reference_Data/GTEx_Models/Breast_Mammary_Tissue_GRCh38.db"
LOG_FILE="$OUT_DIR/predixcan.log"
#VARIANT_MAP="/home/garauzaguir/TFM_Jafet_Arauz/Results/PrediXcan_prep/VCF_filtrado/variant_mapping_final_with_header.tsv"

mkdir -p "$OUT_DIR"
echo "======================================" | tee -a "$LOG_FILE"
echo "Inicio de PrediXcan: $(date)" | tee -a "$LOG_FILE"
echo "Archivo VCF: $VCF_FILE" | tee -a "$LOG_FILE"
echo "Modelo: $MODEL_DB" | tee -a "$LOG_FILE"
echo "Salida: $OUT_DIR" | tee -a "$LOG_FILE"
echo "======================================" | tee -a "$LOG_FILE"

# === Ejecutar PrediXcan ===
echo "[INFO] Ejecutando PrediXcan... $(date)" | tee -a "$LOG_FILE"


python "$PREDICT_SCRIPT" \
    --model_db_path "$MODEL_DB" \
    --vcf_genotypes "$VCF_FILE" \
    --vcf_mode imputed \
    --verbosity 9 \
    --capture "$OUT_DIR/predixcan_capture.tsv.gz" \
    --prediction_output "$OUT_DIR/predicted_expression.txt" \
    --prediction_summary_output "$OUT_DIR/predicted_summary.txt" \
    > "$OUT_DIR/predixcan_full.log" 2>&1

predixcan_status=$?

echo "[INFO] PrediXcan terminó" | tee -a "$LOG_FILE"

# === Verificar estado ===
if [[ $predixcan_status -ne 0 ]]; then
    echo "[ERROR] PrediXcan falló en archivo completo." | tee -a "$LOG_FILE"
else
    echo "[OK] PrediXcan ejecutado correctamente." | tee -a "$LOG_FILE"
    echo "Resultado principal: $OUT_DIR/predicted_expression.txt" | tee -a "$LOG_FILE"
fi

conda deactivate

echo "======= PrediXcan finalizado con éxito =======" | tee -a "$LOG_FILE"
echo "======= Elaborado por Jafet Arauz ======="
