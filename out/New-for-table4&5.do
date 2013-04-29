*****************************************************************************************************************
**     PROGRAMME: PREPARARTION OF STANDARD TABLE 4: CONS_COD_TRANS
**     AUTHOR: HARUNA SEKABIRA
**     DATA IN: HSEC10A_CLN.dta
**              Coversionfactors.dta
**
**
**     DATA OUT: Cons_Cod_trans.dta
**
**
**
**    NOTES: Food consumption values and quantities have been excluded from the calculations of daily food consumption per household because it is the requirement
**            of GAPP. a few Food conversion factors that were not available from the statistics body for instance the kilograms in a crate of bear have been
**            calculated related on the available conversion factors for a bottle then counting how many bottles there are in a crate. Futher still some units
**            like heaps that were not available have been estimated using the town market experiences of these heaps in relation to related measurements 
**            given by UBOS
**
**
*************************************************************************************************************************************

clear
set logtype text
capture log close
set more off
 

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\ww-ug\UNHS 2009_10 DATASET\SOCIO\HSEC10A_CLN.dta", clear
sort hh
rename hh hhid
la var hhid "household id"
duplicates report  hh itmcd
duplicates list  hh itmcd
duplicates drop  hh itmcd, force
codebook hhid
egen quantity=rowtotal( h10aq4 h10aq6 h10aq8 )
 
la var quantity "quantity of food consumed by the household including purchases, home, away from hm & kind"
gen quantityd = quantity/7
drop quantity h10aq10 h10aq8 h10aq6 h10aq4
la var quantityd "daily household food consumption"
egen value=rowtotal ( h10aq5 h10aq7 h10aq9 )
la var value "household food consumption in seven days"
gen valuez = value/7
la var valuez "daily value of food consumed by the household"
rename quantityd quantityz
drop value h10aq11 h10aq11 h10aq9 h10aq7 h10aq5 h10aq13 h10aq12
gen unit = 1
la var unit "set equal to one since all observations are converted into kg"
gen food_cat = 1
la var food_cat "food category equals 1, if product is food and 0 if non food"
des itm
des hhid
des food_cat
des valuez
rename itmcd product
format %10.0g product
format %9.0g hhid
format %10.0g unit
la var product "Food product code: numerical"
*******************************************************************************
*** to avoid zero quantities during multiples and or divisions, because certains foods like other juice, other foods and foods from restaurants
**** did not have quantities, we replaced the zero with one. However ahead, in calculating unit prices in table five where foods whose 
**** quantities are missing thus not included for unit price calculations, even foodsof product codes 157, 160 and 161, must not be included
*******************************************************
replace quantityz=1 if (product==157 | product==160 | product==161)
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\household_table4.dta", replace
set more off
count
sort product untcd
merge m:1 product untcd using  "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\conversionfactors.dta"
tab _m
drop _m
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\household_table4cf.dta", replace
gen quantity = quantityz* cfactor
gen value = valuez* 1
************************************************************************************************************
*** valuez is multiplied by 1 because it had been erroneously multiplied by the unit conversion factors meant for only quantities
*********************************************************************************************
la var quantity "daily quantity consumed in Kgs per household"
la var value  "daily value of consumption in UGX per per household"
drop quantityz valuez
rename quantity quantityz
rename value valuez
drop cfactor
sort hhid
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\cons_cod_trans.dta", replace

***************************************************************************************************
**    Standard table 4, cons_cod_trans generated: AMOUNT AND QUANTITY OF FOOD TRANSACTION: TRANSACTION LEVEL
**
*********************************************************************************************
**   Generating Standard Table 5: TOTAL AMOUNT AND QUANTITY OF PRODUCTS: Food as well as non food
**
***********************************************************************************************
**  DATA IN:       HSEC4.dta : On Education costs, column 13f which has all total school expenses, it is on 365 dayss basis
**                 HSEC5.dta : On Medical Expenditure, column 10 and 13, on 30 days basis
**                 HSEC8.dta : On assets Expenditure, column h8q4 on numbers and h8q5 on value, considering 20% value used per 365 days basis
**                 HSEC10B_CLN.dta: On non-durables and frequently purchased items e.g imputed rent, electricity, soap etc, on 30 days basis, columns 5,7 & 9 for value
**                 HSEC10C_CLN.dta: On semi-durable goods and services, column 3, 4 & 5, on 365 days basis for value
**                 HSEC10D.dta:     On Non-consumption expenses like taxes, remitances away, subscriptions etc, on 365 days basis, colum 3
**
**
******************************************************************************************************************************************************88
clear
use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC4.dta"

rename hh hhid
codebook hhid
keep hhid h4q13f
sort hhid
gen educationd = h4q13f/365
la var educationd "daily household expense on education"
drop h4q13f
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdeducationexp.dta", replace

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC5.dta"

des
rename hh hhid
sort hhid
keep hhid h5q10 h5q13
egen medicalexp = rowtotal ( h5q10 h5q13)
gen medicalexpd = medicalexp/30
la var medicalexpd "household daily expenditure"
drop h5q10 h5q13 medicalexp
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdmedicalexp.dta", replace

clear
use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC8.dta"
des
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhddurables.dta", replace
keep if inlist( h8q2 ,003,009,010,011,012)
gen assetvalue = h8q4* h8q5

**************************************************************************************************************
** i took land, bicycle, motor cycle and boat as durables and assumed that a year, the household can use 20% of these assests
**********************************************************************************************************************
gen dassetvalue = (assetvalue*0.2)/365
la var dassetvalue "household daily durables expenditure"
rename hh hhid
sort hhid
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhddurablesexp.dta", replace
clear

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC8.dta"
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhnondurables.dta", replace
rename hh hhid
drop if inlist( h8q2 ,003,009,010,011,012)
gen nondurablevalue = h8q4* h8q5
la var nondurablevalue "household daily non-durables expenditure"
sort hhid
gen dnondurables = nondurablevalue/365
la var dnondurables "household daily non-durables expenditure"
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdnondurablesexp.dta", replace
clear

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC10B_CLN.dta"
des
rename hh hhid
sort hhid
egen hhfrequents = rowtotal ( h10bq5 h10bq7 h10bq9)
gen dhhfrequents = hhfrequents/30
la var dhhfrequents "daily household expenditure on frequently bought commodities"
tostring hhid, replace
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdfrequentsexp.dta", replace

clear

*******************************************************************************************
**   in considering semi durable goods and services, the value of those services and goods recieved in kind, column 5 of HSEC10C_CLN.dta has been excluded
**   just as in kind food consumptions were eliminated in table 4 as per the GAPP guidelines
***************************************************************************************************************************************************

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC10C_CLN.dta"
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhsemidurables.dta", replace
des
sort hh
rename hh hhid
egen hhsemidurables = rowtotal ( h10cq3 h10cq4)
sort hhid
gen hhdsemidurs = hhsemidurables/365
la var hhdsemidurs "household daily semi durables goods and seervices expenses"
drop hhsemidurables
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdsemidurablesexp.dta", replace
clear

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC10D.dta"
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\hhnonconsmpexptaxes.dta", replace
sort hh
rename hh hhid
gen hhdnonconsumpexp = h10dq3/365
la var hhdnonconsumpexp "hh daily expenditure on taxes, contributions, donations, duties, etc"
sort hhid
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdnonconsumpexp.dta", replace
clear
******************************************************************************
** after generating all daily total household expenditures of various considered items, then we start merging these  seven hhd--- prefixed files, and ending with sufix exp to get all non food hh daily expenditure
**
**********************************************************************************************





