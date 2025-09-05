# ImPreNet-PGS

Pipeline para la predicción del riesgo genético de cáncer de mama combinando **Imputación**, **PrediXcan**, **NetActivity** y **Polygenic Risk Scores (PGS)**.

Este pipeline está estructurado en diferentes etapas. La **primera etapa** corresponde a la **preparación de datos para la imputación**, la cual requiere herramientas genómicas específicas, diseñado y desarrollado en entorno HPC para su ejecucion.

---

## Instalación y configuración del pipeline

### Paso 1. Configurar la variable BASE\_PATH

Antes de ejecutar cualquier script, definir la ruta base del proyecto:

```bash
export BASE_PATH=/home/usuario/ImPreNet_PGS
echo $BASE_PATH
```

### Paso 2. Clonar este repositorio

```bash
git clone https://github.com/usuario/ImPreNet_PGS.git
cd ImPreNet_PGS
```

### Paso 3. Instalar Miniconda3

Se recomienda instalar Miniconda dentro de la carpeta `Programas/`:

```bash
mkdir -p Programas
cd Programas

# Descargar el instalador
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

# Ejecutar el instalador
bash Miniconda3-latest-Linux-x86_64.sh
```

Durante la instalación:

* Cuando aparezca el mensaje
  *Miniconda3 will now be installed into this location:*
  asegúrese de escribir la ruta:

  ```bash
  $BASE_PATH/Programas/Miniconda3
  ```
* Cuando el programa pregunte:
  *You can undo this by running `conda init --reverse $SHELL`? \[yes|no]*
  responda `no`.

Después:

```bash
source ~/.bashrc
conda --version  # Verificar instalación
```

### Paso 4. Configurar canales de Conda

El orden de los canales es importante: conda-forge debe tener prioridad sobre bioconda.

```bash
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority flexible
conda config --show channels
```

### Paso 5. Crear los entornos Conda

Este proyecto utiliza tres entornos de Conda para el procesamiento de datos genómicos:

```bash
cd $BASE_PATH/environments

conda activate base
conda env create -f GenoNexus_Env.yml
conda env create -f GenExpress_env.yml
conda env create -f convert_vcf_env.yml
conda env create -f r_genomics_analysis_env.yml
```

Posteriormente:

```bash
conda activate GenoNexus_Env
conda install -c conda-forge perl-app-cpanminus

cpanm --local-lib=~/perl5 Term::ReadKey
export PERL5LIB=~/perl5/lib/perl5:$PERL5LIB
echo $PERL5LIB

# Verificar módulo de Perl
perl -MTerm::ReadKey -e "print \"Perl Term::ReadKey module OK\n\";"
conda deactivate 
```

---

## Estructura del proyecto

Al clonar el repositorio, se creará la siguiente estructura de carpetas:

```
ImPreNet_PGS/
│── Raw_Data/ # Archivos de entrada crudos (BED/BIM/FAM)
│── Results/ # Salidas procesadas y resultados de QC
│── Scrip/ # Scripts principales del pipeline (.sh)
│── environments/ # Archivos .yml para entornos Conda
│── Reference_Data/ # Datos de referencia para imputación y modelos
│── Metadata/ # Metadatos asociados
│── Figuras/ # Figuras y gráficos generados en los análisis
│── README.md # Documentación principal del repositorio
```

---

## Reference Data

La carpeta `Reference_Data/` contiene los archivos necesarios para el pipeline. A continuación, se describe cómo obtenerlos y prepararlos.

### Bim-check

```bash
cd "$BASE_PATH/Reference_Data"

mkdir Bim_Check
cd Bim_Check
wget https://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.7.zip
unzip HRC-1000G-check-bim-v4.2.7.zip
```

Esto genera:

* `HRC-1000G-check-bim.pl`
* `LICENSE.txt`

### Panel HRC

```bash
wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
gunzip HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
```

### Modelos GTEx (hg38, mashr)

```bash
cd ..
mkdir GTEx_Models
cd GTEx_Models

wget https://zenodo.org/record/3518299/files/mashr_eqtl.tar -O mashr_eqtl.tar

tar -xvf mashr_eqtl.tar eqtl/mashr/mashr_Whole_Blood.db
mv eqtl/mashr/mashr_Whole_Blood.db Whole_Blood_GRCh38.db

tar -xvf mashr_eqtl.tar eqtl/mashr/mashr_Breast_Mammary_Tissue.db
mv eqtl/mashr/mashr_Breast_Mammary_Tissue.db Breast_Mammary_Tissue_GRCh38.db

rm -r eqtl
rm mashr_eqtl.tar
```

Generar archivos `model_keys`:

```bash
sqlite3 Breast_Mammary_Tissue_GRCh38.db <<EOF | sed 's/_/\t/g' | awk '{print $1,$2,$3,$4}' OFS="\t" > model_keys_mama.tsv
SELECT DISTINCT varID FROM weights;
EOF

sqlite3 Whole_Blood_GRCh38.db <<EOF | sed 's/_/\t/g' | awk '{print $1,$2,$3,$4}' OFS="\t" > model_keys_sangre.tsv
SELECT DISTINCT varID FROM weights;
EOF
```

### Archivos para PGS

```bash
cd ..
mkdir PGS_score_file
cd PGS_score_file

wget https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/PGS000335/ScoringFiles/PGS000335.txt.gz
gunzip -c PGS000335.txt.gz > PGS000335.txt
cd $BASE_PATH
```

---

