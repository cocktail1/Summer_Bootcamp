##Chapter 2: Analysis of Variance (ANOVA)

###Two-Sample t-tests in the TTEST Procedure

**Review of the Assumptions**

- **Independent observations**: The assumption of independent observations means that no observations provide any information about any other observation that you collect. For example, measurements are not repeated on the same subject.
- **Normally distributed data for each group**: The assumption of normality can be relaxed if the data are approximately normally distributed or if enough data are collected. Examine plots of the data to confirm.
- **Equal variances for each group**: There are several tests for this. If the assumption is not valid, an approximate t-test can be performed.

**Folded *F* Test for Equality of Variances p.2-5**

```
F = (max(s1^2,s2^2)/min(s1^2,s2^2))
```

To evaluate the assumption of equal variances in each group, you can use the Folded *F* test for equality of variances. The null hypothesis for this test is that the variances are equal. The *F* value is calculated as a ratio of the greater of the two variances divided by the lesser of the two.

This test is valid **only** for independent samples from normal distributions. Normality is required even for large sample sizes. If your data are not normally distributed, you can look at plots to determine whether the variances are approximately equal. If you reject the null hypothesis, it is recommended that you use the unequal variance t-test in the `PROC TTEST` output for testing the equality of the group.

**The `TTEST` Procedure**

This is the general form:
```
PROC TTEST DATA = dataset;
    CLASS  variable;
    VAR    variables;
    PAIRED variable1*variable2;
RUN;
```

- `CLASS` specifies the two-level variable for the analysis. Only one variable is allowed in this statement. Gender, for example.
- `VAR` specifies numeric response variables for the analysis. If the `VAR` statement is not specified, `PROC TTEST` analyzes all numeric variables in the input data set that are not listed in a `CLASS` (or `BY`) statement.
- `PAIRED` specifies pairs of numeric response variables from which difference scores (variable1 - variable2) are calculated. A one-sample t-test is then performed on the difference scores.

To look for Equal Variance, first look for the `Prob > |T| = ...` section of the *Equal Variance t-test (Pooled)* and then look for the `Prob > F' = ...` under *Equality of Variances Test (Folded F)*. You can end up with different answers for these. 

1. Check the assumption of equal variances and then use the appropriate test for equal means. Because the p-value of the test F statistic is > 0.05, there is not enough evidence to reject the null hypothesis of equal variances.
2. Therefore, use the equal variance t-test line in the output to test whether the means fo the two populations are equal.

The null hypothesis that the group means are equal is rejected at the 0.05 level. In the example on page 2-7, you conclude that there is a difference between the means of the groups.

Other possibility:

1. Check the assumption of equal variances (Folded F) and then use the appropriate test for equal means. In the example, because the p-value of the test F statistic is less than alpha = 0.05, there is enough evidence to reject the null hypothesis of equal variances. 
2. Therefore, use the unequal variance t-test line in the output to test whether the means of the two populations are equal. In the example, the null hypothesis that the group means are equal is rejected at the 0.05 level.

**Example SAS code**

The `SHOWNULL` option will include the reference line for the null hypothesis on the charts.

```
proc ttest data=sasuser.TestScores plots(shownull)=interval;
    class Gender;
    var SATScore;
    title "Two-Sample t-test Comparing Girls to Boys";
run;
```
 In this example, look at the Folded F value. It is 0.2545. We fail to reject the null, which means that the variances likely are equal. Then use the Pooled Equal Variances test to determine if the means of the two groups are equal. p = 0.0643, so we fail to reject the null hypothesis, concluding that we do not have enough evidence to show that the Girls and Boys have different mean SAT Scores.

 Results:
 ```
                                      The TTEST Procedure

                                      Variable:  SATScore

         Gender          N        Mean     Std Dev     Std Err     Minimum     Maximum

         Female         40      1221.0       157.4     24.8864       910.0      1590.0
         Male           40      1160.3       130.9     20.7008       890.0      1600.0
         Diff (1-2)            60.7500       144.8     32.3706

 Gender        Method               Mean       95% CL Mean        Std Dev      95% CL Std Dev

 Female                           1221.0      1170.7   1271.3       157.4       128.9    202.1
 Male                             1160.3      1118.4   1202.1       130.9       107.2    168.1
 Diff (1-2)    Pooled            60.7500     -3.6950    125.2       144.8       125.2    171.7
 Diff (1-2)    Satterthwaite     60.7500     -3.7286    125.2

                  Method           Variances        DF    t Value    Pr > |t|

                  Pooled           Equal            78       1.88      0.0643
                  Satterthwaite    Unequal      75.497       1.88      0.0644

                                     Equality of Variances

                       Method      Num DF    Den DF    F Value    Pr > F

                       Folded F        39        39       1.45    0.2545

 ```

 Look at the female Q-Q plot. Almost all points represent normality. One of the points in the male graph appears to be an outlier -- a male who scored 1600. This might affect the analysis.

 If the mean of the difference between the two Genders is greater than 2* the Standard Error, then we can get a sense of whether there is statistical difference (since 1.96 is the normal cutoff for 95%). You see that the mean of the differences is 60.75 and the St. Error is 32.37. Since the mean is not > 2* the standard error, we can infer that they are not unequal.

