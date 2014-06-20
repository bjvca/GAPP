clear all
*set mem 700m

clear
cap log close
log using "${path}/rep/250_Future_Revealed_Preference.log", replace
set more off
#delimit ;

***************************************************************************
* 250_Future_Revealed_Preference.do		(start)
*
* Creates data sets for future revealed preference tests and for a future fixed basked poverty line
* We export final food basket quantities (qent) and as many prices as possible for use in t+1 as well the final food share 
* We must use product codes for T

* Also, the file exports the Value share weighted mean prices as default. If another way to calculate prices are used,
* this needs to be changed under the export of price_unit_flex_it5 below.
****************************************************************************;


use "${path}/work/povlines.dta", clear ;
drop spi* ;
sort spdomain ;
save "${path}/out/t_plus1/povlines.dta", replace;

clear;

insheet spdomain product quan5 qent	price calperg using "${path}/work/qent.csv", comma;
drop quan5;
sort spdomain product;
save "$path/out/t_plus1/qent.dta", replace;



merge spdomain using "work/calpp.dta";
drop _merge;
sort spdomain;
merge spdomain using "$path/out/t_plus1/povlines.dta";
drop _merge;
gen val=qent*price;
gen f_share_fix=val/food_povline_ent;

bysort spdomain: egen tot=total(f_share_fix);
* These should be 90%;
tab tot;
drop tot;

rename  food_povline_ent povline_a_fix;

keep spdomain product f_share_fix price qent povline_a_fix calpp;

save "out/t_plus1/food_basket_fix.dta", replace;

use "out/t_plus1/food_basket_fix.dta", clear;

		sort spdomain;
            collapse (mean) povline_a_fix  calpp, by(spdomain);
            *adjust line to hit a constant calorie target; 
		gen povline_t1_cc = povline_a_fix*2150/calpp;	      

* MAH ;
outsheet spdomain povline_t1_cc using "${path}/out/t_plus1/povline_t1_cc.inc", replace noname;



use "${path}/work/price_unit_flex_it5.dta", clear ;
keep product spdomain count price_uw5  ;
order  product spdomain price_uw5 count ;
sort spdomain product ;
save "${path}/out/t_plus1/price_unit_flex_it5.dta", replace ;


use "$path/out/t_plus1/qent.dta", replace;
            sort spdomain product;
*save "$path/work/rpref_t2_t1.dta", replace;
		ren price mppg_ir;

            replace mppg_ir=0 if mppg_ir==.;
            gen crap=1;
		lab def crap
         	1  ".";
 		lab val crap crap;

		gen reg=spdomain;

outsheet product crap reg mppg_ir using "${path}/out/t_plus1/price_t1.inc", noname noquote replace ;








***************************************************************************
* 250_Future_Revealed_Preferences.do		(end)
****************************************************************************;

log close;
