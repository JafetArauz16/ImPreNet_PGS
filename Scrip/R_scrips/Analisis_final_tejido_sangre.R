#############################################################################################
####################   Analisis Tejido Sangre  #################################################
#############################################################################################

# Cargar librerías
library(tidyverse)
library(biomaRt)
library(reshape2)
library(pheatmap)
library(ggplot2)
library(dplyr)
library(knitr)
library(kableExtra)

# Ruta de archivos y salida
BASE_PATH <- Sys.getenv("BASE_PATH")

salida <- file.path(BASE_PATH, "Figuras")

setwd(BASE_PATH)

#  Cargar archivos 
metadatos_edad <- read_tsv(file.path(BASE_PATH,"Metadata/CGEMS_Breast_Cancer_Subject_Phenotypes.GRU.txt"), show_col_types = FALSE, comment = "#")
predict_sangre_expr <- read_tsv(file.path(BASE_PATH,"Results/PrediXcan_Output/Tejido_sangre/predicted_expression.txt"), show_col_types = FALSE)
summary_sangre_expr <- read_tsv(file.path(BASE_PATH,"Results/PrediXcan_Output/Tejido_sangre/predicted_summary.txt"), show_col_types = FALSE)
fam <- read.table(file.path(BASE_PATH,"Results/Correcciones_Raw_data/nhs_subjects_hg19_final.fam"), header = FALSE)
capture_sangre <- read_tsv(file.path(BASE_PATH,"Results/PrediXcan_Output/Tejido_sangre/predixcan_capture.tsv.gz"))


colnames(fam) <- c("FID", "IID", "Father", "Mother", "Sex", "Phenotype")
fam <- fam %>% 
  dplyr::select(-FID)

metadatos_edad <- metadatos_edad %>% 
  dplyr::select(SUBJID, AGE)

# Corregir IIDs en predicted_expression
predict_sangre_expr$IID <- sub("_.*", "", predict_sangre_expr$IID)

# Convertir IID a carácter
fam$IID <- as.character(fam$IID)
predict_sangre_expr$IID <- as.character(predict_sangre_expr$IID)

predict_sangre_expr <- predict_sangre_expr %>% 
  dplyr::select(-FID)


# Eliminar duplicados si los hay
fam <- fam[!duplicated(fam$IID), ]
predict_sangre_expr <- predict_sangre_expr[!duplicated(predict_sangre_expr$IID), ]

# Verificación previa
cat("Muestras en fam:", nrow(fam), "\n")
cat("Muestras en expresión:", nrow(predict_sangre_expr), "\n")

# Renombrar genes 
genes_predichos <- colnames(predict_sangre_expr)[-c(1)]
genes_sin_version <- gsub("\\..*", "", genes_predichos)


gene_map <- summary_sangre_expr[, c("gene", "gene_name")]

gene_map_vector <- setNames(gene_map$gene_name, gene_map$gene)

new_colnames <- gene_map_vector[colnames(predict_sangre_expr)[-1]] 
new_colnames[is.na(new_colnames)] <- colnames(predict_sangre_expr)[-1][is.na(new_colnames)]
new_colnames <- make.unique(new_colnames)  
colnames(predict_sangre_expr) <- c("IID", new_colnames)



# Verificar resultado
sin_renombrar <- colnames(predict_sangre_expr)[-1][grepl("^ENSG", colnames(predict_sangre_expr)[-1])]
# Muestra cuántas y cuáles
cat("Número de columnas sin renombrar: ", length(sin_renombrar), "\n")
print(sin_renombrar)


#  Unión  por IID 
datos_combinados <- inner_join(fam, predict_sangre_expr, by = "IID")



# Verificación post-unión
cat("Muestras combinadas:", nrow(datos_combinados), "\n")
cat("Casos y controles tras combinación:\n")
print(table(datos_combinados$Phenotype))


