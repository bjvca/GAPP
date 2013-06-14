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
**    NOTES: Food consumption values and quantities have been done on daily basis per household because it is the requirement
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
 
 if c(os)=="Unix" {
global path "/home/bjvca/data/data/GAP/Haruna"
}
else{
global path "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA"
}

 

use "$path/ww-ug/UNHS 2009_10 DATASET/SOCIO/HSEC10A_CLN.dta", clear
sort hh
rename hh hhid
la var hhid "household id"
** we drop alcoholic and tobacco as these were not considered basic in foods generally and by GAPP, these included beer-152, other alcoholic dricns-153
** cigarettes-155, other tobacco-156 and beer taken in restaurants-159
drop if inlist( itmcd ,152,153,155,156,159)
duplicates report  hh itmcd
duplicates list  hh itmcd
codebook hhid
egen quantity=rowtotal( h10aq4 h10aq6 h10aq8 h10aq10)
 
la var quantity "quantity of food consumed by the household including purchases, home, away from hm & kind"
gen quantityd = quantity/7
drop quantity h10aq10 h10aq8 h10aq6 h10aq4
la var quantityd "daily household food consumption"
egen value=rowtotal ( h10aq5 h10aq7 h10aq9 h10aq11 )
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


save "$path/out/household_table4.dta", replace
set more off
count
sort product untcd
merge m:1 product untcd using  "$path/in/conversionfactors.dta"
tab _m
drop _m
save "$path/out/household_table4cf.dta", replace
gen quantity = quantityz* cfactor
**************  ??? this i do not understand
************************************************************************************************************
*** valuez is multiplied by 1 because it had been erroneously multiplied by the unit conversion factors meant for only quantities
*********************************************************************************************
la var quantity "daily quantity consumed in Kgs per household"
la var value  "daily value of consumption in UGX per per household"

drop cfactor
sort hhid
label drop _all
destring hhid, replace

save "$path/out/cons_cod_trans.dta", replace
save "$path/in/cons_cod_trans.dta", replace
save "$path/work/cons_cod_trans.dta", replace
***************************************************************************************************
**    Standard table 4, cons_cod_trans.dta generated: AMOUNT AND QUANTITY OF FOOD TRANSACTION: TRANSACTION LEVEL
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
**  DATA OUT: cons_cod.dta
******************************************************************************************************************************************************
clear
use "$path/in/HSEC4.dta"

rename hh hhid
codebook hhid
keep hhid h4q13f
sort hhid
gen educationd = h4q13f/365
la var educationd "daily household expense on education"
drop h4q13f
save "$path/out/hhdeducationexp.dta", replace

use "$path/in/HSEC5.dta"

des
rename hh hhid
sort hhid
keep hhid h5q10 h5q13
egen medicalexp = rowtotal ( h5q10 h5q13)
gen medicalexpd = medicalexp/30
la var medicalexpd "household daily expenditure"
drop h5q10 h5q13 medicalexp
save "$path/out/hhdmedicalexp.dta", replace

clear
use "$path/in/HSEC8.dta"
des
save "$path/out/hhddurables.dta", replace
keep if inlist( h8q2 ,003,009,010,011,012)

*** h8q4 multiple has been removed because h8q5 was captured as total estimated value by UBOS 
gen assetvalue = h8q5

**************************************************************************************************************
** i took land, bicycle, motor cycle and boat as durables and assumed that a year, the household can use 10% of these assests
**********************************************************************************************************************
gen dassetvalue = (assetvalue*0.1)/365
la var dassetvalue "household daily durables expenditure"
rename hh hhid
sort hhid
save "$path/out/hhddurablesexp.dta", replace
clear

use "$path/in/HSEC8.dta"
save "$path/out/hhnondurables.dta", replace
rename hh hhid
drop if inlist( h8q2 ,001,002,003,009,010,011,012)
gen nondurablevalue = h8q5
**h8q4 multiple has been dropped since UBOS had recorded h8q5 as total estimated value in Ush and also discounted them by 10% to get rough value used per year
*** we considered other buildings-002, furniture-004, Hh appliances as Kettle,flat iron-005, electronics as tv,radio-006, generators-007, solar-panel-008
*** other transport equipment-013, jewelry&watches-014, mobilephone-015, otherassets as lawn mores-016, others -017 & 018. NOTE: figures are codes in data set
la var nondurablevalue "household daily non-durables expenditure"
sort hhid
gen dnondurables = (nondurablevalue*0.1)/365
la var dnondurables "household daily non-durables expenditure"
save "$path/out/hhdnondurablesexp.dta", replace
clear

