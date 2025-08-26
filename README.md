# ImPreNet-PGS

Workflow for breast cancer genetic risk prediction combining **Imputation**, **PrediXcan**, **NetActivity** and **Polygenic Risk Scores (PGS)**.

This pipeline is structured in different stages. The **first stage** corresponds to **data preparation for imputation**, which requires specific genomic tools (PLINK, LiftOver, Perl).

---

## Installation

Step 3. Clone this repository
git clone https://github.com/usuario/ImPreNet_PGS.git
cd ImPreNet_PGS

Getting Started
After cloning this repository, the following folder structure will be created:

ImPreNet_PGS/
│── Raw_Data/     # Place your raw input files here (BED/BIM/FAM)
│── Result/       # Processed outputs and QC results
│── Scrip/        # Main pipeline scripts (.sh)
│── Temporales/   # Temporary intermediate files
│── Figuras/      # Figures and plots generated during analysis
│── README.md

### Step 1. Install Miniconda3
For organization, it is recommended to install Miniconda inside the Programas/
mkdir -p Programas
cd Programas

```bash
# 1. Download the installer
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

# 2. Run the installer
bash Miniconda3-latest-Linux-x86_64.sh

# 3. (Optional) Reload shell configuration so conda is available
source ~/.bashrc

# 4. Verify installation
conda --version

Step 2. Configure Conda channels
# Add channels (the order matters: conda-forge should have higher priority than bioconda)
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge

# Or alternatively (preferred way):
conda config --set channel_priority strict

# Check configuration
conda config --show channels



Conda environment setup
This project uses the GenoNexus_Env environment for genomic data processing (PLINK, LiftOver, Perl modules).

Conda environment setup
conda env create -f environments/GenoNexus_Env.yml
conda activate GenoNexus_Env

Verify installation

After activating the environment, check that the main tools are available:
# PLINK
plink --version
# Expected output (example):
# PLINK v1.90b6.21 64-bit (19 Oct 2020)

# LiftOver
liftOver
# Expected output:
# liftOver - Move annotations from one assembly to another
# usage: liftOver oldFile map.chain newFile unMapped

# Perl module Term::ReadKey
perl -MTerm::ReadKey -e 'print "Perl Term::ReadKey module OK\n";'
# Expected output:
# Perl Term::ReadKey module OK

### Configure base path
Before running any script, define the base path of the project:

```bash
export BASE_PATH=/home/usuario/ImPreNet_PGS
echo $BASE_PATH


Move your raw data files to the Raw_Data/ folder before running the pipeline.


## Workflow de preparación de datos

El pipeline debe ejecutarse en el siguiente orden:

1. **check_bim_inicial.sh**  
   Corre el primer `bim-check` sobre los datos crudos para identificar inconsistencias de cromosoma, posición, strand y frecuencias alélicas.

2. **Correcciones_Raw_data.sh**  
   Aplica las correcciones iniciales sugeridas por `bim-check` (cromosomas, posiciones, strand flips, referencia A2, inferencia de sexo, QC).  
   → Genera un conjunto de archivos PLINK filtrados y corregidos.

3. **bimcheck_after_corrections.sh**  
   Ejecuta un nuevo `bim-check` sobre los datos ya corregidos para verificar que los problemas fueron solucionados.

4. **Correcciones_finales.sh**  
   Aplica las últimas correcciones restantes, limpieza final y QC adicional si es necesario.  
   → Deja un conjunto final de archivos PLINK listos para conversión a VCF.

5. **check_bim_final.sh**  
   Corre el `bim-check` final sobre los datos corregidos, asegurando que todo está en orden antes de la imputación.

6. **convert_vcf.sh**  
   Convierte los archivos PLINK finales a formato VCF:  
   - Fuerza alelos de referencia  
   - Comprime e indexa con bgzip/tabix  
   - Renombra `chrX` como `23`  
   - Divide el VCF por cromosoma en archivos listos para imputación.

## Paso final: Imputación

Una vez generados los archivos `.vcf.gz` divididos por cromosoma (en `Results/Correcciones_Raw_data/VCF_by_Chrom/`), estos deben subirse al **Michigan Imputation Server (TOPMed)** para la imputación.

Requisitos importantes:
- Los archivos deben estar **comprimidos con bgzip** (`.vcf.gz`) y **indexados con tabix** (`.tbi`).
- Los cromosomas deben estar numerados como `1-22` y `23` (para X).
- Subir todos los cromosomas generados (`chr1.vcf.gz` ... `chr23.vcf.gz`).

📌 Referencia: [Michigan Imputation Server](https://imputationserver.sph.umich.edu/index.html)

El servidor devolverá archivos imputados que podrán ser utilizados posteriormente para **PrediXcan**, **NetActivity** y análisis de **PGS**.

## Descarga de resultados de imputación (TOPMed)

Una vez completada la imputación en el **Michigan Imputation Server (TOPMed)**, se deben descargar los resultados.  
El propio servidor proporciona un **script de descarga** (`wget` o `curl`) en la página de resultados.

### Instrucciones:
1. Accede a tu carpeta de resultados en el servidor de imputación.
2. Copia el script de descarga que aparece en el portal (por ejemplo `download.sh`).
3. Modifica la línea del script para descargar **todos los archivos imputados** en lugar de archivos individuales.  
   - El script suele contener un comando como:  
     ```bash
     curl -sL ....
     ```  
   - Ajusta esta línea para descargar todos los cromosomas.

### Nota importante:
- Los archivos imputados estarán comprimidos (`.vcf.gz`).  
- Asegúrate de descargarlos **todos los cromosomas** y almacenarlos en la carpeta de resultados correspondiente.



