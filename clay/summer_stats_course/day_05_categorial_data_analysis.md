##Chapter 5: Categorical Data Analysis

Trying to predict categories that customers will fall into.

###Describing Categorical Data

Look at frequency tables to understand categorical variables. They will reveal structure and association.

**Categorical Variables Association**

- An association exists between two categorical variables if the distribution of one variable changes when the level (or value) or the other variable changes. 
- If there is no association, the distribution of the first variable is the same regardless of the level of the other variable.

No relationship:

.....|Happy|Mad
-----|-----|---
Sunny|72% |28%
Rainy|72% |28%


Association:

.....|Happy|Mad
-----|-----|---
Sunny|82% |18%
Rainy|60% |40%


A frequency table shows the number of observations that occur in certain categories or intervals. A one-way frequency table examines one variable.

**Crosstabulation Table**

A *crosstabulation* table shows the number of observations for each combination of the row and column variable. Each cell should contain frequency, percent, Row Percent, and Column Percent.

Use `PROC FREQ` to see frequency tables.

```
PROC FREQ DATA=dataset;
    TABLES table-requests </options>;
RUN;
```

**Titanic Example...**

Variables are Gender, Fare, Survival, Age, and Class. Fare and Age are not categorical - they are continuous.

```
/*st105d01.sas*/
title;
proc format;
    value survfmt 1 = "Survived"
                  0 = "Died"
                  ;
run;

proc freq data=sasuser.Titanic;
    tables Survived Gender Class
           Gender*Survived Class*Survived /
           plots(only)=freqplot(scale=percent);
    format Survived survfmt.;
run;
```

This will look at Survived, Gender, and Class by themselves. Then you will see a crosstabulation of gender by survived and class by survived. 

```
                              Gender     Survived

                              Frequency‚
                              Percent  ‚
                              Row Pct  ‚
                              Col Pct  ‚Died    ‚Survived‚  Total
                              ƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                              female   ‚    127 ‚    339 ‚    466
                                       ‚   9.70 ‚  25.90 ‚  35.60
                                       ‚  27.25 ‚  72.75 ‚
                                       ‚  15.70 ‚  67.80 ‚
                              ƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                              male     ‚    682 ‚    161 ‚    843
                                       ‚  52.10 ‚  12.30 ‚  64.40
                                       ‚  80.90 ‚  19.10 ‚
                                       ‚  84.30 ‚  32.20 ‚
                              ƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                              Total         809      500     1309
                                          61.80    38.20   100.00

```

127 females died. Females were 9.7% of total data. Approx 27.25% of all females died. Of those who died, only about 15.7% were female.

Looking at class:
```
                              Class     Survived

                              Frequency‚
                              Percent  ‚
                              Row Pct  ‚
                              Col Pct  ‚Died    ‚Survived‚  Total
                              ƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                                     1 ‚    123 ‚    200 ‚    323
                                       ‚   9.40 ‚  15.28 ‚  24.68
                                       ‚  38.08 ‚  61.92 ‚
                                       ‚  15.20 ‚  40.00 ‚
                              ƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                                     2 ‚    158 ‚    119 ‚    277
                                       ‚  12.07 ‚   9.09 ‚  21.16
                                       ‚  57.04 ‚  42.96 ‚
                                       ‚  19.53 ‚  23.80 ‚
                              ƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                                     3 ‚    528 ‚    181 ‚    709
                                       ‚  40.34 ‚  13.83 ‚  54.16
                                       ‚  74.47 ‚  25.53 ‚
                                       ‚  65.27 ‚  36.20 ‚
                              ƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                              Total         809      500     1309
                                          61.80    38.20   100.00

```

More people survived than died if you were a first class customer. There were more rich females and more 3rd class males. You can't see that in this chart, however.

Now, look at `PROC UNIVARIATE` for the continuous variables:
```
proc univariate data=sasuser.Titanic noprint;
    class Survived;
    var Age ;
    histogram Age;
    inset mean std median min max / format=5.2 position=ne;
    format Survived survfmt.;
run;
```

Look at Age by whether you survived or died. Look at variable age, split up by whether you survived. Draw a histogram. Record the mean, std, median, min, and max in the inset box, for reference.

Now that we've seen that it looks like there are some relationships, we need to test if they are actually present. 

- Perform a chi-square test for association
- Examine the strength of the association
- Calculate exact p-values
- Perform a Mantel-Haenszel chi-square test

*Testing for an association between gender and survival**

Null Hypothesis:

- There is no association between **Gender** and **Survival**
- The probability of surviving the Titanic crash was the same whether you were male or female

Alternative Hypothesis:

- There **is** an association between **Gender** and **Survival**
- The probability of surviving the Titanic crash was not the same for males and females.


####The Pearson Chi-Square Test (Χ)

Compare what we would actualy see to what we would expect to see under the null hypothesis.

Basically comparing these tables:


.....|Happy|Mad
-----|-----|---
**Sunny**|72% |28%
**Rainy**|72% |28%



.....|Happy|Mad
-----|-----|---
**Sunny**|82% |18%
**Rainy**|60% |40%


Chi-square tests and the corresponding p-values:

- determine whether an association exists
- do not measure strength of an association
- depend on and reflect the sample size

To perform this, for each cell, you do:

```
SUM((observed - expected)^2/expected)
```

####Cramer's V

It has a range of -1 to 1 for 2-by-2 tables and 0 to 1 for larger tables. Values farther from 0 indicate stronger association. Cramer's V statistic is derived from the Pearson chi-square statistic.


###Odds Ratios