Try the t-test again, excluding the male that has 1600 as a score (the outlier).
```
proc ttest data=sasuser.TestScores(WHERE=(IDNumber ~= 39196697)) plots(shownull)=interval;
    class Gender;
    var SATScore;
    title "Two-Sample t-test Comparing Girls to Boys";
run;
```

Now, the Equality of Variance Test rejects the hypothesis that the variances are equal and we have to use the Unequal Variances test. It is less that 0.05, which means that the mean of males and females is not the same. This means that the observation we excluded was highly influential. Also, note that the mean of the difference is > 2 * the Std. Error.

```
                                      The TTEST Procedure

                                      Variable:  SATScore

         Gender          N        Mean     Std Dev     Std Err     Minimum     Maximum

         Female         40      1221.0       157.4     24.8864       910.0      1590.0
         Male           39      1149.0       111.2     17.8114       890.0      1360.0
         Diff (1-2)            72.0256       136.6     30.7349

 Gender        Method               Mean       95% CL Mean        Std Dev      95% CL Std Dev

 Female                           1221.0      1170.7   1271.3       157.4       128.9    202.1
 Male                             1149.0      1112.9   1185.0       111.2     90.9041    143.4
 Diff (1-2)    Pooled            72.0256     10.8247    133.2       136.6       118.0    162.2
 Diff (1-2)    Satterthwaite     72.0256     10.9928    133.1

                  Method           Variances        DF    t Value    Pr > |t|

                  Pooled           Equal            77       2.34      0.0217
                  Satterthwaite    Unequal      70.266       2.35      0.0214

                                     Equality of Variances

                       Method      Num DF    Den DF    F Value    Pr > F

                       Folded F        39        38       2.00    0.0345

```

The `CLASS` statement is what tells `PROC TTEST` to do a 2-sample t-test.


**Exercise on page 2-13**

```
PROC TTEST DATA = sasuser.german plots(shownull) = interval;
    CLASS Group;
    VAR   Change;
    TITLE "Two-Sample t-test Comparing Treatment and Control";
RUN;
```

Results:

```
                                      The TTEST Procedure

                                       Variable:  Change

         Group           N        Mean     Std Dev     Std Err     Minimum     Maximum

         Control        13      6.9677      8.6166      2.3898     -6.2400     19.4100
         Treatment      15     11.3587     14.8535      3.8352    -17.3300     32.9200
         Diff (1-2)            -4.3910     12.3720      4.6882

 Group         Method               Mean       95% CL Mean        Std Dev      95% CL Std Dev

 Control                          6.9677      1.7607  12.1747      8.6166      6.1789  14.2238
 Treatment                       11.3587      3.1331  19.5843     14.8535     10.8747  23.4255
 Diff (1-2)    Pooled            -4.3910    -14.0276   5.2457     12.3720      9.7432  16.9550
 Diff (1-2)    Satterthwaite     -4.3910    -13.7401   4.9581

                  Method           Variances        DF    t Value    Pr > |t|

                  Pooled           Equal            26      -0.94      0.3576
                  Satterthwaite    Unequal      22.947      -0.97      0.3413

                                     Equality of Variances

                       Method      Num DF    Den DF    F Value    Pr > F

                       Folded F        14        12       2.97    0.0660

```

The null hypothesis for the Equality of Variances Folded F test is that the variances are equal. p > 0.05, so we fail to reject and conclude that the variances are equal. This means that we have to use the Pooled Equal Variances test to determine if the mean values of Control and Treatment are the same. The null hypothesis is that the means are equal. The p-value is 0.3576, so we fail to reject the null and conclude that the means of the control and treatment groups are equal.


###One-Way ANOVA

How do we test for equality of means when we have more than two groups? We will use `PROC GLM` to analyze the population means for more than two populations.

