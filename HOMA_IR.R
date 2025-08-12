
# Insulin resistance data
# If insulin or glucose is missing, set HOMA-IR to be missing
homa <- read_csv("./data/HAT_LabResults w HOMA IR calculated.csv")

# The data is in long format
# 948 obs in visit 8
homa %>% 
  group_by(visitcode) %>% 
  tally()

# Descriptive on HOMA-IR
summary(homa$HOMA_IR)

# Extreme outliers
homa %>% 
  filter(HOMA_IR > 100)

# Zero values
homa %>% 
  filter(HOMA_IR == 0) %>% 
  print(n = Inf)

# Extract only visit 8
homa_visit8 <- homa %>% 
  filter(visitcode == "V08")

summary(homa_visit8$HOMA_IR)

# No insulin resistance data for 6 subjects
df %>% 
  semi_join(homa_visit8, by = "pid") %>% 
  nrow()

df %>% 
  anti_join(homa_visit8, by = "pid") %>% 
  select(pid)

# Left-join with df
df_ins <- df %>% 
  left_join(homa_visit8, by = "pid")

# PIDs with missing HOMA_IR at visit 8
df_ins %>% 
  filter(is.na(HOMA_IR)) %>% 
  select(pid, Insulin, glucose, HOMA_IR)

# Cut off values: glucose 240, insulin 50
df_ins %>% 
  filter(glucose >= 240) %>% 
  select(pid, randarm, glucose, Insulin, HOMA_IR)

df_ins %>% 
  filter(Insulin >= 50) %>% 
  select(pid, randarm, glucose, Insulin, HOMA_IR)

df_ins %>% 
  filter(Insulin >= 50 | glucose >= 240) %>% 
  select(pid, randarm, glucose, Insulin, HOMA_IR)

# If insulin or glucose is missing, exclude (n = 888)
# Exclude if glucose >= 240 or insulin >= 50
# Yields n = 858 
df_ins2 <- df_ins %>%
  filter(!is.na(Insulin) & !is.na(glucose)) %>% 
  filter(glucose < 240, Insulin < 50)


# Check extreme HOMA-IR values  
df_ins2 %>% 
  filter(HOMA_IR > 20) %>% 
  arrange(HOMA_IR) %>% 
  select(pid, randarm, visitcode, SexM, bmi, weight, waist, hff_Post, Insulin, glucose, HOMA_IR)

# Distribution of HOMA-IR
p1 <- df_ins2 %>% 
  ggplot(aes(x = HOMA_IR)) +
  geom_histogram() + 
  labs(title = "Histogram of HOMA-IR")

p2 <- df_ins2 %>% 
  ggplot(aes(x = HOMA_IR)) +
  stat_ecdf() +
  geom_vline(xintercept = 2.36, color = "red", linetype = 2) + 
  geom_vline(xintercept = 4.36, color = "red", linetype = 2) + 
  labs(title = "Empirical CDF of HOMA-IR", y = "Cumulative CDF")

library(patchwork)
p1 + p2

# Create tertile groups
tertile_breaks <- quantile(df_ins2$HOMA_IR, probs = 0:3/3, na.rm = TRUE)
df_ins3 <- df_ins2 %>%
  mutate(HOMA_IR3 = cut(HOMA_IR, breaks = tertile_breaks, include.lowest = TRUE),
         HOMA_IR3 = factor(HOMA_IR3, labels = c("Tertile1", "Tertile2", "Tertile3")))

# Descriptive stats on HOMA-IR by its tertile group
df_ins3 %>% 
  group_by(HOMA_IR3) %>% 
  summarize(n = n(),
            min = min(HOMA_IR),
            max = max(HOMA_IR),
            mean = mean(HOMA_IR),
            median = median(HOMA_IR))

# Table 1 -----------------------------------------------------------------

table_vars <- c("SexM", "age", "Race2", "Educ3", "bmi", "Trt", "hff_Pre", "hff_Post", "GL", "GI", "kcal", "SFA_ea", "HOMA_IR")

CreateTableOne(table_vars, data = df_ins3) %>% 
  print(showAllLevels = TRUE, nonnormal = c("hff_Pre", "hff_Post", "HOMA_IR"))

df_ins3 %>% 
  select(Trt) %>% 
  table()

# Linear models -----------------------------------------------------------
library(gtsummary)

