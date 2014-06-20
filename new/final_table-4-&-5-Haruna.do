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

drop if inlist( itmcd ,152,153, 155,156, 157, 158,159)
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

replace product=100 if product==101  | product==102  | product==103  | product==104

merge m:1 product untcd using  "/home/bjvca/data/data/GAP/Haruna/conversionfactors_corrected_onlyUNPS.dta"
tab _m
drop _m

save "$path/out/household_table4cf.dta", replace
gen quantity = quantityz * qkg_uca
**************  ??? this i do not understand
************************************************************************************************************
*** valuez is multiplied by 1 because it had been erroneously multiplied by the unit conversion factors meant for only quantities
*********************************************************************************************
la var quantity "daily quantity consumed in Kgs per household"
la var value  "daily value of consumption in UGX per per household"


sort hhid
label drop _all
destring hhid, replace

save "$path/out/cons_cod_trans.dta", replace
save "$path/in/cons_cod_trans.dta", replace
save "$path/work/cons_cod_trans.dta", replace
***************************************************************************************************
**    Standard table 4, cons_cod_trans.dta generated: AMOUNT AND QUANTITY OF FOOD TRANSACTION: TRANSACTION LEVEL
**
**   Generating Standard Table 5: TOTAL AMOUNT AND QUANTITY OF PRODUCTS: Food as well as non food
**
***********************************************************************************************
**  DATA IN:       hsec4.dta : On Education costs, column 13f which has all total school expenses, it is on 365 dayss basis
**                 hsec5.dta : On Medical Expenditure, column 10 and 11, on 30 days basis
**                 hsec12a.dta : On assets Expenditure, column h8q5 on total estimated present value, considering 10% value used per 365 days basis
**                 hsec14b.dta: On non-durables and frequently purchased items e.g imputed rent, electricity, soap etc, on 30 days basis, columns 5,7 & 9 for value
**                 hsec14c.dta: On semi-durable goods and services, column 3, 4 & 5, on 365 days basis for value
**                 hsec14d.dta:     On Non-consumption expenses like taxes, remitances away, subscriptions etc, on 365 days basis, colum 3
**
**  DATA OUT: cons_cod.dta
******************************************************************************************************************************************************
clear
use "$path/in/HSEC4.dta"
 
rename hh hhid
codebook hhid
keep hhid h4q13f
sort hhid
 ** since total education expenses were clooected in h4q10f and since is at yearly basis, we divided it by 365 to get daily expenses on education
gen educationd = h4q13f/365
*replace educationd=0
la var educationd "daily household expense on education"
drop h4q13f
save "$path/out/hhdeducationexp.dta", replace
 
use "$path/in/HSEC5.dta"
 
des
rename hh hhid
sort hhid
keep hhid h5q10 h5q11
egen medicalexp = rowtotal ( h5q10 h5q11)
gen medicalexpd = medicalexp/30
replace medicalexpd=0
la var medicalexpd "household daily expenditure"
drop h5q10 h5q11 medicalexp
save "$path/out/hhdmedicalexp.dta", replace
 

use "$path/in/HSEC8.dta"

save "$path/out/hhddurables.dta", replace
*keep if inlist( h8q2 ,010,011,012)
  drop if h8q2==3
  drop if h8q2==2
drop  if h8q2==1
gen assetvalue = h8q5/10
 
** **************************************************************************************************************
** ** i took land, bicycle, motor cycle and other transport equipment-012, that in 2009 were motor vehicles, as durables and assumed that a year, the household can use 1% of these assests. **there was no land in 2005 assets
 ** house not treated as an asset as the toolkit takes care of imputed rent
************************************************************************************************************************
 gen dassetvalue = (assetvalue*0.1)/365
replace dassetvalue=0
la var dassetvalue "household daily durables expenditure"
rename hh hhid
sort hhid
save "$path/out/hhddurablesexp.dta", replace




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


 
drop if inlist( h10bq2 ,502, 501, 462)
 
egen hhfrequents = rowtotal ( h10bq5 h10bq7 h10bq9)
gen dhhfrequents = hhfrequents/30
la var dhhfrequents "daily household expenditure on frequently bought commodities"


save "$path/out/hhdfrequentsexp.dta", replace

clear

*******************************************************************************************
**   in considering semi durable goods and services, the value of those services and goods recieved in kind, column 5 of hsec14c.dta has been excluded
**   just as in kind food consumptions were eliminated in table 4 as per the GAPP guidelines, These have also been discounted by 10% usage per year
***************************************************************************************************************************************************

use "$path/in/HSEC10C_CLN.dta"
save "$path/out/hhsemidurables.dta", replace
des
sort hh
rename hh hhid
egen hhsemidurables = rowtotal ( h10cq3 h10cq4 h10cq5)
sort hhid
gen hhdsemidurs = (hhsemidurables*0.5)/365
replace hhdsemidurs=0
la var hhdsemidurs "household daily semi durables goods and seervices expenses"
drop hhsemidurables
save "$path/out/hhdsemidurablesexp.dta", replace

clear

use "$path/in/HSEC10D.dta"
save "$path/in/hhnonconsmpexptaxes.dta", replace
sort hh
rename hh hhid

*drop if inlist( h10dq2 ,906)
gen hhdnonconsumpexp = h10dq3/365
*replace hhdnonconsumpexp = 0
la var hhdnonconsumpexp "hh daily expenditure on taxes, contributions, donations, duties, etc"
sort hhid
save "$path/out/hhdnonconsumpexp.dta", replace
clear

******************************************************************************
** after generating all daily non food total household expenditures of various considered items, then we start merging these  seven hhd--- prefixed files, and ending with sufix exp to get all non food hh daily expenditure
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


save "$path/out/hhdeduc&medic&durab&nondurabex.dta", replace



use "$path/out/hhdfrequentsexp.dta"
collapse (sum) dhhfrequents , by(hhid)
tostring hhid, replace

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
replace hhdnonconsumpexp=0 if hhdnonconsumpexp==.
sort hhid
save "$path/out/hhdnonconsumpexp.dta", replace

use "$path/out/hhdeduc&medic&durab&nondurab&freqs&semidurabex.dta"
merge 1:1 hhid using "$path/out/hhdnonconsumpexp.dta"
drop _merge
replace hhdnonconsumpexp=0 if hhdnonconsumpexp==.
sort hhid
save "$path/out/hhdeduc&medic&durab&nondurab&freqs&semidurab&nonconsmpex.dta", replace

gen hhnonfoodexp = educationd + medicalexpd+ dassetvalue + dhhfrequents +hhdsemidurs +hhdnonconsumpexp
la var hhnonfoodexp "household total non food expenditure"
*drop if hhnonfoodexp>45000 & hhnonfoodexp!=.
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
drop if product==139

replace descript=1 if descript==.
label drop _all
save "$path/out/cons_cod.dta", replace
save "$path/work/cons_cod.dta", replace
save "$path/in/cons_cod.dta", replace



