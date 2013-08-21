/* ------------------------------------------------------------------------------ */
/* ---------------- HEADER CODE ------------------------------------------------- */
/* ------------------------------------------------------------------------------ */

/* Macro to close the viewtables */
%macro closevts; 
  %local i; 
  %do i=1 %to 20;
    dm 'next VIEWTABLE:; end';
    * next "viewtable:"; end; 
  %end; 
%mend;

/* Macro to set F12 to close all open viewtables */
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

/* Clear the log */
DM LOG 'clear' OUTPUT;

/* Clear the results window */
DM 'odsresults; clear';

/* Clear the output */
ODS _all_ CLOSE;
ODS PREFERENCES;

%LET tempLib = a%SYSFUNC(INT(%SYSFUNC(TIME())));

/* This will delete EVERYTHING in your Work library!!! */
PROC DATASETS LIBRARY=work KILL NOLIST;
RUN;

LIBNAME &tempLib "c:\iaa\summer";

PROC COPY IN = &tempLib OUT = work CLONE;
RUN;

LIBNAME &templib CLEAR;




/* ------------------------------------------------------------------------------ */
/* ---------------- LOADING SUPPORT DATA ---------------------------------------- */
/* ------------------------------------------------------------------------------ */

/* Import SAS Reference Zip Code File */
/* You can download it here: http://support.sas.com/rnd/datavisualization/mapsonline/html/misc.html */

PROC CIMPORT INFILE='c:\iaa\summer\zipcode_Jul13_v9.cpt' library=work;
RUN;

DATA reference_zips(KEEP = Ref_zip 
                           Ref_state 
                           Ref_state_fips 
                           Ref_county 
                           Ref_county_fips 
                           Ref_city
                           Ref_lat 
                           Ref_lon);
    SET zipcode_13q3_unique(RENAME=(ZIP         = Ref_zip
                                    STATECODE   = Ref_state
                                    STATE       = Ref_state_fips
                                    COUNTYNM    = Ref_county
                                    COUNTY      = Ref_county_fips
                                    CITY        = Ref_city
                                    Y           = Ref_lat
                                    X           = Ref_lon));
RUN;

DATA reference_zips;
    SET reference_zips;

    Ref_lon_rad = atan(1)/45 * Ref_lon;
    Ref_lat_rad = atan(1)/45 * Ref_lat;

RUN;

/* Remove the labels that SAS applies to the zip data */
PROC DATASETS LIB = work MEMTYPE = data NOLIST;
   MODIFY reference_zips; 
     ATTRIB _ALL_ LABEL = ' '; 
RUN;

/* Import file that references likely zip code by telephone area code and exchange */
DATA phone_zips;
    INFILE "c:\iaa\summer\zips_by_phone_AC_Exchange.csv" DLM = ',' FIRSTOBS = 2;
    INPUT  area_code  :$3.
           exchange   :$3.
           likely_zip :$5.;
RUN;

DATA phone_zips(DROP= area_code exchange);
    FORMAT Cust_ACEX $6.;
    SET phone_zips;
    
    Cust_ACEX = area_code||exchange;
RUN;

PROC SORT DATA = phone_zips;
    BY Cust_ACEX;
RUN;


/* ------------------------------------------------------------------------------ */
/* ---------------- DATA CLEANING ----------------------------------------------- */
/* ------------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------------ */
/* ---------------- Cleaning adjuster_technician -------------------------------- */
/* ------------------------------------------------------------------------------ */

/* adjuster_technician: modify table so that adjuster and technician are separate columns */

PROC SORT DATA = adjuster_technician;
    BY Cov_ID;
RUN;

DATA adjuster_technician (DROP = Claim_Info);
    LENGTH  Adjuster_ID   $ 4
            Technician_ID $ 4;

    RETAIN  Adjuster_ID
            Technician_ID;

    SET     adjuster_technician;
    BY      Cov_ID;

    IF      Claim_Info    =: 'A_'
      THEN  Adjuster_ID   =  COMPRESS(Claim_Info, ' A_');
      ELSE  Technician_ID =  COMPRESS(Claim_Info, ' T_');

    IF      LAST.Cov_ID;
RUN; 


/* adjuster_technician: Fix zip codes */

/* Create a table that summarizes the count of zips for each adjuster_id 
   The table is called tempAT */
PROC SUMMARY DATA = adjuster_technician NWAY;
    CLASS   Adjuster_ID Adj_ZIP;
    OUTPUT  OUT = tempAT (DROP = _type_);
RUN;

/* Sort to prepare for keeping only the most frequent zip */
PROC SORT DATA = tempAT;
    BY Adjuster_ID DESCENDING _FREQ_;
RUN;

/* Remove the less frequent zips from tempAT */
DATA tempAT;
    SET    tempAT;

    BY     Adjuster_ID;
    IF     FIRST.Adjuster_ID;
    RENAME Adj_ZIP = Adj_Zip_Corr;
RUN;

/* Sort to prepare for merge */
PROC SORT DATA = adjuster_technician;
    BY  Adjuster_ID;
RUN;

/* Merge the most common zip in for each Adjuster_ID */
DATA adjuster_technician(DROP = _FREQ_);
    MERGE adjuster_technician
          tempAT;

    BY    Adjuster_ID;
RUN;

/* Special Cases */
DATA adjuster_technician;  
    SET adjuster_technician;

    IF Adjuster_ID = '475' THEN Adj_Zip_Corr = '89014';
    IF Adjuster_ID = '476' THEN Adj_Zip_Corr = '89014';
    IF Adjuster_ID = '477' THEN Adj_Zip_Corr = '89014';
    IF Adjuster_ID = '478' THEN Adj_Zip_Corr = '89014';
    IF Adjuster_ID = '479' THEN Adj_Zip_Corr = '89014';
RUN;

/* Make Adj_Zip_Corr a numeric field b/c SAS prefers it */
DATA adjuster_technician(DROP = tZIP);
    SET adjuster_technician(RENAME=(Adj_Zip_Corr = tZIP));

    LENGTH  Corrected_Adj_ZIP 8.;
    FORMAT  Corrected_Adj_ZIP Z5.;

    Corrected_Adj_ZIP = INPUT(tZIP,8.);
RUN;


/* Delete the temp data set */
PROC DATASETS LIBRARY=work NOLIST;
    DELETE tempAT;
QUIT;

/* resort the data by Cov_ID */
PROC SORT DATA = adjuster_technician;
    BY Cov_ID;
RUN;




/* adjuster_technician: add Cust_ID for convenience */
DATA adjuster_technician;
    SET     adjuster_technician;
    LENGTH  Cust_ID $30;

    Cust_ID = SUBSTR(Cov_ID, 1, LENGTH(Cov_ID) - 1);
RUN;


/* Add radian geocoordinates for the adjuster corrected zip */

PROC SORT DATA = adjuster_technician;
    BY Corrected_Adj_ZIP;
RUN;

PROC SORT DATA = reference_zips;
    BY Ref_zip;
RUN;

DATA adjuster_technician;
    MERGE  adjuster_technician(RENAME=(Corrected_Adj_ZIP = Ref_zip) IN = inAdj)
           reference_zips;
    BY     Ref_zip;
    IF     inAdj;
    RENAME Ref_lon_rad = adj_lon_rad
           Ref_lat_rad = adj_lat_rad
           Ref_lat     = adj_lat
           Ref_lon     = adj_lon
           Ref_city    = adj_city
           Ref_state   = adj_state
           Ref_zip     = Corrected_Adj_ZIP;

    DROP   Ref_county Ref_county_fips Ref_state_fips;
RUN;

/* ------------------------------------------------------------------------------ */
/* ---------------- Cleaning customer_transactions ------------------------------ */
/* ------------------------------------------------------------------------------ */


/* customer_transactions: add the claim date and initial date to RE transactions */
/* customer_transactions: add the latest income and Cov_limit to RE transactions */

PROC SORT DATA = customer_transactions;
    BY Cov_ID Date;
RUN;

DATA customer_transactions;
    SET customer_transactions;

    LENGTH tIncome          8.
           tLimit           8.
           tDate            8.
           tDateIN          8.
           Claim_Date       8.
           Transaction_Date 8.
           Policy_Initiated 8.;

    FORMAT tDate            DATE9.
           Claim_Date       DATE9.
           Transaction_Date DATE9.
           Policy_Initiated DATE9.;

    RETAIN tIncome
           tLimit
           tDate
           tDateIN;

    BY  Cov_ID;

    Transaction_Date = Date;

    IF  FIRST.Cov_ID THEN 
        DO;
            IF Transaction = 'IN' THEN tDateIN = Date;
            tIncome          = income;
            tLimit           = cov_limit;
            tDate            = Date;
            Policy_Initiated = tDateIN;
        END;

    Policy_Initiated = tDateIN;

    IF  ~LAST.Cov_ID THEN
        DO;
            tIncome          = income;
            tLimit           = cov_limit;
            tDate            = Date;
        END;

    IF  LAST.Cov_ID & Transaction = 'RE' THEN
        DO;
            income           = tIncome;
            cov_limit        = tLimit;
            Claim_Date       = tDate;
            Policy_Initiated = tDateIN;
        END;

    DROP tIncome
         tLimit
         tDate
         Date
         tDateIN;
RUN;



/* customer_transactions: find the customers with RE transactions prior to CL transactions */ /* STEP 2 */

DATA _reward_before_claim;
    SET customer_transactions;
    IF  Transaction = 'RE' &
        Cov_Limit   = .;
RUN;

PROC SORT DATA = customer_transactions;
    BY Cust_ID Cov_ID Transaction_Date;
RUN;

/* customer_transactions: add the policy age at date of transaction */
DATA customer_transactions;
    SET customer_transactions;

    LENGTH Policy_Age_Years      5.2
           Adjudication_Days     8.;

    FORMAT Policy_Age_Years      5.2
           Reward_Date           DATE9.;

    IF Transaction = 'IN' THEN Policy_Age_Years = 0;
    ELSE Policy_Age_Years = (Transaction_Date - Policy_Initiated) / 365.2425;

    IF Transaction = 'RE' then
       DO;
            Reward_Date           = Transaction_Date;
            Adjudication_Days     = Reward_Date - Claim_Date;
       END;

RUN;

/* customer_transactions: for policies with only an IN transaction, 
   set the Policy_Age_Years equal to 01JUL2013 - Transaction_Date. */

/* Policy_Age_Years is the age of the policy at the time of transaction 
   UNLESS there is only a single IN transaction, in which case, it is the
   age of the policy as of 01JUL2013. */

DATA customer_transactions;
    SET customer_transactions;
    BY Cust_ID Cov_ID;

    IF FIRST.Cov_ID & LAST.COV_ID & Transaction = 'IN' THEN
      DO;
        Policy_Age_Years = ("01JUL2013"d - Transaction_Date) / 365.2425;
      END;
RUN;