Working with this, the response variable is *continuous* and the predictors are *categorical*.

*Analysis of Variance* (ANOVA) is a statistical technique used to compare the means of two or more groups of observations or treatments.

Possible research questions: 

- Do accountants, on average, earn more than teachers? If you analyze the difference between two means using ANOVA, you reach the same conclusions as you reach using a pooled, two-group t-test. Performing a two-grup mean comparison in `PROC GLM` gives you access to different graphical and assessment tools than performing the same comparison in `PROC TTEST`.
- Do people treated with one of two new drugs have higher average T-cell counts than people in the control group? When there are three or more levels for the grouping variable, a simple approach is to run a series of t-test between all the pairs of levels. For example, you might be interested in T-cell counts in patients taking three medications (including one placebo). You could simply run a t-test for each pair of medications. A more powerful approach is to analyze all the data simultaneously. The mathematical model is called a *one-way analysis of variance*, and the test statistic is the *F* ratio, rather than the Student's t-value.
- Do people spend different amounts depending on which type of credit card they have?
- Does the type of fertilizer used affect the average weight of garlic grown at the Montana Gourmet Garlic Ranch?

####One-Way ANOVA Garlic Example

With One-Way ANOVA, you can first ask, "Are all of them equal?" When you can prove that they are not all equal, then you can start to narrow down and try to determine the differences.

Look at the data for the garlic example. Examine the data and look at the frequency and means of the different fertilizer types. Do this just to get a feeling about the data.
```
/*st102d02.sas*/  /*Part A*/
proc print data=sasuser.MGGarlic (obs=10);
   title 'Partial Listing of Garlic Data';
run;

/*st102d02.sas*/  /*Part B*/
proc means data=sasuser.MGGarlic printalltypes maxdec=3;
    var BulbWt;
    class Fertilizer;
    title 'Descriptive Statistics of Garlic Weight';
run;
```

When the sample sizes are not the same, you may hear that the study is not "balanced". Or you will hear that is it "unbalanced".

Next, look at the box and whisker plot, to get a visual sense of how they relate:
```
PROC SGPLOT DATA=sasuser.MGGarlic;
    VBOX    BulbWt / category=Fertilizer datalabel=BedID;
    REFLINE 0.219; *Calculated earlier;
    FORMAT  BedID 5.;
    TITLE  "Box and Whisker Plots of Garlic Weight";
RUN;
```

####Partitioning Variability in ANOVA

In ANOVA, the Total Variation (as measured by the corrected total sum of squares) is partitioned into two components, the Between Group Variation (displayed in the ANOVA table as the Model Sum of Squares) and the Within Group Variation (displayed as the Error Sum of Squares). As the name implies, ANOVA breaks apart the variance of the dependent variable to determine whether the between-group variation is a significant portion of the total variation. ANOVA compares the portion of variation in the response variable attributable to the grouping variable to the portion of variability that is unexplained. The test statistic, the *F* Ratio, is only a ratio of the model variance to the error variance. 

The model sum of squares and the error sum of squres sums to the total sum of squares.

```
TSS = SSM + SSE
```

####Example of calculating errors and sums of squares

```
3 4 5 7 8 9
```

The overall mean, or y-double-bar, is:
```
overall_mean = (3+4+5+7+8+9)/6 = 6
```

The total sum of squares is:
```
TSS = (3-6)^2 + (4-6)^2 + (5-6)^2 + (7-6)^2 + (8-6)^2 + (9-6)^2 + = 28
```

The total sum of squares, TSS, is a measure of the total variability in a response variable. It is calculated by summing the squared distances from each point to the overall mean. Because it is correcting for the mean, this sum sometimes is called the *corrected total sum of squares*.

The error sum of squares is:
```
SSE = (3-4)^2 + (4-4)^2 + (5-4)^2 + (7-8)^2 + (8-8)^2 + (9-8)^2 = 4
```

The error sum of squares, SSE, measures the random variability **within** groups; it is the sum of the squared deviations between observations in each group and that group's mean. This is often referred to as the *unexplained variation* or *within-group variation*.

The model sum of squares is:
```
SSM = 3*(4-6)^2 + 3*(8-6)^2 = 24
```

The model sum of squares, SSM, measures the variability **between** groups; it is the sum of the squared deviations between each group mean and the overall mean, weighted by the number of observations in each group. This is often referred to as the *explained variation*. The model sum of squares can also be calculated by subtracting the error sum of squares from the total sum of squares:
```
SSM = SST - SSE
```

