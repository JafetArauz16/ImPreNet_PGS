# Librerías
library(readr)
library(dplyr)
library(purrr)
library(ggplot2)

# Ruta de archivos y salida
ruta <- "/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputacion_TOPMed"
salida <- "/home/garauzaguir/TFM_Jafet_Arauz/Figuras"

# Leer archivos .info.gz
archivos_info <- list.files(path = ruta, pattern = "chr[0-9XY]+\\.info\\.gz$", full.names = TRUE)

info_total <- map_dfr(archivos_info, function(file) {
  chr <- gsub(".*(chr[0-9XY]+)\\.info\\.gz$", "\\1", file)
  
  df <- read_tsv(
    file,
    comment = "#",
    col_names = c("CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO"),
    col_types = cols(.default = "c")
  )
  
  if (nrow(df) > 0) {
    df %>%
      mutate(
        AF = as.numeric(sub(".*AF=([^;]*).*", "\\1", INFO)),
        MAF = as.numeric(sub(".*MAF=([^;]*).*", "\\1", INFO)),
        R2 = as.numeric(sub(".*R2=([^;]*).*", "\\1", INFO)),
        CHR = chr
      )
  } else {
    message(paste("Archivo vacío o ilegible:", file))
    NULL
  }
})

# Procesamiento base
info_total <- info_total %>%
  mutate(
    CHR = factor(CHR, levels = paste0("chr", c(1:22, "X", "Y"))),
    POS = as.numeric(POS),
    R2 = as.numeric(R2)
  ) %>%
  mutate(calidad = case_when(
    R2 >= 0.7 ~ "Alta (≥ 0.7)",
    R2 >= 0.3 ~ "Media (0.3 - 0.7)",
    TRUE      ~ "Baja (< 0.3)"
  ))

# Mostrar total de SNPs imputados
cat("Total de SNPs imputados:", nrow(info_total), "\n")

# Gráfico 1: Histograma global de R²
g1 <- ggplot(info_total, aes(x = R2)) +
  geom_histogram(bins = 100, fill = "steelblue", color = "black") +
  geom_vline(xintercept = c(0.3, 0.7), linetype = "dashed", color = c("orange", "darkgreen"), linewidth = 1) +
  labs(title = "Distribución global de R²", x = "R²", y = "Número de SNPs") +
  theme_minimal()
ggsave(filename = file.path(salida, "grafico1_histograma_R2.png"), plot = g1, width = 8, height = 5)

# Gráfico 2: Boxplot por cromosoma
g2 <- ggplot(info_total, aes(x = CHR, y = R2)) +
  geom_boxplot(fill = "lightblue", outlier.size = 0.5) +
  labs(title = "Distribución de R² por cromosoma", x = "Cromosoma", y = "R²") +
  theme_minimal()
ggsave(file.path(salida, "grafico2_boxplot_R2_por_chr.png"), plot = g2, width = 8, height = 5)

# Gráfico 3: Calidad de imputación
# Reordenar niveles del factor calidad
info_total$calidad <- factor(info_total$calidad,
                             levels = c("Baja (< 0.3)", "Media (0.3 - 0.7)", "Alta (≥ 0.7)"))

# Colores asignados en el orden correcto
colors_calidad <- c("Baja (< 0.3)" = "red",
                    "Media (0.3 - 0.7)" = "orange",
                    "Alta (≥ 0.7)" = "green")

# Gráfico 3: Calidad de imputación corregido
g3 <- info_total %>%
  count(calidad) %>%
  ggplot(aes(x = calidad, y = n, fill = calidad)) +
  geom_col() +
  scale_fill_manual(values = colors_calidad) +
  labs(title = "Distribución de calidad de imputación", x = "Calidad", y = "Número de SNPs") +
  theme_minimal()

ggsave(file.path(salida, "grafico3_calidad_imputacion.png"), plot = g3, width = 7, height = 5)

# Gráfico 4: SNPs por cromosoma con línea
snp_por_chr <- info_total %>%
  count(CHR) %>%
  arrange(CHR)
g4 <- ggplot(snp_por_chr, aes(x = CHR, y = n, group = 1)) +
  geom_col(fill = "skyblue") +
  geom_line(color = "darkblue", linewidth = 1) +
  geom_point(color = "darkblue", size = 2) +
  labs(title = "Número de SNPs imputados por cromosoma", x = "Cromosoma", y = "Cantidad de SNPs") +
  theme_minimal()
ggsave(file.path(salida, "grafico4_snp_por_cromosoma.png"), plot = g4, width = 9, height = 5)

# Gráfico 5: R² promedio por cromosoma
r2_promedios <- info_total %>%
  group_by(CHR) %>%
  summarise(promedio_R2 = mean(R2, na.rm = TRUE)) %>%
  arrange(CHR)
g5 <- ggplot(r2_promedios, aes(x = CHR, y = promedio_R2, group = 1)) +
  geom_col(fill = "lightgreen") +
  geom_line(color = "darkgreen", linewidth = 1) +
  geom_point(color = "darkgreen", size = 2) +
  labs(title = "R² promedio por cromosoma", x = "Cromosoma", y = "R² promedio") +
  theme_minimal()
ggsave(file.path(salida, "grafico5_R2_promedio_por_chr.png"), plot = g5, width = 8, height = 5)

# Gráfico 6: Heatmap por decil genómico
info_binned <- info_total %>%
  group_by(CHR) %>%
  mutate(decil = ntile(POS, 10)) %>%
  group_by(CHR, decil) %>%
  summarise(promedio_R2 = mean(R2, na.rm = TRUE), .groups = "drop")

g6 <- ggplot(info_binned, aes(x = factor(decil), y = CHR, fill = promedio_R2)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "white", high = "steelblue", name = "R² promedio") +
  labs(title = "Mapa de calor de R² promedio por decil genómico",
       x = "Decil genómico (posición relativa)", y = "Cromosoma") +
  theme_minimal()
ggsave(file.path(salida, "grafico6_heatmap_R2_por_decil.png"), plot = g6, width = 8, height = 6)