An *odds ratio* indicates how much more likely, with respect to odds, a certain event occurs in one group relative to its occurrence in another group.

```
Odds = p.event/(1-p.event)
```

The odds ratio can be used as a measure of the strength of association for 2x2 tables. Do not mistake odds for probability. Odds are calculated from probabilities.

Typically, we will look at the likelihood ratio instead of Pearson's Chi-Square

**Probability vs. Odds of an Outcome**

...|Yes Outcome|No Outcome|Total
---|-----------|----------|-----
**GroupA**|60|20|80
**GroupB**|90|10|100
**Total**|150|30|180

Calcualte Probability:
```
Total YES outcomes in Group B / Total outcomes in Group B = 90 / 100 = 0.9
```

**Probability** of a **YES** in Group B = 90/100 = 0.9.

Calculate Odds:
```
Probability of YES in Group B / Probability of NO in group B = 0.90 / 0.10 = 9
```

**Odds** of **Yes** in Group B = 0.90 / 0.10 = 9

Calculate Odds Ratio:
```
Odds of YES in Group A / Odds of YES in Group B = 3 / 9 = 0.3333
```

**Odds Ratio** of A to B = 3 / 9 = 0.3333

The odds of getting the outcome in group A are one third those in group B. If you were interested in the odds ratio of group B to group a, you would simply take the inverse of 1/3 to arrive at 3.

Group A had 1/3 the odds that the outcome occured compared to Group B.

**Properties of the Odds Ratio, A to B**

If Group A and Group B had the same odds of doing something, their odds ratio would be 1.

The odds ratio shows the strength of the association between the predictor variable and the outcome variable. If the odds ratio is greater than 1, then group A, the numerator group, is more likely to have the outcome. If the odds ratio is less than 1, then group B, the denominator group, is more likely to have the outcome.

**SAS Example of Chi-square tests**

This is saying that you want **both** Gender and Class by Survived. `PROC FREQ` has a ton of options.

- `chisq` gives you Pearson, likelihood ratio, and all tests of association. 
- `expected` gives you the expected cell count for each cell in the table (an additional number)
- `cellchi2` gives you the exact piece of the Pearson Chi-Square test that the one cell contributes to. This helps show which cells have the biggest difference and provide the most evidence that there is an association.
- `nocol` does not report the column percentages
- `nopercent` does not report the overall percentage
- `relrisk` stands for "Relative Risk" and is where the Odds Ratio is located.

```
/*st105d02.sas*/
ods graphics off;
proc freq data=sasuser.Titanic;
    tables (Gender Class)*Survived
          / chisq expected cellchi2 nocol nopercent 
            relrisk;
    format Survived survfmt.;
    title1 'Associations with Survival';
run;

ods graphics on;
```

```
                                  Table of Gender by Survived

                           Gender          Survived

                           Frequency      ‚
                           Expected       ‚
                           Cell Chi-Square‚
                           Row Pct        ‚Died    ‚Survived‚  Total
                           ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                           female         ‚    127 ‚    339 ‚    466
                                          ‚    288 ‚    178 ‚
                                          ‚ 90.005 ‚ 145.63 ‚
                                          ‚  27.25 ‚  72.75 ‚
                           ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                           male           ‚    682 ‚    161 ‚    843
                                          ‚    521 ‚    322 ‚
                                          ‚ 49.753 ‚ 80.501 ‚
                                          ‚  80.90 ‚  19.10 ‚
                           ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                           Total               809      500     1309

```

If there was no relationship, we would have expected 288 females to die (instead of 127). There were 339 females that survived. If there was no relationship, we would have expected 178 females to survive. 

`(178-339)^2/178 = 145.63` is the Cell Chi-Square for Females who survived.

These are the Chi-Square tests:

```
                           Statistics for Table of Gender by Survived

                     Statistic                     DF       Value      Prob
                     ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                     Chi-Square                     1    365.8869    <.0001
                     Likelihood Ratio Chi-Square    1    372.9213    <.0001
                     Continuity Adj. Chi-Square     1    363.6179    <.0001
                     Mantel-Haenszel Chi-Square     1    365.6074    <.0001
                     Phi Coefficient                      -0.5287
                     Contingency Coefficient               0.4674
                     Cramer's V                           -0.5287
```

The first is the Pearson Chi-Square test. There is an association between Gender and Survival. The value of Cramer's V -- the further from 0 the better. Cramer's V is made to compare two things.

Fisher's Exact test is for when you don't have a large enough sample.

Odds Ratio:
```
                           Statistics for Table of Gender by Survived

                          Estimates of the Relative Risk (Row1/Row2)

               Type of Study                   Value       95% Confidence Limits
               ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
               Case-Control (Odds Ratio)      0.0884        0.0677        0.1155
               Cohort (Col1 Risk)             0.3369        0.2894        0.3921
               Cohort (Col2 Risk)             3.8090        3.2797        4.4239
```

The Odds Ratio that we are interested in is 0.0884. Look at the table to see what Row1/Row2 is. This is the odds that the females is doing something versus the odds of males doing something. It is telling you the odds of the first category, which is Death. The odds that a female dies is close to 1/10 of the odds of a male dying. The odds that a female dies is 0.088 of the odds that a male dies. Take the inverse: The odds that a male dies is 11.36 times more than that a female dies.

If we wanted to swap this, the best thing to do is to code SAS to make survived come before died. Instead of coding died as 0 and survived as 1, then code survived as 1 and died as 2.

Look at the confidence intervals for the Odds Ratio. If it contained 1, then it would mean that there is no significant difference between the odds that a female died and the odds that a male died.