/* customer_transactions: add a change_count to RE transactions
   so that we can see how many times they were changed prior to
   being claimed and rewarded. */

PROC SORT DATA = customer_transactions;
    BY Cov_ID Transaction_Date;
RUN;

DATA customer_transactions(DROP= tempcc);
    SET customer_transactions;

    LENGTH change_count 3
           tempcc       3;

    FORMAT change_count 3.
           tempcc       3.;

    BY     Cov_ID;

    IF     Transaction = 'IN' THEN tempcc = 0;
    IF     Transaction = 'CH' THEN tempcc + 1;
    * IF     LAST.Cov_ID & Transaction = 'RE' THEN change_count = tempcc;
    change_count = tempcc;

RUN;


/* customer_transactions: coding Reward_R into Reward as a categorical variable */
DATA customer_transactions;
    SET    customer_transactions;
    LENGTH Reward_Cat 3;

    IF      (Reward_R = .)           THEN Reward_Cat = .;
    ELSE IF (100 <= Reward_R <= 199) THEN Reward_Cat = 1;
    ELSE IF (200 <= Reward_R <= 299) THEN Reward_Cat = 2;
    ELSE IF (300 <= Reward_R <= 499) THEN Reward_Cat = 3;
    ELSE IF (500 <= Reward_R <= 549) THEN Reward_Cat = 4;
    ELSE IF (550 <= Reward_R <= 559) THEN Reward_Cat = 5;
    ELSE IF (560 <= Reward_R <= 569) THEN Reward_Cat = 6;
    ELSE IF (570 <= Reward_R <= 579) THEN Reward_Cat = 7;
    ELSE                                  Reward_Cat = 8;
RUN;



/* customer_transactions: create coverage/income ratio variable */

DATA customer_transactions;
    SET     customer_transactions;
    LENGTH  cov_income_ratio 6;
    FORMAT  cov_income_ratio 6.3;

    cov_income_ratio = Cov_Limit / Income;
RUN;





/* ------------------------------------------------------------------------------ */
/* ---------------- Cleaning customer_info -------------------------------------- */
/* ------------------------------------------------------------------------------ */

/* customer_info: fix the Zip Codes that have a missing digit by prepending '9' 
   and rename ZipCode to CustomerZip */



PROC SORT DATA = customer_info;
    BY ZipCode;
RUN;


/* Rename ZipCode to CustomerZip and remove white space */
DATA customer_info(DROP = tempZip);
    LENGTH CustomerZip $ 5;
    SET customer_info(RENAME=(ZipCode=tempZip));

    CustomerZip = COMPRESS(tempZip, ' ');
RUN;

/* Fix the zip codes with the missing 9 in front */
DATA customer_info;
    SET customer_info;
    IF LENGTH(CustomerZip) < 5 THEN CustomerZip = '9'||CustomerZip;
RUN;

/* Convert the CustomerZip to a numeric field to match the reference */
DATA customer_info(DROP = tZip);
    LENGTH CustomerZip 8.;
    FORMAT CustomerZip Z5.;

    SET customer_info(RENAME= (CustomerZip = tZip));
    CustomerZip = INPUT(tZip,8.);
RUN;



DATA customer_info;
    FORMAT Cust_AC $3.
           Cust_Ex $3.
           Cust_ACEX $6.;

    SET customer_info;

    Cust_AC = SUBSTR(TelephoneNumber,1,3);
    Cust_Ex = SUBSTR(TelephoneNumber,5,7);
    Cust_ACEX = Cust_AC||Cust_Ex;
RUN;



/* Merge with reference zips to get customer lat lon into the customer_info table */
PROC SORT DATA = customer_info;
    BY CustomerZip;
RUN;

PROC SORT DATA = reference_zips;
    BY Ref_zip;
RUN;

DATA customer_info;
    MERGE customer_info                                (IN = inCust)
          reference_zips(RENAME=(Ref_zip = CustomerZip) IN = inRef);
    BY    CustomerZip;
    IF    inCust;
    RENAME Ref_lat     = Cust_lat
           Ref_lon     = Cust_lon
           Ref_lat_rad = Cust_lat_rad
           Ref_lon_rad = Cust_lon_rad;

    DROP  Ref_city Ref_state Ref_county;
RUN;

/* Mark Customers with a valid zip code */
DATA customer_info;
    FORMAT valid_zip 3.;

    SET customer_info;
    IF  Cust_lat = . THEN valid_zip = 0;
    ELSE valid_zip = 1;
RUN;

PROC SORT DATA = customer_info;
    BY valid_zip;
RUN;

/* Try to look up an alternate zip code for customers 
   with a bad zip code, using area code and exchange
   as reference. */

PROC SORT DATA = customer_info;
    BY Cust_ACEX;
RUN;

DATA customer_info;
    MERGE customer_info (IN = inCust)
          phone_zips    (IN = inPhone);
    BY    Cust_ACEX; 
    IF    inCust;
RUN;

DATA customer_info(DROP = likely_zip Cust_ACEX Cust_AC Cust_Ex);
    LENGTH cust_best_zip 8.;
    FORMAT cust_best_zip Z5.;
    SET    customer_info;

    IF     valid_zip = 1 THEN cust_best_zip = CustomerZip;
    ELSE                      cust_best_zip = likely_zip;
RUN;

/* This is a fishy customer -- PSX00070114 -- bad zip and phone number. Fixing his 
   zip to match the zip of other people on the same street in Seattle.
   The zip of 19526 also is fishy and is in PA. Maybe it means 91526, but there
   still is no Hamburg, CA. */
DATA customer_info;
    FORMAT fishy 3.;
    SET customer_info;
    
    IF fishy = . THEN fishy = 0;

    IF  Cust_ID = 'PSX00070114' THEN 
      DO;
        cust_best_zip = 98101;
        fishy = 1;
      END;

    IF CustomerZip = 19526 THEN fishy = 1;
    
RUN;

/* Repeat the merge to find coordinates for the cust_best_zip
   in order to fill in blank values. Have to drop the existing
   correct ones and repeat them. There's got to be a better way
   to do this... */
DATA customer_info(DROP = Cust_lat Cust_lon Cust_lon_rad Cust_lat_rad);
    SET customer_info;
RUN;

PROC SORT DATA = customer_info;
    BY cust_best_zip;
RUN;

PROC SORT DATA = reference_zips;
    BY Ref_zip;
RUN;

DATA customer_info;
    MERGE customer_info                                  (IN = inCust)
          reference_zips(RENAME=(Ref_zip = cust_best_zip) IN = inRef);
    BY    cust_best_zip;
    IF    inCust;
    RENAME Ref_lat     = Cust_lat
           Ref_lon     = Cust_lon
           Ref_lat_rad = Cust_lat_rad
           Ref_lon_rad = Cust_lon_rad;

    DROP  Ref_city Ref_state Ref_county;
RUN;


PROC SORT DATA = reference_zips;
    BY Ref_state Ref_city Ref_zip;
RUN;





/* customer_info: separate the vehicle make from the model year */

DATA customer_info;
    SET     customer_info;

    LENGTH  vehicle_year     4
            vehicle_model $ 35;

    DROP    vehicle;

    vehicle_year  = SUBSTR(vehicle,1,4);
    vehicle_model = SUBSTR(vehicle,6);
RUN;




/* customer_info: change FeetInches to inches */

DATA customer_info;
    SET     customer_info;

    LENGTH  inches  3;

    DROP    feetinches
            feet
            t_inches;

    feet          = SUBSTR(feetinches,1,1) + 0;
    t_inches        = SUBSTR(feetinches, LENGTH(feetinches)-2,2) + 0;
    inches = (feet * 12) + t_inches;
RUN;




/* customer_info: create bmi, bmi_code, and bmi_prime variables */

DATA customer_info;
    SET     customer_info;

    LENGTH  bmi            5
            bmi_code       3
            bmi_prime      5;

    FORMAT  bmi            5.2
            bmi_prime      5.2;

    bmi           = (pounds/(inches * inches)) * 703;
    bmi_prime     = bmi / 25;

    IF      bmi < 15.0         THEN bmi_code = 1;
    ELSE IF 15.0 <= bmi < 16.0 THEN bmi_code = 2;
    ELSE IF 16.0 <= bmi < 18.5 THEN bmi_code = 3;
    ELSE IF 18.5 <= bmi < 25.0 THEN bmi_code = 4;
    ELSE IF 25.0 <= bmi < 30.0 THEN bmi_code = 5;
    ELSE IF 30.0 <= bmi < 35.0 THEN bmi_code = 6;
    ELSE IF 35.0 <= bmi < 40.0 THEN bmi_code = 7;
    ELSE IF 40.0 <= bmi < 99.0 THEN bmi_code = 8;
    ELSE DO; bmi = .; bmi_code = .; END;
RUN;




/* customer_info: Determine if an SSN is in use by more than one customer
                  and move those customers to a separate table for
                  additional review. */

PROC SORT DATA = customer_info;
    BY NationalID;
RUN;

DATA national_id_count(KEEP= NationalID Dup_SSN);
    SET customer_info;
    RETAIN Dup_SSN;

    BY NationalID;

    IF FIRST.NationalID THEN Dup_SSN = 0;

    Dup_SSN+1;

    IF LAST.NationalID;
RUN;

/* Sort again, just to be safe */
PROC SORT DATA = customer_info;
    BY NationalID;
RUN;

PROC SORT DATA = national_id_count;
    BY NationalID;
RUN;

/* Merge the count back into customer_info */
DATA customer_info;
    MERGE customer_info       (IN = inCust)
          national_id_count   (IN = inDup);

    BY    NationalID;
RUN;

/* Delete the temporary count table */
PROC DATASETS LIBRARY=work NOLIST;
    DELETE national_id_count;
QUIT;

DATA customer_info;
    SET customer_info;
    IF  Dup_SSN > 1 THEN Dup_SSN = 1;
    ELSE Dup_SSN = 0;
RUN;




/* ------------------------------------------------------------------------------ */
/* ---------------- Cleaning customer_medical ----------------------------------- */
/* ------------------------------------------------------------------------------ */


/* customer_medical: remove the useless observations - from RE transactions */
DATA customer_medical;
    SET customer_medical;

    IF Tobacco_Num ~= . THEN OUTPUT;
RUN;





/* ------------------------------------------------------------------------------ */
/* ---------------- Create Lookup Tables ---------------------------------------- */
/* ------------------------------------------------------------------------------ */

/* Lookup table for reward codes */
DATA codes_reward;

   LENGTH   Code_ID        3
            Code_Name     $22
            Code_Exclusion 3;

   INPUT    Code_ID         1-3
            Code_Name     $ 4-25
            Code_Exclusion  26-28;
   DATALINES;
0  Other                 0  
1  Accidental Death      0  
2  Criminal Acts         0  
3  Health Related Causes 0  
4  Dangerous Activity    1  
5  War                   1  
6  Aviation              1  
7  Suicide               1  
RUN;

