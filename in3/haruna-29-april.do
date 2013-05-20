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