Relative risks are the ratios of the probabilities:
```
Probability of Female Dies / Probability of Male Dies = Col1 Risk
```
 Now, looking at Class
 ```
                           Statistics for Table of Class by Survived

                     Statistic                     DF       Value      Prob
                     ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                     Chi-Square                     2    127.8592    <.0001
                     Likelihood Ratio Chi-Square    2    127.7655    <.0001
                     Mantel-Haenszel Chi-Square     1    127.7093    <.0001
                     Phi Coefficient                       0.3125
                     Contingency Coefficient               0.2983
                     Cramer's V                            0.3125

                                       Sample Size = 1309

 ```

 Cramer's V will be between 0 and 1 because we don't have a 2x2 table. We do not get odds ratios because we have more than a 2x2 table. The table shows a difference between class and survival.


**Sample Size Requirements and When Not to Use Chi-Square Tests**

Do not use the Asymptotic Chi-Square when more than 20% of cells have expected counts less than five. It doesn't actually observe -- it only matters what your expected cell counts are.

In the 2x2 table, if you only observed 1 day when your boss was happy on a rainy day -- it doesn't matter, as long as the **expected** count in that cell is more than 5.

**What to do with small sample sizes: calculate exact p-values**

The Chi-Square tests are approximations that can be used with large sample sizes. 

The `EXACT` statement provides exact p-values for many tests in the `FREQ` procedure.

A p-value gives the probability of the value of the Chi-Square value being as extreme or more extreme than the one observed, just by chance. It calculates every possible value for a cell and then calculates the possibility that you got the value that you did in the cell. Do not do this with large sample sizes.

After SAS determines the probability that you got the results that you did, it adds it to the probabilities of getting the ones that ARE MORE EXTREME, to come up with the exact p-value. The ones that are more extreme are the ones with a higher Chi-square value than the observed cell. The cells follow the "hypergeometric distribution." A hypergeometric distribution is not a continuous distribution -- it is a discreet distribution.

*The exact p-value is the sum of probabilities of all tables with Chi-squar values as great or greater than that of the observed table.*

**Example in SAS**

There is an `EXACT` statement to pull this data out of SAS.

```
proc freq data=sasuser.exact;
   tables A*B / chisq expected cellchi2 nocol nopercent;
   title "Exact P-Values";
run;
```

In tables larger than 2x2, you have to force it to show the Fisher's Exact Test.

```
                                         Exact P-Values        09:03 Thursday, July 18, 2013  10

                                       The FREQ Procedure

                                        Table of A by B

                           A               B

                           Frequency      ‚
                           Expected       ‚
                           Cell Chi-Square‚
                           Row Pct        ‚       1‚       2‚  Total
                           ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                                        1 ‚      0 ‚      3 ‚      3
                                          ‚ 0.8571 ‚ 2.1429 ‚
                                          ‚ 0.8571 ‚ 0.3429 ‚
                                          ‚   0.00 ‚ 100.00 ‚
                           ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                                        2 ‚      2 ‚      2 ‚      4
                                          ‚ 1.1429 ‚ 2.8571 ‚
                                          ‚ 0.6429 ‚ 0.2571 ‚
                                          ‚  50.00 ‚  50.00 ‚
                           ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                           Total                 2        5        7


                                 Statistics for Table of A by B

                     Statistic                     DF       Value      Prob
                     ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                     Chi-Square                     1      2.1000    0.1473
                     Likelihood Ratio Chi-Square    1      2.8306    0.0925
                     Continuity Adj. Chi-Square     1      0.3646    0.5460
                     Mantel-Haenszel Chi-Square     1      1.8000    0.1797
                     Phi Coefficient                      -0.5477
                     Contingency Coefficient               0.4804
                     Cramer's V                           -0.5477

                      WARNING: 100% of the cells have expected counts less
                               than 5. Chi-Square may not be a valid test.


                                      Fisher's Exact Test
                               ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                               Cell (1,1) Frequency (F)         0
                               Left-sided Pr <= F          0.2857
                               Right-sided Pr >= F         1.0000

                               Table Probability (P)       0.2857
                               Two-sided Pr <= P           0.4286

                                        Sample Size = 7
```

Look at Fisher's Exact Test for Two-Sided results. The p-value is 0.4286.

####Associations Between Ordinal Variables (ORDER MATTERS)

Class is an example of this.

We will use the Mantel-Haenszel Chi-Square Test to test ordinal association. It is more specifically designed to handle ordinal vs. ordinal relationships. Pearson and Likelihood ratios can be used to test ordinals, but they don't work well here.

Recall that ordinal variables can only be written forwards and backwards.

Null Hypothesis: There is no **linear** association between variables.
Alternative Hypothesis: There is a **linear** association between variables.

####Mantel-Haenszel Chi-Square Test

- Determines whether an ordinal association exists
- Does not measure the strength of the ordinal association
- Depends on and reflects the sample size

####Spearman Correlation Statistic

To measure the strength of the ordinal association, you can use the Spearman correlation statistic. This statistic:

- Has a range between -1 and 1
- Has values close to 1 if ther eis a relatively high degree of positive correlation
- Has values close to -1 if there is a relatively high degree of negative correlation
- Is appropriate only if both variables are ordinal scaled and the values are in a logical order.

Spearman looks simply at whether if one variable goes up, the other has a tendency to go up.

If Y goes 1 -> 2 -> 3 -> 4 when X goes 1 -> 2 -> 3 -> 4, then the Spearman Correlation Statistic is 1.

