clear
use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\out\cons_cod_trans_daily2.dta"
gen descript = product
rename product product2

rename descript product-
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
