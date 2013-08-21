## Stats Review SAS Code

### Day 1

```

/* Day 1 SAS Code */
/*----------------------------------------------------------------------------------*/
*ods html close;
*ods rtf file="Day 1 SAS Report 2013.rtf";
*ods rtf;
*options nodate nonumber ls=95 ps=80;


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


/* User Exercise */

/* What is the overall mean and standard deviation? */
/* Mean: 98.25
   STD :  0.73

*/

/* What is the interquartile Range of body temperature? */
/*
    QRANGE: 0.90
*/


PROC MEANS DATA = sasuser.NormTemp MAXDEC = 2 n mean std qrange;
    VAR   BodyTemp;
RUN;

/* Do the mean values seem to differ between men and women? */
/*
    Female: 98.4
    Male  : 98.1
*/

PROC MEANS DATA = sasuser.NormTemp MAXDEC = 2 n mean median std qrange PRINTALLTYPES;
    CLASS Gender;
    VAR   BodyTemp;
RUN;

/*----------------------------------------------------------------------------------*/


/*st101d02.sas*/  /*Part A*/
proc univariate DATA = sasuser.testscores;
    VAR       SATScore;
    HISTOGRAM SATScore / NORMAL(MU=est SIGMA=est) KERNEL; /* est tell sas to estimate it */
    INSET     SKEWNESS KURTOSIS / POSITION = ne;

    PROBPLOT  SATScore / NORMAL(MU=est SIGMA=est);
    INSET     SKEWNESS KURTOSIS;
    TITLE    'Descriptive Statistics Using PROC UNIVARIATE';
run;

/*st101d02.sas*/  /*Part B*/
proc sgplot data=sasuser.testscores;
    vbox SATScore / datalabel=IDNumber;
    format IDNumber 8.;
    refline 1200 / axis=y label;
    title "Box-and-Whisker Plots of SAT Scores";
run;


/* Exercise from page 1-41 */

PROC UNIVARIATE DATA = sasuser.NormTemp;
    VAR     BodyTemp;

    HISTOGRAM BodyTemp / NORMAL(MU = est SIGMA = est) KERNEL;
    INSET     SKEWNESS KURTOSIS / POSITION = ne;
    TITLE   'Desc Stats for BodyTemp';

    PROBPLOT BodyTemp / NORMAL(MU = est SIGMA = est);
    INSET   SKEWNESS KURTOSIS;
RUN;

PROC SGPLOT DATA = sasuser.NormTemp;
    VBOX    BodyTemp / DATALABEL = BodyTemp;
    FORMAT  BodyTemp 5.2;
    REFLINE 98.6 / AXIS = y LABEL;
    TITLE   'Body Temp Box Plot';
RUN;
/*----------------------------------------------------------------------------------*/


/*st101d03.sas*/
proc means data=sasuser.testscores maxdec=2
           n mean std stderr clm;
    var SATScore;
    title '95% Confidence Interval for SAT';
run;

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

/*----------------------------------------------------------------------------------*/


/*st101d04.sas*/  /*Part A*/
*ods graphics off;
*ods select testsforlocation; /* would give only the test for location piece of the proc univariate output */
PROC UNIVARIATE data=sasuser.testscores mu0=1200;
    VAR SATScore;
    TITLE 'Testing Whether the Mean of SAT Scores = 1200';
run;
ods graphics on;

/*st101d04.sas*/  /*Part B*/
PROC TTEST DATA=sasuser.testscores H0 = 1200
           plots(shownull)=interval;
    VAR   SATScore;
    TITLE 'Testing Whether the Mean of SAT Scores = 1200 '
          'Using PROC TTEST';
RUN;

*ods rtf close;
*ods html;

PROC UNIVARIATE DATA = sasuser.NormTemp MU0 = 98.6;
    VAR BodyTemp;
    TITLE 'Testing Whether the Mean of BodyTemp = 98.6 using PROC UNIVARIATE';
RUN;

PROC TTEST DATA = sasuser.NormTemp H0 = 98.6 plots(shownull) = interval;
    VAR BodyTemp;
    TITLE 'Testing Whether the Mean of BodyTemp = 98.6 Using PROC TTEST';
RUN;

```

