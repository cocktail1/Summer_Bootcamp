## SAS Programming 1

Create a path reference: `%let path=c:\workshop\prg1;`

A `libref` is an alias to a library. You establish the library with
`libname orion "c:\myfiles";` where orion is the name of the library and the location of the library is specified in the quotes.

To get rid of the library reference `libname orion clear`.

A library name is limited to 8 characters.
A variable name is limited to 32 characters.
Numeric variables have a maximum length of 8 bytes. ??
16 or 17 digits is the maximum precision?

TODO: Put the SAS definitions vs. the regular definitions here; data set = table, etc.
TODO: Working with date and time.

In the following, `nods` means no descriptors. This shows the entire dataset and all of the members get a single page.
```
proc contents data=orion._all_ nods;
run;
```

If you want to look at a single table, then:
```
proc contents data=orion.staff;
run;
```
At the top, it will indicate whether it is sorted, among other things.

The **SAS Autoexec File** is executed at start up. If you want SAS to run some commands automatically, at start up, then you put those commands into the autoexec file.

### Simple Reporting

This will display all observations, all variables, and an Obs column on the left.
```
proc print data=orion.sales;
run;
```

This will select the variables to include in the report and specifies their order:
```
proc print data=orion.sales;
    var Last_Name First_Name Salary;
run;
```

The SUM statement calculates and displays report totals for the requested numeric variables:
```
proc print data=orion.sales;
    var Last_Name First_Name Salary;
    sum Salary;
run;
```

The WHERE statement selects observations that meet the criteria specified in the WHERE expression. The log will show you how many observations were read from the file.
```
proc print data=orion.sales;
    var Last_name First_Name Salary;
    where Salary < 25500;
run;
```

You can suppress the Obs column if you don't want to see it:
```
proc print data=orion.sales noobs;
    var Last_name First_Name Salary;
    where Salary < 25500;
run;
```

Examples of SAS Date Constants
```
'01JAN2000'd
'31Dec1'D
'1jan04'd
'06NOV2000'D
```

Comparison Operators
```
Equal to                 =          EQ
Not equal to             ^= or ~=   NE
Greater than             >          GT
Less than                <          LT
Greater than or equal    >=         GE
Less than or equal       <=         LE
Equal to one of a list              IN
```

Logical Operators modify WHERE expressions:
```
proc print data=orion.sales;
    where Country = 'AU' and
          Salary < 30000;
run;
```

Logical Operators, listed in order of priority:
```
NOT   ^ ~
AND   &
OR    |
```

Logical Operator Examples
```
where Country ne 'AU' and Salary >= 50000;
where Gender eq 'M' or Salary ge 50000;
where Country = 'AU' or Country='US';
where Country in ('AU', 'US');
where Country not in ('AU', 'US');
```

Subsetting in a PROC PRINT Step. CONTAINS is a special WHERE operator:
```
proc print data=orion.sales noobs;
    var Last_Name First_Name Country Job_Title;
    where Country = 'AU' and Job_Title contains 'Rep';
run;
```

You can substitute `?` for `CONTAINS`, for example:
```
proc print data=orion.sales noobs;
    var Last_Name First_Name Country Job_Title;
    where Country = 'AU' and Job_Title ? 'Rep';
run;
```

Special WHERE Operators are operators that can be used only in WHERE expressions:
```
CONTAINS                  Includes a substring       (char)
BETWEEN-AND               An inclusive range         (char, num)
WHERE SAME AND            Augment a WHERE expression (char, num)
IS NULL                   A missing value            (char, num)
IS MISSING                A missing value            (char, num)
LIKE                      Matches a pattern          (char)
```

**Examples of the `BETWEEN-AND` Operator:**
```
where salary between 50000 and 100000;
where salary not between 50000 and 100000;
where Last_Name between 'A' and 'L';
where Last_Name between 'Baker' and 'Gomez';
```

These statements are equivalent:
```
where salary between 50000 and 100000;
where salary >= 50000 and salary <= 100000;
where 50000 <= salary <= 100000;
```

Use the **WHERE SAME AND operator** to add more conditions to an existing WHERE expression. The WHERE SAME AND condition augments the original condition.
```
proc print data=orion.sales;
    where Country = 'AU' and Salary < 30000;
    where same and Gender = 'F';
    var First_Name Last_Name Gender Salary Country;
run;
```

**`IS NULL` Operator** selects observations in which a variable has a missing value
```
where Employee_ID is null;
where Employee_ID is not null;
```

`IS NULL` can be used for both character and numeric variables, and is equivalent to the following statements:
```
where employee_ID = ' ';
where employee_ID = .;
```

**The `IS MISSING` operator** selects observations in which a variable has a missing value
```
where Employee_ID is missing;
where Employee_ID is not missing;
```

**The `LIKE` operator** selects observations by comparing character values to specified patterns. Two special characters are used to define a pattern:
- A percent sign `%` specifies that any number of characters can occupy that position.
- An underscore `_` specifies that exactly one character can occupy that position.
```
where Name like '%N';
where Name like 'T_m';
where Name like 'T_m%';
```
Note that this is case sensitive.

When using the LIKE operator:
- Consecutive underscores can be specified.
- A percent sign and an underscore can be specified in the same pattern.
- The operator is case sensitive.

**Subsetting the Data Set**
```
proc print data=orion.customer_dim;
    where Customer_Age = 21;
    var Customer_ID Customer_Name Customer_Gender
        Customer_Country Customer_Type;
run;
```

**The `ID` Statement**

The ID statement specifies the variable or variables to print at the beginning of each row instead of an observation number. Make sure to choose ID variables that uniquely identify observations.
```
proc print data=orion.customer_dim;
    where Customer_Age = 21;
    id Customer_ID;
    var Customer_ID Customer_Name Customer_Gender
        Customer_Country Customer_Type;
run;
```

**Page 4-25 exercises:**
```
proc print data=orion.order_fact noobs;
	where Total_Retail_Price > 500;
	sum   Total_Retail_Price;
	id    Customer_ID;
	var   Order_ID Order_Type Quantity Total_Retail_Price;
run;

proc print data=orion.customer_dim;
	where 30 < Customer_Age < 40;
run;
```

If you need to make your report wider, you can add:
```
options linesize = 200;
```
The max is 256.

Other options include changing the column headers' orientation:
```
proc print data=orion.customer_dim heading=v;
run;
```
You also can use `heading=h`.

You can create uniform column widths:
```
proc print data=orion.customer_dim width=uniform;
run;
```
This can be used together with header settings.

`PROC PRINT` cannot reorder/sort the data.

**Sorting data with `PROC SORT`**

The SORT procedure rearranges the observations in the input data set based on the values of the variable or variables listed in the `BY` statement. This creates a new data set, in a different library, and sorts it by salary.

```
proc sort data=orion.sales out=work.sales;
    by Salary;
run;
```
You also can use `by descending Salary`.

If you do not use `out =` then you will overwrite the original data set.

**Creating a Grouped Report**

1. Use the `SORT` procedure to group data in a data set. This scenario requires two variables to be sorted: Country and then descending Salary within Country.

2. Use a `BY` statement in `PROC PRINT` to display the sorted observations grouped by Country.

```
proc sort data=orion.sales out=work.sales;
    by Country descending Salary;
run;
```

Specifying sort order: the observations are sorted from the largest value to the smallest value and descending refers to the variable that comes after the keyword `descending`.
Examples:
```
by descending Last First;
```
Sorts by last name descending and then by first name

```
by Last descending First;
by descending Last descending First;
```

Use the `BY` statement in `PROC PRINT` to create report groupings.
```
proc print data=work.sales noobs;
    by Country;
run;
```
The data in work.sales must be sorted by Country in order for this to work.

**Generating Subtotals**

```
proc sort data=orion.sales out=work.sales;
    by Country descending Salary;
run;

proc print data=work.sales noobs;
    by Country
    sum Salary;
    var First_Name Last_Name Gender Salary;
run;
```

In this following example, the `where` statement can appear in either block, but putting it in the first block will make the program execute faster because it won't send the additional salary data to `proc print`. The earlier you can do your subsetting, the more efficient your program will be.

```
proc sort data=orion.sales out=work.sales;
    /* where Salary < 25500; */
    by Country descending Salary;
run;
proc print data=work.sales noobs;
    by Country;
    sum Salary;
    /* where Salary < 25500; */
    var First_Name Last_Name Gender Salary;
run;
```

Chapter 4 Exercise 6 page 4-39
```
proc sort data=orion.employee_payroll out=work.sort_salary2;
	by Employee_Gender descending Salary;
run;

proc print data=work.sort_salary2;
	by Employee_Gender;
run;
```

