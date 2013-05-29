                    Univ Of Goettingen

Notes:
      1.  (/m# option or -set memory-) 1.00 MB allocated 
> to data

. sysuse auto
(1978 Automobile Data)

. describe

Contains data from C:\Program Files (x86)\Stata9\ado\base/a/auto.dta
  obs:            74                          1978 Automobile Data
 vars:            12                          13 Apr 2005 17:45
 size:         3,478 (99.7% of memory free)   (_dta has notes)
-------------------------------------------------------------------------------
              storage  display     value
variable name   type   format      label      variable label
-------------------------------------------------------------------------------
make            str18  %-18s                  Make and Model
price           int    %8.0gc                 Price
mpg             int    %8.0g                  Mileage (mpg)
rep78           int    %8.0g                  Repair Record 1978
headroom        float  %6.1f                  Headroom (in.)
trunk           int    %8.0g                  Trunk space (cu. ft.)
weight          int    %8.0gc                 Weight (lbs.)
length          int    %8.0g                  Length (in.)
turn            int    %8.0g                  Turn Circle (ft.) 
displacement    int    %8.0g                  Displacement (cu. in.)
gear_ratio      float  %6.2f                  Gear Ratio
foreign         byte   %8.0g       origin     Car type
-------------------------------------------------------------------------------
Sorted by:  foreign

. summarize

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
        make |         0
       price |        74    6165.257    2949.496       3291      15906
         mpg |        74     21.2973    5.785503         12         41
       rep78 |        69    3.405797    .9899323          1          5
    headroom |        74    2.993243    .8459948        1.5          5
-------------+--------------------------------------------------------
       trunk |        74    13.75676    4.277404          5         23
      weight |        74    3019.459    777.1936       1760       4840
      length |        74    187.9324    22.26634        142        233
        turn |        74    39.64865    4.399354         31         51
displacement |        74    197.2973    91.83722         79        425
-------------+--------------------------------------------------------
  gear_ratio |        74    3.014865    .4562871       2.19       3.89
     foreign |        74    .2972973    .4601885          0          1

. summarize

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
        make |         0
       price |        74    6165.257    2949.496       3291      15906
         mpg |        74     21.2973    5.785503         12         41
       rep78 |        69    3.405797    .9899323          1          5
    headroom |        74    2.993243    .8459948        1.5          5
-------------+--------------------------------------------------------
       trunk |        74    13.75676    4.277404          5         23
      weight |        74    3019.459    777.1936       1760       4840
      length |        74    187.9324    22.26634        142        233
        turn |        74    39.64865    4.399354         31         51
displacement |        74    197.2973    91.83722         79        425
-------------+--------------------------------------------------------
  gear_ratio |        74    3.014865    .4562871       2.19       3.89
     foreign |        74    .2972973    .4601885          0          1

. do "C:\Users\TEMPLE~1\AppData\Local\Temp\STD05000000.tmp"

. 
. 
end of do-file

. summarize

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
        make |         0
       price |        74    6165.257    2949.496       3291      15906
         mpg |        74     21.2973    5.785503         12         41
       rep78 |        69    3.405797    .9899323          1          5
    headroom |        74    2.993243    .8459948        1.5          5
-------------+--------------------------------------------------------
       trunk |        74    13.75676    4.277404          5         23
      weight |        74    3019.459    777.1936       1760       4840
      length |        74    187.9324    22.26634        142        233
        turn |        74    39.64865    4.399354         31         51
displacement |        74    197.2973    91.83722         79        425
-------------+--------------------------------------------------------
  gear_ratio |        74    3.014865    .4562871       2.19       3.89
     foreign |        74    .2972973    .4601885          0          1

. summarize

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
        make |         0
       price |        74    6165.257    2949.496       3291      15906
         mpg |        74     21.2973    5.785503         12         41
       rep78 |        69    3.405797    .9899323          1          5
    headroom |        74    2.993243    .8459948        1.5          5
-------------+--------------------------------------------------------
       trunk |        74    13.75676    4.277404          5         23
      weight |        74    3019.459    777.1936       1760       4840
      length |        74    187.9324    22.26634        142        233
        turn |        74    39.64865    4.399354         31         51
displacement |        74    197.2973    91.83722         79        425
-------------+--------------------------------------------------------
  gear_ratio |        74    3.014865    .4562871       2.19       3.89
     foreign |        74    .2972973    .4601885          0          1

. summarize */trying to find simple statistics*/
/ invalid name
r(198);

. summarize /* treying to do descripts*/
/ invalid name
r(198);

. summarize

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
        make |         0
       price |        74    6165.257    2949.496       3291      15906
         mpg |        74     21.2973    5.785503         12         41
       rep78 |        69    3.405797    .9899323          1          5
    headroom |        74    2.993243    .8459948        1.5          5
-------------+--------------------------------------------------------
       trunk |        74    13.75676    4.277404          5         23
      weight |        74    3019.459    777.1936       1760       4840
      length |        74    187.9324    22.26634        142        233
        turn |        74    39.64865    4.399354         31         51
displacement |        74    197.2973    91.83722         79        425
-------------+--------------------------------------------------------
  gear_ratio |        74    3.014865    .4562871       2.19       3.89
     foreign |        74    .2972973    .4601885          0          1

. summarize // trying descriptives
/ invalid name
r(198);

. summarize /* trying decripts */
/ invalid name
r(198);

. // sysuse
unrecognized command:  / invalid command name
r(199);

. version 9

. clear

. capture log close

. log using auto, text replace
(note: file C:\data\auto.log not found)
-------------------------------------------------------------------------------------------------------------------------------------------------------
       log:  C:\data\auto.log
  log type:  text
 opened on:  25 Mar 2013, 13:25:44

. summarize

. sysuse auto
(1978 Automobile Data)

. summarize

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
        make |         0
       price |        74    6165.257    2949.496       3291      15906
         mpg |        74     21.2973    5.785503         12         41
       rep78 |        69    3.405797    .9899323          1          5
    headroom |        74    2.993243    .8459948        1.5          5
-------------+--------------------------------------------------------
       trunk |        74    13.75676    4.277404          5         23
      weight |        74    3019.459    777.1936       1760       4840
      length |        74    187.9324    22.26634        142        233
        turn |        74    39.64865    4.399354         31         51
displacement |        74    197.2973    91.83722         79        425
-------------+--------------------------------------------------------
  gear_ratio |        74    3.014865    .4562871       2.19       3.89
     foreign |        74    .2972973    .4601885          0          1

. codebook make

-------------------------------------------------------------------------------------------------------------------------------------------------------
make                                                                                                                                     Make and Model
-------------------------------------------------------------------------------------------------------------------------------------------------------

                  type:  string (str18), but longest is str17

         unique values:  74                       missing "":  0/74

              examples:  "Cad. Deville"
                         "Dodge Magnum"
                         "Merc. XR-7"
                         "Pont. Catalina"

               warning:  variable has embedded blanks

. codebook rep78

-------------------------------------------------------------------------------------------------------------------------------------------------------
rep78                                                                                                                                Repair Record 1978
-------------------------------------------------------------------------------------------------------------------------------------------------------

                  type:  numeric (int)

                 range:  [1,5]                        units:  1
         unique values:  5                        missing .:  5/74

            tabulation:  Freq.  Value
                             2  1
                             8  2
                            30  3
                            18  4
                            11  5
                             5  .

. browse if missing (rep78)
missing not found
r(111);

. browse if missing(rep78)

. list make if missing(rep78)

     +---------------+
     | make          |
     |---------------|
  3. | AMC Spirit    |
  7. | Buick Opel    |
 45. | Plym. Sapporo |
 51. | Pont. Phoenix |
 64. | Peugeot 604   |
     +---------------+

. summarize price, detail

                            Price
-------------------------------------------------------------
      Percentiles      Smallest
 1%         3291           3291
 5%         3748           3299
10%         3895           3667       Obs                  74
25%         4195           3748       Sum of Wgt.          74

50%       5006.5                      Mean           6165.257
                        Largest       Std. Dev.      2949.496
75%         6342          13466
90%        11385          13594       Variance        8699526
95%        13466          14500       Skewness       1.653434
99%        15906          15906       Kurtosis       4.819188

. browse if price > 13000

. tabulate  foreign

   Car type |      Freq.     Percent        Cum.
------------+-----------------------------------
   Domestic |         52       70.27       70.27
    Foreign |         22       29.73      100.00
------------+-----------------------------------
      Total |         74      100.00

. tabulate rep78

     Repair |
Record 1978 |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |          2        2.90        2.90
          2 |          8       11.59       14.49
          3 |         30       43.48       57.97
          4 |         18       26.09       84.06
          5 |         11       15.94      100.00
------------+-----------------------------------
      Total |         69      100.00

. tabulate rep78 foreign

    Repair |
    Record |       Car type
      1978 |  Domestic    Foreign |     Total
-----------+----------------------+----------
         1 |         2          0 |         2 
         2 |         8          0 |         8 
         3 |        27          3 |        30 
         4 |         9          9 |        18 
         5 |         2          9 |        11 
-----------+----------------------+----------
     Total |        48         21 |        69 


. by foreign sort: summarize mpg
variable sort not found
r(111);

. by foreign, sort: summarize mpg

-------------------------------------------------------------------------------------------------------------------------------------------------------
-> foreign = Domestic

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
         mpg |        52    19.82692    4.743297         12         34

-------------------------------------------------------------------------------------------------------------------------------------------------------
-> foreign = Foreign

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
         mpg |        22    24.77273    6.611187         14         41


. tabulate foreign, summarize (mpg)

            |      Summary of Mileage (mpg)
   Car type |        Mean   Std. Dev.       Freq.
------------+------------------------------------
   Domestic |   19.826923   4.7432972          52
    Foreign |   24.772727   6.6111869          22
------------+------------------------------------
      Total |   21.297297   5.7855032          74

. ttest mpg, by(foreign)

Two-sample t test with equal variances
------------------------------------------------------------------------------
   Group |     Obs        Mean    Std. Err.   Std. Dev.   [95% Conf. Interval]
---------+--------------------------------------------------------------------
Domestic |      52    19.82692     .657777    4.743297    18.50638    21.14747
 Foreign |      22    24.77273     1.40951    6.611187    21.84149    27.70396
---------+--------------------------------------------------------------------
combined |      74     21.2973    .6725511    5.785503     19.9569    22.63769
---------+--------------------------------------------------------------------
    diff |           -4.945804    1.362162               -7.661225   -2.230384
------------------------------------------------------------------------------
    diff = mean(Domestic) - mean(Foreign)                         t =  -3.6308
Ho: diff = 0                                     degrees of freedom =       72

    Ha: diff < 0                 Ha: diff != 0                 Ha: diff > 0
 Pr(T < t) = 0.0003         Pr(|T| > |t|) = 0.0005          Pr(T > t) = 0.9997

. correlate mpg weight
(obs=74)

             |      mpg   weight
-------------+------------------
         mpg |   1.0000
      weight |  -0.8072   1.0000


. by foreign, sort: correlate mpg weight

-------------------------------------------------------------------------------------------------------------------------------------------------------
-> foreign = Domestic
(obs=52)

             |      mpg   weight
-------------+------------------
         mpg |   1.0000
      weight |  -0.8759   1.0000


-------------------------------------------------------------------------------------------------------------------------------------------------------
-> foreign = Foreign
(obs=22)

             |      mpg   weight
-------------+------------------
         mpg |   1.0000
      weight |  -0.6829   1.0000



. scatter mpg weight

. twoway (scatter mpg weight)

. twoway (scatter mpg weight), by(foreign, total)

. regress mpg weight wtsq foreign
variable wtsq not found
r(111);

. gen wtsq =  weight* weight

. regress mpg weight wtsq foreign

      Source |       SS       df       MS              Number of obs =      74
-------------+------------------------------           F(  3,    70) =   52.25
       Model |  1689.15372     3   563.05124           Prob > F      =  0.0000
    Residual |   754.30574    70  10.7757963           R-squared     =  0.6913
-------------+------------------------------           Adj R-squared =  0.6781
       Total |  2443.45946    73  33.4720474           Root MSE      =  3.2827

------------------------------------------------------------------------------
         mpg |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      weight |  -.0165729   .0039692    -4.18   0.000    -.0244892   -.0086567
        wtsq |   1.59e-06   6.25e-07     2.55   0.013     3.45e-07    2.84e-06
     foreign |    -2.2035   1.059246    -2.08   0.041      -4.3161   -.0909002
       _cons |   56.53884   6.197383     9.12   0.000     44.17855    68.89913
------------------------------------------------------------------------------

. predict mpghat 
(option xb assumed; fitted values)

. twoway (scatter mpg weight) (line mpghat weight, sort), by(foreign)

. generate gpm = 1/mpg

. label variable gpm "Gallons per mile"

. twoway (scatter gpm weight), by (foreign, total)
) required
r(100);

. twoway (scatter gpm weight) , by (foreign, total)
) required
r(100);

. twoway (scatter gpm weight), by(foreign, total)

. regress gpm weight foreign

      Source |       SS       df       MS              Number of obs =      74
-------------+------------------------------           F(  2,    71) =  113.97
       Model |  .009117618     2  .004558809           Prob > F      =  0.0000
    Residual |   .00284001    71      .00004           R-squared     =  0.7625
-------------+------------------------------           Adj R-squared =  0.7558
       Total |  .011957628    73  .000163803           Root MSE      =  .00632

------------------------------------------------------------------------------
         gpm |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      weight |   .0000163   1.18e-06    13.74   0.000     .0000139    .0000186
     foreign |   .0062205   .0019974     3.11   0.003     .0022379    .0102032
       _cons |  -.0007348   .0040199    -0.18   0.855    -.0087504    .0072807
------------------------------------------------------------------------------

. 