### Day 2


```
/* Day 2 SAS Code */
/*----------------------------------------------------------------------------------*/
*ods html close;
*ods rtf file="Day 2 SAS Report 2013.rtf";
*ods rtf;
*options nodate nonumber ls=95 ps=80;

/*st103d01.sas*/  /*Part A*/
ods graphics / reset=all imagemap;
proc corr data=sasuser.fitness rank
          plots(only)=scatter(nvar=all ellipse=none);
    var RunTime Age Weight Run_Pulse
        Rest_Pulse Maximum_Pulse Performance;
    with Oxygen_Consumption;
    id name;
    title "Correlations and Scatter Plots with Oxygen_Consumption";
run;

/*st103d01.sas*/  /*Part B*/
ods graphics / reset=all;
proc corr data=sasuser.fitness nosimple 
          plots=matrix(nvar=all histogram);
    var RunTime Age Weight Run_Pulse
         Rest_Pulse Maximum_Pulse Performance;
    title "Correlations and Scatter Plot Matrix of Fitness Predictors";
run;


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

/*----------------------------------------------------------------------------------*/


/*st103d02.sas*/

proc reg data=sasuser.fitness;
    model Oxygen_Consumption = RunTime;
    title 'Predicting Oxygen_Consumption from RunTime';
run;
quit;


/*----------------------------------------------------------------------------------*/


/*st103d03.sas*/
data Need_Predictions;
    input RunTime @@;
    datalines;
9 10 11 12 13
;
run;

PROC PRINT DATA = Need_Predictions;
RUN;

proc reg data=sasuser.fitness noprint 
         outest=Betas;
    PredOxy: model Oxygen_Consumption=RunTime;
run;
quit;

proc print data=Betas;
    title "OUTEST= Data Set from PROC REG";
run;

proc score data=Need_Predictions score=Betas
           out=Scored type=parms;
    var RunTime;
run;

proc print data=Scored;
    title "Scored New Observations";
run;

/*st103d03.sas*/  /*Self Study*/ 
data Need_Predictions;
    input RunTime @@;
    datalines;
9 10 11 12 13
;
run;

data Predict;
    set Need_Predictions 
        sasuser.fitness;
run;

ods graphics off;

proc reg data=Predict;
    model Oxygen_Consumption=RunTime / p;
    id RunTime;
    title 'Oxygen_Consumption=RunTime with Predicted Values';   
run;
quit;

ods graphics on;


/*----------------------------------------------------------------------------------*/


/*st103d04.sas*/
ods graphics off;
proc reg data=sasuser.fitness;
    model Oxygen_Consumption=Performance RunTime;
    title 'Multiple Linear Regression for Fitness Data';
run;
quit;

ods graphics on;


/* Exercise 3 on page 3-65 */
PROC REG DATA = sasuser.BodyFat2;
    MODEL PctBodyFat2 = Age Weight Height Neck Abdomen Hip Thigh Ankle Biceps Forearm Wrist;
    TITLE 'Kitchen Sink';
RUN;




/*----------------------------------------------------------------------------------*/


/*st103d05.sas*/  /*Part A*/
ods graphics / imagemap=on;

proc reg data=sasuser.fitness plots(only)=(rsquare adjrsq cp);
    ALL_REG: model oxygen_consumption 
                    = Performance RunTime Age Weight
                      Run_Pulse Rest_Pulse Maximum_Pulse
            / selection=rsquare adjrsq cp;
    title 'Best Models Using All-Regression Option';
run;
quit;


/*st103d05.sas*/  /*Part B*/
ods graphics / imagemap=on;

proc reg data=sasuser.fitness plots(only)=(cp);
    ALL_REG: model oxygen_consumption 
                    = Performance RunTime Age Weight
                      Run_Pulse Rest_Pulse Maximum_Pulse
            / selection=cp rsquare adjrsq best=20;
    title 'Best Models Using All-Regression Option';
run;
quit;


/*----------------------------------------------------------------------------------*/


/*st103d06.sas*/
ods graphics off;
proc reg data=sasuser.fitness;
   PREDICT: model Oxygen_Consumption 
                  = RunTime Age Run_Pulse Maximum_Pulse;
   EXPLAIN: model Oxygen_Consumption 
                  = RunTime Age Weight Run_Pulse Maximum_Pulse;
   title 'Check "Best" Two Candidate Models';
run;
quit;

ods graphics on;


/*----------------------------------------------------------------------------------*/


/*st103d07.sas*/

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


proc reg data=sasuser.fitness plots(only)=(rsquare adjrsq cp);
    ALL_REG: model oxygen_consumption 
                    = Performance RunTime Age Weight
                      Run_Pulse Rest_Pulse Maximum_Pulse
            / selection=rsquare adjrsq cp;
    title 'Best Models Using All-Regression Option';
run;
quit;



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

### Day 3

```