The total sum of squares (TSS) refers to the **overall** variability in the response variable. The TSS is computed under the null hypothesis (that the group means are all the same). The error sum of squares (SSE) refers to the variability **within** the treatments not explained by the independent variable. The SSE is computed nder the alternative hypothesis (that the model includes nonzero effects). The model sum of squares (SSM) refers to the variability **between** the treatments explained by the independent variable.

The basic measures of variation under the two hypotheses are transformed into a ratio of the model and the error variances that has a known distribution (a sample statistic, the *F* ratio) under the null hypothesis that all group means are equal. The *F* ratio can be used to compute a p-value.

**The F Statistic**

The null hypothesis for ANOVA is tested using an *F* statistic. The *F* statistic is calculated as the ratio of the Between Group Variance to the Within Group Variance. In the output of `PROC GLM`, these values are shown as the Model Mean Square and the Error Mean Square. The mean square values are calculated as the sum of square value divided by the degrees of freedom.

In general, *degrees of freedom* (DF) can be thought of as the number of independent pieces of information

- Model DF is the number of treatments minus 1.
- Corrected total DF is the sample sie minus 1.
- Error DF is the sample size minus the number of treatments (or the difference between the corrected total DF and the Model DF.)

*Mean squares* are calculated by taking sums of squares and dividing by the corresponding degrees of freedom. They can be thought of as variances.

- Mean Square Error (MSE) is an estimate of σ^2, the constant variance assumed for all treatments.
- If μi = μj for all i != j, then the mean square for the model (MSM) is also an estimate of σ^2.
- If μi != μj for any i != j, then MSM estimates σ^2 plus a positive constant.
- *F* = MSM/MSE

**Coefficient of Determination**

This is the proportion of variance accounted for by the model.

```
R^2 = SSM/SST
```
The value of R^2 is between 0 and 1. The value is:

- close to 0 if the independent variables do not explain much variability in the data
- close to 1 if the independent variables explain a relatively large proportion of variability in the data.

####The ANOVA Model

```
Yik = μ + τi + εik

Yik = The kth value of the response variable for the ith treatment
μ   = the overall population mean of the response, for example, garlic bulb weight
τi  = the difference between the population mean of the ith treatment and the overall mean μ. This is referred to as the effect of treatment i.
εik = the difference between the observed value of the kth observation in the ith group and the mean of the ith group. This is the error term.

```

For our example:
```
BulbWt = Base_Level + Fertilizer + Unaccounted for Variation
```

**The `GLM` Procedure**

Look at page 2-29 for examples of the statements.

The `MEANS` option computes the unadjusted means of the dependent variables.
The `LSMEANS` computes the means after you have asked for the effect of other independent variables.

**Assumptions for ANOVA**

