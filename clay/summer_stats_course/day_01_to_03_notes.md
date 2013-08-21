###Stat Review Day 1



We will look at continuous, nominal, and ordinal variables.

**Review: Continuous versus Categorical Variables**

**Nominal**

There is no order to a nominal variables. An example is type of beverage.

**Ordinal**

There is a structured order to what is going on. An example is SIZE of beverage -- small, medium, large. 

An ordinal variable can only be written two directions:

- small, medium, large
- large, medium, small

There are **Binary** variables, such as sex. 

- Male, Female
- Female, Male

- Yes, No
- No, Yes

Look at the chart on 1-8.


Population: The entire collection of individual members of a group of interest.

Sample - A subset of a population drawn to enable inferences to the population

**LEARN**

*ALL that we care about with a sample is that it is representative of the population. Randomness is really nice, but it is not a requirement.*

**Assumption for this course**

The sample that is drawn is *representative* of the population.

**Parameters** describe **population**. 

**Statistics** describe **samples**.

Look at the chart on 1-10.

####Describing Your Data

When you describe data, your goals are as follows:

- characterize the central tendency
- inspect the spread and shape of continuous variables
- screen for unusual data values


ID Number is categorical. A good way to test if something is categorical is to ask: can you take an average of two of the numbers and have it be meaningful?

When you look at a distribution, you can find out:

- the range of possible values
- the frequency of values
- whether the values accumulate in the middle of the distribution or at one end.

We will measure **central tendency** when we measure frequency.

Mean, median, and mode are the central tendency measures that we will use.

Most of the time, the mean and the median are what we care about.

**Percentiles and Quartiles**

The median is the second quartile. 

The IQR (Interquartile Range) is Q3 - Q1 = the middle 50% of the data.

We don't have to just look at central tendency -- sometimes we want to look at the tails: in risk analysis. We can look at any percentile that we would like, in order to understand the location of an individual in the data.

- **Range**: the difference between the maximum and minimum data values
- **Interquartile Range** the difference between the 25th and 75th percentiles.
- **Variance**: a measure of dispersion of the data around the mean. Average of squared distances from the mean. If you're looking at dollars, you have variance of squared dollars, which is difficult to understand.
- **Standard Deviation**: a measure of dispersion expressed in the same units of measurement as your data (the square root of the variance). Standard Deviation is here to put the variance back into units that are useful. In the previous example, we would go from squared dollars to dollars.

**The `MEANS` Procedure in SAS**

```
PROC MEANS DATA=SAS-data-set <options>;
    CLASS variables;
    VAR   variables;
RUN;
```

The `CLASS` statement specifies the variables whose values define the subgroup combinations for the analysis. Class variables are numeric or character. Class variables can have continuous values, but they typically have a few discrete values that define levels of the variable. **You do not have to sort the data by CLASS variables.**

**Example in SAS**

```
/*st101d01.sas*/  /*Part A*/
proc print data=sasuser.testscores (obs=10);
    title 'Listing of the SAT Data Set';
run;

/*st101d01.sas*/  /*Part B*/
proc means data=sasuser.testscores;
    var SATScore;
    title 'Descriptive Statistics Using PROC MEANS';
run;

/*st101d01.sas*/  /*Part C*/
proc means data=sasuser.testscores 
           maxdec=2 
           n mean median std q1 q3 qrange;
    var SATScore;
    title 'Selected Descriptive Statistics for SAT Scores';
run;
```

NOTE: You can purposefully made an error with a SAS option to see the proper options in the log.

`qrange` is the interquartile range.

**Exercise on page 1-20**

```
/* User Exercise */

/* What is the overall mean and standard deviation? */
/*
    Mean: 98.25
   STD :  0.73
*/

/* What is the interquartile Range of body temperature? */
/*
    QRANGE: 0.90
*/

/* Do the mean values seem to differ between men and women? */
/*
    Female: 98.4
    Male  : 98.1
*/

PROC MEANS DATA = sasuser.NormTemp MAXDEC = 2 n mean median std qrange PRINTALLTYPES;
    CLASS Gender;
    VAR   BodyTemp;
RUN;
```

The `PRINTALLTYPES` option will show you the overall and then by class.

####Picturing Distributions

**Histograms**

- Each bar in the histogram represents a group of values (a *bin*)
- The height of the bar represents the frequency or percent of values in the bin.
- SAS determines the width and number of bins automatically, or you can specify them.

**Normal Distribution Review**

**The EMPIRICAL Rule**

- 68%   of the data fall within 1 standard deviation of the mean
- 95%   of the data fall within 2 standard deviations of the mean.
- 99.7% of the data fall within 3 standard deviations of the mean.

Often, values that are more than 2 standard deviations from the ean are regarded as unusual.

**Characteristics of the Normal Distribution**

All you need is mean and standard deviation and you know exactly what the normal distribution is.

- It is symmetric. If you draw a line down the center, you get the same shape on either side.
- If **fully characteried* by the mean and the standard deviation
- Is bell shaped
- has mean = median = mode


Skewness: If the left tail is longer than the right tail, it is **left skewed**.

- **High Kurtosis**: You have thicker tails than the normal distribution.
- **Low Kurtosis**: You have thinner tails than the normal distribution.


Most of the time, SAS and other software display excess kurtosis and they call it kurtosis. 

```
Excess Kurtosis = Kurtosis - 3
```

Excess Kurtosis is centered at 0. Plain kurtosis is centered at 3.

If you have negative skewness, you have a left-skewed distribution. A positive skewness is right-skewed.

If your distribution is more spread out on the:

- **left** side, then the statistic is negative, and the mean is less than the median. This is left-skewed.
- **right** side, then the statistic is positive, and the mean is greater than the median. This is right-skewed.

Kurtosis:

- Leptokurtic: a positive kurtosis value. Thin tails.
- Platykurtic: a negative kurtosis value. Thick tails.

We will look at QQ plots to understand kurtosis. AKA *Normal Probability Plots*.

A *normal probability plot* is a visual method for determining whether your data come from a distribution that is approximately normal. The vertical axis represents the actual data values, and the horizonal axis displays the expected percentiles from a standard normal distribution.

- Curve above the diagonal is left-skewed.
- Curve below the diagonal is right-skewed.
- S shape - below the curve at the bottom left and above at the top-right - is a representation of low kurtosis. Reverse S shape is a representative of high kurtosis.

You also can look at a *box plot*. The problem is that it tells you nothing about the shape of the curve.

See how to read the box plot on page 1-29 in the book. The lines above and below the box in the plot either will go to the smallest and largest values **OR** it will stop at the smallest/biggest values that are not outliers. Anything more or less than 1.5 times the Interquartile Range is considered an outlier. Remember that these aren't influential.

**ODS Graphics Output**

We aren't going to discuss this in detail -- represents the options for creating graphics.

####Plotting Procedures

- `PROC SGSCATTER` creates single-cell and multi-cell scatter plots and scatter plot matrices with optional fits and ellipses.
- `PROC SGPLOT` creates single-cell plots with a variety of plot and chart types.
- `PROC SGPANEL` creates single-page or multi-page panels of plots and charts conditional on classification variables.
- `PROC SGRENDER` provides a way to create plots from graph templates that you modify or write.

**The `UNIVARIATE` Procedure**

General form:
```
PROC UNIVARIATE DATA= dataset <options>;
    VAR variables;
    ID  variable;
    HISTOGRAM variables </options>;
    PROBPLOT  variables </options>; /* creates QQ plots */
    INSET     keywords  </options>; /* will give output of specific quantities and put them on the plot */
RUN;
```

```
PROC SGPLOT <options>;
    DOT category-variable;
    HBAR category-variable;
    HBOX response-variable
    HISTOGRAM ...

RUN;
```


**Examples in SAS**

```
/*st101d02.sas*/  /*Part A*/

PROC UNIVARIATE DATA = sasuser.testscores;
    VAR       SATScore;

    /* Create a histogram */
    HISTOGRAM SATScore / NORMAL(MU=est SIGMA=est) KERNEL; /* est tell sas to estimate it */
    INSET     SKEWNESS KURTOSIS / POSITION = ne;          /* ne means Northeast corner */

    /* Create a QQ plot */
    PROBPLOT  SATScore / NORMAL(MU=est SIGMA=est); /* NORMAL tells SAS to compare our data to a normal dist */
    INSET     SKEWNESS KURTOSIS;

    TITLE    'Descriptive Statistics Using PROC UNIVARIATE';
run;
```

The `NORMAL` option tells SAS to put a normal curve over the data.

The `KERNEL` option tell SAS to try to put its own distribution curve over the histogram. It's easy to eyeball whether it lines up with the normal curve and will help you understand whether the data is normal.

A "Moment" describes distributions.

Quantiles take a long time to calculate and can make PROC UNIVARIATE slow.

For the test for Fitted Normal Distribution, pay attention to:

- Kolmogorov-Smirnov ("KS" test) - made to compare any two distributions.
- Anderson-Darling - made to test normality. Typically, this is the best one to look at.

You don't need to pay attention to the Cramer-von Mises test.

The null hypothesis for a test of normality is that it is normal. We want normality -- want to fail to reject the hypothesis.

```
PROC SGPLOT DATA=sasuser.testscores;
    /* Vertical Box Plot
    VBOX    SATScore / DATALABEL = IDNumber; /* DATALABEL will label the outliers on the box plot */
    FORMAT  IDNumber 8.;
    REFLINE 1200 / axis=y label; /*Draw a reference line at the point 1200 */
    TITLE   "Box-and-Whisker Plots of SAT Scores";
RUN;

/* Same, but with a gender ID label */
PROC SGPLOT DATA=sasuser.testscores;
    /* Vertical Box Plot
    VBOX    SATScore / DATALABEL = Gender; /* DATALABEL will label the outliers on the box plot */
    FORMAT  IDNumber 8.;
    REFLINE 1200 / axis=y label; /*Draw a reference line at the point 1200 */
    TITLE   "Box-and-Whisker Plots of SAT Scores";
RUN;
```

With these, you don't know where the IQR lines are. The whiskers merely indicate the lowest/highest values or the ones closest to the IQR, but within range.

**Exercise: Producting Descriptive Statistics p. 1-41**