coinciden <- sum(datos_combinados$IID %in% metadatos_edad$SUBJID)
cat("Número de IIDs con edad disponible: ", coinciden, "\n")

datos_combinados <- inner_join(datos_combinados, metadatos_edad, by = c("IID" = "SUBJID"))
cat("Número de muestras tras unir con metadatos: ", nrow(datos_combinados), "\n")


datos_combinados <- datos_combinados %>% 
  dplyr::select(-Father, -Mother)

datos_combinados <- datos_combinados %>%
  dplyr::rename(CaseControl = Phenotype)
datos_combinados$AGE <- as.factor(datos_combinados$AGE)



capture_resumen <- capture_sangre %>%
  filter(!is.na(weight)) %>%
  group_by(gene) %>%
  summarise(
    n_snps_total = n(),
    n_snps_used = sum(weight != 0),
    sum_abs_weight = sum(abs(weight), na.rm = TRUE),
    mean_abs_weight = mean(abs(weight), na.rm = TRUE)
  ) %>%
  ungroup()



# Crear data frame con el número de SNPs por gen
snps_por_gen <- capture_sangre %>%
  group_by(gene) %>%
  summarise(n_snps = n())

# Plot 
g1 <- ggplot(snps_por_gen, aes(x = n_snps)) +
  geom_histogram(binwidth = 1, fill = "#2C7BB6", color = "black", alpha = 0.8) +
  scale_x_continuous(breaks = 1:10, limits = c(0, 10)) +
  labs(
    title = "Distribución de número de SNPs usados por gen\n en tejido sangre",
    x = "Número de SNPs por gen",
    y = "Cantidad de genes"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold")
  )

ggsave(filename = file.path(salida, "Distribución_de_número_de_SNPs_usados_por_gen_sangre.png"), plot = g1, width = 8, height = 5)

library(limma)

# Agregar PCs al data frame
pcs <- read_tsv(file.path(BASE_PATH, "Results/PCA_results/PCA_subjects.tsv"))


datos_combinados <- left_join(datos_combinados, pcs, by = "IID")



# Convertir  Sexo y CaseControl a factores

datos_combinados$Sex <- as.factor(datos_combinados$Sex)
datos_combinados$CaseControl <- as.factor(datos_combinados$CaseControl)

# matriz de diseño
design <- model.matrix(~ AGE + CaseControl + PC1 + PC2 + PC3 + PC4 + PC5, data = datos_combinados)

# matriz de expresión
exp_matrix <- as.matrix(datos_combinados%>%
                          dplyr::select(-IID, -CaseControl, -Sex, -AGE))

exp_matrix_t <- t(exp_matrix)


# Filtrar genes con varianza > 0
exp_matrix_t <- exp_matrix_t[apply(exp_matrix_t, 1, var) > 0, ]

library(limma)

fit <- lmFit(exp_matrix_t, design)
fit <- eBayes(fit)
res_casecontrol <- topTable(fit, coef = "CaseControl2", number = Inf, adjust.method = "BH")

# Ordenar por p-valor ajustado
res_casecontrol <- res_casecontrol[order(res_casecontrol$adj.P.Val), ]


g2 <- ggplot(res_casecontrol, aes(x = logFC, y = -log10(P.Value))) +
  geom_point(alpha = 0.5) +
  geom_hline(aes(yintercept = -log10(0.05), color = "P-valor 0.05"), linetype = "dashed") +
  geom_vline(aes(xintercept = -0.05, color = "logFC ±0.05"), linetype = "dotted") +
  geom_vline(aes(xintercept = 0.05, color = "logFC ±0.05"), linetype = "dotted") +
  coord_cartesian(xlim = c(-0.1, 0.1)) +
  scale_color_manual(
    name = "Umbrales",
    values = c("P-valor 0.05" = "red", "logFC ±0.05" = "green")
  ) +
  theme_minimal() +
  labs(
    title = "Volcano plot - Caso vs Control (modelo_sangre)",
    x = "log2 Fold Change",
    y = "-log10(P-valor)"
  )

