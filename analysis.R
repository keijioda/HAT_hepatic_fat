
# HAT: hepatic fat and GI/GL

# Setup -------------------------------------------------------------------

# Required packages
pacs <- c("tidyverse", "haven", "ggExtra", "tableone", "ggResidpanel", "emmeans")
sapply(pacs, require, character.only = TRUE)


# Subject demographics ----------------------------------------------------

# Subjects: n = 961
demog <- read_sas("./data/final_n961_foodgroups_june2024.sas7bdat") %>% 
  mutate(SexM  = factor(sex, labels = c("F", "M"))) %>% 
  mutate(Trt   = factor(randarm, labels = c("Cntrl", "Avocado"))) %>% 
  mutate(Educ3 = factor(Edu_New, labels = c("LTCollege", "College", "Postgrad"))) %>% 
  mutate(Race2 = factor(Race_New, labels = c("NonWhite", "White", "NonWhite", "NonWhite", "NonWhite")),
         Race2 = relevel(Race2, "White"),
         Race3 = factor(Race_New, labels = c("AA", "White", "Other", "Other", "Other")),
         Race3 = relevel(Race3, "White"))

names(demog)

# pid all unique
demog %>% distinct(pid) %>% nrow()

# Treatment group
demog %>%
  group_by(randarm) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

demog %>%
  group_by(Trt) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

# Sex: 0 = Female, 1 = Male
demog %>%
  group_by(sex) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

demog %>%
  group_by(SexM) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

# age: 25 to 86 years
summary(demog$age)
demog %>% ggplot(aes(x = age)) + geom_histogram()

# Education
demog %>%
  group_by(Edu_New) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

demog %>%
  group_by(Educ3) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

# BMI: 20 to 60
summary(demog$bmi)
demog %>% ggplot(aes(x = bmi)) + geom_histogram()

# Race/Ethnicity
demog %>% 
  select(starts_with("Race"))

demog %>% 
  group_by(hispanic) %>% 
  tally()

# Race_New
# 1: AA
# 4: White
# 5: Asian
# 6: Other
# 7: Mixed
demog %>% 
  group_by(Race_New) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

demog %>% 
  group_by(Race2) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

demog %>% 
  group_by(Race3) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

# GL/GI
demog %>% 
  select(avg_GL_glucose, avg_GI_glucose) %>% 
  summary()

# Hepatic fat measurements ------------------------------------------------

# Date randomized
# n distinct = 1008
randdate <- read_csv("./data/HAT_KeyVariables.csv") %>% 
  mutate(d_randomized = as.Date(d_randomized, format = "%d%b%Y")) %>% 
  select(pid, d_randomized)

# MRI measurement of hepatic fat
# n obs = 1932
# n distinct = 1008
# hfat <- read_csv("./data/HAT_HFF.csv") %>% 
hfat <- read_csv("./data/HAT_HFF_SN_fixed.csv") %>% 
  mutate(mridate = as.Date(mridate, format = "%d%b%y")) %>% 
  inner_join(randdate, by = "pid") %>% 
  mutate(prepost = ifelse(mridate <= d_randomized, 0, 1))

# Number of MRIs
n_MRI <- hfat %>% 
  group_by(pid) %>% 
  tally()

# hfat %>% 
#   inner_join(n_MRI) %>% 
#   write_csv("./data/HAT_HFF_v2.csv", na = "")

# How many have two MRIs? -- 924 subjects
hfat %>% 
  inner_join(n_MRI) %>% 
  filter(n == 2) %>% 
  distinct(pid)

# There are 3 subjects who have 2 MRIs after randomization
hfat %>% 
  inner_join(n_MRI) %>% 
  filter(n == 2) %>% 
  filter(prepost == 1) %>% 
  group_by(pid) %>% 
  tally() %>% 
  filter(n > 1)

# n = 84 subjcts with 1 MRI or no MRI
hfat %>% 
  inner_join(n_MRI) %>% 
  filter(n < 2) %>% 
  distinct(pid)

# n = 81 subjcts with 1 MRI
hfat %>% 
  inner_join(n_MRI) %>% 
  filter(n == 1) %>% 
  filter(!is.na(hff)) %>% 
  distinct(pid)