**REMEMBER WHICH TESTS TO USE**

- Ordinal: Mantel-Hanzel tests for association, Spearman is strength
- Nominal: Pearson & Likelihood tests for association, Cramer's V tests strength.

Examples in SAS. We have to put the `MEASURES` option to get the Spearman correlation. It reports different measures of strength of association. `CL` reports confidence limits around all of the measures calculated. `CHISQ` gives the tests of association.
```
proc freq data=sasuser.Titanic;
    tables Class*Survived / chisq measures cl;
    format Survived survfmt.;
    title1 'Ordinal Association between CLASS and SURVIVAL?';
run;
```


Results. SAS decides which variable goes on the rows -- the first variable always goes on the rows. If you want to switch them around, then list `TABLES Survived*Class / ...` instead.
```
                        Ordinal Association between CLASS and SURVIVAL?                       13
                                                                   09:03 Thursday, July 18, 2013

                                       The FREQ Procedure

                                   Table of Class by Survived

                              Class     Survived

                              Frequency‚
                              Percent  ‚
                              Row Pct  ‚
                              Col Pct  ‚Died    ‚Survived‚  Total
                              ƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                                     1 ‚    123 ‚    200 ‚    323
                                       ‚   9.40 ‚  15.28 ‚  24.68
                                       ‚  38.08 ‚  61.92 ‚
                                       ‚  15.20 ‚  40.00 ‚
                              ƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                                     2 ‚    158 ‚    119 ‚    277
                                       ‚  12.07 ‚   9.09 ‚  21.16
                                       ‚  57.04 ‚  42.96 ‚
                                       ‚  19.53 ‚  23.80 ‚
                              ƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                                     3 ‚    528 ‚    181 ‚    709
                                       ‚  40.34 ‚  13.83 ‚  54.16
                                       ‚  74.47 ‚  25.53 ‚
                                       ‚  65.27 ‚  36.20 ‚
                              ƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                              Total         809      500     1309
                                          61.80    38.20   100.00


                           Statistics for Table of Class by Survived

                     Statistic                     DF       Value      Prob
                     ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                     Chi-Square                     2    127.8592    <.0001
                     Likelihood Ratio Chi-Square    2    127.7655    <.0001
                     Mantel-Haenszel Chi-Square     1    127.7093    <.0001
                     Phi Coefficient                       0.3125
                     Contingency Coefficient               0.2983
                     Cramer's V                            0.3125

```

You want to look at Mantel-Haenszel Chi-Square for the association here. There is an association and it is statisticaly significant.

In the following results, look for Spearman Correlation:
```
                        Ordinal Association between CLASS and SURVIVAL?                       14
                                                                   09:03 Thursday, July 18, 2013

                                       The FREQ Procedure

                           Statistics for Table of Class by Survived

                                                                           95%
          Statistic                              Value       ASE     Confidence Limits
          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
          Gamma                                -0.5067    0.0375    -0.5801    -0.4332
          Kendall's Tau-b                      -0.2948    0.0253    -0.3444    -0.2451
          Stuart's Tau-c                       -0.3141    0.0274    -0.3677    -0.2604

          Somers' D C|R                        -0.2613    0.0226    -0.3056    -0.2170
          Somers' D R|C                        -0.3326    0.0286    -0.3887    -0.2765

          Pearson Correlation                  -0.3125    0.0267    -0.3647    -0.2602
          Spearman Correlation                 -0.3097    0.0266    -0.3619    -0.2576

          Lambda Asymmetric C|R                 0.1540    0.0331     0.0892     0.2188
          Lambda Asymmetric R|C                 0.0317    0.0320     0.0000     0.0944
          Lambda Symmetric                      0.0873    0.0292     0.0301     0.1445

          Uncertainty Coefficient C|R           0.0734    0.0127     0.0485     0.0983
          Uncertainty Coefficient R|C           0.0485    0.0084     0.0320     0.0650
          Uncertainty Coefficient Symmetric     0.0584    0.0101     0.0386     0.0782

                                       Sample Size = 1309
```

The value for Spearman is negative, so as Class goes up, Survival goes down. When Spearman is negative, when one category is getting larger (Class) the other category is getting smaller (Survival).

ASE in the results is the Asymptotic Standard Error that is used to calculate the Confidence Limits. It's basically the spread around the statistic value.

**Exercise 1: Performing Tests and Measures of Association from p. 5-43**

```
/* Example 1 from page 5-43 */

PROC FREQ DATA = sasuser.safety;
    TABLES Unsafe Type Region Weight Size;
RUN;

* The proportion of cars made in NA is 63.54;

PROC FORMAT;
    VALUE SAFEFMT 0 = 'Average or Above'
                  1 = 'Below Average';
RUN;

PROC FREQ DATA = sasuser.safety;
    TABLES Region*Unsafe / EXPECTED CHISQ RELRISK;
    FORMAT Unsafe SAFEFMT.;
    TITLE  'Association between Region and Unsafe';
RUN;

* 42.86% of Asian cars had a below-average safety score;
* 69.7% of cars with average or above safety were made in NA;
* Both variables considered ordinal, so use the Fisher's exact to
  see that there is not a statistically significant relationship;
* The odds that a NA car is Average or Above in safety, compared to 
  an Asian car, is 2.23.;

PROC FREQ DATA = sasuser.safety;
    TABLES Size*Unsafe / CHISQ MEASURES CL;
    FORMAT Unsafe SAFEFMT.;
    TITLE  'Association between Size and Safety';
RUN;
```

###Introduction to Logistic Regression on p. 5-45