/* Day 3 SAS Code */
/*----------------------------------------------------------------------------------*/
*ods html close;
*ods rtf file="Day 3 SAS Report 2013.rtf";
*ods rtf;
*options nodate nonumber ls=95 ps=80;

/* st201d01.sas */ /* Part A */
proc sgscatter data=sasuser.school;
 compare y=reading3
         x=(words1 letters1 phonics1);
 title 'Scatter Plots of READING3 by WORDS1 LETTERS1 and PHONICS1';
run;                                

/* st201d01.sas */ /* Part B */
options formdlim="_";
proc reg data=sasuser.school 
    plots (only)=diagnostics (unpack);
    model reading3 = words1 letters1 phonics1;
    output out=out r=residuals;
title 'School Data: Regression and Diagnostics';
run;
quit;                                

/* st201d01.sas */ /* Part C */
proc univariate data=out normal;
  var residuals;
run;
                                    

/*----------------------------------------------------------------------------------*/


/* st201d02.sas */

options formdlim="_";
title1 "Sasuser.Paper Data Set";
ods html close;
ods listing;
ods html;
proc sgplot data=sasuser.paper;
 scatter x=amount y=strength;
 title2 "Scatter Plot";
run;

proc sgplot data=sasuser.paper;
    reg  x=amount y=strength / lineattrs =(color=brown       
         pattern=solid) legendlabel="Linear";
title2 "Linear Model";
run; 

proc sgplot data=sasuser.paper;
    reg  x=amount y=strength / degree=2 lineattrs =(color=green       
         pattern=mediumdash) legendlabel="2nd Degree";
title2 "Second Degree Polynomial";
run;

proc sgplot data=sasuser.paper;
   reg  x=amount y=strength / degree=3 lineattrs =(color=red   
        pattern=shortdash) legendlabel="3rd Degree";
title2 "Third Degree Polynomial";
run;

proc sgplot data=sasuser.paper;
    reg  x=amount y=strength / degree=4 lineattrs =(color=blue
      pattern=longdash) legendlabel="4th Degree";
title2 "Fourth Degree Polynomial";
run;                                                


/*----------------------------------------------------------------------------------*/


/* st201d03.sas */
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


/*----------------------------------------------------------------------------------*/


/* st201d04.sas */
proc reg data=paper plots (unpack) =(diagnostics (stats=none)); 
   Cubic_Model: model strength=amount amount2 amount3 / lackfit 
   scorr1(tests);
title "Paper Data Set: 3rd Degree Polynomial";   
run;
quit;


/*----------------------------------------------------------------------------------*/


/* st201d05.sas */
title 'Collinearity Diagnosis for the Cubic Model';

proc corr data=paper nosimple plots=matrix;
   var amount amount2 amount3;
run;

proc reg data=paper;
   model strength=amount amount2 amount3 / vif collin collinoint;
run;
quit;
title; 


/*----------------------------------------------------------------------------------*/


/* st201d06.sas */
options formdlim="_";
proc stdize data=sasuser.paper method=mean out=paper1(rename=(amount=mcamount));
   var amount;
run;

