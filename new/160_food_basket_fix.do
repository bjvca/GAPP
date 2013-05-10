*global path "C:\user\gapp"
clear all
set mem 999m

cap log close
log using "$path\rep\160_food_basket_fix.log", replace
clear
set more off
#delimit ;

*************************************************************************************
* 160_food_basket_fix.do	(start)
*
*This file calculates the food poverty line using the food_basket_fix from 1996-97
*It takes as inputs prices from work\price_unit_fix.dta and quantities from 
*work\food_basket_fix.dta. Note that, for some goods in small basket, there were 
*insufficient observations to generate price info
*************************************************************************************;


*global food_basket_fix "smallbasket_iof.dta";
*global povline_f_fix  "povline_a_fix";


* Changes made for bootstap. Rather than read food_basket_fix.dta from work we read from in ;

/*
This file uses:
        in\food_basket_fix.dta
        work\calpp.dta
        work\price_unit.dta

This file creates:
        work\food_basket_fix_t2.dta
        work\price_unitw.inc
        work\tgrpdpc_ir.inc
        work\share_t1c.inc
        work\povline_food.dta
        work\povline_food_fix.inc
*/
        

use spdomain product f_share_fix price qent povline_a_fix calpp
using "$path\in/food_basket_fix.dta", clear;

* Product code in previous survey (PS);
rename product    product_t1;

* Food share in PS;
rename f_share_fix share_t1;

* Price per gram in PS;
rename price  mppg_ir;

* Grams of product in food basket in PS;
rename qent      tgrpdpc_ir;

* Amount spend on food item (national currency) in PS;
rename $povline_f_fix tvrpdpc_r;

* Total calories per person in PS, by region;
rename calpp      calnecpp;

        sort spdomain;

        * Merge in year t2 (e.g. 2002) values for calories needed and adjust bundle;
		* such that the year t1 (e.g. 1996) basket attains year t2 (e.g. 2002) calorie needs;
        merge spdomain using "$path\work\calpp.dta";
      tab _merge;
      drop _merge;
        * Calories requirement in year t2 (e.g. 2002) divided by calories requirement in year t1 (e.g. 1996) ;
        gen calrat=calpp/calnecpp;
      * (Fixed!) Quantity in t2 = Quantity in t1 * (1+ rise/fall in calories requirement from t1 to t2) ;
      gen tgrpdpc_t2=tgrpdpc_ir*calrat;

*MAH;
sum;
        * merge in year t2 prices and calculate food poverty lines;
      sort spdomain product_t1;
      merge spdomain product_t1 using "$path\work\price_unit_fix.dta";
      tab _merge;


      keep if _merge==3;

        *drop basket items with averages based on less than five observations;
      *CA modified to handle bootstrap sample weights;
      drop if bswt==.;
      drop if round(bswt)<=5;


      *drop tea due to absurd results ;
       drop if product_t1==1111100;
	*MAH. Tea in IOF 2008/09;
	drop if product_t1==12120;

      sort spdomain share_t1;

        *calculate basket values ;
	* tgrpdpc_t2 : Calories adjusted quantities from 1996 ;
	* value_t2_<i>: value of 1996 fixed bundle in 2002 prices ;
      gen value_t2_t=price_unitt*tgrpdpc_t2;
      gen value_t2_w=price_unitw*tgrpdpc_t2;
      gen value_t2_m=price_unitm*tgrpdpc_t2;

	* Poverty lines calculated (almost - an adjustment below) ;
      by spdomain: egen food_povline_t= sum(value_t2_t);
      by spdomain: egen food_povline_w_fix= sum(value_t2_w);
      by spdomain: egen food_povline_m= sum(value_t2_m);

      *note: inflation for items dropped comes later.;

      *calculate cost shares for year t1 fixed basket ;
      gen share02_t=value_t2_t/food_povline_t;
      gen share02_w=value_t2_w/food_povline_w;
      gen share02_m=value_t2_m/food_povline_m;

      *calculate various shares;
      by spdomain: gen  cumshr_t1_r = sum(share_t1);
      by spdomain: egen sumshr_t1_r = sum(share_t1);
      by spdomain: gen  share_t1c   = share_t1/sumshr_t1_r;
      by spdomain: egen sumshr_t1_c = sum(share_t1c);
	  
      *this should be very close to 1;
      by spdomain: sum sumshr_t1_c;
        
      *calculate price indices to examine extent of relative price variation ;
      by spdomain: gen  ind_t1_i    = share_t1c*mppg_ir;
      by spdomain: egen ind_t1      = sum(ind_t1_i); 
      by spdomain: gen  ind_t2_i    = share_t1c*price_unitm;
      by spdomain: egen ind_t2      = sum(ind_t2_i);
      by spdomain: gen  preal_um    = price_unitm/(ind_t2/ind_t1);
      by spdomain: gen  prat_t2_t1m = preal_um/mppg_ir;
      by spdomain: gen  preal_uw    = price_unitw/(ind_t2/ind_t1);
      by spdomain: gen  prat_t2_t1w = preal_uw/mppg_ir;

      *get an indicator of relative price change by region ;
      by spdomain: gen pchng_w = abs(prat_t2_t1w-1)*share_t1c;
      by spdomain: gen pchng_a = abs(prat_t2_t1w-1);
      by spdomain: gen pchng_s = abs(prat_t2_t1w-1);
      gen numobs=1;
      drop _merge;


save "$path\work\food_basket_fix_t2.dta", replace;        

        gen cod_t1 = product_t1;
 
        *output files that GAMS can read for Cobb-Douglas preference analysis;
        gen reg=spdomain ;
          gen crap=1;
           lab def crap
         1  ".";
          lab val crap crap;

* price_unitw: weighted unit price year t2 ;
          outsheet reg crap cod_t1 price_unitw using "$path/work/price_unitw.inc", noquote noname replace  ;
* tgrpdpc_ir: Quantity in year t1 ;
          outsheet reg crap cod_t1 tgrpdpc_ir using "$path/work/tgrpdpc_ir.inc", noquote noname replace  ;
* share_t1c: corrected expenditure share - correction in the sense that total share equals 1 after excluding some products ;
          outsheet reg crap cod_t1 share_t1c using "$path/work/share_t1c.inc", noquote noname replace  ;
          

      collapse (mean) tvrpdpc_r food_povline_t food_povline_w food_povline_m pchng_a (sum) pchng_w pchng_s numobs share_t1, by(spdomain);
      replace food_povline_t=food_povline_t/share_t1;
      replace food_povline_w_fix=food_povline_w/share_t1;
      replace food_povline_m=food_povline_m/share_t1;

save "$path\work\povline_food_fix.dta", replace;

*output food poverty line for later use by GAMS;
        gen reg=spdomain;

* MAH ;
outsheet reg food_povline_w_fix using "$path\work\povline_food_fix.inc" , replace noname noquote; 

      gen ratio_m=food_povline_m/tvrpdpc_r;
      gen ratio_w=food_povline_w_fix/tvrpdpc_r;


*************************************************************************************
* 160_food_basket_fix.do	(end)
*************************************************************************************

log close;
