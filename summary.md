HAT hepatic fat study
================

## Datasets

- A CSV file `HAT_KeyVariables.csv` includes PIDs, their assigned group
  and date randomized, n = 1008

- A CSV file `HAT_HFF.csv` includes PID, MRI dates and 3 variables about
  hepatic fat MRI measurements:

  - `hff`: Hepatic fat fraction
  - `FWHM`: Full width half maximum (the width of the peak measured at
    50% of its maximum height), smaller the better
  - `sn`: Signal/noise ratio, higher the better
  - The file is in long format, having up to 2 MRI measurements per
    subject: n obs = 1932

- Demographic data: A SAS data file
  `final_n961_foodgroups_june2024.sas7bdat`

  - n = 961
  - Includes demographics (age, gender, race, education), BMI, and GL/GI

<!-- * Dietary data: A CSV file `HAT_GL_GI_by_FG_updated_080224.csv` -->
<!--   * n.obs = 2845 from n = 961 distinct PIDs -->
<!--   * Include glycemic load/index from various food groups by subject and visit -->

## Data check on hepatic fat

- The hepatic fat data file `HAT_HFF.csv` includes 1932 MRI measurements
  from 1008 distinct PIDs
  - The file does not have a variable indicating if a measurement is a
    pre- or post-intervention
  - The date of randomization was added from `HAT_KeyVariables.csv` to
    determine pre/post measurements
- Most of the subjects (n = 924) have two MRI measurements:
  - There were 3 subjects who have 2 measurements **after**
    randomization **\[Decision needed\]**
- There are 81 subjects who have only one MRI measurement
  - Among them, 75 subjects have only pre-intervention measurement
    **\[Decision needed\]**
  - Six subjects have only post-measurement **\[Decision needed\]**
- There are 3 subjects who did not have any MRI measurements (i.e., MRI
  date missing, measurement missing)

## Preliminary analysis on hepatic fat measurements

- Disclaimer: The following analysis was done regardless of pre/post
  measurements

- Descriptive statistics on `hff`, `FWHM`, `sn`:

  - The HFF value ranges from 0.04% to 54%, with mean of 10% (median
    5.7%)
    - Its distribution appears to be very right-skewed
  - ~~Note the negative value of -1 on S/N ratio – what does this
    indicate? **\[Clarify\]**~~
  - ~~There are 7 MRI measurements that have a value `-1` on S/N ratio~~
  - The issue of S/N = -1 has been resolved – see the email
    correspondence on 1/27/25

<!-- -->

    ##       hff                 FWHM             sn        
    ##  Min.   :0.0004123   Min.   :0.117   Min.   :  19.0  
    ##  1st Qu.:0.0247974   1st Qu.:0.252   1st Qu.: 204.0  
    ##  Median :0.0568708   Median :0.299   Median : 321.0  
    ##  Mean   :0.1008132   Mean   :0.320   Mean   : 346.1  
    ##  3rd Qu.:0.1408586   3rd Qu.:0.365   3rd Qu.: 457.0  
    ##  Max.   :0.5446429   Max.   :0.666   Max.   :1100.0  
    ##  NA's   :3           NA's   :3       NA's   :3

### Distribution of HFF

- A histogram and a cumulative density function of HFF are shown below
  - Vertical dash lines divide HFF values into 5 groups at 5, 10, 20,
    and 30%
  - The distribution of HFF is highly right-skewed, but very smooth
    without apparent separating points
  - **\[Decision needed\]** What should we draw a line for outliers on
    HFF?

![](summary_files/figure-gfm/hff_distrib-1.png)<!-- -->

- A frequency table of HFF (5 groups):
  - About 45% of measurements are “normal” having HFF \<5%

<!-- -->

    ## # A tibble: 5 × 3
    ##   hff_cat             n   pct
    ##   <fct>           <int> <dbl>
    ## 1 Normal  : 0-5     882 45.7 
    ## 2 Mild    : 5-10    389 20.2 
    ## 3 Moderate: 10-20   349 18.1 
    ## 4 Severe  : 20-30   166  8.61
    ## 5 Advanced: >30     143  7.41