hfat %>% 
  inner_join(n_MRI) %>% 
  filter(n == 1) %>% 
  filter(!is.na(hff)) %>% 
  group_by(prepost) %>% 
  tally()
 
# There are n = 3 subjects with no MRI measurements 
hfat %>%
  inner_join(n_MRI) %>% 
  filter(is.na(hff))

# Check: Total n obs = 1932
924 * 2 + (81 + 3)

# Wide format data
# This excludes those with 2 MRIs after randomization (3 subjects)
# and those with no MRI (3 subjects)
hfat_wide <- hfat %>% 
  filter(!is.na(mridate)) %>% 
  filter(!pid %in% c(15154629, 15217132, 15235033)) %>% 
  mutate(prepost = factor(prepost, labels = c("Pre", "Post"))) %>%
  select(pid, hff, FWHM, prepost) %>% 
  pivot_wider(names_from = prepost, values_from = c(hff, FWHM))

hfat_wide %>% print(n = Inf)

# Checking distributions
# Hepatic fat fraction
hfat %>% 
  select(hff, FWHM, sn) %>%
  # mutate(hff = hff * 100) %>% 
  summary()

hfat %>% 
  filter(is.na(hff))

p1 <- hfat %>% 
  ggplot(aes(x = hff)) +
  geom_histogram() +
  geom_vline(xintercept = c(0.05, 0.1, 0.2, 0.3), linetype = 2) +
  labs(x = "Hepatic fat fraction")

p2 <- hfat %>% 
  ggplot(aes(x = hff)) +
  stat_ecdf(geom = "step") +
  geom_vline(xintercept = c(0.05, 0.1, 0.2, 0.3), linetype = 2) +
  scale_y_continuous(n.breaks = 11) +
  labs(x = "Hepatic fat fraction", y = "Empirical CDF")

p3 <- hfat %>% 
  ggplot(aes(x = hff)) +
  geom_histogram() +
  scale_x_continuous(trans = "log10") +
  geom_vline(xintercept = c(0.05, 0.1, 0.2, 0.3), linetype = 2) +
  labs(x = "Hepatic fat fraction (log-scale)")

library(patchwork)
p1 + p2

# pdf("Histogram_HFF.pdf", height = 5, width = 10)
# p1 + p3
# dev.off()

hfat %>% 
  filter(!is.na(hff)) %>% 
  mutate(hff_cat = cut(hff, breaks = c(0, 0.05, 0.1, 0.2, 0.3, Inf)),
         hff_cat = factor(hff_cat, labels = c("Normal  : 0-5", "Mild    : 5-10", "Moderate: 10-20", "Severe  : 20-30", "Advanced: >30"))) %>% 
  group_by(hff_cat) %>% 
  tally() %>% 
  mutate(pct = n / sum(n) * 100)

hfat %>% 
  filter(!is.na(hff)) %>% 
  ggplot(aes(x = factor(prepost), y = hff)) +
  geom_point() +
  geom_line(aes(group = pid))

# Difference of HFF between pre and post
hfat_wide %>% 
  mutate(hff_diff = hff_Post - hff_Pre) %>%
  select(hff_diff) %>% summary()
  
hfat_wide %>% 
  mutate(hff_diff = hff_Post - hff_Pre) %>% 
  ggplot(aes(x = hff_diff)) +
  geom_histogram(aes(y = after_stat(count / sum(count)))) +
  scale_y_continuous(labels = scales::percent) +
  labs(x = "Change in HFF (post - pre)",
       y = "Percent")

hfat_wide %>% 
  mutate(hff_diff = hff_Post - hff_Pre) %>% 
  ggplot(aes(x = hff_diff)) +
  stat_ecdf(geom = "step")

hfat_wide %>% 
  mutate(hff_diff = hff_Post - hff_Pre) %>% 
  mutate(pid = factor(pid)) %>% 
  ggplot(aes(x = reorder(pid, hff_diff), y = hff_diff)) +
  geom_bar(stat = "identity")

hfat_wide %>% 
  mutate(hff_diff = hff_Post - hff_Pre) %>% 
  filter(!is.na(hff_diff)) %>% 
  filter(abs(hff_diff) > .2) %>% 
  # filter(abs(hff_diff) > .15) %>% 
  select(pid, hff_Pre, hff_Post, hff_diff) %>% 
  print(n = Inf)
  