# Change units
# Create tertile groups
df_ins3_mod <- df_ins3 %>% 
  # filter(HOMA_IR < 15) %>% 
  mutate(GL10 = GL / 10,
         # GI100 = GI / 100,
         GI10 = GI / 10,
         kcal100 = kcal / 100,
         avg_avoc_100gd = avg_avoc_gd / 100) %>% 
  mutate(GL_cat3 = cut(GL, quantile(GL, 0:3/3), include.lowest = TRUE),
         GL_cat3 = factor(GL_cat3, labels = c("1st tertile", "2nd tertile", "3rd tertile")),
         GI_cat3 = cut(GI, quantile(GI, 0:3/3), include.lowest = TRUE),
         GI_cat3 = factor(GI_cat3, labels = c("1st tertile", "2nd tertile", "3rd tertile")))

summary(df_ins3_mod$HOMA_IR)
df_ins3 %>% nrow()

df_ins3 %>% 
  filter(HOMA_IR < 15) %>% 
  nrow()

df_ins3 %>% 
  filter(HOMA_IR < 10) %>% 
  nrow()

# Model for GL
# Both control and intervention
# fit_gl <- lm(log(hff_Post) ~ GL10 + SexM + age + Race2 + Educ3 + HOMA_IR3, data = df_ins3_mod)
fit_gl <- lm(log(hff_Post) ~ GL10 + SexM + age + Race2 + Educ3 + HOMA_IR3 + GL10 * HOMA_IR3, data = df_ins3_mod)
summary(fit_gl)

# Base model with demographics
var_labs <- list(GL10 = "GL/10", SexM = "Sex", age = "Age", Race2 = "Race", Educ3 = "Education")

t1 <- tbl_regression(fit_gl, 
               label = var_labs,
               estimate_fun = label_style_number(digits = 3),
               pvalue_fun   = label_style_pvalue(digits = 3)) %>% 
  add_global_p(keep = TRUE, include = Educ3)

# Base + BMI
t2 <- update(fit_gl, .~. + bmi) %>%
  tbl_regression(label = c(var_labs, bmi = "BMI"),
                 estimate_fun = label_style_number(digits = 3),
                 pvalue_fun = label_style_pvalue(digits = 3)) %>% 
  add_global_p(keep = TRUE, include = Educ3)

# Base + dietary variables (including kcal) 
t3 <- update(fit_gl, .~. + kcal100) %>%
  tbl_regression(label = c(var_labs, 
                           kcal100 = "Energy (per 100 kcal)"),
                 estimate_fun = label_style_number(digits = 3),
                 pvalue_fun = label_style_pvalue(digits = 3)) %>% 
  add_global_p(keep = TRUE, include = Educ3)

# Model comparisons
tbl_merge <- tbl_merge(tbls = list(t1, t2, t3),
                        tab_spanner = c("**Model 1**", "**Model 2**", "**Model 3**")) %>% 
  modify_header(label = "**Variable**", 
                p.value_1 = "**p**", 
                p.value_2 = "**p**", 
                p.value_3 = "**p**")

tbl_merge

# Models for GI
# Both control and intervention
# fit_gi <- lm(log(hff_Post) ~ GI10 + SexM + age + Race2 + Educ3 + HOMA_IR3, data = df_ins3_mod)
fit_gi <- lm(log(hff_Post) ~ GI10 + SexM + age + Race2 + Educ3 + HOMA_IR3 + GI10 * HOMA_IR3, data = df_ins3_mod)
summary(fit_gi)
anova(fit_gi)

# Base model with demographics
var_labs <- list(GI10 = "GI/10", SexM = "Sex", age = "Age", Race2 = "Race", Educ3 = "Education")

t1 <- tbl_regression(fit_gi, 
               label = var_labs,
               estimate_fun = label_style_number(digits = 3),
               pvalue_fun   = label_style_pvalue(digits = 3)) %>% 
  add_global_p(keep = TRUE, include = Educ3)

# Base + BMI
t2 <- update(fit_gi, .~. + bmi) %>%
  tbl_regression(label = c(var_labs, bmi = "BMI"),
                 estimate_fun = label_style_number(digits = 3),
                 pvalue_fun = label_style_pvalue(digits = 3)) %>% 
  add_global_p(keep = TRUE, include = Educ3)

# Base + dietary variables (including kcal) 
t3 <- update(fit_gi, .~. + kcal100) %>%
  tbl_regression(label = c(var_labs, 
                           kcal100 = "Energy (per 100 kcal)"),
                 estimate_fun = label_style_number(digits = 3),
                 pvalue_fun = label_style_pvalue(digits = 3)) %>% 
  add_global_p(keep = TRUE, include = Educ3)

# Model comparisons
tbl_merge <- tbl_merge(tbls = list(t1, t2, t3),
                        tab_spanner = c("**Model 1**", "**Model 2**", "**Model 3**")) %>% 
  modify_header(label = "**Variable**", 
                p.value_1 = "**p**", 
                p.value_2 = "**p**", 
                p.value_3 = "**p**")

tbl_merge