Chapter 4 Exercise 7 page 4-39
```
proc sort data=orion.employee_payroll out=work.sort_sal;
	by Employee_Gender descending Salary;
run;

proc print data=work.sort_sal noobs;
	where Employee_Term_Date is missing and Salary > 65000;
	by Employee_Gender;
	sum Salary;
	var Employee_ID Salary Marital_Status;
run;
```

Chapter 4 Exercise 8 page 4-40
```
proc sort data=orion.orders out=work.orders nodupkey dupout=work.duporders;
	by Customer_ID;
run;

proc print data=work.orders;
run;

proc print data=work.duporders;
run;

```

**Adding Titles and Footnotes**

```
title1 'Orion Star Sales Staff';
title2 'Salary Report';

footnote1 'Confidential';

proc print data=orion.sales;
    var Employee_ID Last_Name Salary;
run;

title;
footnote;
```

You can have titles 1-10 and footnotes 1-10. However, if you change footnote1 later, then you automatically destroy footnotes that have a value higher than 1. They have to be reentered if you want to preserve them.

###Chapter 5

**`LABEL` Statement**

Use a `LABEL` statement and the `LABEL` option to display descriptive column headings instead of variable names. Example:
```
title1 'Orion Star Sales Staff';
title2 'Salary Report';
footnote1 'Confidential';

proc print data=orion.sales label;
    var Employee_ID Last_Name Salary;
    label Employee_ID = 'Sales ID'
          Last_Name   = 'Last Name'
          Salary      = 'Annual Salary';
run;

title;
footnote;
```
The `PRINT` procedure uses labels only when the `LABEL` or `SPLIT=` option is specified.

The `SPLIT=` option in `PROC PRINT` specifies a split character to control line breaks in column headings.
```
proc print data=orion.sales split='*';
    var Employee_ID Last_Name Salary;
    label Employee_ID = 'Sales ID'
          Last_Name   = 'Last*Name'
          Salary      = 'Annual*Salary';
run;
```

**The `FORMAT` Statement**

The `FORMAT` Statement is used to enhance the display of values in a report. You must use character formats for character values and numeric formats for numeric values.
```
proc print data=orion.sales noobs;
    format Salary dollar8. Hire_Date mmddyy10.;
    var Last_Name First_Name Country Job_Title Salary Hire_Date;
run;
```

SAS formats have the following form: `<$>format<w>.<d>`

`$` indicates a character format.
`format` names the SAS format.
`w` specifies the total format width, including decimal places and the special characters.
`.` is required syntax. Formats always contain a period as part of the name.
`d` specifies the number of decimal places to display in numeric formats.

```
$w.          Writes standard character data
w.d          Writes standard numeric data
COMMAw.d     Writes numeric values with a comma that separates every three digits and a period that separates the decimal fraction
DOLLARw.d    Writes numeric values with a leading dollar sign, a comma that separates every three digits, and a period that separates the decimal fraction.
COMMAXw.d    Writes numeric values with a period that separates every three digits and a comma that separates the decimal fraction.
EUROXw.d     Writes numeric values with a leading euro symbol, a period that separates every three digits, and a comma that separates the decimal fraction.
```

See page 5-8 for examples for formats.
```
MMDDYY10.     01/01/1960
MMDDYY8.      01/01/60
MMDDYY6.      010160
DDMMYY10.     31/12/1960
DDMMYY8.      31/12/60
DDMMYY6.      311260

DATE7.        01JAN60
DATE9.        01JAN1960
WORDDATE.     January 1, 1960
WEEKDATE.     Friday, January 1, 1960
MONYY7.       JAN1960
YEAR4.        1960
```

Exercise #2 from page 5-11
```
title1 'US Sales Employees';
title2 'Earning Under $26,000';

proc print data=orion.sales label noobs;
          var Employee_ID First_Name Last_Name Job_Title Salary Hire_Date;
        label First_Name = 'First Name'
	      Last_Name  = 'Last Name'
              Job_Title  = 'Title' 
              Hire_Date  = 'Date Hired';

	where Salary < 26000;

        format Salary             DOLLAR12.2
               Hire_Date          MONYY7.;
run;

title;
```

Relevant for Exercise 3 on page 5-11:
Formats for quotes and uppercase
```
format First_Name Last_Name $upcase. Job_Title $quote.;
```

**`PROC FORMAT`**

Two-step process... create the format and then use it later in the code.

Running the following stores this in the work library for the rest of the session.
```
/* Defining a character format */
proc format;
    value $ctryfmt  'AU'  = 'Australia'
                    'US'  = 'United States'
                    other = 'Miscoded';
run;
```

If a value is missing, for example, FR, then the original value in the data is displayed.

Once you have defined the format, you use it like any other format.
```
/* Applying a format in a report */
proc print data=orion.sales;
    var Employee_ID Job_Title Salary Country Birth_Date Hire_Date;
    format Salary               DOLLAR10.
           Birth_Date Hire_Date MONYY7.
           Country              $ctryfmt.;
run;
```

**The `VALUE` Statement**

Format Names:
- can be up to 32 characters in length
- for character formats, must begin with a dollar sign ($), followed by a letter or underscore
- for numeric formats, must begin with a letter or underscore
- cannot end in a number
- cannot be given the name of a SAS format
- cannot include a period in the `VALUE` statement.

Ranges can be:
- a single value
- a range of values
- a list of values

Labels:
- can be up to 32,767 characters in length
- are enclosed in quotation marks.

**Example of creating and using a numeric format**
```
/* Defining a Numeric Format */
proc format;
    value tiers     0 - 49999 = 'Tier 1'
                50000 - 99999 = 'Tier 2'
              100000 - 250000 = 'Tier 3';
run;

/* Using the format */
proc print data=work.salaries;
    format Salary tiers.;
run;
```

p105d04.sas example:
```
proc format;
   value tiers 0-49999='Tier 1'                  
           50000-99999='Tier 2'
         100000-250000='Tier 3';
run;

data work.salaries;
	input Name $ Salary;
	Original_Salary=Salary;
	datalines;
Abi 50000
Mike 65000
Jose 50000.00
Joe 37000.50
Ursula 142000
Lu 49999.99
;

/* 
   This rounds up the salary for Lu. The reason why is because
   'When a value does not match any of the ranges, PROC PRINT attempts to 
   display the actual value. In this case, the column width was determined by
   the width of the formatted values, which is 6.
 */
proc print data=work.salaries;
   format Salary tiers.;
run;

/* This displays the entire range of Lu's salary */
proc print data=work.salaries;
   format Salary tiers8.;
run;
```
If two tiers overlap, then the value will go into the lower tier. If you need a tier that goes up to but does not include a value:
```
/* In this case, $49999.99 will fall into Tier 1
   50000 will fall into Tier 2 */
proc format tiers       0 -< 50000 = 'Tier 1'
                    50000 -  99999 = 'Tier 2';
run;
```

**Defining a Continuous Range**
```
50000 - 100000     Includes 50000     Includes 100000
50000 -< 100000    Includes 50000     Excludes 100000
50000 <- 100000    Excludes 50000     Includes 100000
50000 <-< 100000   Excludes 50000     Excludes 100000
```

You can define like this to get below or above a value:
```
proc format;
    value tiers        low -< 50000 = 'Tier 1'
                    50000 -< 100000 = 'Tier 2'
                      100000 - high = 'Tier 3';
run;
```

**User-Defined Format Using Lists for Ranges**
```
proc format;
    value mnthfmt 1,2,3 = 'Qtr 1'
                    4-6 = 'Qtr 2'
                    7-9 = 'Qtr 3'
                  10-12 = 'Qtr 4'
                      . = 'missing'
                  other = 'unknown';
run;
```

You can have multiple value statements inside a single format statement:
```
proc format;
    value mnthfmt 1,2,3 = 'Qtr 1'
                    4-6 = 'Qtr 2'
                    7-9 = 'Qtr 3'
                  10-12 = 'Qtr 4'
                      . = 'missing'
                  other = 'unknown';

    value tiers        low -< 50000 = 'Tier 1'
                    50000 -< 100000 = 'Tier 2'
                      100000 - high = 'Tier 3';
run;
```

**Exercise 4 on page 5-24**
```
proc format;
	value $GENDER 'F' = 'Female'
                  'M' = 'Male';

    value MNAME     1 = 'January'
                    2 = 'February'
                    3 = 'March';
run;

data Q1Birthdays;
   set orion.employee_payroll;
   BirthMonth=month(Birth_Date);
   if BirthMonth le 3;
run;

proc print data=Q1Birthdays;
    var Employee_ID Employee_Gender BirthMonth;
    format Employee_Gender $GENDER.
           BirthMonth      MNAME.;
run;
```

**Exercise 5 on page 5-25**
```
proc format;
    value  $GENDER 'F' = 'Female'
                   'M' = 'Male'
                 other = 'Invalid code';

    value  SALRANGE 20000 -< 100000 = 'Below $100,000'
                   100000 -< 500000 = '$100,000 or more'
                                  . = 'Missing salary'
                              other = 'Invalid salary';
run;

proc print data=orion.nonsales;
   var Employee_ID Job_Title Salary Gender;
   title1 'Salary and Gender Values';
   title2 'for Non-Sales Employees';

   format Salary SALRANGE.
          Gender $GENDER.;
run;
```

**Storing a format in a permanent library**
Simply add `lib=orion` to add it to the orion library, for example.
```
proc format lib=orion;
    value  $GENDER 'F' = 'Female'
                   'M' = 'Male'
                 other = 'Invalid code';
run;
```
If you do this, you then have to specify the location of the formats when you use them.
```
/* Format search option */
options fmtsearch=(orion);

proc print data=orion.nonsales;
   var Employee_ID Job_Title Salary Gender;
   title1 'Salary and Gender Values';
   title2 'for Non-Sales Employees';

   format Salary SALRANGE.
          Gender $GENDER.;
run;
```

###Chapter 6 - Reading SAS Data Sets

**Reading an existing SAS data set into another data set (as a subset)**
```
/* Take a subset of the data and save it into the work data set called subset1 */
data work.subset1;
    set orion.sales;
    where Country = 'AU' and
          Job_Title contains 'Rep' and
          Hire_Date < '01jan2000'd;
run;

/*
This takes the format
DATA output-SAS-data-set;
    SET input-SAS-data-set;
    WHERE WHERE-expression-for-subsetting;
RUN;
*/
```

By default, the SET statement reads all observations and all variables from the input data set. Observations are read sequentially, one at a time. The SET statement can read temporary or permanent data sets.

Using a WHERE statement might improve the efficiency of your SAS programs because SAS only processes the observations that meet the condition or conditions in the WHERE expression.

**SAS Date Constants**
A SAS date constant is a date written in the form `'ddmmm<yy>yy'd`

**Assignment Statements**
The assignment statement evaluates an expression and assigns the result to a new or existing variable.
```
data work.subset1;
    set orion.sales;
    where Country = 'AU' and
          Job_Title contains 'Rep' and
          Hire_Date < '01jan2000'd;
    Bonus = Salary * 0.10;
run;
```

**Sample Assignment Statements**

|Example            |Type           |
|-------------------|---------------|
|`Salary = 26960;` |Numeric constant|
|`Gender = 'F';` |Character constant|
|`Hire_Date = '21JAN1995'd;` |Date constant|
|`Bonus = Salary * 0.10;` |Arithmetic expression|

**Arithmetic Operators**

|Symbol|Definition|Priority|
|------|----------|--------|
|`**`|Exponentiation|1|
|`*`|Multiplication|2|
|`/`|Division|2|
|`+`|Addition|3|
|`-`|Subtraction|3|

In arithmetic expressions, if any of the values is missing, the result will be missing.

**Exercise 1 on page 6-15**
```
data work.youngadult;
    set orion.customer_dim;
    where Customer_Gender = 'F' and
          Customer_Age >= 18 and
          Customer_Age <= 36 and
          Customer_Group contains 'Gold';
    Discount = 0.25;
run;

proc print data=work.youngadult noobs;
    ID Customer_ID;
    var Customer_ID
        Customer_Name
        Customer_Age
        Customer_Gender
        Customer_Group
        Discount;
run;
```

**Exercise 2 on page 6-15**
```
data work.assistant;
    set orion.staff;
    where Job_Title contains 'Assistant' and 
          Salary < 26000;
    Increase   = Salary * 0.10;
    New_Salary = Salary + Increase;
run;

proc print data=work.assistant noobs;
    ID Employee_ID;
    var Job_Title Salary Increase New_Salary;
    format Salary Increase New_Salary DOLLAR10.2;
run;
```

**Exercise 3 on page 6-16**
```
data work.tony;
    set orion.customer_dim;
    where Customer_FirstName =* 'Tony';
run;

proc print data=work.tony;
    var Customer_FirstName Customer_LastName;
run;
```

`=*` is the SOUNDS-LIKE operator.

**The `DROP` Statement**
The DROP statement specifies the variables to exclude from the output data set
```
data work.subset1;
    set orion.sales;
    where Country = 'AU' and
          Job_Title contains 'Rep' and
          Hire_Date < '01jan2000'd;
    Bonus = Salary * 0.10;
    drop Employee_ID Gender Country Birth_Date;
run;
```

**The `KEEP` Statement**
The KEEP statement specifies all variables to include in the output data set. If a KEEP statement is used, it must include every variable to be written, including any new variables.
```
data work.subset1;
    set orion.sales;
    where Country = 'AU' and
          Job_Title contains 'Rep' and
          Hire_Date < '01jan2000'd;
    Bonus = Salary * 0.10;
    keep First_Name Last_Name Salary Job_Title Hire_Date Bonus;
run;
```

**PDV: Program Data Vector**

*DATA Step* processing includes two phases:
1. Compilation Phase: 
-- Scans the program for syntax errors; translates the program into machine language.
-- Creates the PDV (program data vector) to hold one observation; width, type, and name are required
-- Creates the descriptor portion of the output data set; the empty data set will then be sitting there ready.

2. Execution Phase:
- Compile the step; if it fails, go to the next step.
- Loops: Initialize PDV to missing -> Execute SET statement -> Execute other statements -> Output to SAS data set.
- At the SET statement, if it is the end of the file, then it goes to the next SAS program step.
- Implicit `OUTPUT` and `RETURN` statements are executed at the `run` phase.
- Variables populated from an existing source are not reinitialized. Variables created in the data step are reinitialized at the beginning of the loop.

**Look to the class notes to see which steps are compile time and which are execution time -- some of the statements are skipped during each phase.**

**The Subsetting `IF` Statement**
The subsetting IF statement tests a condition to determine whether the DATA step should continue processing the current observation. In this program, processing will reach the bottom of the DATA step and output an observation only if the condition is true.
```
data work.auemps;
    set orion.sales;
    where Country = 'AU';
    Bonus = Salary * 0.10;
    IF Bonus >= 3000;
run;
```

**Usage of the Subsetting IF Statment**

A subsetting IF can only be used in a DATA step.

|Step and Usage|`WHERE`|`IF`|
|--------------|-------|----|
|**PROC** step|Yes|No|
|**DATA** step (source of variable)| | |
|--SET statement|Yes|Yes|
|--assignment statement|No|Yes|

**Processing the Subsetting `IF` Statement**
1. DATA Statement
2. Read an Observation
3. IF False -> Return to 1.
4. If True... Continue Processing the Observation
5. Output Observation to SAS Data Set
6. Return to 1.

The following code explains how including the `WHERE` statement before the `IF` statement will improve performance when evaluating what should be in the output. The only difference is in how quickly the output is generated. The output itself is the same.
```
 /* Run each of the following programs.                */ 
 /* compare the output and number of observations read */

 /* original program with WHERE and subsetting IF      */
data work.auemps;
    set orion.sales;
    where Country='AU';
    Bonus=Salary*.10;
   if Bonus>=3000;
run;

proc print data=work.auemps;
    var First_Name Last_Name Salary Bonus;
run;

 /* modified program with only a subsetting IF         */
data work.auemps;
    set orion.sales;
    Bonus=Salary*.10;
   if Country='AU' and Bonus>=3000;
run;

proc print data=work.auemps;
    var First_Name Last_Name Salary Bonus;
run;
```

**Using the `LABEL` Statement and Defining Permanent Labels**
The `LABEL` statement assigns descriptive labels to variables. Use a `LABEL` statement in a `DATA` step to permanently assign labels to variables. The labels are stored in the descriptor portion of the data set.
```
data work.subset1;
    set orion.sales;
    where Country = 'AU' and
          Job_Title contains 'Rep';
    Bonus = Salary * 0.10;
    label Job_Title = 'Sales Title'
          Hire_Date = 'Date Hired';
    drop Employee_ID Gender Country Birth_Date;
run;
```

**Displaying Labels**
To use labels in the `PRINT` procedure, use the `LABEL` option in the `PROC PRINT` statement.
```
proc print data=work.subset1 label;
run;
```

**Splitting Labels**
Use the `PROC PRINT SPLIT=` option to split labels across lines based on a split character.
```
proc print data=work.subset1 split=' ';
run;
```

**Using the `FORMAT` Statement**
If you put the `FORMAT` statement in the `DATA` step, then it assigns the format as an attribute to the variable and the format doesn't have to be assigned in the print step.
```
data work.subset1;
    set orion.sales;
    where Country = 'AU' and
          Job_Title contains 'Rep';
    Bonus = Salary * 0.10;
    label Job_Title = 'Sales Title'
          Hire_Date = 'Date Hired';
    format Salary    commax8.
           Bonus     commax8.2
           Hire_Date ddmmyy10.;
    drop Employee_ID Gender Country Birth_Date;
run;
```

**Exercise 4 from page 6-40**
```
data work.increase;
   SET orion.staff;
   WHERE Emp_Hire_Date >= '01JUL2010'd;
   Increase=Salary*0.10;
   NewSalary=Salary+Increase;

   IF Increase > 3000;

   KEEP Employee_ID 
        Emp_Hire_Date
        Salary
        Increase
        NewSalary;

   LABEL Employee_ID   = "Employee ID"
         Emp_Hire_Date = "Hire Date"
         NewSalary     = "New Annual Salary";

   FORMAT Salary NewSalary DOLLAR10.2
          Increase         COMMA5.;
run;

proc print data=work.increase split=" ";
run;
/*
proc contents data=work.increase;
run;
*/
```

**Exercise 5 from page 6-41**
```
data work.delays;
    SET   orion.orders;
    WHERE Delivery_Date > Order_Date + 4 and
          Employee_ID = 99999999;

    Order_Month = month(Order_Date);

    IF   Order_Month = 8;

    KEEP Employee_ID
         Customer_ID
         Order_Date
         Delivery_Date
         Order_Month;

    LABEL Order_Date    = "Date Ordered"
          Delivery_Date = "Date Delivered"
          Order_Month   = "Month Ordered";

    FORMAT Order_Date Delivery_Date MMDDYY10.;
    
run;

PROC CONTENTS data = work.delays;

proc print data=work.delays;
run;
```

**Exercise 6 on page 6-41**
```
data work.bigdonations;
    SET   orion.employee_donations;

    Total   = sum(Qtr1,Qtr2,Qtr3,Qtr4);
    NumQtrs = n(Qtr1,Qtr2,Qtr3,Qtr4);

    DROP   Recipients 
           Paid_By;

    IF     (Total < 50 or NumQtrs ~= 4)
    THEN   DELETE;
run;

proc print data=work.bigdonations;
run;
```

###Chapter 7 - Reading Spreadsheet and Database Data

**Using the SAS/ACCESS `LIBNAME` Statement**

SAS/ACCESS is a separately-licensed product that allows users to read excel files. This does not come with Base SAS. If the bit count of SAS and MS Office are the same, you can use the default SAS/ACCESS engine.
```
libname orionx excel "&path\sales.xls";

LIBNAME libref <engine> "workbook-name" <options>;
```

When the bit counts differ...
```
libname orionx pcfiles path="&path\sales.xls";

LIBNAME libref <engine> <PATH=>"workbook-name" <options>;
```

SAS treats the workbook as a library and each worksheet as a SAS data set.
- A named range might exist for each worksheet.
- Worksheet names end with a dollar sign.
- Names ranges do NOT end with a dollar sign.

To see whether there are named ranges, you can:
```
proc contents data=orionx._all_;
run;
```

**SAS Name Literals**

A SAS name literal is a string within quotation marks, followed by the letter n. SAS name literals permit special characters in data set names.
```
orionx.'Australia$'n
```
Name literals are used for printing, for example
```
libname orionx pcfiles path="&path\sales.xls";

proc print data=orionx.'Australia$'n;
run;
```

**Subsetting Worksheet Data**

```
libname orionx pcfiles path="&path\sales.xls";
proc print data=orionx.'Australia$'n noobs;
    where Job_Title ? 'IV';
    var Employee_ID Last_Name Job_Title Salary;
run;
```

**Disassociating a Libref**

If SAS has a libref assigned to an Excel workbook, the workbook cannot be opened in Excel. To disassociate the libref, use a `LIBNAME` statement with the `CLEAR` option.
```
libname orionx pcfiles path="&path\sales.xls";

/* use the worksheets */

libname orionx clear;
```

Reminder: if you run `proc contents` and don't want to see the metadata, use the `nods` option.

**Creating a SAS Data Set from an Excel File**

This will create work.subset2:
```
libname orionxls excel path= "&PATH\sales.xls";
*options validvarname=v7;       /* Needed for SAS Enterprise Guide */

data work.subset2;
    set orionxls.'Australia$'n;
    where Job_Title contains 'Rep';
    Bonus = Salary*.10;
    keep First_Name Last_Name Salary Bonus Job_Title Hire_Date;
    label Job_Title = 'Sales Title'
          Hire_Date = 'Date Hired';
   format Salary    comma10. 
          Hire_Date mmddyy10.
          Bonus     comma8.2;
run;
```

**Accessing Oracle Databases**
```
libname oralib oracle user=edu001 pw=edu001 path=dbmssrv schema=educ;
```

**Printing an Oracle Table**
```
libname oralib oracle user=edu001 pw=edu001 path=dbmssrv schema=educ;

proc print data=oralib.supervisors;
    where state in ('NY' 'NJ');
run;

libname oracle clear;
```

Creating a SAS Data Set from Oracle is simple:
```
data nynjsup;
    set oralib.supervisors;
    where state in ('NY 'NJ');
run;

proc print data=nynjsup;
run;

libname oralib clear;
```

**Creating an Excel Spreadsheet from SAS**

```
/* delete employees.xls from the data directory if it exists */
libname out pcfiles path="&path\employees.xls";
/* options validvarname=v7; */ /* SAS Enterprise Guide Only */

data out.salesemps;
    length First_Name $ 12 Last_Name $ 18 Job_Title $ 25;
    infile "&path\newemps.csv" dlm=',';
    input First_Name $ Last_Name $ Job_Title $ Salary;
run;
libname out clear;
```

### Chapter 8 - Intro to Reading Raw Data Files

**What are Raw Data Files?**

A raw data file is also known as a flat file.
- They are text files that contain one record per line.
- A record typically contains multiple fields.
- Flat files do not have internal metadata.
- External documentation, known as a record layout, should exist.
- A record layout describes the fields and locations within each record.

**Reading Raw Data Files**

TODO: Learn these for the SAS Base exam?

|Input Style|Used for Reading|
|-----------|----------------|
|Column Input|Standard data in fixed columns|
|Formatted Input|Standard and nonstandard data in fixed columns|
|List Input|Standard and nonstandard data separated by blanks or some other delimiter|

**Standard data** is data that SAS can read without any additional information.
- Character data is always standard.
- Some numeric values are standard and some are not.

**Reading Standard Delimited Data**

Use list input to read delimited raw data files. SAS considers a space to the be default delimiter. Both standard and nonstandard data can be read. Fields must be read sequentially, left to right.

Use `INFILE` and `INPUT` statements in a `DATA` step to read a raw data file.
```
data work.subset;
    infile "&path\sales.csv" dlm=',';
    input Employee_ID 
          First_Name  $ 
          Last_Name   $ 
          Gender      $ 
          Salary       
          Job_Title   $ 
          Country     $;
run;
```

In the above example, there is no `$` after `Employee_ID` because it is a numeric field.

**The `INFILE` Statement identifies the raw data file to be read**

```
INFILE "&path\sales.csv" DLM=',';
INFILE "raw-data-file" <DLM='delimiter'>;
```
- A full path is recommended.
- Using the `&path` macro variable reference makes the program more flexible.
- **Be sure to use double quotation marks when referencing a macro variable within a quoted string (like with &path)**
- The `DLM=` option specifies alternate delimiters. To specify a tab delimiter on Windows or UNIX, type `dlm='09'x`.

**The `INPUT` Statement**

The `INPUT` statement reads the data fields sequentially, left to right. Standard data fields require only a variable name and type. The optional dollar sign indicates a character variable. Default length for **all** variable is eight bytes, regardless of type.


**Compilation Phase**

During compilation, SAS does the following:
- Scans the step for syntax errors
- translates each statement into machine language
- creates an *input buffer* to hold one record at a time from the raw data file
- creates the program data vector (PDV) to hold one observation
- creates the descriptor portion of the output data set


**DATA Step Processing**

It processes one record at a time, as a loop. The loop is:
- Initialize all variables to missing
- Execute INPUT statement -> End of File? -> Next Step, if yes
- if no, Execute other statements
- `OUTPUT` to SAS data set
- `RETURN` to the first step

Execution:
- SAS scans the input buffer until it finds a delimiter.

**The `LENGTH` Statement defines the type and length of a variable**

You must put the `LENGTH` statement before the `INPUT` statement.
```
data work.subset;
    LENGTH First_Name $ 12
           Last_Name  $ 18
           Gender     $  1
           Job_Title  $ 25
           Country    $  2;
    
    INFILE "&path\sales.csv" dlm = ",';
 
    INPUT  Employee_ID
           First_Name  $
           Last_name   $
           Gender      $
           Salary
           Job_Title   $
           Country     $;
run;
```

The `LENGTH` statement identifies the character variables, so dollar signs can be omitted from the `INPUT` statement.

```
data work.subset;
    LENGTH First_Name $ 12
           Last_Name  $ 18
           Gender     $  1
           Job_Title  $ 25
           Country    $  2;
    
    INFILE "&path\sales.csv" dlm = ",';
 
    INPUT  Employee_ID
           First_Name
           Last_name
           Gender
           Salary
           Job_Title
           Country;
run;
```

The name, type, and length of a variable are determined at the variable's first use. These specifications can be in a `LENGTH` statement or the `INPUT` statement, whichever appears first in the DATA step. The name is used exactly as specified at first use, including the case. It looks like the following:
```
data work.subset;
    
    INFILE "&path\sales.csv" dlm = ",';
 
    INPUT  Employee_ID
           First_Name  :$12.
           Last_name   :$18.
           Gender      :$1.
           Salary
           Job_Title   :$25.
           Country     :$2.;
run;
```

If you want to display the variables in creation order:
```
proc contents data=work.subset varnum;
run;
```

**Reading a Raw Data File with Data Errors**

In this example, Salary is defined as numeric and Country as Character. You get a data error for trying to put a character value into a numeric fields, but you will not get a data error for trying to put a numeric value into a character field. The log will show exactly where the errors are:
- A note describing the error
- a column ruler
- the input record
- the contents of the PDV
- A missing value is assigned to the corresponding variable and execution continues.

Two temporary variables are created during the processing of every DATA step:
- `_N_` is the DATA step iteration counter.
- `_ERROR_` indicates data error status. 0 indicates that no data error occurred on that record. 1 indicates that one **or more** errors occurred on that record.
- `_ERROR_` is reset to 0 and `_N_` is incremented by 1 at the beginning of each iteration.

You can set `options errors=20;`, or whatever you want to see in the log with regards to errors.

**Exercise 1 from page 8-34**
```
DATA work.newemployees;
    LENGTH First $ 12
           Last  $ 18
           Title $ 25;
           
    INFILE "&path\newemps.csv" 
           DELIMITER = ',' 
           LRECL     = 5000;
           
    INPUT First $
          Last  $
          Title $
          Salary;
RUN;
    
```

This is the same with different syntax:
```
DATA work.newemployees;
    INFILE "&path\newemps.csv"
           DELIMITER = ','
           LRECL     = 5000;
    
    INPUT First :$12.
          Last  :$18.
          Title :$25.
          Salary;
RUN;
```

`LRECL` specifies the default logical record length to use for reading and writing external files.

**Exercise 2 on page 8-35**
```
TODO: add solution
```

**Exercise 3 on page 8-36**
```
DATA work.managers2;
    LENGTH IDNum $6;
    INFILE "&pathmanagers2.dat" DLM = '09'x; /* Tab delimiter */
    INPUT  ID First $ Last $ Gender $ Salary Title $;
    KEEP   First Last Title;
RUN;
```

The language processor will not look inside of single quotes for macro variables. It only will look inside of double quotes.

**Reading Nonstandard Data**

**Using `MODIFIED LIST` Input**

The DATA step uses modified list input. Instead of a `LENGTH` statement, an informat specifies the length for each character variable.

```
/* input variable <:informat.>...; */

data work.subset;
    INFILE "&pathsales.csv" DLM = ',';
    INPUT  Employee_ID
           First_Name :$12.
           Last_Name  :$18.
           Gender     :$1.
           Salary
           Job_Title  :$25.
           Country    :$2.;
run;
```

Omitting the colon modifier causes unexpected results.

An informat is **required** to read nonstandard numeric data. An informat is an instruction that SAS uses to read data values into a variable. The informat describes the data value and tells SAS how to convert it.

`<$><informat><w>.`

|   |                               |
|---|-------------------------------|
|`$`|Indicates a character informat.|
|*informat*|Names the SAS informat or user-defined informat|
|`w`|Specifies the width or number of columns to read or specifies the length of a character variable|
|`.`|Is required syntax|

*The width is typically not used with list input because SAS will read each field until it encounters a delimiter.*

|Informat|Definition|
|--------|----------|
|`COMMA.` `DOLLAR.`|Reads nonstandard numeric data and removes embedded commas, blanks, dollar signs, percent signs, and dashes.|
|`COMMAX.` `DOLLARX.`|Reads nonstandard numeric data and removes embedded non-numeric characters; reverses the roles of the decimal point and the comma.|
|`EUROX.`|Reads nonstandard numeric data and removes embedded non-numeric characters in European currency.|
|`$CHAR.`|Reads character values and preserves leading blanks.|
|`$UPCASE.`|Reads character values and converts them to uppercase.|


|Informat|Raw Data Values|SAS Data Value|
|--------|---------------|--------------|
|`MMDDYY.`|010160 or 01/01/60 or 01/01/1960 or 1/1/1960|0|
|`DDMMYY.`|311260 or 31/12/60 or 31/12/1960|365|
|`DATE.`|31DEC59 or 31DEC1959|-1|

The colon format modifier `:` tells SAS to read until it encounters a delimiter.

```
INPUT Employee_ID 
      First_Name :$12.
      Last_Name  :$18.
      Gender     :$1.
      Salary
      Job_Title  :$25.
      Country    :$2.
      Birth_Date :DATE.
      Hire_Date  :MMDDYY.;
```

Additional SAS Statements can be added to perform further processing in the DATA step.
```
DATA work.sales;
    INFILE "&path\sales.csv" dlm = ',';

    INPUT Employee_ID 
      First_Name :$12.
      Last_Name  :$18.
      Gender     :$1.
      Salary
      Job_Title  :$25.
      Country    :$2.
      Birth_Date :DATE.
      Hire_Date  :MMDDYY.;

    IF Country = 'AU';

    KEEP First_Name
         Last_Name
         Salary
         Job_Title
         Hire_Date;

    LABEL Job_Title = 'Sales Title'
          Hire_Date = 'Date Hired'

    FORMAT Salary    DOLLAR12.
           Hire_Date MONYY7.;
RUN;
```

**Using `WHERE` versus Subsetting `IF` Statement**

|Step and Usage|`WHERE`|`IF`|
|--------------|-------|----|
|**PROC** step|Yes|No|
|**DATA** step (source of variable)| | |
|--SET statement|Yes|Yes|
|--assignment statement|No|Yes|
|--INPUT statement|No|Yes|

For consistency, consider using a colon everywhere.

**Using the DATALINES statement**

The `DATALINES` statement supplies data within a program. You also can use `CARDS` interchangeably.
```
/* This DATA step uses the DATALINES statement 
    to provide instream directly in the DATA step.
    The INPUT statement to reads this instream data 
    instead of reading data from an external file.        */

data work.newemps;
   INPUT First_Name :$ 
         Last_Name  :$  
         Job_Title  :$ 
         Salary     :dollar8.;
   DATALINES;
Steven Worton Auditor $40,450
Merle Hieds Trainee $24,025
Marta Bamberger Manager $32,000
;

proc print data=work.newemps;
run;
```

**Exercise 4 on page 8-51**

```
data work.canada_customers;
    INFILE "&path\custca.csv" DLM = ',';

    INPUT First     :$12.
          Last      :$20.
          ID
          Gender    :$1.
          BirthDate :DDMMYY.
          Age       :
          AgeGroup  :$12.;

    FORMAT BirthDate DATE7.;

    DROP ID
         Age;
run;

proc print data=work.canada_customers;
    VAR First
        Last
        Gender
        AgeGroup
        BirthDate;
run;

```

**Exercise 5 on page 8-52**

```
DATA work.prices;
    INFILE "&path\pricing.dat" DLM = '*';

    INPUT ProductID  :$12.
          StartDate  :DATE.
          EndDate    :DATE.
          Cost       :DOLLAR.
          SalesPrice :DOLLAR.;

    FORMAT SalesPrice 5.2
           StartDate  MMDDYY10.
           EndDate    MMDDYY10.;
RUN;

PROC PRINT data=work.prices;
RUN;
```

**To output to a text file**

```
DATA _null_;
    SET  orion.country;

    FILE "&path\country.dat" dsd; /* Changes delimiter and deals with double quotes */

    PUT  country 
         country_name 
         population 
         country_id 
         continent_id;
RUN;
```

#####Handling Missing Data

**The `DSD` Option for Reading Values**

In the example, missing values are indicated by consecutive delimiters.

```
DATA work.contacts;
    LENGTH Name $ 20
           Phone
           Mobile $ 14;

    INFILE "&\path\phone2.csv" DSD;

    INPUT  Name   $
           Phone  $
           Mobile $;
RUN;

PROC PRINT DATA = work.contacts;
RUN;
```

The DSD option in the INFILE statement does the following:

- Sets the default delimiter to a comma
- Treats consecutive delimiters as missing values
- Enables SAS to read values with embedded delimiters if the value is surrounded by quotation marks

**Using the `MISSOVER` Option**

The `MISSOVER` option prevents SAS from loading a new record when the end of the current record is reached. (The `DSD` option is not appropriate because the missing data is not marked by consecutive delimiters.) You can specify multiple at the same time: `DLM = '*' DSD MISSOVER`. DLM overrides the comma that the DSD sets.

```
DATA work.contacts;
    LENGTH Name $ 20
           Phone
           Mobile $ 14;

    INFILE "&\path\phone2.csv" 
      DLM = ',' 
      MISSOVER;

    INPUT  Name   $
           Phone  $
           Mobile $;
RUN;

PROC PRINT DATA = work.contacts;
RUN;
```

**Exercise 7 from page 8-60**

```
DATA work.donations;
    INFILE "&path\donation.csv" DSD;
    INPUT EmpID
          Q1
          Q2
          Q3
          Q4;
RUN;

PROC PRINT data=work.donations;
RUN;
```

**Exercise 8 from page 8-61**

```
DATA work.prices;
    INFILE "&path\prices.dat" 
      DLM = '*' 
      DSD 
      MISSOVER;

    INPUT ProductID      :12.
          StartDate      :DATE.
          EndDate        :DATE.
          UnitCostPrice  :DOLLAR.
          UnitSalesPrice :DOLLAR.;

    FORMAT StartDate      MMDDYY10.
           EndDate        MMDDYY10.
           UnitCostPrice  7.2
           UnitSalesPrice 7.2;

    LABEL ProductID      = "Product ID"
          StartDate      = "Start of Date Range"
          EndDate        = "End of Date Range"
          UnitCostPrice  = "Cost Price per Unit"
          UnitSalesPrice = "Sales Price per Unit";

RUN;

proc print data=work.prices label;
run;
```

**Exercise 9 from page 8-62**

```
DATA work.salesmgmt;
    LENGTH First 
           Last   $ 12 
           Gender $ 1 
           Title  $ 25 
           Country $ 2;

    FORMAT BirthDate date9.
           HireDate  date9.;

    INFILE "&path\managers.dat" 
      DSD 
      DLM = '/' 
      MISSOVER;

    INPUT ID 
          First 
          Last 
          Gender 
          Salary 
          Title 
          Country 
          BirthDate :DATE.. 
          HireDate :MMDDYY.;
run;

TITLE 'Orion Star Managers';

PROC PRINT DATA = work.salesmgmt;
    VAR ID 
        Last 
        Title 
        HireDate 
        Salary ;
run;

TITLE;
```

Reminder: The `LENGTH` statement must go before the `INPUT` statement.
Reminder: `WHERE` cannot be used in a DATA step that specifies raw data. It CAN be used if the DATA step specifies a SAS file.

###Chapter 9 - Manipulating Data

SAS functions can be used in an assignment statement. A function is a routine that accepts arguments and returns a value. Some functions manipulate character values, compute descriptive statistics, or manipulate SAS date values. 

- Arguments are enclosed in parenthesis and separated by commas.
- A function can return a numeric or character result.

**The `SUM` Function**

Missing values are ignored by `SUM` and other descriptive statistics functions.

```
Compensation = sum(Salary,Bonus);
```

- The arguments must be numeric
- Missing values are ignored by `SUM` and other descriptive statistics functions.

**The `MONTH` Function**

```
BonusMonth = month(Hire_Date);
```

- Extracts the month from SAS date values


Other Date functions:

```
/* Extract information *?
YEAR(SAS-date)
QTR(SAS-date)
MONTH(SAS-date)
DAY(SAS-date)
WEEKDAY(SAS-date)

/* Create SAS Dates */
TODAY()
DATE()
MDY(month,day,year)
```

Example of using SAS Functions:
```
DATA work.comp;
    SET orion.sales;
    Bonus        = 500;
    Compensation = SUM(Salary,Bonus);
    BonusMonth   = MONTH(Hire_Date)
RUN;
```

**Exercise 1 on page 9-10**

```
data work.increase;
   SET orion.staff;

   Increase  = Salary * 0.10;
   NewSalary = Salary + Increase;
   BdayQtr   = QTR(Birth_Date);

   KEEP Employee_ID 
        Salary 
        Birth_Date
        Increase
        NewSalary
        BdayQtr;

   FORMAT Salary    COMMA10.
          Increase  COMMA10.
          NewSalary COMMA10.;

   LABEL Employee_ID = "Employee ID"
         Salary      = "Employee Annual Salary"
         Birth_Date  = "Employee Birth Date"
         BdayQtr     = "Bday Qtr";
run;

proc print data=work.increase LABEL;
run;
```

**Exercise 2 on page 9-11**

```
DATA work.birthday;
    SET orion.customer;

    /* Create Variables */
    Bday2012    = MDY(MONTH(Birth_Date),DAY(Birth_Date),2012);
    BdayDOW2012 = WEEKDAY(Bday2012);
    Age2012     = (Bday2012 - Birth_Date) / 365.25;

    KEEP Customer_Name
         Birth_Date
         Bday2012
         BdayDOW2012
         Age2012;

    FORMAT Bday2012 DATE9.
           Age2012  3.0;
RUN;

PROC PRINT DATA = work.birthday;
RUN;
```


**Exercise 3 on page 9-12**

```
data work.employees;
   SET orion.sales;

   FullName = catx(' ',First_Name,Last_Name);
   Yrs2012  = intck('year',Hire_Date,'01JAN2012'd);

   FORMAT Hire_Date DDMMYY10.;
   LABEL  Yrs2012 = 'Years of Employment in 2012';
run;

proc print data=work.employees label;
   var FullName Hire_Date Yrs2012;
run;
```

#####Conditional Processing

```
DATA work.comp;
    SET orion.sales;

    IF   Job_Title = 'Sales Rep. IV'
    THEN Bonus = 1000;

RUN;
```

In the above example, Bonus is created at compile time and will be there regardless of whether any of the Job_Titles meet the condition.

You can replace variable values as well as creating new ones:

```
DATA work.comp;
    SET orion.sales;

    IF   Job_Title = 'Sales Rep. IV'
    THEN Job_Title = 'Sales Rep. V';
    
RUN;
```

You also can use `ELSE` and `ELSE IF` statements:

```
data work.comp;
    set orion.sales;
    if Job_Title='Sales Rep. IV'             then Bonus=1000;
    else if Job_Title='Sales Manager'        then Bonus=1500;
    else if Job_Title='Senior Sales Manager' then Bonus=2000;
    else if Job_Title='Chief Sales Officer'  then Bonus=2500;
    else Bonus = 500;
run;

proc print data=work.comp;
    var Last_Name Job_Title Bonus;
run;
```

**Using `UPCASE` to clean data**

If you want to temporarily UPCASE a value in order to run a conditional check:
```
...
if Country = UPCASE(Country) then ...;
...
```

Clean data as early as possible.

You also can test using this type of approach:
```
...
if Country in ('US', 'us') then ...;
...
```

**Using a `DO` Group to put multiple statements in a conditional**

Each `DO` group ends with an `END` statement.
```
DATA work.bonus;
    SET orion.sales;

    IF  Country = 'US'
      THEN DO;
        Bonus = 500;
        Freq  = "Once a Year";
      END;
    ELSE IF Country = "AU"
      THEN DO;
        Bonus = 300;
        Freq  = "Twice a Year";
      END;

RUN;
```

When the variable `Freq` is created, it is created with the first length passed to it. In this case, it is set to the length of "Once a Year" and then there is truncation on "Twice a Year". To address this, you can use a `LENGTH` statement.