hfat_wide %>% 
  mutate(hff_diff = hff_Post - hff_Pre) %>% 
  filter(abs(hff_diff) <= 0.2)
  
# SN: Higher SN is good, lower FWHM is good
summary(hfat$sn)

hfat %>% 
  ggplot(aes(x = sn)) +
  geom_histogram()

summary(hfat$FWHM)

hfat %>% 
  ggplot(aes(x = FWHM)) +
  geom_histogram()

hfat %>% 
  ggplot(aes(x = FWHM)) +
  geom_histogram() +
  scale_x_continuous(trans = "log10")

p <- hfat %>% 
  ggplot(aes(x = sn, y = FWHM)) +
  geom_point(color = "black") +
  # geom_point(data = hfat[hfat$sn < 0,], aes(x = sn, y = FWHM), color = "red") +
  labs(x = "S/N")

ggMarginal(p, type = "histogram")

hfat %>% 
  filter(sn < 100, FWHM > 0.6)

hfat %>% 
  mutate(logHFF = log(hff)) %>% 
  select(logHFF, FWHM, sn) %>% 
  pairs()

# p <- hfat %>% 
#   ggplot(aes(x = sn, y = hff)) +
#   geom_point(color = "black") +
#   geom_point(data = hfat[hfat$sn < 0,], aes(x = sn, y = hff), color = "red") +
#   labs(x = "S/N") +
#   scale_y_continuous(trans = "log10")
# 
# ggMarginal(p, type = "histogram")

# # Dietary data ------------------------------------------------------------
# 
# # Subjects: n = 961
# diet <- read_csv("./data/HAT_GL_GI_by_FG_updated_080224.csv")
# n_distinct(diet$cpartid)
# nrow(diet)
# names(diet)
# 
# # GL variables
# GL_vars <- names(diet) %>% grep("_GL", ., value = TRUE)
# diet %>% select(all_of(GL_vars)) %>% colMeans()
# 
# # GI variables
# GI_vars <- names(diet) %>% grep("_GI", ., value = TRUE)
# diet %>% select(all_of(GI_vars)) %>% colMeans()
# 
# # Average GL/GI by PID
# glgi <- diet %>% 
#   mutate(GL = rowSums(across(all_of(GL_vars)))) %>% 
#   mutate(GI = rowSums(across(all_of(GI_vars)))) %>%
#   group_by(cpartid) %>% 
#   summarize(GL = mean(GL), GI = mean(GI)) %>% 
#   rename(pid = cpartid)

# Dietary data for covariate from GS --------------------------------------

# Using SPSS data file: n = 1008
diet_other <- read_spss("./data/mean intake of selected nutriient covariates.sav")
nrow(diet_other)
names(diet_other)

# # When merged with GL/GI data, n = 961
# diet_other %>% semi_join(diet, by = c("pid" = "cpartid")) %>% nrow()

# When merged with demog data, n = 961
diet_other %>% semi_join(demog) %>% nrow()

# glgi2 <- glgi %>% 
#   inner_join(diet_other, by = "pid")

# Merge data --------------------------------------------------------------

hfat2 <- hfat %>% 
  left_join(demog %>% select(pid, bmi), by = "pid")

test <- hfat2 %>% 
  # filter(sn >= 100, FWHM <= 0.6) %>% 
  ggplot(aes(x = bmi, y = hff)) +
  geom_point() +
  scale_x_continuous(trans = "log10") +
  scale_y_continuous(trans = "log10") +
  geom_smooth() +
  labs(x = "BMI", y = "HFF")

ggMarginal(test, type = "histogram")

p4 <- test 

p5 <- hfat2 %>% 
  # filter(sn >= 100, FWHM <= 0.6) %>% 
  ggplot(aes(x = bmi, y = hff)) +
  geom_point() +
  # scale_x_continuous(trans = "log10") +
  # scale_y_continuous(trans = "log10") +
  geom_smooth() +
  labs(x = "BMI", y = "HFF")

# pdf("Scatter_HFF_BMI.pdf", height = 5, width = 10)
# p4 + p5
# dev.off()

# Pearson correlation on log scale: 0.318
hfat2 %>% 
  # filter(sn >= 100, FWHM <= 0.6) %>%
  select(bmi, hff) %>% 
  mutate(bmi = log(bmi), hff = log(hff)) %>% 
  cor(use = "pairwise")

