/* START HEADER */

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
/* END HEADER */

/* ------------------------------------------------------------------------------ */


/* Combine the adjuster_technician rows to create a single record for each Cov_ID */
PROC SORT DATA = adjuster_technician;
    BY Cov_ID;
RUN;

DATA adjuster_technician     (KEEP = Cov_ID 
                                     Adj_ZIP 
                                     Adjuster_ID 
                                     Technician_ID);
    LENGTH  Cov_ID        $ 20
            Adj_ZIP       $ 20
            Adjuster_ID   $ 4
            Technician_ID $ 4;

    RETAIN  Adjuster_ID
            Technician_ID;

    SET     work.adjuster_technician;
    BY      Cov_ID;

    IF      Claim_Info    =: 'A_'
      THEN  Adjuster_ID   =  COMPRESS(Claim_Info, ' A_');
      ELSE  Technician_ID =  COMPRESS(Claim_Info, ' T_');

    IF      LAST.Cov_ID;
RUN; 


/* Fix the Zip Code Problems in Adj_ZIP (DIANA & COBEY) */

PROC SORT DATA = adjuster_technician;
    BY Adjuster_ID;
RUN;

data adjuster_technician;
    set adjuster_technician;
    IF Adjuster_ID = '1' THEN Adj_Zip_Corr  = '99504';
    IF Adjuster_ID = '2' THEN Adj_Zip_Corr  = '99522';
    IF Adjuster_ID = '3' THEN Adj_Zip_Corr  = '99509';
    IF Adjuster_ID = '4' THEN Adj_Zip_Corr  = '99517';
    IF Adjuster_ID = '5' THEN Adj_Zip_Corr  = '99511';
    IF Adjuster_ID = '6' THEN Adj_Zip_Corr  = '99503';
    IF Adjuster_ID = '7' THEN Adj_Zip_Corr  = '99502';
    IF Adjuster_ID = '8' THEN Adj_Zip_Corr  = '99501';
    IF Adjuster_ID = '9' THEN Adj_Zip_Corr  = '99577';
    IF Adjuster_ID = '10' THEN Adj_Zip_Corr = '99615';
    IF Adjuster_ID = '11' THEN Adj_Zip_Corr = '96808';
    IF Adjuster_ID = '12' THEN Adj_Zip_Corr = '96828';
    IF Adjuster_ID = '13' THEN Adj_Zip_Corr = '96844';
    IF Adjuster_ID = '14' THEN Adj_Zip_Corr = '96818';
    IF Adjuster_ID = '15' THEN Adj_Zip_Corr = '96789';
    IF Adjuster_ID = '16' THEN Adj_Zip_Corr = '96841';
    IF Adjuster_ID = '17' THEN Adj_Zip_Corr = '96841';
    IF Adjuster_ID = '18' THEN Adj_Zip_Corr = '96841';
    IF Adjuster_ID = '19' THEN Adj_Zip_Corr = '96841';
    IF Adjuster_ID = '20' THEN Adj_Zip_Corr = '96841';
    IF Adjuster_ID = '21' THEN Adj_Zip_Corr = '96797';
    IF Adjuster_ID = '22' THEN Adj_Zip_Corr = '96797';
    IF Adjuster_ID = '23' THEN Adj_Zip_Corr = '96797';
    IF Adjuster_ID = '24' THEN Adj_Zip_Corr = '96797';
    IF Adjuster_ID = '25' THEN Adj_Zip_Corr = '96797';
    IF Adjuster_ID = '26' THEN Adj_Zip_Corr = '98004';
    IF Adjuster_ID = '27' THEN Adj_Zip_Corr = '98004';
    IF Adjuster_ID = '28' THEN Adj_Zip_Corr = '98008';
    IF Adjuster_ID = '29' THEN Adj_Zip_Corr = '98008';
    IF Adjuster_ID = '30' THEN Adj_Zip_Corr = '98008';
    IF Adjuster_ID = '31' THEN Adj_Zip_Corr = '98008';
    IF Adjuster_ID = '32' THEN Adj_Zip_Corr = '98008';
    IF Adjuster_ID = '33' THEN Adj_Zip_Corr = '98008';
    IF Adjuster_ID = '34' THEN Adj_Zip_Corr = '98008';
    IF Adjuster_ID = '35' THEN Adj_Zip_Corr = '98107';
    IF Adjuster_ID = '36' THEN Adj_Zip_Corr = '98107';
    IF Adjuster_ID = '37' THEN Adj_Zip_Corr = '98107';
    IF Adjuster_ID = '38' THEN Adj_Zip_Corr = '98127';
    IF Adjuster_ID = '39' THEN Adj_Zip_Corr = '98127';
    IF Adjuster_ID = '40' THEN Adj_Zip_Corr = '98127';
    IF Adjuster_ID = '41' THEN Adj_Zip_Corr = '98127';
    IF Adjuster_ID = '42' THEN Adj_Zip_Corr = '98127';
    IF Adjuster_ID = '43' THEN Adj_Zip_Corr = '98127';
    IF Adjuster_ID = '44' THEN Adj_Zip_Corr = '98127';
    IF Adjuster_ID = '45' THEN Adj_Zip_Corr = '98205';
    IF Adjuster_ID = '46' THEN Adj_Zip_Corr = '98205';
    IF Adjuster_ID = '47' THEN Adj_Zip_Corr = '98205';
    IF Adjuster_ID = '48' THEN Adj_Zip_Corr = '98205';
    IF Adjuster_ID = '49' THEN Adj_Zip_Corr = '98205';
    IF Adjuster_ID = '50' THEN Adj_Zip_Corr = '98205';
    IF Adjuster_ID = '51' THEN Adj_Zip_Corr = '98207';
    IF Adjuster_ID = '52' THEN Adj_Zip_Corr = '98207';
    IF Adjuster_ID = '53' THEN Adj_Zip_Corr = '98207';
    IF Adjuster_ID = '54' THEN Adj_Zip_Corr = '98207';
    IF Adjuster_ID = '55' THEN Adj_Zip_Corr = '98422';
    IF Adjuster_ID = '56' THEN Adj_Zip_Corr = '98405';
    IF Adjuster_ID = '57' THEN Adj_Zip_Corr = '98405';
    IF Adjuster_ID = '58' THEN Adj_Zip_Corr = '98405';
    IF Adjuster_ID = '59' THEN Adj_Zip_Corr = '98405';
    IF Adjuster_ID = '60' THEN Adj_Zip_Corr = '98405';
    IF Adjuster_ID = '61' THEN Adj_Zip_Corr = '98405';
    IF Adjuster_ID = '62' THEN Adj_Zip_Corr = '98405';
    IF Adjuster_ID = '63' THEN Adj_Zip_Corr = '98405';
    IF Adjuster_ID = '64' THEN Adj_Zip_Corr = '98405';
    IF Adjuster_ID = '65' THEN Adj_Zip_Corr = '98405';
    IF Adjuster_ID = '66' THEN Adj_Zip_Corr = '97314';
    IF Adjuster_ID = '67' THEN Adj_Zip_Corr = '97314';
    IF Adjuster_ID = '68' THEN Adj_Zip_Corr = '97007';
    IF Adjuster_ID = '69' THEN Adj_Zip_Corr = '97007';
    IF Adjuster_ID = '70' THEN Adj_Zip_Corr = '97007';
    IF Adjuster_ID = '71' THEN Adj_Zip_Corr = '97007';
    IF Adjuster_ID = '72' THEN Adj_Zip_Corr = '97007';
    IF Adjuster_ID = '73' THEN Adj_Zip_Corr = '97007';
    IF Adjuster_ID = '74' THEN Adj_Zip_Corr = '97076';
    IF Adjuster_ID = '75' THEN Adj_Zip_Corr = '97076';
    IF Adjuster_ID = '76' THEN Adj_Zip_Corr = '97076';
    IF Adjuster_ID = '77' THEN Adj_Zip_Corr = '97076';
    IF Adjuster_ID = '78' THEN Adj_Zip_Corr = '97404';
    IF Adjuster_ID = '79' THEN Adj_Zip_Corr = '97404';
    IF Adjuster_ID = '80' THEN Adj_Zip_Corr = '97404';
    IF Adjuster_ID = '81' THEN Adj_Zip_Corr = '97404';
    IF Adjuster_ID = '82' THEN Adj_Zip_Corr = '97404';
    IF Adjuster_ID = '83' THEN Adj_Zip_Corr = '97412';
    IF Adjuster_ID = '84' THEN Adj_Zip_Corr = '97412';
    IF Adjuster_ID = '85' THEN Adj_Zip_Corr = '97412';
    IF Adjuster_ID = '86' THEN Adj_Zip_Corr = '97412';
    IF Adjuster_ID = '87' THEN Adj_Zip_Corr = '97412';
    IF Adjuster_ID = '88' THEN Adj_Zip_Corr = '97219';
    IF Adjuster_ID = '89' THEN Adj_Zip_Corr = '97219';
    IF Adjuster_ID = '90' THEN Adj_Zip_Corr = '97219';
    IF Adjuster_ID = '91' THEN Adj_Zip_Corr = '97219';
    IF Adjuster_ID = '92' THEN Adj_Zip_Corr = '97219';
    IF Adjuster_ID = '93' THEN Adj_Zip_Corr = '97222';
    IF Adjuster_ID = '94' THEN Adj_Zip_Corr = '97222';
    IF Adjuster_ID = '95' THEN Adj_Zip_Corr = '97222';
    IF Adjuster_ID = '96' THEN Adj_Zip_Corr = '97222';
    IF Adjuster_ID = '97' THEN Adj_Zip_Corr = '97222';
    IF Adjuster_ID = '98' THEN Adj_Zip_Corr = '97224';
    IF Adjuster_ID = '99' THEN Adj_Zip_Corr = '97224';
    IF Adjuster_ID = '100' THEN Adj_Zip_Corr = '97224';
    IF Adjuster_ID = '101' THEN Adj_Zip_Corr = '97224';
    IF Adjuster_ID = '102' THEN Adj_Zip_Corr = '97224';
    IF Adjuster_ID = '103' THEN Adj_Zip_Corr = '97224';
    IF Adjuster_ID = '104' THEN Adj_Zip_Corr = '97224';
    IF Adjuster_ID = '105' THEN Adj_Zip_Corr = '97229';
    IF Adjuster_ID = '106' THEN Adj_Zip_Corr = '97229';
    IF Adjuster_ID = '107' THEN Adj_Zip_Corr = '97229';
    IF Adjuster_ID = '108' THEN Adj_Zip_Corr = '97229';
    IF Adjuster_ID = '109' THEN Adj_Zip_Corr = '97229';
    IF Adjuster_ID = '110' THEN Adj_Zip_Corr = '97229';
    IF Adjuster_ID = '111' THEN Adj_Zip_Corr = '97256';
    IF Adjuster_ID = '112' THEN Adj_Zip_Corr = '97256';
    IF Adjuster_ID = '113' THEN Adj_Zip_Corr = '97258';
    IF Adjuster_ID = '114' THEN Adj_Zip_Corr = '97258';
    IF Adjuster_ID = '115' THEN Adj_Zip_Corr = '97258';
    IF Adjuster_ID = '116' THEN Adj_Zip_Corr = '92802';
    IF Adjuster_ID = '117' THEN Adj_Zip_Corr = '92802';
    IF Adjuster_ID = '118' THEN Adj_Zip_Corr = '92802';
    IF Adjuster_ID = '119' THEN Adj_Zip_Corr = '92802';
    IF Adjuster_ID = '120' THEN Adj_Zip_Corr = '92802';
    IF Adjuster_ID = '121' THEN Adj_Zip_Corr = '92808';
    IF Adjuster_ID = '122' THEN Adj_Zip_Corr = '92808';
    IF Adjuster_ID = '123' THEN Adj_Zip_Corr = '92808';
    IF Adjuster_ID = '124' THEN Adj_Zip_Corr = '92808';
    IF Adjuster_ID = '125' THEN Adj_Zip_Corr = '92808';
    IF Adjuster_ID = '126' THEN Adj_Zip_Corr = '92814';
    IF Adjuster_ID = '127' THEN Adj_Zip_Corr = '92814';
    IF Adjuster_ID = '128' THEN Adj_Zip_Corr = '92814';
    IF Adjuster_ID = '129' THEN Adj_Zip_Corr = '92814';
    IF Adjuster_ID = '130' THEN Adj_Zip_Corr = '92814';
    IF Adjuster_ID = '131' THEN Adj_Zip_Corr = '92825';
    IF Adjuster_ID = '132' THEN Adj_Zip_Corr = '92825';
    IF Adjuster_ID = '133' THEN Adj_Zip_Corr = '92825';
    IF Adjuster_ID = '134' THEN Adj_Zip_Corr = '92825';
    IF Adjuster_ID = '135' THEN Adj_Zip_Corr = '92825';
    IF Adjuster_ID = '136' THEN Adj_Zip_Corr = '93304';
    IF Adjuster_ID = '137' THEN Adj_Zip_Corr = '93304';
    IF Adjuster_ID = '138' THEN Adj_Zip_Corr = '93304';
    IF Adjuster_ID = '139' THEN Adj_Zip_Corr = '93304';
    IF Adjuster_ID = '140' THEN Adj_Zip_Corr = '93304';
    IF Adjuster_ID = '141' THEN Adj_Zip_Corr = '93389';
    IF Adjuster_ID = '142' THEN Adj_Zip_Corr = '93389';
    IF Adjuster_ID = '143' THEN Adj_Zip_Corr = '93389';
    IF Adjuster_ID = '144' THEN Adj_Zip_Corr = '93389';
    IF Adjuster_ID = '145' THEN Adj_Zip_Corr = '93389';
    IF Adjuster_ID = '146' THEN Adj_Zip_Corr = '93390';
    IF Adjuster_ID = '147' THEN Adj_Zip_Corr = '93390';
    IF Adjuster_ID = '148' THEN Adj_Zip_Corr = '93390';
    IF Adjuster_ID = '149' THEN Adj_Zip_Corr = '93390';
    IF Adjuster_ID = '150' THEN Adj_Zip_Corr = '93390';
    IF Adjuster_ID = '151' THEN Adj_Zip_Corr = '94161';
    IF Adjuster_ID = '152' THEN Adj_Zip_Corr = '94161';
    IF Adjuster_ID = '153' THEN Adj_Zip_Corr = '94161';
    IF Adjuster_ID = '154' THEN Adj_Zip_Corr = '94161';
    IF Adjuster_ID = '155' THEN Adj_Zip_Corr = '94161';
    IF Adjuster_ID = '156' THEN Adj_Zip_Corr = '94701';
    IF Adjuster_ID = '157' THEN Adj_Zip_Corr = '94701';
    IF Adjuster_ID = '158' THEN Adj_Zip_Corr = '94701';
    IF Adjuster_ID = '159' THEN Adj_Zip_Corr = '94701';
    IF Adjuster_ID = '160' THEN Adj_Zip_Corr = '94701';
    IF Adjuster_ID = '161' THEN Adj_Zip_Corr = '94708';
    IF Adjuster_ID = '162' THEN Adj_Zip_Corr = '94708';
    IF Adjuster_ID = '163' THEN Adj_Zip_Corr = '94708';
    IF Adjuster_ID = '164' THEN Adj_Zip_Corr = '94708';
    IF Adjuster_ID = '165' THEN Adj_Zip_Corr = '94708';
    IF Adjuster_ID = '166' THEN Adj_Zip_Corr = '94710';
    IF Adjuster_ID = '167' THEN Adj_Zip_Corr = '94710';
    IF Adjuster_ID = '168' THEN Adj_Zip_Corr = '94710';
    IF Adjuster_ID = '169' THEN Adj_Zip_Corr = '94710';
    IF Adjuster_ID = '170' THEN Adj_Zip_Corr = '94710';
    IF Adjuster_ID = '171' THEN Adj_Zip_Corr = '94712';
    IF Adjuster_ID = '172' THEN Adj_Zip_Corr = '94712';
    IF Adjuster_ID = '173' THEN Adj_Zip_Corr = '94712';
    IF Adjuster_ID = '174' THEN Adj_Zip_Corr = '94712';
    IF Adjuster_ID = '175' THEN Adj_Zip_Corr = '94712';
    IF Adjuster_ID = '176' THEN Adj_Zip_Corr = '93716';
    IF Adjuster_ID = '177' THEN Adj_Zip_Corr = '93716';
    IF Adjuster_ID = '178' THEN Adj_Zip_Corr = '93716';
    IF Adjuster_ID = '179' THEN Adj_Zip_Corr = '93716';
    IF Adjuster_ID = '180' THEN Adj_Zip_Corr = '93716';
    IF Adjuster_ID = '181' THEN Adj_Zip_Corr = '93721';
    IF Adjuster_ID = '182' THEN Adj_Zip_Corr = '93721';
    IF Adjuster_ID = '183' THEN Adj_Zip_Corr = '93721';
    IF Adjuster_ID = '184' THEN Adj_Zip_Corr = '93721';
    IF Adjuster_ID = '185' THEN Adj_Zip_Corr = '93721';
    IF Adjuster_ID = '186' THEN Adj_Zip_Corr = '93760';
    IF Adjuster_ID = '187' THEN Adj_Zip_Corr = '93760';
    IF Adjuster_ID = '188' THEN Adj_Zip_Corr = '93760';
    IF Adjuster_ID = '189' THEN Adj_Zip_Corr = '93760';
    IF Adjuster_ID = '190' THEN Adj_Zip_Corr = '93760';
    IF Adjuster_ID = '191' THEN Adj_Zip_Corr = '93790';
    IF Adjuster_ID = '192' THEN Adj_Zip_Corr = '93790';
    IF Adjuster_ID = '193' THEN Adj_Zip_Corr = '93790';
    IF Adjuster_ID = '194' THEN Adj_Zip_Corr = '93790';
    IF Adjuster_ID = '195' THEN Adj_Zip_Corr = '93790';
    IF Adjuster_ID = '196' THEN Adj_Zip_Corr = '92607';
    IF Adjuster_ID = '197' THEN Adj_Zip_Corr = '92607';
    IF Adjuster_ID = '198' THEN Adj_Zip_Corr = '92607';
    IF Adjuster_ID = '199' THEN Adj_Zip_Corr = '92607';
    IF Adjuster_ID = '200' THEN Adj_Zip_Corr = '92607';
    IF Adjuster_ID = '201' THEN Adj_Zip_Corr = '92677';
    IF Adjuster_ID = '202' THEN Adj_Zip_Corr = '92677';
    IF Adjuster_ID = '203' THEN Adj_Zip_Corr = '92677';
    IF Adjuster_ID = '204' THEN Adj_Zip_Corr = '92677';
    IF Adjuster_ID = '205' THEN Adj_Zip_Corr = '92677';
    IF Adjuster_ID = '206' THEN Adj_Zip_Corr = '90745';
    IF Adjuster_ID = '207' THEN Adj_Zip_Corr = '90745';
    IF Adjuster_ID = '208' THEN Adj_Zip_Corr = '90745';
    IF Adjuster_ID = '209' THEN Adj_Zip_Corr = '90745';
    IF Adjuster_ID = '210' THEN Adj_Zip_Corr = '90745';
    IF Adjuster_ID = '211' THEN Adj_Zip_Corr = '90746';
    IF Adjuster_ID = '212' THEN Adj_Zip_Corr = '90746';
    IF Adjuster_ID = '213' THEN Adj_Zip_Corr = '90746';
    IF Adjuster_ID = '214' THEN Adj_Zip_Corr = '90746';
    IF Adjuster_ID = '215' THEN Adj_Zip_Corr = '90746';
    IF Adjuster_ID = '216' THEN Adj_Zip_Corr = '90805';
    IF Adjuster_ID = '217' THEN Adj_Zip_Corr = '90805';
    IF Adjuster_ID = '218' THEN Adj_Zip_Corr = '90805';
    IF Adjuster_ID = '219' THEN Adj_Zip_Corr = '90805';
    IF Adjuster_ID = '220' THEN Adj_Zip_Corr = '90805';
    IF Adjuster_ID = '221' THEN Adj_Zip_Corr = '90001';
    IF Adjuster_ID = '222' THEN Adj_Zip_Corr = '90001';
    IF Adjuster_ID = '223' THEN Adj_Zip_Corr = '90001';
    IF Adjuster_ID = '224' THEN Adj_Zip_Corr = '90001';
    IF Adjuster_ID = '225' THEN Adj_Zip_Corr = '90001';
    IF Adjuster_ID = '226' THEN Adj_Zip_Corr = '90005';
    IF Adjuster_ID = '227' THEN Adj_Zip_Corr = '90005';
    IF Adjuster_ID = '228' THEN Adj_Zip_Corr = '90005';
    IF Adjuster_ID = '229' THEN Adj_Zip_Corr = '90005';
    IF Adjuster_ID = '230' THEN Adj_Zip_Corr = '90005';
    IF Adjuster_ID = '231' THEN Adj_Zip_Corr = '90007';
    IF Adjuster_ID = '232' THEN Adj_Zip_Corr = '90007';
    IF Adjuster_ID = '233' THEN Adj_Zip_Corr = '90007';
    IF Adjuster_ID = '234' THEN Adj_Zip_Corr = '90007';
    IF Adjuster_ID = '235' THEN Adj_Zip_Corr = '90007';
    IF Adjuster_ID = '236' THEN Adj_Zip_Corr = '90013';
    IF Adjuster_ID = '237' THEN Adj_Zip_Corr = '90013';
    IF Adjuster_ID = '238' THEN Adj_Zip_Corr = '90013';
    IF Adjuster_ID = '239' THEN Adj_Zip_Corr = '90013';
    IF Adjuster_ID = '240' THEN Adj_Zip_Corr = '90013';
    IF Adjuster_ID = '241' THEN Adj_Zip_Corr = '90016';
    IF Adjuster_ID = '242' THEN Adj_Zip_Corr = '90016';
    IF Adjuster_ID = '243' THEN Adj_Zip_Corr = '90016';
    IF Adjuster_ID = '244' THEN Adj_Zip_Corr = '90016';
    IF Adjuster_ID = '245' THEN Adj_Zip_Corr = '90016';
    IF Adjuster_ID = '246' THEN Adj_Zip_Corr = '90022';
    IF Adjuster_ID = '247' THEN Adj_Zip_Corr = '90022';
    IF Adjuster_ID = '248' THEN Adj_Zip_Corr = '90022';
    IF Adjuster_ID = '249' THEN Adj_Zip_Corr = '90022';
    IF Adjuster_ID = '250' THEN Adj_Zip_Corr = '90022';
    IF Adjuster_ID = '251' THEN Adj_Zip_Corr = '90026';
    IF Adjuster_ID = '252' THEN Adj_Zip_Corr = '90026';
    IF Adjuster_ID = '253' THEN Adj_Zip_Corr = '90026';
    IF Adjuster_ID = '254' THEN Adj_Zip_Corr = '90026';
    IF Adjuster_ID = '255' THEN Adj_Zip_Corr = '90026';
    IF Adjuster_ID = '256' THEN Adj_Zip_Corr = '90028';
    IF Adjuster_ID = '257' THEN Adj_Zip_Corr = '90028';
    IF Adjuster_ID = '258' THEN Adj_Zip_Corr = '90028';
    IF Adjuster_ID = '259' THEN Adj_Zip_Corr = '90028';
    IF Adjuster_ID = '260' THEN Adj_Zip_Corr = '90028';
    IF Adjuster_ID = '261' THEN Adj_Zip_Corr = '90039';
    IF Adjuster_ID = '262' THEN Adj_Zip_Corr = '90039';
    IF Adjuster_ID = '263' THEN Adj_Zip_Corr = '90039';
    IF Adjuster_ID = '264' THEN Adj_Zip_Corr = '90039';
    IF Adjuster_ID = '265' THEN Adj_Zip_Corr = '90039';
    IF Adjuster_ID = '266' THEN Adj_Zip_Corr = '90064';
    IF Adjuster_ID = '267' THEN Adj_Zip_Corr = '90064';
    IF Adjuster_ID = '268' THEN Adj_Zip_Corr = '90064';
    IF Adjuster_ID = '269' THEN Adj_Zip_Corr = '90064';
    IF Adjuster_ID = '270' THEN Adj_Zip_Corr = '90064';
    IF Adjuster_ID = '271' THEN Adj_Zip_Corr = '90067';
    IF Adjuster_ID = '272' THEN Adj_Zip_Corr = '90067';
    IF Adjuster_ID = '273' THEN Adj_Zip_Corr = '90067';
    IF Adjuster_ID = '274' THEN Adj_Zip_Corr = '90067';
    IF Adjuster_ID = '275' THEN Adj_Zip_Corr = '90067';
    IF Adjuster_ID = '276' THEN Adj_Zip_Corr = '90069';
    IF Adjuster_ID = '277' THEN Adj_Zip_Corr = '90069';
    IF Adjuster_ID = '278' THEN Adj_Zip_Corr = '90069';
    IF Adjuster_ID = '279' THEN Adj_Zip_Corr = '90069';
    IF Adjuster_ID = '280' THEN Adj_Zip_Corr = '90069';
    IF Adjuster_ID = '281' THEN Adj_Zip_Corr = '90076';
    IF Adjuster_ID = '282' THEN Adj_Zip_Corr = '90076';
    IF Adjuster_ID = '283' THEN Adj_Zip_Corr = '90076';
    IF Adjuster_ID = '284' THEN Adj_Zip_Corr = '90076';
    IF Adjuster_ID = '285' THEN Adj_Zip_Corr = '90076';
    IF Adjuster_ID = '286' THEN Adj_Zip_Corr = '90088';
    IF Adjuster_ID = '287' THEN Adj_Zip_Corr = '90088';
    IF Adjuster_ID = '288' THEN Adj_Zip_Corr = '90088';
    IF Adjuster_ID = '289' THEN Adj_Zip_Corr = '90088';
    IF Adjuster_ID = '290' THEN Adj_Zip_Corr = '90088';
    IF Adjuster_ID = '291' THEN Adj_Zip_Corr = '91617';
    IF Adjuster_ID = '292' THEN Adj_Zip_Corr = '91617';
    IF Adjuster_ID = '293' THEN Adj_Zip_Corr = '91617';
    IF Adjuster_ID = '294' THEN Adj_Zip_Corr = '91617';
    IF Adjuster_ID = '295' THEN Adj_Zip_Corr = '91617';
    IF Adjuster_ID = '296' THEN Adj_Zip_Corr = '91618';
    IF Adjuster_ID = '297' THEN Adj_Zip_Corr = '91618';
    IF Adjuster_ID = '298' THEN Adj_Zip_Corr = '91618';
    IF Adjuster_ID = '299' THEN Adj_Zip_Corr = '91618';
    IF Adjuster_ID = '300' THEN Adj_Zip_Corr = '91618';
    IF Adjuster_ID = '301' THEN Adj_Zip_Corr = '94615';
    IF Adjuster_ID = '302' THEN Adj_Zip_Corr = '94615';
    IF Adjuster_ID = '303' THEN Adj_Zip_Corr = '94615';
    IF Adjuster_ID = '304' THEN Adj_Zip_Corr = '94615';
    IF Adjuster_ID = '305' THEN Adj_Zip_Corr = '94615';
    IF Adjuster_ID = '306' THEN Adj_Zip_Corr = '94617';
    IF Adjuster_ID = '307' THEN Adj_Zip_Corr = '94617';
    IF Adjuster_ID = '308' THEN Adj_Zip_Corr = '94617';
    IF Adjuster_ID = '309' THEN Adj_Zip_Corr = '94617';
    IF Adjuster_ID = '310' THEN Adj_Zip_Corr = '94617';
    IF Adjuster_ID = '311' THEN Adj_Zip_Corr = '94620';
    IF Adjuster_ID = '312' THEN Adj_Zip_Corr = '94620';
    IF Adjuster_ID = '313' THEN Adj_Zip_Corr = '94620';
    IF Adjuster_ID = '314' THEN Adj_Zip_Corr = '94620';
    IF Adjuster_ID = '315' THEN Adj_Zip_Corr = '94620';
    IF Adjuster_ID = '316' THEN Adj_Zip_Corr = '94252';
    IF Adjuster_ID = '317' THEN Adj_Zip_Corr = '94252';
    IF Adjuster_ID = '318' THEN Adj_Zip_Corr = '94252';
    IF Adjuster_ID = '319' THEN Adj_Zip_Corr = '94252';
    IF Adjuster_ID = '320' THEN Adj_Zip_Corr = '94252';
    IF Adjuster_ID = '321' THEN Adj_Zip_Corr = '94252';
    IF Adjuster_ID = '322' THEN Adj_Zip_Corr = '94252';
    IF Adjuster_ID = '323' THEN Adj_Zip_Corr = '94252';
    IF Adjuster_ID = '324' THEN Adj_Zip_Corr = '94252';
    IF Adjuster_ID = '325' THEN Adj_Zip_Corr = '94252';
    IF Adjuster_ID = '326' THEN Adj_Zip_Corr = '94252';
    IF Adjuster_ID = '327' THEN Adj_Zip_Corr = '94252';
    IF Adjuster_ID = '328' THEN Adj_Zip_Corr = '94252';
    IF Adjuster_ID = '329' THEN Adj_Zip_Corr = '94252';
    IF Adjuster_ID = '330' THEN Adj_Zip_Corr = '94252';
    IF Adjuster_ID = '331' THEN Adj_Zip_Corr = '94205';
    IF Adjuster_ID = '332' THEN Adj_Zip_Corr = '94205';
    IF Adjuster_ID = '333' THEN Adj_Zip_Corr = '94205';
    IF Adjuster_ID = '334' THEN Adj_Zip_Corr = '94205';
    IF Adjuster_ID = '335' THEN Adj_Zip_Corr = '94205';
    IF Adjuster_ID = '336' THEN Adj_Zip_Corr = '94206';
    IF Adjuster_ID = '337' THEN Adj_Zip_Corr = '94206';
    IF Adjuster_ID = '338' THEN Adj_Zip_Corr = '94206';
    IF Adjuster_ID = '339' THEN Adj_Zip_Corr = '94206';
    IF Adjuster_ID = '340' THEN Adj_Zip_Corr = '94206';
    IF Adjuster_ID = '341' THEN Adj_Zip_Corr = '94235';
    IF Adjuster_ID = '342' THEN Adj_Zip_Corr = '94235';
    IF Adjuster_ID = '343' THEN Adj_Zip_Corr = '94235';
    IF Adjuster_ID = '344' THEN Adj_Zip_Corr = '94235';
    IF Adjuster_ID = '345' THEN Adj_Zip_Corr = '94235';
    IF Adjuster_ID = '346' THEN Adj_Zip_Corr = '94246';
    IF Adjuster_ID = '347' THEN Adj_Zip_Corr = '94246';
    IF Adjuster_ID = '348' THEN Adj_Zip_Corr = '94246';
    IF Adjuster_ID = '349' THEN Adj_Zip_Corr = '94246';
    IF Adjuster_ID = '350' THEN Adj_Zip_Corr = '94246';
    IF Adjuster_ID = '351' THEN Adj_Zip_Corr = '94273';
    IF Adjuster_ID = '352' THEN Adj_Zip_Corr = '94273';
    IF Adjuster_ID = '353' THEN Adj_Zip_Corr = '94273';
    IF Adjuster_ID = '354' THEN Adj_Zip_Corr = '94273';
    IF Adjuster_ID = '355' THEN Adj_Zip_Corr = '94273';
    IF Adjuster_ID = '356' THEN Adj_Zip_Corr = '94279';
    IF Adjuster_ID = '357' THEN Adj_Zip_Corr = '94279';
    IF Adjuster_ID = '358' THEN Adj_Zip_Corr = '94279';
    IF Adjuster_ID = '359' THEN Adj_Zip_Corr = '94279';
    IF Adjuster_ID = '360' THEN Adj_Zip_Corr = '94279';
    IF Adjuster_ID = '361' THEN Adj_Zip_Corr = '94280';
    IF Adjuster_ID = '362' THEN Adj_Zip_Corr = '94280';
    IF Adjuster_ID = '363' THEN Adj_Zip_Corr = '94280';
    IF Adjuster_ID = '364' THEN Adj_Zip_Corr = '94280';
    IF Adjuster_ID = '365' THEN Adj_Zip_Corr = '94280';
    IF Adjuster_ID = '366' THEN Adj_Zip_Corr = '94282';
    IF Adjuster_ID = '367' THEN Adj_Zip_Corr = '94282';
    IF Adjuster_ID = '368' THEN Adj_Zip_Corr = '94282';
    IF Adjuster_ID = '369' THEN Adj_Zip_Corr = '94282';
    IF Adjuster_ID = '370' THEN Adj_Zip_Corr = '94282';
    IF Adjuster_ID = '371' THEN Adj_Zip_Corr = '94274';
    IF Adjuster_ID = '372' THEN Adj_Zip_Corr = '94274';
    IF Adjuster_ID = '373' THEN Adj_Zip_Corr = '94274';
    IF Adjuster_ID = '374' THEN Adj_Zip_Corr = '94274';
    IF Adjuster_ID = '375' THEN Adj_Zip_Corr = '94274';
    IF Adjuster_ID = '376' THEN Adj_Zip_Corr = '92153';
    IF Adjuster_ID = '377' THEN Adj_Zip_Corr = '92153';
    IF Adjuster_ID = '378' THEN Adj_Zip_Corr = '92153';
    IF Adjuster_ID = '379' THEN Adj_Zip_Corr = '92153';
    IF Adjuster_ID = '380' THEN Adj_Zip_Corr = '92153';
    IF Adjuster_ID = '381' THEN Adj_Zip_Corr = '92153';
    IF Adjuster_ID = '382' THEN Adj_Zip_Corr = '92153';
    IF Adjuster_ID = '383' THEN Adj_Zip_Corr = '92153';
    IF Adjuster_ID = '384' THEN Adj_Zip_Corr = '92153';
    IF Adjuster_ID = '385' THEN Adj_Zip_Corr = '92153';
    IF Adjuster_ID = '386' THEN Adj_Zip_Corr = '92110';
    IF Adjuster_ID = '387' THEN Adj_Zip_Corr = '92110';
    IF Adjuster_ID = '388' THEN Adj_Zip_Corr = '92110';
    IF Adjuster_ID = '389' THEN Adj_Zip_Corr = '92110';
    IF Adjuster_ID = '390' THEN Adj_Zip_Corr = '92110';
    IF Adjuster_ID = '391' THEN Adj_Zip_Corr = '92113';
    IF Adjuster_ID = '392' THEN Adj_Zip_Corr = '92113';
    IF Adjuster_ID = '393' THEN Adj_Zip_Corr = '92113';
    IF Adjuster_ID = '394' THEN Adj_Zip_Corr = '92113';
    IF Adjuster_ID = '395' THEN Adj_Zip_Corr = '92113';
    IF Adjuster_ID = '396' THEN Adj_Zip_Corr = '92132';
    IF Adjuster_ID = '397' THEN Adj_Zip_Corr = '92132';
    IF Adjuster_ID = '398' THEN Adj_Zip_Corr = '92132';
    IF Adjuster_ID = '399' THEN Adj_Zip_Corr = '92132';
    IF Adjuster_ID = '400' THEN Adj_Zip_Corr = '92132';
    IF Adjuster_ID = '401' THEN Adj_Zip_Corr = '92140';
    IF Adjuster_ID = '402' THEN Adj_Zip_Corr = '92140';
    IF Adjuster_ID = '403' THEN Adj_Zip_Corr = '92140';
    IF Adjuster_ID = '404' THEN Adj_Zip_Corr = '92140';
    IF Adjuster_ID = '405' THEN Adj_Zip_Corr = '92140';
    IF Adjuster_ID = '406' THEN Adj_Zip_Corr = '92143';
    IF Adjuster_ID = '407' THEN Adj_Zip_Corr = '92143';
    IF Adjuster_ID = '408' THEN Adj_Zip_Corr = '92143';
    IF Adjuster_ID = '409' THEN Adj_Zip_Corr = '92143';
    IF Adjuster_ID = '410' THEN Adj_Zip_Corr = '92143';
    IF Adjuster_ID = '411' THEN Adj_Zip_Corr = '92152';
    IF Adjuster_ID = '412' THEN Adj_Zip_Corr = '92152';
    IF Adjuster_ID = '413' THEN Adj_Zip_Corr = '92152';
    IF Adjuster_ID = '414' THEN Adj_Zip_Corr = '92152';
    IF Adjuster_ID = '415' THEN Adj_Zip_Corr = '92152';
    IF Adjuster_ID = '416' THEN Adj_Zip_Corr = '92199';
    IF Adjuster_ID = '417' THEN Adj_Zip_Corr = '92199';
    IF Adjuster_ID = '418' THEN Adj_Zip_Corr = '92199';
    IF Adjuster_ID = '419' THEN Adj_Zip_Corr = '92199';
    IF Adjuster_ID = '420' THEN Adj_Zip_Corr = '92199';
    IF Adjuster_ID = '421' THEN Adj_Zip_Corr = '90247';
    IF Adjuster_ID = '422' THEN Adj_Zip_Corr = '90247';
    IF Adjuster_ID = '423' THEN Adj_Zip_Corr = '90247';
    IF Adjuster_ID = '424' THEN Adj_Zip_Corr = '90247';
    IF Adjuster_ID = '425' THEN Adj_Zip_Corr = '90247';
    IF Adjuster_ID = '426' THEN Adj_Zip_Corr = '90247';
    IF Adjuster_ID = '427' THEN Adj_Zip_Corr = '90247';
    IF Adjuster_ID = '428' THEN Adj_Zip_Corr = '90247';
    IF Adjuster_ID = '429' THEN Adj_Zip_Corr = '90247';
    IF Adjuster_ID = '430' THEN Adj_Zip_Corr = '90247';
    IF Adjuster_ID = '431' THEN Adj_Zip_Corr = '90670';
    IF Adjuster_ID = '432' THEN Adj_Zip_Corr = '90670';
    IF Adjuster_ID = '433' THEN Adj_Zip_Corr = '90670';
    IF Adjuster_ID = '434' THEN Adj_Zip_Corr = '90670';
    IF Adjuster_ID = '435' THEN Adj_Zip_Corr = '90670';
    IF Adjuster_ID = '436' THEN Adj_Zip_Corr = '90670';
    IF Adjuster_ID = '437' THEN Adj_Zip_Corr = '90670';
    IF Adjuster_ID = '438' THEN Adj_Zip_Corr = '90670';
    IF Adjuster_ID = '439' THEN Adj_Zip_Corr = '90670';
    IF Adjuster_ID = '440' THEN Adj_Zip_Corr = '90670';
    IF Adjuster_ID = '441' THEN Adj_Zip_Corr = '90808';
    IF Adjuster_ID = '442' THEN Adj_Zip_Corr = '90808';
    IF Adjuster_ID = '443' THEN Adj_Zip_Corr = '90808';
    IF Adjuster_ID = '444' THEN Adj_Zip_Corr = '90808';
    IF Adjuster_ID = '445' THEN Adj_Zip_Corr = '90808';
    IF Adjuster_ID = '446' THEN Adj_Zip_Corr = '90808';
    IF Adjuster_ID = '447' THEN Adj_Zip_Corr = '90808';
    IF Adjuster_ID = '448' THEN Adj_Zip_Corr = '90808';
    IF Adjuster_ID = '449' THEN Adj_Zip_Corr = '90808';
    IF Adjuster_ID = '450' THEN Adj_Zip_Corr = '90808';
    IF Adjuster_ID = '451' THEN Adj_Zip_Corr = '91504';
    IF Adjuster_ID = '452' THEN Adj_Zip_Corr = '91504';
    IF Adjuster_ID = '453' THEN Adj_Zip_Corr = '91504';
    IF Adjuster_ID = '454' THEN Adj_Zip_Corr = '91504';
    IF Adjuster_ID = '455' THEN Adj_Zip_Corr = '91504';
    IF Adjuster_ID = '456' THEN Adj_Zip_Corr = '91504';
    IF Adjuster_ID = '457' THEN Adj_Zip_Corr = '91504';
    IF Adjuster_ID = '458' THEN Adj_Zip_Corr = '91504';
    IF Adjuster_ID = '459' THEN Adj_Zip_Corr = '91504';
    IF Adjuster_ID = '460' THEN Adj_Zip_Corr = '91504';
    IF Adjuster_ID = '461' THEN Adj_Zip_Corr = '91504';
    IF Adjuster_ID = '462' THEN Adj_Zip_Corr = '91504';
    IF Adjuster_ID = '463' THEN Adj_Zip_Corr = '91504';
    IF Adjuster_ID = '464' THEN Adj_Zip_Corr = '91504';
    IF Adjuster_ID = '465' THEN Adj_Zip_Corr = '91504';
    IF Adjuster_ID = '466' THEN Adj_Zip_Corr = '89002';
    IF Adjuster_ID = '467' THEN Adj_Zip_Corr = '89002';
    IF Adjuster_ID = '468' THEN Adj_Zip_Corr = '89002';
    IF Adjuster_ID = '469' THEN Adj_Zip_Corr = '89002';
    IF Adjuster_ID = '470' THEN Adj_Zip_Corr = '89014';
    IF Adjuster_ID = '471' THEN Adj_Zip_Corr = '89014';
    IF Adjuster_ID = '472' THEN Adj_Zip_Corr = '89014';
    IF Adjuster_ID = '473' THEN Adj_Zip_Corr = '89014';
    IF Adjuster_ID = '474' THEN Adj_Zip_Corr = '89014';
    IF Adjuster_ID = '475' THEN Adj_Zip_Corr = '89014';
    IF Adjuster_ID = '476' THEN Adj_Zip_Corr = '89014';
    IF Adjuster_ID = '477' THEN Adj_Zip_Corr = '89014';
    IF Adjuster_ID = '478' THEN Adj_Zip_Corr = '89014';
    IF Adjuster_ID = '479' THEN Adj_Zip_Corr = '89014';
    IF Adjuster_ID = '480' THEN Adj_Zip_Corr = '89101';
    IF Adjuster_ID = '481' THEN Adj_Zip_Corr = '89101';
    IF Adjuster_ID = '482' THEN Adj_Zip_Corr = '89101';
    IF Adjuster_ID = '483' THEN Adj_Zip_Corr = '89101';
    IF Adjuster_ID = '484' THEN Adj_Zip_Corr = '89101';
    IF Adjuster_ID = '485' THEN Adj_Zip_Corr = '89102';
    IF Adjuster_ID = '486' THEN Adj_Zip_Corr = '89102';
    IF Adjuster_ID = '487' THEN Adj_Zip_Corr = '89102';
    IF Adjuster_ID = '488' THEN Adj_Zip_Corr = '89102';
    IF Adjuster_ID = '489' THEN Adj_Zip_Corr = '89102';
    IF Adjuster_ID = '490' THEN Adj_Zip_Corr = '89106';
    IF Adjuster_ID = '491' THEN Adj_Zip_Corr = '89106';
    IF Adjuster_ID = '492' THEN Adj_Zip_Corr = '89106';
    IF Adjuster_ID = '493' THEN Adj_Zip_Corr = '89106';
    IF Adjuster_ID = '494' THEN Adj_Zip_Corr = '89106';
    IF Adjuster_ID = '495' THEN Adj_Zip_Corr = '89108';
    IF Adjuster_ID = '496' THEN Adj_Zip_Corr = '89108';
    IF Adjuster_ID = '497' THEN Adj_Zip_Corr = '89108';
    IF Adjuster_ID = '498' THEN Adj_Zip_Corr = '89108';
    IF Adjuster_ID = '499' THEN Adj_Zip_Corr = '89108';
    IF Adjuster_ID = '500' THEN Adj_Zip_Corr = '89127';
    IF Adjuster_ID = '501' THEN Adj_Zip_Corr = '89127';
    IF Adjuster_ID = '502' THEN Adj_Zip_Corr = '89127';
    IF Adjuster_ID = '503' THEN Adj_Zip_Corr = '89127';
    IF Adjuster_ID = '504' THEN Adj_Zip_Corr = '89127';
    IF Adjuster_ID = '505' THEN Adj_Zip_Corr = '89125';
    IF Adjuster_ID = '506' THEN Adj_Zip_Corr = '89125';
    IF Adjuster_ID = '507' THEN Adj_Zip_Corr = '89125';
    IF Adjuster_ID = '508' THEN Adj_Zip_Corr = '89125';
    IF Adjuster_ID = '509' THEN Adj_Zip_Corr = '89125';
    IF Adjuster_ID = '510' THEN Adj_Zip_Corr = '89125';
    IF Adjuster_ID = '511' THEN Adj_Zip_Corr = '89125';
    IF Adjuster_ID = '512' THEN Adj_Zip_Corr = '89125';
    IF Adjuster_ID = '513' THEN Adj_Zip_Corr = '89125';
    IF Adjuster_ID = '514' THEN Adj_Zip_Corr = '89125';
    IF Adjuster_ID = '515' THEN Adj_Zip_Corr = '89152';
    IF Adjuster_ID = '516' THEN Adj_Zip_Corr = '89152';
    IF Adjuster_ID = '517' THEN Adj_Zip_Corr = '89152';
    IF Adjuster_ID = '518' THEN Adj_Zip_Corr = '89152';
    IF Adjuster_ID = '519' THEN Adj_Zip_Corr = '89152';
    IF Adjuster_ID = '520' THEN Adj_Zip_Corr = '89152';
    IF Adjuster_ID = '521' THEN Adj_Zip_Corr = '89152';
    IF Adjuster_ID = '522' THEN Adj_Zip_Corr = '89152';
    IF Adjuster_ID = '523' THEN Adj_Zip_Corr = '89152';
    IF Adjuster_ID = '524' THEN Adj_Zip_Corr = '89152';
    IF Adjuster_ID = '525' THEN Adj_Zip_Corr = '89150';
    IF Adjuster_ID = '526' THEN Adj_Zip_Corr = '89150';
    IF Adjuster_ID = '527' THEN Adj_Zip_Corr = '89150';
    IF Adjuster_ID = '528' THEN Adj_Zip_Corr = '89150';
    IF Adjuster_ID = '529' THEN Adj_Zip_Corr = '89150';
    IF Adjuster_ID = '530' THEN Adj_Zip_Corr = '89160';
    IF Adjuster_ID = '531' THEN Adj_Zip_Corr = '89160';
    IF Adjuster_ID = '532' THEN Adj_Zip_Corr = '89160';
    IF Adjuster_ID = '533' THEN Adj_Zip_Corr = '89160';
    IF Adjuster_ID = '534' THEN Adj_Zip_Corr = '89160';
    IF Adjuster_ID = '535' THEN Adj_Zip_Corr = '89177';
    IF Adjuster_ID = '536' THEN Adj_Zip_Corr = '89177';
    IF Adjuster_ID = '537' THEN Adj_Zip_Corr = '89177';
    IF Adjuster_ID = '538' THEN Adj_Zip_Corr = '89177';
    IF Adjuster_ID = '539' THEN Adj_Zip_Corr = '89177';
    IF Adjuster_ID = '540' THEN Adj_Zip_Corr = '89177';