data paper1;
   set paper1;
   mcamount2 = mcamount**2;
   mcamount3 = mcamount**3;
run;                               *ST201d06.sas;      


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


/*----------------------------------------------------------------------------------*/


/* st201d07.sas */
proc reg data=paper1;
   model strength = mcamount mcamount2 mcamount3 / 
                      vif collin collinoint;
   title 'Centered Cubic Model';
run;
title;
quit;                                  


/*----------------------------------------------------------------------------------*/


/* st201d08.sas */
proc sgscatter data=sasuser.cars;
   plot price*(citympg hwympg cylinders enginesize horsepower fueltank
        luggage weight); 
run;


ods graphics  / imagemap=on;
ods listing close;
ods html style=statistical;
proc sgscatter data=sasuser.cars;
 plot price*(citympg hwympg fueltank weight) / pbspline;
run;
ods html close;
ods listing;


/*----------------------------------------------------------------------------------*/


/* st201d09.sas */
ods html;
proc corr data=sasuser.cars nosimple;
   var price citympg hwympg cylinders enginesize horsepower fueltank luggage weight;
run;         
                                
ods listing  style=analysis;
proc sgscatter data=sasuser.cars;
  matrix  citympg hwympg cylinders enginesize horsepower fueltank luggage weight;
run; 


/*----------------------------------------------------------------------------------*/


/* st201d10.sas */
proc stdize data=sasuser.cars method=mean out=sasuser.cars2;
   var citympg hwympg fueltank weight;
run;

data sasuser.cars2;
   set sasuser.cars2;
   citympg2 = citympg*citympg;
   hwympg2 = hwympg*hwympg;
   fueltank2=fueltank*fueltank;
   fueltank3=fueltank2*fueltank;
   weight2 = weight*weight;
run;    


/*----------------------------------------------------------------------------------*/


/* st201d11.sas */
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


/*----------------------------------------------------------------------------------*/


/* st202d01.sas */
ods graphics / imagemap=on;
ods listing close;
ods html style=analysis;
proc reg data=sasuser.cars2  plots (label)=all;
   model price = hwympg hwympg2 horsepower
     / vif collin collinoint influence spec partial;
   id model;
   output out=check r=residual p=pred rstudent=rstudent h=leverage;
run;
quit;                               


data check;
   set check;
   abserror=abs(residual);
run;

proc corr data=check spearman nosimple;
   var abserror pred;
run;                   

proc print data = sasuser.cars;
    VAR model hwympg horsepower price;
RUN; 


/*----------------------------------------------------------------------------------*/


/* st202d02.sas */
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


/*----------------------------------------------------------------------------------*/


/* st202d03.sas */
*ods html close;
*ods rtf file="BoxPlots.rtf" style=journal;
ods select BoxCoxFPlot BoxCoxLogLikePlot RMSEPlot;

proc transreg data=sasuser.cars2 ss2 test cl nomiss 
    plots=boxcox (rmse unpack);
   model boxcox(price / convenient)=identity(hwympg hwympg2 horsepower);
run;
quit;                                                
*ods rtf close;     
                                    
*ods listing;
proc transreg data=sasuser.cars2 ss2 test cl nomiss plots=none;
   model boxcox(price / convenient)=identity(hwympg hwympg2 horsepower);
run;
quit;                               


/*----------------------------------------------------------------------------------*/


/* st202d04.sas */
title;

data sasuser.logcars2;
 set sasuser.cars2;
 LogPrice=log(price);
run;

proc reg data=sasuser.logcars2;
   model logprice = hwympg hwympg2 horsepower;
   ods output ANOVA=ANOVATable; 
   output out=out p=Pred r=Resid;
run;
quit;

data out;
   set out;
   abserror=abs(resid);
run;

proc corr data=out spearman nosimple;
   var abserror pred;
run;                               

data _null_;
   set ANOVATable;
   if source='Error' then call symput('Var', MS);
run;

data out;
   set out;
   Estimate = exp(pred + &var/2);
   Difference = price - estimate;
run;

