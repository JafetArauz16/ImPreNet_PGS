#!/bin/bash
#SBATCH --job-name=predixcan_tejido_mama_hg38
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/PrediXcan_Output/logs/predixcan_tejido_mama_hg38_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/PrediXcan_Output/logs/predixcan_tejido_mama_hg38_%j.err
#SBATCH --ntasks=1
#SBATCH --time=02:30:00
#SBATCH --mem=64G
#SBATCH --partition=medium
#SBATCH --cpus-per-task=2
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es


# Crear carpeta de logs si no existe
mkdir -p /home/garauzaguir/TFM_Jafet_Arauz/Results/PrediXcan_Output/logs

# Ejecutar script principal
bash /home/garauzaguir/TFM_Jafet_Arauz/Scrip/predixcan.sh