run;

/* Merge adjuster_technician with the customer_transactions */

PROC SORT DATA = adjuster_technician;
    BY  Cov_ID;
RUN;

PROC SORT DATA = customer_transactions;
    BY  Cov_ID;
RUN;

DATA customer_transactions;
    LENGTH  Cov_ID $ 20;
    MERGE   adjuster_technician
            customer_transactions;
    BY      Cov_ID;
RUN; 

/* Shows how many missing adjuster_technician observations there are */
/*
PROC FREQ  DATA = customer_transactions NLEVELS ORDER = FREQ;
    TABLES Adj_Zip;
    WHERE  Adj_Zip IS MISSING;
RUN;
*/

/* Look at the frequency distribution of blood types */
/*
PROC FREQ  DATA = customer_info NLEVELS ORDER = FREQ;
    TABLES BloodType;
RUN;
*/

/* Look at the distribution of race and sex */
/*
PROC FREQ DATA = customer_info NLEVELS ORDER = FREQ;
    TABLES Gender*Race;
RUN;

PROC MEANS DATA = customer_transactions;
    WHERE Reward_A IS NOT MISSING;
    VAR   Reward_A;
RUN;

PROC FREQ DATA = customer_transactions NLEVELS ORDER = FREQ;
    WHERE Reward_A IS NOT MISSING;
    TABLES Type Reward_R;
RUN;
*/