ggsave(file.path(salida, "Volcano_plot_Caso_vs_Control_modelo_sangre.png"), plot = g2, width = 8, height = 5)

top_genes <- rownames(head(res_casecontrol[order(res_casecontrol$P.Value), ], 5))

df_long <- datos_combinados %>%
  dplyr::select(CaseControl, all_of(top_genes)) %>%
  pivot_longer(cols = -CaseControl, names_to = "Gen", values_to = "Expresion")

df_long$Gen <- factor(df_long$Gen, levels = top_genes)
df_long$CaseControl <- factor(df_long$CaseControl, labels = c("Control", "Caso"))

g3 <- ggplot(df_long, aes(x = CaseControl, y = Expresion, fill = CaseControl)) +
  geom_boxplot() +
  facet_wrap(~ Gen, scales = "fixed") +
  theme_minimal() +
  ylab("Expresión predicha") +
  xlab("Grupo") +
  ggtitle("Expresión predicha de los 5 genes más significativos (modelo_sangre)") +
  scale_fill_brewer(palette = "Set2")

ggsave(file.path(salida, "Resumen_de_los_5_genes_más_significativos_modelo_sangre.png"), plot = g3, width = 7, height = 5)

head(res_casecontrol, 5) %>%
  kable("html", digits = 4, caption = "Resumen de los 5 genes más significativos modelo_sangre") %>%
  kable_styling(full_width = FALSE, bootstrap_options = c("striped", "hover")) %>%
  save_kable(file = file.path(salida, "Tablas", "Top5_genes_significativos_sangre.html"))




# Grafica de varianzas por genes 
library(ggplot2)

# Calcular varianza por gen
varianzas <- apply(exp_matrix_t, 1, var)

# Transformar con log10 (añadiendo pseudoconteo para evitar log(0))
log_varianzas <- log10(varianzas + 1e-10)

# Graficar el histograma en escala log
g <- ggplot(data.frame(log_varianza = log_varianzas), aes(x = log_varianza)) +
  geom_histogram(bins = 100, fill = "#2C7BB6", color = "black", alpha = 0.8) +
  labs(
    title = "Distribución logarítmica de varianza de expresión predicha por gen (modelo_sangre)",
    x = "log10(Varianza)",
    y = "Número de genes"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold")
  )

ggsave(file.path(salida, "Distribución_logarítmica_de_varianza_de_expresión_predicha_por_gen_sangre.png"), plot = g, width = 9, height = 5)


############################################################################################################
                  # Análisis previo al de  NetActivity en tejido sangre #
############################################################################################################
library(NetActivity)
library(NetActivityData)
library(SummarizedExperiment)
library(dplyr)
library(readr)



# Revertir nombres de genes a ENSEMBL IDs 

gene_map_vector_inv <- setNames(gene_map$gene, gene_map$gene_name)

# Obtener nombres actuales (HGNC) y revertir a ENSEMBL
colnames_expr <- colnames(predict_sangre_expr)[-1]  
new_colnames <- gene_map_vector_inv[colnames_expr]
new_colnames[is.na(new_colnames)] <- colnames_expr[is.na(new_colnames)]  
new_colnames <- make.unique(new_colnames)  

# Reasignar nombres de columnas
colnames(predict_sangre_expr) <- c("IID", new_colnames)


#Unir metadaotos y pcs a predict_sangre_expr
fam <- read.table(file.path(BASE_PATH,"Results/Correcciones_Raw_data/nhs_subjects_hg19_final.fam"), header = FALSE)
colnames(fam) <- c("FID", "IID", "Father", "Mother", "Sex", "Phenotype")
fam<- fam %>% dplyr::select(IID, Phenotype)


pcs <- read_tsv(file.path(BASE_PATH, "Results/PCA_results/PCA_subjects.tsv"))

