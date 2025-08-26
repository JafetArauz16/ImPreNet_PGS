#!/bin/bash

# ========================
# Configuración inicial
# ========================

if [ -z "$BASE_PATH" ]; then
  echo "ERROR: BASE_PATH is not defined. Please run:"
  echo "  export BASE_PATH=/path/to/ImPreNet_PGS"
  exit 1
fi


echo "============================"
echo "→ PLINK → VCF → chrX→23 → dividir"
echo "============================"

# Activar entorno
conda deactivate
source "${BASE_PATH}/Programas/Miniconda3/etc/profile.d/conda.sh"
conda activate convert_vcf_env

# ==== Rutas ====
WORKDIR="${BASE_PATH}/Results/Correcciones_Raw_data"
BFILE="${WORKDIR}/nhs_subjects_hg19_final"
CORR_FILE="${BASE_PATH}/Results/Bim_Check/Resultados_Raw_data/Force-Allele1-nhs_subjects-HRC.txt"

BASE="nhs_hg19_corrected"
VCF_TXT="${BASE}.vcf"
VCF_GZ="${BASE}.vcf.gz"
VCF_FIXED="${BASE}_chrfixed.vcf.gz"
VCF_CHR_DIR="${WORKDIR}/VCF_by_Chrom"

mkdir -p "$VCF_CHR_DIR"
cd "$WORKDIR"

# ==== Paso 1: Generar VCF plano con alelos forzados ====
echo "→ Generando VCF desde PLINK..."
plink --bfile "$BFILE" \
      --a2-allele "$CORR_FILE" 2 1 \
      --keep-allele-order \
      --recode vcf \
      --output-chr M \
      --out "$BASE"

# ==== Paso 2: Comprimir e indexar correctamente ====
echo "→ Comprimir con bgzip..."
bgzip -c "$VCF_TXT" > "$VCF_GZ"
tabix -p vcf "$VCF_GZ"

# ==== Paso 3: Reemplazar chrX por 23 ====
echo "→ Reemplazando chrX por 23..."
bcftools annotate --rename-chrs <(echo -e "X\t23") "$VCF_GZ" -Oz -o "$VCF_FIXED"
tabix -p vcf "$VCF_FIXED"

# ==== Paso 4: Dividir por cromosoma ====
echo "→ Dividiendo por cromosoma..."
for CHR in {1..23}; do
    echo "   → chr${CHR}"
    VCF_OUT="${VCF_CHR_DIR}/chr${CHR}.vcf.gz"
    bcftools view -r "$CHR" "$VCF_FIXED" -Oz -o "$VCF_OUT"
    tabix -p vcf "$VCF_OUT"
done

# ==== Paso 5: Verificación rápida ====
echo "→ Verificación de compresión BGZF:"
for CHR in {1..23}; do
    file "$VCF_CHR_DIR/chr${CHR}.vcf.gz"
done

echo "============================"
echo " VCFs por cromosoma listos en: $VCF_CHR_DIR"
echo "============================"