Now that we have *explored* the data, let's try to *model* the categorical variables.

**Predictors: Continuous (or Continuous and Categorical), Response: Categorical**

If you have a continuous response variable, use linear regression. If you have a categorical response variable, you have to use logistic regression.

Logistic Regression can be used to model ANY categorical variable. We will ONLY talk about **binary** ones during the summer.

`PROC REG` will see binary variables as any number and won't know that it is bounded between 0 and 1. Linear regression is not made to try to predict a probability. That's why we use logistic regression. With `PROC REG`, we have to assume a linear probability model. The values also will take on arbitrary meaning.

With logistic regression, we will not have normality or constant variance. You can't measure a residual if you don't have a true value. You either are right or wrong when you guess, unlike being off by a certain value.

There are no errors, so you can't minimize them for an ordinary least squares model. 

We get around this by saying that probabilities follow a curve (S-shaped -- sigmoid) instead of a straight line.

####Logit Transformation, p. 5-51

```
logit(p.i) = ln(p.i/(1-p.i))

i = indexes of all cases (observations)
p.i = is the probability that the event (for example, a sale) occurs in the ith case
ln is the natural log (to the base e)

The logit is the natural log of the odds.
```

If you can model the logit, then simple algebra enables you to model the odds or the probability. The logit transformation ensures that the model generates estimate probabilities between 0 and 1.

Remember that `p/(1-p)` is the odds. We are predicting the natural log of the odds, which models percentages instead of standard values.

**Assumptions**

- Independence
- The logit has a linear relationship with the predictor variables. (You are assuming that your data actually follows an S-curve that is the logistic curve. -- that the logit transformation gives a straight line on the other side, once the transform is removed.). This is an assumption that we have to check. **The assumption is that the logistic transformation is the correct one.**

####The Logistic Regression Model

For a binary response variable, the linear logistic model with one predictor variable has the form below:
```
logit(p.i) = B0 + B1X1.i + ... + BkXk.i
```

The natural log of 0 is negative infinity. The logit can approach negative infinity -- it is the lowest bound. SAS will never tell you a probability is 0.

The upper bound on the logit is positive infinity. 

The -infinity to infinity bounds are what make the logit mimick the linear regression.

####The `LOGISTIC` Procedure

General Form:

```
PROC LOGISTIC DATA = dataset
    CLASS variables * put categorical variables here;
    MODEL response = predictors;
    UNITS independent1 = list;
    ODDSRATIO <'label'> variable;
    OUTPUT OUT = dataset KEYWORD = name;
RUN;
```

You can do an odds ratio for a continuous ratio. `UNITS` will change how many units you want to look out for that example. If x goes up by 1, y goes up by 1 on average, etc...  UNITS will converts results into "if x goes up by 10, then y goes up by...".

**SAS Example**

```
/*st105d05.sas*/
proc logistic data=sasuser.Titanic
              plots(only)=(effect oddsratio);
    model Survived(event='1')=Age / clodds=pl;
    title1 'LOGISTIC MODEL (1):Survived=Age';
run;
```

THe `CLODDS` option means "Confidence Level for the Odds". You will **always** put `clodds=pl`. It says that you want the 'profile likelihood' method of calculating the odds. The old method is the walled method and is not as accurate.

We are trying to model `Survived` and we are going to use `Age` to try to predict it. We have to specify what we are trying to model. Do you want to model the probability of survival or the probability of death? The `Survived(event='1')` statement says that we are trying to predict the '1' value -- the probability that somebody survived. If you wanted to predict death, then you would use `Survived(event='0')`. You **always** have to specify an `event=` option.

You could put `Survived(event='Y')`.

Results:
```
                                     The LOGISTIC Procedure

                                       Model Information

                         Data Set                      SASUSER.TITANIC
                         Response Variable             Survived
                         Number of Response Levels     2
                         Model                         binary logit
                         Optimization Technique        Fisher's scoring


                            Number of Observations Read        1309
                            Number of Observations Used        1046


                                        Response Profile

                               Ordered                      Total
                                 Value     Survived     Frequency

                                     1            0           619
                                     2            1           427

                               Probability modeled is Survived=1.
   
NOTE: 263 observations were deleted due to missing values for the response or explanatory
      variables.

```

Shows you what you have in your data in the 'Response Profile'. Tells you what you modeled.

```
                                    Model Convergence Status

                         Convergence criterion (GCONV=1E-8) satisfied.


                                      Model Fit Statistics

                                                          Intercept
                                           Intercept            and
                             Criterion          Only     Covariates

                             AIC            1416.620       1415.301
                             SC             1421.573       1425.207
                             -2 Log L       1414.620       1411.301

```

Make sure that the model converged. Smaller is better with the `-2 Log L` Statistic. A model with no variables gives me a model of `1416` and with variables of `1415`. The SC output is showing that Age is not a very good predictor because SC went up from Intercept only to Intercept and Covariates.

```
                               LOGISTIC MODEL (1):Survived=Age                               25
                                                                   09:03 Thursday, July 18, 2013

                                     The LOGISTIC Procedure

                            Testing Global Null Hypothesis: BETA=0

                    Test                 Chi-Square       DF     Pr > ChiSq

                    Likelihood Ratio         3.3191        1         0.0685
                    Score                    3.3041        1         0.0691
                    Wald                     3.2932        1         0.0696


                           Analysis of Maximum Likelihood Estimates

                                             Standard          Wald
              Parameter    DF    Estimate       Error    Chi-Square    Pr > ChiSq

              Intercept     1     -0.1335      0.1448        0.8501        0.3565
              Age           1    -0.00800     0.00441        3.2932        0.0696


                  Association of Predicted Probabilities and Observed Responses

                       Percent Concordant      51.3    Somers' D    0.050
                       Percent Discordant      46.4    Gamma        0.051
                       Percent Tied             2.3    Tau-a        0.024
                       Pairs                 264313    c            0.525


                Odds Ratio Estimates and Profile-Likelihood Confidence Intervals

                   Effect         Unit     Estimate     95% Confidence Limits

                   Age          1.0000        0.992        0.983        1.001

```

