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
collapse (sum) quantityz valuez, by (hhid)
sort hhid
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\table4_with_consumption_per_household.dta", replace
merge m:1 hhid using "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdata_gen_hhsize.dta"
tab _m
drop _m
gen quantity = quantityz/1
la var quantity "daily quantity consumed in kgs per person"
gen value = valuez/1
*********************************************************************************************************
*** valuez and quantityz are divided by one because had been erroneously divided by hhzize yet the GAPP toolkit takes care of this
***************************************************************************************************************
la var value "daily value of consumption in UGX per person"
drop quantityz valuez
rename quantity quantityz
rename value valuez
gen food_cat = 1
la var food_cat "food product or not, if food coded 1 and if non food 0"
gen unit = 1
la var unit "set to 1 since all values are in kgs"
drop hhsize
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\full_table4.dta", replace
gen product = 1
la var product "product code, since were many per hh, these have been coded 1 for foods and 0 for non foods"
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
collapse (sum) h4q13f , by (hhid)
sort hhid
gen educationd = h4q13f/365
la var educationd "dail household expense on education"
drop h4q13f
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdeducationexp.dta", replace
clear
use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC5.dta"

des
rename hh hhid
sort hhid
keep hhid h5q10 h5q13
egen medicalexp = rowtotal ( h5q10 h5q13)
gen medicalexpd = medicalexp/30
la var medicalexpd "household daily expenditure"
drop h5q10 h5q13 medicalexp
collapse (sum) medicalexpd , by (hhid)
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
collapse (sum) dassetvalue , by (hhid)
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
collapse (sum) dnondurables, by (hhid)
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdnondurablesexp.dta", replace
clear

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC10B_CLN.dta"
des
rename hh hhid
sort hhid
egen hhfrequents = rowtotal ( h10bq5 h10bq7 h10bq9)
gen dhhfrequents = hhfrequents/30
la var dhhfrequents "daily household expenditure on frequently bought commodities"
collapse (sum) dhhfrequents, by (hhid)
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
collapse (sum) hhsemidurables, by (hhid)
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
collapse (sum) hhdnonconsumpexp, by (hhid)
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdnonconsumpexp.dta", replace
clear

******************************************************************************
** after generating all daily total household expenditures of various considered items, then we start merging these  seven hhd--- prefixed files, and ending with sufix exp to get all non food hh daily expenditure
**
**********************************************************************************************

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdeducationexp.dta"
merge m:1 hhid using "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdmedicalexp.dta"
tab _m
drop _m
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdeduc&medicex.dta", replace
clear

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdeduc&medicex.dta"
merge m:1 hhid using "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhddurablesexp.dta"
tab _m
drop _m
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdeduc&medic&durabex.dta", replace
merge m:1 hhid using "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdnondurablesexp.dta"
tab _m
drop _m
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdeduc&medic&durab&nondurabex.dta", replace

clear

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdeduc&medic&durab&nondurabex.dta"
merge m:1 hhid using "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdfrequentsexp.dta"
tab _m
drop _m
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdeduc&medic&durab&nondurab&freqsex.dta", replace

merge m:1 hhid using "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdsemidurablesexp.dta"
tab _m
drop _m
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdeduc&medic&durab&nondurab&freqs&semidurabex.dta", replace
merge m:1 hhid using "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdnonconsumpexp.dta"
tab _m
drop _m
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdeduc&medic&durab&nondurab&freqs&semidurab&nonconsmpex.dta", replace

egen hhnonfoodexp = rowtotal ( educationd medicalexpd dassetvalue dnondurables dhhfrequents hhdsemidurs hhdnonconsumpexp)
la var hhnonfoodexp "household total non food expenditure"
keep hhid hhnonfoodexp
gen product = 0
la var product "product code equal to 1 for food and 0 for non food"
gen food_cat = 0
la var food_cat "food product or not equals 1 for foods and 0 for non foods"
gen prod_cat = 2
la var prod_cat "COICOP product categories, 2 for all non food"
replace product = 2 if product==0
replace food_cat = 2 if food_cat==0
gen descript = 2
la var descript "product description including product code but equals 2 for all non-foods"
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhtotalnonfoodexp.dta", replace
label define descrip 2 " non food", add
label values descript descrip
label define descrip 1 " food", add
replace descript = 1 in 6
replace descript = 2 in 6
sort hhid
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhtotalnonfoodexp.dta", replace