metadatos_edad <- read.delim(
  file.path(BASE_PATH, "Metadata/CGEMS_Breast_Cancer_Subject_Phenotypes.GRU.txt"),
  header = TRUE,
  sep = "\t",
  skip = 10,
  stringsAsFactors = FALSE,
  check.names = TRUE
)

metadatos_edad <- metadatos_edad %>% dplyr::select(AGE,SUBJID)
metadatos_edad <- metadatos_edad %>%
  dplyr::filter(SUBJID %in% fam$IID)
metadatos_edad <- metadatos_edad %>%
  dplyr::rename(IID = SUBJID)



predict_sangre_expr <- left_join(predict_sangre_expr, pcs, by = "IID")
predict_sangre_expr <- left_join(predict_sangre_expr, fam, by =  "IID")
predict_sangre_expr <- left_join(predict_sangre_expr, metadatos_edad, by = "IID")



genes_predichos <- predict_sangre_expr %>%
  dplyr::select(-AGE, -starts_with("PC")) %>%
  mutate(Phenotype = factor(Phenotype, levels = c(1, 2), labels = c("control", "case")))

# Separar variables
genes <- genes_predichos %>%
  dplyr::select(-IID, -Phenotype)

# Vector de grupos
grupo <- genes_predichos$Phenotype

# Aplicar t-test a cada gen

t_test_resultados <- lapply(genes, function(gen) {
  res <- try(t.test(gen ~ grupo), silent = TRUE)
  if (inherits(res, "try-error") || is.na(res$p.value)) {
    return(NULL)
  } else {
    return(data.frame(
      p_value = res$p.value,
      t_stat = res$statistic,
      mean_control = res$estimate[1],
      mean_case = res$estimate[2],
      mean_diff = res$estimate[2] - res$estimate[1],
      conf_low = res$conf.int[1],
      conf_high = res$conf.int[2]
    ))
  }
})


# Elimina los NULL
t_test_resultados <- t_test_resultados[!sapply(t_test_resultados, is.null)]

# Combinar resultados
resultados_df <- do.call(rbind, t_test_resultados)
resultados_df$Gen <- names(t_test_resultados)



# Ajustar p-valores 
resultados_df <- resultados_df %>%
  mutate(
    p_adj = p.adjust(p_value, method = "BH"),
    log10p = -log10(p_value),
    Significativo = p_value < 0.05
  ) %>%
  arrange(p_value)

anyNA(resultados_df)
table(resultados_df$Significativo)

library(knitr)
library(kableExtra)


top10 <- resultados_df |>
  arrange(p_value) |>
  dplyr::select(p_value, p_adj, t_stat, mean_control, mean_case, mean_diff, conf_low, conf_high, log10p, Significativo ) |>
  head(10)

top10 %>%
  kable("html", caption = "Top 10 genes más significativos por p-valor crudo en tejido sangre", digits = 5) %>%
  kable_styling(full_width = FALSE, bootstrap_options = c("striped", "hover")) %>%
  save_kable(file = file.path(salida, "Tablas", "Top10_genes_significativos_sangre.html"))

##################################################################################################################################
##      NetActivity    ####
##################################################################################################################################

#  Preparar para calculo de genset score 

genes_only <- predict_sangre_expr %>%
  dplyr::select(-starts_with("PC"), -AGE, -Phenotype)

genes_scaled <- genes_only %>%
  mutate(across(where(is.numeric), ~as.numeric(scale(.)))) %>%
  as.data.frame()

rownames(genes_scaled) <- genes_scaled$IID
genes_scaled<- genes_scaled %>% dplyr::select(-IID)

# Convertir a matriz y asignar nombres de fila
matriz_expr <- as.matrix(genes_scaled)


# Transponer genes como filas, muestras como columnas
matriz_expr_t <- t(matriz_expr)

#  Limpiar y estandarizar nombres de genes 
# Quitar versiones .13, .2, etc. en los nombres de genes