### Change in HFF

- For those who have both pre- and post-measurements, changes in HFF
  value (post - pre) were calculated
- A histogram of change in HFF is shown below
  - Most of subjects have an absolute change \<0.2

![](summary_files/figure-gfm/hff_change-1.png)<!-- -->

- See the list below for those whose HFF value changed \>0.2. There are
  11 such subjects:
  - **\[Clarify\]** Is it likely to see such change in HFF during the
    study period?

<!-- -->

    ## # A tibble: 11 × 4
    ##         pid hff_Pre hff_Post hff_diff
    ##       <dbl>   <dbl>    <dbl>    <dbl>
    ##  1 15055809  0.402    0.201    -0.201
    ##  2 15060489  0.462    0.234    -0.228
    ##  3 15098613  0.204    0.488     0.284
    ##  4 15099423  0.0180   0.240     0.222
    ##  5 15129942  0.173    0.391     0.218
    ##  6 15142450  0.369    0.138    -0.231
    ##  7 15156753  0.447    0.0740   -0.373
    ##  8 15163377  0.344    0.0745   -0.269
    ##  9 15170152  0.303    0.102    -0.200
    ## 10 15268632  0.133    0.352     0.220
    ## 11 15270106  0.115    0.409     0.294

- There are 23 subjects whose HFF value changed \>0.15 (not shown here)

### S/N ratio and FWHM

- A scatterplot of S/N and FWHM is shown below, with histograms on
  margins.
  - Those measurements of S/N = -1 are shown red in the figure
  - Notice that both distributions are right-skewed
  - **\[Decision needed\]** Where should we draw lines for potential
    outliers?
    - For example, there are 18 measurements that have S/N \< 100 (more
      noise) and FWHM \> 0.6 (lower resolution)

![](summary_files/figure-gfm/sn_fwhm_scatter-1.png)<!-- -->

### Relationship between HFF and BMI

- A scatterplot between BMI and HFF is shown below
  - Both axes are log-scale, due to their skewed distributions
  - A smoothed trend curve is super-imposed (with 95% confidence
    intervals)

![](summary_files/figure-gfm/hff_bmi_scatter-1.png)<!-- -->

- The Pearson correlation coefficient between BMI and HFF (both
  log-scale) was r = 0.32
  - If MRI measurements of S/N \< 100 and FWHM \> 0.6 were removed, the
    correlation slightly reduced to r = 0.31

## Exploratory analysis on HFF vs GL/GI

<!-- * Based on dietary data, total GL/GI intake was calculated for each visit and then averaged for each subject -->

- After merging with demographic data and HFF data, there were n = 903
  subjects
  - This excludes those who had 2 MRIs after randomization and those
    missing either pre/post-intervention MRIs or both
- Descriptive statistics on hepatic fat fraction (post-intervention
  only), GL and GI are shown below:

<!-- -->

    ##     hff_Post              GL                GI       
    ##  Min.   :0.001236   Min.   :  6.658   Min.   :38.22  
    ##  1st Qu.:0.026358   1st Qu.: 75.568   1st Qu.:55.31  
    ##  Median :0.057759   Median :103.142   Median :58.44  
    ##  Mean   :0.103438   Mean   :107.614   Mean   :57.98  
    ##  3rd Qu.:0.147841   3rd Qu.:133.435   3rd Qu.:61.24  
    ##  Max.   :0.544643   Max.   :350.114   Max.   :69.88

- Histograms of HFF, GL and GI are shown below
  - Note that the distribution of HFF is highly right-skewed
  - When HFF is used as the dependent variable, this will be
    log-transformed
  - **\[Clarify\]** There are 4 participants with GL values \> 300. Are
    these values plausible?

![](summary_files/figure-gfm/hff_gl_gi_histograms-1.png)<!-- -->

