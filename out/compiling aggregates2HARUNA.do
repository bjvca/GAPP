
use C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC4.dta, clear
duplicates report  hh h4q1
sum
ed
collapse (sum)  h4q13f,by( hh)
la var  h4q13f "total education expense"
save C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\education_total.dta, replace


use C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC5.dta, clear
tab  h5q12
br  h5q12 h5q13
duplicates report  hh h5q1
collapse (sum)  h5q10  h5q13, by(hh)
egen medical=rowtotal( h5q10 h5q13)
drop  h5q10 h5q13
save C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\medical_cost.dta, replace


use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\ww-ug\UNHS 2009_10 DATASET\SOCIO\HSEC10D.dta", clear
br  h10dq3
codebook  h10dq3
br
tab  h10dq2
duplicates report  hh h10dq2
duplicates report  hh
collapse (sum) h10dq3,by (hh)
la var  h10dq3 "remittances and others"
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\remittance and other.dta", replace

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\ww-ug\UNHS 2009_10 DATASET\SOCIO\HSEC11.dta",clear
codebook  h11q2 h11q3 h11q4
tab h11q2
tab h11q2,nol
keep if  h11q2==11
tab  h11q2
ed
tab  h11q3
drop  h11q3
drop  h11q2
la var  h11q4 "imputed rent"
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\imputed rent.dta", replace

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\ww-ug\UNHS 2009_10 DATASET\SOCIO\HSEC10B_CLN.dta",clear
keep  h10bq2 h10bq5 h10bq7 h10bq9
use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\ww-ug\UNHS 2009_10 DATASET\SOCIO\HSEC10B_CLN.dta",clear
keep  h10bq2 h10bq5 h10bq7 h10bq9 hh
egen small_exp=rowtotal( h10bq5 h10bq7 h10bq9)
ed
ed
drop  h10bq5 h10bq7 h10bq9
collapse (sum)  small_exp, by(hh)
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\utilities_small_exp.dta", replace

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\ww-ug\UNHS 2009_10 DATASET\SOCIO\HSEC10C_CLN.dta", clear
egen durables=rowtotal ( h10cq3 h10cq4 h10cq5)
duplicates report  hh  durables
collapse (sum)   durables, by(hh)
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\durables.dta", replace


use C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\durables.dta,clear
destring  hh,force replace
save C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\durables.dta,replace

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\remittance and other.dta",clear
destring  hh,force replace
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\remittance and other.dta",replace





use C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\education_total.dta,clear
merge 1:1 hh using C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\medical_cost.dta
drop _merge
destring  hh,gen( hh1)
ed
format %14.0g hh1
drop hh
ren  hh1 hh

merge 1:1 hh using C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\utilities_small_exp.dta
drop _merge
merge 1:1 hh using C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\durables.dta
drop _merge
merge 1:1 hh using "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\remittance and other.dta"
drop _merge

save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\all_non_foodexpenses.dta", replace

summarize  h4q13f, d
gen educationd = (h4q13f/365)
summarize  educationd, d
gen remmitancesd = ( h10dq3/365)
summarize  remmitancesd
summarize  remmitancesd, d
gen medicald = (medical/30)
summarize  medicald, d
gen small_expd = (small_exp/30)
summarize  small_expd, d
gen durablesd = (durables/365)
gen durablesdd = (durables/365)*0.2
summarize  durablesd, d
la var  educationd "daily expenditure on school and education utilities"
la var  remmitancesd "daily expense on remmitances, imputed rent and others"
la var  medicald "daily expenditure on medical utilities including transport to hospitals"
la var  small_expd "small expenditures on utilities like tooth paste, electricity, water, tooth paste etc"
la var  durablesd "daily expense on semi durables and durables"
la var  durablesdd "daily expense on semi durables and durables"

keep  hh educationd remmitancesd medicald small_expd durablesd
sort hh
rename  hh hhid
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\all_non_food_dailyexpens.dta", replace




keep if inlist( product,401,421,422,423,424,425,426,427,428,429,430,431,441,442,443,444,445)


drop if inlist( product,401,421,422,423,424,425,426,427,428,429,430,431,441,442,443,444,445)


gen food_cat = 0
tab  food_cat
la var  food_cat "categorization whether food product or not, 1 for food, 0 otherwise"
gen product = 00
la var  product "product code"
egen tothhnnfdexp=rowtotal( educationd remmitancesd medicald small_expd durablesd)
la var  tothhnnfdexp "total daily household non food expenditure"
keep  hhid food_cat product tothhnnfdexp

save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\partial_table5.dta", replace

tab  food_cat
tab  product
replace  product=991
gen prod_cat=12
gen descript=""
replace  descript="non food"
gen valuez= tothhnnfdexp

save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\table 5_new.dta"
append using "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\cons_cod_trans2.dta"



use C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\cons_cod_trans.dta
summarize  valuez, d
tab  product
gen  valuez1= valuez*7
drop  valuez
ren  valuez1  valuez
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\cons_cod_trans1.dta"
drop if inrange( product,162,999)
drop if  product==155
drop if  product==156
tab  food_cat
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\cons_cod_trans2.dta"

replace  prod_cat=1 if  food_cat==1
tab  descript
tab  descript if   product==991
gen cod_hh_nom= valuez
gen cod_hh_nom2= cod_hh_nom if ~inlist( cod_hh_nom,0,.)
gen  cod_hh_nom3= cod_hh_nom if  food_cat==1
replace  cod_hh_nom3=0 if  cod_hh_nom3==.
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\cons_cod_final.dta"