rownames(matriz_expr_t) <- gsub("\\..*", "", rownames(matriz_expr_t))
typeof(matriz_expr_t)

# Verificación final
stopifnot(is.numeric(matriz_expr_t[1, 1]))
stopifnot(is.character(rownames(matriz_expr_t)))
stopifnot(is.character(colnames(matriz_expr_t)))

# Filtrar genes presentes en el modelo NetActivity 
data("gtex_gokegg")  
genes_model <- colnames(gtex_gokegg)

# data("tcga_gokegg") 
# genes_model <- colnames(tcga_gokegg)
common_genes <- intersect(rownames(matriz_expr_t), genes_model)
cat("Genes en común con el modelo:", length(common_genes), "\n")

matriz_expr_t <- matriz_expr_t[common_genes, ]


dim(matriz_expr_t)

# Crear objeto SummarizedExperiment con metadatos
se <- SummarizedExperiment(assays = list(counts = matriz_expr_t))
colData(se) <- DataFrame(row.names = colnames(matriz_expr_t), IID = colnames(matriz_expr_t))

# calcular scores con NetActivity 
se_prep <- prepareSummarizedExperiment(se, "gtex_gokegg")
scores <- computeGeneSetScores(se_prep, model = "gtex_gokegg")

# se_prep <- prepareSummarizedExperiment(se, "tcga_gokegg")
# scores <- computeGeneSetScores(se_prep, model = "tcga_gokegg")
cat("Número de vías KEGG obtenidas:", nrow(scores), "\n")

#  Resultado final 
score_matrix <- assay(scores)
score_matrix[1:5, 1:5]

##########################################################################################################
#          analisis vías más significativas por p-valor crudo 
##########################################################################################################

library(dplyr)
library(limma)
library(ggplot2)

# Convertir score_matrix a data frame
score_data <- as.data.frame(t(score_matrix))  
score_data$IID <- rownames(score_data)

# t-test para seleccionar los genset mas significativos
score_data_test <- left_join(score_data, fam, by = "IID")

score_data_test <- score_data_test %>%
  mutate(Grupo = factor(Phenotype, levels = c(1, 2), labels = c("control", "case")))


# score_data_test contiene los valores por vía + columna Grupo
genes <- setdiff(colnames(score_data), "IID")


# Subset solo con geneset y la variable respuesta
score_data_subset <- score_data_test %>%
  dplyr::select(all_of(genes), Grupo)

t_test_resultados <- lapply(genes, function(gen) {
  res <- try(t.test(score_data_subset[[gen]] ~ score_data_subset$Grupo), silent = TRUE)
  if (inherits(res, "try-error") || is.na(res$p.value)) {
    return(NULL)
  } else {
    return(data.frame(
      Pathway = gen,
      p_value = res$p.value,
      t_stat = res$statistic,
      mean_control = res$estimate[1],
      mean_case = res$estimate[2],
      mean_diff = res$estimate[2] - res$estimate[1],
      conf_low = res$conf.int[1],
      conf_high = res$conf.int[2]
    ))
  }
})


# Combinar
resultados_df <- do.call(rbind, t_test_resultados)
rownames(resultados_df) <- NULL

# Agregar p-valor ajustado
resultados_df <- resultados_df %>%
  mutate(
    p_adj = p.adjust(p_value, method = "BH"),
    log10p = -log10(p_value),
    Significativo = p_value < 0.05
  ) %>%
  arrange(p_value)

table(resultados_df$Significativo)

# Visualización 
library(knitr)
library(kableExtra)

top10 <- resultados_df |>
  arrange(p_value) |>
  dplyr::select(Pathway, p_value, p_adj, t_stat, mean_control, mean_case, mean_diff, conf_low, conf_high, log10p, Significativo) |>
  head(10)

