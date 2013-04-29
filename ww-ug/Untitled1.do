
. use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdata_6_2009.dta", clear

. describe

Contains data from C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdata_6_2009.dta
  obs:         6,775                          
 vars:            20                          25 Mar 2013 16:35
 size:       460,700 (56.1% of memory free)
-------------------------------------------------------------------------------
              storage  display     value
variable name   type   format      label      variable label
-------------------------------------------------------------------------------
hhid            double %13.0f                 Household ID
strata          byte   %13.0g      STRA       Strata
mult            float  %9.0g                  Individual weights
region          byte   %10.0g      lbreg      Region
urban           byte   %10.0g      lbur       Place of residence
district        int    %10.0g                 District Code
spdomain        float  %13.0g      lbregu     Spatial domains: each with own
                                                poverty line
rmult           float  %9.0g                  Rounded mult weights
hhsize          double %9.0g                  Household Size
welfare         float  %9.0g                  Household Welfare Indicator
hhweight        float  %9.0g                  Household sample weight
poor09          float  %9.0g       lbpoor     Poverty status
day             byte   %8.0g                  DAY OF INTERVIEW
month           byte   %8.0g                  MONTH OF INTERVIEW
Year            int    %8.0g                  YEAR OF INTERVIEW
h1bq8           byte   %14.0g      Q1B8       RESPONSE CODE
psu             int    %10.0g                 Primary Sampling Unit
survquar        float  %11.0g      lsurvquar
                                              Sequential Survey Quarter
                                                May-Jun 09=1)
survmon         float  %9.0g       lsurvmon   Sequential Survey Month (May
                                                2009=1)
rural           float  %9.0g       lrural     Rural/Urban Location
-------------------------------------------------------------------------------
Sorted by:  hhid

. browse psu

. codebook psu


. use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\ww-ug\HSEC2.dta", clear

. describe

Contains data from C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\ww-ug\HSEC2.dta
  obs:        36,432                          
 vars:             9                          15 Mar 2013 15:29
 size:       728,640 (30.5% of memory free)
-------------------------------------------------------------------------------
              storage  display     value
variable name   type   format      label      variable label
-------------------------------------------------------------------------------
hh              double %10.0g                 Household Code
h2q1            byte   %8.0g                  person Id
h2q3            byte   %8.0g       HS23       Sex
h2q4            byte   %32.0g      HS24       What is the relationship of
                                                [NAME] to the head of the
                                                househ
h2q5            byte   %47.0g      HS25       What is the residential status
                                                of [NAME]?
h2q6            byte   %8.0g       HS26       During the past 12 months, how
                                                many months did [NAME] live h
h2q7            byte   %41.0g      HS27       If [NAME] has not   stayed for
                                                12 months, what is the main r
h2q8            byte   %8.0g       HS28       How old is [NAME] in completed
                                                years?
h2q9            byte   %20.0g      HS29       What is the present marital
                                                status of [NAME]?
-------------------------------------------------------------------------------
Sorted by:  hh

. codebook  h2q8

-------------------------------------------------------------------------------------------------------------------------------------------------------
h2q8                                                                                                              How old is [NAME] in completed years?
-------------------------------------------------------------------------------------------------------------------------------------------------------

                  type:  numeric (byte)
                 label:  HS28, but label does not exist

                 range:  [0,98]                       units:  1
         unique values:  98                       missing .:  1592/36432

. describe

Contains data from C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\inddata_6_2009.dta
  obs:        35,945                          
 vars:             5                          25 Mar 2013 16:35
 size:       934,570 (10.9% of memory free)
-------------------------------------------------------------------------------
              storage  display     value
variable name   type   format      label      variable label
-------------------------------------------------------------------------------
indid           double %10.0g                 Individual ID
motherhh        float  %9.0g       lmoth      Mother lives in hh
hhid            double %10.0g                 Household ID
sex             byte   %8.0g       HS23       Sex
age             byte   %8.0g       HS28       Age in years completed
-------------------------------------------------------------------------------
Sorted by:  