/* Lookup table for BMI */
DATA codes_bmi;

   LENGTH   Code_ID        3
            Code_Name     $37;

   INPUT    Code_ID        1-3
            Code_Name     $4-40;
   DATALINES;
1  Very severely underweight            
2  Severely underweight                 
3  Underweight                          
4  Normal (healthy weight)              
5  Overweight                           
6  Obese Class I (Moderately obese)     
7  Obese Class II (Severely obese)      
8  Obese Class III (Very severely obese)
RUN;

* TODO: Create permanent formats out of these;





/* ------------------------------------------------------------------------------ */
/* ---------------- Combining Tables to Create Customer_Consolidated ------------ */
/* ------------------------------------------------------------------------------ */


/* Merge adjuster_technician with customer_transactions */
PROC SORT DATA = customer_transactions;
    BY      Cov_ID;
RUN;

PROC SORT DATA = adjuster_technician;
    BY      Cov_ID;
RUN;

DATA customer_transactions;
    MERGE customer_transactions  (IN = inCust)
          adjuster_technician    (IN = inAdj);

    BY    Cov_ID;

    IF    inCust;
RUN;

/* Locate RE transactions where there is no assigned adjuster */
/*DATA cust_rewards_no_adjuster;*/
/*    SET customer_transactions(WHERE(Transaction='RE'));*/
/*    IF  adj_lat = . OR*/
/*        adj_lon = .;*/
/*RUN;*/



/* Create a series of policy tables that will be merged and
   cleaned in order to create a series of variables that can
   be added to the customer information to describe their 
   policy stances. */

PROC SORT DATA = customer_transactions;
    BY Cov_ID Transaction_Date;
RUN;


DATA policies;
    SET customer_transactions(RENAME=(Transaction = Latest_Transaction));

    BY  Cov_ID;

    IF  (Transaction = 'RE' OR LAST.Cov_ID);
RUN;


PROC SUMMARY DATA = policies NWAY;
    CLASS   Cust_ID Type;
    OUTPUT  OUT = policyTemp (DROP = _type_);
RUN;


PROC SORT DATA = policyTemp;
    BY Cust_ID;
RUN;

DATA policyTypeCounts (DROP = Type _FREQ_);
    SET policyTemp;
    
    LENGTH has_whole      3
           has_term       3
           has_variable   3
           num_policies   3;

    FORMAT has_whole      3.
           has_term       3.
           has_variable   3.
           num_policies   3.;

    BY     Cust_ID;

    IF     FIRST.Cust_ID THEN
        DO;
           has_whole    = 0;
           has_term     = 0;
           has_variable = 0;
           num_policies = 0;
        END;

    IF     Type = 'W' THEN has_whole    + 1;
    IF     Type = 'T' THEN has_term     + 1;
    IF     Type = 'V' THEN has_variable + 1;

    IF     LAST.Cust_ID THEN 
         DO; 
           num_policies = has_whole + has_term + has_variable;
           OUTPUT;
         END;
RUN;

/* Merge this with customer_info */
PROC SORT DATA = policyTypeCounts;
    BY Cust_ID;
RUN;

PROC SORT DATA = customer_info;
    BY Cust_ID;
RUN;

DATA customer_info;
    MERGE customer_info    (IN = inCust)
          policyTypeCounts (IN = inPol);
    BY    Cust_ID;
    IF    inCust;
RUN;

/* Intermediate Cleanup */
PROC DATASETS LIBRARY = work NOLIST;
    DELETE policies
           policytemp
           policytypecounts;
QUIT;


PROC SORT DATA = customer_transactions;
    BY      Cust_ID Cov_ID Transaction_Date;
RUN;

DATA policies_term(DROP = Cov_ID Transaction Type Reward_R Reward_A Cov_Limit Income Claim_Date Transaction_Date
                          Policy_Initiated Policy_Age_Years Adjudication_Days Reward_Date change_count Reward_cat
                          cov_income_ratio Adj_Zip Corrected_Adj_Zip);

    SET     customer_transactions(WHERE=(Type = 'T'));
    BY      Cust_ID Cov_ID;

    LENGTH  Term_Cov_ID      $ 20
            Term_Initiated      8
            Term_Claim_Date     8
            Term_Reward_Date    8
            Term_Age_Years      5
            Term_Days_To_Reward 3
            Term_Change_Count   3
            Term_Cov_Limit      8
            Term_Income         8
            Term_Cov_Inc_Ratio  6
            Term_Reward_R       3
            Term_Reward_A       8
            Term_Reward_Cat     3
            Term_Status      $ 10
            Term_Adjuster_ID    3
            Term_Technician_ID  3
            Term_Adj_Zip     $ 30
            Term_Adj_Zip_Cor $  5;

    FORMAT  Term_Initiated      DATE9.
            Term_Claim_Date     DATE9.
            Term_Reward_Date    DATE9.
            Term_Age_Years      5.2
            Term_Days_To_Reward 3.
            Term_Change_Count   3.
            Term_Cov_Limit      8.
            Term_Income         8.
            Term_Cov_Inc_Ratio  6.3
            Term_Reward_R       3.
            Term_Reward_A       8.
            Term_Reward_Cat     3.
            Term_Adjuster_ID    3.
            Term_Technician_ID  3.;

    RETAIN  Term_Cov_ID
            Term_Initiated
            Term_Claim_Date
            Term_Reward_Date
            Term_Age_Years
            Term_Days_To_Reward
            Term_Change_Count
            Term_Cov_Limit
            Term_Income
            Term_Cov_Inc_Ratio
            Term_Reward_R
            Term_Reward_A
            Term_Reward_Cat
            Term_Status
            Term_Adjuster_ID
            Term_Technician_ID
            Term_Adj_Zip 
            Term_Adj_Zip_Cor;
            
    * Initialize all to missing;
    IF      FIRST.Cust_ID = 1 THEN 
        DO;
            Term_Cov_ID         = ' ';
            Term_Initiated      = .;
            Term_Claim_Date     = .; 
            Term_Reward_Date    = .;
            Term_Age_Years      = .;
            Term_Days_To_Reward = .;
            Term_Change_Count   = .;
            Term_Cov_Limit      = .;
            Term_Income         = .;
            Term_Cov_Inc_Ratio  = .;
            Term_Reward_R       = .;
            Term_Reward_A       = .;
            Term_Reward_Cat     = .;
            Term_Status         = ' ';
            Term_Adjuster_ID    = .;
            Term_Technician_ID  = .;
            Term_Adj_Zip        = ' ';
            Term_Adj_Zip_Cor    = ' ';
        END;

    * Get started with recording the proper values;
    IF      FIRST.Cov_ID = 1 THEN
        DO;
            IF Type = 'T' THEN
              DO;
                  Term_Cov_ID        = Cov_ID;              *PUTLOG 'Cov_ID=' Cov_ID; *PUTLOG 'Term_Cov_ID=' Term_Cov_ID;
                  Term_Initiated     = Transaction_Date;
                  Term_Status        = Transaction;
              END;
        END;
        
    * Processing Intermediate Transactions; 
    IF      ~FIRST.Cov_ID & ~LAST.Cov_ID THEN
        DO;
            IF Type = 'T' THEN
              DO;
                  Term_Status        = Transaction;
                  IF Term_Status  = 'CL' THEN Term_Claim_Date = Transaction_Date;
              END;
        END;

    * Processing Final Policy Transactions; 
    IF      LAST.Cov_ID THEN
        DO;
            IF Type = 'T' THEN
              DO;
                  Term_Income        = Income;
                  Term_Cov_Limit     = Cov_Limit;
                  Term_Cov_Inc_Ratio = Term_Cov_Limit / Term_Income;
                  Term_Status        = Transaction;
                  IF Term_Status     = 'CL' THEN Term_Claim_Date = Transaction_Date;

                  Term_Age_Years     = Policy_Age_Years;
                  Term_Change_Count  = change_count;
                  Term_Adj_Zip       = Adj_Zip;
                  Term_Adj_Zip_Cor   = Corrected_Adj_Zip;

                  IF Term_Status     = 'RE' THEN
                    DO;
                        Term_Reward_R    = Reward_R;
                        Term_Reward_A    = Reward_A;
                        Term_Reward_Date = Reward_Date;
                        Term_Reward_Cat  = Reward_Cat;
                        Term_Days_To_Reward = Adjudication_Days;
                    END;
              END;
        END;

    IF LAST.Cov_ID THEN OUTPUT;
RUN;



DATA policies_whole(DROP = Cov_ID Transaction Type Reward_R Reward_A Cov_Limit Income Claim_Date Transaction_Date
                           Policy_Initiated Policy_Age_Years Adjudication_Days Reward_Date change_count Reward_cat
                           cov_income_ratio Adj_Zip Corrected_Adj_Zip);

    SET     customer_transactions(WHERE=(Type = 'W'));
    BY      Cust_ID Cov_ID;

    LENGTH  Whole_Cov_ID      $ 20
            Whole_Initiated      8
            Whole_Claim_Date     8
            Whole_Reward_Date    8
            Whole_Age_Years      5
            Whole_Days_To_Reward 3
            Whole_Change_Count   3
            Whole_Cov_Limit      8
            Whole_Income         8
            Whole_Cov_Inc_Ratio  6
            Whole_Reward_R       3
            Whole_Reward_A       8
            Whole_Reward_Cat     3
            Whole_Status      $ 10
            Whole_Adjuster_ID    3
            Whole_Technician_ID  3
            Whole_Adj_Zip     $ 30
            Whole_Adj_Zip_Cor $  5;

    FORMAT  Whole_Initiated      DATE9.
            Whole_Claim_Date     DATE9.
            Whole_Reward_Date    DATE9.
            Whole_Age_Years      5.2
            Whole_Days_To_Reward 3.
            Whole_Change_Count   3.
            Whole_Cov_Limit      8.
            Whole_Income         8.
            Whole_Cov_Inc_Ratio  6.3
            Whole_Reward_R       3.
            Whole_Reward_A       8.
            Whole_Reward_Cat     3.
            Whole_Adjuster_ID    3.
            Whole_Technician_ID  3.;

    RETAIN  Whole_Cov_ID
            Whole_Initiated
            Whole_Claim_Date
            Whole_Reward_Date
            Whole_Age_Years
            Whole_Days_To_Reward
            Whole_Change_Count
            Whole_Cov_Limit
            Whole_Income
            Whole_Cov_Inc_Ratio
            Whole_Reward_R
            Whole_Reward_A
            Whole_Reward_Cat
            Whole_Status
            Whole_Adjuster_ID
            Whole_Technician_ID
            Whole_Adj_Zip  
            Whole_Adj_Zip_Cor;
            
    * Initialize all to missing;
    IF      FIRST.Cust_ID = 1 THEN 
        DO;
            Whole_Cov_ID        = ' ';
            Whole_Initiated     = .;
            Whole_Claim_Date    = .;
            Whole_Reward_Date   = .;
            Whole_Age_Years     = .;
            Whole_Days_To_Reward= .;
            Whole_Change_Count  = .;
            Whole_Cov_Limit     = .;
            Whole_Income        = .;
            Whole_Cov_Inc_Ratio = .;
            Whole_Reward_R      = .;
            Whole_Reward_A      = .;
            Whole_Reward_Cat    = .;
            Whole_Status        = ' ';
            Whole_Adjuster_ID   = .;
            Whole_Technician_ID = .;
            Whole_Adj_Zip       = ' ';
            Whole_Adj_Zip_Cor   = ' ';
        END;

    * Get started with recording the proper values;
    IF      FIRST.Cov_ID = 1 THEN
        DO;
            IF Type = 'W' THEN
              DO;
                  Whole_Cov_ID       = Cov_ID;
                  Whole_Initiated    = Transaction_Date;
                  Whole_Status       = Transaction;
              END;
        END;
        
    * Processing Intermediate Transactions; 
    IF      ~FIRST.Cov_ID & ~LAST.Cov_ID THEN
        DO;
            IF Type = 'W' THEN
              DO;
                  Whole_Status       = Transaction;
                  IF Whole_Status = 'CL' THEN Whole_Claim_Date = Transaction_Date;
              END;
        END;

    * Processing Final Policy Transactions; 
    IF      LAST.Cov_ID THEN
        DO;
            IF Type = 'W' THEN
              DO;
                  Whole_Income        = Income;
                  Whole_Cov_Limit     = Cov_Limit;
                  Whole_Cov_Inc_Ratio = Whole_Cov_Limit / Whole_Income;
                  Whole_Status        = Transaction;
                  IF Whole_Status     = 'CL' THEN Whole_Claim_Date = Transaction_Date;

                  Whole_Age_Years     = Policy_Age_Years;
                  Whole_Change_Count  = change_count;
                  Whole_Adj_Zip       = Adj_Zip;
                  Whole_Adj_Zip_Cor   = Corrected_Adj_Zip;

                  IF Whole_Status     = 'RE' THEN
                    DO;
                        Whole_Reward_R    = Reward_R;
                        Whole_Reward_A    = Reward_A;
                        Whole_Reward_Date = Reward_Date;
                        Whole_Reward_Cat  = Reward_Cat;
                        Whole_Days_To_Reward = Adjudication_Days;
                    END;
              END;
        END;

    IF LAST.Cov_ID THEN OUTPUT;