/* Coding Reward_R into Reward as a categorical variable */
DATA work.customer_transactions;
    SET    work.customer_transactions;
    LENGTH Reward_Cat 3;

    IF      (Reward_R = .)           THEN Reward_Cat = 0;
    ELSE IF (100 <= Reward_R <= 199) THEN Reward_Cat = 1;
    ELSE IF (200 <= Reward_R <= 299) THEN Reward_Cat = 2;
    ELSE IF (300 <= Reward_R <= 499) THEN Reward_Cat = 3;
    ELSE IF (500 <= Reward_R <= 549) THEN Reward_Cat = 4;
    ELSE IF (550 <= Reward_R <= 559) THEN Reward_Cat = 5;
    ELSE IF (560 <= Reward_R <= 569) THEN Reward_Cat = 6;
    ELSE IF (570 <= Reward_R <= 579) THEN Reward_Cat = 7;
    ELSE                                  Reward_Cat = 8;
RUN;

/* Lookup table for reward codes */
DATA reward_codes;

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
DATA bmi_codes;

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

/* Modifications to the customer_info table 
   1. Create BMI
   2. Create BMI Prime
   3. Create height_inches
   4. Separate vehicle_year from vehicle_model 
*/
DATA work.customer_info;
    SET     work.customer_info;

    LENGTH  vehicle_year   4
            vehicle_model $35
            height_inches  3
            bmi            5
            bmi_code       3
            bmi_prime      5
            race_sex      $2;

    FORMAT  bmi            5.2
            bmi_prime      5.2;

    DROP    vehicle
            feetinches
            feet
            inches
            tempSex;

    vehicle_year  = SUBSTR(vehicle,1,4);
    vehicle_model = SUBSTR(vehicle,6); /* 5 is a space */

    feet          = SUBSTR(feetinches,1,1) + 0;
    inches        = SUBSTR(feetinches, LENGTH(feetinches)-2,2) + 0;
    height_inches = (feet * 12) + inches;

    bmi           = (pounds/(height_inches * height_inches)) * 703;
    bmi_prime     = bmi / 25;

    IF      bmi < 15.0         THEN bmi_code = 1;
    ELSE IF 15.0 <= bmi < 16.0 THEN bmi_code = 2;
    ELSE IF 16.0 <= bmi < 18.5 THEN bmi_code = 3;
    ELSE IF 18.5 <= bmi < 25.0 THEN bmi_code = 4;
    ELSE IF 25.0 <= bmi < 30.0 THEN bmi_code = 5;
    ELSE IF 30.0 <= bmi < 35.0 THEN bmi_code = 6;
    ELSE IF 35.0 <= bmi < 40.0 THEN bmi_code = 7;
    ELSE IF 40.0 <= bmi < 99.0 THEN bmi_code = 8;
    ELSE bmi = .;

    IF      Gender = 'male'   THEN tempSex = 'M';
    ELSE IF Gender = 'female' THEN tempSex = 'F';
    ELSE    Gender = 'U';

    race_sex = CATS(Race,tempSex);