top10 %>%
  kable("html", caption = "Top 10 vías más significativas por p-valor crudo en tejido sangre", digits = 5) %>%
  kable_styling(full_width = FALSE, bootstrap_options = c("striped", "hover")) %>%
  save_kable(file = file.path(salida, "Tablas", "Top10_vias_significativas_sangre.html"))


##################################################################################################################################
#                            analisis con modelo  limma 
##################################################################################################################################

# Unir los datos en un solo dataset


datos_finales <- left_join(score_data, fam, by = "IID")
datos_finales <- left_join(datos_finales, metadatos_edad, by = "IID")
datos_finales <- left_join(datos_finales, pcs, by = "IID")

ncol(datos_finales)
table(datos_finales$Phenotype)

datos_finales$Phenotype <- ifelse(datos_finales$Phenotype == 1, "control", 
                                  ifelse(datos_finales$Phenotype == 2, "case", NA))


table(datos_finales$Phenotype)

datos_finales$Phenotype <- factor(datos_finales$Phenotype, levels = c("control", "case"))

datos_finales$AGE <- factor(datos_finales$AGE, ordered = TRUE)

# Diseño de modelo
design <- model.matrix(~ Phenotype +  PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, data = datos_finales)
stopifnot(ncol(score_matrix) == nrow(datos_finales))

colnames(design)


# Transponer primero para que filas = muestras
score_matrix_t <- t(score_matrix)

# Eliminar columnas (vías) con varianza cero
score_matrix_filtrado <- score_matrix_t[, apply(score_matrix_t, 2, function(x) var(x) > 0)]
score_matrix_filtrado <-  t(score_matrix_filtrado)

# Verifica dimensiones
dim(score_matrix_filtrado)  

library(limma)
fit <- lmFit(score_matrix_filtrado, design)
fit <- eBayes(fit)
top_res <- topTable(fit, coef = "Phenotypecase", number = Inf)

# Volcano plot
library(ggplot2)
library(dplyr)

# Asegurar la columna de significancia 
top_res$Significancia <- ifelse(top_res$P.Value < 0.05, "Significativo", "No significativo")
top_res$Significancia <- factor(ifelse(top_res$P.Value < 0.05, 
                                       "Significativo", "No significativo"),
                                levels = c("No significativo", "Significativo"))


top_res$Pathway <- rownames(top_res)


# Graficar 
g4 <- ggplot(top_res, aes(x = logFC, y = -log10(P.Value))) +
  geom_point(aes(color = Significancia), alpha = 0.7, size = 1.5) +
  geom_text(
    data = subset(top_res, P.Value < 0.01 & abs(logFC) > 0.05),
    aes(label = Pathway),
    color = "black", vjust = 1.2, size = 2.5, check_overlap = TRUE
  ) +
  geom_hline(aes(yintercept = -log10(0.05), linetype = "Umbral p-valor = 0.05"),
             color = "#E74C3C", linewidth = 0.7) +
  scale_color_manual(
    values = c("No significativo" = "#2C3E50", "Significativo" = "#E74C3C")
  ) +
  scale_linetype_manual(name = "Referencia", values = c("Umbral p-valor = 0.05" = "dashed")) +
  theme_minimal(base_size = 13) +
  labs(
    title = "Análisis limma con NetActivity en tejido sangre",
    x = "log Fold Change",
    y = "-log10(p-valor)",
    color = "Significancia"
  ) +
  theme(
    legend.title = element_text(face = "bold"),
    legend.text = element_text(size = 11),
    plot.title = element_text(face = "bold", size = 14)
  )
 
ggsave(file.path(salida, "Análisis_limma_con_NetActivity_en_tejido_sangre.png"), plot = g4, width = 9, height = 5)


##############################################################################################################
#           Análisis regresión logística con Lasso + Validación
##############################################################################################################

library(glmnet)
library(dplyr)
library(pROC)
library(stringr)
library(ggplot2)
library(caret) 