RUN;



DATA policies_var(DROP = Cov_ID Transaction Type Reward_R Reward_A Cov_Limit Income Claim_Date Transaction_Date
                          Policy_Initiated Policy_Age_Years Adjudication_Days Reward_Date change_count Reward_cat
                          cov_income_ratio Adj_Zip Corrected_Adj_Zip);

    SET     customer_transactions(WHERE=(Type = 'V'));
    BY      Cust_ID Cov_ID;

    LENGTH  Var_Cov_ID      $ 20
            Var_Initiated      8
            Var_Claim_Date     8
            Var_Reward_Date    8
            Var_Age_Years      5
            Var_Days_To_Reward 3
            Var_Change_Count   3
            Var_Cov_Limit      8
            Var_Income         8
            Var_Cov_Inc_Ratio  6
            Var_Reward_R       3
            Var_Reward_A       8
            Var_Reward_Cat     3
            Var_Status      $ 10
            Var_Adjuster_ID    3
            Var_Technician_ID  3
            Var_Adj_Zip     $ 30
            Var_Adj_Zip_Cor $  5;

    FORMAT  Var_Initiated      DATE9.
            Var_Claim_Date     DATE9.
            Var_Reward_Date    DATE9.
            Var_Age_Years      5.2
            Var_Days_To_Reward 3.
            Var_Change_Count   3.
            Var_Cov_Limit      8.
            Var_Income         8.
            Var_Cov_Inc_Ratio  6.3
            Var_Reward_R       3.
            Var_Reward_A       8.
            Var_Reward_Cat     3.
            Var_Adjuster_ID    3.
            Var_Technician_ID  3.;

    RETAIN  Var_Cov_ID
            Var_Initiated
            Var_Claim_Date
            Var_Reward_Date
            Var_Age_Years
            Var_Days_To_Reward
            Var_Change_Count
            Var_Cov_Limit
            Var_Income
            Var_Cov_Inc_Ratio
            Var_Reward_R
            Var_Reward_A
            Var_Reward_Cat
            Var_Status
            Var_Adjuster_ID
            Var_Technician_ID
            Var_Adj_Zip
            Var_Adj_Zip_Cor;
            
    * Initialize all to missing;
    IF      FIRST.Cust_ID = 1 THEN 
        DO;
            Var_Cov_ID          = ' ';
            Var_Initiated       = .;
            Var_Claim_Date      = .;
            Var_Reward_Date     = .;
            Var_Age_Years       = .;
            Var_Days_To_Reward  = .;
            Var_Change_Count    = .;
            Var_Cov_Limit       = .;
            Var_Income          = .;
            Var_Cov_Inc_Ratio   = .;
            Var_Reward_R        = .;
            Var_Reward_A        = .;
            Var_Reward_Cat      = .;
            Var_Status          = ' ';
            Var_Adjuster_ID     = .;
            Var_Technician_ID   = .;
            Var_Adj_Zip         = ' ';
            Var_Adj_Zip_Cor     = ' ';
        END;

    * Get started with recording the proper values;
    IF      FIRST.Cov_ID = 1 THEN
        DO;
            IF Type = 'V' THEN
              DO;
                  Var_Cov_ID         = Cov_ID;
                  Var_Initiated      = Transaction_Date;
                  Var_Status         = Transaction;
              END;
        END;
        
    * Processing Intermediate Transactions; 
    IF      ~FIRST.Cov_ID & ~LAST.Cov_ID THEN
        DO;
            IF Type = 'V' THEN
              DO;
                  Var_Status         = Transaction;
                  IF Var_Status   = 'CL' THEN Var_Claim_Date = Transaction_Date;
              END;
        END;

    * Processing Final Policy Transactions; 
    IF      LAST.Cov_ID THEN
        DO;
            IF Type = 'V' THEN
              DO;
                  Var_Income        = Income;
                  Var_Cov_Limit     = Cov_Limit;
                  Var_Cov_Inc_Ratio = Var_Cov_Limit / Var_Income;
                  Var_Status        = Transaction;
                  IF Var_Status     = 'CL' THEN Var_Claim_Date = Transaction_Date;
                  
                  Var_Age_Years     = Policy_Age_Years;
                  Var_Change_Count  = change_count;
                  Var_Adj_Zip       = Adj_Zip;
                  Var_Adj_Zip_Cor   = Corrected_Adj_Zip;

                  IF Var_Status     = 'RE' THEN
                    DO;
                        Var_Reward_R    = Reward_R;
                        Var_Reward_A    = Reward_A;
                        Var_Reward_Date = Reward_Date;
                        Var_Reward_Cat  = Reward_Cat;
                        Var_Days_To_Reward = Adjudication_Days;
                    END;
              END;
        END;

    IF LAST.Cov_ID THEN OUTPUT;
RUN;





/* Collapse Multiple Policy Overviews into a single observation
   for each type of policy. Separated mainly for convenience. */

PROC SORT DATA = Policies_term;
    BY Cust_ID Term_Cov_ID;
RUN;

DATA Policies_term_overview(DROP = t_Term_Age_Years     
                            t_Term_Days_To_Reward
                            t_Term_Change_Count  
                            t_Term_Cov_Limit     
                            t_Term_Income        
                            t_Term_Cov_Inc_Ratio   
                            t_Term_Reward_A  
                              Term_Cov_ID       
                              Term_Initiated     
                              Term_Claim_Date    
                              Term_Reward_Date   
                              Term_Reward_R           
                              Term_Reward_Cat    
                              Term_Status       
                              Term_Adjuster_ID   
                              Term_Technician_ID 
                              Term_Adj_Zip     
                              Term_Adj_Zip_Cor
                              Adjuster_ID
                              Technician_ID);

    SET Policies_term(RENAME=(       
                                Term_Age_Years      = t_Term_Age_Years     
                                Term_Days_To_Reward = t_Term_Days_To_Reward
                                Term_Change_Count   = t_Term_Change_Count  
                                Term_Cov_Limit      = t_Term_Cov_Limit     
                                Term_Income         = t_Term_Income        
                                Term_Cov_Inc_Ratio  = t_Term_Cov_Inc_Ratio   
                                Term_Reward_A       = t_Term_Reward_A      
                                ));
    BY Cust_ID Term_Cov_ID;

    FORMAT  Term_Age_Years          5.2
            Term_Days_To_Reward     3.
            Term_Change_Count       3.
            Term_Cov_Limit          8.
            Term_Income             8.
            Term_Cov_Inc_Ratio      6.3
            Term_Reward_A           8.
            Term_Count              3.
            Term_Count_Rewarded     3.
            Term_avg_Age_Years      5.2
            Term_avg_Days_To_Reward 5.2
            Term_avg_Change_Count   5.2
            Term_avg_Cov_Limit      8.
            Term_avg_Income         8.
            Term_avg_Cov_Inc_Ratio  6.3
            Term_avg_Reward_A       8.;

    RETAIN  Term_Age_Years
            Term_Days_To_Reward
            Term_Change_Count
            Term_Cov_Limit
            Term_Income
            Term_Cov_Inc_Ratio
            Term_Reward_A
            Term_Count
            Term_Count_Rewarded;

    * Initialize all to missing;
    IF      FIRST.Cust_ID THEN 
        DO;
            Term_Age_Years      = 0;
            Term_Days_To_Reward = 0;
            Term_Change_Count   = 0;
            Term_Cov_Limit      = 0;
            Term_Income         = 0;
            Term_Cov_Inc_Ratio  = 0;
            Term_Reward_A       = 0;
            Term_Count          = 0;
            Term_Count_Rewarded = 0;
        END;

    * Increment the counter;
    Term_Count + 1;

    * Increment the counter of rewarded term policies;
    IF Term_Status = 'RE' THEN Term_Count_Rewarded +1;

    Term_Age_Years      = SUM(Term_Age_Years     , t_Term_Age_Years     );
    Term_Days_To_Reward = SUM(Term_Days_To_Reward, t_Term_Days_To_Reward);
    Term_Change_Count   = SUM(Term_Change_Count  , t_Term_Change_Count  );
    Term_Cov_Limit      = SUM(Term_Cov_Limit     , t_Term_Cov_Limit     );
    Term_Income         = SUM(Term_Income        , t_Term_Income        );
    Term_Cov_Inc_Ratio  = SUM(Term_Cov_Inc_Ratio , t_Term_Cov_Inc_Ratio );
    Term_Reward_A       = SUM(Term_Reward_A      , t_Term_Reward_A      );

    IF      LAST.Cust_ID THEN
      DO;
            Term_avg_Age_Years      = Term_Age_Years      / Term_Count;
            Term_avg_Days_To_Reward = Term_Days_To_Reward / Term_Count;
            Term_avg_Change_Count   = Term_Change_Count   / Term_Count;
            Term_avg_Cov_Limit      = Term_Cov_Limit      / Term_Count;
            Term_avg_Income         = Term_Income         / Term_Count;
            Term_avg_Cov_Inc_Ratio  = Term_Cov_Inc_Ratio  / Term_Count;
            Term_avg_Reward_A       = Term_Reward_A       / Term_Count;
            OUTPUT;
      END;
