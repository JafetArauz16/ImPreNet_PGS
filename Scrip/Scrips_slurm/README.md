# Ejecución del pipeline en HPC con SLURM

Este pipeline puede ejecutarse en un entorno HPC usando los scripts `.sl` de esta carpeta.
Cada script `.sl` lanza el `.sh` o `.R` correspondiente del pipeline.

* Se recomienda ejecutarlos desde esta carpeta.
* Si se lanzan desde otro lugar, usar rutas absolutas.
* Algunos scripts `.sl` son **reutilizables** (por ejemplo, para varios pasos de bim-check). En ese caso, es necesario **comentar/descomentar** las líneas correspondientes dentro del `.sl`.
* Ajustar siempre los parámetros de SLURM (`--time`, `--mem`, `--cpus-per-task`, `--job-name`, `--output`, `--error`) según dataset y análisis.

---

## Orden de ejecución recomendado

1. **hrc\_check\_job.sl**

   * Ejecuta `bim-check` (inicial, intermedio o final).
   * Editar el script para activar solo el paso que se desea correr.

   ```bash
   # Ejecutar el script
   bash check_bim_inicial.sh
   #bash check_bim_after_corrections.sh
   #bash check_bim_final.sh

   # Ejecución del script
   sbatch hrc_check_job.sl
   ```

2. **run\_bimcheck\_corrections.sl**

   * Corre las correcciones sobre los datos crudos. Este script es reutilizable en el pipeline.
   * Cambiar en el script: comentar solo el script que no se va a ejecutar.

   ```bash
   # Ejecutar el script de corrección
   bash Correcciones_Raw_data.sh
   #bash Correcciones_finales.sh

   # Ejecución del script
   sbatch run_bimcheck_corrections.sl
   ```

3. **hrc\_check\_job.sl**

   * Corre todos los `bim-check` sobre los datos crudos. Este script es reutilizable en el pipeline.

   ```bash
   # Ejecutar el script
   #bash check_bim_inicial.sh
   bash check_bim_after_corrections.sh
   #bash check_bim_final.sh

   # Ejecución del script
   sbatch hrc_check_job.sl
   ```

4. **run\_bimcheck\_corrections.sl**

   ```bash
   # Ejecutar el script de corrección
   #bash Correcciones_Raw_data.sh
   bash Correcciones_finales.sh

   # Ejecución del script
   sbatch run_bimcheck_corrections.sl
   ```

5. **hrc\_check\_job.sl**

   ```bash
   # Ejecutar el script
   #bash check_bim_inicial.sh
   #bash check_bim_after_corrections.sh
   bash check_bim_final.sh

   # Ejecución del script
   sbatch hrc_check_job.sl
   ```

6. **run\_Frecuencias\_alelicas.sl**

   * Corre el script `Frecuencias_alelicas.R`.

   ```bash
   sbatch run_Frecuencias_alelicas.sl
   ```

7. **run\_PCA\_analisis.sl**

   * Corre el script `PCA_analisis.sh`.

   ```bash
   sbatch run_PCA_analisis.sl
   ```

8. **convert\_to\_vcf\_and\_compres.sl**

   * Corre el script `convert_vcf.sh`.

   ```bash
   sbatch convert_to_vcf_and_compres.sl
   ```

9. **descargar\_imputacion.sl**

   * Corre el script `descargar_imputacion.sh`.
   * Cambiar en el script: actualizar el comando `curl -sL` que se obtiene del servidor.

   ```bash
   sbatch descargar_imputacion.sl
   ```

10. **run\_PCA\_analisis.sl**

   ```bash
   sbatch run_PCA_analisis.sl
   ```

11. **run\_analisis\_imputacion.sl**

    * Corre el script `analisis_imputacion.R`.

    ```bash
    sbatch run_analisis_imputacion.sl
    ```

12. **run\_pgsc\_calc.sl**

    * Corre el script `pgsc_calc.sh`.

    ```bash
    sbatch run_pgsc_calc.sl
    ```

13. **run\_PGS\_analisis\_r.sl**

    * Corre el script `PGS_analisis.R`.

    ```bash
    sbatch run_PGS_analisis_r.sl
    ```

14. **run\_descomprimir\_zip.sl**

    * Corre el script `descomprimir_zip.sh`.

    ```bash
    sbatch run_descomprimir_zip.sl
    ```

15. **run\_unificar\_vcf.sl**

    * Corre el script `Unificar_vcf.sh`.

    ```bash
    sbatch run_unificar_vcf.sl
    ```

16. **run\_filter\_rsID\_model.sl**

    * Corre el script `filtrar_vcf.sh`.

    ```bash
    sbatch run_filter_rsID_model.sl
    ```

17. **run\_predixcan.sl**

    * Corre el script `predixcan.sh`.
    * Nota: este script es reutilizable por tejido. Modificar `MODEL_DB`, `VCF_FILE`, `OUT_DIR`, y los parámetros de SLURM (`--job-name`, `--output`, `--error`).

    ```bash
    sbatch run_predixcan.sl
    ```

18. **run\_Analisis\_final\_tejido\_mama.sl**

    * Corre el script `Analisis_final_tejido_mama.R`.

    ```bash
    sbatch run_Analisis_final_tejido_mama.sl
    ```

19. **run\_Analisis\_final\_tejido\_sangre.sl**

    * Corre el script `Analisis_final_tejido_sangre.R`.

    ```bash
    sbatch run_Analisis_final_tejido_sangre.sl

    
    ```
