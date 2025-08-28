
# Cargar librerias
library(readr)
library(dplyr)
library(ggplot2)
library(stringr)
library(tidyverse)
library(pROC)
library(glmnet)

# Ruta de archivos y salida
BASE_PATH <- Sys.getenv("BASE_PATH")

salida <- file.path(BASE_PATH, "Figuras")

setwd(BASE_PATH)

# Leer PGS y FAM
pgs_data <- read_tsv(file.path(BASE_PATH,"Results/PGS_Results/PGS000001_run_20250828_072946/proyecto/score/aggregated_scores.txt.gz"))
pgs_data <- pgs_data %>%
  mutate(IID = str_extract(IID, "(?<=_).*"))


fam <- read.table(file.path(BASE_PATH,"Results/Correcciones_Raw_data/nhs_subjects_hg19_final.fam"), header = FALSE)
colnames(fam) <- c("FID", "IID", "PID", "MID", "Sex", "Phenotype")
fam$Phenotype <- factor(fam$Phenotype, levels = c(1, 2), labels = c("control", "case"))

pgs_merged <- inner_join(pgs_data, fam, by = "IID")

# Boxplot PGS
g1 <- ggplot(pgs_merged, aes(x = Phenotype, y = SUM, fill = Phenotype)) +
  geom_boxplot() +
  labs(title = "Comparación de PGS por grupo", y = "PGS (Polygenic Score)", x = "") +
  theme_minimal()

ggsave(file.path(salida, "Comparación_de_PGS_por_grupo.png"), plot = g1, width = 9, height = 5)

# Wilcoxon test
wilcox.test(SUM ~ Phenotype, data = pgs_merged)


# Regresión logística simple con PGS escalado
pgs_merged$Grupo_bin <- ifelse(pgs_merged$Phenotype == "case", 1, 0)
pgs_merged$SUM_scaled <- as.numeric(scale(pgs_merged$SUM))

modelo2 <- glm(Grupo_bin ~ SUM_scaled, data = pgs_merged, family = "binomial")

# Gráfico regresión logística
nuevo_df <- data.frame(
  SUM_scaled = seq(min(pgs_merged$SUM_scaled),
                   max(pgs_merged$SUM_scaled),
                   length.out = 300)
)
pred <- predict(modelo2, newdata = nuevo_df, type = "link", se.fit = TRUE)
nuevo_df$fit <- plogis(pred$fit)
nuevo_df$lower <- plogis(pred$fit - 1.96 * pred$se.fit)
nuevo_df$upper <- plogis(pred$fit + 1.96 * pred$se.fit)

g2 <- ggplot(pgs_merged, aes(x = SUM_scaled, y = Grupo_bin)) +
  geom_jitter(height = 0.05, width = 0, alpha = 0.2, color = "gray40") +
  geom_line(data = nuevo_df, aes(x = SUM_scaled, y = fit),
            inherit.aes = FALSE, color = "firebrick", linewidth = 1.2) +
  geom_ribbon(data = nuevo_df, aes(x = SUM_scaled, ymin = lower, ymax = upper),
              inherit.aes = FALSE, alpha = 0.2, fill = "firebrick") +
  labs(
    title = "Regresión logística: PGS escalado vs Probabilidad de ser caso",
    x = "PGS escalado",
    y = "Probabilidad estimada"
  ) +
  theme_minimal()

ggsave(file.path(salida, "Regresión_logística_PGS.png"), plot = g2, width = 9, height = 5)

# Modelo con PCs + validación (train/test) 
pcs <- read_tsv(file.path(BASE_PATH, "Results/PCA_results/PCA_subjects.tsv"))
pgs_completo <- left_join(pgs_merged, pcs, by = "IID")%>%
  mutate(SUM_scaled = as.numeric(scale(SUM)))

# Correlación entre PGS y PCs
library(corrplot)

cor_matrix <- cor(pgs_completo %>% dplyr::select(SUM, PC1:PC10))

png(file.path(salida, "Correlacion_PGS_con_PCs.png"), width = 900, height = 600)
corrplot(cor_matrix, method = "color", type = "full", addCoef.col = "black",
         tl.col = "black", tl.srt = 45, number.cex = 0.7,
         title = "Correlación entre PGS (SUM) y los primeros 10 PCs",
         mar = c(0,0,2,0))