The global null hypothesis is that all of the variables = 0. The alternative is that at least one of the variables is useful.

Look at the Likelihood Ratio test; it has the best properties. Based on this test, the model is not useful.

**Analysis of Maximum Likelihood Estimates**

These are the parameter estimates, the beta-0 and beta-1. We don't have t-tests here; we have chi-square tests instead. Look at the p-value for age; it's not useful. The global test would test all variables, even if we had 20 of them.

Wald does a good job of predicting estimates, but a bad job of predicting odds ratios.

Next are the statistics to tell you if you have a good model.

Look at the Odds Ratio Estimates -- this gives good confidence intervals (profile likelihood) and the odds ratio. The confidence interval for odds ratios contains 1, so it means that Age isn't a useful variable.

The Odds Ratio chart allows you to see if 1 is inside your confidence interval.

The S-curve is depicted in the "Predicted Probabilities" chart at the bottom. The plot looks relatively straight because Age isn't very important. As age goes up, the probability of survival slowly drops.

If you used these estimates to write a prediction model, it would look like:

```
-0.13 - 0.008Age = Y*


p = 1/(1+e^-(-0.13 - 0.008Age))
```

You can use `PROC SCORE` to test.

**Odds Ratio Calculation from the Current Logistic Regression Model -- for a continuous variable**

```
Odds Ratio = e^(-0.008) = 0.992 (from the previous example)

e^β1

Odds = e^(β0 + β1.Age)
```

-0.008 is the estimate of the coefficient for age, as seen in the previous results screen.

Here is where you can use the `UNITS` statement in `PROC LOGISTIC` to see what the odds will be over 10 years, for example, instead of 1.

The parameter estimates reflect the change in the odds. The odds are going down by 1% if you go up in Age by 1 year.

###Model Assessment: Comparing Pairs

Use this to compare one model to another.

In general, you want a high number of concordant pairs and a low number of discordant and tied pairs. A concordant pair means that your model did something good. A discordant pair means your model did something bad. Tied means that your model didn't know what to do.

Pick one person out of each group (survived and dead). If the model says that the person from the survived group had a higher likelihood of surviving than the person from the dead group, that is a concordant pair and is evidence that the model did well.

```
/* Concordant Pair */
Subject 1: Died, Age 30. P(survived) = 0.4077
Subject 2: Alive Age 20. P(survived) = 0.4272

/* Discordant Pair */
Subject 1: Died, Age 35. P(survived) = 0.3981
Subject 2: Alive Age 45. P(survived) = 0.3791

/* Tied Pair */
Subject 1: Died, Age 50. P(survived) = 0.3697
Subject 2: Alive Age 50. P(survived) = 0.3697
```

The model correctly predicted that the person who did survive had a higher probability of surviving than the person that died.

**Exercise 2: p. 5-66**

```
/* Exercise 2 from page 5-66 */

PROC LOGISTIC DATA = sasuser.safety PLOTS(ONLY) = (EFFECT ODDSRATIO);
    MODEL Unsafe(event='1') = Weight / CLODDS = PL;
    TITLE 'Logistic Model: Unsafe = Weight';
RUN;

/* Y* = logit(predicted probability of being unsafe) = 3.5422 - 1.3901Weight

   For each increase in 1000 lbs of the car, the odds for being unsafe are 25% of 
   what they used to be; or the odds of the car being unsafe drops by 75% 

   If the weight goes up by 1000 lbs, the odds of you being safe is 4 times greater
   as compared to how safe you were before.

*/
```

Take the reciprocal here:
```
PROC LOGISTIC DATA = sasuser.safety PLOTS(ONLY) = (EFFECT ODDSRATIO);
    MODEL Unsafe(event='1') = Weight / CLODDS = PL;
    TITLE 'Logistic Model: Unsafe = Weight';
RUN;
```

**Adding Categorical Variables into the Model**

Using Categories to predict categories.

The `CLASS` statement creates a set of "design variables" representing the information in the categorical variables.

- Character variables cannot be used, as is, in a model.
- The design ariables are the ones actually used in model calculations
- There are several "parameterizations" available in `PROC LOGISTIC`.

If you have a categorical variable, you **HAVE** to put it in the `CLASS` statement. If you put it in the `CLASS` statement, you **must** include it in the model.


**EFFECTS CODING**: By default, SAS will use effects coding. If we have low, medium, and high as categories, we need two dummy variables and have to set a reference level. If we select high as the reference variable, it is coded as -1 in the fields of the other variables. With reference coding, we are comparing one of the categories to the overall average. Is low income different, in the probability of doing something, versus the overall probability of doing something in all groups. With effects coding, we can only ask if the design variable levels are different. We cannot ask if the reference variable is different (we will do that in the fall).

See the slide on page 5-70. Estimate for Low Income IncLevel1 is 0.2259 below the average. The p-value says that it is not significant, meaning that Low Income is not statistically different from the overall average.

There also is no difference in medium income and the overall average, with regards to probabilities.

