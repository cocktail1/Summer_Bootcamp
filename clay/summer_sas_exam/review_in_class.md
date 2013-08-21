## Exam Review with LaBarr

Material Exam:
  * 50 questions
  * Multiple Choice
  * True/False
  * Short Answer (1-2 sentences)
  * All conceptual - no calculations
  * No notes, books, internet, friends
  * Will have a formula sheet, but probaby won't need it
  * 3 hours, should take 1-2 to finish

Computing Assessment:
  * Notes, Internet, Books allowed - no friends
  * 3 questions (each has 5-10 parts)
  * Not open ended
  * Steps aren't all dependent on the previous step
  * submit.ncsu.edu or email


Here's a regression, I need you to explore your data. Do it. Here are variables, let's look at relationships. Give me a scatterplot.

Scatter plot of all x's vs. all x's (matrix of scatterplots)



What is a confidence interval? What is the interpretation of a confidence interval?

## Fundamental Statistical Concepts

**Variable Types**

* Categorical
  * Nominal: any order
  * Ordinal: inherent order
* Continuous

**Populations vs. Samples**

Know that parameters are for populations and statistics are for samples.

What to know parameter. The parameter describes the population. Instead, you take a sample and calculate a statistic, which estimates the parameter.  Circular pattern.

**Central Tendency**

What do distributions look like? Where are their centers? Locations of distributions?

Quartiles. Q2 is the median. 

**Spread**

- Range
- Interquartile Range
- Variance: great, but the units are squared and difficult to interpret
- Square root of the variance -> Standard Deviation

**Normal Distribution**

Described completely by its central tendency and spread

- Symmetric, mean = median, bell shaped, skewness = 0, unimodal, any value from neg to pos infinity
- Empirical rule: 68, 95, 99.7
- Standard normal dist has a mean of 0 and standard dev of 1.

**Distribution Shape**

- Skewness, left vs. right skewed
- Kurtosis, platykurtic vs. leptokurtic

**Sampling Distribution**

Distribution of *statistics*, not a distribution of observations. For example, a distribution of sample means.

**Confidence Intervals**

Know what they mean and how to interpret them.

**Central Limit Theorem**

From any population, as long as the sample is large enough, sample means follow the normal distribution

**Hypothesis testing**

- Null vs. Alternative
- What is a test statistic?
- What is a p-value and how do you interpret it.

0. Verify the assumptions
1. State hypothesis, null and alternative
2. Collect evidence -- calculate test statistic
3. Calculate the p-value -- how rare is the evidence
4. Decision rule -- how rare is too rare?
5. State your conclusions in human language

LaBarr will give us the alpha that we need to know -- don't need to reference the table.

- Type I Error: Person innocent, threw them in jail
- Type II Error: Person guilty, let them go

### Regression

**REMEMBER: ALWAYS PLOT YOUR DATA!!!**

You have to understand what data you have before you run a regression.

Summarize data:
  - Pearson correlation coefficient: *r*
  - Define it, know the properties

Correlation does not imply causation. **This will be on the exam**

Problems with correlation:
  * it doesn't detect everything
  * outliers will screw it up
  * shouldn't be used with non-linear relationships

#### Simple Linear Regression

Model the relationship between two variables: `y = beta0 + beta1*x + error`

Be able to interpret both the slope and the intercept.

Residuals = actual value - predicted value.

- TSS = Total Sums of Squares
- SSE = Sums of square errors
- SSM/SSR = Sums of squares model

Know the interpretation of big R-squared. The percentage change you can explain with the model.

Hypothesis test for the slope (beta1)

**KNOW THESE: Assumptions for Regression**

1. Linearity of the mean
2. Normality of errors
3. Independence of errors
4. Constant variance of errors / homoscedasticity

#### Multiple Linear Regression

1. Global F-test. Know what it is, how to interpret it, and where to find it on SAS output.

Additional assumption: No **perfect** collinearity. We can have collinearity and multicollinearity, but we cannot have perfect collinearity.

Adjusted R-squared: know why we needed it instead of regular R-squared

**Two Goals of Modelling**

1. Prediction
2. Explanation of parameters

#### Model Selection Techniques

Two overall family of methods: know the advantages and disadvantages of both families.
  1. Stepwise regression techniques: know them and how they work
    * Forward Selection
    * Backward Selection
    * Stepwise Selection
  2. All possible regression techniques
    * Comparing R-squared
    * Comparing Adj R-squared
    * Mallow's Cp

#### Violations of Assumptions

- Know how to determine if you have violated an assumption.
- Know how to fix the assumptions - for example, you can use transformations to fix a lack of normality. Know the idea that they can be a solution.
- What breaks and doesn't break when assumptions break?

Use Spearman correlation to check homo- vs. heterscedasticity.

Spearman is the correlation of the ranks... Pearson is correlation of non-ranked. All Spearman did was take the ranks, order them, and then look at the correlation

Do not worry about the interpretation of the log transformations right now.

Know all of the solutions to multicollinearity:
  * take out terms
  * ridge regression
  * standardize 
  * transform variables

**Residual Plots**

**Polynomial Regression**

What is inherent in polynomial regression? multicollinearity. Address it by centering around 0.

You can standardize x, but then you square, cube, etc... the standardized value. Do not standardize a value that already is squared.

