#!/bin/bash

# Definir rutas
VCF_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/Correcciones_Raw_data/Correccion_sexo_and_QC/VCF_by_Chrom"
REFCORR_DIR="${VCF_DIR}/refcorrected"
REF_GENOME="/home/garauzaguir/TFM_Jafet_Arauz/Reference_Data/hg19/hs37d5.fa.gz"

# Crear carpeta de salida si no existe
mkdir -p "$REFCORR_DIR"

# Corrección de REF/ALT por cromosoma
for chr in {1..22} 23; do
    echo "Corrigiendo chr$chr..."

    INPUT_VCF="${VCF_DIR}/chr${chr}.vcf.gz"
    OUTPUT_VCF="${REFCORR_DIR}/chr${chr}_refcorrected.vcf.gz"

    bcftools +fixref "$INPUT_VCF" \
        -o "$OUTPUT_VCF" \
        -- -f "$REF_GENOME" -m flip -d

    bcftools index "$OUTPUT_VCF"
done

echo "============================"
echo "¡Corrección finalizada!"
echo "============================"