**REFERENCE CODING**: The reference level is all zeros instead of -1. It is still High Income. Reference coding compares everything to the reference. B0 is the value of the logit when income is high. The data is the same, but the results are different (p 5-71). Here we can look at the significance of IncLevel 1 and say that low income is statistically different from high income. We also can say that medium is different from high. Neither of them, however, is different from the overall average.

First, test the entire thing to see if Income is useful. Then use Effecting Coding; if nothing in income seems useful, then we go back and recode it to Reference Coding to look for significance.

Odds Ratios for Categorical Predictors are easier to interpret.

The actual logit will be the intercept + the level of interest. For the quiz on page 5-72. The answer is -0.7563. The value of dummy variable for income level 1 is 0 when the dummy variable for level 2 is 1. Cancel the dummy 1 variable out of the equation and sum the intercept and the remaining beta coefficient for dummy variable 2.

In effects coding, the value of the logit for the reference level equals the intercept - beta1 - beta2. In reference coding, the value of the logit for the reference level equals the intercept.

**Multiple Logistic Regression**

 Three "overall" variables: Gender, Class, and Age. Gender needs 1 variable, Age needs 1 (continuous) variable, and Class needs 2 variables (for the 3 levels).

 ```
/*st105d06.sas*/
proc logistic data=sasuser.Titanic plots(only)=(effect oddsratio);
    class Gender(ref='male') Class(ref='3') / param=ref;
    model Survived(event='1')=Age Gender Class / clodds=pl;
    units age=10;
    title1 'LOGISTIC MODEL (2):Survived=Age Gender Class';
run;
 ```

 For `CLASS`, we list out our two categorical variables. You can specify the reference level, as shown, in parentheses. This tells SAS, "if you see male, that is your reference level. everything else is not."

 We have to change the type of coding that we use. You can change it globally with the `/ PARAM = ref` option. That makes it reference coding for all variables. If it is AFTER the slash, it is on all variables. 

 If you wanted Gender to be effects and Class to be reference, you can do:
 ```
 CLASS Gender(ref='male' param=ref)
 ```

 If you put the param with the class variable and in the global, the global takes precedence for the entire model.

 ALWAYS put `CLODDS = PL`. 

 This includes the `UNITS age = 10;` statement, to look for the odds ratios changing for 10 year age increments.

 ```
                         LOGISTIC MODEL (2):Survived=Age Gender Class                        34
                                                                   09:03 Thursday, July 18, 2013

                                     The LOGISTIC Procedure

                                      Model Fit Statistics

                                                          Intercept
                                           Intercept            and
                             Criterion          Only     Covariates

                             AIC            1416.620        992.315
                             SC             1421.573       1017.079
                             -2 Log L       1414.620        982.315


                            Testing Global Null Hypothesis: BETA=0

                    Test                 Chi-Square       DF     Pr > ChiSq

                    Likelihood Ratio       432.3052        4         <.0001
                    Score                  386.1522        4         <.0001
                    Wald                   277.3202        4         <.0001


                                   Type 3 Analysis of Effects

                                                   Wald
                           Effect      DF    Chi-Square    Pr > ChiSq

                           Age          1       29.6314        <.0001
                           Gender       1      226.2235        <.0001
                           Class        2      103.3575        <.0001


                            Analysis of Maximum Likelihood Estimates

                                                 Standard          Wald
           Parameter           DF    Estimate       Error    Chi-Square    Pr > ChiSq

           Intercept            1     -1.2628      0.2030       38.7108        <.0001
           Age                  1     -0.0345     0.00633       29.6314        <.0001
           Gender    female     1      2.4976      0.1661      226.2235        <.0001
           Class     1          1      2.2907      0.2258      102.8824        <.0001
           Class     2          1      1.0093      0.1984       25.8849        <.0001


                  Association of Predicted Probabilities and Observed Responses

                       Percent Concordant      83.8    Somers' D    0.680
                       Percent Discordant      15.8    Gamma        0.683
                       Percent Tied             0.4    Tau-a        0.329
                       Pairs                 264313    c            0.840

```

The Type 3 Analysis of Effects shows you that your Class is statistically significant -- overall, the class variable is useful. It is like an F-test within its own variable. As long as something is different within Class, then we know that we can look at the Analysis of Maximum Likelihood Estimates. If it is insignificant in this chart, then we know that we can throw out the Class variable from the model. If it shows here as useful but shows as insignificant in the Analysis of Maximum Likelihood Estimates, then we need to recode the Class variable to make sure that we are making the right comparison.

The Analysis of Maximum Likelihood Estimates shows that the class variable is useful because each level of them is different from the reference. In this example, Class 1 is different from Class 3 and Class 2 is different from Class 3. There is no test that tells us if Class 1 is different from Class 2.

Now, with the Association of Predicted Probabilities and Observed Responses (pair testing), we see that the Percent Concordant is pretty good. It means that 83.8% of the time, the model will properly predict the outcme from the pairs of people. Only 0.4% of people had the same Gender, Age, and Class and had different outcomes.

```
               Odds Ratio Estimates and Profile-Likelihood Confidence Intervals

           Effect                        Unit     Estimate     95% Confidence Limits

           Age                        10.0000        0.708        0.625        0.801
           Gender female vs male       1.0000       12.153        8.823       16.925
           Class  1 vs 3               1.0000        9.882        6.395       15.513
           Class  2 vs 3               1.0000        2.744        1.863        4.059

```

