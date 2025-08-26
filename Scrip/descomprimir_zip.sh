#!/bin/bash

# ========================
# Configuración inicial
# ========================

if [ -z "$BASE_PATH" ]; then
  echo "ERROR: BASE_PATH is not defined. Please run:"
  echo "  export BASE_PATH=/path/to/ImPreNet_PGS"
  exit 1
fi


# ========================
# Script: Extraer archivos .dose.vcf.gz y .info.gz desde ZIPs por cromosoma
# ========================

# Ruta a la carpeta donde están los ZIP
ZIP_DIR="${BASE_PATH}/Results/Imputacion_TOPMed"

# Contraseña de los ZIP
ZIP_PASSWORD="5cLluRaJYY1Gz"

# Entrar al directorio
cd "$ZIP_DIR" || { echo "ERROR: No se pudo acceder a $ZIP_DIR"; exit 1; }

echo "Iniciando extracción de archivos .dose.vcf.gz y .info.gz..."
echo "------------------------------------------------------------"

# Extraer los archivos necesarios
for zipfile in chr_*.zip; do
    echo "Procesando $zipfile..."

    7z x -p"$ZIP_PASSWORD" "$zipfile" '*.dose.vcf.gz' '*.info.gz' >/dev/null
    status=$?

    if [[ $status -eq 0 ]]; then
        echo "$zipfile descomprimido correctamente."
    else
        echo "ERROR: Fallo al descomprimir $zipfile."
    fi

    echo "------------------------------------------------------------"
done

echo "Extracción finalizada correctamente."
echo ".....Elaborado por Jafet Arauz....."