RUN;

PROC SORT DATA = Policies_whole;
    BY Cust_ID Whole_Cov_ID;
RUN;

DATA Policies_whole_overview(DROP = t_Whole_Age_Years     
                            t_Whole_Days_To_Reward
                            t_Whole_Change_Count  
                            t_Whole_Cov_Limit     
                            t_Whole_Income        
                            t_Whole_Cov_Inc_Ratio   
                            t_Whole_Reward_A  
                              Whole_Cov_ID       
                              Whole_Initiated     
                              Whole_Claim_Date    
                              Whole_Reward_Date   
                              Whole_Reward_R           
                              Whole_Reward_Cat    
                              Whole_Status       
                              Whole_Adjuster_ID   
                              Whole_Technician_ID 
                              Whole_Adj_Zip     
                              Whole_Adj_Zip_Cor
                              Adjuster_ID
                              Technician_ID);

    SET Policies_whole(RENAME=(       
                                Whole_Age_Years      = t_Whole_Age_Years     
                                Whole_Days_To_Reward = t_Whole_Days_To_Reward
                                Whole_Change_Count   = t_Whole_Change_Count  
                                Whole_Cov_Limit      = t_Whole_Cov_Limit     
                                Whole_Income         = t_Whole_Income        
                                Whole_Cov_Inc_Ratio  = t_Whole_Cov_Inc_Ratio   
                                Whole_Reward_A       = t_Whole_Reward_A      
                                ));
    BY Cust_ID Whole_Cov_ID;

    FORMAT  Whole_Age_Years          5.2
            Whole_Days_To_Reward     3.
            Whole_Change_Count       3.
            Whole_Cov_Limit          8.
            Whole_Income             8.
            Whole_Cov_Inc_Ratio      6.3
            Whole_Reward_A           8.
            Whole_Count              3.
            Whole_Count_Rewarded     3.
            Whole_avg_Age_Years      5.2
            Whole_avg_Days_To_Reward 5.2
            Whole_avg_Change_Count   5.2
            Whole_avg_Cov_Limit      8.
            Whole_avg_Income         8.
            Whole_avg_Cov_Inc_Ratio  6.3
            Whole_avg_Reward_A       8.;

    RETAIN  Whole_Age_Years
            Whole_Days_To_Reward
            Whole_Change_Count
            Whole_Cov_Limit
            Whole_Income
            Whole_Cov_Inc_Ratio
            Whole_Reward_A
            Whole_Count
            Whole_Count_Rewarded;

    * Initialize all to missing;
    IF      FIRST.Cust_ID THEN 
        DO;
            Whole_Age_Years      = 0;
            Whole_Days_To_Reward = 0;
            Whole_Change_Count   = 0;
            Whole_Cov_Limit      = 0;
            Whole_Income         = 0;
            Whole_Cov_Inc_Ratio  = 0;
            Whole_Reward_A       = 0;
            Whole_Count          = 0;
            Whole_Count_Rewarded = 0;
        END;

    * Increment the counter;
    Whole_Count + 1;

    * Increment the counter of rewarded term policies;
    IF Whole_Status = 'RE' THEN Whole_Count_Rewarded +1;

    Whole_Age_Years      = SUM(Whole_Age_Years     , t_Whole_Age_Years     );
    Whole_Days_To_Reward = SUM(Whole_Days_To_Reward, t_Whole_Days_To_Reward);
    Whole_Change_Count   = SUM(Whole_Change_Count  , t_Whole_Change_Count  );
    Whole_Cov_Limit      = SUM(Whole_Cov_Limit     , t_Whole_Cov_Limit     );
    Whole_Income         = SUM(Whole_Income        , t_Whole_Income        );
    Whole_Cov_Inc_Ratio  = SUM(Whole_Cov_Inc_Ratio , t_Whole_Cov_Inc_Ratio );
    Whole_Reward_A       = SUM(Whole_Reward_A      , t_Whole_Reward_A      );

    IF      LAST.Cust_ID THEN
      DO;
            Whole_avg_Age_Years      = Whole_Age_Years      / Whole_Count;
            Whole_avg_Days_To_Reward = Whole_Days_To_Reward / Whole_Count;
            Whole_avg_Change_Count   = Whole_Change_Count   / Whole_Count;
            Whole_avg_Cov_Limit      = Whole_Cov_Limit      / Whole_Count;
            Whole_avg_Income         = Whole_Income         / Whole_Count;
            Whole_avg_Cov_Inc_Ratio  = Whole_Cov_Inc_Ratio  / Whole_Count;
            Whole_avg_Reward_A       = Whole_Reward_A       / Whole_Count;
            OUTPUT;
      END;
RUN;

PROC SORT DATA = Policies_var;
    BY Cust_ID Var_Cov_ID;
RUN;

DATA Policies_var_overview(DROP = t_Var_Age_Years     
                            t_Var_Days_To_Reward
                            t_Var_Change_Count  
                            t_Var_Cov_Limit     
                            t_Var_Income        
                            t_Var_Cov_Inc_Ratio   
                            t_Var_Reward_A  
                              Var_Cov_ID       
                              Var_Initiated     
                              Var_Claim_Date    
                              Var_Reward_Date   
                              Var_Reward_R           
                              Var_Reward_Cat    
                              Var_Status       
                              Var_Adjuster_ID   
                              Var_Technician_ID 
                              Var_Adj_Zip     
                              Var_Adj_Zip_Cor
                              Adjuster_ID
                              Technician_ID);

    SET Policies_var(RENAME=(       
                                Var_Age_Years      = t_Var_Age_Years     
                                Var_Days_To_Reward = t_Var_Days_To_Reward
                                Var_Change_Count   = t_Var_Change_Count  
                                Var_Cov_Limit      = t_Var_Cov_Limit     
                                Var_Income         = t_Var_Income        
                                Var_Cov_Inc_Ratio  = t_Var_Cov_Inc_Ratio   
                                Var_Reward_A       = t_Var_Reward_A      
                                ));
    BY Cust_ID Var_Cov_ID;

    FORMAT  Var_Age_Years          5.2
            Var_Days_To_Reward     3.
            Var_Change_Count       3.
            Var_Cov_Limit          8.
            Var_Income             8.
            Var_Cov_Inc_Ratio      6.3
            Var_Reward_A           8.
            Var_Count              3.
            Var_Count_Rewarded     3.
            Var_avg_Age_Years      5.2
            Var_avg_Days_To_Reward 5.2
            Var_avg_Change_Count   5.2
            Var_avg_Cov_Limit      8.
            Var_avg_Income         8.
            Var_avg_Cov_Inc_Ratio  6.3
            Var_avg_Reward_A       8.;

    RETAIN  Var_Age_Years
            Var_Days_To_Reward
            Var_Change_Count
            Var_Cov_Limit
            Var_Income
            Var_Cov_Inc_Ratio
            Var_Reward_A
            Var_Count
            Var_Count_Rewarded;

    * Initialize all to missing;
    IF      FIRST.Cust_ID THEN 
        DO;
            Var_Age_Years      = 0;
            Var_Days_To_Reward = 0;
            Var_Change_Count   = 0;
            Var_Cov_Limit      = 0;
            Var_Income         = 0;
            Var_Cov_Inc_Ratio  = 0;
            Var_Reward_A       = 0;
            Var_Count          = 0;
            Var_Count_Rewarded = 0;
        END;

    * Increment the counter;
    Var_Count + 1;

    * Increment the counter of rewarded term policies;
    IF Var_Status = 'RE' THEN Var_Count_Rewarded +1;

    Var_Age_Years      = SUM(Var_Age_Years     , t_Var_Age_Years     );
    Var_Days_To_Reward = SUM(Var_Days_To_Reward, t_Var_Days_To_Reward);
    Var_Change_Count   = SUM(Var_Change_Count  , t_Var_Change_Count  );
    Var_Cov_Limit      = SUM(Var_Cov_Limit     , t_Var_Cov_Limit     );
    Var_Income         = SUM(Var_Income        , t_Var_Income        );
    Var_Cov_Inc_Ratio  = SUM(Var_Cov_Inc_Ratio , t_Var_Cov_Inc_Ratio );
    Var_Reward_A       = SUM(Var_Reward_A      , t_Var_Reward_A      );

    IF      LAST.Cust_ID THEN
      DO;
            Var_avg_Age_Years      = Var_Age_Years      / Var_Count;
            Var_avg_Days_To_Reward = Var_Days_To_Reward / Var_Count;
            Var_avg_Change_Count   = Var_Change_Count   / Var_Count;
            Var_avg_Cov_Limit      = Var_Cov_Limit      / Var_Count;
            Var_avg_Income         = Var_Income         / Var_Count;
            Var_avg_Cov_Inc_Ratio  = Var_Cov_Inc_Ratio  / Var_Count;
            Var_avg_Reward_A       = Var_Reward_A       / Var_Count;
            OUTPUT;
      END;
RUN;



/* Combine The policy overview tables into a single table */

* Start by getting a full list of customer ids;
DATA id_list;
    SET Customer_info;
    KEEP Cust_ID;
RUN;

PROC SORT DATA = id_list;
    BY Cust_ID;
RUN;

PROC SORT DATA = Policies_term_overview;
    BY Cust_ID;
RUN;

DATA consolidated_policies;
    MERGE id_list                (IN = inID)
          Policies_term_overview (IN = inTerm);
    BY    Cust_ID;
    IF    inID;
RUN;

PROC SORT DATA = consolidated_policies;
    BY Cust_ID;
RUN;

PROC SORT DATA = Policies_whole_overview;
    BY Cust_ID;
RUN;

DATA consolidated_policies;
    MERGE consolidated_policies   (IN = inCon)
          Policies_whole_overview (IN = inWhole);
    BY    Cust_ID;
    IF    inCon;
RUN;

PROC SORT DATA = consolidated_policies;
    BY Cust_ID;
RUN;

PROC SORT DATA = Policies_var_overview;
    BY Cust_ID;
RUN;

DATA consolidated_policies;
    MERGE consolidated_policies (IN = inCon)
          Policies_var_overview (IN = inVar);
    BY    Cust_ID;
    IF    inCon;
RUN;







/* Create "Grand" Totals from the overviews in the consolidated policies table */
/* The importance to these is that every customer will have values here that
   summarize their policy stances */