use "$path/in/HSEC10B_CLN.dta"
des
rename hh hhid
sort hhid
** here we considered rent of rented house-301, imputed rent of own house-302, imputed rent of free given house-303, repair expenses-304, water-305 
** electricity-306, generator fuels-307, parafin-308, charcoal-309, firewood-310, matches-451, washing soap-452, bathing soap-453, toothpaste-454, 
** taxifares-463, and expenditure on phones not owned-468
** and we dropped others-311, cosmetics-455, handbags-456, batteries-drycells-457, newspapers-458, others-459, tires-461, petrol-462, 
*** bus fares-464, bodaboda fare-465, stamps/envelops-466, mobilephoneairtime-467 and others-469,health fees as consultation-501, medicine-502
*** hospitalcharges-503, traditionaldoctors-504, others-509 since medical expenses were cosidered in section 5, sports/theater-701,
**  drycleaning-702, houseboys-703, barbers&beauty shops-704 and lodging-705. THESE HAVE BEEN CONSIDERED NON BASIC

drop if inlist( h10bq2 ,311,455,456,457,458,459,461,462,464,465,466,467,469,501,502,503,504,509,701,702,703,704,705)
 
egen hhfrequents = rowtotal ( h10bq5 h10bq7 h10bq9)
gen dhhfrequents = hhfrequents/30
la var dhhfrequents "daily household expenditure on frequently bought commodities"
tostring hhid, replace
save "$path/out/hhdfrequentsexp.dta", replace

clear

*******************************************************************************************
**   in considering semi durable goods and services, the value of those services and goods recieved in kind, column 5 of HSEC10C_CLN.dta has been excluded
**   just as in kind food consumptions were eliminated in table 4 as per the GAPP guidelines, These have also been discounted by 10% usage per year
***************************************************************************************************************************************************

use "$path/in/HSEC10C_CLN.dta"
save "$path/out/hhsemidurables.dta", replace
des
sort hh
rename hh hhid
** we have considered the following men clothing-201, womenclothing-202, childrenclothing-203, men footware-221, women footware-222, children footware-223
** bedding mattress-404, blankets-405, charcoal/parafin stoves-422, plastic plates and tumblers-442
** and dropped other clothing-209, tailoring materials-210, other footware-229, furniture items-401, carpets-402, curtains&bedsheets-403, others-409
** kettles-421, tv&radio-423, byclcles-424, radio-425, motors-426, motorcycles-427,computers-428, phone handsets-429, others-430, jewelry&watches-431, 
** glass/table ware of codes 441-449, education cost (601-609) as education done in section 4, and others like functions & premiums (801-809)
** as these have been consideered NON BASIC
drop if inlist( h10cq2 ,209,210,229,401,402,403,409,421,423,424,425,426,427,428,429,430,431,441,443,444,445,449,601,602,603,604,609,801,802,803)
egen hhsemidurables = rowtotal ( h10cq3 h10cq4)
sort hhid
gen hhdsemidurs = (hhsemidurables*0.1)/365
la var hhdsemidurs "household daily semi durables goods and seervices expenses"
drop hhsemidurables
save "$path/out/hhdsemidurablesexp.dta", replace
clear

use "$path/in/HSEC10D.dta"
save "$path/in/hhnonconsmpexptaxes.dta", replace
sort hh
rename hh hhid
** we only considered local service tax-904, that may cause arrest if not paid and it used to be per head paid to local government annually
** and dropped income tax-901, property tax-902, user fees-903, social security payments-905, remmitances-906, funerals-907 and others-909
drop if inlist( h10dq2 ,901,902,903,905,906,907,909)
gen hhdnonconsumpexp = h10dq3/365
la var hhdnonconsumpexp "hh daily expenditure on taxes, contributions, donations, duties, etc"
sort hhid
save "$path/out/hhdnonconsumpexp.dta", replace
clear
******************************************************************************
** after generating all daily total household expenditures of various considered items, then we start merging these  seven hhd--- prefixed files, and ending with sufix exp to get all non food hh daily expenditure
**
**********************************************************************************************