- Observations are independent
- Errors are normally distributed: Use diagnostic plots from `PROC GLM` to verify the assumption
- All groups have equal error variances. Use the `HOVTEST` option in the `MEANS` statement of `PROC GLM`. H0 for this hypothesis test is that the variances are equal for all populations.

 **SAS example of using the `GLM` procedure**

 ```
proc glm data=sasuser.MGGarlic;
     class Fertilizer;
     model BulbWt=Fertilizer;
     title 'Testing for Equality of Means with PROC GLM';
run;
quit;
 ```

 Results:

 ```
                          Testing for Equality of Means with PROC GLM                          7
                                                                  09:09 Wednesday, July 17, 2013

                                       The GLM Procedure
     Dependent Variable: BulbWt

                                              Sum of
      Source                      DF         Squares     Mean Square    F Value    Pr > F

      Model                        3      0.00457996      0.00152665       1.96    0.1432

      Error                       28      0.02183054      0.00077966

      Corrected Total             31      0.02641050


                      R-Square     Coeff Var      Root MSE    BulbWt Mean

                      0.173414      12.74520      0.027922       0.219082


      Source                      DF       Type I SS     Mean Square    F Value    Pr > F

      Fertilizer                   3      0.00457996      0.00152665       1.96    0.1432


      Source                      DF     Type III SS     Mean Square    F Value    Pr > F

      Fertilizer                   3      0.00457996      0.00152665       1.96    0.1432

 ```

 Here, the p-value on the *F* test, is 0.14, which > 0.05, which means that we fail to reject the hypothesis that all of the means are 0. The difference is not statistically significant.

 The R-Square is 0.17. We have captured 17% of the variability in our model.

 The Coefficient of Variation is in percentage terms and compares the Root MSE to the BulbWt Mean. This allows us to compare with a unitless measure and show how much is the variability of the error in comparison with the mean.

 One important thing that we have to do is to validate the assumptions, to make sure that we have done everything in a valid way. You can use this code to do it:

 ```
/*st102d03.sas*/  /*Part B*/
proc glm data=sasuser.MGGarlic PLOTS(ONLY) = DIAGNOSTICS;
     CLASS Fertilizer;
     MODEL BulbWt=Fertilizer;
     MEANS Fertilizer / HOVTEST;
     TITLE 'Testing for Equality of Means with PROC GLM';
RUN;
QUIT;
 ```

 We ask for `DIAGNOSTIC` plots. The `MEANS` statement gives us the unadjusted means across each fertilizer type. We put it there for the `HOVTEST`, which we can use to determine equality of variances. You can use the `UNPACK` option to get all of the plots out of the matrix.

 Focus on the two diagnostic plots on the left -- the QQ plot and the histogram -- to determine normality of errors.

 Look at the Cook's D plot to determine if we have any outliers and/or influential points.

 Look at "Levene's Test for Homogeneity of BulbWt Variance". We fail to reject the null, which means that we can assume that all of the variances are the same, so we can continue with the analysis without any problem. The null hypothesis is that the variances are equal over all **Fertilizer** groups.

 Results:

 ```
                          Testing for Equality of Means with PROC GLM                         10
                                                                  09:09 Wednesday, July 17, 2013

                                       The GLM Procedure

                       Levene's Test for Homogeneity of BulbWt Variance
                         ANOVA of Squared Deviations from Group Means

                                         Sum of        Mean
               Source            DF     Squares      Square    F Value    Pr > F

               Fertilizer         3    1.716E-6    5.719E-7       0.98    0.4173
               Error             28    0.000016    5.849E-7

 ```

 If you look at the Fit-Mean/Residual plot, it shows that the spread of the residuals is larger than the spread of the Fit-Mean, showing that we do not explain a lot of the variance with our model. This falls in line with the low R-squared value of 0.17.

 ####Analysis Plan for ANOVA -- Summary

 **Null Hypothesis**: All means are equal

 **Alternative Hypothesis**: At least one mean is different

 1. Produce descriptive statistics.
 2. Verify assumptions: independence, errors are normally distributed, error variances are equal for all groups. Also look for weird influential outliers.
 3. Examine the p-value in the ANOVA table. If the p-value is less than alpha, reject the null.

 **Exercise 2 on page 2-38**

```
/* Exercise 2 on page 2-37 */
PROC MEANS DATA = sasuser.ads PRINTALLTYPES N MEAN STD SKEWNESS KURTOSIS MAXDEC = 2;
    VAR     Sales;
    CLASS   Ad;
    TITLE   'Descriptive Statistics of Ad Sales';
RUN;
```

```
PROC SGPLOT DATA = sasuser.ads;
    VBOX    Sales / CATEGORY = Ad;
    REFLINE 66.82;
    TITLE   'Box and Whisker Plots of Ad Sales';
RUN;
```

```
/* part b */
PROC GLM DATA = sasuser.ads PLOTS(ONLY) = DIAGNOSTICS;
    CLASS Ad;
    MODEL Sales = Ad;
    MEANS Ad / HOVTEST;
    TITLE 'Testing for Equality of Means of Ad Groups with PROC GLM';
RUN;
```

#### Controlled Experiments

- Random assignment might be desirable to eliminate selection bias.
- You often want to look at the outcome measure prospectively.
- You can manipulate the factors of interest and can more reasonably claim causation.
- You can design your experiment to control for other factors contributing to the outcome measure.

**Anything you do not account for in your model is rolled up in your unexplained error.**

This only means that you model does not explain some of the error -- not that it cannot change to explain the error.

**Randomized Complete Block Designs**

If you are trying fertilizers on different plots, there may be characteristics to the plots that affect the study outcome. The idea of this design is to give every fertilizer equal opportunity by dividing the plots by 4 and then putting some of each fertilizer on each plot. This allows you to measure each fertilizer in each scenario.

**Including a Blocking Variable in the Model**

All we're doing is adding another variable to the model instead of just fertilizer.

```
Yik = μ + αi + τi + εik

α is the block variable. 
```

This moves some of the unexplained error into the model error.

Additional assumptions:

- Treatments are randomly assigned within each block
- The effects of the treatment factor are constant across the levels of the blocking variable. There is no interaction between the blocks and treatments.

