LIBNAME clean 'C:\iaa\summer_datacleaning';

/* Macro to close the viewtables */
%macro closevts; 
  %local i; 
  %do i=1 %to 20;
    dm 'next VIEWTABLE:; end';
    * next "viewtable:"; end; 
  %end; 
%mend;

%macro closevts_f12; 
  %local i; 
  %do i=1 %to 20;
    next "viewtable:"; end; 
  %end; 
%mend;

/* Assign F12 to close View table windows */
dm "keydef F12 '%NRSTR(%closevts_f12);";

/* Close open view table windows */
%closevts

/* Create the Payroll Dataset */

DATA CLEAN.PAYROLL;
	FORMAT 
	ID $2.
	NAME $6.
	AGE 2.
	DEPARTMENT $9.
	SALARY 5.;
   INPUT @1 ID $2. NAME $ AGE DEPARTMENT $ SALARY;
DATALINES;
01 John 40 Marketing 45000
02 Mary 42 Finance 50000
03 Peter 36 Fince 40000
   Laura 38 Marketing 46000
05 Mike 26 IT 56000
03 Eric 49 Marketing 63000
07 Kevin 29 Marketin 45000
08 Andrea 35 Finance 50000
09 Mark 58 IT 75000
10 Sandy 20 IT 45000
11 Joseph 36 Marketing 30000
;
RUN;

/* Patients data set has

    PATNO  - Patient ID
    GENDER - Gender
    VISIT  - Visit Date
    HR     - Heart Rate
    SBP    - Systolic Blood Pressure
    DBP    - Distolic Blood pressure
    DX     - Diagnosis Code
    AE     - Adverse Event (boolean)
    DRUG   - Drug Group
    WEIGHT - Weight in Pounds
*/

/* PROC FREQ */

/* Example */
PROC FREQ DATA = sashelp.cars;
    TABLES origin;
RUN;

/* Practice */
PROC FREQ DATA = sashelp.company;
    TABLES level3;
RUN;

/* PROC SQL */
/*
PROC SQL;
    SELECT   column_name, count(*)
    FROM     table_name
    GROUP BY column_name;
QUIT;
*/

PROC SQL;
    SELECT      origin, count(*) AS Count
    FROM        sashelp.cars
    GROUP BY    origin;
QUIT;

PROC SQL;
    SELECT   level4, count(*) AS Count
    FROM     sashelp.company
    GROUP BY level4
    ORDER BY Count DESC; /* or ORDER BY 2 (for second column) */
QUIT;


/* The following two are functionally equivalent */
PROC FREQ DATA = clean.patients;
    TITLE "Frequency Counts";
    TABLES GENDER;
RUN;

PROC SQL;
    SELECT      GENDER, count(*) AS Count
    FROM        clean.patients
    GROUP BY    GENDER
    ORDER BY    Count DESC;
QUIT;


/* Examining values; these two are equivalent */
PROC SQL;
    SELECT  *
    FROM    clean.patients
    WHERE   GENDER ~= 'M' AND GENDER <> 'F'
            AND GENDER is not null;
QUIT;


PROC PRINT DATA = clean.patients LABEL;
    TITLE "Invalid Gender Values";
    WHERE GENDER NOT IN ('M' 'F' ' ');
    ID    PATNO;
RUN;


PROC SQL;
    SELECT *
    FROM   clean.payroll
    WHERE  DEPARTMENT IN ('Marketing','Finance','IT');
QUIT;

PROC PRINT DATA = clean.payroll LABELS;
    TITLE "Payroll Values";
    WHERE DEPARTMENT IN ('Marketing','Finance','IT');
    ID    ID;
RUN;
           

/* PROC MEANS */
/* Checking that numeric values are within predetermined ranges */

PROC MEANS DATA = sashelp.cars;
    VAR cylinders;
RUN;

/* with options */
PROC MEANS DATA = sashelp.cars N NMISS MIN MAX MAXDEC = 3;
    VAR cylinders;
RUN;

PROC MEANS DATA = clean.patients MAXDEC = 2;
    TITLE 'Checking Numeric Variables';
    VAR    hr sbp dbp;
RUN;

/* The next two are equivalent */
PROC PRINT DATA = clean.patients LABEL;
    WHERE (HR NOT BETWEEN 40 AND 100) AND 
          (HR IS NOT MISSING);
    TITLE "Out-of-Range Values for Numeric Variables";
    ID    PATNO;
RUN;

PROC SQL;
    SELECT *
    FROM   clean.patients
    WHERE  (HR NOT BETWEEN 40 AND 100) AND
           (HR IS NOT MISSING);
QUIT;

PROC MEANS DATA = clean.payroll MAXDEC = 0;
    TITLE 'Checking Salary Data';
    VAR   SALARY;
RUN;

PROC SQL;
    SELECT  *
    FROM    clean.payroll
    WHERE   (SALARY NOT BETWEEN 40000 AND 70000);
QUIT;



/* Using PROC FORMAT to check for improper values */

PROC FREQ DATA = sashelp.cars;
    TABLES Type;
RUN;

PROC FORMAT;
    VALUE   $car
            'Sedan' = 1
            'SUV'   = 2
            'Wagon' = 3
             other  = 4;
RUN;

PROC FREQ DATA = sashelp.cars;
    FORMAT TYPE $car.;
    TABLES TYPE;
RUN; 

/* Example with patients */
PROC FORMAT;
    VALUE $misscnt
          ' ' = 'missing'
        other = 'nonmissing';
RUN;

PROC FREQ DATA = clean.patients;
    FORMAT PATNO $misscnt.;
    TABLES PATNO / missing;
RUN;

/* Display the record with the missing patient id */
PROC SQL;
    SELECT *
    FROM   clean.patients
    WHERE  PATNO IS NULL;
RUN;


/* Checking for duplicate data vales */
/* Use DISTINCT and BY groups */

PROC SQL;
    CREATE TABLE single AS
    SELECT DISTINCT PATNO
    FROM   clean.patients;
RUN;

/*PROC SQL;*/
/*    SELECT PATNO, Count(*) As OrigCount FROM clean*/
/*           DISTINCT PATNO, Count(*) As OrigCount*/
/**/
/*    FROM   clean.patients;*/
/*QUIT;*/

/*PROC SQL;*/
/*    SELECT  (*/
/*            SELECT PATNO, COUNT(*)*/
/*            FROM   clean.patients*/
/*            ) AS countAllPATNO,*/
/**/
/*            (*/
/*            SELECT DISTINCT PATNO, COUNT(*)*/
/*            FROM   clean.patients*/
/*            ) AS countDistinctPATNO*/
/**/
/*    FROM    clean.patients;*/
/*QUIT;*/


DATA dates;
    SET clean.patients;
    IF  VISIT < '01jun1998'd OR
        VISIT > '15oct1999'd;
RUN;

PROC PRINT DATA = dates;
RUN;



/* Making Simple corrections */
