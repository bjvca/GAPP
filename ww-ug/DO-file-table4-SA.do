       Serial number:  1990519589
         Licensed to:  Gen Haruna Sekabira
                       Univ Of Goettingen

Notes:
      1.  (/m# option or -set memory-) 1.00 MB allocated 
> to data

. use "C:\Users\Templeton\Desktop\A4\HSEC10A_CLN.dta", clear
no room to add more observations
    An attempt was made to increase the number of observations beyond what is currently possible.  You have the following alternatives:

     1.  Store your variables more efficiently; see help compress.  (Think of Stata's data area as the area of a rectangle; Stata can trade off width
         and length.)

     2.  Drop some variables or observations; see help drop.

     3.  Increase the amount of memory allocated to the data area using the set memory command; see help memory.
r(901);

. use "C:\Users\Templeton\Desktop\A4\HSEC10A_CLN.dta", clear
no room to add more observations
    An attempt was made to increase the number of observations beyond what is currently possible.  You have the following alternatives:

     1.  Store your variables more efficiently; see help compress.  (Think of Stata's data area as the area of a rectangle; Stata can trade off width
         and length.)

     2.  Drop some variables or observations; see help drop.

     3.  Increase the amount of memory allocated to the data area using the set memory command; see help memory.
r(901);

. clear

. use "C:\Users\Templeton\Desktop\A4\HSEC10A_CLN.dta", clear
no room to add more observations
    An attempt was made to increase the number of observations beyond what is currently possible.  You have the following alternatives:

     1.  Store your variables more efficiently; see help compress.  (Think of Stata's data area as the area of a rectangle; Stata can trade off width
         and length.)

     2.  Drop some variables or observations; see help drop.

     3.  Increase the amount of memory allocated to the data area using the set memory command; see help memory.
r(901);

. set memory 2m
(2048k)

. use "C:\Users\Templeton\Desktop\A4\HSEC10A_CLN.dta", clear
no room to add more observations
    An attempt was made to increase the number of observations beyond what is currently possible.  You have the following alternatives:

     1.  Store your variables more efficiently; see help compress.  (Think of Stata's data area as the area of a rectangle; Stata can trade off width
         and length.)

     2.  Drop some variables or observations; see help drop.

     3.  Increase the amount of memory allocated to the data area using the set memory command; see help memory.
r(901);

. set memory 4m
(4096k)

. use "C:\Users\Templeton\Desktop\A4\HSEC10A_CLN.dta", clear
no room to add more observations
    An attempt was made to increase the number of observations beyond what is currently possible.  You have the following alternatives:

     1.  Store your variables more efficiently; see help compress.  (Think of Stata's data area as the area of a rectangle; Stata can trade off width
         and length.)

     2.  Drop some variables or observations; see help drop.

     3.  Increase the amount of memory allocated to the data area using the set memory command; see help memory.
r(901);

. clear

. set memory 500m
(512000k)

. use "C:\Users\Templeton\Desktop\A4\HSEC10A_CLN.dta", clear

. describe

Contains data from C:\Users\Templeton\Desktop\A4\HSEC10A_CLN.dta
  obs:        89,597                          
 vars:            13                          15 Mar 2013 15:28
 size:     5,555,014 (98.9% of memory free)
-------------------------------------------------------------------------------
              storage  display     value
variable name   type   format      label      variable label
-------------------------------------------------------------------------------
hh              double %13.0f                 Household Code
itmcd           float  %16.0g      HS10A2     code
untcd           int    %23.0g      HS10A3     Unit of Quantity
h10aq4          float  %9.0g                  Qty consumed out of purchases
h10aq5          long   %12.0g                 Value of consumption out of
                                                purchases
h10aq6          float  %9.0g                  Qty consumed away from home
h10aq7          long   %12.0g                 Value of consumption away from
                                                home
h10aq8          float  %9.0g                  Qty consumed out of home produce
h10aq9          long   %12.0g                 Value of consumption out of
                                                home produce
h10aq10         float  %9.0g                  Qty recieved in-kind/free
h10aq11         long   %12.0g                 Value of items recieved
                                                in-kind/free
h10aq12         double %12.0g                 Market Price
h10aq13         long   %12.0g                 Farm-Gate price
-------------------------------------------------------------------------------
Sorted by:  hh

. use "C:\Users\Templeton\Desktop\A4\HSEC10AA.dta", clear

. describe

Contains data from C:\Users\Templeton\Desktop\A4\HSEC10AA.dta
  obs:         6,775                          
 vars:             9                          15 Mar 2013 15:28
 size:       149,050 (99.9% of memory free)
-------------------------------------------------------------------------------
              storage  display     value
variable name   type   format      label      variable label
-------------------------------------------------------------------------------
hh              str10  %10s                   Household Code
h10aaq1         byte   %8.0g                  Male adults members
h10aaq2         byte   %8.0g                  Female adults members
h10aaq3         byte   %8.0g                  Male children members
h10aaq4         byte   %8.0g                  Female children members
h10aaq5         byte   %8.0g                  Male adults
h10aaq6         byte   %8.0g                  Female adults
h10aaq7         byte   %8.0g                  Male children
h10aaq8         byte   %8.0g                  Female children
-------------------------------------------------------------------------------
Sorted by:  hh

. use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\ww-ug\foodcomp_uganda_hhsurvey2009_v5.dta", clear

. describe

Contains data from C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\ww-ug\foodcomp_uganda_hhsurvey2009_v5.dta
  obs:            62                          
 vars:             4                          15 Mar 2013 15:27
 size:         2,480 (99.9% of memory free)
-------------------------------------------------------------------------------
              storage  display     value
variable name   type   format      label      variable label
-------------------------------------------------------------------------------
product         int    %8.0g                  
descript        str26  %26s                   
kcal_100g       float  %9.0g                  
edible          float  %9.0g                  
-------------------------------------------------------------------------------
Sorted by:  

. use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdata_6_2009.dta", clear

. describe

Contains data from C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdata_6_2009.dta
  obs:         6,775                          
 vars:            20                          25 Mar 2013 16:35
 size:       460,700 (99.9% of memory free)
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

. use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\calperg_6_2009.dta", clear

. describe

Contains data from C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\calperg_6_2009.dta
  obs:            62                          
 vars:             3                          25 Mar 2013 16:35
 size:         2,480 (99.9% of memory free)
-------------------------------------------------------------------------------
              storage  display     value
variable name   type   format      label      variable label
-------------------------------------------------------------------------------
product         int    %8.0g                  Food product code: numerical
descript        str26  %26s                   Product Description: incl.
                                                product code in the beginning
calperg         double %10.0g                 Calorie content of food
                                                product: calories per gram
-------------------------------------------------------------------------------
Sorted by:  

. use "C:\Users\Templeton\Desktop\A4\HSEC10A_CLN.dta", clear

. describe

Contains data from C:\Users\Templeton\Desktop\A4\HSEC10A_CLN.dta
  obs:        89,597                          
 vars:            13                          15 Mar 2013 15:28
 size:     5,555,014 (98.9% of memory free)
-------------------------------------------------------------------------------
              storage  display     value
variable name   type   format      label      variable label
-------------------------------------------------------------------------------
hh              double %13.0f                 Household Code
itmcd           float  %16.0g      HS10A2     code
untcd           int    %23.0g      HS10A3     Unit of Quantity
h10aq4          float  %9.0g                  Qty consumed out of purchases
h10aq5          long   %12.0g                 Value of consumption out of
                                                purchases
h10aq6          float  %9.0g                  Qty consumed away from home
h10aq7          long   %12.0g                 Value of consumption away from
                                                home
h10aq8          float  %9.0g                  Qty consumed out of home produce
h10aq9          long   %12.0g                 Value of consumption out of
                                                home produce
h10aq10         float  %9.0g                  Qty recieved in-kind/free
h10aq11         long   %12.0g                 Value of items recieved
                                                in-kind/free
h10aq12         double %12.0g                 Market Price
h10aq13         long   %12.0g                 Farm-Gate price
-------------------------------------------------------------------------------
Sorted by:  hh

. ren hh hhid

. ren  itmcd product

. tab product

                  code |      Freq.     Percent        Cum.
-----------------------+-----------------------------------
     Matooke (Cluster) |        274        0.31        0.31
   Matooke (Big Bunch) |        149        0.17        0.47
Matooke (Medium Bunch) |        299        0.33        0.81
 Matooke (Small Bunch) |        780        0.87        1.68
        Matooke (Heap) |      1,362        1.52        3.20
Sweet Potatoes (Fresh) |      3,250        3.63        6.82
  Sweet Potatoes (Dry) |        120        0.13        6.96
       Cassava (Fresh) |      2,890        3.23       10.18
  Cassava (Dry/ Flour) |      1,849        2.06       12.25
        Irish Potatoes |        843        0.94       13.19
                  Rice |      1,730        1.93       15.12
        Maize (grains) |        452        0.50       15.62
          Maize (cobs) |      1,214        1.35       16.98
         Maize (flour) |      3,591        4.01       20.99
                 Bread |      1,606        1.79       22.78
                Millet |        962        1.07       23.85
               Sorghum |      1,232        1.38       25.23
                  Beef |      2,161        2.41       27.64
                  Pork |        477        0.53       28.17
             Goat Meat |        534        0.60       28.77
            Other Meat |        114        0.13       28.89
               Chicken |        691        0.77       29.67
            Fresh Fish |      1,167        1.30       30.97
      Dry/ Smoked fish |      1,892        2.11       33.08
                  Eggs |      1,106        1.23       34.31
            Fresh Milk |      2,324        2.59       36.91
  Infant Formula Foods |         38        0.04       36.95
           Cooking oil |      3,921        4.38       41.33
                  Ghee |        320        0.36       41.68
Margarine, Butter, etc |        272        0.30       41.99
        Passion Fruits |        904        1.01       43.00
         Sweet Bananas |      1,313        1.47       44.46
                Mangos |      1,336        1.49       45.95
               Oranges |        648        0.72       46.68
          Other Fruits |      1,242        1.39       48.06
                Onions |      4,776        5.33       53.39
              Tomatoes |      4,551        5.08       58.47
              Cabbages |      1,728        1.93       60.40
                  Dodo |      2,697        3.01       63.41
      Other vegetables |      2,567        2.87       66.28
          Beans fresh) |      1,264        1.41       67.69
           Beans (dry) |      4,146        4.63       72.31
