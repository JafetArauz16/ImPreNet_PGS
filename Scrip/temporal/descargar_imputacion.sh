#!/bin/bash

# Crear la carpeta de logs si no existe
mkdir -p /home/garauzaguir/TFM_Jafet_Arauz/Results/Imputacion_TOPMed/log

# Ir al directorio donde quieres guardar los archivos descargados
cd /home/garauzaguir/TFM_Jafet_Arauz/Results/Imputacion_TOPMed

# Ejecutar la descarga

curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/1730956/bb188de385e9f06ada6abc7c887478b7015d38a1d139131185fb1aa82d3eb414 | bash