In the garlic example, the design is balanced, which means that there is the same number of garlic samples for every **Fertilizer/Sector** combination.

Blocking is all about how you collect your data. SAS doesn't care and you don't need more options.

```
proc glm data=sasuser.MGGarlic_Block plots(only)=diagnostics;
     class Fertilizer Sector;
     model BulbWt=Fertilizer Sector;
     title 'ANOVA for Randomized Block Design';
run;
quit;
```

The `Sector` is the variable for blocks. All we are doing is adding another variable to the model. That's it.

```
                               ANOVA for Randomized Block Design                               2
                                                                  13:11 Wednesday, July 17, 2013

                                       The GLM Procedure
Dependent Variable: BulbWt

                                              Sum of
      Source                      DF         Squares     Mean Square    F Value    Pr > F

      Model                       10      0.02307263      0.00230726       5.86    0.0003

      Error                       21      0.00826745      0.00039369

      Corrected Total             31      0.03134008


                      R-Square     Coeff Var      Root MSE    BulbWt Mean

                      0.736202      9.085064      0.019842       0.218398


      Source                      DF       Type I SS     Mean Square    F Value    Pr > F

      Fertilizer                   3      0.00508630      0.00169543       4.31    0.0162
      Sector                       7      0.01798632      0.00256947       6.53    0.0004


      Source                      DF     Type III SS     Mean Square    F Value    Pr > F

      Fertilizer                   3      0.00508630      0.00169543       4.31    0.0162
      Sector                       7      0.01798632      0.00256947       6.53    0.0004

```

Remember that the Type-I SS is sequential. Type III is individual.

Looking at the Model p-value -- it tells us that something in the model is useful. R-squared improved. 

The p-value indicates significance for the Fertilizer type. We have enough evidence to say that the 4 different types of Fertilizer produce different Garlic Bulb Weight.

The p-value for Sector indicates that we have enough evidence to say that the sectors produce different Garlic Bulb Weight.

When we were only looking at Fertilizer, we couldn't find the difference. However, now that we blocked and removed the nuisance factors, we can see that the Fertilizer matters.

Fixed Effects vs. Random Effects model... If you only care about making generalizations regarding the sample that you have, then you have a Fixed Effects model. If you want to generalize to other data, then you need a random effects model.