RUN;


/* Puts the income and coverage limit into the same rows as the reward amounts */
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
           Initial_Cov_Date 8.;

    FORMAT tDate            DATE9.
           Claim_Date       DATE9.
           Transaction_Date DATE9.
           Initial_Cov_Date DATE9.;

    RETAIN tIncome
           tLimit
           tDate
           tDateIN;

    BY  Cov_ID;

    Transaction_Date = Date;

    IF  FIRST.Cov_ID THEN 
        DO;
            IF Transaction = 'IN' THEN tDateIN = Date;
            tIncome = income;
            tLimit  = cov_limit;
            tDate   = Date;
        END;

    IF  ~LAST.Cov_ID THEN
        DO;
            tIncome = income;
            tLimit  = cov_limit;
            tDate   = Date;
        END;

    IF  LAST.Cov_ID & Transaction = 'RE' THEN
        DO;
            income           = tIncome;
            cov_limit        = tLimit;
            Claim_Date       = tDate;
            Initial_Cov_Date = tDateIN;
        END;

    DROP tIncome
         tLimit
         tDate
         Date
         iDateIN;
RUN;


/* Add the Cust_ID to the adjuster_technician table */
DATA adjuster_technician;
    SET     adjuster_technician;
    LENGTH  Cust_ID $30;

    Cust_ID = SUBSTR(Cov_ID, 1, LENGTH(Cov_ID) - 1);