pid_large_hff_change <- hfat_wide %>% 
  mutate(hff_diff = hff_Post - hff_Pre) %>% 
  filter(abs(hff_diff) > .2) %>% 
  distinct(pid)

hfat2 %>% 
  anti_join(pid_large_hff_change) %>% 
  select(bmi, hff) %>% 
  mutate(bmi = log(bmi), hff = log(hff)) %>% 
  cor(use = "pairwise")

demog %>% 
  mutate(bmi = log(bmi)) %>%
  ggplot(aes(x = bmi)) +
  geom_histogram()

# Inner-join yields n = 955 subjects
# There are 46 PIDs whose HFF post is missing
# There are  6 PIDs whose HFF pre  is missing
# After removing these, n = 903 subjects
df <- demog %>% 
  # inner_join(glgi2) %>% 
  inner_join(diet_other) %>% 
  inner_join(hfat_wide) %>% 
  filter(!is.na(hff_Post)) %>% 
  filter(!is.na(hff_Pre)) %>% 
  rename(GL = avg_GL_glucose,
         GI = avg_GI_glucose)

df %>% 
  select(hff_Pre, hff_Post) %>% 
  summary()

df %>% 
  ggplot(aes(x = hff_Post)) +
  geom_histogram()

df %>% 
  ggplot(aes(x = hff_Post)) +
  geom_histogram() +
  scale_x_continuous(trans = "log10")

df %>% 
  ggplot(aes(x = kcal)) +
  geom_histogram() +
  scale_x_continuous(trans = "log10")

df %>% 
  ggplot(aes(x = SFA)) +
  geom_histogram() +
  scale_x_continuous(trans = "log10")

df %>% 
  ggplot(aes(x = addsugar)) +
  geom_histogram() +
  scale_x_continuous(trans = "log10")

# SFA, addsugar, availcarb
df %>% 
  select(SFA, addsugar, availcarb) %>% 
  summary()

# Exploratory analysis ----------------------------------------------------

# Descriptive stats
df %>% 
  select(hff_Post, GL, GI) %>% 
  summary()

# Histograms
hist_hff <- df %>% 
  ggplot(aes(x = hff_Post)) + 
  geom_histogram() +
  labs(x = "Hepatic fat fraction (post-intervention)")

hist_gl <- df %>% 
  ggplot(aes(x = GL)) + 
  geom_histogram() +
  labs(x = "Glycemic load")

hist_gi <- df %>% 
  ggplot(aes(x = GI)) + 
  geom_histogram() +
  labs(x = "Glycemic index")

library(patchwork)
hist_hff + hist_gl + hist_gi

scatter_HFF_GL <- df %>% 
  ggplot(aes(x = GL, y = hff_Post)) +
  geom_point() +
  geom_smooth(span = 0.9) +
  scale_y_continuous(trans = "log10") +
  labs(x = "Glycemic load", y = "Hepatic fat fraction (log-scale)") +
  theme(legend.position = "bottom")

scatter_HFF_GI <- df %>% 
  ggplot(aes(x = GI, y = hff_Post)) +
  geom_point() +
  geom_smooth(span = 0.95) +
  scale_y_continuous(trans = "log10") +
  labs(x = "Glycemic index", y = "Hepatic fat fraction (log-scale)") +
  theme(legend.position = "bottom")

scatter_HFF_GL + scatter_HFF_GI

names(df)

df %>%
  ggplot(aes(x = GL, y = hff_Post, color = SexM, group = SexM)) +
  geom_point() +
  geom_smooth(span = 0.9, method = "lm") +
  scale_y_continuous(trans = "log10") +
  labs(x = "Glycemic load", y = "Hepatic fat fraction (log-scale)", color = "Gender") +
  theme(legend.position = "bottom")

df %>%
  ggplot(aes(x = GI, y = hff_Post, color = SexM, group = SexM)) +
  geom_point() +
  geom_smooth(span = 0.9, method = "lm") +
  scale_y_continuous(trans = "log10") +
  labs(x = "Glycemic index", y = "Hepatic fat fraction (log-scale)", color = "Gender") +
  theme(legend.position = "bottom")

df %>% 
  ggplot(aes(x = GL, y = hff_Post, color = Educ3, group = Educ3)) +
  geom_point() +
  geom_smooth(span = 0.9, method = "lm") +
  scale_y_continuous(trans = "log10") +
  labs(x = "Glycemic load", y = "Hepatic fat fraction (log-scale)") +
  theme(legend.position = "bottom")

df %>% 
  ggplot(aes(x = hff_Pre, y = hff_Post, color = Trt)) +
  geom_point() +
  geom_smooth(method = "lm") +
  scale_x_continuous(trans = "log10") +
  scale_y_continuous(trans = "log10")

cor.test(df$hff_Pre, df$hff_Post, method = "pearson")
cor.test(df$hff_Pre, df$hff_Post, method = "spearman")

df %>% 
  select(Trt, hff_Pre, hff_Post) %>% 
  group_by(Trt) %>% 
  summarize(mean_hff_pre = mean(hff_Pre), mean_hff_post = mean(hff_Post),)

df %>% 
  select(Trt, hff_Pre, hff_Post) %>% 
  group_by(Trt) %>% 
  summarize(median_hff_pre = median(hff_Pre), median_hff_post = median(hff_Post),)

df %>% 
  mutate(hff_diff = hff_Post - hff_Pre) %>% 
  group_by(Trt) %>% 
  summarize(mean_change = mean(hff_diff))

df %>% 
  mutate(hff_diff = hff_Post - hff_Pre) %>% 
  ggplot(aes(x = GL, y = hff_diff)) +
  # ggplot(aes(x = GL, y = hff_diff, color = factor(randarm))) +
  geom_point() +
  geom_smooth()
  # geom_smooth(method = lm) 

df %>% 
  mutate(hff_diff = hff_Post - hff_Pre) %>% 
  ggplot(aes(x = GL, y = hff_diff, color = Trt)) +
  geom_point() +
  geom_smooth(method = "lm") 

df %>% 
  mutate(hff_diff = hff_Post - hff_Pre) %>% 
  ggplot(aes(x = GL, y = hff_diff, color = Trt)) +
  geom_boxplot()


# Dietary variables
df %>% 
  select(kcal, SFA, addsugar, availcarb) %>% 
  summary()

df %>% 
  select(pid, kcal, SFA, addsugar, availcarb) %>% 
  pivot_longer(2:5, names_to = "nutr", values_to = "value") %>% 
  mutate(nutr = factor(nutr, levels = c("kcal", "SFA", "addsugar", "availcarb"))) %>% 
  ggplot(aes(x = value)) +
  geom_histogram() +
  facet_wrap(~nutr, scales = "free")

df %>% 
  select(pid, kcal, SFA, addsugar, availcarb) %>% 
  filter(kcal > 4000) %>% 
  arrange(kcal)

# Energy adjustment
kcal_adjust <- function(data, var, energy, log=TRUE){
  if (missing(var))
    stop("Need to specify variable for energy-adjustment.")
  if (missing(energy))
    stop("Need to specify energy intake.")
  if (missing(data))
    stop("Need to specify a data frame.")
  df <- eval(substitute(data.frame(y = data$var, ea_y = data$var, kcal = data$energy)))
  count_negative <- sum(df$y < 0, na.rm=TRUE)
  if (count_negative > 0)
    warning("There are negative values in variable.")
  if(log) df$y[df$y > 0 & !is.na(df$y)] <- log(df$y[df$y > 0 & !is.na(df$y)])
  mod <- lm(y ~ kcal, data=df[df$y != 0, ])
  if(log){
    ea <- exp(resid(mod) + mean(df$y[df$y != 0], na.rm=TRUE))
    df$ea_y[!is.na(df$y) & df$y != 0] <- ea
  }
  else{
    ea <- resid(mod) + mean(df$y[df$y != 0], na.rm=TRUE)
    df$ea_y[!is.na(df$y) & df$y != 0] <- ea
  }
  return(df$ea_y)
}

df$SFA_ea       <- kcal_adjust(SFA,       kcal, data = df, log = FALSE)
df$addsugar_ea  <- kcal_adjust(addsugar,  kcal, data = df, log = FALSE)
df$availcarb_ea <- kcal_adjust(availcarb, kcal, data = df, log = FALSE)

df %>% 
  select(SFA_ea, addsugar_ea, availcarb_ea, GL, GI) %>% 
  cor()

df %>% 
  select(pid, kcal, SFA_ea, addsugar_ea, availcarb_ea) %>% 
  pivot_longer(2:5, names_to = "nutr", values_to = "value") %>% 
  mutate(nutr = factor(nutr, levels = c("kcal", "SFA_ea", "addsugar_ea", "availcarb_ea"))) %>% 
  ggplot(aes(x = value)) +
  geom_histogram() +
  facet_wrap(~nutr, scales = "free")


# Table 1 -----------------------------------------------------------------

table_vars <- c("SexM", "age", "Race2", "Educ3", "bmi", "Trt", "hff_Pre", "hff_Post", "GL", "GI", "kcal", "SFA_ea")

CreateTableOne(table_vars, data = df) %>% 
  print(showAllLevels = TRUE, nonnormal = c("hff_Pre", "hff_Post"))

# Linear models -----------------------------------------------------------
library(gtsummary)

# Change units
# Create tertile groups
df_mod <- df %>% 
  mutate(GL10 = GL / 10,
         # GI100 = GI / 100,
         GI10 = GI / 10,
         kcal100 = kcal / 100) %>% 
  mutate(GL_cat3 = cut(GL, quantile(GL, 0:3/3), include.lowest = TRUE),
         GL_cat3 = factor(GL_cat3, labels = c("1st tertile", "2nd tertile", "3rd tertile")),
         GI_cat3 = cut(GI, quantile(GI, 0:3/3), include.lowest = TRUE),
         GI_cat3 = factor(GI_cat3, labels = c("1st tertile", "2nd tertile", "3rd tertile")))

# Model for GL
# Both control and intervention
fit_gl <- lm(log(hff_Post) ~ GL10 + SexM + age + Race2 + Educ3, data = df_mod)
# fit_gl <- lm(log(hff_Post) ~ GL10 + log(hff_Pre) + SexM + age + Race2 + Educ3, data = df_mod)
summary(fit_gl)

# Check model diagnosis
resid_panel(fit_gl, plots="all")

# Check for interaction
update(fit_gl, .~. + GL10*SexM)  %>% summary()
update(fit_gl, .~. + GL10*age)   %>% summary()
update(fit_gl, .~. + GL10*Race2) %>% summary()
update(fit_gl, .~. + GL10*Educ3) %>% summary()
update(fit_gl, .~. + Trt + GL10*Trt) %>% summary()
update(fit_gl, .~. + bmi + GL10*bmi) %>% summary()
update(fit_gl, .~. + SFA_ea + GL10*SFA_ea) %>% summary()

# Base model with demographics
var_labs <- list(GL10 = "GL/10", SexM = "Sex", age = "Age", Race2 = "Race", Educ3 = "Education")

t1 <- tbl_regression(fit_gl, 
               label = var_labs,
               estimate_fun = label_style_number(digits = 3),
               pvalue_fun   = label_style_pvalue(digits = 3)) %>% 
  add_global_p(keep = TRUE, include = Educ3)

# # Base + trt and its interaction with GL
# t2 <- update(fit_gl, .~. + Trt + Trt * GL10) %>%
#   tbl_regression(label = c(var_labs, Trt = "Group"),
#                  estimate_fun = label_style_number(digits = 3),
#                  pvalue_fun = label_style_pvalue(digits = 3)) %>% 
#   add_global_p(keep = TRUE, include = Educ3)

# Base + BMI
t2 <- update(fit_gl, .~. + bmi) %>%
  tbl_regression(label = c(var_labs, bmi = "BMI"),
                 estimate_fun = label_style_number(digits = 3),
                 pvalue_fun = label_style_pvalue(digits = 3)) %>% 
  add_global_p(keep = TRUE, include = Educ3)

# Base + dietary variables (including kcal) 
# t3 <- update(fit_gl, .~. + kcal100 + SFA_ea) %>%
t3 <- update(fit_gl, .~. + kcal100) %>%
  tbl_regression(label = c(var_labs, 
                           kcal100 = "Energy (per 100 kcal)"),
                           # kcal100 = "Energy (per 100 kcal)",
                           # SFA_ea = "SFA, gram (energy-adjusted)"),
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

update(fit_gl, .~. + kcal100 + pcten_SFA) %>% summary()

# GL as tertiles
fit_gl_cat3 <- lm(log(hff_Post) ~ GL_cat3 + SexM + age + Race2 + Educ3, data = df_mod)
summary(fit_gl_cat3)

# Adjusted mean (with 95% CI) after back-transformation
fit_gl_cat3 %>% 
  emmeans(~GL_cat3) %>% 
  as_tibble() %>% 
  select(GL_cat3, emmean, lower.CL, upper.CL) %>% 
  mutate_at(2:4, exp)

# Significant difference exists between 1st and 3rd tertile
fit_gl_cat3 %>% 
  emmeans(pairwise ~GL_cat3, adjust = "none") %>% 
  confint(adjust = "none")
  
df_mod %>% 
  group_by(GL_cat3) %>% 
  summarize(min = min(GL), max = max(GL))

# Control group only
df_mod %>%
  filter(Trt == "Cntrl") %>%
  # filter(Trt == "Avocado") %>%
  lm(log(hff_Post) ~ GL10 + SexM + age + Race2 + Educ3, data = .) %>% 
  summary()

# Models for GI
# Both control and intervention
fit_gi <- lm(log(hff_Post) ~ GI10 + SexM + age + Race2 + Educ3, data = df_mod)
summary(fit_gi)

# Check model diagnosis
resid_panel(fit_gi, plots="all")

# Check for interaction
update(fit_gi, .~. + GI10*SexM)  %>% summary()
update(fit_gi, .~. + GI10*age)   %>% summary()
update(fit_gi, .~. + GI10*Race2) %>% summary()
update(fit_gi, .~. + GI10*Educ3) %>% summary()
update(fit_gi, .~. + bmi + GI10*bmi) %>% summary()
update(fit_gi, .~. + Trt + GI10*Trt) %>% summary()

# Base model with demographics
var_labs <- list(GI10 = "GI/10", SexM = "Sex", age = "Age", Race2 = "Race", Educ3 = "Education")

t1 <- tbl_regression(fit_gi, 
               label = var_labs,
               estimate_fun = label_style_number(digits = 3),
               pvalue_fun   = label_style_pvalue(digits = 3)) %>% 
  add_global_p(keep = TRUE, include = Educ3)

# # Base + trt and its interaction with GI
# t2 <- update(fit_gi, .~. + Trt + Trt * GI100) %>%
#   tbl_regression(label = c(var_labs, Trt = "Group"),
#                  estimate_fun = label_style_number(digits = 3),
#                  pvalue_fun = label_style_pvalue(digits = 3)) %>% 
#   add_global_p(keep = TRUE, include = Educ3)

# Base + BMI
t2 <- update(fit_gi, .~. + bmi) %>%
  tbl_regression(label = c(var_labs, bmi = "BMI"),
                 estimate_fun = label_style_number(digits = 3),
                 pvalue_fun = label_style_pvalue(digits = 3)) %>% 
  add_global_p(keep = TRUE, include = Educ3)

# Base + dietary variables (including kcal) 
# t3 <- update(fit_gi, .~. + kcal100 + SFA_ea) %>%
t3 <- update(fit_gi, .~. + kcal100) %>%
  tbl_regression(label = c(var_labs, 
                           kcal100 = "Energy (per 100 kcal)"),
                           # kcal100 = "Energy (per 100 kcal)",
                           # SFA_ea = "SFA, gram (energy-adjusted)"),
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

# GI as tertiles
fit_gi_cat3 <- lm(log(hff_Post) ~ GI_cat3 + SexM + age + Race2 + Educ3, data = df_mod)
summary(fit_gi_cat3)

df_mod %>% 
  group_by(GI_cat3) %>% 
  summarize(min = min(GI), max = max(GI))

# Adjusted mean (with 95% CI) after back-transformation
fit_gi_cat3 %>% 
  emmeans(~GI_cat3) %>% 
  as_tibble() %>% 
  select(GI_cat3, emmean, lower.CL, upper.CL) %>% 
  mutate_at(2:4, exp)

# Significant difference exists between 1st and 3rd tertile
fit_gi_cat3 %>% 
  emmeans(pairwise ~GI_cat3, adjust = "none")
 