#  DIVISIÓN DE LOS DATOS 
datos_finales$AGE <- NULL
datos_finales$IID <- NULL
set.seed(123)
train_idx <- sample(seq_len(nrow(datos_finales)), size = 0.8 * nrow(datos_finales))
train_data <- datos_finales[train_idx, ]
test_data  <- datos_finales[-train_idx, ]

# Separar variable respuesta
y_train <- train_data$Phenotype
y_test  <- test_data$Phenotype

# Extraer solo variables numéricas predictoras
X_train <- train_data %>% dplyr::select(-Phenotype)
X_test  <- test_data %>% dplyr::select(-Phenotype)

# Escalado Z-score en train
preproc <- preProcess(X_train, method = c("center", "scale"))

X_train_scaled <- predict(preproc, X_train)
X_test_scaled  <- predict(preproc, X_test)



train_scaled_df <- data.frame(Phenotype = y_train, X_train_scaled)
test_scaled_df  <- data.frame(Phenotype = y_test,  X_test_scaled)

# Volver a separar X e y desde los data frames escalados
X_train_final <- train_scaled_df %>% dplyr::select(-Phenotype)
y_train_final <- train_scaled_df$Phenotype
y_train_final <- ifelse(y_train_final == "case", 1, 0)

X_test_final  <- test_scaled_df %>% dplyr::select(-Phenotype)
y_test_final  <- test_scaled_df$Phenotype
y_test_final <- ifelse(y_test_final == "case", 1, 0)

# Convertir a matriz 
X_train_mat <- as.matrix(X_train_final)
X_test_mat  <- as.matrix(X_test_final)

stopifnot(!anyNA(X_train_mat))
stopifnot(!anyNA(X_test_mat))

# Ajustar modelo con validación cruzada 
set.seed(123)
cv_lasso <- cv.glmnet(
  X_train_mat,
  y_train_final,
  family = "binomial",
  alpha = 1,
  type.measure = "auc"   
)

# Mejor lambda
best_lambda <- cv_lasso$lambda.min
cat("Mejor lambda:", best_lambda, "\n")

# Ajustar modelo final con ese lambda
lasso_model <- glmnet(
  X_train_mat,
  y_train_final,
  family = "binomial",
  alpha = 1,
  lambda = best_lambda
)


# Evaluación en TRAIN

train_pred <- predict(lasso_model, newx = X_train_mat, type = "response")
roc_train <- roc(y_train_final, as.numeric(train_pred))
cat("AUC (Train):", auc(roc_train), "\n")


# Evaluación en TEST

test_pred <- predict(lasso_model, newx = X_test_mat, type = "response")
roc_test <- roc(y_test_final, as.numeric(test_pred))
cat("AUC (Test):", auc(roc_test), "\n")


# Curvas ROC 

library(ggplot2)
library(pROC)

# Extraer datos de curvas
df_train <- data.frame(
  specificity = rev(roc_train$specificities),
  sensitivity = rev(roc_train$sensitivities),
  dataset = "Entrenamiento"
)

df_test <- data.frame(
  specificity = rev(roc_test$specificities),
  sensitivity = rev(roc_test$sensitivities),
  dataset = "Test"
)

df <- rbind(df_train, df_test)

# Plot 
g5 <- ggplot(df, aes(x = 1 - specificity, y = sensitivity, color = dataset)) +
  geom_line(linewidth = 1.2) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray") +
  theme_minimal(base_size = 14) +
  labs(title = "Curva ROC del modelo en tejido de sangre (entrenamiento y test)",
       x = "1 - Especificidad (FPR)",
       y = "Sensibilidad (TPR)",
       color = "Conjunto") +
  scale_color_manual(values = c("Entrenamiento" = "blue", "Test" = "red")) +
  annotate("text", x = 0.95, y = 0.10,
           label = paste0("AUC Entrenamiento = ", round(auc(roc_train), 3)),
           color = "black") +
  annotate("text", x = 0.95, y = 0.03,
           label = paste0("AUC Test = ", round(auc(roc_test), 3)),
           color = "black")