merge m:1 hhid using  "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\cons_cod_trans2_4merge.dta"
tab _m
drop _m

rename quantityz quantityd
egen cod_hh_nom = rowtotal ( hhnonfoodexp valuez)
la var cod_hh_nom "total household daily expenditure"
gen cod_hh_nom2 = cod_hh_nom
la var cod_hh_nom2 "total household expenditure where quantity
gen cod_hh_nom3= cod_hh_nom if ~inlist( cod_hh_nom,0,.)
drop cod_hh_nom2
rename cod_hh_nom3 cod_hh_nom2
la var cod_hh_nom2 "total hh expenditure only when quantity is reported, observations without quantity set missing"
rename valuez cod_hh_nom3
la var cod_hh_nom2 "total household daily expenditure only when quantity is reported without quantity set to missing"
la var cod_hh_nom3 "total household daily food expenditure, excluding receipts in kind"
la var quantityd "housedhold daily quantity of food consumed in Kgs"
drop unit
drop hhnonfoodexp
sort hhid

save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\cons_cod.dta", replace

*********************************************************************************************************
*** I realised that the generated cons_cod.dta, had only food_cat lables for the noon-food, after the collapsing had already been done to the hhid, however
*** the toolkit takes care of these collapsing. so I used the old file having all food categories called cons_cod14merge.dta, and merged it with a renamed conss_cod
***  called, cons_cod24merge.dta, to genrated new cons_cod.
******** Unfortunately this trick also fails because I had just merged the files and not appended them, thus losing codes. Hense I resort to the phenomenon below
******************************************************************************************************************
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
la var quantity "daily quantity consumed in Kgs per person"
la var value  "daily value of consumption in UGX per person"
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
**   DATA OUT: cons_cod.dta
******************************************************************************************************************************************************88
clear

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC4.dta"

rename hh hhid
codebook hhid
keep hhid h4q13f
sort hhid
gen educationd = h4q13f/365
la var educationd "dail household expense on education"
drop h4q13f
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdeducationexp_daily.dta", replace


use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC5.dta"

des
rename hh hhid
sort hhid
keep hhid h5q10 h5q13
egen medicalexp = rowtotal ( h5q10 h5q13)
gen medicalexpd = medicalexp/30
la var medicalexpd "household daily expenditure"
drop h5q10 h5q13 medicalexp
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdmedicalexp_daily.dta", replace
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
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhddurablesexp_daily.dta", replace

clear

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC8.dta"
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhnondurables_daily.dta", replace
rename hh hhid
drop if inlist( h8q2 ,003,009,010,011,012)
gen nondurablevalue = h8q4* h8q5
la var nondurablevalue "household daily non-durables expenditure"
sort hhid
gen dnondurables = nondurablevalue/365
la var dnondurables "household daily non-durables expenditure"
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdnondurablesexp_daily.dta", replace
clear

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC10B_CLN.dta"
des
rename hh hhid
sort hhid
egen hhfrequents = rowtotal ( h10bq5 h10bq7 h10bq9)
gen dhhfrequents = hhfrequents/30
la var dhhfrequents "daily household expenditure on frequently bought commodities"
tostring hhid, replace
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdfrequentsexp_daily.dta", replace