- Scatterplots between HFF (post-intervention) and GL/GI are shown below
  - These plots are exploratory and not adjusted for any covariates
  - The y-axis (HFF) is on the log scale
  - A smoothed trend is overlaid for each plot
    - Please ignore the tail region of GL/GI where data are sparse and
      the confidence interval is wide
    - No apparent relationship with HFF (again, unadjusted)

![](summary_files/figure-gfm/hff_gl_gi_scatter-1.png)<!-- -->

- Below, you see similar plots, except that this time a linear trend was
  overlaid for each gender
  - There is a clear difference in HFF between two genders. Males have
    higher HFF values than females
  - Maybe slight upward trend for both gender?

![](summary_files/figure-gfm/hff_gl_gi_scatter_by_sex-1.png)<!-- -->

## Regression models of HFF on GL

- Regression models were run using log(post HFF) as the dependent
  variable and glycemic load (GL) as an independent variable of
  interest.

  - Because of its highly right-skewed distribution, HFF was
    log-transformed
  - GL values were divided by 10 (labelled as “GL/10” in the table
    below). Thus, its beta estimate is interpreted as a change in
    log(HFF) for a 10-unit change in GL.

- Model 1 (or “base” model) below adjusts for basic demographic
  variables: gender, age, race (NH White/rest), education (less than
  college, college degree, postgraduate degree)

  - There was a significant positive association between HFF and GL (p =
    0.04). A 10-unit increment in GL gives a corresponding increment of
    HFF by 1.6% (i.e., $exp(0.016) = 1.016$ or 1.6% increase)
  - Males’ HFF values were significantly higher than females by 68%
    ($exp(0.520) = 1.68$)
  - Non-Whites had significantly lower HFF value than White
    ($exp(-0.185) = 0.83$ or 17% lower)
  - Education was negatively associated with HFF

- In Model 2, BMI was added to the base model

  - BMI was significantly positively associated with HFF (p \<.001). A
    1-unit increment of BMI corresponds to an increase of HFF by 6%
    (i.e., $exp(0.059) = 1.061$ or 6% increase)
  - The beta coefficient for GL was attenuated and became
    non-significant after adding BMI into the base model

- In Model 3, total energy (per 100 kcal) ~~and SFA (gram,
  energy-adjusted)~~ was added to the base model

  - The total energy intake (kcal) was not significantly associated with
    HFF
  - Glycemic load was not significantly associated with HFF, after
    further adjusting for kcal ~~and SFA~~

- \[I did not use added sugar and carbohydrate, because these two
  variables have a high correlation with each other and this will cause
  multicollinearity in the model. Carbohydrate was highly correlated
  with GL too.\]

- There were no significant interactions between GL and gender, age,
  race, education, BMI, treatment group, or SFA (results not shown here)

<img src="summary_files/figure-gfm/gl_models-1.png" width="1976" />

- The results above suggest that GL is significantly positively
  associated with HFF when adjusted for demographic variables (gender,
  age, race and education in Model 1). In order to estimate how HFF
  differs according to GL levels, GL values were categorized into 3
  equal tertiles (6.6-85.4, 85.5-121, \>121) and then this categorical
  GL variable was entered into the model, instead of using GL as
  continuous as in the previous model.

- The table below shows estimated means (with 95% confidence intervals)
  of HFF for the tertile groups, after adjusting for the demographic
  variables.

  - As expected, the mean HFF values (see the column `emmean`) tend to
    be greater for higher tertile groups.
  - A significant difference was found between the 1st and the 3rd
    tertile groups (p = 0.0085). There were no significant differences
    between (1st vs 2nd) or (2nd vs 3rd).

| GL_cat3     | emmean | lower.CL | upper.CL |
|:------------|-------:|---------:|---------:|
| 1st tertile | 0.0566 |   0.0494 |   0.0649 |
| 2nd tertile | 0.0669 |   0.0586 |   0.0763 |
| 3rd tertile | 0.0716 |   0.0631 |   0.0813 |

## Regression models of HFF on GI

