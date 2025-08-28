# Scripts de análisis en R

Esta carpeta contiene los scripts en R utilizados en el pipeline (**PrediXcan**, **NetActivity**, **PGS** y análisis exploratorios).  

**Nota importante**:  
- Estos scripts **no deben ejecutarse directamente**.  
- Para correrlos en un entorno HPC se utilizan los scripts `.sl` ubicados en la carpeta `/Scrips_slurm/`.  
- Cada `.R` tiene un `.sl` asociado con los parámetros de SLURM ya configurados.  

## Correspondencia entre scripts `.R` y `.sl`

- `Analisis_final_tejido_mama.R` → `run_Analisis_final_tejido_mama.sl`  
- `Analisis_final_tejido_sangre.R` → `run_Analisis_final_tejido_sangre.sl`  
- `PGS_analisis.R` → `run_PGS_analisis_r.sl`  
- `Panalisis_imputacion.R` → `run_analisis_imputacion.sl`  
- `PCA_analisis.R` → `run_PCA_analisis.sl`  

## Outputs

Todos los resultados generados por estos scripts (gráficas, tablas en HTML, reportes) se guardan automáticamente en la carpeta:


