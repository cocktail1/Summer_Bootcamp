## SAS Programming 2

**Controlling Input and Output**

Remember that there is an implicit `OUTPUT` and `RETURN` at the end of a `DATA` step.

You can use an explicit `OUTPUT` statement to override the implicit statement.

**Explicit Output**

```
DATA forecast;
    set orion.growth;
    Year = 1;
    Total_Employees = Total_Employees * (1 + Increase);
    OUTPUT; /* This statement writes the PDV to the output table; OUTPUT the current observation */

    /* From here, it overwrites the values in the PDV and then outputs another observation */
    /* Year is reinitialized in this second iteration */
    Year = 2;
    Total_Employees = Total_Employees * (1 + Increase);
    OUTPUT;
RUN;
```

When you use an explicit output, the implicit output no longer is called at the end of the DATA block. When the program data vector is reinitialized, the values of variables created by the assignment statement are set to missing. Variables that you read with a `SET` statement are not set to missing because they are overwritten when the next observation is read.

**2.03 Quiz**

```
DATA forecast;
   SET orion.growth;
   Year=1;
   Total_Employees=Total_Employees*(1+Increase);
   * OUTPUT;

   Year=2;
   Total_Employees=Total_Employees*(1+Increase);
   OUTPUT;
RUN;

PROC PRINT DATA = forecast NOOBS;
   VAR Department Total_Employees Year;
RUN;


* Alternate Solution
DATA forecast;
   SET orion.growth;
   Total_Employees=Total_Employees*(1+Increase);
   Total_Employees=Total_Employees*(1+Increase);
   Year=2;
   OUTPUT;
RUN;
```
produces this report:

```
                                                   Total_
                             Department          Employees    Year

                             Administration        53.125       2
                             Engineering           15.210       2
                             IS                    30.250       2
                             Marketing             28.800       2
                             Sales                339.690       2
                             Sales Management      13.310       2
```

**Exercise 1: Writing Observations Explicitly on page 2-15**

```
DATA price_increase;
    SET orion.prices;
    Year = 1;
    Unit_Price = Unit_Price * Factor;
    OUTPUT;

    Year = 2;
    Unit_Price = Unit_Price * Factor;
    OUTPUT;

    Year = 3;
    Unit_Price = Unit_Price * Factor;
    OUTPUT;
RUN;

PROC PRINT DATA = price_increase;
    VAR Product_ID
        Unit_Price
        Year;
RUN;
```

**Exercise 2: Writing Observations Explicitly**

```
DATA work.extended;
    SET     orion.discount;
    DROP    Unit_Sales_Price;

    WHERE Start_Date = MDY(12,1,2011);

    Promotion = "Happy Holidays";
    Season    = "Winter";

    RETAIN Promotion;
    OUTPUT;

    Start_Date = MDY(7,1,2012);
    End_Date   = MDY(7,31,2012);
    Season     = "Summer";
    OUTPUT;

RUN;

PROC PRINT DATA = work.extended;
    VAR Product_ID
        Start_Date
        End_Date
        Discount
        Promotion
        Season;
RUN;
```

**Writing to more than one data set in a single DATA step**

```
DATA usa australia other;
    SET  orion.employee_addresses;

    IF      Country = 'AU' THEN OUTPUT australia;
    ELSE IF Country = 'US' THEN OUTPUT usa;
    ELSE                   THEN OUTPUT other;
RUN;
```

If you do not specify a SAS data set name or the reserved name `_NULL_` in a DATA statement, then SAS reates data sets automatically with the names data1, data2, and so on in the Work library by default.

Data sets names in the OUTPUT statement *must* appear in the DATA statement.
To specify multiple data sets in a single OUTPUT statement, separate the names with a space:
```
OUTPUT data1 data2;
```

Make sure that you sort and then put in the conditional statements so that we don't have to use the additional compare with `IF` statements.

You cannot put multiple data sets in a single `PROC PRINT` statement.

```
/* Use the upcase function to ignore case for Country values */
data usa australia other;
   set orion.employee_addresses;
   if upcase(Country)='US' then output usa;
   else if upcase(Country)='AU' then output australia;
   else output other;
run;

/* Alternate solution - correct the case of Country */
data usa australia other;
   set orion.employee_addresses;
   Country=upcase(country);
   if Country='US' then output usa;
   else if Country='AU' then output australia;
   else output other;
run;

```

**Select Groups**

Here are some examples of using a SELECT group instead of IF statements:

```
  /* Use a Select group for conditional output */

data usa australia other;
   set orion.employee_addresses;
   select (country);
      when ('US') output usa;
      when ('AU') output australia;
      otherwise output other;
   end;
run;

  /* Check for multiple values with SELECT */

data usa australia other;
   set orion.employee_addresses;
   select (country);
      when ('US','us') output usa;
      when ('AU','au') output australia;
      otherwise output other;
   end;
run;

  /* Use UPCASE function with SELECT */

data usa australia other;
   set orion.employee_addresses;
   select (upcase (country));
      when ('US') output usa;
      when ('AU') output australia;
      otherwise output other;
   end;
run;

  /* Use DO-END in a Select group */

data usa australia other;
   set orion.employee_addresses;
   select (upcase(country));
      when ('US') do;
         Benefits=1;
         output usa;
      end;
      when ('AU') do;
         Benefits=2;
         output australia;
      end;
      otherwise do;
         Benefits=0;
         output other;
      end;
   end;
run;
```

If you want the `WHEN` expression to have a condition check, then you use this form, leaving out the `SELECT` statement:

```
/* alternate form of select statement */

data usa australia other;
   set orion.employee_addresses;
   select;
      when (country='US') output usa;
      when (country='AU') output australia;
      otherwise output other;
   end;
run;
```

**Exercise 4: Creating Multiple SAS Data Sets on page 2-26**

```
DATA admin stock purchasing;
    SET orion.employee_organization;

    SELECT (LOWCASE(Department));
        WHEN ('administration')   OUTPUT admin;
        WHEN ('stock & shipping') OUTPUT stock;
        WHEN ('purchasing')       OUTPUT purchasing;
        OTHERWISE;
    END;
RUN;

TITLE "Administration Employees";
PROC PRINT DATA = admin;
RUN;
TITLE;

TITLE "Stock and Shipping Employees";
PROC PRINT DATA = stock;
RUN;
TITLE;

TITLE "Purchasing Employees";
PROC PRINT DATA = purchasing;
RUN;
TITLE;
```

**Exercise 2 on page 2-27**

```
DATA veryslow slow fast;
    SET     orion.orders;
    DROP    Employee_ID;

    WHERE   2 <= Order_Type <= 3;

    ShipDays = Delivery_Date - Order_Date;

    SELECT;
        WHEN (ShipDays < 3)       OUTPUT fast;
        WHEN (5 <= ShipDays <= 7) OUTPUT slow;
        WHEN (ShipDays > 7)       OUTPUT veryslow;
        OTHERWISE;
    END;
RUN;

```

**Selecting Variables and Observations**

Remember to use the `DROP` and `KEEP` statements to determine what you want to have in the data set.

By default, `PROC CONTENTS` will display the variables in alphabetical order. If you use the `VARNUM` option, they will be listed by their position in the data set.

Use the `POSITION` option to see both in alphabetical order and numerical order.

**DROP as a Data Set Option**

This will selectively drop fields per output data set.

```
DATA usa      (DROP = Street_ID Country)
	 australia(DROP = Street_ID State Country)
	 other;

	 SET orion.employee_addresses;

	 IF      Country = 'US' THEN OUTPUT usa;
	 ELSE IF Country = 'AU' THEN OUTPUT australia;
	 ELSE                        OUTPUT other;
RUN;
```

**KEEP as a Data Set Option**

This will selectively keep fields per output data set.

```
DATA usa      (KEEP = Employee_Name City State)
	 australia(DROP = Street_ID State Country)
	 other;

	 SET orion.employee_addresses;

	 IF      Country = 'US' THEN OUTPUT usa;
	 ELSE IF Country = 'AU' THEN OUTPUT australia;
	 ELSE                        OUTPUT other;
RUN;
```


You also can use these as statements in the input data set, to retain those by default:

```
	SET orion.employee_addresses(DROP = x);
	SET orion.employee_addresses(KEEP = x);
```

When a `DROP=` data set option is used in an input data set, the specified variables are not read into the PDV and therefore are **not** available for processing.

When a `KEEP=` data set option is used in an input data set, only the specified variables are read into the PDV and therefore are available for processing.

Dataset options always are closed in parentheses and only affect the data set where they are listed.

**The `WHERE` Data Set Option**

```
DATA work.temp(
               DROP  = Cust_ID
			   WHERE = (State = 'NC')
			   );
```

This is an example of using them in combination:

```
DATA usa 
     australia(DROP=State) 
     other;
   SET orion.employee_addresses(DROP=Street_ID 
                                     Employee_ID);
   DROP Country;

   IF      Country='US' THEN OUTPUT usa;
   ELSE IF Country='AU' THEN OUTPUT australia;
   ELSE                      OUTPUT other;
run;
```

`DROP` is a compile-time statement, so it doesn't matter where you put it in the block (vs. the data set option DROP).

If a `DROP` or `KEEP` statement is used in the same step as a data set option, the statement is applied first.

**Selecting which records are processed**

The `OBS=` data set option causes the DATA step to stop processing after 100 observations.
```
DATA aus
	SET orion.employee_addresses (OBS = 100);
	IF  Country='AU' THEN OUTPUT;
RUN;
```

The `FIRSTOBS=` and `OBS=` data set options cause the `SET` statement below to read 51 observations from orion.employee_addresses. Processing begins with observation 50 and ends after observation 100.

These can be used with `INFILE` for non-SAS data sets.

```
DATA employees;
	INFILE "&pathemps.dat" FIRSTOBS = 11 OBS = 15;
	INPUT  @1 EmpID 8. @9 EmpName $40. @153 Country $2.;
RUN;

PROC PRINT DATA = employees;
RUN;
```

You can use these data set options elsewhere.

```
PROC PRINT DATA = orion.employee_addresses (FIRSTOBS = 10 OBS = 15);
	VAR Employee_Name 
		City 
		State 
		Country;
RUN;
```

When the `FIRSTOBS=` or `OBS=` option and the `WHERE` statement are used together, the following occurs:

- The subsetting `WHERE` is applied **first**. It is a *preprocessor*.
- The `FIRSTOBS=` and `OBS=` options are applied to the resulting observations.


The following includes the `N` frequency count option on PROC PRINT. They will do the same thing.
```
PROC PRINT DATA = orion.employee_addresses (OBS = 10) N;
	WHERE Country = 'AU';
	VAR Employee_Name City Country;
RUN;

PROC PRINT DATA = orion.employee_addresses (OBS = 10 WHERE=(Country = 'AU')) N;
	VAR Employee_Name City Country;
RUN;
```

**Exercise 7: Specifying Variables and Observations from page 2-43**

```
DATA sales(KEEP = Employee_ID Job_Title Manager_ID)
     exec (KEEP = Employee_ID Job_Title);
	SET orion.employee_organization;

	IF      Department = 'Sales'      THEN OUTPUT sales;
	ELSE IF Department = 'Executives' THEN OUTPUT exec;
RUN;

TITLE "Sales Employees";
PROC PRINT DATA = sales(OBS=6);
RUN;
TITLE;

TITLE "Executives";
PROC PRINT DATA = exec(FIRSTOBS = 2 OBS = 3);
RUN;
TITLE;
```

**Exercise 8:Specifying Variables and Observations, from page 2-44**

```
DATA instore (KEEP = Order_ID Customer_ID Order_Date)
     delivery(KEEP = Order_ID Customer_ID Order_Date ShipDays);
     SET orion.orders (WHERE=(Order_Type = 1));

     ShipDays = Delivery_Date - Order_Date;

     SELECT;
     	WHEN (ShipDays = 0) OUTPUT instore;
     	WHEN (ShipDays > 0) OUTPUT delivery;
     	OTHERWISE;
     END;
RUN;

TITLE "Deliverys from In-store Purchases";

PROC PRINT DATA = work.delivery;
RUN;

TITLE;

TITLE "In-stock Store Purchases, By Year";

PROC FREQ DATA = work.instore;
    FORMAT Order_Date YEAR4.;
    TABLES Order_Date;
RUN;

TITLE;

```

*Look into the Mahalanobis distance as an outlier consideration*

####Chapter 3: Creating Summary Values

**The `RETAIN` Statement**

The `RETAIN` statement:

- retains the value of the variable in the PDV across iterations of the DATA step
- initialies the retained variables to missing or a specified initial value before the first iteration of the DATA step
- is compile-time-only statement
- The `RETAIN` statement has no effect on variables read with `SET`, `MERGE`, or `UPDATE` statements. Variables read from SAS data sets are retained automatically.

This creates a retained variable called Mth2Dte and sets its initial value to 0.

```
DATA monthTotal;
	SET orion.aprsales;
	RETAIN Mth2Dte 0;
	Mth2Dte = Mth2Dte + SaleAmt;
RUN
```

Make sure when you use this that the input data set is sorted by the date.

If one of the SaleAmt values is missing, the running total breaks; we want to ignore missing values.

**Using the `SUM` Function**

A `RETAIN` statement along with a SUM function in an assignment can be used to deal with missing values.

```
DATA mnthtot;
	SET orion.aprsales;
	RETAIN Mth2Dte 0;
	Mth2Dte = SUM(Mth2Dte,SaleAmt);
RUN;
```

You can use a **SUM Statement** to create a value, too. It will retain it and initialize it to 0.

```
DATA mnthtot2;
	SET work.aprsales2;
	Mth2Dte + SaleAmt;
RUN;
```

Specifics about Mth2Dte:

- initialized to zero
- automatically retained
- increased by the value of SaleAmt for each observation
- ignored missing values of SaleAmt

**Exercise 1: Creating Accumulating Totals on page 3-15**

```
data work.mid_q4;
  set orion.order_fact;
  where '01nov2008'd <= Order_Date <= '14dec2008'd;
  Sales2Dte + Total_Retail_Price;
  NumOrders + 1;
run;


title 'Orders from 01Nov2008 through 14Dec2008';
proc print data=work.mid_q4;
    format Sales2Dte DOLLAR10.2;
    var Order_ID Order_Date Total_Retail_Price Sales2Dte NumOrders;
run;
title;
```

**Exercise 2: Creating Accumulating Totals with Conditional Logic on page 3-15**

```
DATA typetotals(KEEP = Order_Date Order_ID TotalRetail TotalCatalog TotalInternet);
    SET orion.order_fact;

    WHERE YEAR(Order_Date) = 2009;

    RETAIN TotalRetail   0
           TotalCatalog  0
           TotalInternet 0;

    SELECT (Order_Type);
        WHEN (1) TotalRetail   + Quantity;
        WHEN (2) TotalCatalog  + Quantity;
        WHEN (3) TotalInternet + Quantity;
        OTHERWISE;
    END;
RUN;

PROC PRINT DATA = typetotals;
RUN;
```

**Accumulating Totals for a Group of Data**

**BY-Group Processing**

The BY statement in the DATA step enables SAS to process data in groups.

```
PROC SORT DATA = orion.specialsals OUT = salsort;
	BY Dept;
RUN;

DATA deptsals(KEEP = Dept DeptSal);
	SET salsort;
	BY  Dept;
	<additional statements>
RUN;
```

A `BY` statement in a  DATA step creates two temporary variables for each variable listed in the BY statement. When a BY statement is used with a SET statement, the data must be sorted by the BY variable(s) or have an index based on the BY variable(s).

There is a three-step process for using the DATA step to summarize grouped data.

- Step 1: Initialize: Set the accumulating variable to zero at the start of each BY group.
- Step 2: Accumulate: Increment the accumulating variable with a sum statement (automatically retains).
- Step 3: Output: Write only the last observation of each BY group.

```
PROC SORT DATA = orion.specialsals OUT = salsort;
	BY Dept;
RUN;

DATA deptsals(KEEP = Dept DeptSal);
	SET salsort;
	BY  Dept;
	IF  FIRST.Dept THEN DeptSal = 0; /* Initialize */
	DeptSal+Salary;
	IF  LAST.Dept;
RUN;
```

The subsetting IF defines a condition that the observation must meet to be further processed by the DATA step. Basically, the implied `OUTPUT` only happens when the subsetting IF condition is true. The last line is the same as writing `IF LAST.Dept THEN OUTPUT;`.

**Sorting with Two Variables**

```
PROC SORT DATA = orion.projsals
          OUT  = projsort;
    BY Proj Dept;
RUN;
```

When you use more than one variable in the `BY` statement:

- `LAST.By-variable=1` for the **primary variable** forces
- `LAST.By-variable=1` for the **secondary variables**

**Working with Multiple BY Variables in the DATA step**

Remember that we're trying to get a print out that has the salary totals by project and department. That's the reason why the following code has the IF statement on First.Dept. It's a secondary variable, however, 

```
DATA pdsals (KEEP = Proj Dept DeptSal NumEmps);
	SET projsort;

	BY  Proj Dept;

	IF  First.Dept THEN 
	  DO;
		DeptSal = 0;
		NumEmps = 0;
	  END;

	 DeptSal+Salary;
	 NumEmps+1;

	 IF LAST.Dept;
RUN;

```

**Exercise 4: Summaryizing Data Using the DATA Step on page 3-35**

```
PROC SORT DATA = orion.order_summary 
          OUT  = work.sumsort;
    BY Customer_ID;
RUN;

DATA customers;
    SET sumsort;

    BY Customer_ID;

    IF FIRST.Customer_ID THEN Total_Sales = 0;
    Total_Sales + Sale_Amt;

    IF LAST.Customer_ID;
RUN;

PROC PRINT DATA = customers;
    VAR Customer_ID 
        Total_Sales;

    FORMAT Total_Sales DOLLAR11.2;
RUN;
```

**Exercise 5: Summarizing and Grouping Data Using the DATA Step on page 3-35**

```
PROC SORT DATA = orion.order_qtrsum OUT = qtrsum;
    BY Customer_ID Order_Qtr;
RUN;

DATA qtrcustomers;
    SET qtrsum;

    BY Customer_ID Order_Qtr;

    IF FIRST.Order_Qtr THEN 
        DO;
            Total_Sales = 0;
            Num_Months  = 0;
        END;
    Total_Sales + Sale_Amt;
    IF Sale_Amt > 0 THEN
        DO;
            Num_Months+1;
        END;

    IF LAST.Order_Qtr;
RUN;

PROC PRINT DATA = qtrcustomers NOOBS;
    FORMAT Total_Sales DOLLAR11.2;
    VAR Customer_ID
        Order_Qtr
        Total_Sales
        Num_Months;
RUN;
```

####Chapter 4: Reading Raw Data Files

The following are the only acceptable characters in a standard numeric field:
```
0 1 2 3 4 5 6 7 8 9 . E e D d - +
```
Leading or trailing blanks are also acceptable. 

Reading Data Using Formatted Input:

```
data work.discounts;
  infile "&path\offers.dat";
  input @  1  Cust_type  4. 
        @  5  Offer_dt   mmddyy8.
        @ 14  Item_gp    $8. 
        @ 22  Discount   percent3.;
run;

/* INPUT pointer-control variable informat...; */

proc print data=work.discounts noobs;
run;

proc print data=work.discounts noobs;
  format Offer_dt date9.;
run;
```

**Column Pointer Controls**

| | |
|-|-|
|`@n`|moves the pointer to column *n*.|
|`+n`|moves the pointer n positions.|

TODO: Look up the SAS Date and Value Informat Examples and insert them here.

The `ANYDTDTEw.` informat can be used to read data that has a variety of date forms.

You only get the input buffer when you use `INFILE`. Just the keyword `INPUT` is what physically loads the record into the input buffer. 

The PDV reads from the input buffer. When iterating through input buffer records, EVERY variable is reinitialized to missing at the beginning of the iteration.

**Exercise 1: Using Formatted Input from page 4-17**

```
%let path=c:\workshop\prg2;

data sales_staff;
  infile "&path\sales1.dat";
  input @1 Employee_ID 6. 
        @8 First_Name $12.
        @21 Last_Name $18. 
        @43 Gender    $1.
        @64 Salary    DOLLAR8.
        @73 Country   $2.
        @76 Birth_Date MMDDYY10.
        @87 Hire_Date MMDDYY10.;
run;

TITLE "Australian and US Sales Staff";

proc print data = sales_staff noobs;
run;

TITLE;
```

####Controlling when a Record Loads

By default, SAS loads a new record into the input buffer when it encounters an INPUT statement. You can have multiple INPUT statements in one DATA step. Each line reads a separate line.  If this is the data set:

```
Ms. Sue Farr
15 Harvey Rd.
Macon, GA 31298
869-7998
```
This code pulls out just the lines 1, 3, and 4:

```
DATA contacts;
  INFILE "&path\address.dat";
  INPUT  FullName $ 30.;
  INPUT; /* Skips the street address */
  INPUT  Address2 $ 25.;
  INPUT  Phone    $  8.;
RUN;
```

By default, SAS begins reading each new line of raw data at position 1 of the input buffer, so having `@1` in the INPUT statement is not necessary.

If you have a blank `INPUT` statement, SAS still loads the raw data line into the input buffer.


**Line Pointer Controls**

The other way to handle the problem above is with `/`, the line pointer control:

```
DATA contacts;
    INFILE "&path\address.dat";
    INPUT  FullName $30. / /
           Address2 $25. /
           Phone $8.;
RUN;
```

**Using Conditional Logic to Read Mixed Record Types**

You have to use a trailing `@` on an input line to tell SAS to hold the input in the input buffer until it encounters an input statement without a trailing `@` or it starts the next iteration of the DATA step. 

```
DATA salesQ1;
  INFILE "&path\sales.dat";

  INPUT  SaleID $ 4.  @6 Location $ 3. @;

  IF     Location = 'USA' THEN
    INPUT @10 SaleDate MMDDYY10.
          @20 Amount   7.;

  ELSE IF Location = 'EUR' THEN
    INPUT @10 SaleDate date9.
          @20 Amount   commax7.;
RUN;
```
Normally, each IPUT statement in a DATA step reads a new data record into the input buffer. When you use a trailing `@`, the following occur:

- The pointer position does not change.
- No new record is read into the input buffer.
- The next INPUT statement for the same iteration of the DATA step continues to read the same record rather than a new one.

SAS releases a record held by a trailing `@` when:

- a null INPUT statement executes: `INPUT;`
- an INPUT statement without a trailing `@` executes.
- the next iteration of the DATA step begins.

If you want to read just the Euro records, consider the placement of the subsetting IF so that you can skip as much of the conditional logic as possible.

```
DATA EuropeQ1;
    INFILE "&pathsales.dat";

    INPUT  @6 Location $3. @;

    IF     Location = 'EUR';
    INPUT   @1 SaleID $4.
           @10 SaleDate date9.
           @20 Amount commax7.;
RUN;
```

**Exercise 4: Reading Multiple Input Records per Observation**

```
DATA sales_staff2;
    INFILE "&path\sales2.dat";

    INPUT  @1 Employee_ID    6.
          @21 Last_Name   $ 18.       /

           @1 Job_Title   $ 20.
          @22 Hire_Date     MMDDYY10.
          @33 Salary        DOLLAR8.  /;
RUN;

TITLE "Australian and US Sales Staff";

PROC PRINT DATA = sales_staff2;
RUN;

TITLE;
```

**Exercise 5: Working with Mixed Record Types**

```
DATA US_Sales AU_Sales;
    INFILE "&path\sales3.dat";

    INPUT  @1 Employee_ID   6.
          @21 Last_Name   $18.
          @43 Job_Title   $20. /
          @10 Country     $ 2. @;

    IF    Country = 'AU' THEN
       DO;
          INPUT @1 Salary    DOLLARX8.
               @24 Hire_Date DDMMYY10.;
          OUTPUT AU_Sales;
       END;
    
    ELSE IF Country = 'US' THEN
        DO;
          INPUT @1 Salary    DOLLAR8.
               @24 Hire_Date MMDDYY10.;
          OUTPUT US_Sales;
       END;

    DROP Country;
RUN;
    
TITLE "Australian Sales Staff";

PROC PRINT DATA = AU_Sales;
RUN;

TITLE;

TITLE "US Sales Staff";

PROC PRINT DATA = US_Sales;
RUN;

TITLE;
```

###Chapter 5: Data Transformations

SAS provides a large library of functions for manipulating data during DATA step execution.

**Variable Lists**

You can use a variable list instead of using discreet variables:
```
Total = SUM(q1,q2,q3,q4);

/* Numbered Range List */
Total = SUM(OF q1-q4);

/* Name Range List */
Total = SUM(OF q1--Fourth);

/* Name Prefix List */
Total = SUM(OF Tot:);

/* Special Name Lists */
Total = SUM(OF _Numeric_);
```

In order to use the *Name Range List*, you have to know the order of the variables.

To use the *Numbered Range List*, you have to have the same base name for your variables.

If the keyword OF is omitted from function calls, SAS will give a syntax error or perform a subtraction operation.

TODO: Add the table of variable lists from pate 5-6

|SAS Variable Lists| | |
|------------------|-|-|
|Numbered range list| | |

**Using the `SUBSTR` Function (Right Side)**

Extract the fourth character from the value in the `Acct_Code` variable and store it in `Org_Code`:
```
Org_Code = SUBSTR(Acct_Code,4);
```

The SUBSTR function on the left side of an assignment statement is used to replace characters.

**The `LENGTH` Function**

The `LENGTH` function returns the length of a nonblank character string, excluding trailing blanks.
```
Code          = 'ABCD   ';
Last_NonBlank = LENGTH(Code);
```

You can nest function calls:
```
DATA charities;
    LENGTH ID $ 5;
    SET    orion.biz_list;

    IF SUBSTR(Acct_Code,LENGTH(Acct_Code),1) = '2';
      THEN ID = SUBSTR(Acct_Code,1,LENGTH(Acct_Code) - 1);
RUN;
```

In the `SUBSTR` function, if you omit the `<length>` parameter, it extracts the remainder of the expression.

**Using the `PROPCASE Function`**

This function puts strings into proper case:
```
Name   = 'SURF&LINK SPORTS';
Pname  = PROPCASE(Name);
Pname2 = PROPCASE(Name, ' &');

/*
    Pname  is Surf&link Sports
    Pname2 is Surf&Link Sports
*/
```

**Other Useful Character Functions**

|Function|Purpose|
|--------|-------|
|`RIGHT(string)`|Right-aligns a character expression|
|`LEFT(string)`|Left-aligns a character expression|
|`UPCASE(string)`|Converts all letters in an argument to uppercase|
|`LOWCASE(string)`|Converts all letters in an argument to lowercase|
|`CHAR(string.position)`|Returns a single character from a specified *position* in a character *string*|

**Exercise 1: Extracting Characters Based on Position on page 5-20**

```
DATA codes;
    LENGTH lcode  $ 4.
           fcode1 $ 1.
           fcode2 $ 1.;

    SET orion.au_salesforce;

    fcode1 = LOWCASE(SUBSTR(First_Name,1,1));
    fcode2 = LOWCASE(SUBSTR(First_Name,LENGTH(First_Name)-1));
    lcode  = LOWCASE(SUBSTR(Last_Name,1, 4));
RUN;

TITLE "Extracted Letters for User IDs";

PROC PRINT DATA = codes;
    VAR First_Name
        FCode1
        FCode2
        Last_Name
        LCode;
RUN;

TITLE;
```

TODO: Exercise 2 on page 5-21.


**Using the `SCAN` Function**

The `SCAN` function is used to extract words from a character value when the relative order of words is known, but their starting positions are not. The SCAN function returns the nth word of a character value.

Use the character length for what it returns because it defaults to 200.

```
/* Given a name like "Cox,Kay B." */
LENGTH FMName $ 20.;
FMName = SCAN(Name,2,',');
```

When you use the `SCAN` function:

- A missing value is returned if there are fewer than n words in the string.
- If n is negative, the SCAN function selects the word in the character string starting from the end of the string.
- The length of the created variable is 200 bytes.
- Delimiters before the first word have no effect.
- Any character or set of characters can serve as delimiters.
- Two or more contiguous delimiters are treated as a single delimiter.

```
DATA labels;
    SET orion.contacts;

    LENGTH FMName LName $ 15;

    FMName = SCAN(Name,2,',');
    LName  = SCAN(Name,1,',');
RUN;
```

If you use `SCAN(Text,6,', ');` then the delimiter is a space, a comma, a space and comma, or any combination of spaces and commas. The delimiter input is a list of delimiters.

Be careful with leading a trailing spaces.

**Using the `CATX` Function**

You can combine strings with `CATX`:

```
FullName = CATX(' ',FMName,LName);
```

**Other CAT Functions**

|Function|Details|
|--------|-------|
|`CAT(str1,...,strn)`|Does not remove leading or trailing blanks from the arguments before concatenating them|
|`CATS(str1,...,str-n)`|Removes leading and trailing blanks from the arguments.|
|`CATT(str,...str-n)`|emoves trailing blanks from the arguments.|


**The Concatenation Operator**

The *concatenation operator* is another way to join character strings.
```
Phone = '('!!area!!') '!!Number;
```

The operator can also be written as two vertical bars `||`.

**Data Cleanup Example**

Original incorrect data:
```
Product_ID            Product
21 02 002 00003       Luci Knit Mittens, Red
```

Step 1: Use the `SUBSTR` and `FIND` functions to change incorrect product IDs for mittens.

```
DATA correct;
    SET orion.clean_up;
    IF  FIND(Product,'Mittens','I') > 0 THEN DO;
        SUBSTR(Product_ID,9,1) = '5';
    END;
RUN;

/* The I modifier means 'ignore case' */
```

The `FIND` function searaches a target string for a specified substring.

```
Position = FIND(string,substring<,modifiers,startpos>);
```

Position: The starting position of the first occurrence of substring within string, if substring is found. 0 if substring is not found.

- A modifier can be the value I or T. These two values can be combined in either order and in either case. If this argument is omitted, the search is case sensitive and trailing blanks are considred.
- The *startpos* value not only specifies the position at which the search should start but also the direction of the search. A positive value indicates a forward (right) search. A negative value indicates a backward (left) search. If this argument is omitted, the search starts at position 1 and moves forward.
- These two optional arguments can be in either order (that is, *startpos* can precede *modifier*).

**Using the `SUBSTR` Function (Left Side)**

This form of the SUBSTR function (left side of the assignment statement) replaces characters in a character variable. Example, replace two characters starting at position 11:
```
SUBSTR(Location,11,2) = 'OH';
```

**Using the `TRANWRD` Function**

The `TRANWRD` function replaces or removes all occurrences of a given word (or a pattern of characters) within a character string. Using the `TRANWRD` function to replace an existing string with a longer string might cause truncation of the resulting value if a `LENGTH` statement is not used.

```
NewVar = TRANWRD(source, target, replacement);
```

- The TRANWRD function does not remove trailing blanks from *target* or *replacement*.
- If *NewVar* is not previously defined, it is given a length of 200.
- If the target string is not found in the source, then no replacement occurs.

```
DATA correct;
    SET orion.clean_up;
    IF  FIND(Product,'Mittens','I') > 0 THEN DO;
        SUBSTR(Product_ID,9,1) = '5';
        Product = TRANWRD(Product, 'Luci ', 'Lucky ');
    END;
RUN;

/* The I modifier means 'ignore case' */
```

**Functions that Remove Blanks**

The `COMPRESS` function removes the characters listed in teh *chars* argument from the source.

|Function|Purpose|
|--------|-------|
|`TRIM(string)`|Removes trailing blanks from a character string|
|`STRIP(string)`|Removes all leading and trailing blanks from a character string|
|`COMPBL(string)`|Removes multiple blanks from a character string by translating each occurrence of two or more consecutive blanks into a single blank.|

- The `TRIMN` function is similar to the `TRIM` function. `TRIMN` returns a null string (zero blanks) if the argument is blank while `TRIM` return a blank.
- The `STRIP` function returns a null string if the argument is blank.
- By default, the length of the value returned by the `COMPBL` function is the same as the length of the argument.

**Exercise 4: Cleaning Text Data on page 5-39**

```
DATA names;
    SET orion.customers_ex5;
    
    LENGTH New_Name $ 40.;

    First = SCAN(Name,2);
    Last  = PROPCASE(SCAN(Name,1));

    IF (Gender = 'M') THEN Sal = 'Mr.';
    ELSE                   Sal = 'Ms.';

    New_Name = CATX(' ',Sal,First,Last);

DROP First
     Last
     Sal;

RUN;

PROC PRINT DATA = names (OBS = 5);
    VAR New_Name
        Name
        Gender;
RUN;
```

**Exercise 5: Searching for and Replacing Character Values**

```
DATA silver gold platinum;
    SET orion.customers_ex5;
    
    Type = PROPCASE(COMPRESS(SCAN(Customer_ID,1,'-'),'0'));

    Customer_ID = TRANWRD(Customer_ID,'-00-','-15-');

    SELECT (Type);
      WHEN ('Silver')   OUTPUT silver;
      WHEN ('Gold')     OUTPUT gold;
      WHEN ('Platinum') OUTPUT platinum;
      OTHERWISE;
    END;

RUN;

PROC PRINT DATA = silver;
RUN;

PROC PRINT DATA = gold;
RUN;

PROC PRINT DATA = platinum;
RUN;
```

####Manipulating Numeric Values

|Function|Explanation|
|--------|-----------|
|`ROUND()`|The ROUND function returns a value rounded to the nearest multiple of rounding unit|
|`CEIL()`|The CEIL function returns the smallest integer greater than or equal to the argument|
|`FLOOR()`|Returns the greatest integer less than or equal to the argument|
|`INT()`|The INT function returns the integer portion of the argument|

```
DATA truncate;
    Var1      = -6.478;
    CeilVar1  = CEIL(Var1);
    FloorVar1 = FLOOR(Var1);
    IntVar1   = INT(Var1);
RUN;

/*
  Var1      = -6.478
  CeilVar1  = -6
  FloorVar1 = -7
  IntVar1   = -6
*/
```

```
NewVar5 = ROUND(12.69, .25); /* Round to the nearest .25 */
```

For values greater than or equal to 0, the FLOOR and INT functions return the ame value. For values less than 0, the CEIL and INT functions return the same value.

|Function|Returns|
|--------|-------|
|`SUM`|Sum of arguments|
|`MEAN`|Average of arguments|
|`MIN`|Smallest value from arguments|
|`MAX`|Largest value from arguments|
|`N`|Count of nonmissing arguments|
|`NMISS`|Count of missing numeric arguments|
|`CMISS`|Count of missing numeric or character arguments|

**Exercise 8: Calculating Statistics and Rounding**

```
DATA sale_stats;
    SET orion.orders_midyear;

    MonthAvg = ROUND(MEAN(OF month:));
    MonthMax = MAX(OF month:);
    MonthSum = SUM(OF month:);
RUN;

PROC PRINT data = sale_stats;
VAR Customer_ID
    MonthAvg
    MonthMax
    MonthSum;
RUN;
```

####Converting Variable Type

**Character-to-Numeric Conversion**

SAS automatically converts a character value to a numeric value when the character value is used in a numeric context, such as the following:

- assignment to a numeric variable
- an arithmetic operation
- logical comparison with a numeric value
- a function that takes numeric arguments
- The `WHERE` statement and the `WHERE=` data set option do not perform any automatic conversion in comparisons.
- The automatic conversion uses the w. informat
- produces a numeric missing value from a character value that does ot conform to standard numeric notation.


If you have ID as a char field and you create `EmpID = ID + 123`, then ID is automatically converted to a numeric value and EmpID is numeric.

**The `INPUT` Function**

The INPUT function returns the value produced when the source is read with a specified informat. If ou use the INPUT function to create a variable not previously defined, the type and length of the variable is defined by the informat.

```
data conversions;
   CVar1='32000';
   CVar2='32.000';
   CVar3='03may2008';
   CVar4='030508';
   NVar1=input(CVar1,5.);
   NVar2=input(CVar2,commax6.);
   NVar3=input(CVar3,date9.);
   NVar4=input(CVar4,ddmmyy6.);
run;

proc contents data=conversions;
run;

proc print data=conversions noobs;
run;
```

You can explicitly convert values, too:

```
data hrdata;
   keep EmpID GrossPay Bonus HireDate;
   set orion.convert;
   EmpID = input(ID,5.)+11000;
   Bonus = input(GrossPay,comma6.)*.10;
   HireDate = input(Hired,mmddyy10.);
run;

proc print data=hrdata noobs;
    var EmpID GrossPay Bonus HireDate;
run;

proc print data=hrdata noobs;
    var EmpID GrossPay Bonus HireDate;
   format HireDate mmddyy10.;
run;
```

This following assignment **does not** change GrossPay from a character variable to a numeric variable.

```
GrossPay = INPUT(GrossPay,comma6.);
```

A variable is character or numeric. After the variable's type is established, it cannot be changed. By following three steps, you can create a new variable with the same name and a different type:

1. Use the `RENAME=` data set option to rename:

```
DATA hrdata;
    SET orion.convert(RENAME=(GrossPay=CharGross));
RUN
```

2. Use the INPUT function in an assignment statement to create a new variable with the original name of the variable that you renamed.

```
DATA hrdata;
    SET orion.convert(RENAME=(GrossPay=CharGross));

    GrossPay = INPUT(CharGross,comma6.);
RUN
```

3. Use a `DROP=` data set option in the DATA statement to exclude the original variable from the output SAS data set.

```
DATA hrdata (DROP = CharGross);
    SET orion.convert(RENAME=(GrossPay=CharGross));

    GrossPay = INPUT(CharGross,comma6.);
RUN
```

The compilation for this program shows the PDV being created with a numeric GrossPay variable.

**Automatic Numeric-to-Character Conversion**

SAS converts a numeric value to a character value automatically when the numeric value is used in a character context, such as:

- assignment to a character variable
- a concatenation operation
- a function that accepts character arguments

The `WHERE` statement and the `WHERE=` data set option do not perform any automatic conversion in comparisons.

The automatic conversion:

- uses the BEST12. format
- right-aligns the resulting character value

To fix leading blanks, use the `PUT` function to explicitly control the numeric-to-character conversion.

The `PUT` function writes values with a specific format. It returs the value produced when *source* is written with *format*.

```
DATA hrdata;
    KEEP Phone Code Mobile;
    SET  orion.convert;

    Phone = '(' !! put(Code,3.) !! ') ' !! Mobile;
RUN;
```

The `PUT` function always returns a character string. Numeric formats right-align the results. Character formats left-align the results. If you use the `PUT` function to create a variable not previously defined, it creates a character varable with a length equal to the format width. No conversion messages are written to the log by the `PUT` function.

Examples:

```
data conversion;
  NVar1=614;
  NVar2=55000;
  NVar3=366;
  CVar1=put(NVar1,3.);
  CVar2=put(NVar2,dollar7.);
  CVar3=put(NVar3,date9.);
run;
proc contents data=conversion varnum;
run;
proc print data=conversion noobs;
run;

```

The CAT family of functions converts any numeric argument to a character string by using the `BEST12.` format and then removing any leading blanks. No note is written to the log.

These are equivalent statements:

```
Phone = CAT('(',Code,') ',Mobile);
Phone = '(' !! put(Code,3.) !! ') ' !! Mobile;
```

**Example 10: Converting Variable Type on page 5-77**

```
data shipping_notes;
  set orion.shipped;
  length Comment $ 21;
  Comment = cat('Shipped on ',PUT(Ship_Date,MMDDYY10.));
  Total = Quantity * INPUT(Price,DOLLAR7.);
run;

proc print data=shipping_notes noobs;
  format Total dollar7.2;
run;
```

**Example 11: Changing a Variable's Data Type**

```
DATA US_converted(DROP = newID newTel);
    SET orion.US_newhire(RENAME=(       ID = newID
                                 Telephone = newTel));

    ID = INT(COMPRESS(newID,"- "));
    tempTelephone = PUT(newTel,7.);

    LENGTH Telephone $8
           AreaCode  $3;

    AreaCode = SUBSTR(tempTelephone,1,3);

    Telephone = CAT(AreaCode,'-',SUBSTR(tempTelephone,4,4));


RUN;

PROC PRINT DATA = US_converted (OBS=5);
RUN;

PROC CONTENTS DATA = US_converted VARNUM;
RUN;
```

###SAS Debugging

The `PUTLOG` statement can be used in the DATA step to display the value of one or more variables and messages in the log. The `PUT` statement can also be used for this purposed. In addition, the `PUT` statement is used to write to an external file. If an external file is open for output, steps must be taken to ensure that debugging messages are written to the SAS log and not to the external file. 

**Using the `PUTLOG` statement to write the value of a variable to the log:

```
PUTLOG variable-name=;

PUTLOG City=;

/* Writes City=SanDiego to the log */
```

To write the formatted value of a variable to the log, use this form:

```
PUTLOG variable-name format-namew.;

PUTLOG City $quote22.;
```

Write all variables with `PUTLOG _ALL_;`.

**Special Variables**

|Variable|Desc|Debugging Use|
|--------|----|-------------|
|`_N_`|The number of times that the DATA step iterated|Display debugging messages for some number of iterations of the DATA step|
|`_ERROR_`|Initialized to 0, set to 1 when an error occurs|Display debugging messages when an error occurs|

Keep in mind that you can read in multiple lines with a single DATA iteration by using multiple INPUT statements. Therefore, `_N_` does not represent the observation number.

```
data _null_;
   set orion.donate;
   IF _N_ < 4 THEN PUTLOG _N_= _ERROR_=;
run;
```

**Processing at the End of a DATA Step**

The `END=` option creates a temporary variable that acts as an end-of-file indicator.

- The option can be used in SET and INFILE statements
- The variable is initialized to 0 and is set to 1 when the last observation or record is read.

```
DATA work.donate
    SET orion.donate END=last;

    IF LAST = 1 THEN DO;
       ...
    END;
RUN;
```

**Using PUTLOG with Conditional Logic**

The program below displays a message in the log on the first iteration of the DATA step, and displays the contents of the PDV in the last iteration of the DATA step.

```
data _null_;
   set orion.donate end=lastObs;
   if _n_=1 then
      putlog 'First iteration';
   if lastObs then do;
      putlog 'Final values of variables:';
      putlog _all_;
   end; 
run;
```

Debugging examples:

```
  /* Program with incorrect output */
data us_mailing;
   set orion.mailing_list;
   drop Address3;
   length City $ 25 State $ 2 Zip $ 5;
   if find(Address3,'US') > 0;
   Name=catx(' ',scan(Name,2,','),scan(Name,1,','));
   City=scan(Address3,1,',');
   State=scan(Address3,2,',');
   Zip=scan(Address3,3,',');
run;

proc print data=us_mailing noobs;
   title 'Current Output from Program';
run;
title;

  /* Use PUTLOG to help identify the error */
data us_mailing;
   set orion.mailing_list;
   drop Address3;
   length City $ 25 State $ 2 Zip $ 5;
   putlog _n_=;
   putlog "Looking for country";
   if find(Address3,'US') > 0;
   putlog "Found US";
   Name=catx(' ',scan(Name,2,','),scan(Name,1,','));
   City=scan(Address3,1,',');
   State=scan(address3,2,',');
   Zip=scan(Address3,3,',');
   putlog State= Zip=;
run;

  /* Use a format with PUTLOG to help identify the error */
  /* Use OBS= to limit processing to the first 10 obs */
data us_mailing;
   set orion.mailing_list (obs=10);
   drop Address3;
   length City $ 25 State $ 2 Zip $ 5;
   putlog _n_=;
   putlog "Looking for country";
   if find(Address3,'US') > 0;
   putlog "Found US";
   Name=catx(' ',scan(Name,2,','),scan(Name,1,','));
   City=scan(Address3,1,',');
   State=scan(address3,2,',');
   putlog state $quote4.;
   Zip=scan(Address3,3,',');
   putlog Zip $quote7.;
run;


  /* Use the LEFT function to remove leading blanks */

data us_mailing;
   set orion.mailing_list (obs=10);
   drop Address3;
   length City $ 25 State $ 2 Zip $ 5;
   putlog _n_=;
   putlog "Looking for country";
   if find(Address3,'US') > 0;
   putlog "Found US";
   Name=catx(' ',scan(Name,2,','),scan(Name,1,','));
   City=scan(Address3,1,',');
   State=left(scan(address3,2,','));
   putlog state $quote4.;
   Zip=left(scan(Address3,3,','));
   putlog Zip $quote7.;
run;

  /* Remove putlog statements */

data us_mailing;
   set orion.mailing_list;
   drop Address3;
   length City $ 25 State $ 2 Zip $ 5;
   if find(Address3,'US') > 0;
   Name=catx(' ',scan(Name,2,','),scan(Name,1,','));
   City=scan(Address3,1,',');
   State=left(scan(address3,2,','));
   Zip=left(scan(Address3,3,','));
run;

proc print data=work.us_mailing noobs;
   title 'Corrected Output';
run;
title;
```

###Chapter 7: Processing Data Iteratively

Use DO loops to perform repetitive calculations:

```
DO index-variable=start TO stop <BY increment>;
    iterated SAS statements...
END;
```

```
DATA compound(DROP = i);
    Amount = 50000;
    Rate   = 0.045;

    DO i = 1 to 20;
        Yearly + (Yearly+Amount) * Rate;
    END;

    DO i = 1 to 80;
        Quarterly+((Quarterly+Amount)*Rate/4);
    END;
RUN;
```

**The Iterative DO Statement**

The values of start, stop, and increment:

- must be numbers or expressions that yield numbers
- are established before executing the loop
- if omitted, increment defaults to 1.

Details of *index-variable*:

- The index-variable is written to the output data set by default unless you drop it.
- At the termination of the loop, the value of *index-variable* is one *increment beyond the *stop* value

You can create DO loops with Item Lists:

```
do Month = 'JAN', 'FEB', 'MAR';
    ...
end;

do odd=1,3,5,7,9;
    ...
end;

do i=Var1,Var2,Var3;
    ...
end;
```

More examples:

```
DATA invest;
    DO Year = 2008 to 2010;
        Capital+5000;
        Capital+(Capital*.045);
    END;
RUN;
```

**Exercise 1: Performing Computations with DO Loops on page 7-16**

```
data future_expenses;
   drop start stop; 
   Wages=12874000;
   Retire=1765000;
   Medical=649000;
   start=year(today())+1;
   stop=start+9;
  /* insert a DO loop here */
   DO year=start to stop;
        wages = wages * 1.06;
        retire = retire * 1.014;
        medical = medical * 1.095;
        total_cost = SUM(wages,retire,medical);
        OUTPUT future_expenses;
   END;
run;
proc print data=future_expenses;
   format wages retire medical total_cost comma14.2;
   var year wages retire medical total_cost;
run;
```

####Conditional Iterative Processing

The `DO UNTIL` statement executes statements in a DO loop repetitively until a condition is true. The value of expression is evaluated at the bottom of the loop. The statements in the loop are executed at least once.

```
DATA invest;
    DO UNTIL (Capital > 1000000);
        Year+1;
        Capital+5000;
        Capital+(Capital*.045);
    END;
RUN;

PROC PRINT DATA = invest NOOBS;
    FORMAT Capital DOLLAR14.2;
RUN;
```

The `DO WHILE` Statement executes statements in a DO loop repetitively while a condition is true. The value of expression is evaluated at the top of the loop. The statements in the loop never execute if expression is initially false.


```
DATA invest;
    DO WHILE (Capital <= 1000000);
        Year+1;
        Capital+5000;
        Capital+(Capital*.045);
    END;
RUN;

PROC PRINT DATA = invest NOOBS;
    FORMAT Capital DOLLAR14.2;
RUN;
```

The following is going to stop the loop if you hit 30 years or $250,000.
```
DATA invest;
    DO Year=1 to 30 WHILE(Capital <= 250000);
        Capital+5000;
        Capital+(Capital*0.45);
    END;
RUN;

PROC PRINT DATA = invest NOOBS;
    FORMAT Capital DOLLAR14.2;
RUN;



The output is:
Year        Capital
28          $264,966.67
```

In a DO UNTIL loop, the condition is checked before the index variable is incremented.

```
DATA invest;
    DO Year=1 to 30 UNTIL(Capital > 250000);
        Capital+5000;
        Capital+(Capital*0.45);
    END;
RUN;

PROC PRINT DATA = invest NOOBS;
    FORMAT Capital DOLLAR14.2;
RUN;



The output is:
Year        Capital
27          $264,966.67
```

**Nested DO Loops**

```
data invest(drop=Quarter);
   do Year=1 to 5;
      Capital+5000;
      do Quarter=1 to 4;
         Capital+(Capital*(.045/4));
      end;
      output;
   end;
run;
proc print data=invest noobs;
run;

```

There are three observations in orion.banks. Therefore, there are three iterations of the DATA step. Capital must be set to zero on each iteration of the DATA step.

```
proc print data=orion.banks;
   format rate 6.4;
run;

data invest(drop=Quarter Year);
   set orion.banks;
   Capital=0;
   do Year=1 to 5;
      Capital+5000;
      do Quarter=1 to 4;
         Capital+(Capital*(Rate/4));
      end;
   end;
run;

proc print data=invest noobs;
run;

```

TODO: Exercise 2 on 7-28 

####Array Processing

An array provides an alternate way to access values in the PDV, which simplifies repetitive calculations.

A SAS array is:

- is a temporary grouping of SAS variables that are arranged in a particular order.
- Is identified by an array name
- must contain all numeric or all character variables
- exists only for the duration of the current DATA step
- is **not** a variable

In SAS, an array is **NOT** a data structure. It is simply a convenient way of temporarily identifying a group of variables.

**Create an array of variables**

```
/* Format */
ARRAY array-name{subscript} <$> <length> <array-elements>;

ARRAY Contrib{4} Qtr1 Qtr2 Qtr3 Qtr4;

OR

ARRAY Contrib{*} Qtr1 Qtr2 Qtr3 Qtr4;

OR

ARRAY Contrib{*} Qtr:;
```

Access elements in an array:
```
Contrib{1} Contrib{2} Contrib{3} Contrib{4}
```

Array references cannot be used in compile-time statements such as LABEL, FORMAT, DROP, KEEP, or LENGTH statements. If you use a function name as the name of the array, SAS treats parenthetical references that involve the name as array references, not function references, for the duration of the DATA step.

Variables that are elements of an array do not need the following:

- to have similar, related, or numbered names
- to be stored sequentially
- to be adjacent

**Using a DO loop to process an array**

```
DATA charity;
    SET orion.employee_donations;
    KEEP Employee_ID Qtr1-Qtr4;

    ARRAY Contrib{4} Qtr1-Qtr4;

    DO i = 1 to 4;
        Contrib{i} = Contrib{i} * 1.25;
    END;
RUN;
```

By default, SAS includes the index-variable in the output data set. Use a DROP or KEEP statement or the `DROP=` or `KEEP=` data set option to prevent the index variable from being written to your output data set.

When there is not a dollar sign in the array statement, SAS will default to creating numeric variables.

**Using an Array as a Function Argument**

```
Tot2 = SUM(OF val{*});
```

**The `DIM` Function**

The `DIM` Function returns the number of elements in an array. This value is often used as the stop value in a `DO` loop.

```
data charity;
   set orion.employee_donations;
   keep employee_id qtr1-qtr4; 
   array Contrib{4} qtr:;
   do i=1 to dim(contrib);        
      Contrib{i}=Contrib{i}*1.25;
   end; 
run; 

proc print data=charity noobs;
run;
```

The `HBOUND` function returns the upper bound of an array. The `LBOUND` function returns the lower bound of an array. 

If you want to define an array that has different indices than the default:

```
ARRAY items{5:14} n5-n14;
```

This is how you use an array to create numeric variables:
```
ARRAY Pct{4} Pct1-Pct4;
```

This is how you create character variables:

```
ARRAY Month{6} $ 10;

/* Creates Month1, Month2, etc... */
```


**Creating Variables with Arrays**

```
data percent(drop=i);              
   set orion.employee_donations;
   array Contrib{4} qtr1-qtr4;        
   array Percent{4};
   Total=sum(of contrib{*});           
   do i=1 to 4;     
      percent{i}=contrib{i}/total;
   end;                               
run; 
proc print data=percent noobs;
   var Employee_ID percent1-percent4;
   format percent1-percent4 percent6.;
run;
```

**Assigning Initial Values to an Array**

```
ARRAY Target{5} (50,100,125,150,200);

/* Creates Target1 and sets it to 50.
           Target2 and sets it to 100.
           etc...
*/
```

Elements and values are matches by position. If there are more array elements than initial values, the remaining array elements are assigned missing values and SAS issues a warning.


**Using different arrays to calculate values easily**

```
data compare(drop=i Goal1-Goal4);
   set orion.employee_donations;
   array Contrib{4} Qtr1-Qtr4;
   array Diff{4};
   array Goal{4} (10,20,20,15);
   do i=1 to 4;
      Diff{i}=Contrib{i}-Goal{i};
   end;
run;
proc print data=compare noobs;
   var Employee_id diff1-diff4;
run;
```


**Creating a Temporary Lookup Table**

You can use the keyword `_TEMPORARY_` in an array statement to indicate that the elements are not needed in the output data set.

```
DATA compare(drop=i);
   SET orion.employee_donations;
   ARRAY Contrib{4} Qtr1-Qtr4;
   ARRAY Diff{4};
   ARRAY Goal{4} _TEMPORARY (10,20,20,15);
   DO i=1 to 4;
      Diff{i}=Contrib{i}-Goal{i};
   END;
RUN;

PROC PRINT DATA=compare NOOBS;
   VAR employee_id diff1-diff4;
RUN;
```