- Regression models were run using log(post HFF) as the dependent
  variable and glycemic index (GI) as an independent variable of
  interest

  - Again, HFF was log-transformed
  - GI values were divided by 10 (labelled as “GI/10” in the table
    below). Thus, its beta estimate is interpreted as a change in
    log(HFF) for a 10-unit change in GI.

- Similarly to GL models, 3 models were run (see below)

- In Model 1 (or “base” model):

  - There was a significant positive association between HFF and GI (p =
    0.023). A 10-unit increment in GI gives a corresponding increment of
    HFF by 19% (i.e., $exp(0.173) = 1.19$ or 19% increase)
  - Males’ HFF values were significantly higher than females by 75%
    ($exp(0.557) = 1.75$)
  - Non-Whites had significantly lower HFF value than White
    ($exp(-0.197) = 0.82$ or 18% lower)
  - Education was negatively associated with HFF

- In Model 2 (with BMI):

  - BMI was significantly positively associated with HFF (p \<.001). A
    1-unit increment of BMI corresponds to an increase of HFF by 6%
    (i.e., $exp(0.059) = 1.061$ or 6% increase)
  - The beta coefficient for GI was slightly attenuated but still
    significant (p = 0.029). A 10-unit increment in GI gives a
    corresponding increment of HFF by 17% (i.e., $exp(0.160) = 1.17$ or
    17% increase)

- In Model 3 (Base + kcal):

  - The total energy intake (kcal) not significantly associated with HFF
  - The beta coefficient for GI was slightly attenuated but still
    significant (p = 0.034). A 10-unit increment in GI gives a
    corresponding increment of HFF by 18% (i.e., $exp(0.163) = 1.18$ or
    18% increase)

- There were no significant interactions between GI and gender, age,
  race, education, BMI, treatment group, or SFA (results not shown here)

<img src="summary_files/figure-gfm/gi_models-1.png" width="1976" />

- The results above suggest that GI is significantly positively
  associated with HFF when adjusted for demographics (Model 1),
  demographics plus BMI (Model 2), or demographics plus energy intake
  (Model 3). In order to estimate how HFF differs according to GI
  levels, GI values were categorized into 3 equal tertiles (38.2-56.3,
  56.4-60, \>60) and then this categorical GI variable was entered into
  the model, instead of using GI as continuous as in the previous model.

- The table below shows estimated means (with 95% confidence intervals)
  of HFF for the tertile groups, after adjusting for the demographic
  variables.

  - As expected, the mean HFF values (see the column `emmean`) tend to
    be greater for higher tertile groups.
  - A significant difference was found between the 1st and the 3rd
    tertile groups (p = 0.0198). There were no significant differences
    between (1st vs 2nd) or (2nd vs 3rd).

| GI_cat3     | emmean | lower.CL | upper.CL |
|:------------|-------:|---------:|---------:|
| 1st tertile | 0.0601 |   0.0527 |   0.0685 |
| 2nd tertile | 0.0622 |   0.0545 |   0.0710 |
| 3rd tertile | 0.0737 |   0.0648 |   0.0839 |

## Descriptive table

- A descriptive table is shown below
  - For HFF, the median and IQR are shown, instead of mean/SD
  - kcal: Total energy intake (kcal/day)
  - SFA_ea: Energy-adjusted SFA intake (gram/day)
  - SFA values were energy-adjusted by the residual method

|                           | level     | Overall             |
|:--------------------------|:----------|:--------------------|
| n                         |           | 903                 |
| SexM (%)                  | F         | 664 (73.5)          |
|                           | M         | 239 (26.5)          |
| age (mean (SD))           |           | 50.74 (14.07)       |
| Race2 (%)                 | White     | 631 (69.9)          |
|                           | NonWhite  | 272 (30.1)          |
| Educ3 (%)                 | LTCollege | 324 (35.9)          |
|                           | College   | 298 (33.0)          |
|                           | Postgrad  | 281 (31.1)          |
| bmi (mean (SD))           |           | 32.91 (5.44)        |
| Trt (%)                   | Cntrl     | 456 (50.5)          |
|                           | Avocado   | 447 (49.5)          |
| hff_Pre (median \[IQR\])  |           | 0.06 \[0.02, 0.14\] |
| hff_Post (median \[IQR\]) |           | 0.06 \[0.03, 0.15\] |
| GL (mean (SD))            |           | 107.61 (45.99)      |
| GI (mean (SD))            |           | 57.98 (4.69)        |
| kcal (mean (SD))          |           | 1957.67 (591.15)    |
| SFA_ea (mean (SD))        |           | 27.68 (6.82)        |