DATA consolidated_policies;
    SET consolidated_policies;

    FORMAT  Grand_Age_Years          5.2
            Grand_Days_To_Reward     3.
            Grand_Change_Count       3.
            Grand_Cov_Limit          8.
            Grand_Income             8.
            Grand_Cov_Inc_Ratio      6.3
            Grand_Reward_A           8.
            Grand_Count              3.
            Grand_Count_Rewarded     3.
            Grand_avg_Age_Years      5.2
            Grand_avg_Days_To_Reward 5.2
            Grand_avg_Change_Count   5.2
            Grand_avg_Cov_Limit      8.
            Grand_avg_Income         8.
            Grand_avg_Cov_Inc_Ratio  6.3
            Grand_avg_Reward_A       8.;

    Grand_Age_Years          = SUM( Term_Age_Years          , Whole_Age_Years          , Var_Age_Years          );
    Grand_Days_To_Reward     = SUM( Term_Days_To_Reward     , Whole_Days_To_Reward     , Var_Days_To_Reward     );
    Grand_Change_Count       = SUM( Term_Change_Count       , Whole_Change_Count       , Var_Change_Count       );
    Grand_Cov_Limit          = SUM( Term_Cov_Limit          , Whole_Cov_Limit          , Var_Cov_Limit          );
    Grand_Income             = SUM( Term_Income             , Whole_Income             , Var_Income             );
    Grand_Cov_Inc_Ratio      = SUM( Term_Cov_Inc_Ratio      , Whole_Cov_Inc_Ratio      , Var_Cov_Inc_Ratio      );
    Grand_Reward_A           = SUM( Term_Reward_A           , Whole_Reward_A           , Var_Reward_A           );
    Grand_Count              = SUM( Term_Count              , Whole_Count              , Var_Count              );
    Grand_Count_Rewarded     = SUM( Term_Count_Rewarded     , Whole_Count_Rewarded     , Var_Count_Rewarded     );
    Grand_avg_Age_Years      = SUM( Term_avg_Age_Years      , Whole_avg_Age_Years      , Var_avg_Age_Years      );
    Grand_avg_Days_To_Reward = SUM( Term_avg_Days_To_Reward , Whole_avg_Days_To_Reward , Var_avg_Days_To_Reward );
    Grand_avg_Change_Count   = SUM( Term_avg_Change_Count   , Whole_avg_Change_Count   , Var_avg_Change_Count   );
    Grand_avg_Cov_Limit      = SUM( Term_avg_Cov_Limit      , Whole_avg_Cov_Limit      , Var_avg_Cov_Limit      );
    Grand_avg_Income         = SUM( Term_avg_Income         , Whole_avg_Income         , Var_avg_Income         );
    Grand_avg_Cov_Inc_Ratio  = SUM( Term_avg_Cov_Inc_Ratio  , Whole_avg_Cov_Inc_Ratio  , Var_avg_Cov_Inc_Ratio  );
    Grand_avg_Reward_A       = SUM( Term_avg_Reward_A       , Whole_avg_Reward_A       , Var_avg_Reward_A       );

RUN;





/* Create the customer medical profile with the bad health index */

PROC SORT DATA = customer_medical;
    BY Cust_ID Cov_ID Date;
RUN;

/* Medical Model Weighting Criteria for severity */

%LET factor_Tobacco  = 10; * History of using tobacco;
%LET factor_Caffeine = 3;  * History of using caffeine;
%LET factor_Alcohol  = 7;  * History of using alcohol;

%LET factor_HA   = 15; * Heart Attack;
%LET factor_BP   = 9;  * High Blood Pressure;
%LET factor_Can  = 15; * Cancer;
%LET factor_Diab = 8;  * Diabetes;
%LET factor_Chol = 7;  * High Cholesterol;
%LET factor_Arth = 2;  * Arthritis;
%LET factor_Asth = 3;  * Asthma;
%LET factor_Gla  = 2;  * Glacoma;
%LET factor_Kid  = 5;  * Kidney Disease;
%LET factor_Leuk = 4;  * Leukemia;
%LET factor_Ment = 6;  * Mental Illness;
%LET factor_SE   = 4;  * Seizures / Epilepsy;
%LET factor_SCA  = 10; * Sickle Cell Anemia;
%LET factor_Str  = 15; * Stroke;
%LET factor_TD   = 4;  * Thyroid disorders;
%LET factor_TB   = 11; * Tuberculosis;
%LET factor_Ul   = 6;  * Ulcers;


DATA customer_medical_risk(DROP =   Tobacco_Num
                                    Caffeine_Num
                                    Alcohol_Num
                                    Tobacco
                                    Caffeine
                                    Alcohol
                                    Med_HA
                                    Med_BP
                                    Med_Can
                                    Med_Diab
                                    Med_Chol
                                    Med_Arth
                                    Med_Asth
                                    Med_Gla
                                    Med_Kid
                                    Med_Leuk
                                    Med_Ment
                                    Med_SE
                                    Med_SCA
                                    Med_Str
                                    Med_TD
                                    Med_TB
                                    Med_Ul
                                    Cov_ID
                                    Date);
    SET customer_medical;
    BY  Cust_ID;

    FORMAT Tobacco_Num_Score  5.2
           Caffeine_Num_Score 5.2
           Alcohol_Num_Score  5.2
           Tobacco_Score      5.2
           Caffeine_Score     5.2
           Alcohol_Score      5.2
           Med_HA_Score       5.2
           Med_BP_Score       5.2
           Med_Can_Score      5.2
           Med_Diab_Score     5.2
           Med_Chol_Score     5.2
           Med_Arth_Score     5.2
           Med_Asth_Score     5.2
           Med_Gla_Score      5.2
           Med_Kid_Score      5.2
           Med_Leuk_Score     5.2
           Med_Ment_Score     5.2
           Med_SE_Score       5.2
           Med_SCA_Score      5.2
           Med_Str_Score      5.2
           Med_TD_Score       5.2
           Med_TB_Score       5.2
           Med_Ul_Score       5.2
           Med_Record_Count   3.
           Bad_Health_Index   5.2;

    RETAIN Tobacco_Num_Score
           Caffeine_Num_Score
           Alcohol_Num_Score
           Tobacco_Score
           Caffeine_Score     
           Alcohol_Score      
           Med_HA_Score       
           Med_BP_Score       
           Med_Can_Score      
           Med_Diab_Score     
           Med_Chol_Score     
           Med_Arth_Score     
           Med_Asth_Score     
           Med_Gla_Score      
           Med_Kid_Score      
           Med_Leuk_Score     
           Med_Ment_Score  
           Med_SE_Score       
           Med_SCA_Score      
           Med_Str_Score      
           Med_TD_Score
           Med_TB_Score 
           Med_Ul_Score
           Med_Record_Count
           Bad_Health_Index;

    IF    FIRST.Cust_ID THEN
        DO;
           Tobacco_Num_Score  = 0;
           Caffeine_Num_Score = 0;
           Alcohol_Num_Score  = 0;
           Tobacco_Score      = 0;
           Caffeine_Score     = 0;
           Alcohol_Score      = 0;
           Med_HA_Score       = 0;
           Med_BP_Score       = 0;
           Med_Can_Score      = 0;
           Med_Diab_Score     = 0;
           Med_Chol_Score     = 0;
           Med_Arth_Score     = 0;
           Med_Asth_Score     = 0;
           Med_Gla_Score      = 0;
           Med_Kid_Score      = 0;
           Med_Leuk_Score     = 0;
           Med_Ment_Score     = 0;
           Med_SE_Score       = 0;
           Med_SCA_Score      = 0;
           Med_Str_Score      = 0;
           Med_TD_Score       = 0;
           Med_TB_Score       = 0;
           Med_Ul_Score       = 0;
           Med_Record_Count   = 0;
           Bad_Health_Index   = 0;
        END;

    * For each record, add the value. At the last record, divide by the count;
    Med_Record_Count + 1;

    Tobacco_Num_Score  + Tobacco_Num;
    Caffeine_Num_Score + Caffeine_Num;
    Alcohol_Num_Score  + Alcohol_Num;

    IF Tobacco  = 'Y' THEN Tobacco_Score  + 1;
    IF Caffeine = 'Y' THEN Caffeine_Score + 1; * May be beneficial;
    IF Alcohol  = 'Y' THEN Alcohol_Score  + 1; * May be beneficial;
    IF Med_HA   = 'Y' THEN Med_HA_Score   + 1; 
    IF Med_BP   = 'Y' THEN Med_BP_Score   + 1;
    IF Med_Can  = 'Y' THEN Med_Can_Score  + 1;
    IF Med_Diab = 'Y' THEN Med_Diab_Score + 1;
    IF Med_Chol = 'Y' THEN Med_Chol_Score + 1;
    IF Med_Arth = 'Y' THEN Med_Arth_Score + 1;
    IF Med_Asth = 'Y' THEN Med_Asth_Score + 1;
    IF Med_Gla  = 'Y' THEN Med_Gla_Score  + 1;
    IF Med_Kid  = 'Y' THEN Med_Kid_Score  + 1;
    IF Med_Leuk = 'Y' THEN Med_Leuk_Score + 1;
    IF Med_Ment = 'Y' THEN Med_Ment_Score + 1;
    IF Med_SE   = 'Y' THEN Med_SE_Score   + 1;
    IF Med_SCA  = 'Y' THEN Med_SCA_Score  + 1;
    IF Med_Str  = 'Y' THEN Med_Str_Score  + 1;
    IF Med_TD   = 'Y' THEN Med_TD_Score   + 1;
    IF Med_TB   = 'Y' THEN Med_TB_Score   + 1;
    IF Med_Ul   = 'Y' THEN Med_Ul_Score   + 1;

    IF      LAST.Cust_ID THEN 
        DO;
           Tobacco_Num_Score  =                    (Tobacco_Num_Score  / Med_Record_Count);
           Caffeine_Num_Score =                    (Caffeine_Num_Score / Med_Record_Count);
           Alcohol_Num_Score  =                    (Alcohol_Num_Score  / Med_Record_Count);
           Tobacco_Score      = &factor_Tobacco  * (Tobacco_Score      / Med_Record_Count);
           Caffeine_Score     = &factor_Caffeine * (Caffeine_Score     / Med_Record_Count);
           Alcohol_Score      = &factor_Alcohol  * (Alcohol_Score      / Med_Record_Count);

           Med_HA_Score       = &factor_HA   * (Med_HA_Score       / Med_Record_Count);
           Med_BP_Score       = &factor_BP   * (Med_BP_Score       / Med_Record_Count);
           Med_Can_Score      = &factor_Can  * (Med_Can_Score      / Med_Record_Count);
           Med_Diab_Score     = &factor_Diab * (Med_Diab_Score     / Med_Record_Count);
           Med_Chol_Score     = &factor_Chol * (Med_Chol_Score     / Med_Record_Count);
           Med_Arth_Score     = &factor_Arth * (Med_Arth_Score     / Med_Record_Count);
           Med_Asth_Score     = &factor_Asth * (Med_Asth_Score     / Med_Record_Count);
           Med_Gla_Score      = &factor_Gla  * (Med_Gla_Score      / Med_Record_Count);
           Med_Kid_Score      = &factor_Kid  * (Med_Kid_Score      / Med_Record_Count);
           Med_Leuk_Score     = &factor_Leuk * (Med_Leuk_Score     / Med_Record_Count);
           Med_Ment_Score     = &factor_Ment * (Med_Ment_Score     / Med_Record_Count);
           Med_SE_Score       = &factor_SE   * (Med_SE_Score       / Med_Record_Count);
           Med_SCA_Score      = &factor_SCA  * (Med_SCA_Score      / Med_Record_Count);
           Med_Str_Score      = &factor_Str  * (Med_Str_Score      / Med_Record_Count);
           Med_TD_Score       = &factor_TD   * (Med_TD_Score       / Med_Record_Count);
           Med_TB_Score       = &factor_TB   * (Med_TB_Score       / Med_Record_Count);
           Med_Ul_Score       = &factor_Ul   * (Med_Ul_Score       / Med_Record_Count);
           OUTPUT;
        END;