The `SUM` Function Ignores Missing Values. It can be used to calculate the difference between the quarterly contribution and the corresponding goal. In this example, the missing values are handled as if no contribution was made for that quarter.

```
data compare(drop=i Goal1-Goal4);
   set orion.employee_donations;
   array Contrib{4} Qtr1-Qtr4;
   array Diff{4};
   array Goal{4} _temporary_ (10,20,20,15);
   do i=1 to 4;
      Diff{i}=sum(Contrib{i},-Goal{i});
   end;
run;
proc print data=compare noobs;
   var Employee_id diff1-diff4;
run;
```

**Quiz 7.09**

```
ARRAY Country{3} $2 _TEMPORARY_ ("AU","NZ","US");
```

**Exercise 8 on page 7-59**

```
data preferred_cust(KEEP= Customer_ID Over1 Over2 Over3 Over4 Over5 Over6 Total_Over);
   set orion.orders_midyear;
   array Mon{6} Month1-Month6;
   ARRAY Target{6} _TEMPORARY_ (200,400,300,100,100,200);
   ARRAY Over{6};
   keep Customer_ID Over1-Over6 Total_Over;

   Total_Over = 0;

   DO i = 1 to 6;
        IF Mon{i} > Target{i} THEN 
          DO;
            Over{i} = Mon{i} - Target{i};
            Total_Over + Over{i};
          END;
   END;

   IF Total_Over > 500;
RUN;
proc print data=preferred_cust noobs;
run;
```

####Restructuring a Data Set

If you want to rotate a data set...

**Rotating a SAS Data Set**

The DATA step below rotates the input data set and outputs an observation if a contribution was made in a given quarter:

```
data rotate (keep=Employee_Id Period Amount);
   set orion.employee_donations
             (drop=recipients paid_by);
   array contrib{4} qtr1-qtr4;
   do i=1 to 4;
      if contrib{i} ne . then do;
         Period=cats("Qtr",i);
         Amount=contrib{i};
         output;
      end;
   end;
run;

proc print data=rotate;
run;

proc freq data=rotate;
   tables Period /nocum nopct;
run;
```

Automatic conversion occurs when you use a numeric value in character context. The functions in the CAT family remove leading and trailing blanks from numeric arguments after it formats the numeric value with the `BEST12.` format.

**Exercise 1: Rotating a Data Set on page 8-22**

```
DATA sixmonths (KEEP = Customer_ID Month Sales);
    SET orion.orders_midyear;

    ARRAY months{6} Month1-Month6;

    DO Month = 1 to 6;
        IF months{Month} ~= . THEN
          DO;
            Sales = months{Month};
            OUTPUT;
          END;
    END;
RUN;

PROC PRINT DATA = sixmonths;
RUN;
```

TODO: Look into this to see which age is more correct:

```
  DATA birth;
    INPUT id birthday MMDDYY6.;
    today = DATE();
    days  = today - birthday;
    age   = days / 365.2425; 
    age2  = (intck('month',birthday,today) - (day(today) < day(birthday))) / 12;
    DATALINES;
    01 112573
 RUN;
```

#### Chapter 9: Match-Merging Data Sets in SAS

To review, use the `IN=` data set variable option to see if a record contributes to a match:

```
DATA CustOrd;
    MERGE orion.customer (IN = cust)
          work.order_fact(IN = order);
    BY    Customer_ID;
    IF    cust AND order;
RUN;
```

**Multiple Data Sets without a Common Variable**

Look for a string of common variables across tables and use them to join.

When merging in SAS, if the two tables have more than one shared column, the values from the second table will be written to the new data set instead of the values from the first table. You can avoid this by using a `DROP=` data set option on the second data set to exclude the columns in the second table from the merge.

Remember to use a SAS Name Literal when referencing an Excel worksheet. The n after Supplier$ means that Supplier$ is a literal.

```
LIBNAME BONUS "BonusGift.xls";

PROC PRINT DATA = bonus."Supplier$"n;
RUN;
```

Create gift list solution:
```
  /* This program will only execute on the Windows platform */
proc sort data=orion.Customer_Orders out=CustOrdProd;
   by Supplier;
run;

libname bonus "&path\BonusGift.xls";

data CustOrdProdGift;
   merge CustOrdProd(in=c) 
         bonus.'Supplier$'n(in=s
            rename=(SuppID=Supplier
                    Quantity=Minimum));
   by Supplier;
   if c=1 and s=1 and Quantity > Minimum;
run;

libname bonus clear;

proc sort data=CustOrdProdGift;
   by Customer_Name;
run;

proc print data=CustOrdProdGift noobs;
   var Customer_Name Gift;
run;
```

###Chapter 10: Creating and Maintaining Permanent Formats

What you can do is create a SAS data set that has the data that you want to use in the permanent format. You do this by using something that you refer to as the Control Data Set.

```
PROC FORMAT LIBRARY = orion.MyFmts
            CTLIN   = orion.country;
RUN;

...

DATA country;
    KEEP Start Label FmtName;
    FMTName = '$country';
    SET orion.country;
    Start = Country;
    Label = Country_Name;
RUN;

DATA country;
    KEEP Start Label FmtName;
    RETAIN FmtName '$country';
    SET orion.country(RENAME=(Country=Start 
                              Country_Name=Label));
RUN;
```
The `CTLIN=` data set has the following features:

- assumes that the ending value of theformat range is equal to the value of `Start` if no variable named `End` is found.
- can be used to create new formats, as well as re-create existing formats
- must be grouped by `FmtName` if multiple formats are specified

FmtName

- can be up to 32 characters in length
- for character formats, must begin with a dollar sign $ followed by a letter or underscore
- for numeric formats, must begin with a letter or underscore
- cannot end in a number
- cannot be the name of a SAS format

**Using the `CATALOG` Procedure**

The `CATALOG` procedure manages entries in SAS catalogs.

```
PROC CATALOG CAT = orion.MyFmts;
    CONTENTS;
RUN;
```

You can use the `FMTLIB` option in the `PROC FORMAT` statement to document the format.

```
PROC FORMAT LIBRARY = orion.MyFmts FMTLIB;
    SELECT $country;
RUN;
```

**Nesting Formats**

In the `VALUE` statement, you can specify that the format use a second format as the formatted value.

Enclose the format name in square brackets:

```
PROC FORMAT LIBRARY = orion.MyFmts;
    VALUE $extra ' '= 'Unknown'
              other = [$country30.];
RUN;
```

When a format is referened, SAS does the following:

- loads the format from the catalog entry into memory
- performs a binary search on values in the table to execute a lookup
- returns a single result for each lookup.

You can use formats:

- FORMAT statements
- FORMAT= options
- PUT statements
- PUT functions

You can use the line `OPTIONS NOFMTERR;` at the top of a program to bypass errors.
TODO: Add this to the header code. Reverse it with `OPTIONS FMTERR;`.

You can use a system option to search for the format, with:
```
OPTIONS FMTSEARCH = (item-1 item-2 etc...);

OPTIONS FMTSEARCH = (orion orion.myfmts work);
```

To maintain formats, perform one of the following tasks:

- Edit the `PROC FORMAT` code that created the original format.
- Create a SAS data set from the format, edit the data set, and use the `CNTLIN=` option to re-create the format.



```
/* Step 1: Create a SAS data set from a permanent library */
proc format library=orion.myfmts cntlout=countryfmt;
   select $country;
run;

proc print data=countryfmt;
run;

proc print data=orion.NewCodes;
run;

/* Step 2 Concatenate the new country codes to countryfmt */

data countryfmt;
   set countryfmt 
      orion.NewCodes; /* Tables concatenate here because 2 tables on the set statement */
run;

/* Step 3 */

proc format library=work.myfmts cntlin=countryfmt fmtlib;
   select $country;
run;

```

**Exercise 1: Creating Formats with Values from a SAS Data Set**