proc print data=out;
   var manufacturer model hwympg horsepower price estimate difference;
run;                                    

proc sgplot data=out;
   scatter x=estimate y=difference;
   xaxis min=0 max=60;
   yaxis min=-30 max=25;
   refline 0;
run;
quit;
                                    
proc sgplot data=out;
   scatter x=estimate y=difference /datalabel=model;
   xaxis min=0 max=60;
   yaxis min=-30 max=25;
   refline 0;
run;
quit;


/*----------------------------------------------------------------------------------*/


/* st202d05.sas */
proc reg data=sasuser.cars2;
   model price = hwympg hwympg2 horsepower  / hcc hccmethod=3;
run;
quit; 

```

### Day 4

```

/* Day 4 SAS Code */
/*----------------------------------------------------------------------------------*/
*ods html close;
*ods rtf file="Day 4 SAS Report 2013.rtf";
*ods rtf;
*options nodate nonumber ls=95 ps=80;

/*st102d01.sas*/
proc ttest data=sasuser.TestScores(WHERE=(IDNumber ~= 39196697)) plots(shownull)=interval;
    class Gender;
    var SATScore;
    title "Two-Sample t-test Comparing Girls to Boys";
run;

PROC TTEST DATA = sasuser.german plots(shownull) = interval;
    CLASS Group;
    VAR   Change;
    TITLE "Two-Sample t-test Comparing Treatment and Control";
RUN;
/*----------------------------------------------------------------------------------*/


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

/*st102d02.sas*/  /*Part C*/
proc sgplot data=sasuser.MGGarlic;
    vbox BulbWt / category=Fertilizer datalabel=BedID;
    REFLINE 0.219; *Calculated earlier;
    format BedID 5.;
    title "Box and Whisker Plots of Garlic Weight";
run;


/*----------------------------------------------------------------------------------*/


/*st102d03.sas*/  /*Part A*/
proc glm data=sasuser.MGGarlic;
     class Fertilizer;
     model BulbWt=Fertilizer;
     title 'Testing for Equality of Means with PROC GLM';
run;
quit;

/*st102d03.sas*/  /*Part B*/
proc glm data=sasuser.MGGarlic plots(only)=diagnostics;
     class Fertilizer;
     model BulbWt=Fertilizer;
     means Fertilizer / hovtest;
     title 'Testing for Equality of Means with PROC GLM';
run;
quit;



/* Exercise 2 on page 2-37 */
PROC MEANS DATA = sasuser.ads PRINTALLTYPES N MEAN STD SKEWNESS KURTOSIS MAXDEC = 2;
    VAR     Sales;
    CLASS   Ad;
    TITLE   'Descriptive Statistics of Ad Sales';
RUN;

PROC SGPLOT DATA = sasuser.ads;
    VBOX    Sales / CATEGORY = Ad;
    REFLINE 66.82;
    TITLE   'Box and Whisker Plots of Ad Sales';
RUN;

/* part b */
PROC GLM DATA = sasuser.ads PLOTS(ONLY) = DIAGNOSTICS;
    CLASS Ad;
    MODEL Sales = Ad;
    MEANS Ad / HOVTEST;
    TITLE 'Testing for Equality of Means of Ad Groups with PROC GLM';
RUN;
QUIT;

/*----------------------------------------------------------------------------------*/


/*st102d04.sas*/
proc glm data=sasuser.MGGarlic_Block plots(only)=diagnostics;
     class Fertilizer Sector;
     model BulbWt=Fertilizer Sector;
     title 'ANOVA for Randomized Block Design';
run;
quit;

/* Exercise 3 from page 2-49 */
PROC GLM DATA = sasuser.ads1 PLOTS(ONLY) = DIAGNOSTICS;
    CLASS Ad Area;
    MODEL Sales = Ad Area;
    MEANS Ad / HOVTEST;
    TITLE 'Testing for Equality of Means of Ad Groups with Blocking';
RUN;
QUIT;


/*----------------------------------------------------------------------------------*/


/*st102d05.sas*/
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