```
PROC UNIVARIATE DATA = sasuser.NormTemp;
    VAR     BodyTemp;
    TITLE   'Desc Stats for BodyTemp';
RUN;

PROC SGPLOT DATA = sasuser.NormTemp;
    VBOX    BodyTemp / DATALABEL = BodyTemp;
    FORMAT  BodyTemp 5.2;
    REFLINE 98.6 / AXIS = y LABEL;
    TITLE   'Body Temp Box Plot';
RUN;
```

####Confidence Intervals for the Mean


A *point estimate* is a sample statistic that is used to estimate a population parameter. If you don't have the actual population mean, you need to know the variability of the estimate.

**Variability of the Sample**

NOT EVERY SAMPLE IS THE SAME. Every sample will look different and every sample mean could look different.

We are going to look at the distribution of means across a lot of different samples. p 1-44

What is a distribution of sample means? It is a distribution of many mean values, each of a common sample size.

1. Take a sample from the population (sample sizes all should be the same)
2. Calculate its mean
3. Return to step 1 and repeat

The distribution of the sample means is normal.

It does not matter what the population looks like, with regards to skewness, etc... but the distribution of the sample means always is normal.

**Standard Error of the Mean**

*A statistic that measure the variability of your estimate is the standard error of the mean.*

It differs from the sample standard deviation because:

- the sample standard deviation is a measure of the variability of the data.
- the standard error of the mean is a measure of the variability of the sample means.

Means always will be thinner in spread than the population.

**Confidence Intervals**

A 95% confidence interval represents a range of values within which you are 95% certain that the true population mean exists. One interpretation is that if 100 different samples were drawn from the same population and 100 intervals were calulated, approximately 95 of them would contain the population mean. The true value does not change. 95% of the time, what you calculate will include the true mean. It is 95% confidence in the procedure that you use to find the range.

**Normality and the Central Limit Theorem**

You need an observation of 50 observations for this to apply.

*The central limit theorem states that the distribution of sample means is approximately normal, regardless of the population distribution's shape, if the sample sie is large enough.*


**Exercise 3**

```
PROC UNIVARIATE DATA = sasuser.NormTemp;
    VAR     BodyTemp;

    HISTOGRAM BodyTemp / NORMAL(MU = est SIGMA = est) KERNEL;
    INSET       SKEWNESS KURTOSIS / POSITION = ne;
    TITLE       'Desc Stats for Body Temp';

    PROBPLOT    BodyTemp / NORMAL(MU = est SIGMA = est);
    INSET       SKEWNESS KURTOSIS;
RUN;

PROC SGPLOT DATA = sasuser.NormTemp;
    VBOX    BodyTemp / DATALABEL = BodyTemp;
    FORMAT  BodyTemp 5.2;
    REFLINE 98.6 / AXIS = y LABEL;
    TITLE   'Body Temp Box Plot';
RUN;

PROC MEANS data = sasuser.NormTemp maxdec=3 n mean std stderr clm;
    VAR BodyTemp;
    title '95% Confidence Interfal for BodyTemp';
RUN;
```

####Hypothesis Testing

Perform hypothesis testing using the `UNIVARIATE` and `TTEST` procedures.

Assume the null, try to prove the alternative, etc...

Review types of errors:

- Fail to reject Null & Null is True  -> Correct
- Fail to reject Null & Null is False -> Type II Error
- Reject Null         & Null is True  -> Type I Error
- Reject Null         & Null is False -> Correct

Make sure you understand the real world consequences of having either Type I or Type II Errors.

p-value: the probability you got the results that you did assuming that the null hypothesis is true.

Example: Flip a coin 100 times and get 40 heads. p-value: 0.0569. There is a 5.7% chance that I would get the results that I did GIVEN THAT the coin is a fair coin.

Sample size influences the p-value. When the number of observations is low, it is more difficult to reject the null hypothesis.

The value of alpha -- the probability of a Type I error -- is specified by the experimenter before collecting data.

p-value >= alpha then fail to reject the null hypothesis
p-value <  alpha then reject the null hypothesis

Wehn you compare means, then use the Student's t-test.

(what did you have - what did you think) / (how far away is that?) = t-value

To compare a hypothesis test and a confidence interval:

- If you have a two-sided hypothesis test
- You have to be comparing the same percentages -- if you have a 95% confidence interval, then you have to be using an alpha from your hypothesis test with alpha = 0.05.

**Using `PROC TTEST` in SAS**

General form:
```
PROC TTEST DATA = SAS-data-set;
    CLASS  variable;
    PAIRED variables;
    VAR    variables;
RUN;
```

If you wanted to see if there was a difference in SAT scores between male and females, the CLASS would be Gender and the VAR would be SATScore.

```
PROC UNIVARIATE data=sasuser.testscores MU0=1200;
    VAR SATScore;
    TITLE 'Testing Whether the Mean of SAT Scores = 1200';
run;
```

The `mu0` option is your null hypothesis value. Look for "Tests for Location" on the `PROC UNIVARIATE` output.

In this output, fail to reject.

```
/* Will plot the test and show the null hypothesis value with the shownull value */

PROC TTEST DATA=sasuser.testscores H0 = 1200
           plots(shownull)=interval;
    VAR   SATScore;
    TITLE 'Testing Whether the Mean of SAT Scores = 1200 '
          'Using PROC TTEST';
RUN;
```

If your confidence interval contains your null hypothesis, that's the same thing as running a null hypothesis and NOT rejecting.

**Exercise 4 from page 1-72**

```
PROC UNIVARIATE DATA = sasuser.NormTemp MU0 = 98.6;
    VAR BodyTemp;
    TITLE 'Testing Whether the Mean of BodyTemp = 98.6 using PROC UNIVARIATE';
RUN;

PROC TTEST DATA = sasuser.NormTemp H0 = 98.6 plots(shownull) = interval;
    VAR BodyTemp;
    TITLE 'Testing Whether the Mean of BodyTemp = 98.6 Using PROC TTEST';
RUN;
```

###Exploratory Data Analysis

- Use a scatter plot to examine the relationship between two continuous variables
- Use correlation statistics to quantify the degree of association between two continuous variables
- Describe potential misuses of the correlation coefficient
- Use the `CORR` procedure to obtain Pearson correlation coefficients.

The OLS (Ordinary Least Squares Regression) model is what we will use to explore Continuous predictors with Continuous Response variables. For example, height and weight are both continuous. 

It is very important to do scatter plots of the data - to visually explore it. This will help you determine if the relationship is linear. Look for the following:

- A straight line -- linear relationship
- Curvature -- quadratic relationship
- Cyclical patterns -- these can lead you to believe that you have a linear relationship when you actually don't or it is more complex that a simple linear relationship
- Random scatter - no relationship.

**Review of Correlation**

Two variables are correlated if there is a **linear** relationship between them. If not, the variables are uncorrelated. You can classify correlated variables according to the type of correlation:

- Positive: One variable tends to increase in value as the other variable increases in value
- Negative: One variable tends to decrease in value as the other variable increases in value
- Zero: No linear relationship exists between teh two variables (uncorrelated).

Correlation is a **standardized** measure. It takes values between -1 and 1.

**Hypothesis Test for a Correlation**

- The parameter representing correlation is ρ.
- *p* is estimated by the sample statistic *r*.
- Null hypothesis: ρ = 0.
- Rejecting the null indicates only great confidence that ρ is not exactly zero.
- A p-value does nto measure the magnitude of the association. 
- Sample size affects the p-value.

You may be able to say that you have enough association to show that there is a linear relationship between two variables, but the strength of the relationship might be week (r).

**Correlation Does Not Imply Causation**

A strong correlation between two variables does not mean change in one variable causes the other variable to change, or vice versa. Sample correlation coefficients can be large because of chance or because both variables are affected by other variables.

In-Class example of SAT scores vs. state spending on education. The problem is that there are states where not as many students take the SAT. If you adjust the spending and adjust the total score, then you see a positive relationship.

**Extreme Data Values**

Correlation coefficients are highly affected by a few extreme values on either variable's range. The scatter plots show that the degree of linear relationship is mainly determined by one point. If you include the unusual point in the data set, the correlation is close to 1. If you do not include it, the correlation is close to 0. In these situations:

- Investigate the unusual data point to make sure it is valid.
- If the data point is valid, collect more data between the unusual data point ad the group of data points to see whether a linear relationship exists.
- Try to replicate the unusual data point by collecting data at a fixed value of x. This determines whether the data point is unusual.
- Compute two correlation coefficients, one with the unusual data point and one without it. This shows how influential the unusual data point is in the analysis.

**The `CORR` Procedure**

```
PROC CORR DATA = dataset <options>;
    VAR  variables;
    WITH variables;
    ID   variables;
RUN;
```

- `VAR` specifies varialbe for which to produce correlations. If a `WITH` statement is not specified, correlations are produced for each pair of varialbe in the `VAR` statement. If the `WITH` statement is specified, the `VAR` statement specifies the column variables in the correlation matrix.
- `WITH` produces correlations for each variable in the `VAR` statement with all variables in the `WITH` statement. The `WITH` statement specifies the row variables in the correlation matrix.
- `ID` specifies one or more additional tip variables to identify observations in scatter plots and scatter plot matrices. This helps to identify outliers on plots.

The `PROC CORR` Plots Options...

```
PLOTS
- ALL
- MATRIX
- SCATTER
- HIST
- HISTOGRAM
- NVAR = ALL
- ELLIPSE = PREDICTION | CONFIDENCE | NONE
```

Code for the Fitness example in class:

```
proc corr data=sasuser.fitness rank
          plots(only)=scatter(nvar=all ellipse=none);
    var RunTime Age Weight Run_Pulse
        Rest_Pulse Maximum_Pulse Performance;
    with Oxygen_Consumption;
    id name;
    title "Correlations and Scatter Plots with Oxygen_Consumption";
run;
```

**Exercise 1 on page 3-27**