ggsave(file.path(salida, "Curva_ROC_del_modelo_en_tejido_de_sangre_entrenamiento_y_test.png"), plot = g5, width = 8, height = 5)

##############################################################################################################
#              Extraer variables seleccionadas por el modelo Lasso
##############################################################################################################

# Obtener coeficientes del modelo
coef_lasso <- coef(lasso_model)

# Pasar a data frame
coef_df <- as.data.frame(as.matrix(coef_lasso))
coef_df$Variable <- rownames(coef_df)
colnames(coef_df)[1] <- "Coef"

# Filtrar solo variables con coef ≠ 0 (excluye intercepto)
selected_vars <- coef_df %>%
  dplyr::filter(Coef != 0 & Variable != "(Intercept)") %>%
  arrange(desc(abs(Coef)))

# Mostrar las primeras
head(selected_vars, 20)

best_lambda_1se <- cv_lasso$lambda.1se
lasso_model_1se <- glmnet(
  X_train_mat, y_train_final,
  family = "binomial", alpha = 1,
  lambda = best_lambda_1se
)

coef_1se <- coef(lasso_model_1se)
selected_vars_1se <- as.data.frame(as.matrix(coef_1se)) %>%
  tibble::rownames_to_column("Variable") %>%
  dplyr::rename(Coef = 2) %>%
  filter(Coef != 0 & Variable != "(Intercept)") %>%
  arrange(desc(abs(Coef)))
head(selected_vars_1se, 20)

str(selected_vars)

library(broom)
library(dplyr)
library(ggplot2)

# crear Variables seleccionadas 
selected_features <- selected_vars %>%
  filter(!grepl("^PC", Variable)) %>%
  pull(Variable)

# Reajustar modelo logístico clásico con esas variables
formula <- as.formula(
  paste("Phenotype ~", paste(selected_features, collapse = " + "))
)

glm_fit <- glm(formula, data = train_scaled_df, family = binomial)

# Extraer coeficientes con OR e IC95%
results <- tidy(glm_fit, conf.int = TRUE, exponentiate = TRUE)

# Filtrar solo las vías (no intercepto)
results <- results %>%
  filter(term != "(Intercept)") %>%
  arrange(desc(estimate))

# Seleccionar las vías con OR < 0.85 o > 1.15 y p < 0.05
results_filtered <- results %>%
  mutate(abs_effect = abs(log(estimate))) %>%
  arrange(desc(abs_effect)) %>%
  filter((estimate < 0.85 | estimate > 1.15) & p.value < 0.05)

# Mostrar cuántas quedaron
cat("Número de vías seleccionadas:", nrow(results_filtered), "\n")
print(results_filtered %>% dplyr::select(term, estimate, conf.low, conf.high, p.value))

# Plot 
library(broom)
library(dplyr)
library(ggplot2)

# Plot 
g6 <- ggplot(results_filtered, aes(x = estimate, y = reorder(term, estimate))) +
  geom_point(size = 3, color = "black") +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high),
                 height = 0.2, color = "gray40") +
  geom_vline(xintercept = 1, linetype = "dashed", color = "gray40") +
  labs(
    x = "Odds Ratio (OR)",
    y = "Pathways (GO term)",
    title = "Asociación entre vías génicas seleccionadas\n en tejido de sangre y el riesgo de la enfermedad (OR e IC95%)"
  ) +
  coord_cartesian(xlim = c(0.75, 1.40)) +  
  scale_x_continuous(breaks = seq(0.75, 1.40, 0.05)) +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    axis.title = element_text(face = "bold"),
    axis.text.y = element_text(size = 12),
    axis.text.x = element_text(size = 12)
  )

ggsave(file.path(salida, "Odd_tario_tejido_sangre.png"), plot = g6, width = 8, height = 6)