Remember that you can output the residuals to another data set and then run proc univariate on them to determine if they are normally distributed. (If you can't tell by the QQ plot.)

You cannot block AFTER you have created the data. You have to block when you set up the experiment.

**Exercise 3 from page 2-49**

This still is only looking at the global F-test to determine if ANY of the variables are useful. We have yet to figure out the beta values and to determine how the ads and areas affect the sales.

```
/* Exercise 3 from page 2-49 */
PROC GLM DATA = sasuser.ads1 PLOTS(ONLY) = DIAGNOSTICS;
    CLASS Ad Area;
    MODEL Sales = Ad Area;
    MEANS Ad / HOVTEST;
    TITLE 'Testing for Equality of Means of Ad Groups with Blocking';
RUN;
QUIT;
```

If your data is blocked, you cannot remove the blocking variable. We know from this that blocking is useful, so from now own, we have to block when we collect data.

####My Groups are Different - What Next? Post Hoc Testing

The p-value for Fertilizer indicates you should reject the H0 that all groups are the same. From which pairs of fertilizers, are garlic bulb weights different from one another?

With a fair coin, your probability of getting heads on one flip is 05. If you flip a coin twice, what is the probability of getting **at least** one head out of two? 0.75. You have a 0.25 chance of getting tails twice, so 1-0.25 is the chance of getting heads at least once.

**Comparisonwise Error Rate vs. Experimentwise Error Rate**

Comparisonwise Error Rate|Number of Comparisons|Experimentwise Error Rate
-------------------------|---------------------|-------------------------
0.05|1|0.05
0.05|3|0.14
0.05|6|0.26
0.05|10|0.40

The error rate explodes quickly for the experimentwise error rate, so we have to control it.


To control the experimentwise error rate, we will perform Tukey's test. There's also the Control Dunnett test for special cases.

**Tukey's Multiple Comparison Method**

This method is appropriate when you consider pairwise compairsons only. The experimentwise error rate is:

- equal to alpha when **all** pairwise comparisons are considered.
- less than alpha when **fewer** than all pairwise comparisons are considered.

Tukey assumes that you want to compare everything. 

**Diffograms**

The x and y axes are the values that your data takes -- essentially your means. On the inside, you see different levels (1,2,3,4 for 4 fertilizers). To compare two different things, you have to match them up on your chart. If you want to compare Fertilizer 1 to Fertilizer 3, find 1 at the inset at the bottom and then move up until you intersect Fertilizer 3 (coming from the right). If the line crosses the dashed diagonal (which represents a means difference of 0), there is no significant difference. If it does not cross the line, then they are significantly different.

SAS will give a diffogram for a t-test. DO NOT USE IT. Only use the Diffogram for Tukey's test.

**Special Case - Dunnet**

Comparing to a control is appropriate when there is a natural reference group, such as a placebo group in a drug trial. Not comparing every pair -- just comparing other levels to a single level.

- Experimentwise error rate is no greater than the stated alpha
- Comparing to a control takes into account the correlations among tests.
- One-sided hypothesis tests against a control group can be performed.
- Control coparison computes and tests k-1 groupwise differences, where k is the number of levels of the `CLASS` variable.



```
proc glm data=sasuser.MGGarlic_Block 
         plots(only)=(controlplot diffplot(center));
    class Fertilizer Sector;
    model BulbWt=Fertilizer Sector;
    lsmeans Fertilizer / pdiff=all adjust=tukey;
    lsmeans Fertilizer / pdiff=control('4') adjust=dunnett;
    lsmeans Fertilizer / pdiff=all adjust=t;
    title 'Garlic Data: Multiple Comparisons';
run;
quit;
```

LS-mean control plots are produced only when you specify `PDIFF = CONTROL` or `ADJUST = DUNNETT` in the `LSMEANS` statement.

`CONTROLPLOT` gives you Dunnet's plot and `DIFFPLOT` gives you the Diffogram. Instead of a `MEANS` statement, if you want to do Tukey adjustments, using adjusted means, you have to use `LSMEANS` statements.

`PDIFF=` What differences do you want to test? All of them. Test every single difference.

`ADJUST = TUKEY` will use Tukey's adjustments.

Imagine we had a control/placebo. Then we use the following. You have to put the control level in the parenthesis or SAS will take the first level. Put it in quotes. Use Dunnett because we only are comparing to the placebo/control.
```
lsmeans Fertilizer / pdiff=control('4') adjust=dunnett;
```

Never do this:
```
lsmeans Fertilizer / pdiff=all adjust=t;
```

Tukey has a wider confidence interval.

**Exercise 4: Post Hoc Pairwise Comparisons on p. 2-65**

```
PROC GLM DATA = sasuser.ads1 PLOTS(ONLY) = (CONTROLPLOT DIFFPLOT(CENTER));
    CLASS   Ad Area;
    MODEL   Sales = Ad Area;
    LSMEANS Ad / PDIFF = ALL ADJUST = TUKEY;
    LSMEANS Ad / PDIFF = CONTROL('display') ADJUST = DUNNETT;
    TITLE   'Sales Data: Multiple Comparisons';
RUN;
```

###Two-Way ANOVA with Interactions

We don't need to have just one independent variable -- we can have as many as we want, but then we have to deal with interaction terms. This is called a k-way ANOVA.

**Drug Example**

We will have multiple blood pressure drugs and multiple levels of blood pressure drugs.

```
BloodP = Base Level + Disease + Drug Dose + (DrugDose and Disease Interaction) + Unaccounted for Variation
```

Interaction: the level of one variable influences the effect of another. See page 2-69.

Depending on the disease, it will change the relationship between the dosage and the blood pressure. The value of one variable influences the relationship between another variable and y.

When you have no interaction, the lines are parallel. If they cross or are not parallel (will eventually cross) then you have an interaction.

**Nonsignificant Interaction**

Analyze the main effects with the interaction in the model. or Delete the interaction from the model and then analyze the main effects.

If the interaction is significant, then you must leave in the individual variables that make up the interaction term and the interaction term.

```
proc print data=sasuser.drug(obs=10);
    title 'Partial Listing of Drug Data Set';
run;

/*st102d06.sas*/  /*Part B*/
proc format;
    value dosefmt 1='Placebo'
                  2='50 mg'
                  3='100 mg'
                  4='200 mg';
run;

proc means data=sasuser.drug
           mean var std nway;
    class Disease DrugDose;
    var BloodP;
    format DrugDose dosefmt.;
    output out=means mean=BloodP_Mean;
    title 'Selected Descriptive Statistics for Drug Data Set';
run;
```

Here we are outputting the means to a variable called `BloodP_Mean` in the `means` data set.

Now plot them to explore further.

```
proc sgplot data=means;
    series x=DrugDose y=BloodP_Mean / group=Disease markers;
    xaxis integer;
    title 'Plot of Stratified Means in Drug Data Set';
    format DrugDose dosefmt.;
run;
```

Plot them by drug dose vs. blood pressure and group by disease.

The `xaxis integer` value tells SAS to draw the x-axis as integers. Telling SAS not to get fancy.

It looks like there is an interaction because the lines are not parallel. How can we tell if they are statistically significant interactions?

```
/*st102d06.sas*/  /*Part D*/
proc glm data=sasuser.drug order=internal;
    class  DrugDose Disease;
    model  Bloodp=DrugDose Disease DrugDose*Disease;
    title  'Analyze the Effects of DrugDose and Disease';
    title2 'Including Interaction';
    format  DrugDose dosefmt.;
run;
quit;
```

The interaction term is included in the `model` as `DrugDose*Disease`. `PROC GLM` will create the interaction inside of the step. For `PROC REG`, you have to hard code the interation into the data with a DATA step.

```
                          Analyze the Effects of DrugDose and Disease                         22
                                     Including Interaction        13:11 Wednesday, July 17, 2013

                                       The GLM Procedure

Dependent Variable: BloodP

                                              Sum of
      Source                      DF         Squares     Mean Square    F Value    Pr > F

      Model                       11      36476.8353       3316.0759       7.66    <.0001

      Error                      158      68366.4589        432.6991

      Corrected Total            169     104843.2941


                      R-Square     Coeff Var      Root MSE    BloodP Mean

                      0.347918     -906.7286      20.80142      -2.294118


      Source                      DF       Type I SS     Mean Square    F Value    Pr > F

      DrugDose                     3        54.03137        18.01046       0.04    0.9886
      Disease                      2     19276.48690      9638.24345      22.27    <.0001
      DrugDose*Disease             6     17146.31698      2857.71950       6.60    <.0001


      Source                      DF     Type III SS     Mean Square    F Value    Pr > F

      DrugDose                     3       335.73526       111.91175       0.26    0.8551
      Disease                      2     18742.62386      9371.31193      21.66    <.0001
      DrugDose*Disease             6     17146.31698      2857.71950       6.60    <.0001

```

Overall F-Test: Something is useful in the model. According to this, there is no difference in DrugDose. There is a difference in the average blood pressure among different Diseases. The important part is that `DrugDose*Disease` is significant, meaning that there is an interaction. This means that you cannot trust the p-value on the DrugDose.

On average, the DrugDose does nothing, though the chart shows that Disease A and Disease B are going in different directions. The Interaction is hiding that significance. There actually is a different in drug dosage in disease A and B, probably not in C.

Now, add an `LSMEANS` statement and the option at the end. SAS will "slice" the interaction term by disease. SAS is going to test if there is a difference in drug dose but it will do it within each disease.

It will run a formal test for:

- Is there a difference in drugdosage for disease A?
- Is there a difference in drugdosage for disease B?
- Is there a difference in drugdosage for disease C?

```
/*st102d06.sas*/  /*Part E*/
ods graphics off;
ods select LSMeans SlicedANOVA;
proc glm data=sasuser.drug order=internal;
    class DrugDose Disease;
    model Bloodp=DrugDose Disease DrugDose*Disease;
    lsmeans DrugDose*Disease / slice=Disease;
    title 'Analyze the Effects of DrugDose';
    title2 'at Each Level of Disease';
    format DrugDose dosefmt.;
run;
quit;

ods graphics on;
```

Now, you get the additional output:

```
                                Analyze the Effects of DrugDose                               24
                                    at Each Level of Disease      13:11 Wednesday, July 17, 2013

                                       The GLM Procedure
                                      Least Squares Means

                      DrugDose*Disease Effect Sliced by Disease for BloodP

                                        Sum of
             Disease        DF         Squares     Mean Square    F Value    Pr > F

             A               3     6320.126747     2106.708916       4.87    0.0029
             B               3           10561     3520.222833       8.14    <.0001
             C               3      468.099308      156.033103       0.36    0.7815

```

This shows that there is a statistical difference in A and B, but not in C. This is equivalent to extracting all of the data for disease A and running it through an ANOVA, doing the same for B and C.

The idea of `CLASS` in PROC ANOVA is to tell SAS that it is a categorical variable. The `SLICE` option is to tell SAS that you want an F test within each CLASS.

If you need to test multiple different interactions, then you need an `LSMEANS` statement for each interaction.