*global path "C:\user\gapp"
clear all
set mem 999m

cap log close
log using "$path\rep\150_price_unit_fix.log", replace
clear
set more off
#delimit ;



****************************************************************************************
* 150_price_unit_fix.do	(start)
*
* Purpose: This file calculates present unit prices for goods in the fixed food basket
*          from the previous survey (year = t-1)
*
* So this do file creates a price_unit_fix.dta database with the unit prices of the goods
* of the fixed food basket (from last survey) in order to determine the fixed poverty
* lines per domain (region). It uses the work\daily.dta and work\own.dta file and try
* to draw unit prices by: sum of values and sum of quantities
*
* Generate price_unit, dividing values by quantity in each region.
* But for some goods like cereals, meats, beans and other beans the unit price
* will be obtained by an average. For the other with unmatched codes we try to 
* use their respective product codes in daily.
****************************************************************************************;

/*
This file uses:
                work\daily.dta
                work\own.dta
                in\match_t1_t2.dta
                work\temp_index_reg_tpi.dta
                work\bottom_basket.dta

This file creates:
            work\match_t1_t2.dta
            work\price_unit.dta
*/



*global match_t1_t2 "$path\in\match_t1_t2.dta";

*global match_t1_t2 "$path\in\match96_02_iof.dta";
*global product        "codigo";
*global product_t1     "codigo96";


**************************************************************************************;
* Create sorted data set with daily and own and the matched codes;
**************************************************************************************;

use "$path/in/cons_cod_trans.dta", clear;

drop if quantityd==0 ;

drop value    valued;
drop quantity quantityd;

rename valuez    value;
rename quantityz quantity;

*drop count;

        sort hhid product;
        collapse quantity value, by (hhid product unit);
      sort product;
      gen count=1;


        tempfile dd_acsort;
        save    `dd_acsort', replace;

/*
use "$path\work\daily.dta";
        drop days ;
        sort product;
        tempfile dd_acsort;
save `dd_acsort', replace;

use "$path\work\own.dta";
      keep hhid product valued quantityd unit;
      rename valued value;
      rename quantityd quantity;

      * Drop if quantity info does not exist ;
      drop if quantity==0;

append using `dd_acsort';

        sort hhid product;
        collapse quantity value, by (hhid product unit);
      sort product;
      gen count=1;
save `dd_acsort', replace;
*/

************************************************************************************;
* Generate a shell temporary file called "build" to use later;
***********************************************************************************;

      tempfile build;
      drop if _N ~= _n;
      gen crap=1;
      keep crap;
save `build';


use "$path\in\match_t1_t2.dta", clear;
*rename $product   product;
*rename $product_t1 product_t1;
        drop if product==.;
        sort product;
save "$path\work\match_t1_t2.dta", replace; 

**************************************************************************************;
*Merge the matched codes with the dd  and own data set;
*This also drops all codes not a part of small basket
*Because some of the codes repeat, we do this in loop mode.
*The loop goes item by item in small basket and gets all of the observations
*from the dd and ac data sets that will form the basis for the average price
**************************************************************************************;

      local matchobs=_N; 
      forvalues x = 1/`matchobs' 
         { 		;
           use "$path\work\match_t1_t2.dta", clear;
           drop if _n ~= `x';
           sort product;
           merge product using `dd_acsort', nokeep;
           drop _merge;
           append using `build' ;
           save `build', replace;
         };

        drop if crap==1;
      drop crap;

**************************************************************************************;
* Drop all observations where no code, quantity, or value information is available
**************************************************************************************;
     drop if product==. | value==. | quantity==.  ;


**************************************************************************************
* Convert non-KG quantities (units and liters) into kilograms
**************************************************************************************;
*do "$path\new\110a_conversions.do"

********************************************************************
* There remain a few difficult to interpret observations such as liters
* of fish and liters of pasta. These are dropped ;
********************************************************************;
drop if unit~=2;

********************************************************************
* Merge in general info
********************************************************************;
     sort hhid;
     merge hhid using "$path\work\hhdata.dta";
     tab _merge;
     drop _merge;
     drop if product==.;
     
********************************************************************
* Merge in temporal price indices
********************************************************************;

* This is the eight commodity calculated index by reg_tpi;
      sort reg_tpi survquar;
      merge reg_tpi survquar using "$path\work\temp_index_reg_tpi.dta";
      tab _merge;
      drop _merge;

* Deflate temporally - this is the food basket so we deflate all values;
     gen value_r=value/tpi_trim;

     sort hhid product;
     tempfile ddacspdomain;