RUN;


/* Defining a case a DEAD customer who has been adjudicated */
DATA cases_all;
     SET customer_transactions(WHERE=(Reward_Cat > 0));
RUN;

/*
PROC FREQ DATA = customer_transactions(WHERE=(Reward_Cat > 0)) NLEVELS ORDER=FREQ;
    TABLES Reward_Cat / NOCUM;
RUN;

PROC FREQ DATA = cases_rewarded NLEVELS ORDER=FREQ;
    TABLES Reward_Cat;
RUN;

PROC FREQ DATA = cases_denied NLEVELS ORDER=FREQ;
    TABLES Reward_Cat;
RUN;

PROC PRINT DATA = reward_codes NOOBS;
RUN;
*/

/* Sort the Customer Medical and Customer Family Medical tables by Cust_ID */

PROC SORT DATA = customer_family_medical;
    BY Cust_ID;
RUN;

PROC SORT DATA = customer_medical;
    BY Cust_ID Date;
RUN;

/* customer_medical has a blank record for each date of a Transaction type RE. 
   Those records are garbage and useless and can be deleted. 
   Use a missing Tobacco_Num value as proxy for garbage data.
*/

DATA customer_medical;
    SET customer_medical;

    IF Tobacco_Num ~= . THEN OUTPUT;
