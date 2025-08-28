# Cargar paquetes
library(tidyverse)
library(knitr)
library(kableExtra)

# Ruta de archivos y salida
BASE_PATH <- Sys.getenv("BASE_PATH")
salida <- file.path(BASE_PATH, "Figuras")
setwd(BASE_PATH)

# Leer archivo PCA
pca <- read.table(file.path(BASE_PATH,"Results/PCA_results/nhs_subjects_hg19_final_PCA.eigenvec"), header = FALSE)
colnames(pca) <- c("FID", "IID", paste0("PC", 1:(ncol(pca)-2)))

# Leer archivo FAM
fam <- read.table(file.path(BASE_PATH,"Results/Correcciones_Raw_data/nhs_subjects_hg19_final.fam"), header = FALSE)
colnames(fam) <- c("FID", "IID", "PID", "MID", "Sex", "Phenotype")

# Unir por FID e IID
pca_data <- left_join(pca, fam[, c("FID", "IID", "Phenotype")], by = c("FID", "IID"))

# Reemplazar 1 y 2 por etiquetas
pca_data$Grupo <- case_when(
  pca_data$Phenotype == 1 ~ "Control",
  pca_data$Phenotype == 2 ~ "Caso",
  TRUE ~ "Desconocido"
)


# Graficar PC1 vs PC2
g1 <- ggplot(pca_data, aes(x = PC1, y = PC2, color = Grupo)) +
  geom_point(alpha = 0.7) +
  labs(title = "PCA de variación genética en casos y controles", x = "PC1", y = "PC2", color = "Grupo") +
  theme_minimal()

ggsave(filename = file.path(salida, "PCA_de_variación_genética_en_casos_y_controles.png"), plot = g1, width = 8, height = 5)


# Crear archivo con los PCs y el IID
pca_solo <- pca_data %>%
  dplyr::select(IID, starts_with("PC"))

# Guardar como archivo TSV
write.table(
  pca_solo,
  file = file.path(BASE_PATH, "Results/PCA_results/PCA_subjects.tsv"),
  sep = "\t", row.names = FALSE, quote = FALSE
)

### ver los PCs

# Leer los autovalores (varianza explicada por cada PC)
eigenval <- scan(file.path(BASE_PATH,"Results/PCA_results/nhs_subjects_hg19_final_PCA.eigenval"))
prop_var_exp <- eigenval / sum(eigenval)
cum_var_exp <- cumsum(prop_var_exp)

pca_summary <- data.frame(
  PC = paste0("PC", 1:length(eigenval)),
  Proporcion = round(prop_var_exp, 4),
  Acumulado = round(cum_var_exp, 4)
)

# Ordenar factor
pca_summary$PC <- factor(pca_summary$PC, levels = paste0("PC", 1:length(eigenval)))

# Graficar
g2 <- ggplot(pca_summary[1:20,], aes(x = PC, y = Proporcion)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_line(aes(y = Acumulado, group = 1), color = "red") +
  geom_point(aes(y = Acumulado), color = "red") +
  labs(title = "Varianza explicada por cada PC ",
       y = "Proporción de varianza",
       x = "Componente principal") +
  theme_minimal()

ggsave(filename = file.path(salida, "Varianza_explicada_por_cada_PC.png"), plot = g2, width = 8, height = 5)


# Mostrar  la tabla summary 
pca_summary %>%
  kable("html", caption = "Varianza explicada por los 20 PCs") %>%
  kable_styling(full_width = FALSE, position = "center") %>%
  save_kable(file = file.path(salida, "Tablas", "PCA_summary.html"))