RUN;




/* There is one customer_family_medical record per customer. Combine with customer_medical_risk */

PROC SORT DATA = customer_family_medical;
    BY Cust_ID;
RUN;

PROC SORT DATA = customer_medical_risk;
    BY Cust_ID;
RUN;

DATA customer_medical_risk;
    MERGE customer_medical_risk (IN = inRisk)
          customer_family_medical (IN = inFam);
    BY    Cust_ID;
    IF    inRisk;
RUN;





* Incorporate family medical data into risk profile;
DATA customer_medical_risk (DROP =  MedF_HA  
                                    MedF_BP  
                                    MedF_Can 
                                    MedF_Diab
                                    MedF_Chol
                                    MedF_Arth
                                    MedF_Asth
                                    MedF_Gla 
                                    MedF_Kid 
                                    MedF_Leuk
                                    MedF_Ment
                                    MedF_SE  
                                    MedF_SCA 
                                    MedF_Str 
                                    MedF_TD  
                                    MedF_TB  
                                    MedF_Ul  
                                    MedM_HA  
                                    MedM_BP  
                                    MedM_Can 
                                    MedM_Diab
                                    MedM_Chol
                                    MedM_Arth
                                    MedM_Asth
                                    MedM_Gla 
                                    MedM_Kid 
                                    MedM_Leuk
                                    MedM_Ment
                                    MedM_SE  
                                    MedM_SCA 
                                    MedM_Str 
                                    MedM_TD  
                                    MedM_TB  
                                    MedM_Ul);
    SET customer_medical_risk;

    IF MedF_HA   = 'Y' THEN Med_HA_Score   + (&factor_HA   * 0.2);
    IF MedF_BP   = 'Y' THEN Med_BP_Score   + (&factor_BP   * 0.2);
    IF MedF_Can  = 'Y' THEN Med_Can_Score  + (&factor_Can  * 0.2);
    IF MedF_Diab = 'Y' THEN Med_Diab_Score + (&factor_Diab * 0.2);
    IF MedF_Chol = 'Y' THEN Med_Chol_Score + (&factor_Chol * 0.2);
    IF MedF_Arth = 'Y' THEN Med_Arth_Score + (&factor_Arth * 0.2);
    IF MedF_Asth = 'Y' THEN Med_Asth_Score + (&factor_Asth * 0.2);
    IF MedF_Gla  = 'Y' THEN Med_Gla_Score  + (&factor_Gla  * 0.2);
    IF MedF_Kid  = 'Y' THEN Med_Kid_Score  + (&factor_Kid  * 0.2);
    IF MedF_Leuk = 'Y' THEN Med_Leuk_Score + (&factor_Leuk * 0.2);
    IF MedF_Ment = 'Y' THEN Med_Ment_Score + (&factor_Ment * 0.2);
    IF MedF_SE   = 'Y' THEN Med_SE_Score   + (&factor_SE   * 0.2);
    IF MedF_SCA  = 'Y' THEN Med_SCA_Score  + (&factor_SCA  * 0.2);
    IF MedF_Str  = 'Y' THEN Med_Str_Score  + (&factor_Str  * 0.2);
    IF MedF_TD   = 'Y' THEN Med_TD_Score   + (&factor_TD   * 0.2);
    IF MedF_TB   = 'Y' THEN Med_TB_Score   + (&factor_TB   * 0.2);
    IF MedF_Ul   = 'Y' THEN Med_Ul_Score   + (&factor_Ul   * 0.2);

    IF MedM_HA   = 'Y' THEN Med_HA_Score   + (&factor_HA   * 0.2);
    IF MedM_BP   = 'Y' THEN Med_BP_Score   + (&factor_BP   * 0.2);
    IF MedM_Can  = 'Y' THEN Med_Can_Score  + (&factor_Can  * 0.2);
    IF MedM_Diab = 'Y' THEN Med_Diab_Score + (&factor_Diab * 0.2);
    IF MedM_Chol = 'Y' THEN Med_Chol_Score + (&factor_Chol * 0.2);
    IF MedM_Arth = 'Y' THEN Med_Arth_Score + (&factor_Arth * 0.2);
    IF MedM_Asth = 'Y' THEN Med_Asth_Score + (&factor_Asth * 0.2);
    IF MedM_Gla  = 'Y' THEN Med_Gla_Score  + (&factor_Gla  * 0.2);
    IF MedM_Kid  = 'Y' THEN Med_Kid_Score  + (&factor_Kid  * 0.2);
    IF MedM_Leuk = 'Y' THEN Med_Leuk_Score + (&factor_Leuk * 0.2);
    IF MedM_Ment = 'Y' THEN Med_Ment_Score + (&factor_Ment * 0.2);
    IF MedM_SE   = 'Y' THEN Med_SE_Score   + (&factor_SE   * 0.2);
    IF MedM_SCA  = 'Y' THEN Med_SCA_Score  + (&factor_SCA  * 0.2);
    IF MedM_Str  = 'Y' THEN Med_Str_Score  + (&factor_Str  * 0.2);
    IF MedM_TD   = 'Y' THEN Med_TD_Score   + (&factor_TD   * 0.2);
    IF MedM_TB   = 'Y' THEN Med_TB_Score   + (&factor_TB   * 0.2);
    IF MedM_Ul   = 'Y' THEN Med_Ul_Score   + (&factor_Ul   * 0.2);

    Bad_Health_Index   = Tobacco_Num_Score     + Tobacco_Score  + Med_HA_Score 
                              + Med_BP_Score   + Med_Can_Score  + Med_Diab_Score
                              + Med_Chol_Score + Med_Arth_Score + Med_Asth_Score
                              + Med_Gla_Score  + Med_Kid_Score  + Med_Leuk_Score
                              + Med_Ment_Score + Med_SE_Score   + Med_SCA_Score
                              + Med_Str_Score  + Med_TD_Score   + Med_TB_Score
                              + Med_Ul_Score;
RUN;


PROC SORT DATA = customer_info;
    BY Cust_ID;
RUN;

PROC SORT DATA = customer_medical_risk;
    BY Cust_ID;
RUN;

DATA customer_consolidated;
    MERGE customer_info           (IN = inInfo)
          customer_medical_risk   (IN = inRisk);

    BY    Cust_ID;

    IF    inInfo;
RUN;







/* Insert the approximate age at death into customer info */
/* NOTE: this does not take into consideration the people
   who have false death claims on their record. It simply
   looks at the first RE Transaction for a customer and grabs
   the claim date, Reward_R, and Reward_Cat values. */

PROC SORT DATA = customer_transactions;
    BY Cust_ID Transaction_Date;
RUN;

DATA rewards(KEEP = Cust_ID 
                    Claim_Date 
                    Reward_R 
                    Reward_Cat 
                    Adjuster_ID 
                    Technician_ID 
                    Adj_ZIP 
                    Corrected_Adj_ZIP
                    adj_city
                    adj_state);

    SET customer_transactions(WHERE=(Transaction = 'RE'));
    BY  Cust_ID;

    IF  FIRST.Cust_ID THEN OUTPUT;
RUN;

/* Rename some variables */
DATA rewards;
    SET rewards(RENAME=( Reward_R          = Death_Reward_R
                         Reward_Cat        = Death_Reward_Cat
                         Claim_Date        = Death_Date_Est
                         Adjuster_ID       = Death_Adjuster
                         Technician_ID     = Death_Technician
                         Adj_Zip           = Death_Adj_ZIP
                         Corrected_Adj_ZIP = Death_Corr_Adj_ZIP
                         adj_city          = Death_Adj_City
                         adj_state         = Death_Adj_State
                ));
RUN;


/* Add some Death-related variables */
PROC SORT DATA = rewards;
    BY  Cust_ID;
RUN;

PROC SORT DATA = customer_consolidated;
    BY  Cust_ID;
RUN;

DATA customer_consolidated;
    MERGE customer_consolidated (IN = inCust)
          rewards               (IN = inRew);
    BY    Cust_ID;
    IF    inCust;
RUN;

DATA customer_consolidated;
    SET customer_consolidated;

    FORMAT Dead      3.
           Death_Age 6.2
           Death_Age_Group $ 8.;

    IF  Death_Reward_R ~= . THEN Dead = 1;
    ELSE Dead = 0;

    IF  Dead = 1 THEN
      DO;
        Death_Age = (Death_Date_Est - Birthday) / 365.2425;

            SELECT;
                WHEN (Death_Age < 20)       Death_Age_Group = '0-20';
                WHEN (20 <= Death_Age < 25) Death_Age_Group = '20-25';
                WHEN (25 <= Death_Age < 30) Death_Age_Group = '25-30';
                WHEN (30 <= Death_Age < 35) Death_Age_Group = '30-35';
                WHEN (35 <= Death_Age < 40) Death_Age_Group = '35-40';
                WHEN (40 <= Death_Age < 45) Death_Age_Group = '40-45';
                WHEN (45 <= Death_Age < 50) Death_Age_Group = '45-50';
                WHEN (50 <= Death_Age < 55) Death_Age_Group = '50-55';
                WHEN (55 <= Death_Age < 60) Death_Age_Group = '55-60';
                WHEN (60 <= Death_Age < 65) Death_Age_Group = '60-65';
                WHEN (65 <= Death_Age < 70) Death_Age_Group = '65-70';
                WHEN (70 <= Death_Age < 75) Death_Age_Group = '70-75';
                WHEN (75 <= Death_Age < 80) Death_Age_Group = '75-80';
                WHEN (80 <= Death_Age < 85) Death_Age_Group = '80-85';
                WHEN (85 <= Death_Age < 90) Death_Age_Group = '85-90';
                WHEN (Death_Age > 90)       Death_Age_Group = '90 +';
            END;

      END;
RUN;