RUN;

/* This creates a table of the last recorded customer medical records */
DATA customer_med_recent;
    SET customer_medical;
    BY  Cust_ID;

    IF LAST.Cust_ID;
RUN;

/* Merge the last known customer_medical record with the customer_family_medical */
DATA customer_med_recent_total;
    MERGE customer_med_recent
          customer_family_medical;

    BY    Cust_ID;
RUN;

/* Merge cases_all with the customer_med_recent_total 
   to build a comprehensive table that can be used for calculating 
   summary medical statistics about customers who died from a medical 
   cause. */

PROC SORT DATA = cases_all;
    BY Cust_ID;
RUN;

 /* Merge medical records into cases_all excluding non-matches */
DATA cases_all;
    MERGE cases_all                 (IN = in_CA)
          customer_med_recent_total (IN = in_CMRT);

    BY    Cust_ID;

    IF    in_CA AND
          in_CMRT;
RUN;      

/* Merge the Customer_Info table with cases_all
   so that we can run comprehensive customer statistics from people 
   who died from medical causes -- all their med info will be in the 
   same place with their other info. */

DATA cases_all;
    MERGE customer_info (IN = in_CI)
          cases_all     (IN = in_CA);

    BY    Cust_ID;

    IF    in_CI AND
          in_CA;