Ground nuts (in shell) |        374        0.42       72.73
 Ground nuts (shelled) |        533        0.59       73.33
 Ground nuts (pounded) |      1,801        2.01       75.34
                  Peas |        517        0.58       75.91
               Sim sim |        798        0.89       76.81
                 Sugar |      4,261        4.76       81.56
                Coffee |        512        0.57       82.13
                   Tea |      4,037        4.51       86.64
                  Salt |      6,157        6.87       93.51
                  Soda |        806        0.90       94.41
                  Beer |        323        0.36       94.77
Other Alcoholic drinks |      1,085        1.21       95.98
          Other drinks |        373        0.42       96.40
            Cigarettes |        555        0.62       97.02
         Other Tobacco |        833        0.93       97.95
                  Food |        894        1.00       98.94
                  soda |        292        0.33       99.27
                  Beer |         90        0.10       99.37
           Other juice |        139        0.16       99.53
           Other foods |        425        0.47      100.00
-----------------------+-----------------------------------
                 Total |     89,597      100.00

. gen food_cat = 1

. d

Contains data from C:\Users\Templeton\Desktop\A4\HSEC10A_CLN.dta
  obs:        89,597                          
 vars:            14                          15 Mar 2013 15:28
 size:     5,913,402 (98.9% of memory free)