```
/* Exercise 1 on page 3-27 */

ods graphics / reset=all imagemap;
PROC CORR DATA = sasuser.BodyFat2 RANK 
                 PLOTS(only)=SCATTER(NVAR=ALL ELLIPSE=NONE);
    VAR Age
        Weight
        Height;

    WITH PctBodyFat2;
    
    TITLE "Correlations for Age Weight and Height with Perc Body Fat";
RUN;

ods graphics / reset=all imagemap;
PROC CORR DATA = sasuser.BodyFat2 RANK 
                 PLOTS(only)=SCATTER(NVAR=ALL ELLIPSE=NONE);
    VAR Neck
        Chest
        Abdomen
        Hip
        Thigh
        Knee
        Ankle
        Biceps
        Forearm
        Wrist;

    WITH PctBodyFat2;
    
    TITLE "Correlations for Circumferences with Perc Body Fat";
RUN;

ods graphics / reset=all;
PROC CORR DATA = sasuser.BodyFat2 NOSIMPLE
                 PLOTS(MAXPOINTS = 100000)=MATRIX(NVAR=ALL HISTOGRAM);
    VAR Age
        Weight
        Height
        Neck
        Chest
        Abdomen
        Hip
        Thigh
        Knee
        Ankle
        Biceps
        Forearm
        Wrist;

    TITLE "Correlation matrix of Body Fat Predictors";
RUN;
```


####Simple Linear Regression

Even if two variables have the same correlation coefficient, they might have different regression coefficients. Correlation helps direct us to which variables have the strongest relationship, but we have to use other tools to understand the linear relationship.


- The *response variable*  - usually *y* - is the variable of primary interest.
- The *predictor variable* - usually *x* - is used to explain the variability in the response variability.

The key objectives of simple linear regression analysis:

- assess the significance of the predictor variable in explaining the variability or behavior of the response variable.
- predict the values of the response variable given the values of the predictor variable.

In simple linear regression, the values of the predictor variable are assumed to be fixed. Thus, you try to explain the variability of the response variable given the value of the predictor variable.

β1, as a coefficient, represents the change in *y* due to a change in *x* -- the slope.

**The way that we come up with the regression line is to minimize the sum of the squared errors.**

You use the sum of the squared errors instead of the sum of the absolute value of the errors because it adds a greater penalty to observations with large error.

**The Baseline Model**

If we didn't have x, then we have to assume that y-bar (the mean) is the best predictor for y. When we create a regression line, we want to know how much better it is than the baseline.

**Explained versus Unexplained Variability**

To determine whether a simple linear regression model is better than the baseline model, compare the explained variability to the unexplained variability:

- **Explained Variability** is related to the difference between the regression line and the mean of the response variability. The model sum of squares (SSR or SSM) is the amount of variability explained by your model.
- **Unexplained variability** is related to the difference between the observed values and the regression line. The error sum of squares (SSE) is the amount f variability unexplained by your model.
- **Total variability** is related to the difference between the observed values and the mean of the response variable. The corrected total sum of squares is the sum of the explained and unexplained variability.

```
TSS = SSR + SSE
```

Remeber that the relationship of the following `total = unexplained + explained` applies for sums of squares over all observations and not necessarily for any individual observation.

```
r-squared = Coefficient of Determination = SSR/TSS
```

Measure the percent of variability of y that was explained by the model. The higher it is, the better off we are.

**Model Hypothesis Test**

The null hypothesis is that the simple linear regression model does **not** fit the data better than the baseline model. (β0 = 0)

The alternative hypothesis is that the simple linear regression model does fit the data better than the baseline model. (β0 ≠ 0)

**Assumptions of Simple Linear Regression**

