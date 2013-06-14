*global path "C:\user\gapp"
clear all
set mem 999m

cap log close
log using "$path/rep/180_povline_food_fix.log" , replace
clear
set more off
#delimit ;



**************************************************************************
* 180_povline_food_fix.do		(start)
*
*This file generates prices from 1996 to be matched with 2002 quantities
* for the revealed preference constraints.
**************************************************************************;


/*
This file uses:
               in\rev_pref_matchcodes_t2-t1.dta 
		   in\povlines-96-v1-vers7.dta
               work\quan_flex_it$it_n.dta 
                
This file creates:
                work\96_02_povline.dta
		    work\rev_pref_matchcodes_t2-t1.dta
                work\rpref_t2_t1.dta
		    work\price_t1.inc
		    work\povline_t1_cc.inc
*/



*global rev_pref_matchcodes_t2_t1 "$path\in\rev_pref_matchcodes_02-96_iof.dta";

* Used in 180_povline_fix.do. Prices from past survey
*global povlines_t1_v1_vers7_new "$path\in\povlines-96-v1-vers7_iof.dta"

**************************************************************************;
*Obtain the file that matches codes for products consumed in 2002
*with codes for 1996
**************************************************************************;

use "$path\in\rev_pref_matchcodes_t2_t1.dta", clear ;
*rename $product   product  ;
*rename $product_t1 product_t1;

	*drop repeated codes (left over from matching 96 to 02);
	drop if delete==1;

	replace product_t1=substr(product_t1,1,7);
      destring product_t1, replace;

	keep product product_t1;
lab var product_t1 "Product code year t1 (e.g. 1996)";
lab var product    "Product code year t2 (e.g. 2002)";
	sort product;
save "$path\work\rev_pref_matchcodes_t2-t1.dta", replace ;
sum;





use "$path\in\povlines_t1.dta", clear ;
*	rename $product2 product_t1;

rename product product_t1;
rename price_uw5 mppg_ir;
rename $povline_f_flex tvrpdpc_r;
rename calpp calnecpp;



	sort product_t1;
      tempfile povlines_t1;
save `povlines_t1';





use "$path\work\rev_pref_matchcodes_t2-t1.dta", clear;
	*find codes that are not one to one matches;





	sort product_t1;
      gen count=1;
      collapse (sum) count (mean) product, by (product_t1);
      drop if product_t1==.;
	tempfile product_t1;
save `product_t1';


	*get the one to one set of codes;
      drop if count>1;
      display _N;
    
      merge product_t1 using `povlines_t1';
	tab _m;
	keep if _m==3;
      drop _m;
	tempfile rpref_t2_t1;
save `rpref_t2_t1';



*----------------------------------------------------------*
Do year t1 codes that match with more than one year t2 code
(start)
*----------------------------------------------------------*


/*
* Comment out this whole section if there are only 1-1 code matching. E.g. in IOF 2008/09 ( START );

use "$path\work\rev_pref_matchcodes_t2-t1.dta", clear;
      sort product_t1;
      display _N;
      merge product_t1 using `product_t1';
      keep if _m==3;
      keep if count>1;
      drop _m;
	local numobs=_N;
	tempfile multcod_t1;
save `multcod_t1';

	forval i=1/`numobs' {	;
		use `multcod_t1', clear;
            keep if _n==`i';
		sort product_t1;
            merge product_t1 using `povlines_t1';
            drop if _m<3;
            drop _m;
            append using `rpref_t2_t1';
            
		save `rpref_t2_t1', replace;

      };

* Comment out this whole section if there are only 1-1 code matching. E.g. in IOF 2008/09 ( END );
*/


*----------------------------------------------------------*
Do year t1 codes that match with more than one year t2 code
(end)
*----------------------------------------------------------*


            *rename reglnpob spdomain;
            sort spdomain product;
	      *keep only necessary observations;
		merge spdomain product using "$path\work\quan_flex_it$it_n.dta"; 
		drop if _m==1;
            drop _m;
            sort spdomain product;
*save "$path\work\rpref_t2_t1.dta", replace;

            replace mppg_ir=0 if mppg_ir==.;
            gen crap=1;
		lab def crap
         	1  ".";
 		lab val crap crap;

		gen reg=spdomain;

outsheet product crap reg mppg_ir using "$path\work\price_t1.inc", noname noquote replace ;

		sort reg;
            collapse (mean) tvrpdpc_r calnecpp, by(reg);
            *adjust line to hit a constant calorie target; 
		gen povline_t1_cc = tvrpdpc_r*2150/calnecpp;	      

* MAH ;
outsheet reg povline_t1_cc using "$path\work\povline_t1_cc.inc", replace noname;


**************************************************************************
* 180_povline_food_fix.do		(end)
**************************************************************************;

log close;