clear
*******************************************************************************************
**   in considering semi durable goods and services, the value of those services and goods recieved in kind, column 5 of HSEC10C_CLN.dta has been excluded
**   just as in kind food consumptions were eliminated in table 4 as per the GAPP guidelines
***************************************************************************************************************************************************

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC10C_CLN.dta"
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhsemidurables_daily.dta", replace
des
sort hh
rename hh hhid
egen hhsemidurables = rowtotal ( h10cq3 h10cq4)
sort hhid
gen hhdsemidurs = hhsemidurables/365
la var hhdsemidurs "household daily semi durables goods and seervices expenses"
drop hhsemidurables
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdsemidurablesexp_daily.dta", replace
clear

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC10D.dta"
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\hhnonconsmpexptaxes_daily.dta", replace
sort hh
rename hh hhid
gen hhdnonconsumpexp = h10dq3/365
la var hhdnonconsumpexp "hh daily expenditure on taxes, contributions, donations, duties, etc"
sort hhid
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdnonconsumpexp_daily.dta", replace

clear

******************************************************************************
** after generating all daily total household expenditures of various considered items, then we start merging these  seven hhd--- prefixed files, and ending with sufix exp to get all non food hh daily expenditure
**
**********************************************************************************************
use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\hhdeduc&medic&durab&nondurab&freqs&semidurab&nonconsmpex.dta"
gen product = 991
la var product "product numerical code is 991 for all non foods"
gen descript = 999
la var descript "product description equals 999 for all non foods"
gen food_cat = 2
la var food_cat "food product code equals 2 for all non foods"
gen prod_cat = 12
la var prod_cat "COICOP product categories equals 12 for all non foods"
destring hhid, replace
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\allnon_food_expenses_daily.dta", replace
clear
use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\cons_cod_trans_daily.dta"
merge m:1 hhid using "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\allnon_food_expenses_daily.dta"

tab _m
drop _m
rename quantityz quantityd
rename valuez cod_hh_nom
rename cod_hh_nom cod_hh_nom3
la var cod_hh_nom3 "total daily household food expenditure"
egen cod_hh_nom = rowtotal ( cod_hh_nom3 educationd medicalexpd dassetvalue dnondurables dhhfrequents hhdsemidurs hhdnonconsumpexp)
la var cod_hh_nom "total household expenditure on given product"
gen cod_hh_nom2= cod_hh_nom if ~inlist( quantityd ,0,.)
la var cod_hh_nom2 "total houhehold daily expenditure, only when quantity is reported"
drop untcd unit educationd medicalexpd dassetvalue dnondurables dhhfrequents hhdsemidurs hhdnonconsumpexp

replace prod_cat = 1  if prod_cat==12

*******************************************************************************************
** because i realised that all prod_cat were showing 12, when browsed after running the "boom, GAPP toolkit" I realised that instead coded for non food
**  had not showed up though the values were there and all descriptions were for food, thus i decided to replace all these with a food cod, 1
*************************************************************************

save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\cons_cod.dta", replace

**************************************************************************************
***
*** I go back and forth, renaming files with different names but same data to find out
***  what works best. on combining several trials i generate cons_cod_trans.dta and 
***  cons_cod.dta as below, using the files above and using the appending technique
***  to maintain all products. You will see that some commands are repeatedly used
************************************************************************************
clear
use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\cons_cod_trans_daily2.dta"
gen descript = product
rename product product2

rename descript product
rename product2 descript
la var product "food product code; numerical"
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\cons_cod_trans.dta", replace
clear
use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\allnon_food_expenses_daily.dta"
append using "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\cons_cod_trans.dta"
replace  prod_cat =1 if  prod_cat ==.
rename quantityz quantityd
rename valuez cod_hh_nom
rename cod_hh_nom cod_hh_nom3
la var cod_hh_nom3 "total daily household food expenditure"
egen cod_hh_nom = rowtotal ( cod_hh_nom3 educationd medicalexpd dassetvalue dnondurables dhhfrequents hhdsemidurs hhdnonconsumpexp)
la var cod_hh_nom "total household expenditure on given product"
gen cod_hh_nom2= cod_hh_nom if ~inlist( quantityd ,0,.)
la var cod_hh_nom2 "total houhehold daily expenditure, only when quantity is reported"
drop untcd unit educationd medicalexpd dassetvalue dnondurables dhhfrequents hhdsemidurs hhdnonconsumpexp
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\cons_cod.dta", replace






