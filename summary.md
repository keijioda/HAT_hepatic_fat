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

- A SAS data file `final_n961_foodgroups_june2024.sas7bdat`

  - n = 961
  - Includes demographics (age, gender, race, education), BMI, and some
    dietary data

## Data check on hepatic fat data

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
  - The issue of S/N = -1 has been corrected – see the email
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

## Notes

- Zoom meeting on 1/23/2025 (KL/GS/CH/KO)
  - ~~S/N = -1 indicates invalid values?~~

    - ~~Kristie can look up PIDs of those subjects~~
    - ~~Dr. Barnes can look into those images to check if HFF values
      make sense~~
    - **\[Updated\]** The issue of S/N = -1 has been corrected – see the
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