RUN;

/* Drop transition tables that aren't needed */
PROC DATASETS LIBRARY = work NOLIST;
    DELETE customer_med_recent_total;
RUN;

/*
LIBNAME exp 'C:\iaa\export';

DATA exp.customer_medical;
    SET work.customer_medical;
RUN;
*/

/* Calculate age at death, length of adjudication and length policy was held */
DATA cases_all;
    SET cases_all;

    LENGTH Death_Age_Years   5.2
           Policy_Held_Years 5.2
           Adjudication_Days 8.;

    FORMAT Death_Age_Years   5.2
           Policy_Held_Years 5.2
           Reward_Date       DATE9.;

    Reward_Date       = Transaction_Date;
    Death_Age_Days    = Claim_Date - Birthday;
    Death_Age_Years   = Death_Age_Days / 365.2425;
    Death_Year        = YEAR(Reward_Date);
    Adjudication_Days = Reward_Date - Claim_Date;
    Policy_Held_Years = (Claim_Date - Initial_Cov_Date) / 365.2425;

    DROP Date
         Transaction_Date;
RUN;


/* Create age bins for descriptive statistics purposes */
DATA cases_all;
    SET cases_all;

    LENGTH Death_Age_Group $8.;

    SELECT;
        WHEN (Death_Age_Years < 20)       Death_Age_Group = '0-20';
        WHEN (20 <= Death_Age_Years < 25) Death_Age_Group = '20-25';
        WHEN (25 <= Death_Age_Years < 30) Death_Age_Group = '25-30';
        WHEN (30 <= Death_Age_Years < 35) Death_Age_Group = '30-35';
        WHEN (35 <= Death_Age_Years < 40) Death_Age_Group = '35-40';
        WHEN (40 <= Death_Age_Years < 45) Death_Age_Group = '40-45';
        WHEN (45 <= Death_Age_Years < 50) Death_Age_Group = '45-50';
        WHEN (50 <= Death_Age_Years < 55) Death_Age_Group = '50-55';
        WHEN (55 <= Death_Age_Years < 60) Death_Age_Group = '55-60';
        WHEN (60 <= Death_Age_Years < 65) Death_Age_Group = '60-65';
        WHEN (65 <= Death_Age_Years < 70) Death_Age_Group = '65-70';
        WHEN (70 <= Death_Age_Years < 75) Death_Age_Group = '70-75';
        WHEN (75 <= Death_Age_Years < 80) Death_Age_Group = '75-80';
        WHEN (80 <= Death_Age_Years < 85) Death_Age_Group = '80-85';
        WHEN (85 <= Death_Age_Years < 90) Death_Age_Group = '85-90';
        WHEN (Death_Age_Years > 90)       Death_Age_Group = '90 +';
    END;