use "$path/out/hhdeducationexp.dta", clear
collapse (sum) educationd , by(hhid)
sort hhid
save "$path/out/hhdeducationexp.dta", replace

use "$path/out/hhdmedicalexp.dta", clear
collapse (sum) medicalexpd , by(hhid)
sort hhid
save "$path/out/hhdmedicalexp.dta", replace

use "$path/out/hhdeducationexp.dta", clear
merge 1:1 hhid using "$path/out/hhdmedicalexp.dta"
drop _merge
sort hhid
save "$path/out/hhdeduc&medicex.dta", replace


use "$path/out/hhddurablesexp.dta"
collapse (sum) dassetvalue , by(hhid)
sort hhid
save "$path/out/hhddurablesexp.dta", replace

use "$path/out/hhdeduc&medicex.dta"
merge 1:1 hhid using "$path/out/hhddurablesexp.dta"
drop _merge
sort hhid
save "$path/out/hhdeduc&medic&durabex.dta", replace

use "$path/out/hhdnondurablesexp.dta"
collapse (sum) dnondurables , by(hhid)
sort hhid
save "$path/out/hhdnondurablesexp.dta", replace

use "$path/out/hhdeduc&medic&durabex.dta"
merge 1:1 hhid using "$path/out/hhdnondurablesexp.dta"
drop _merge
sort hhid
save "$path/out/hhdeduc&medic&durab&nondurabex.dta", replace



use "$path/out/hhdfrequentsexp.dta"
collapse (sum) dhhfrequents , by(hhid)
sort hhid
save "$path/out/hhdfrequentsexp.dta", replace

use "$path/out/hhdeduc&medic&durab&nondurabex.dta"
merge 1:1 hhid using "$path/out/hhdfrequentsexp.dta" 
drop _merge
sort hhid
save "$path/out/hhdeduc&medic&durab&nondurab&freqsex.dta", replace

use "$path/out/hhdsemidurablesexp.dta"
collapse (sum) hhdsemidurs , by(hhid)
sort hhid
save "$path/out/hhdsemidurablesexp.dta", replace

use "$path/out/hhdeduc&medic&durab&nondurab&freqsex.dta"
merge 1:1 hhid using "$path/out/hhdsemidurablesexp.dta"
drop _merge
replace hhdsemidurs=0 if hhdsemidurs==.
sort hhid
save "$path/out/hhdeduc&medic&durab&nondurab&freqs&semidurabex.dta", replace

use "$path/out/hhdnonconsumpexp.dta"
collapse (sum) hhdnonconsumpexp , by(hhid)
sort hhid
save "$path/out/hhdnonconsumpexp.dta", replace

use "$path/out/hhdeduc&medic&durab&nondurab&freqs&semidurabex.dta"
merge 1:1 hhid using "$path/out/hhdnonconsumpexp.dta"
drop _merge
replace hhdnonconsumpexp=0 if hhdnonconsumpexp==.
sort hhid
save "$path/out/hhdeduc&medic&durab&nondurab&freqs&semidurab&nonconsmpex.dta", replace

gen hhnonfoodexp =  educationd+medicalexpd+dassetvalue+dnondurables+dhhfrequents+hhdsemidurs+hhdnonconsumpexp
la var hhnonfoodexp "household total non food expenditure"
keep hhid hhnonfoodexp

****this is complete nonsense
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
save "$path/out/hhtotalnonfoodexp.dta", replace
label define descrip 2 " non food", add
label values descript descrip
label define descrip 1 " food", add
replace descript = 1 in 6
replace descript = 2 in 6
sort hhid
destring hhid, replace
save "$path/out/hhtotalnonfoodexp.dta", replace

use "$path/out/hhtotalnonfoodexp.dta"
append using  "$path/out/cons_cod_trans.dta"


rename quantityz quantityd
egen cod_hh_nom = rowtotal( hhnonfoodexp valuez)
la var cod_hh_nom "total household daily expenditure"
la var quantityd "housedhold daily quantity of food consumed in Kgs"
drop unit
drop hhnonfoodexp
sort hhid
replace product = 999 if product==2
la var product "product code is 999, if product is non food"
replace prod_cat = 1 if prod_cat==.
drop untcd
replace descript=1 if descript==.
label drop _all
save "$path/out/cons_cod.dta", replace
save "$path/work/cons_cod.dta", replace
save "$path/in/cons_cod.dta", replace