save `ddacspdomain', replace;

*Bring in the households on whom we want to perform the price calculations ;
use "$path\work\bottom_basket.dta", clear;
      drop if bottom_basket==0;
      keep hhid;
      sort hhid;
      tempfile pricehh;
save `pricehh';

*********************************************************************
* Note that we do prices in three ways. First, by summing quantity and value 
* This average price price_unitw is thus quantity/value weighted. Second, we
* calculate the price and take simple means for a transaction weighted
* price, price_unitt. Last we take the median, price_unitm. But in the end
* we only use price_unitw
*********************************************************************;

*********************************************************************;
* Work first on prices that are averages of year t2 (e.g. 2002) prices
* for example, cereals is a single commodity in year t1 (e.g. 1996)
* to develop a year t2 (e.g. 2002) price, we take a weighted average
* of cereals such as maize sorghum and millet
*********************************************************************;


* Comment out his section if avg==0 everywhere. E.g. in IOF 2008/09 ( START );
/*
use `ddacspdomain';

        merge hhid using `pricehh';
        tab _m;
      keep if _merge==3;
      drop _merge;

* NOTE: value_r has been temporally deflated.;
* It is not necessary to spatially deflate since we are working within each region;

        drop if avg==0;
        gen price_unitt=value_r/(quantity*1000);
        gen price_unitm=price_unitt;
        sort spdomain product product_t1;
        tempfile tmp1;
        save `tmp1';

                *trim the data to inner 90 percent ;
                 collapse (p05) price_unitt (p95) price_unitm [aw=hhweight*hhsize], by (spdomain product product_t1);
                rename price_unitt price_05;
                rename price_unitm price_95;
                sort spdomain product product_t1;
                tempfile tmp2;
		    save `tmp2';
	
	use `tmp1', clear;
      merge spdomain product product_t1 using `tmp2';
      tab _merge;

      drop _merge;
      drop if price_unitt < price_05;
      drop if price_unitt > price_95;
      
      *CA modified to boot sample weights bswt;

        collapse (sum) quantity value_r count bswt (mean) price_unitt (median) price_unitm [aw=hhweight] , by(spdomain product product_t1);
        *Generate price per gram ;
        gen price_unitw=value_r/(quantity*1000);

        collapse (max) count bswt (mean) price_unitt price_unitw price_unitm [aw=value_r], by(spdomain product_t1) ;

        tempfile prices_avg;
save `prices_avg', replace;

*/
* Comment out his section if avg==0 everywhere. E.g. in IOF 2008/09 ( END );

         

*********************************************************************
* Calculate the prices where codes match one to one
*********************************************************************;

use `ddacspdomain', clear;
        merge hhid using `pricehh';
        tab _m;
      keep if _merge==3;
      drop _merge;

      drop if avg==1;
      gen price_unitt=value_r/(quantity*1000);
      gen price_unitm=price_unitt;
      sort spdomain product_t1;
      *MAH;
      tempfile tmp1;
      save `tmp1', replace;

                *trim the data to inner 90 percent ;
                 collapse (p05) price_unitt (p95) price_unitm [aw=hhweight*hhsize], by (spdomain product_t1);
                rename price_unitt price_05;
                rename price_unitm price_95;
                sort spdomain product_t1;
            *MAH;
            tempfile tmp2;
      	    save `tmp2', replace;
      use `tmp1', clear;
      merge spdomain product_t1 using `tmp2';
      tab _merge;
      drop _merge;
      drop if price_unitt < price_05;
      drop if price_unitt > price_95;

*CA modified to boot sample weights bswt;

        collapse (sum) quantity value_r count bswt (mean) price_unitt (median) price_unitm [aw=hhweight], by(spdomain product_t1);
        *Generate weighted price per gram ;
        gen price_unitw=value_r/(quantity*1000);
      drop value_r quantity;
       

* Comment out his section if avg==0 everywhere. E.g. in IOF 2008/09 ( START );

*append using `prices_avg';

* Comment out his section if avg==0 everywhere. E.g. in IOF 2008/09 ( END );

      replace product_t1=substr(product_t1,1,7);
      destring product_t1, replace;

        sort spdomain product_t1;

save "$path\work\price_unit_fix.dta", replace;

        *get an idea of the difference between the price measures;
        gen ratiotw=price_unitt/price_unitw;
      gen ratiomw=price_unitm/price_unitw;

      sum ratiotw ratiomw;


****************************************************************************************
* 150_price_unit_fix.do	(end)
****************************************************************************************;

log close;