RUN;

PROC FREQ DATA = cases_all NLEVELS;
    TABLES Death_Age_Group*Gender / NOCUM;
RUN;

PROC FREQ DATA = cases_all;
    TABLES Gender;
RUN;

DATA reward_before_claim;
    SET customer_transactions;
    IF  Cust_ID = 'PSX000406624' OR
        Cust_ID = 'PSX000511596' OR
        Cust_ID = 'PSX000605278' OR
        Cust_ID = 'PSX000658707' OR
        Cust_ID = 'PSX00069101'  OR
        Cust_ID = 'PSX000733780' OR
        Cust_ID = 'PSX000830451';
RUN;

/* Build several tables that segregate cases adjudicated */
DATA cases_rewarded 
     cases_denied
     cases_rewarded_medical;

    SET cases_all;

    IF (1 <= Reward_Cat < 4)  THEN OUTPUT cases_rewarded;
    ELSE IF (Reward_Cat >= 4) THEN OUTPUT cases_denied;

    IF      (Reward_Cat = 3)  THEN OUTPUT cases_rewarded_medical;
RUN;


PROC FREQ DATA = cases_rewarded_medical NLEVELS ORDER=FREQ;
    TABLES Reward_R / NOCUM;
RUN;

/********************************************
 * Name: corrgraph                          *
 * Function: create scatter plot with       *
 * correlation coefficient displyed         *
 * most of gplot features are available.    *
 * %corgraph(data=, varx=, vary=)         *
 *******************************************/

/*%macro corrgraph(data=, varx=, vary=, outfile= ' ', dev=gif373,*/
/*                 title=' ',axisx=, axisy=, symbol=, gopt=, plot=, */
/*                 labelx=' ', labely=' '); */
/**/
/* proc corr data=&data  noprint outp=_rcorr_;*/
/*  var &varx &vary;*/
/* run;*/
/**/
/* /*trim r to three decimal places or less*/*/
/* data _null_; /*put correlation coefficient to r*/*/
/*   set _rcorr_;*/
/*   if _n_=4 then do;*/
/*   r = &vary + 0;*/
/*   if r = 1 then r1 = 1;*/
/*   else if r = -1 then r1 = -1;*/
/*   else if r = 0 then r1 = 0;*/
/*   else  r1 = input(r, 5.);*/
/*   call symput('r1',left(r1));*/
/*   end;*/
/* run;*/
/* */
/*  %if &title ne ' ' %then %do;*/
/*      %let tle = &title; */
/*      %let tle2 = "Correlation Coefficient = &r1 ";*/
/*      %end;*/
/*  %else %do;*/
/*      %let tle = "Correlation Coefficient = &r1"; */
/*      %let tle2 = " ";*/
/*      %end;*/
/*  %if &labelx ne ' ' %then */
/*      %let lx=&labelx;*/
/*  %else %let lx="&varx"; */
/**/
/*  %if &labely ne ' ' %then   %let ly = &labely; */
/*  %else %let ly="&vary"; */
/**/
/* goptions reset = all;*/
/* %if &outfile ne ' ' %then %do;*/
/*    goptions dev=&dev;*/
/*    goptions gsfname=out;*/
/*    filename out &outfile;*/
/*  %end;*/
/* goptions &gopt;*/
/* axis1 label= (r=0 a=90) minor=none &axisx;*/
/* axis2 minor=none &axisy;*/
/* symbol c=yellow i=none v=circle &symbol;*/
/**/
/* proc gplot data=&data;*/
/*   plot &vary*&varx=1 /haxis=axisy vaxis=axisx cframe=lib &plot;*/
/*   title &tle;*/
/*   title2 &tle2;*/
/*   label &varx =&lx;*/
/*   label &vary=&ly;*/
/* run;*/
/* quit;*/
/**/
/*goptions reset = all;*/
/*title;*/
/**/
/*%mend;*/

/* %corrgraph(data=cases_rewarded_medical, varx=Birthday, vary=Death_Age_Years) */







/* People with CL claim dates AFTER their RE reward transaction dates */
/* Found them because the logic to fix the salary and coverage limit fields
   did not work properly on their data. This also could be a data entry 
   error with dates, but that seems unlikely -- especially when the other
   300,000+ are correct */

/*DATA reward_before_claim;*/
/*    SET customer_transactions;*/
/*    IF  Cust_ID = 'PSX000406624' OR*/
/*        Cust_ID = 'PSX000511596' OR*/
/*        Cust_ID = 'PSX000605278' OR*/
/*        Cust_ID = 'PSX000658707' OR*/
/*        Cust_ID = 'PSX00069101'  OR*/
/*        Cust_ID = 'PSX000733780' OR*/
/*        Cust_ID = 'PSX000830451';*/
/*RUN;*/

