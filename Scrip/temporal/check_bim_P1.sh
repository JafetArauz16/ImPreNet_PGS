#!/bin/bash

# Activar entorno
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env

# Incluir ruta local donde está el módulo Perl instalado con cpanm
export PERL5LIB=~/perl5/lib/perl5:$PERL5LIB

OUTPUT_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/Bim_Check/Resultados_post_correciones"
mkdir -p "$OUTPUT_DIR"

# Este bim-check es post primeras correcciones
perl /home/garauzaguir/TFM_Jafet_Arauz/Reference_Data/Bim_Check/HRC-1000G-check-bim.pl \
  -b /home/garauzaguir/TFM_Jafet_Arauz/Results/Correcciones_Raw_data/nhs_subjects_hg19_QC_passed_HRC_corrected_final.bim \
  -f /home/garauzaguir/TFM_Jafet_Arauz/Results/Correcciones_Raw_data/nhs_subjects_hg19_QC_passed_HRC_corrected_final.frq \
  -r /home/garauzaguir/TFM_Jafet_Arauz/Reference_Data/Bim_Check/HRC.r1-1.GRCh37.wgs.mac5.sites.tab \
  -h \
  > bimcheck_postcorreccion.log 2>&1

# Desactivar entorno
conda deactivate

# ============================
# Paso final: Mover archivos generados al subdirectorio organizado
# ============================

echo "Moviendo archivos generados a: $OUTPUT_DIR"


# Mover todos los archivos generados por el script HRC
mv *.txt *.log \
   /home/garauzaguir/TFM_Jafet_Arauz/Results/Bim_Check/Resultados_post_correciones
mv Run-plink.sh \
  /home/garauzaguir/TFM_Jafet_Arauz/Results/Bim_Check/Resultados_post_correciones

echo "Archivos organizados correctamente"

echo "============================"
echo "Proceso terminado con éxito"
echo "Elaborado por Jafet Arauz"
echo "============================"