dev.off()

set.seed(123)
train_idx <- sample(seq_len(nrow(pgs_completo)), size = 0.8 * nrow(pgs_completo))
train_data <- pgs_completo[train_idx, ]
test_data  <- pgs_completo[-train_idx, ]

X_train <- as.matrix(train_data %>% dplyr::select(SUM_scaled, PC1:PC10))
y_train <- train_data$Grupo_bin
X_test  <- as.matrix(test_data %>% dplyr::select(SUM_scaled, PC1:PC10))
y_test  <- test_data$Grupo_bin

cv_lasso <- cv.glmnet(
  X_train, y_train,
  family = "binomial",
  alpha = 1,
  type.measure = "auc"
)
best_lambda <- cv_lasso$lambda.min
modelo_penalizado <- glmnet(X_train, y_train, family = "binomial", alpha = 1, lambda = best_lambda)

pred_train <- predict(modelo_penalizado, newx = X_train, type = "response")
roc_train <- roc(y_train, as.numeric(pred_train))
pred_test <- predict(modelo_penalizado, newx = X_test, type = "response")
roc_test <- roc(y_test, as.numeric(pred_test))

# Curva ROC Train/Test
df_train <- data.frame(specificity = rev(roc_train$specificities),
                       sensitivity = rev(roc_train$sensitivities),
                       dataset = "Entrenamiento")
df_test <- data.frame(specificity = rev(roc_test$specificities),
                      sensitivity = rev(roc_test$sensitivities),
                      dataset = "Test")
df <- rbind(df_train, df_test)

g3 <- ggplot(df, aes(x = 1 - specificity, y = sensitivity, color = dataset)) +
  geom_line(linewidth = 1.2) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray") +
  theme_minimal(base_size = 14) +
  labs(title = "Curva ROC del modelo con PGS", x = "1 - Especificidad (FPR)", y = "Sensibilidad (TPR)", color = "Conjunto") +
  scale_color_manual(values = c("Entrenamiento" = "blue", "Test" = "red")) +
  annotate("text", x = 0.75, y = 0.15,
           label = paste0("AUC Train = ", round(auc(roc_train), 3)),
           color = "blue", hjust = 0) +
  annotate("text", x = 0.75, y = 0.05,
           label = paste0("AUC Test = ", round(auc(roc_test), 3)),
           color = "red", hjust = 0)

ggsave(file.path(salida, "Curva_ROC_del_modelo_con_PGS.png"), plot = g3, width = 9, height = 5)

# Forest plot 
modelo_pcs <- glm(Grupo_bin ~ SUM_scaled + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10,
                  data = pgs_completo, family = "binomial")

coef_summary <- summary(modelo_pcs)$coefficients
or_df <- data.frame(
  Variable = rownames(coef_summary),
  Estimate = coef_summary[, "Estimate"],
  StdErr = coef_summary[, "Std. Error"],
  p.value = coef_summary[, "Pr(>|z|)"]
) %>%
  mutate(
    OR = exp(Estimate),
    Lower = exp(Estimate - 1.96 * StdErr),
    Upper = exp(Estimate + 1.96 * StdErr)
  ) %>%
  filter(Variable != "(Intercept)")

or_df_top <- or_df %>%
  filter(OR > 0 & OR <= 5) %>%
  arrange(desc(OR)) %>%
  slice_head(n = 10) %>%
  mutate(Variable = reorder(Variable, OR))

g4 <- ggplot(or_df_top, aes(x = OR, y = Variable)) +
  geom_point(size = 3, color = "firebrick") +
  geom_errorbarh(aes(xmin = Lower, xmax = Upper), height = 0.25, color = "gray40") +
  geom_vline(xintercept = 1, linetype = "dashed", color = "black") +
  scale_x_continuous(limits = c(0, 5), breaks = seq(0, 5, by = 1)) +
  labs(title = "OR PGS", x = "Odds Ratio", y = NULL) +
  theme_minimal(base_size = 14) +
  theme(axis.text.y = element_text(size = 11, face = "bold"),
        plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave(file.path(salida, "OR_PGS.png"), plot = g4, width = 9, height = 5)

