# ================================
# Comparación de frecuencias alélicas
# ================================

# Cargar librerías
library(ggplot2)
library(readr)

# Ruta de archivos y salida
BASE_PATH <- Sys.getenv("BASE_PATH")

input_file <- file.path(BASE_PATH, "Results", "Bim_Check", "Resultados_finales", "FreqPlot-nhs_subjects_hg19_final-HRC.txt")
salida <- file.path(BASE_PATH, "Figuras")


# Leer datos
# El archivo no tiene cabecera, entonces se asignan nombres manualmente
freq_data <- read_tsv(input_file, col_names = FALSE, show_col_types = FALSE)

# Renombrar columnas
colnames(freq_data) <- c("rsID", "Freq_HRC", "Freq_nhs", "Diff", "Flag")

# Graficar
 p <- ggplot(freq_data, aes(x = Freq_HRC, y = Freq_nhs)) +
  geom_point(alpha = 0.3, size = 0.5, color = "black") +
  geom_abline(slope = 1, intercept = 0, color = "red") +
  labs(
    title = "Comparación de frecuencias alélicas:\ncohorte NHS vs panel de referencia HRC",
    x = "Frecuencia en HRC",
    y = "Frecuencia en NHS"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5)
  )

#  Guardar en PNG
 ggsave(filename = file.path(salida, "FreqPlot_nhs_vs_HRC.png"), plot = p, width = 6, height = 5, dpi = 300)

        
        