## Organización de datos inicial

Antes de ejecutar el pipeline asegúrese de colocar los archivos de entrada en las carpetas correspondientes, usar los siguientes comandos
para ubicarse en las carpetas donde debe colocorar los datos crudos y metadatos:

- **Datos crudos** (`.bed`, `.bim`, `.fam`): deben ubicarse en /Raw_Data , no deben quedar en otra carpeta.
  ```bash
  cd "$BASE_PATH/Raw_Data"
  
  ```
- **Crear archivo .frq del archivo .bim** debe ubicarse en /Raw_Data , no deben quedar en otra carpeta.
  ```bash
  plink --bfile nombre_de_archivo_sin_extension --freq --out nombre_de_archivo_sin_extension
  
  ```
  
- **Metadatos** (información clínica, fenotipos, covariables, etc.): deben ubicarse en
 ```bash
cd "$BASE_PATH/Metadata"

  ```
---

## Workflow de preparación de datos

Este workflow está diseñado para ejecutarse en entornos HPC. Para ello se cuenta con la carpeta `/Scrips_slurm/`, donde se encuentran los scripts de SLURM que permiten lanzar las tareas. En esa carpeta hay un `README.md` específico con detalles de su ejecución.

El pipeline debe ejecutarse en el siguiente orden:

1. **check\_bim\_inicial.sh** – Primer `bim-check` sobre los datos crudos.
2. **Correcciones\_Raw\_data.sh** – Correcciones iniciales sugeridas por `bim-check`.
3. **check\_bim\_after\_corrections.sh** – Verificación tras las correcciones.
4. **Correcciones\_finales.sh** – Últimas correcciones y QC final.
5. **check\_bim\_final.sh** – Validación final antes de la imputación.
6. **Frecuencias_alelicas.R** – Gráfico de comparación de frecuencias alélicas entre la cohorte NHS y el panel HRC (QC visual).
7. **PCA\_analisis.sh** – Análisis de PCA con datos corregidos.
8. **convert\_vcf.sh** – Conversión a VCF, compresión, indexación y renombrado.

---

## Imputación

Los archivos `.vcf.gz` generados en `Results/Correcciones_Raw_data/VCF_by_Chrom/` deben subirse al **TOPMed Imputation Server**.

Requisitos:

* Archivos comprimidos con bgzip (`.vcf.gz`) e indexados con tabix (`.tbi`).
* Cromosomas numerados como 1–22 y 23 (para X).
* Subir todos los cromosomas.

Referencia: [TOPMed Imputation Server](https://imputation.biodatacatalyst.nhlbi.nih.gov/#!pages/home)

---

## Descarga de resultados de imputación (TOPMed)

Una vez completada la imputación, el servidor genera un comando `wget` o `curl` para descargar los resultados.

1. Acceder a la página de resultados del servidor.
2. Copiar la línea de comando de descarga.
3. Guardarla en el script `descargar_imputacion.sh`.
4. Ejecutar el script para descargar todos los cromosomas.

Los archivos imputados estarán comprimidos (`.vcf.gz`). Asegúrese de descargarlos todos y almacenarlos en la carpeta de resultados correspondiente.

---

## Análisis de PGS

Con los datos imputados se puede calcular el **Polygenic Risk Score (PGS)**.
Ejecutar el script Bash correspondiente y, de manera opcional, el script de R para análisis y visualización.

```bash
bash calc_pgs.sh
Rscript R_scrips/PGS_analisis.R
```

Los resultados incluyen gráficos y modelos, guardados en la carpeta `/Figuras/`.

---

## Preparación para PrediXcan

Los resultados suelen venir en un `.zip` protegido con contraseña. En el script `descomprimir_zip.sh`, se debe modificar la variable:

```bash
ZIP_PASSWORD="xxxxxxxx"
```

Ejecutar:

```bash
bash Scrip/descomprimir_zip.sh
```

Unificar los cromosomas en un único VCF:

```bash
bash Unificar_vcf.sh
```

Filtrar el archivo unificado por modelo (mama o sangre):

```bash
bash filtrar_vcf.sh
```

---

## Ejecución de PrediXcan

Editar el script `predixcan.sh` según el tejido:

* **Mama**:

```bash
VCF_FILE="$BASE_PATH/Results/PrediXcan_prep/VCF_filtrado_nuevo/nhs_subjects_hg38_filtrado_mama.vcf.gz"
OUT_DIR="$BASE_PATH/Results/PrediXcan_Output/Tejido_mama"
MODEL_DB="$BASE_PATH/Reference_Data/GTEx_Models/Breast_Mammary_Tissue_GRCh38.db"
```

* **Sangre**:

```bash
VCF_FILE="$BASE_PATH/Results/PrediXcan_prep/VCF_filtrado_nuevo/nhs_subjects_hg38_filtrado_sangre.vcf.gz"
OUT_DIR="$BASE_PATH/Results/PrediXcan_Output/Tejido_sangre"
MODEL_DB="$BASE_PATH/Reference_Data/GTEx_Models/Whole_Blood_GRCh38.db"
```

Ejecutar:

```bash
bash predixcan.sh
```

---

## Análisis con NetActivity

Para el análisis final con NetActivity se utilizan los scripts de R disponibles en `/R_scrips/`:

* `Analisis_final_tejido_mama.R`
* `Analisis_final_tejido_sangre.R`

Los gráficos y tablas generados (en formato HTML) se guardan en la carpeta `/Figuras/`.