## Additional analyses

### Models including treatment and its interaction with GL

- To examine whether the relationship between HFF and GL differs between
  the control and the avocado groups, models were run including the
  treatment main effect (control/avocado, control as reference) and its
  interaction term with GL.
  - If a significant trt x GL interaction exists, this would suggest
    that the relationship between HFF and GL differs between the two
    groups
- See below for the results of Models 1 to 3, this time including trt
  and trt \* GL interaction:
  - Note that the main effect for GL/10 now represents the slope for the
    control group, which is not significant for all models.
  - The interaction term trt \* GL is positive but non-significant,
    suggesting that the avocado group has a slightly more positive
    association compared to the control group, but the difference in
    slope is not statistically significant

<img src="summary_files/figure-gfm/gl_intx_models-1.png" width="1976" />

### Models including treatment and its interaction with GI

- Similar models were run, but this time for GI
  - The interaction term trt \* GI was not significant in all models,
    suggesting that the relationship between HFF and GI did not differ
    significantly between the two groups

<img src="summary_files/figure-gfm/gi_intx_models-1.png" width="1976" />

### Models adjusting for avocado intake

- To examine if the relationship between HFF and GL/GI may be at least
  partially mediated by avocado intake, models were run including
  avocado intake (gram/day) this time
  - Avocado intake was calculated for each subject, by averaging avocado
    intake across multiple recalls per subject
  - For regression models, avocado intake was divided by 100. Thus, the
    estimated beta coefficient for avocado intake represents the change
    in log(HFF) for each 100 g/day increment of avocado intake
- For GL models, avocado intake was not significantly associated with
  HFF. The estimated beta coefficient for GL main effect was virtually
  unchanged in all models

<img src="summary_files/figure-gfm/gl_avoc_models-1.png" width="2108" />

- For GI models, avocado intake was not significantly associated with
  HFF. The estimated beta coefficient for GI main effect was virtually
  unchanged in all models

<img src="summary_files/figure-gfm/gi_avoc_models-1.png" width="2108" />

## Notes

- Zoom meeting on 1/23/2025 (KL/GS/CH/KO)
  - ~~S/N = -1 indicates invalid values?~~

    - ~~Kristie can look up PIDs of those subjects~~
    - ~~Dr. Barnes can look into those images to check if HFF values
      make sense~~
    - **\[Updated\]** The issue of S/N = -1 has been resolved – see the
      email correspondence on 1/27/25

  - It is plausible to see changes of HFF \> 0.2 according to Dr. Barnes

    - Dig into past literature with similar intervention as well?

  - Any data on compliance on those with a large HFF change during
    study?

  - Need to determine cut-off values for HFF/FWHM/SN outliers

  - Possible covariates to be included in the model

    - Demographics (age/gender/race/education)
    - BMI (pre/post)
    - Any lifestyle variables? – self-reported
    - Nutrient intake? – total kcal, SFA (kcal base), sugar?, CHO?
      - Want to identify those overeating

  - KO to proceed analysis without excluding potential outliers for now
    – Can exclude any outliers later

  - KL to communicate with Dr. Barnes

  - GS to look into nutrient data
- Zoom meeting on 2/27/2025 (KL/SR/GS/CH/KO)
  - High GL due to over-eating
  - Categorize according to tertiles on GL; compare HFF?
  - Food group GL, instead of total GL, as predictors?
    - by foods with high/low GI?
  - Remove SFA from Model 3
