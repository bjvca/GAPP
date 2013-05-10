
. clear

. set mem 100m
(102400k)

. use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\inddata_6_2009.dta", clear

. compress
motherhh was float now byte

. codebook hhid

------------------------------------------------------------------------------------------------------------------------------------------------
hhid                                                                                                                                Household ID
------------------------------------------------------------------------------------------------------------------------------------------------

                  type:  numeric (double)

                 range:  [1.013e+09,4.193e+09]        units:  1
         unique values:  6775                     missing .:  0/35945

                  mean:   2.6e+09
              std. dev:   1.1e+09

           percentiles:        10%       25%       50%       75%       90%
                           1.1e+09   2.0e+09   3.0e+09   3.2e+09   4.1e+09