When you standardize/center, the intercept is pushed back to the average of y and becomes y-bar.

To get results out, then you have to return things back to where they were before -- shift by the mean.

#### Multicollinearity

- Correlation
- VIP
- Condition Index

Know solutions to multicollinearity.

- AIC: smaller number is better (comparison techniques - the value means nothing. run two models and compare the AIC - lower value is better)
- SBC: small number is better

#### Outliers vs. Influential Points

How do you determine which is which? Know what the differences are and how to evaluate them. Also know how to fix them. 

- Look at Studentized Residuals to find outliers
- Cook's D, DFFITS, DFBETA, Leverage to find influential points

**Do not delete influential points!!**

- Investigate your points first. 
- If there is a typo, then fix it. First instinct is not to throw it out.
- Use Robust Regression

### ANOVA

#### Two-Sample Hypothesis Test

Assumptions:
  * Normality
  * Independence
  * Check equal variance - use the appropriate test. Use `HOVTEST` in `PROC GLM` and Folded F test in `PROC TTEST`.

Hypothesis tests for variances.

##### One-way ANOVA

Extending to a One-way ANOVA - comparing 3 or more categories.
  * Know difference between null and alternative hypothesis

Total Sums of Squares (TSS) = Sums of Squares Between (SSB) + Sums of Squares Within (SSW)

SSB = SSR or SSM

SSW = SSW

Within is your unexplained error. Between is explained error (by the model)

Know the ANOVA assumptions
  * Normality of populations OR normality of errors
  * Independence
  * Equal variance

**Observational Studies vs. Experiments**

Know the advantages and disadvantages.

**Blocking**

Common to do in experiments. Why do we block? To control for external nusiance factors that we cannot control. Blocking can solve the problems.

Extra assumptions with blocks:
  * There is no interactions between blocks and treatments
  * Treatments are randomly distributed within a block

##### Post-Hoc Tests

Comparisonwise error vs. Experimentwise error. Know the difference between them. How do we solve the problem?

* Tukey adjustment: not using a control; comparing to everything
* Dunnett adjustment: comparing to a control

#### Two-way ANOVA / N-WAY ANOVA

Be able to define an *interaction*. When we say two variables are interacting, we are **NOT** saying they are correlated. We are saying that when one variable changes, the relationship between the other variable and y changes. They *can* be correlated, and typically will be, but do not have to be.

Think about the Titantic example. The class you were was highly interacting with Gender.

### Categorical Data Analysis

Examine distributions first. The idea is to determine if categorical variables are related; if two are related, their distributions will change across different levels.

| Weather | Sad | Happy |
| ------- | --- | ----- |
| Sunny   | 30% | 70%   |
| Rain    | 80% | 20%   |

There's a relationship between weather and mood. No causal relationship.

**Tests of Association**

1. **Pearson Chi-Square** (SAS calls it just Chi-Square)
2. **Likelihood Ratio Chi-Square**: Has better properties when you get close to violating your sample size assumptions
3. **Mantel-Haenzsel** Chi-Square

The first two can be used for any variable you want: nominal, ordinal, combination of the two.

Mantel-Haenzsel is designed for ordinal vs. ordinal. It is designed to test two ordinal variables and their relationship.

**Strength of Association**

1. **Cramer's V**: calculation is not affected by sample size, but distance from zero is affected by sample size
2. **Odds Ratios** (only for 2x2 tables) = Odds-agroup/Odds-bgroup
3. **Spearman**: *Strength* of association for ordinal vs. ordinal

Don't confuse odds and odds ratios. Odds are probability of something happening over something not happening.

Odds Ratios aren't really affected by sample size in the testing, but the p-value on significance of odds ratios will be affected by sample size. 

Use the `EXPECTED` option in SAS to determine if you have cell counts are too low and you need to use Fisher's exact test.

#### Sample Size Requirements

Need less than 20% of the cells to have expected counts under 5. If this doesn't happen, look at Fisher's Exact Test instead. 

If we're given a table with expected cell counts, we need to be able to tell if we need Fisher's.

### Logistic Regression

Can be used to predict any categorical variable, but we only used it for binary response variables in class. The categories were (Yes/No).

Know why we cannot use Ordinary Least Squares (OLS) and why we need logistic regression.

**Assumption for Logistic Regression**

You are assuming that if you use the Logit -- the logistic regression -- that you will turn your S-curve into a straight line.

Don't worry about normality or errors.

Understand how to get an odds ratio out of a parameter estimate.

The logit is the log of the odds. If you take the exponential function, it gets rid of the log and all we have are the odds

#### Effects vs. Reference Coding

How to code them.

What's the difference between them.

Reference coding also is know as response or dummy coding.

Be able to write out what the coding is for reference vs. effects coding.

Which compares to overall average vs. to the reference level.

### Model Selection

- Condordant Pairs
- Discordant Pairs
- Tied Pairs

### Additional info

Type I vs. Type III p-values. 

Typically only should use Type-I in polynomial regression. For everything else, use Type III.

For the `LACKOFFIT` test with repeated measure, you either need to collect more data or different groups. If you have this problem, then you can't really proceed.

In an underspecified model, your coefficients are biased because you're assuming something is there that isn't. (?)

Overspecified model: variance inflated, but the parameter estimates are good.

Diagnostics - Specification test - tryies to test for multiple things at a time (like a global F test).