```
DATA work.bonus;
    SET orion.sales;

    LENGTH Freq $ 12;

    IF  Country = 'US'
      THEN DO;
        Bonus = 500;
        Freq  = "Once a Year";
      END;
    ELSE IF Country = "AU"
      THEN DO;
        Bonus = 300;
        Freq  = "Twice a Year";
      END;

RUN;
```

**Exercise 4 on page 9-37**

```
DATA work.ordertype;
    SET orion.orders;
    
    LENGTH Method $ 15;

    SELECT (Order_Type);
        WHEN (1)  Method = "Retail";
        WHEN (2)  Method = "Catalog";
        WHEN (3)  Method = "Internet";
        OTHERWISE Method = "Unknown";
    END;


RUN;

PROC PRINT data=work.ordertype;
    VAR  Order_ID
         Order_Type
         Method;
RUN;

```

**Exercise 5 on page 9-38**

```
data work.region;
   SET orion.supplier;

   LENGTH DiscountType $ 15
          Region       $ 20;

   IF     UPCASE(Country) = "CA" or 
          UPCASE(Country) = "US"
   THEN   
     DO;
          Discount     = 0.10;
          DiscountType = "Required";
          Region       = "North America";
     END;

   ELSE
     DO;
          Discount     = 0.05;
          DiscountType = "Optional";
          Region       = "Not North America";
     END;
   
   KEEP   Supplier_Name
          Country
          Discount
          DiscountType
          Region;

   LABEL DiscountType = "Discount Type";

RUN;

proc print data=work.region LABEL;
    VAR Supplier_Name
        Country
        Region
        Discount
        DiscountType;
run;

```

*This is where you find the quizzes online*
http://support.sas.com/training/us/crs/quiz/prg1

####Chapter 10 - Combining Data Sets

**Using a `SET` Statement**

Use a `DATA` step to concatenate the data sets. List the data sets in the SET statement:
```
DATA empsall1;
    SET empsdk empsfr;
RUN;
```

- The `SET` Statement reads observations from each data set in the order in which they are listed
- Any number of data sets can be included in the `SET` statement.
- The Program Data Vector (PDV) is initialized at the beginning of each data set.

If you concatenate two data sets that have different variables, your output will have all of the variables that exist in all of the data sets. If you have one field called "Country" and one called "Region", you can rename one of them to match the other. Example:

```
DATA empsall2;
    SET empscn
        empsjp(RENAME=(Region=Country));
RUN;
```

If you need to rename more than one variable:

```
DATA empsall2;
    SET empscn
        empsjp(RENAME = (Region = Country
                         Land   = Continent));
RUN;
```

**Exercise 1 on page 10-23**

```
DATA work.thirdqtr;
    SET orion.mnth7_2011
        orion.mnth8_2011
        orion.mnth9_2011;
RUN;

PROC PRINT DATA = work.thirdqtr;
    VAR Order_ID
        Order_Type
        Employee_ID
        Customer_ID
        Order_Date
        Delivery_Date;
RUN;
```

**Exercise 2 on page 10-23**

```
proc contents data=orion.sales;
run;

proc contents data=orion.nonsales;
run;

DATA work.allemployees;
    SET orion.sales
        orion.nonsales(RENAME=(
                                First = First_Name
                                Last  = Last_Name
                                ));
RUN;

PROC PRINT DATA = work.allemployees;
RUN;
```

Be careful to make sure that the program attributes match. If there are character variables of different lengths, include the longest one first, or use a `LENGTH` statement.

####Merging Data Sets One-To-One

We must sort the data by the key variables before we can perform the merge.

**Match-Merging one-to-one**

The `MERGE` statement in a DATA step joins observations from two or more SAS data sets into single observations.

```
DATA empsauh;
    MERGE empsau phoneh;
    BY EmpID;
RUN;
```

A `BY` statement indicates a match-merge and lists the variable or variables to match. Requirements:

- Two or more data sets are listed in the `MERGE` statement
- The variables in the `BY` statemtn must be common to all data sets
- The data sets must be sorted by the variables listed in the `BY` statement

**One-To-Many Merging**

In this case, the data is sorted and each employee has one or more phones. The tables still must be sorted first.

```
DATA empphones;
    MERGE empsau phones;
    BY    empID; /* called the by value */
run;
```

"The rule of first occurrence..."

The program data vector reinitializes when it is finished with one of the key values, but prior to that, it doesn't reinitialize, but only replaces values (minimizing the amount of data moving around). After reinitializing, it reads from both data sets to repopulate the PDV.

**Exercise 4 on page 10-47**

```
proc contents data=orion.orders;
run;

proc contents data=orion.order_item;
run;

/* order_id */

DATA work.allorders;
    MERGE orion.orders
          orion.order_item;
    BY    Order_ID;
RUN;

PROC PRINT DATA = work.allorders NOOBS;
    WHERE QTR(Order_Date)  = 4 AND
          YEAR(Order_Date) = 2011;

    VAR   Order_ID
          Order_Date
          Order_Item_Num
          Quantity
          Total_Retail_Price;
RUN;
```

**Exercise 5 on page 10-48**

```
PROC SORT DATA = orion.product_list
          OUT  = work.product_list;
    BY    Product_Level;
RUN;

DATA work.listlevel;
    MERGE orion.product_level 
          work.product_list;

    BY    Product_Level;

    KEEP  Product_ID
          Product_Name
          Product_Level
          Product_Level_Name;
RUN;

PROC PRINT DATA = work.listlevel NOOBS;
    WHERE Product_Level = 3;
RUN;

```

####Merging Data Sets with Non-Matches

By default, you get the non-matches in the output data set, too.

```
DATA empsauc;
    MERGE empsau
          phonec;

    BY    EmpID;
RUN;
```

For the non-matching records, they appear in the output with missing values in the fields from the other table. This is because the PDV only is populated by the table with the value.

**The `IN=` Data Set Option**

The `IN=` data set option creates a variable that indicates whether the data set contributed to building the current observation.
```
MERGE SAS-data-set (IN = variable) ...
```
`variable` is a temporary numeric variable that has two possible values:

- `0`: Indicates that the data set did **not** contribute to the current observation
- `1`: Indicates that the data set **did** contribute to the current observation

```
DATA empsauc;
    MERGE empsau (IN = Emps)
          phonec (IN = Cell);

    BY    EmpID;
RUN;
```

The variables created with the `IN=` data set option are only availabe during DATA step execution. 

- They are not written to the SAS data set
- Their value can be tested using conditional logic

**Matches ONLY**

Add a subsetting `IF` statement to select the employees that have company phones.
```
DATA empsauc;
    MERGE empsau (IN = Emps)
          phonec (IN = Cell);

    BY    EmpID;

    IF    Emps = 1 AND
          Cell = 1;

RUN;
```

**Finding Non-Matches**

Select the employees that do not have company phones...
```
DATA empsauc;
    MERGE empsau (IN = Emps)
          phonec (IN = Cell);

    BY    EmpID;

    IF    Emps = 1 AND
          Cell = 0;

RUN;
```

Select the phones associated with an invalid Employee ID...
```
DATA empsauc;
    MERGE empsau (IN = Emps)
          phonec (IN = Cell);

    BY    EmpID;

    IF    Emps = 0 AND
          Cell = 1;

RUN;
```

This will find all non-matches (using an `OR` instead of an `AND` operator)...
```
DATA empsauc;
    MERGE empsau (IN = Emps)
          phonec (IN = Cell);

    BY    EmpID;

    IF    Emps = 0 OR
          Cell = 0;

RUN;
```

You can use a shorthand: `IF Emps OR Cell` or `IF NOT Emps OR NOT Cell' for example.
```
DATA empsauc;
    MERGE empsau (IN = inEmps)
          phonec (IN = inCell);

    BY    EmpID;

    IF    NOT inEmps AND inCell;

RUN;
```

In the event that you want to merge and subset on a variable that is not in each table, use the subsetting if instead of the `WHERE` statement. This will work.
```
PROC SORT DATA = orion.customer
          OUT  = cust_by_type;
    BY Customer_Type_ID;
RUN;

DATA customers;
    MERGE cust_by_type
          orion.customer_type;

    BY    Customer_Type_ID;

    IF    Country = 'US';
RUN;

```

**Exercise 7 on page 10-72**

```
proc sort data=orion.product_list
          out=work.product;
    by Supplier_ID;
run;

DATA work.prodsup;
    MERGE work.product   (IN = inProd)
          orion.supplier (IN = inSupp);

    BY    Supplier_ID;

    IF    inProd AND NOT inSupp;
RUN;

proc print data=work.prodsup;
    var Product_ID Product_Name Supplier_ID Supplier_Name;