/* Merge the consolidated_policies with the customer_info to create the consolidated table */
PROC SORT DATA = customer_consolidated;
    BY  Cust_ID;
RUN;


PROC SORT DATA = consolidated_policies;
    BY  Cust_ID;
RUN;

DATA customer_consolidated;
    MERGE customer_consolidated  (IN = inCust)
          consolidated_policies  (IN = inPol);
    BY    Cust_ID;
    IF    inCust;
RUN;

/*DATA testdist(KEEP= Cust_ID*/
/*                    cust_lat_rad */
/*                    cust_lon_rad*/
/*                     adj_lat_rad*/
/*                     adj_lon_rad);*/
/*    SET customer_consolidated(WHERE=(Dead=1));*/
/*RUN;*/


DATA customer_consolidated;
    FORMAT death_cust_adj_dist 8.;
    SET customer_consolidated;

    IF Dead = 1                   &
       cust_lat_rad = adj_lat_rad &
       cust_lon_rad = adj_lon_rad
    THEN death_cust_adj_dist = 0;

    ELSE IF Dead = 1          &
            cust_lat_rad ~= . &
            cust_lon_rad ~= . &
             adj_lat_rad ~= . &
             adj_lon_rad ~= .
    THEN
      DO;
        death_cust_adj_dist = 3949.99 * arcos(sin(cust_lat_rad) * sin(adj_lat_rad) +
                              cos(cust_lat_rad) * cos(adj_lat_rad) *
                              cos(cust_lon_rad - adj_lon_rad));
      END;
RUN;




/* Remove Bad Customers - First by Duplicated SSN */
/* Actually, we shouldn't remove them. just flag them as fishy */
DATA customer_consolidated;
    SET customer_consolidated;
    IF Dup_SSN = 1 THEN fishy + 1;
RUN;



/*PROC UNIVARIATE DATA = customer_consolidated;*/
/*    VAR death_cust_adj_dist;*/
/*RUN;*/
/**/
/*PROC SORT DATA = customer_consolidated;*/
/*    BY DESCENDING death_cust_adj_dist;*/
/*RUN;*/



/* Clean up Intermediate Tables */
PROC DATASETS LIBRARY = work NOLIST;
    DELETE consolidated_policies
           customer_medical_risk
           id_list
           policies_term
           policies_term_overview
           policies_var
           policies_var_overview
           policies_whole
           policies_whole_overview
           rewards
           phone_zips
           reference_zips
           /* zipcode_13q3_unique */
           zipmil_13q3
           zipmisc_13q3
           ;
QUIT;


/* Clean up some columns in customer_consolidated that should
   have been cleaned up earlier or might have incorrect information */
DATA customer_consolidated(DROP = adj_city 
                                  adj_state 
                                  has_whole 
                                  has_term 
                                  has_variable 
                                  num_policies);
    SET customer_consolidated(RENAME=(adj_lat         = Death_adj_lat
                                      adj_lon         = Death_adj_lon
                                      adj_lon_rad     = Death_adj_lon_rad
                                      adj_lat_rad     = Death_adj_lat_rad
                                      Ref_state_fips  = Cust_state_fips
                                      Ref_county_fips = Cust_county_fips));
RUN;


/* Save the initial customer transaction date for each customer to customer consolidated */
PROC SORT DATA = customer_transactions;  
    BY Cust_ID Transaction_Date;
RUN;

DATA cust_first_transactions(KEEP = Cust_ID Customer_Since);
    SET customer_transactions(RENAME = (Transaction_Date = Customer_Since));
    BY Cust_ID;

    IF FIRST.Cust_ID THEN OUTPUT cust_first_transactions;
RUN;

PROC SORT DATA = customer_consolidated;
    BY Cust_ID;
RUN;

PROC SORT DATA = cust_first_transactions;
    BY Cust_ID;
RUN;

DATA customer_consolidated;
    MERGE customer_consolidated (IN = inCust)
          cust_first_transactions (IN = inTrans);
    BY Cust_ID;
    IF inCust = 1;
RUN;

PROC DATASETS LIBRARY = work NOLIST;
    DELETE cust_first_transactions;
QUIT;

/* Calculate age at sign up */
DATA customer_consolidated;
    SET customer_consolidated;
    FORMAT Signup_Age 6.2
           Signup_Age_Group $ 8.;

    Signup_Age = (Customer_Since - Birthday) / 365.2425;

    SELECT;
        WHEN       (Signup_Age < 20) Signup_Age_Group = '0-20';
        WHEN (20 <= Signup_Age < 25) Signup_Age_Group = '20-25';
        WHEN (25 <= Signup_Age < 30) Signup_Age_Group = '25-30';
        WHEN (30 <= Signup_Age < 35) Signup_Age_Group = '30-35';
        WHEN (35 <= Signup_Age < 40) Signup_Age_Group = '35-40';
        WHEN (40 <= Signup_Age < 45) Signup_Age_Group = '40-45';
        WHEN (45 <= Signup_Age < 50) Signup_Age_Group = '45-50';
        WHEN (50 <= Signup_Age < 55) Signup_Age_Group = '50-55';
        WHEN (55 <= Signup_Age < 60) Signup_Age_Group = '55-60';
        WHEN (60 <= Signup_Age < 65) Signup_Age_Group = '60-65';
        WHEN (65 <= Signup_Age < 70) Signup_Age_Group = '65-70';
        WHEN (70 <= Signup_Age < 75) Signup_Age_Group = '70-75';
        WHEN (75 <= Signup_Age < 80) Signup_Age_Group = '75-80';
        WHEN (80 <= Signup_Age < 85) Signup_Age_Group = '80-85';
        WHEN (85 <= Signup_Age < 90) Signup_Age_Group = '85-90';
        WHEN       (Signup_Age > 90) Signup_Age_Group = '90 +';
    END;
RUN;


/* Reorder variables for convenience */
DATA customer_consolidated;
    RETAIN  Cust_ID
            fishy
            Dead
            Gender
            Race
            Marriage
            GivenName
            MiddleInitial
            Surname
            StreetAddress
            City
            State
            Country
            CustomerZip
            valid_zip
            cust_best_zip
            TelephoneNumber
            MothersMaiden
            Birthday
            Customer_Since
            Signup_Age
            Signup_Age_Group
            Death_Date_Est
            Death_Age
            Death_Age_Group
            Death_Reward_R
            Death_Reward_Cat
            CCType
            CCNumber
            CCExpires
            NationalID
            Dup_SSN
            BloodType
            Pounds
            inches
            bmi
            bmi_prime
            bmi_code
            vehicle_year
            vehicle_model
            Cust_lat
            Cust_lon
            Cust_lat_rad
            Cust_lon_rad
            Cust_state_fips
            Cust_county_fips
            Bad_Health_Index
            Med_Record_Count
            Death_Adjuster
            Death_Technician
            Death_Adj_ZIP
            Death_Corr_Adj_ZIP
            Death_Adj_City
            Death_Adj_State
            Death_adj_lat
            Death_adj_lon
            Death_adj_lat_rad
            Death_adj_lon_rad
            death_cust_adj_dist;
    SET     customer_consolidated;
RUN;

/* Table of living and dead by zip */
PROC SORT DATA = customer_consolidated;
    BY cust_best_zip;
RUN;

DATA customers_by_zip(KEEP = cust_best_zip num_living num_dead num_total);
    SET customer_consolidated;
    BY cust_best_zip;
    IF FIRST.cust_best_zip THEN 
       DO;
        num_living = 0;
        num_dead   = 0;
        num_total  = 0;
       END;

   SELECT(Dead);
       WHEN(0) num_living + 1;
       WHEN(1) num_dead   + 1;
   END;

   num_total = num_living + num_dead;

   IF LAST.cust_best_zip THEN OUTPUT;
RUN;


/* Get data about the zips from the zip reference file */
DATA unique_zips(KEEP= cust_best_zip);
    SET customers_by_zip;
RUN;

PROC SORT DATA = Zipcode_13q3_unique FORCE;
    BY zip;
RUN;

/* Get rid of the annoying labels on the zip code reference file */
PROC DATASETS LIB = work NOLIST;
   MODIFY Zipcode_13q3_unique;
     attrib _all_ label=' ';
QUIT;

DATA unique_zips (KEEP = cust_best_zip city state statecode statename county countynm);
    MERGE unique_zips         (IN = inUnique)
          Zipcode_13q3_unique (RENAME=(ZIP = cust_best_zip) IN = inRef);
    BY    cust_best_zip;
    IF    inUnique;
RUN;

DATA unique_zips;
    SET unique_zips(RENAME = (city = city_name));
RUN;

/* Create the state reference table for Rails */
DATA states (KEEP = state_name state_abbr state_fips);
    SET unique_zips(RENAME=(state     = state_fips
                            statecode = state_abbr
                            statename = state_name));
RUN;

PROC SORT DATA = states;
    BY state_fips;
RUN;

DATA states;
    SET states;
    BY  state_fips;
    IF  FIRST.state_fips;
RUN;

/* Create the County reference table for Rails */
DATA counties (KEEP = county_name county_fips state_fips);
    SET unique_zips(RENAME = (countynm = county_name
                              county   = county_fips
                              state    = state_fips));
RUN;

PROC SORT DATA = counties;
    BY county_fips;
RUN;

DATA counties;
    SET counties;
    BY  county_fips;
    IF  FIRST.county_fips;
RUN;

/* Create the City reference table for Rails */
DATA cities (KEEP = city_name state_fips county_fips);
    SET unique_zips(RENAME=(state   = state_fips
                            county  = county_fips));
RUN;

PROC SORT DATA = cities;
    BY state_fips county_fips city_name;
RUN;

DATA cities;
    SET cities;
    BY  state_fips county_fips city_name;
    IF  FIRST.city_name;
RUN;

/* Create a city_id that can be used as reference in the consolidated_customer table 
   for output to Rails as a foreign key */
PROC SORT DATA = cities;
    BY city_name;
RUN;

DATA cities;
    RETAIN city_id;
    FORMAT city_id 4.;
    SET cities;
    city_id = _N_;
RUN;

/* Now, merge city_id back into unique_zips using the unique
   combination of state_fips, county_fips, and city_name */

DATA unique_zips(RENAME=(statecode = state_abbr
                         statename = state_name
                         state     = state_fips
                         county    = county_fips
                         countynm  = county_name));
    SET unique_zips;
RUN;

PROC SORT DATA = unique_zips;
    BY state_fips county_fips city_name;
RUN;

PROC SORT data = cities;
    BY state_fips county_fips city_name;
RUN;

DATA unique_zips;
    MERGE unique_zips (IN = inZips)
          cities      (IN = inCities);
    BY state_fips county_fips city_name;
    IF inZips;
RUN;

/* Clean up */
PROC DATASETS LIBRARY = work NOLIST;
    DELETE Zipcode_13q3_unique
           States
           Counties
           Cities;
QUIT;