1. The mean of the response variable is linearly related to the value of the predictor variable.
2. Equal variance of errors. (As the value of x changes, the values of the error don't change.)
3. Errors are independent.
4. Normality of errors.

**The `PROC REG` Procedure**

```
PROC REG DATA = dataset;
    MODEL dependent(s) = regressor(s) </options>;
RUN;
QUIT;
```

The confidence limit provides the 95% confidence for the question: for this value of x, what is the value of y? 

versus 

The 95% confidence interval for the prediction -- If x = 20, what value do you get for y? The CI for the prediction is larger than the CI for the mean.

**The `SCORE` Procedure**

The `SCORE` procedure multiplies values from two SAS data sets, one containing coefficients (for example, factor-scoring coefficients or regression coefficients) and the other containing raw data to be scored using the coefficients from the first data set. The result of this multiplication is a SAS data set that contains linear combinations of the coefficients and the raw data values.


These are the values that I want predictions for:
```
data Need_Predictions;
    input RunTime @@;
    datalines;
9 10 11 12 13 150
;
run;

PROC PRINT DATA = Need_Predictions;
RUN;
```

This generates the model and stores it in the `outest` data set called `Betas`.

```
proc reg data=sasuser.fitness noprint 
         outest=Betas;
    PredOxy: model Oxygen_Consumption=RunTime;
run;
quit;

proc print data=Betas;
    title "OUTEST= Data Set from PROC REG";
run;
```

This tells SAS to apply the model in `Betas` to the data we want to predict and to store the forecasts in the data set called `Scored`:
```
proc score data=Need_Predictions score=Betas
           out=Scored type=parms;
    var RunTime;
run;

proc print data=Scored;
    title "Scored New Observations";
run;
```

Note with the prediction that it takes 150 minutes to complete the run that it shows that you will GENERATE oxygen during the run, which is crazy. This is the problem with trying to extrapolate to values out of a range you've previously seen. We should not extrapolate/predict to values that are outside of what the model was built to handle.

###Concepts of Multiple Regression

Multiple linear regression with two variables. In simple linear regression, we are trying to develop a line that goes through the points. When we have two independent variables, we are trying to develop a plane that passes through the data.

**Model Hypothesis Test**

We use the F test to determine if ANY variables are useful.

- The null hypothesis is that the model does NOT fit the data better than the baseline model.

```
B1 = B2 = B3 = ... = Bk = 0
```

- The alternative hypothesis is that the regression model does fit the data better than the baseline model.

```
Not all beta values are equal to zero.
```

**Assumptions for Linear Regression**

1. The mean of the Ys is accurately modeled by a linear function of the Xs.
2. The random error term is assumed to have a normal distribution with a mean of zero.
3. The random error term is assumed to have a constant variance (homoscedasticity)
4. The errors are independent.
5. No **perfect** collinearity

Multiple linear regression is a powerful tool for the following tasks:

- Prediction: to develop a model to predict future values of a response variable based on its relationships with other predictor variables.
- Explanation: to develop an understanding of the relationships between the response variable and predictor variables

Depending on which of the goals you have, there are different analytical techniques. Do you care about predictions or relationships??

**Learn Adjusted R Squared**

The R square always increases or stays the same as you include more terms in the model. Therefore, choosing the "best" model is not as simple as just making the R square as large as possible.

The adjusted R square is a measure similar to R square, but it takes into account the number of terms in the model. It can be thought of as a penalized version of R square with the penalty increasing with each parameter added to the model.

```
Adjusted R squared = 1-((n-i)(1-R^2)/(n-p))

i = 1 if there is an intercept and 0 otherwise
n = the number of observations used to fit the model
p = the number of parameters in the model
```

SAS will ignore an observation that has a missing value in it. You should always check for this at the top of your `PROC REG` output. It might help you to understand where you have missing data.


Output from PROC REG

```
                                       The REG Procedure
                                         Model: MODEL1
                            Dependent Variable: Oxygen_Consumption

                            Number of Observations Read          31
                            Number of Observations Used          31


                                      Analysis of Variance

                                             Sum of           Mean
         Source                   DF        Squares         Square    F Value    Pr > F

         Model                     2      646.33101      323.16550      44.09    <.0001
         Error                    28      205.22355        7.32941
         Corrected Total          30      851.55455


                      Root MSE              2.70729    R-Square     0.7590
                      Dependent Mean       47.37581    Adj R-Sq     0.7418
                      Coeff Var             5.71450


                                      Parameter Estimates

                                       Parameter       Standard
         Variable              DF       Estimate          Error    t Value    Pr > |t|

         Intercept              1       71.52626        8.93520       8.00      <.0001
         Performance            1        0.06360        0.04718       1.35      0.1885
         RunTime                1       -2.62163        0.62320      -4.21      0.0002

```

In the above example, the bottom table, Performance has a p-value of 0.1885, which means that you would fail to reject the null. This implies that Performance is useless as a predictor.

####The Process of Selecting the Best Model - Model Building and Interpretation

The `SELECTION=` option in the `MODEL` statement of `PROC REG` supports these seelction techniques:

- **Stepwise selection methods** `STEPWISE, FORWARD, or BACKWARD`.
- **All possible regressions ranked using** `RSQUARE, ADJRSQ or CP`. This is ideally used for a small number of variables.

`SELECTION=NONE` is the default.

**Mallows' Cp**

Mallow's Cp is a simple indicator of effective variable selection within a model. Look for models with Cp <= p, where p equals the number of parameters in the model, **including the intercept**. Mallows recommends choosing the first (fewest variables) model where Cp approaches p. Five variables in your model -> 6 variables that you're estimating (because of the intercept).

**Hocking's Criterion versus Mallows' Cp**

Hocking suggests selecting a model based on the following:

- Cp <= p for prediction
- Cp <= 2p - pfull + 1 for parameter estimation (significance). pfull is the number of possible variables that you could add and p is the number of variables that you add to the model.

Here we tell SAS that we only want to see certain plots. `ALL_REG` is the name of the model that we are about to run. You always can name the model - just follow it with a colon. With the `/ selection=`, SAS will rank by the first listed(`rsquare`) but will also tell us the others

```
ods graphics / imagemap=on;

proc reg data=sasuser.fitness plots(only)=(rsquare adjrsq cp);
    ALL_REG: model oxygen_consumption 
                    = Performance RunTime Age Weight
                      Run_Pulse Rest_Pulse Maximum_Pulse
            / selection=rsquare adjrsq cp;
    title 'Best Models Using All-Regression Option';
run;
quit;
```

Now it will rank things by Cp and only show the Cp plot. Here, SAS will only give the 20 best models.
```
ods graphics / imagemap=on;

proc reg data=sasuser.fitness plots(only)=(cp);
    ALL_REG: model oxygen_consumption 
                    = Performance RunTime Age Weight
                      Run_Pulse Rest_Pulse Maximum_Pulse
            / selection=cp rsquare adjrsq best=20;
    title 'Best Models Using All-Regression Option';
run;
quit;
```
SAS won't always highlight the best Cp value -- it will highlight the lower one.


If you have to choose between models, then look at the variables to see if they are easier to use or if they make more sense. In these examples, Age makes more sense than Performance.

**Stepwise Selection Techniques**

When somebody says they are using stepwise selection techniques, it does not mean that they are actually using "stepwise selection".

- **Forward Selection**: Starts with nothing and adds one variable at a time -- the best variable based on p-value. (SAS default is 0.5). Once a variable is added to a model, it never will leave the model, in spite of what happens to its p-value. Use the `SLENTRY=` option to determine the significance level at which a model can enter the model.
- **Backward Elimination**: Every variable is in the model and the worst gets thrown out one at a time. (SAS default is 0.1). Use the `SLSTAY=` option sets the p-value for elimination.
- **Stepwise Selection**: A combination of the two at the top. Variables can leave after being added to the model. 1. Let's in the lowest p-value. 2. Looks at variables in model to determine whether they still can be in the model based on p-values. In stepwise selection, once a variable is booted from the model, it is not allowed to reenter the model.

Best to explore multicollinarity prior to trying to build a model.

Automated model selection results in the following:

- Biases in parameter estimates, predictions, and standard errors
- Incorrect calculation of degrees of freedom
- p-values that tend to err on the side of overestimating significance (increasing Type I Error probability).

**Handling Data**

Take your original data and split it into two group:

- Training: used to train the model(80% - 90%)
- Validation: Need enough data in validation to trust that the model is useful. (10% - 20%)

####USE THESE P-VALUES!!

**Conservative Significance Levels**

This is the table of p-values that we should use:



|Evidence   |30   |50    |100   |1000   |10,000 |100,000 
| --------- | --- | ---- | ---- | ----- | ----- | ------ 
|Weak       |0.076|0.053 |0.032 |0.009  |0.002  |0.007   
|Positive   |0.028|0.019 |0.010 |0.003  |0.0008 |0.002   
|Strong     |0.005|0.003 |0.001 |0.0003 |0.0001 |0.00003 
|Very Strong|0.001|0.0005|0.0001|0.00004|0.00001|0.000004




**Using `PROC REG` with Forward, Backward, and Stepwise**

```
proc reg data=sasuser.fitness plots(only)=adjrsq;
   FORWARD:  model oxygen_consumption 
                    = Performance RunTime Age Weight
                      Run_Pulse Rest_Pulse Maximum_Pulse
            / selection=forward;
   BACKWARD: model oxygen_consumption 
                    = Performance RunTime Age Weight
                      Run_Pulse Rest_Pulse Maximum_Pulse
            / selection=backward;
   STEPWISE: model oxygen_consumption 
                    = Performance RunTime Age Weight
                      Run_Pulse Rest_Pulse Maximum_Pulse
            / selection=stepwise;
   title 'Best Models Using Stepwise Selection';
run;
quit;
```

Stepwise regression uses fewer computer resources, but all-possible regression generates more candidate models that might have nearly equal R-squared statistics and Cp statistics.

**Exercises 6 from page 3-95**

```
/* Exercise 6 on page 3-95 */

/* Part a */
PROC REG DATA = sasuser.BodyFat2 PLOTS(only)=(cp RSQUARE ADJRSQ);
    ALL_REG: MODEL PctBodyFat2 = Age Weight Height Neck Chest Abdomen 
                                 Hip Thigh Knee Ankle Biceps Forearm Wrist
                   / SELECTION = CP RSQUARE ADJRSQ BEST = 60;
             TITLE 'All Regression for BodyFat2';
RUN;

/* Part b */
PROC REG DATA = sasuser.BodyFat2 PLOTS(ONLY)=ADJRSQ;
    FORWARD: MODEL PctBodyFat2 = Age Weight Height Neck Chest Abdomen 
                                 Hip Thigh Knee Ankle Biceps Forearm Wrist
                   / SELECTION = FORWARD;

    STEPWISE: MODEL PctBodyFat2 = Age Weight Height Neck Chest Abdomen 
                                 Hip Thigh Knee Ankle Biceps Forearm Wrist
                   / SELECTION = STEPWISE;

    BACKWARD: MODEL PctBodyFat2 = Age Weight Height Neck Chest Abdomen 
                                 Hip Thigh Knee Ankle Biceps Forearm Wrist
                   / SELECTION = BACKWARD;

              TITLE 'Best Models Using Forward, Stepwise, and Backward';
RUN;

/* Part c */
PROC REG DATA = sasuser.BodyFat2 PLOTS(ONLY)=ADJRSQ;
    FORWARD: MODEL PctBodyFat2 = Age Weight Height Neck Chest Abdomen 
                                 Hip Thigh Knee Ankle Biceps Forearm Wrist
                   / SELECTION = FORWARD SLENTRY = 0.05;

              TITLE 'Best Models Using Forward and SLENTRY';
RUN;
```

###Tuesday: ANOVA and Regression

For a model with *k* variables, you always are estimating k+1 variables (including the intercept).

The global F test is to test whether ANY of the variables are useful. If you reject the null, then *something* is useful -- but not everything.

Review the assumptions for Multiple Linear Regression.

**Violation of Model Assumptions**

- Normality: does not affect the parameter estimates, but it affects the test results
- Constant Variance: does not affect the parameter estimates, but the standard errors are compromised.
- Independent obserations: does not affect the parameter estimates, but the standard errors are compromised.
- Linear in the parameters: indicates a misspecified mode, and therefore the results are not meaningful.

**Quiz Question: The language of the answer is important**

Q: Suppose the regression model that you fit is `y = 3 + 5x`. How do you interpret the slope for `x`, which is 5?

A: For every 1-unit increase in `x`, the predicted value for `y` increases by 5.

Review `PROC REG` and `PROC SGSCATTER`.

The `COMPARE` statement holds the y-axis the same across all plots. You have to be a little bit careful when you use it because it can cram all of the data into a small area on the graph if the y distribution across the graphs you're comparing is different.

```
PROC SGSCATTER DATA=sasuser.school;
 COMPARE y=reading3
         x=(words1 letters1 phonics1);
 TITLE 'Scatter Plots of READING3 by WORDS1 LETTERS1 and PHONICS1';
RUN;   
```

The following will show *only* the diagnostics plots. SAS tries to put all of the plots onto one picture, so you use the `unpack` option to split them up into individual pictures. The diagnostic plot, by default, is a 3x3 matrix of plots. `unpack` separates them into separate plot files.

The `OUTPUT` statement is taking some of the results from the procedure and saves them into a new data set.

The `OUT` statement in `OUTPUT` is the name of the file that you're going to save them to. 

The `R=` option is telling SAS that you want to save the residuals, and they are saved to the `OUT=` dataset.

The `P=` option tells sas to save the predicted values.

```
OPTIONS formdlim="_";
PROC REG DATA=sasuser.school 
    PLOTS (ONLY) = DIAGNOSTICS (UNPACK);
    MODEL reading3 = words1 letters1 phonics1;
    OUTPUT OUT = out R = residuals;
TITLE 'School Data: Regression and Diagnostics';
RUN;
QUIT;       
```


Here is the output:

```
                            School Data: Regression and Diagnostics                            1
                                                                    09:03 Tuesday, July 16, 2013

                                       The REG Procedure
                                         Model: MODEL1
                                 Dependent Variable: Reading3

                     Number of Observations Read                        190
                     Number of Observations Used                        154
                     Number of Observations with Missing Values          36


                                      Analysis of Variance

                                             Sum of           Mean
         Source                   DF        Squares         Square    F Value    Pr > F

         Model                     3         168543          56181     114.73    <.0001
         Error                   150          73453      489.68756
         Corrected Total         153         241996


                      Root MSE             22.12889    R-Square     0.6965
                      Dependent Mean       49.24026    Adj R-Sq     0.6904
                      Coeff Var            44.94063


                                      Parameter Estimates

                                   Parameter       Standard
              Variable     DF       Estimate          Error    t Value    Pr > |t|

              Intercept     1      -10.79366        4.60583      -2.34      0.0204
              Words1        1        0.93737        0.18036       5.20      <.0001
              Letters1      1        0.70787        0.18130       3.90      0.0001
              Phonics1      1        0.84782        0.16133       5.26      <.0001

```

The global F-test shows that one of the variables is useful. There are 36 observations with missing values and they are completely ignored. R-square: approximately 70% of the variation in the reading score is predicted by our model. We don't know if that is good because we need to compare it to something. As for the variables, everything seems to be extremely significant, which is good.

Examining the residuals in the output graphs, it looks like the model is accurate with the early data, but with the later data, it is less accurate -- constant variance problems.

Look at the QQ plot and the histograms to try to eyeball whether the data is normal.

Cook's D plot makes it look that we have some problems. Makes it seem that we have some outliers.

**Using `PROC UNIVARIATE` for Normality Tests**

The `NORMAL` option will check for normality

```
PROC UNIVARIATE DATA=out NORMAL;
  VAR residuals;
RUN;
```

Here are the PROC UNIVARIATE results for Tests for Normality:

```
                                      Tests for Normality

                   Test                  --Statistic---    -----p Value------

                   Shapiro-Wilk          W      0.96493    Pr < W      0.0006
                   Kolmogorov-Smirnov    D     0.077469    Pr > D      0.0230
                   Cramer-von Mises      W-Sq    0.2275    Pr > W-Sq  <0.0050
                   Anderson-Darling      A-Sq  1.298736    Pr > A-Sq  <0.0050

```

Look first at the Anderson-Darling test (and then at Kolmogorov-Smirnov). Remember that the null is normality and that we want to fail to reject the null.  Here, we reject, meaning that the residuals are not normal. Ignore Shapiro-Wilk and Cramer-von Mises.

If you think that some of the extreme observations are causing problems, then you can find them in the output here:

```
                                      Extreme Observations

                           ------Lowest-----        -----Highest-----

                              Value      Obs           Value      Obs

                           -68.2296       29         41.2938       54
                           -54.8771       20         47.6717      106
                           -49.5235       95         48.3138       63
                           -42.5962      173         66.6826      148
                           -40.2228      125         96.5381       35
```

**If you want to do a formal test for normality, you have to take them out of `PROC REG` and put them into `PROC UNIVARIATE`.**

####HINT: We will have to formally test residuals for the exam!!!

####Common Regression Problems

If there is a pattern to your residuals, then you can improve your model. We want the residuals to look like a random cloud; to not have any pattern to them. If you have a curve in the residuals, you probably need to have a quadratic model. This is a hint of a *model misspecification**.

A fan shaped plot of residuals is an example of heterscedasticity.

A wave-like pattern indicates collinearity

The residuals will tell you what is wrong with your model if you know how to interpret them.

Residual plots themselves do not give you a good sense of normality. 

###Simple Polynomial Regression

A Quadratic model will have an x^2 term. A cubic will have x^3 term. A polynomial model with a cross-product term will have an x1x2 term, for example. We typically will not go above an order of 2 with a polynomial model.

Polynomial regression models fall into the category of general linear models because they are linear in the parameters.

Depending on what your value of x is influences the relationship that x has with y. The relationship between x and y changes with values of x. Cross Product is the same as an interaction.

With cross-product, the relationship of x1 to y changes with different values of x2.

**Interaction**: The relationship between x1 and y depends on the value of x2. This does **NOT** mean that x1 and x2 are necessarily correlated, though they could be. Also not saying that as x1 changes that x2 changes... only that as x2 changes, the relationship that x1 has with y changes.


####Paper Example

We're measuring the strength of paper after the application of a chemical.

The first thing that you do is to graph the data and look at it.

```
ods html;
proc sgplot data=sasuser.paper;
 scatter x=amount y=strength;
 title2 "Scatter Plot";
run;
```

Now we are specifying some things with the line and getting it to fit a linear regression through it:

```
proc sgplot data=sasuser.paper;
    reg  x=amount y=strength / lineattrs =(color=brown       
         pattern=solid) legendlabel="Linear";
title2 "Linear Model";
run; 
```

The output is a graph that just show a line that doesn't fit well.

Now, we do the exact same thing, but the `degree=2` option tells SAS that we want to have x and x^2 in the model:

```
proc sgplot data=sasuser.paper;
    reg  x=amount y=strength / degree=2 lineattrs =(color=green       
         pattern=mediumdash) legendlabel="2nd Degree";
title2 "Second Degree Polynomial";
run;
```

This looks at a 3rd order polynomial:
```
proc sgplot data=sasuser.paper;
   reg  x=amount y=strength / degree=3 lineattrs =(color=red   
        pattern=shortdash) legendlabel="3rd Degree";
title2 "Third Degree Polynomial";
run;
```

This will look at a 4th order polynomial:
```
proc sgplot data=sasuser.paper;
    reg  x=amount y=strength / degree=4 lineattrs =(color=blue
      pattern=longdash) legendlabel="4th Degree";
title2 "Fourth Degree Polynomial";
run;    
```

The best thing to do is to go up one order at a time. When you think you are done, do one more just to make sure that you are done. In this example, it looks like we're between 2 and 3.

Now, let's try to build the model in a more manual fashion. We create the data set and then we model strength by all of our terms.

The `SCORR1` option prevents SAS from giving type-III p-values. `SCORR1(TESTS)` will give you type I sums of squares. This is very important. The default is your regular p-values.

```
title;
title2;

data paper;
   set sasuser.paper;
   amount2 = amount**2;
   amount3 = amount**3;
   amount4 = amount**4;
run;

proc reg data=paper ;
   model strength= amount amount2 amount3 amount4 / scorr1(tests);
title "Paper Data Set: 4th Degree Polynomial";
run;
quit; 
```

Here are the results:

```
                            Paper Data Set: 4th Degree Polynomial                             4
                                                                    09:03 Tuesday, July 16, 2013

                                       The REG Procedure
                                         Model: MODEL1
                                 Dependent Variable: Strength

                            Number of Observations Read          22
                            Number of Observations Used          22


                                      Analysis of Variance

                                             Sum of           Mean
         Source                   DF        Squares         Square    F Value    Pr > F

         Model                     4        0.53924        0.13481      12.28    <.0001
         Error                    17        0.18667        0.01098
         Corrected Total          21        0.72591


                      Root MSE              0.10479    R-Square     0.7429
                      Dependent Mean        2.81364    Adj R-Sq     0.6823
                      Coeff Var             3.72427


                                      Parameter Estimates

                                                                         Squared
                     Parameter      Standard                        Semi-partial    Cumulative
  Variable    DF      Estimate         Error   t Value   Pr > |t|    Corr Type I      R-Square

  Intercept    1       3.43333       0.80170      4.28     0.0005              .             0
  Amount       1      -1.68444       1.45927     -1.15     0.2643        0.54625       0.54625
  amount2      1       1.02389       0.87380      1.17     0.2575        0.10748       0.65372
  amount3      1      -0.22222       0.20982     -1.06     0.3044        0.07620       0.72992
  amount4      1       0.01611       0.01743      0.92     0.3682        0.01293       0.74285

                                      Parameter Estimates

                                                ------Type I-----
                               Variable    DF   F Value    Pr > F

                               Intercept    1       .       .
                               Amount       1     36.11    <.0001
                               amount2      1      7.11    0.0163
                               amount3      1      5.04    0.0384
                               amount4      1      0.85    0.3682

```

The F test shows that at least one of the variables is good. The R^2 looks ok. The typical tests that we have seen are to the left of "Squared Semi-partial Corr Type I". The t-tests look really bad there. Since the F test told us that something is useful and the t-tests show that nothing is useful, this is a flag that we may have collinearity problems. Type-I correlations are very important with polynomial regression, to help understand this.

Cumulative R-squared gives you a step-by-step growth in R^2 with the addition of each variable. The Squared Semi-partial Corr Type I shows you how much the Cumulative R-Squared jumps with each variable addition.

The Type-I tests, the last column under parameter Estimates, are what are really important here. The Type-III tests assume that all other varialbes are in the model. The Type-I tests are sequential - for Amount, it is the actual p-value for Amount when it is the only variable in the regression. Look then at p = 0.0163; it is the p-value for amount2 with the only other variable in the model being Amount.

p = 0.0384 is the p-value for amount3, assuming only that Amount and amount2 also are in the model (and not amount4). The p-value for amount4 is bad. Notice that the amount4 p-value is the same as the Type-III p-value for amount4 because it is the same model (with all variables) when produced sequentially.

Everything went haywire when amount4 is added to the model.

Since order matters in a polynomial, be careful how you list them and always use the `SCORR1(TESTS)` option.

You should include the lower order terms if you include the higher order terms. This is called maintaining model hierarchy.

The `LACKFIT` option here is designed to give hypothesis tests around repeated measures. We have a repeated measures example here. We're not randomly selecting data: we prespecified things here. We made multiple observations at amount 1 of chemical. Multiple observations at amount 2 of chemical, etc... The downside to this is that we could be potentially biasing the data. 

'LACKFIT' splits the error into two pieces: Lack of Fit and Pure Error. "Lack of Fit" is a bias measure. Testing if Sum of Squares for bias is too big. The null hypothesis is that the bias is actually small enough -- there is no bias. We want to fail to reject it. 

Example: consulting group that went to Antarctica and took repeated measures of algae at only 3 spots.

```
/* st201d04.sas */
proc reg data=paper plots (unpack) =(diagnostics (stats=none)); 
   Cubic_Model: model strength=amount amount2 amount3 / lackfit 
   scorr1(tests);
title "Paper Data Set: 3rd Degree Polynomial";   
run;
quit;
```

Results:
```
                           Paper Data Set: 3rd Degree Polynomial                             6
                                                                    09:03 Tuesday, July 16, 2013

                                       The REG Procedure
                                       Model: Cubic_Model
                                 Dependent Variable: Strength

                            Number of Observations Read          22
                            Number of Observations Used          22


                                      Analysis of Variance

                                             Sum of           Mean
         Source                   DF        Squares         Square    F Value    Pr > F

         Model                     3        0.52986        0.17662      16.22    <.0001
         Error                    18        0.19605        0.01089
           Lack of Fit             1        0.00938        0.00938       0.85    0.3682
           Pure Error             17        0.18667        0.01098
         Corrected Total          21        0.72591


                      Root MSE              0.10436    R-Square     0.7299
                      Dependent Mean        2.81364    Adj R-Sq     0.6849
                      Coeff Var             3.70919

```

It looks like the errors are coming more from the model that from bias induced by the testing procedure. That is because we fail to reject the null hypothesis for "Lack of Fit".

A repeated measures problem might arise... if you have a room with 80 people and you want to model the average blood pressure. You select 3 people and take their blood pressure 15 times each. A better way to do this would be to select 45 different people and take their blood pressure once. 

In the paper/chemical example, we're spraying the same amounts repeatedly, instead of spraying random amounts each time. That's why the repeated measures problem potentially arises.

####Multicollinearity

Two pieces of information that are summarizing the same thing...

- Affects the parameter estimates
- affects the standard errors of the parameter estimates
- might not affect the predictions for future points
- can lead to serious rounding errors in estimating the parameters

Signs of multicollinearity:

- Significant F test with insignificant t-tests
- Reversal of coefficient signs (add a variable and a different variable's coefficient changes)
- Large fluctuations in coefficient values (from 3.2 to 4300, for example)
- Large swings in errors and the significance of tests start to change.

In a perfect model with no multicollinearity, if you add x2 to a model, the coefficient of x1 never changes.

**Multicollinearity Diagnostics**

- Look at correlation statistics (from `PROC CORR`). Close to 1 or -1 indicate a high degree of linear relationship. Close to 0 indicate no clear linear relationship
- Variance inflation factors (VIF) from `PROC REG`. This basically is how much does the error on your beta change when you add other variables. `VIF = 1/(1-R^2i)`. This is the individual R-squared for the variables in the model. For example `VIF1 = 1/(1-R-squared1)`. If you have x1, x2, and x3, if you want VIF for x1, then you predict x1 using x2 and x3 and get the R-squared from that calculation. A variance inflation factor of 10 is too big.
- Condition index values from `PROC REG`. Values between 10 and 30 suggest weak dependencies. Between 30 and 100 indicate moderate dependencies. Greater than 100 indicate strong collinearity.

Eigenvector: direction of variability
Eigenvalue:  measure of variability

These are ways to "rotate the axis" of the data to evaluate the spread in the data. The condition index is the ratio of the max length along the longest variability axis to the shortest.

The larger the condition index, the more correlation there is.

`NOSIMPLE` will not provide the mean, median, min, max, etc... 
```
title 'Collinearity Diagnosis for the Cubic Model';

proc corr data=paper nosimple plots=matrix;
   var amount amount2 amount3;
run;
```

Results:
```
              Collinearity Diagnosis for the Cubic Model                          7
                                                                    09:03 Tuesday, July 16, 2013

                                       The CORR Procedure

                           3  Variables:    Amount   amount2  amount3


                           Pearson Correlation Coefficients, N = 22
                                  Prob > |r| under H0: Rho=0

                                      Amount       amount2       amount3

                       Amount        1.00000       0.98278       0.94869
                                                    <.0001        <.0001

                       amount2       0.98278       1.00000       0.99036
                                      <.0001                      <.0001

                       amount3       0.94869       0.99036       1.00000
                                      <.0001        <.0001
```

We have enough evidence to say that none of the correlations between these variables is zero.

Here's `PROC REG`. If you want the **condition index**, you must have the `COLLIN` and `COLLINOINT` are key to doing the condition index chart.
```
proc reg data=paper;
   model strength=amount amount2 amount3 / vif collin collinoint;
run;
quit;
title; 
```

Results:
```
                                     Parameter Estimates

                           Parameter       Standard                              Variance
      Variable     DF       Estimate          Error    t Value    Pr > |t|      Inflation

      Intercept     1        2.73280        0.26060      10.49      <.0001              0
      Amount        1       -0.36900        0.32208      -1.15      0.2669      393.09634
      amount2       1        0.22339        0.11651       1.92      0.0712     2048.80921
      amount3       1       -0.02862        0.01270      -2.25      0.0369      699.53428

```

The VIF is super high for all of them and indicate a big problem with collinearity.

Looking at the Condition Index:
```
                                   Collinearity Diagnostics

                             Condition   ---------------Proportion of Variation---------------
    Number    Eigenvalue         Index     Intercept        Amount       amount2       amount3

         1       3.68081       1.00000    0.00043562    0.00002910    0.00001194    0.00004451
         2       0.30838       3.45487       0.01447    0.00001443    0.00005095    0.00060756
         3       0.01072      18.53340       0.10613       0.01759    0.00072341       0.02002
         4    0.00009941     192.42582       0.87897       0.98237       0.99921       0.97932



                         Collinearity Diagnostics (intercept adjusted)

                                   Condition    ---------Proportion of Variation---------
        Number     Eigenvalue          Index         Amount        amount2        amount3

             1        2.94800        1.00000     0.00028442     0.00005614     0.00016067
             2        0.05168        7.55288        0.02697     0.00004444        0.01238
             3     0.00032033       95.93188        0.97274        0.99990        0.98746

```

Top table: Go to the bottom row of Condition Index. Is it greater than 100? Yes.

Go to proportion of variance on the Intercept. Is it greater than 0.5? Yes. This means that the intercept also is part of the problem, so we go down the the `intercept adjusted` table.

Go to the bottom row of the int adjusted table. The Condition Index is still close to 100. Look for variables that have Proportion of variation that is greater than 0.5. All of them have greater than 0.5. You only need to care about the ones that have greater than 0.5 -- those are the ones involved in the collinearity.

**Dealing with Multicollinearity**

- Exclude redundant independent variables.
- Redefine variables.
- Use biased regression techniques such as ridge regression or principal component regression.
- Center the independent variables in polynomial regression models.

**Center Variables**

For polynomial regression, all we have to do is to center variables. The intercept is the biggest problem with a polynomial model. If you center variables, they all center on 0, so the intercept is equal to y-bar and it doesn't try to interfere with your variables (due to multicollinearity).

- Use the `STDIZE` procedure with the `METHOD=mean` option.
- Use SAS DATA steps to subtract the means from the variables.

**Center things before you square them and cube them**

Be very careful that you do not overwrite your data set by mistake.

CENTER FIRST, SQUARE SECOND.


Rename amount to mcamount.
```
options formdlim="_";
proc stdize data=sasuser.paper method=mean out=paper1(rename=(amount=mcamount));
   var amount;
run;

data paper1;
   set paper1;
   mcamount2 = mcamount**2;
   mcamount3 = mcamount**3;
run;

/***altertanively, use a SQL and a DATA step to center the variable*/
proc sql;
   select mean(amount) into: mamount
   from sasuser.paper;
run;

data paper2;
   set sasuser.paper;
   mcamount=amount-&mamount;
   mcamount2 = mcamount**2;
   mcamount3 = mcamount**3;
run;
```

Now, run the regression:
```
/* st201d07.sas */
proc reg data=paper1;
   model strength = mcamount mcamount2 mcamount3 / 
                      vif collin collinoint;
   title 'Centered Cubic Model';
run;
title;
quit; 
```


Results:
```

                                      Centered Cubic Model      09:03 Tuesday, July 16, 2013  10

                                       The REG Procedure
                                         Model: MODEL1
                                 Dependent Variable: Strength

                            Number of Observations Read          22
                            Number of Observations Used          22


                                      Analysis of Variance

                                             Sum of           Mean
         Source                   DF        Squares         Square    F Value    Pr > F

         Model                     3        0.52986        0.17662      16.22    <.0001
         Error                    18        0.19605        0.01089
         Corrected Total          21        0.72591


                      Root MSE              0.10436    R-Square     0.7299
                      Dependent Mean        2.81364    Adj R-Sq     0.6849
                      Coeff Var             3.70919


                                      Parameter Estimates

                           Parameter       Standard                              Variance
      Variable     DF       Estimate          Error    t Value    Pr > |t|      Inflation

      Intercept     1        2.89841        0.03495      82.93      <.0001              0
      mcamount      1        0.18335        0.04372       4.19      0.0005        7.24339
      mcamount2     1       -0.04979        0.01500      -3.32      0.0038        1.18088
      mcamount3     1       -0.02862        0.01270      -2.25      0.0369        7.66067


                                    Collinearity Diagnostics

                             Condition   ---------------Proportion of Variation---------------
    Number    Eigenvalue         Index     Intercept      mcamount     mcamount2     mcamount3

         1       2.04973       1.00000       0.02343       0.02199       0.03190       0.02368
         2       1.64309       1.11691       0.09627       0.01486       0.06824       0.00960
         3       0.24015       2.92150       0.80943       0.02321       0.70431       0.00537
         4       0.06702       5.53008       0.07087       0.93994       0.19554       0.96135



________________________________________________________________________________________________

                                      Centered Cubic Model      09:03 Tuesday, July 16, 2013  11

                                       The REG Procedure
                                         Model: MODEL1
                                 Dependent Variable: Strength

                         Collinearity Diagnostics (intercept adjusted)

                                   Condition    ---------Proportion of Variation---------
        Number     Eigenvalue          Index       mcamount      mcamount2      mcamount3

             1        2.00352        1.00000        0.03095        0.03215        0.03094
             2        0.92755        1.46969        0.01078        0.83355        0.00205
             3        0.06893        5.39133        0.95827        0.13431        0.96701

```

Notice here that The Variance Inflation is low for the variables. Then look at the condition index -- it is only 5, which means that we eradicated the collinearity and we are done.

If you then want to make a prediction with the model, you have to adjust your predicted y by the mean of x so that you can provide the actual predicted model.

The more curve you have in your line, the more that `PROC STDIZE` will help address multicollinearity problems.

####Multiple Polynomial Regression

- Conduct polynomial regression with more than one independent variable

Plot the car data:
The `price*...` means you want to compare all of the other variables to price. This will allow you to eyeball the relationships.

```
proc sgscatter data=sasuser.cars;
   plot price*(citympg hwympg cylinders enginesize horsepower fueltank
        luggage weight); 
run;

```


Look more closely at the variables with a possible higher order term. The `PBSPLINE` option tells SAS to try to fit a curve to the graph.
```
ods graphics  / imagemap=on;
ods listing close;
ods html style=statistical;
proc sgscatter data=sasuser.cars;
 plot price*(citympg hwympg fueltank weight) / pbspline;
run;
ods html close;
ods listing;
```
Citympg and Hwympg look quadratic. Size of Fuel Tank in Gallons looks cubic, but outliers are pulling it down. It probably is quatradic with outliers getting in the way. Weight probably is mostly quadratic.

Next, look at the correlation between all variables:
```
proc corr data=sasuser.cars nosimple;
   var price citympg hwympg cylinders enginesize horsepower fueltank luggage weight;
run;   
```

There is a lot of correlation going on in the data. HOWEVER, just because there is correlation does not mean that we have a PROBLEM with correlation.

This will show a matrix of the correlations:
```
ods listing  style=analysis;
proc sgscatter data=sasuser.cars;
  matrix  citympg hwympg cylinders enginesize horsepower fueltank luggage weight;
run; 
```

Now that we know that there are problems. Now we think about the model selection statistics. We've seen these before:

- Cofficient of determination (R-squared)
- Adjusted coefficient of determination (adj R-squared)
- Mallow' Cp statistic

These are new:

- **Made for comparison**: These CANNOT be compared across different data sets. They are data set dependent because they are heavily dependent on the errors (SSE).
- Akaike's information criteria (AIC). Smaller is better. There is no range on them. Punishes you for crappy variables.
- Schwarz's Bayesian criterian (SBC). Smaller is better. There is no range. This is stricter and it punishes you more for crappy variables.

**Model Selection**

Standardize first - make sure to output to a new data set.
```
proc stdize data=sasuser.cars method=mean out=sasuser.cars2;
   var citympg hwympg fueltank weight;
run;
```

Run the data step to create the quadradic variables:
```
data sasuser.cars2;
   set sasuser.cars2;
   citympg2  = citympg*citympg;
   hwympg2   = hwympg*hwympg;
   fueltank2 = fueltank*fueltank;
   fueltank3 = fueltank2*fueltank;
   weight2   = weight*weight;
run;    
```

Run this to select variables:
```
ods graphics / reset=all;

title 'Model Selection Cars2 Data Set';
proc reg data=sasuser.cars2 plots(only) = criteria ;

   backward: 
   model price = citympg citympg2 hwympg hwympg2 cylinders
                 enginesize horsepower fueltank fueltank2 weight2
                 luggage weight
                 / selection=backward slstay=0.05;

   forward:
   model price = citympg citympg2 hwympg hwympg2 cylinders
                 enginesize horsepower fueltank fueltank2 weight2
                 luggage weight
                 / selection=forward slentry=0.05;

   Rsquared:
   model price = citympg citympg2 hwympg hwympg2 cylinders
                 enginesize horsepower fueltank fueltank2 weight2
                 luggage weight
                 / selection=rsquare adjrsq cp sbc aic best=3;

   plot cp.*np. / vaxis=0 to 30 by 5 haxis=0 to 12 by 1 
                  cmallows=red nostat nomodel;

   symbol v=circle w=4 h=1;

   Adjusted_R2:
   model price = citympg citympg2 hwympg hwympg2 cylinders
                 enginesize horsepower fueltank fueltank2 weight2
                 luggage weight 
                 / selection=adjrsq rsquare cp sbc aic best=10;
run;
quit;  
title;
```
Remember that the "Number of Parameters" is the number of variables + 1. If you see that 5 is the best number of parameters, then you will have 4 variables in the model.

Remember that you look for a Mallow's Cp value that is as close as possible to -- but lower than -- the number of parameters (variables + 1).

Maintain model hierarchy. Do not select a model that has a squared term but lacks the regular term.

`PROC LOGISTIC` and `PROC GLM` will create quadratic and higher order terms for you. Since SAS knows about the creation of them, it will maintain model hierarchy when presenting results.

**Take the candidate models and throw them at the test data set & score them through `PROC SCORE`.**

####Chapter 2: Regression Diagnostics and Remedial Measures

- Evaluate model assumptions
- Evaluate model fit
- Evaluate multicollinearity
- Identify influential observations

The assumptions for linear regression are that the error terms are independent and normally distributed with equal variance. Therefore, evaluating model assumptions for linear regression includes checking for independent observations, normally distributed error terms, and constant variance.

ε ~ iid N(0,σ^2)

**Evaluate Model Assumptions: Independence**

- Know the source of your data: correlated errors can arise from data gathered over time, repeated measures, clustered data, or data from complex survey designs.
- For time series data, check that the errors are independent by examing plots of residuals versus time or other ordering component; Durbin-Watson statistic or the first-order autocorrelation statistic for time-series data. The Durbin-Watson statistic is not appropriate if you higher than 1st order variables or if you have lag-dependent variables (one of the variables depends on the previous value of y).

If you have a positive correlation of errors, you will have higher F-tests and t-test than you should get. The model will look much better than it actually is. 

**Evaluate Model Assumptions: Normality**

Check that the error terms are normally distributed by examining:

- A histogram of the residuals
- A normal probability plot of the residuals
- Tests for normality

**Evaluate Model Assumptions: Constant Variance**

Check for constant variance of the error terms by examining:

- plot of residuals versus predicted values (look for a cloud of points with no pattern, centered around 0)
- plot of residuals versus the independent variables (look for a cloud of points with no pattern, centered around 0)
- test for heteroscedasticity
- Spearman rank correlation coefficient between absolute values of the residuals and predicted values. Here we don't use the value of the variable, but the rank of the variable... do variables tend to move together?

For Spearman, consider this data set:


x  |y  
---|------
10|100
20|5000
30|5000000


In this data, the correlation coefficient would be low, but the Spearman Ranked Correlation Coefficient would be 1 because the variables move in step with each other. You want to take the absolute value of the error and look at the predicted value.

Having heteroscedasticity affects only the p-values.

**The Spearman Rank Correlation Coefficient**

The Spearman rank correlation coefficient is available as an option in `PROC CORR`. If the Spearman rank correlation coefficient between the absolute value fof the residuals and the predicted values is:

- close to zero, then the variances are approximately equal
- positive, then the variance increases as the mean increases
- negative, then the variance decreases as the mean increases

**Evaluate Model Fit**

Use the diagnostic plots available via the ODS graphics output of `PROC REG` to evaluate the model fit:

- Plots of residuals and studentied residuals versus predicted values
- "Residual-Fit Spread" (or R-F) plot provides a visual summary of the amount of variability accounted for by a model. It is comprised of two panels. The left panel shows the quantile plot of the predicted values minus their mean; the right panel is a quantile plot of the residuals. For comparison purposes, the scales are identical on both plots. Look at page 2-9 for more information. The "Fit-Mean" is the variability that we are able to explain in the model (SSR/SSM). The "Residual" panel is the remaining variability that I was unable to explain (SSE).
- Plots of the observed values versus the predicted values gives a visual tool for examining how close the fitted values are to the observed values. Plot y vs. y-hat and hope for all points along the straight 45 degree line (for a perfect fit).
- Partial regression leverage points are an attempt to isolate the effects of a single variable on the residuals. The slope of the linear regression line in the partial regressionleverage plot is the regression coefficient for that independent variable in the full model.


**Partial Regression Leverage Plot**

A partial regression leverage plot is the plot of the residuals for the dependent variable against the residuals for a selected regressor. The residuals for the dependent variable come from regressing the dependent variable on all independent variables, except for the selected regressor; the residuals for the selected regressor are calcualted from a model where the selected regressor is regressed on the remaining independent variables. 

Patterns in these plots, for example curvature, would be evidence of a relationship not accounted for by the full model. These plots are also helpful in detecting outliers and influential points.

It is a scatter plot of:

- Regress Y on x2 and x3 => obtain residuals
- Regress x1 on x2 and x3 => obtain residuals

What are we seeing here? What is the effect that x1 has on y? Is it linear? Or is it something quadratic or sinusoidal that we missed?

Plotting the unique aspects of x1 against the properties of y that can be explained by x2 and x3. What is the effect of x1 on the model if I adjust for all of the other variables that I'm including? The plot shows it.

Bottom Line: you don't want to see a pattern on these plots. You also can use the plot to identify outliers. The slope of the linear line is exactly to the value of β1 from the original model.

**Evaluating Model Fit**

- Examing model-fitting statistics, such as R-squared, Adj R-squared, AID, SBC, and Mallow's Cp.
- Use the `LACKFIT` option in the `MODEL` statement in `PROC REG` to test for lack-of-fit for models that have replicates for each value of the combination of the independent variables.

**Evaluating Multicollinarity**

- Correlation statistics with `PROC CORR`
- Variance inflation factors (`VIF` option in the `MODEL` statement in `PROC REG`).
- Condition index values (`COLLIN` and `COLLINOINT` options in the `MODEL` statement in `PROC REG`)

The VIF and the Condition Index Values are the best measures to use.

**Influential Observations versus Outliers**

An influential observation changes the entire model. An outlier won't change the entire model, but will change one of the variables. Influential observations change the results more than outliers. You can have observations that are both influential and outliers.

If you have 99 people who have average spending and then you add a single observation as influential as Bill Gates, it will affect the slope of the model because 100 is not a lot of observations. However, if the sample has 100,000 observations, then Bill Gate will be an outlier, but perhaps not an influential observation anymore.

**Identifying Influential Observations**

- `RSTUDENT` residual measures the change in the residuals when an observation is deleted from the model.
- Leverage measures how far an observation is from the cloud of observed data points
- Cook's D measures the simultaneous change in the parameter estimates when an observation is deleted.
- `DFFITS` measures the change in predicted values when an observation is deleted from the model.

Other than the Leverage method, which tries to see how far something is from the cloud of data, all of the other ones remove a value and then reevaluate the model.

**Identifying Influential Observations: DFBETAs**

Measure the change in each parameter estimate when an observation is deleted from the model. Separate DFBETAs are calculated for each observation for each variable. Therefore, the statistic assesses the impact of the individual observation on the parameter estimate for a particular variable.

**Identifying Influential Observations: The Covariance Ratio**

The Covariance Ratio measures the change in the precision of the parameter estimates when an observation is deleted from the model. This of this as a single number that shows the overall variability for all of your parameters. `Variability of all data when excluding observation i / Variability of all data when including observation i`. If the observation is not influential, this value will be very close to 1. 

How far away from 1 is considered to be significant?

**Identifying Influential Observations - Summary of Suggested Cutoffs**

|Influential Statistics|Cutoff Values|
|----------------------|-------------|
|RSTUDENT Residuals|ABS(RSTUDENT) > 2|
|LEVERAGE|LEVERAGE > 2p/n|
|Cook's D|CooksD > 4/n|
|DFFITS|ABS(DFFITS) > 2*SQRT(p/n)|
|DFBETAS|ABS(DFBETAS) > 2/SQRT(n)|
|COVRATIO|COVRATIO < 1-(3p/n) or COVRATIO > 1+(3p/n)|


**Examples in SAS**

```
ods html style=analysis;
PROC REG DATA = sasuser.cars2  PLOTS (LABEL) = ALL;
   MODEL price = hwympg hwympg2 horsepower
     / VIF COLLIN COLLINOINT INFLUENCE SPEC PARTIAL;
   ID model;
   OUTPUT OUT = check 
            R = residual 
            P = pred 
            RSTUDENT = rstudent 
            H = leverage;
RUN;
QUIT;    
```

The partial results:
```

                                      Parameter Estimates

                            Parameter       Standard                              Variance
      Variable      DF       Estimate          Error    t Value    Pr > |t|      Inflation

      Intercept      1        4.03949        2.17024       1.86      0.0665              0
      Hwympg         1       -0.80407        0.21378      -3.76      0.0003        4.06937
      hwympg2        1        0.04350        0.01430       3.04      0.0032        2.26764
      Horsepower     1        0.09730        0.01614       6.03      <.0001        2.36905


                                    Collinearity Diagnostics

                             Condition   ---------------Proportion of Variation---------------
    Number    Eigenvalue         Index     Intercept        Hwympg       hwympg2    Horsepower

         1       2.17779       1.00000       0.01125       0.00133       0.03345       0.00845
         2       1.52787       1.19389       0.00125       0.09241       0.06816       0.00352
         3       0.26890       2.84585       0.03127       0.32286       0.68972    0.00003866
         4       0.02544       9.25245       0.95623       0.58341       0.20867       0.98800

```

This shows that we don't have problems with multicollinearity. The condition index is close to 10. When it is between 10 and 30, it shows that we might have some moderate multicollinearity.

This uses the `SPEC` option and test if the errors are homoscedastic, if the errors are independent of the x variables, and constant varance. The null hypothesis here is that the errors are independent and homoscedastic. This means we have to reject the null and that one (or both) of these assumptions is not satisfied. This means we need to do more research.

```
                                       The REG Procedure
                                         Model: MODEL1
                                   Dependent Variable: Price

                                    Test of First and Second
                                      Moment Specification

                                   DF    Chi-Square    Pr > ChiSq

                                    8         16.49        0.0359
```

Note that the log shows:
```
WARNING: The average covariance matrix for the SPEC test has been deemed singular which
         violates an assumption of the test. Use caution when interpreting the results of the
         test.

```

This means that we cannot rely on this test and have to do further research to interpret the results.

Additional results:
```

                                       The REG Procedure
                                         Model: MODEL1
                                   Dependent Variable: Price

                                        Output Statistics

                                                            Hat Diag         Cov
         Obs             Model     Residual     RStudent           H       Ratio      DFFITS

           1    Integra             -1.0276      -0.2177      0.0244      1.0774     -0.0344
           2    Legend               5.2465       1.1274      0.0367      1.0236      0.2199
           3    100                 12.9697       2.8930      0.0239      0.7108      0.4527
           4    90                   4.3697       0.9304      0.0239      1.0317      0.1456
           5    535i                 5.6921       1.2598      0.0882      1.0639      0.3917
           6    Century              1.6914       0.3578      0.0208      1.0688      0.0522
           7    LeSabre             -1.5990      -0.3379      0.0189      1.0675     -0.0469
           8    Riviera              2.8762       0.6085      0.0179      1.0522      0.0821
           9    Roadmaster          -3.0075      -0.6425      0.0363      1.0699     -0.1246
          10    DeVille              6.0465       1.3028      0.0367      1.0013      0.2541


                                                 The REG Procedure
                                         Model: MODEL1
                                   Dependent Variable: Price

                                       Output Statistics

                                       --------------------DFBETAS--------------------
              Obs             Model    Intercept      Hwympg     hwympg2    Horsepower

                1    Integra              0.0059     -0.0218      0.0232       -0.0151
                2    Legend              -0.0266     -0.0837      0.0843        0.0424
                3    100                  0.0885     -0.2313      0.1656       -0.0353
                4    90                   0.0285     -0.0744      0.0533       -0.0113
                5    535i                -0.2901      0.3016     -0.2385        0.3528
                6    Century              0.0257      0.0081     -0.0212       -0.0120
                7    LeSabre              0.0114     -0.0112      0.0147       -0.0223
                8    Riviera              0.0005     -0.0144      0.0033        0.0151
                9    Roadmaster          -0.0275      0.0810     -0.0684        0.0203
               10    DeVille             -0.0307     -0.0968      0.0974        0.0490


```

The various tests that we discussed are here. You can study the table, but it probably is better to look at the plots and think about code that identifies the points that are influential.

The Q-Q Plot of Residuals for Price doesn't fit well on the tails. In risk analysis, it matters that the tails don't fit well, because we aren't trying to look into the middle of the sample, where nobody is committing risky behavior. Regression models, by definition, try to work better around the middle of the data. They aren't great for working with the extremes (outlier analysis).

The plot of Residual by Predicted by Price shows a fan shape -- this shows that variance of residuals is not constant, which probably is why it failed the earlier Chi-squared test. Since we think the variance might not be constant, we can then use the Spearman test to check.

Here's how you do that:
```
data check;
   set check;
   abserror=abs(residual);
run;

proc corr data=check spearman nosimple;
   var abserror pred;
run;   
```

Results:
```
                                       The CORR Procedure

                                2  Variables:    abserror pred


                           Spearman Correlation Coefficients, N = 81
                                   Prob > |r| under H0: Rho=0

                                                    abserror          pred

                      abserror                       1.00000       0.60274
                                                                    <.0001

                      pred                           0.60274       1.00000
                      Predicted Value of Price        <.0001

```

This shows that as the predicted value increases, the variability of the errors increases.

Now, compare the residuals with the regressors -- the "Residual by Regressors for Price" plot. In hwympg2, after the cluster of data, we start to see a linear pattern off to the right. What you want to see is a cloud of points with no other obvious pattern. The linear pattern means that, beyond a certain point, the residuals are not independent. We get into the territory where the residuals are correlated with the x variable, which can introduce bias to the model.

For the Residual-Fit Spread Plot for Price, if the range of the plot on the left is larger than the range of the plot on the right, then we can say that we are capturing enough of the errors in our model.

Consider with the cars that there are elements to luxury cars that cannot be captured easily in the model. For example, a Ferrari is expensive simply because it is a Ferrari.

The "Influence Diagnostics for Price" needle chart shows the DFFITS values for the outliers and shows the bounds for outliers.

We want to focus on the influential observations. This code produces a table with the influential observations:
```
%let numparms = 4;
%let numobs = 81;
data influence;
 set check;
 absrstud=abs(rstudent);
 if absrstud ge 2 then output;
 else if leverage ge (2*&numparms /&numobs) then output;
run;

proc print data=influence;
 var manufacturer model price hwympg horsepower;
run;
```

These are influential observations and outliers:
```
             Obs    Manufacturer     Model          Price     Hwympg     Horsepower

              1     Audi             100             37.7     -4.0370        172
              2     Cadillac         Seville         40.1     -5.0370        295
              3     Dodge            Stealth         25.8     -6.0370        300
              4     Geo              Metro            8.4     19.9630         55
              5     Honda            Civic           12.1     15.9630        102
              6     Infiniti         Q45             47.9     -8.0370        278
              7     Lincoln          Continental     34.3     -4.0370        160
              8     Mercedes-Benz    190E            31.9     -1.0370        130
              9     Suzuki           Swift            8.6     12.9630         70

```

####Remedial Measures for Regression

The process:

1. Exploratory Data Analysis   -> 2   | This step includes the use of descriptive statistics, graphs, and correlation analysis to identify those variables that might be useful in the regression model.
2. Candidate Model Selection   -> 3   | This step uses the information gathered from the exploratory data analysis and numerous model selection options in `PROC REG` to identify one or more candidate models. Potential models can be evaluated by comparing the adjusted coefficients of determination, Mallows' Cp statistic, and information criteria. You can also produce the plot of residuals versus the predicted values, plots of the residuals versus the regressors, and the R-F spread plot to assess the model fit.
3. Model Assumption Validation -> 4   | This step includes graphs of the residuals versus the predicted values. It also includes tests for normal residuals, constant variances, and independent observations.
4. Collinearity and Influential Observation Detection -> 5   | The presence of multicollinearity can be detected by the use of the VIF statistic, condition indices, and variation proportions. Influential observations can be detected by examining plots of Rstudent residuals, Cook's D statistics, DFFITS statistics, DFBETAS statistics, covariance ratio statistics, leverage statistics, and partial leverage plots.
5. Model Revision -> 2,3,6   | If steps 3 and/or 4 indicate the need for model revision, generate a new model that is more appropriate. For example, you might need to transform the response variable to meet the equal variance assumption. Based on the nature of the refinement, you might need to return to step 1 or 2 to identify new candidate models for the transformed response variable.
6. Prediction Testing   | This final step (not covered in this course) is to evaluate the model's predictive capability with data not used to build the model. In other words, you would build the model with part of your data and use the remainder of the data to determine how well the model fits the data.


**When the Normality Assumption is Violated**

- Transform the dependent variable
- Fit a generalize dlinear model using `PROC GENMOD` or `PROC GLIMMIX` with the appropriate `DIST=` and `LINK=` option.

**When the Constant Variance Assumption is Violated**

- Request tests using the heteroscedasticity-consistent variance estimates.
- Transform the dependent variable.
- Model the nonconstant variance by using: `PROC GENMOD` or `PROC GLIMMIX` with the appropriate `DIST=` option.
- `PROC MIXED` with the `GROUP=` option and `TYPE=` option
- SAS SURVEY procedures for survey data
- SAS/ETS procedures for time-series data
- Weighted least squares regression model

**When the Independence Assuption is Violated**

- Use the appropriate modeling tools to account for correlated observations:
- `PROC MIXED`, `PROC GENMOD`, or `PROC GLIMMIX` for repeated measures data
- `PROC AUTOREG` or `PROC ARIMA` in SAS/ETS for time-series data
- `PROC SURVEYREG` for survey data.

**When a Straight Line Is Inappropriate**

- Fit a polynomial regression model
- Transform the independent variables to obtain linearity.
- Fit a nonlinear regression model using `PROC NLIN` if appropriate.
- Fit a nonparametric regression model using `PROC LOESS`

When you do transformations, you're trying to change the shape of the cloud of data so that it is easier to fit a model to it.

**When there is Multicollinearity**

- Exclude redundant independent variables
- Redefine independent variables
- Use biased regression techniques such as ridge regression or principal component regression
- Center the independent variables in polynomial regression models

**When there are Influential Observations**

- Make sure that there are no data errors
- Perform a sensitivity analysis and report results from different scenarios
- Investigate the cause of the influential observations and redefine the model if appropriate
- Delete the influential observations if appropriate and document the situation
- Limit the influence of outliers by performing robust regression analysis using `PROC ROBUSTREG`

**Transforming the Dependent Variable**

- Transforming the dependent variable is one of the common approaches to deal with nonnormal data and/or nonconstant variances.
- To determine the appropriate transformation, use theoretical knowledge or previous research, use trial and error, consider the rate at which the variance increases as the dependent variable increases, use `PROC TRANSREG` for Box-Cox transformations.

**The Box-Cox Transformation**

Use this for correcting heteroscedasticity.

If λ == 0, then take the log(y). If y != 0, then use (y^λ - 1)/λ

Look at the proportion of σ to μ (of y, the dependent variable) and then look for the appropriate transformation on the page 2-42.

Box and Cox present a method for determining the appropriate power transformation for the dependent variable to stabilize variances or to correct for nonnormality.

TODO: Look for slide 40 in the notes that ha the three log regression specifications


|Case|Population regression function|Interpretation of slope coefficient|
|----|------------------------------|-----------------------------------|
|Linear-log|`yi = β1*LN(Xi) + e`|A 1% increase in X is associated with a 0.01β1 change in y.|
|Log-linear|`LN(yi) = β0 + β1X1 + e`|A change in X by one unit is associated with a 100β1% change in y|
|Log-log|`LN(yi) = β0 + β1*LN(Xi) + e`| A 1% change in X is associated with a β1% change in y (β1 is an elasticity)|

...