/* Exercise 4 on page 2-65 */
PROC GLM DATA = sasuser.ads1 PLOTS(ONLY) = (CONTROLPLOT DIFFPLOT(CENTER));
    CLASS   Ad Area;
    MODEL   Sales = Ad Area;
    LSMEANS Ad / PDIFF = ALL ADJUST = TUKEY;
    LSMEANS Ad / PDIFF = CONTROL('display') ADJUST = DUNNETT;
    TITLE   'Sales Data: Multiple Comparisons';
RUN;

/*----------------------------------------------------------------------------------*/


/*st102d06.sas*/  /*Part A*/
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

/*st102d06.sas*/  /*Part C*/
proc sgplot data=means;
    series x=DrugDose y=BloodP_Mean / group=Disease markers;
    xaxis integer;
    title 'Plot of Stratified Means in Drug Data Set';
    format DrugDose dosefmt.;
run;

/*st102d06.sas*/  /*Part D*/
proc glm data=sasuser.drug order=internal;
    class DrugDose Disease;
    model Bloodp=DrugDose Disease DrugDose*Disease;
    title 'Analyze the Effects of DrugDose and Disease';
    title2 'Including Interaction';
    format DrugDose dosefmt.;
run;
quit;

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

### Day 5

```

/* Day 5 SAS Code */
/*----------------------------------------------------------------------------------*/
*ods html close;
*ods rtf file="Day 5 SAS Report 2013.rtf";
*ods rtf;
*options nodate nonumber ls=95 ps=80;

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

proc univariate data=sasuser.Titanic noprint;
    class Survived;
    var Age ;
    histogram Age;
    inset mean std median min max / format=5.2 position=ne;
    format Survived survfmt.;
run;


/*----------------------------------------------------------------------------------*/


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


/*----------------------------------------------------------------------------------*/


/*st105d03.sas*/
ods graphics off;
proc freq data=sasuser.exact;
   tables A*B / chisq expected cellchi2 nocol nopercent;
   title "Exact P-Values";
run;

ods graphics on;


/*----------------------------------------------------------------------------------*/


/*st105d04.sas*/
ods graphics off;
proc freq data=sasuser.Titanic;
    tables Class*Survived / chisq measures cl;
    format Survived survfmt.;
    title1 'Ordinal Association between CLASS and SURVIVAL?';
run;

ods graphics on;


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

/*----------------------------------------------------------------------------------*/


/*st105d05.sas*/
proc logistic data=sasuser.Titanic
              plots(only)=(effect oddsratio);
    model Survived(event='1')=Age / clodds=pl;
    title1 'LOGISTIC MODEL (1):Survived=Age';
run;


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

/*----------------------------------------------------------------------------------*/


/*st105d06.sas*/
proc logistic data=sasuser.Titanic plots(only)=(effect oddsratio);
    class Gender(ref='male') Class(ref='3') / param=ref;
    model Survived(event='1')=Age Gender Class / clodds=pl;
    units age=10;
    title1 'LOGISTIC MODEL (2):Survived=Age Gender Class';
run;


/*----------------------------------------------------------------------------------*/


/*st105d07.sas*/  /*Part A*/
proc logistic data=sasuser.Titanic plots(only)=(effect oddsratio);
    class Gender(ref='female') Class(ref='3') / param=ref;
    model Survived(event='1')=Age|Gender|Class @2 / 
          selection=backward clodds=pl slstay=0.01;
    units age=10;
    title1 'LOGISTIC MODEL (3): Backward Elimination '
           'Survived=Age|Gender|Class';
run;

/*st105d07.sas*/  /*Part B*/
proc logistic data=sasuser.Titanic 
              plots(only)=oddsratio(range=clip);
    class Gender(ref='male') Class(ref='3') / param=ref;
    model Survived(event='1')=Age Gender|Class;
    units age=10;
    oddsratio Gender / at (Class=ALL) cl=pl;
    oddsratio Class / at (Gender=ALL) cl=pl;
    oddsratio Age / cl=pl;
    title1 'LOGISTIC MODEL (3.1): Survived=Age Gender|Class';
run;

```