-------------------------------------------------------------------------------
              storage  display     value
variable name   type   format      label      variable label
-------------------------------------------------------------------------------
hhid            double %13.0f                 Household Code
product         float  %16.0g      HS10A2     code
untcd           int    %23.0g      HS10A3     Unit of Quantity
h10aq4          float  %9.0g                  Qty consumed out of purchases
h10aq5          long   %12.0g                 Value of consumption out of
                                                purchases
h10aq6          float  %9.0g                  Qty consumed away from home
h10aq7          long   %12.0g                 Value of consumption away from
                                                home
h10aq8          float  %9.0g                  Qty consumed out of home produce
h10aq9          long   %12.0g                 Value of consumption out of
                                                home produce
h10aq10         float  %9.0g                  Qty recieved in-kind/free
h10aq11         long   %12.0g                 Value of items recieved
                                                in-kind/free
h10aq12         double %12.0g                 Market Price
h10aq13         long   %12.0g                 Farm-Gate price
food_cat        float  %9.0g                  
-------------------------------------------------------------------------------
Sorted by:  hhid
     Note:  dataset has changed since last saved

. browse 

. gen price == h10aq12 
== invalid name
r(198);

. gen price = h10aq12 
(21673 missing values generated)

. replace  price = h10aq13 if price == .
(20215 real changes made)

. gen valuez =  h10aq5 +  h10aq7 + h10aq9 
(89595 missing values generated)

. drop valuez

. egen valuez_food =rowsum ( h10aq5 h10aq7 h10aq9)
unrecognized command:  _growsum
r(199);

. egen valuez_food = rowsum ( h10aq5 h10aq7 h10aq9)
unrecognized command:  _growsum
r(199);

. egen valuez_food = rowtotal ( h10aq5 h10aq7 h10aq9)

. egen quantityz =  rowtotal ( h10aq4 h10aq6 h10aq8)

. rename  valuez_food valuez

. d valuez

              storage  display     value
variable name   type   format      label      variable label
-------------------------------------------------------------------------------
valuez          float  %9.0g                  

. rename  untcd unit

. keep  hhid product food_cat valuez quantityz

. save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\cons_cod_trans.dta"
file C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\cons_cod_trans.dta saved

. describe

Contains data from C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\cons_cod_trans.dta
  obs:        89,597                          
 vars:             5                          3 Apr 2013 11:15
 size:     2,508,716 (99.5% of memory free)
-------------------------------------------------------------------------------
              storage  display     value
variable name   type   format      label      variable label
-------------------------------------------------------------------------------
hhid            double %13.0f                 Household Code
product         float  %16.0g      HS10A2     code
food_cat        float  %9.0g                  
valuez          float  %9.0g                  
quantityz       float  %9.0g                  
-------------------------------------------------------------------------------
Sorted by:  hhid