Females have 12.15 times the odds of surviving compared to males. Since this isn't the same as the previous example, it means that there is a little multicollinearity. Class 1 passengers had 10 times the odds of survival of Class 3 passengers. Class 2 had 2.7 times the odds of survival of Class 3 passengers.

The odds ratio plot shows that all of the variables are significant because none of the confidence intervals includes 1.

If Age goes up by 10, you have 70% the chance of survival as before. If you are 10 years younger, you have a 30% greater chance of surviving.

The odds ratios are all odds ratios for survival.

The confidence intervals are centered around the log of what's happening, but when we translate them back to reality, the confidence intervals aren't symmetric.

See the chart on page 5-78.

Age previously wasn't significant, but now that we've added other variables, it's suddenly useful. The graph breaks it down by all gender and class combinations. A baby female from rich parents was highly likely to survive. Older females also had a good chance of surviving. 3rd class passenger male babies only had a 25% chance of making it off of the boat. However, -- don't extrapolate. Make sure you look at your data to see if there were any 3rd Class male babies on the Titanic. A 3rd class female passenger had a slightly better chance than a first class male passenger of getting off of the ship.

The curves on this graph might cross if there is an interaction. Holding Age and Gender constant, the descending order of predicted survival probabilities are first class, second class, and third class.

####Stepwise Selection with Interactions

`PROC LOGISTIC` will program the interactions for you and keep model hierarchy.

Continuous and Categorical to predict categorical.

The `SLENTRY` and `SLSTAY` values for forward, backward, and stepwise methods all default to 0.5 with PROC LOGISTIC.

Look at model hierarchy on page 5-82.

If the interactions are significant, you have to keep them. If they are not significant, you can drop them.

```
/*st105d07.sas*/  /*Part A*/
proc logistic data=sasuser.Titanic plots(only)=(effect oddsratio);
    class Gender(ref='male') Class(ref='3') / param=ref;
    model Survived(event='1')=Age|Gender|Class @2 / 
          selection=backward clodds=pl slstay=0.01;
    units age=10;
    title1 'LOGISTIC MODEL (3): Backward Elimination '
           'Survived=Age|Gender|Class';
run;
```

On the `MODEL` statement, we're saying that we want to include Age, Gender, and Class with all of their interactions. Use the `|` character to set. By default, SAS will give you every combination of every size. the `@2` tells SAS to not calculate interactions of more than 2 variables.

```
model Survived(event='1')=Age|Gender|Class @2 / selection=backward clodds=pl slstay=0.01;
```

This gives Age, Gender, and Class by themselves. Also gives Age*Gender, Age*Class, and Gender*Class.

`SLSTAY = 0.01` sets the significance limit for keeping a variable in the model.

The model removes Age*Gender and Age*Class.

```
                                Summary of Backward Elimination

                      Effect                       Number          Wald
              Step    Removed              DF          In    Chi-Square    Pr > ChiSq

                 1    Age*Gender            1           5        4.3264        0.0375
                 2    Age*Class             2           4        8.8477        0.0120


                                   Type 3 Analysis of Effects

                                                      Wald
                        Effect            DF    Chi-Square    Pr > ChiSq

                        Age                1       32.5663        <.0001
                        Gender             1       40.0553        <.0001
                        Class              2       44.4898        <.0001
                        Gender*Class       2       43.9289        <.0001


                           Analysis of Maximum Likelihood Estimates

                                                   Standard          Wald
        Parameter                DF    Estimate       Error    Chi-Square    Pr > ChiSq

        Intercept                 1     -0.6552      0.2113        9.6165        0.0019
        Age                       1     -0.0385     0.00674       32.5663        <.0001
        Gender       female       1      1.3970      0.2207       40.0553        <.0001
        Class        1            1      1.5770      0.2525       38.9980        <.0001
        Class        2            1     -0.0242      0.2720        0.0079        0.9292
        Gender*Class female 1     1      2.4894      0.5403       21.2279        <.0001
        Gender*Class female 2     1      2.5599      0.4562       31.4930        <.0001


                  Association of Predicted Probabilities and Observed Responses

                       Percent Concordant      85.0    Somers' D    0.703
                       Percent Discordant      14.7    Gamma        0.706
                       Percent Tied             0.4    Tau-a        0.340
                       Pairs                 264313    c            0.852

```

Age is significant. Gender is significant. Class 2 is not different from Class 3; there was an interaction between Gender*Class. Almost all Class 2 females got off of the boat but almost none of the Class 2 males got off of the boat.

```
                Odds Ratio Estimates and Profile-Likelihood Confidence Intervals

                   Effect         Unit     Estimate     95% Confidence Limits

                   Age         10.0000        0.681        0.595        0.775
```

If you have an interaction, you can't really have an odds ratio.

The chart shows no difference between class 2 and class 3 males and their chance of getting off of the boat unless you are under the age of 20. Now, Class 1 Males were more likely to get off of the boat than Class 3 females.

The Analysis of Maximum Likelihood Estimates...

Within females, Class 1 vs. Class 3: there is a difference.
Within females, Class 2 vs. Class 3: there is a difference.

We don't see the comparisons for males because they are the reference level.

If you have a 3-way interaction that is significant, you have to keep all of the 2-way interactions under it that are significant.

Review is on the 24th.

The best way to study is to go through all of the exercises and make sure that you know which PROC goes with which exercise. Make a cheat sheet with all of the procs and all of their options.

**REVIEW TIPS**

- Book 1: Stat 1: Ch 1,2,3,5 (skipped ch. 4 - same as ch. 2 in book 2)
- Book 2: Stat 2: Ch 1,2