run;
```

**Exercise 8 on page 10-72**
```
PROC SORT DATA = orion.customer
          OUT  = work.customer;
    BY Country;
RUN;

/*
PROC CONTENTS DATA = work.customer;
RUN;

PROC CONTENTS DATA = orion.lookup_country;
RUN;
*/

DATA work.allcustomer;
    MERGE orion.lookup_country (RENAME = (START = Country
                                          Label = Country_Name)
                                IN = inLook)
          work.customer        (IN = inCust);
    BY    Country;
    KEEP  Customer_ID
          Country
          Customer_Name
          Country_Name;
    IF    inLook AND inCust;
RUN;

PROC PRINT DATA = work.allcustomer;
RUN;
```

**Exercise 9 on page 10-73**

You can include multiple outputs in a DATA step. It's a good idea to have logic that determines which records go into which of the output data sets. SAS provided solution:

```
proc sort data=orion.orders
           out=work.orders;
    by Employee_ID;
run;

data work.allorders work.noorders;
   merge orion.staff(in=Staff) work.orders(in=Ord);
   by Employee_ID;
   if Ord=1 then output work.allorders;
   else if Staff=1 and Ord=0 then output work.noorders;
  /* alternate statement */
  /* else output work.noorders; */
   keep Employee_ID Job_Title Gender Order_ID Order_Type Order_Date;
run;

proc print data=work.allorders;
run;

proc print data=work.noorders;
run;
```

###Chapter 11 - Creating Summary Reports

**The `FREQ` Procedure**

Use the `FREQ` procedure to analyze variables. The `FREQ` procedure produces a one-way frequency table for each variable named in the TABLES statement.

```
PROC FREQ DATA = orion.sales;
    TABLES Gender;
    WHERE  Country = 'AU';
RUN;
```
If the `TABLES` statement is omitted, a one-way frequency table is produced for EVERY variable in the data set. This can produce voluminous output and is seldom desired. The procedure can compute the following:

- chi-square tests for one-way to n-way tables
- tests and measures of agreement for contingency tables
- tests and measures of association for contingency tables and more

Use options in `TABLES` to suppress the display of selected default statistics.

```
TABLES variable(s) / options;
```

|Option|Description|
|------|-----------|
|`NOCUM`|Suppresses the cumulative statistics|
|`NOPERCENT`|Suppresses the percentage display|

Cumulative frequencies and percentages are useful when there are at least three levels of a variable in an ordinal relationship. When this is not the case, the NOCUM option produces a simpler, less confusing report.

**The `BY` Statement**

The `BY` Statement is used to request separate analyses for each `BY` group.
```
PROC SORT DATA = orion.sales 
          OUT  = sorted;
    BY Country;
RUN;

PROC FREQ DATA = sorted;
    TABLES Gender;
    BY     Country;
RUN;
```

**Crosstabulation Table**

An asterisk between two variables generates a two-way frequency table, or crosstabulation table. A two-way frequency table generates a single table with statistics for each distinct combination of values of the selected variables.

```
PROC FREQ DATA = orion.sales;
    TABLES Gender*Country;
RUN;
```
Options to Suppress Statistics:

|Option|Description|
|------|-----------|
|`NOROW`|Suppresses the display of the row percentage|
|`NOCOL`|Suppresses the display of the column percentage|
|`NOPERCENT`|Suppresses the percentage display|
|`NOFREQ`|Suppresses the frequency display|


You can use the `LIST` and `CROSSLIST` Options in the `TABLES` statement to "flatten" the output.

**Using the `FREQ` Procedure for Data Validation**

The `FREQ` procedure lists all discrete values for a variable and reports missing values.

```
PROC FREQ DATA = orion.nonsales2;
    TABLES Gender COUNTRY / NOCUM NOPERCENT;
RUN;
```

**The `NLEVELS` Option**

The `NLEVELS option displays a table that provides the number of distinct values for each analysis variable.
```
PROC FREQ DATA = orion.nonsales2 NLEVELS;
    TABLES Gender COUNTRY / NOCUM NOPERCENT;
RUN;
```

**Check for Uniqueness**

The `ORDER = FREQ` option displays the results in descending frequency order
```
PROC FREQ DATA = orion.nonsales2 ORDER = FREQ;
    TABLES Gender COUNTRY / NOCUM NOPERCENT;
RUN;
```

You can use `NLEVELS` to identify duplicates when the number of distinct values is known.
```
PROC FREQ DATA = orion.nonsales2 NLEVELS;
    TABLES Employee_ID / NOPRINT;
RUN;
```

**Idendifying Observations with Invalid Data**

This builds on the example in the slides.

```
PROC PRINT DATA = orion.nonsales2;
    WHERE Gender      NOT IN ('F', 'M')   OR
          Country     NOT IN ('AU', 'US') OR
          Job_Title   IS NULL             OR
          Employee_ID IS MISSING          OR
          Employee_ID = 120108;
RUN;
```

**Using Formats in `PROC FREQ` to group**

A `FORMAT` statement can also be used in `PROC FREQ` to group the data.
```
PROC FREQ DATA = orion.sales;
    TABLES Hire_Date / NOCUM;
    FORMAT HIRE_Date YEAR4.;
RUN;
```

If a format is permanently assigned to a variable, `PROC FREQ` automatically groups the report by the formatted values.

Use defined formats can also be used to display levels with alternate text in a frequency table.
```
PROC FREQ DATA = orion.sales;
    TABLES Gender*Country;
    FORMAT Country $ctryfmt.
           Gender  $gender.;
RUN;
```

**The `FORMAT=` option**

Use the `FORMAT=` option in the TABLES statement to format the frequence value and to change the width of the column.

```
PROC FREQ DATA = orion.sales;
    TABLES Gender*Country / FORMAT = 12.;
    FORMAT Country $ctryfmt.
           Gender  $gender.;
RUN;
```

NOTE: This automatically clears the log:
```
DM LOG 'clear' OUTPUT;
```

####The MEANS and UNIVARIATE Procedures

**The `MEANS` procedure produces summary reports with descriptive statistics.

```
PROC MEANS DATA = orion.sales;
RUN;
```

- Analysis variables are the numeric variables for which statistics are to be computed.
- Classification variables are the variables whose values define subgroups for the analysis. They can be character or numeric.

The `VAR` Statement identifies the analysis variable (or variables) and their order in the output
```
PROC MEANS DATA = orion.sales;
    VAR Salary;
RUN;
```

The `CLASS` statement identifies variables whose values define subgroups for the analysis
```
PROC MEANS DATA = orion.sales;
    VAR   Salary;
    CLASS Gender Country;
RUN;
```

- Classification variables typically have few discrete values.
- The data set does NOT need to be sorted or indexed by the classification variables.

- N Obs - the number of observations with each unique combination of class variables
- N - the number of observations with **nonmissing** values of the analysis variable (or variables)

Use options in the `PROC MEANS` statement to request specific statistics
```
PROC MEANS DATA = orion.sales NMISS MIN MAX SUM;
    VAR Salary;
    CLASS Gender COUNTRY;
RUN;
```

The requested statistics override the defaults.

`PROC MEANS` Statement Options

|Option|Desc|
|------|----|
|`MAXDEC=`|Specifies the number of decimal places to display.|
|`NONOBS`|Suppresses the N Obs column|

Other statistics keywords:
```
CLM
CSS
```
TODO: Fill in table from page 11-35...

**The `UNIVARIATE` Procedure**

`PROC UNIVARIATE` displays extreme observations, missing values, and other statistics for the variables included in teh VAR statement.

```
PROC UNIVARIATE DATA = orion.nonsales2;
    VAR Salary;
RUN;
```

If the VAR statement is omitted, `PROC UNIVARIATE` analyses all numeric variables in the data set.

The `NEXTROBS=` option specifies the number of extreme observations to display.

The `ID` statement displays the value of teh identifying variable in addition to the observation number.

####Using the Output Delivery System (ODS)

Once you open an output destination, all output will go to it until it is closed.

```
ODS PDF FILE = "&path\example.pdf";
ODS RTF FILE = "&path\example.rtf";

PROC FREQ DATA = orion.sales;
    TABLES Country;
RUN;

ODS _all_ CLOSE;
```

If you close all destinations, it also will close the text listing destination.

To view the styles available for the destination:
```
PROC TEMPLATE;
    LIST STYLES;
RUN;
```

**Destinations used with Excel**

```
CSVALL           /* Standard CSV file */
MSOFFICE2K       /* HTML file that Word, Excel, or a browser can open */
TAGSETS.EXCELXP  /* For xml that Excel can open */
```


