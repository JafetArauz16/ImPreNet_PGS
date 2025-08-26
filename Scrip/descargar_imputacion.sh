#!/bin/bash

# ========================
# Configuración inicial
# ========================

if [ -z "$BASE_PATH" ]; then
  echo "ERROR: BASE_PATH is not defined. Please run:"
  echo "  export BASE_PATH=/path/to/ImPreNet_PGS"
  exit 1
fi


# Crear la carpeta de logs si no existe
mkdir -p "$BASE_PATH/Results/Imputacion_TOPMed/log"

# Ir al directorio donde quieres guardar los archivos descargados
cd "$BASE_PATH/Results/Imputacion_TOPMed"

# Ejecutar la descarga

curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/1730956/bb188de385e9f06ada6abc7c887478b7015d38a1d139131185fb1aa82d3eb414 | bash
