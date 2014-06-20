*global path "C:/user/gapp"
clear all
set mem 999m

cap log close
log using "$path/rep/110_price_unit_flex.log", replace
clear
set more off
#delimit ;



****************************************************************************************
* 110_price_unit_flex.do		(start)
*
* Purpose: This do file creates a price_unit_flex database with the unit prices of the
* goods of the flexible food basket in order to determine the poverty lines per spatial
* domain. It uses the files work/daily.dta and work/own.dta file and draw unit prices
* by: sum of values and quantity
****************************************************************************************;
*CA modified to bring in work/hhdata.dta for bootstrap
*CA check for price calcs conditional on number of observations;

/*
This file uses:
        work/daily.dta
        work/own.dta
        work/hhdata.dta
        work/consump_nom.dta
        work/codes_food_basket_flex.dta
        work/temp_index_reg_tpi.dta
          new/conversions.do

This file creates:
        work/price_unit_flex.dta
        work/bottom_basket.dta
*/




*do "$path/new/010_initial.do";



**************************************************************************************
* Create sorted data set with daily and own and the matched codes
**************************************************************************************;
use "$path/work/cons_cod_trans.dta", clear;
drop if quantity >30000;
*use "$path/in/cons_cod_trans.dta", clear;
*save "$path/work/cons_cod_trans.dta", replace;

*drop if quantityd==0 ;

keep hhid product food_cat valuez quantity unit;

rename valuez    value;
*rename quantityz quantity;

drop if quantity==0 ;

*drop count;

        sort product;
        gen count=1;
		


tempfile dd_acsort;
save `dd_acsort', replace;

/*
use "$path/work/daily.dta";
tempfile dd_acsort;
        drop days;
        sort product;
        tempfile dd_acsort;
save `dd_acsort', replace;

use "$path/work/own.dta";
        keep hhid product valued quantityd unit;
        rename valued value;
        rename quantityd quantity;

        *CHECK THE ZEROS IN quantity FOR NOW DELETE;
        drop if quantity==0;

        append using `dd_acsort';

*CA modified to merge in work/hhdata.dta for bootstrap;
	sort hhid;
      merge hhid using "$path/work/hhdata.dta";
      tab _m;

* Drop observations if non existent in HH data set;
drop if _m!=3;
drop _m;


        sort product;
        gen count=1;


save `dd_acsort', replace;
*/


**************************************************************************************;
* Merge the flexible food basket codes with the daily and own data sets
* Drop all codes not a part of the flexible food basket
**************************************************************************************;
        merge product using "$path/work/codes_food_basket_flex.dta";

        tab _merge;
        drop if _merge~=3;
        drop _merge;

**************************************************************************************;
* Drop observations where product code or quantity or value information is unavailable
**************************************************************************************;
				codebook hhid;
*        drop if product==. | value==. | quantity==.  ;
				codebook hhid;

**************************************************************************************;
* Convert non-KG quantities (units and liters) to kilograms;
**************************************************************************************;
*do "$path/new/110a_conversions.do"

********************************************************************
* There remain a few difficult to interpret observations such as liters
* of fish and liters of pasta. These are dropped
********************************************************************;
*        drop if unit~=2;

********************************************************************
* Merge in labels for the 13 spatial domains
********************************************************************;
        preserve;
                use "$path/work/hhdata.dta", clear;
                                                
                        keep hhid spdomain reg_tpi survquar;
                        sort hhid;
                        tempfile spdomainreg_tpi;
                save `spdomainreg_tpi', replace;
				codebook hhid;

        restore;
        
        sort hhid;
        merge hhid using `spdomainreg_tpi';
        tab _merge;
        drop _merge;
        drop if product==.;
codebook hhid;
tab spd;

sum if spd>=3;
table spdomain, content(mean quantity count quantity count hhid) row missing;

        drop if product==. | value==. | quantity==.  ;
codebook hhid;
tab spd;

********************************************************************
* Merge in temporal price index to convert nominal value to real
********************************************************************;
        sort reg_tpi survquar;
        merge reg_tpi survquar using "$path/work/temp_index_reg_tpi.dta";
        tab _merge;
        drop if _merge ~= 3;
        drop _merge;

        gen value_r=value/tpi_trim;


**************************************************************************;
* Identify relatively poor households, based on nominal temporally adjusted
* consumption per capita. Only work with these households for the price
* calculations.
**************************************************************************;
                preserve;
                        use "$path/work/conpc.dta", clear;
*                       use "$path/work/consump_nom.dta", clear;

*CA modified to merge in work/hhdata.dta for bootstrap;
	sort hhid;
      merge hhid using "$path/work/hhdata.dta";
      tab _m;
      drop _m;

*CA modified to keep bswt;
                                keep hhid hhweight hhsize cons_pc_nom bswt ;

                                sort hhid;
                                merge hhid using `spdomainreg_tpi';
                                tab _merge;
                                drop _merge;

                                sort reg_tpi survquar;
                                cap drop _merge;
                                merge reg_tpi survquar using "$path/work/temp_index_reg_tpi.dta";
                                tab _merge;
                                drop _merge;

                                sort hhid;
                                merge hhid using "$path/work/conpc.dta";
                                tab _merge;
                                drop _merge;

                                gen food_pc_tpi  = food_pc_nom /tpi_trim;
                                lab var food_pc_tpi "Temp-adjusted per capita food consumption/day";
								
* Non-food not TPI adjusted ;
                                gen cons_pc_tpi = food_pc_tpi + nf_pc_nom;
                                lab var cons_pc_tpi "Temp adjusted total consumption/day";

                                gen one=1;

                                tempfile contpi;
                                save `contpi', replace;

                                collapse (p$bottom) one cons_pc_tpi [aw=hhsize*hhweight], by(spdomain) ;
                                rename cons_pc_tpi pctile_60;
                                tempfile 60pct;
                                sort spdomain;
                                save `60pct', replace;

                                use `contpi';
                                        sort spdomain;
                                        merge spdomain using `60pct';
                                        tab _merge;
                                        drop _merge;
                                        drop one;
                                        sort spdomain;
                                        gen bottom_basket=cons_pc_tpi< pctile_60;
                                        by spdomain: tab bottom_basket [aw=hhsize*hhweight];
                                        lab var bottom_basket "=1 if in bottom (60%) of PCE";

                                        sort hhid;                                        
                        save "$path/work/bottom_basket.dta", replace;
        restore;

        sort hhid;
        merge hhid using "$path/work/bottom_basket.dta";
        tab _merge;
        drop _merge;
        
		* Only keep price observations for the poor ;
        keep if bottom_basket==1;
        
**************************************************************************;
* Toss out the bottom 5% and top 5% of the HH-LEVEL prices per kg in
* for each spdomain & product combination. This should eliminate outliers
* that may have an undue influence on the price calculation. 
**************************************************************************;
                gen hhppkg=value_r/quantity;
                egen lower5=pctile(hhppkg), p(5) by(spdomain product);
                egen upper5=pctile(hhppkg), p(95) by(spdomain product);

sum;
describe;

keep if hhppkg-lower5>=0 & hhppkg-upper5<=0;

*********************************************************************
* Note that we do prices in three ways. First, by summing quantity and value 
* This average price price_unitw is thus quantity/value weighted. Second, we
* calculate the price and take simple means for a transaction weighted
* price, price_unitt. Last we take the median, price_unitm. But in the end
* we only use price_unitw
*********************************************************************;
        gen price_unitt=value_r/(quantity*1000);
        gen price_unitm=price_unitt;

		*CA modified to count the boot sample weight bswt;
        collapse (sum) quantity value_r count bswt 
                 (mean) price_unitt 
                 (median) price_unitm [aw=hhweight], by(spdomain product);

        *Generate weighted price per gram ;
        gen price_unitw=value_r/(quantity*1000);
        drop value_r quantity;

        sort spdomain product;

        lab var price_unitt "simple average of calculated prices - transaction weighted";
        lab var price_unitm "median of prices";
        lab var price_unitw "value share weighted mean prices";

       *replace price_unitw = price_unitw*189.48/230.58;
         
* Get an idea of the difference between the price measures;
        gen ratiotw=price_unitt/price_unitw;
        gen ratiomw=price_unitm/price_unitw;

        sum ratiotw ratiomw;

        sort product;
        merge product using "$path/work/codes_food_basket_flex.dta";
        tab _m;
        count if _merge~=3;
        drop if _merge~=3;
        drop _merge;

        sort product spdomain;
save "$path/work/price_unit_flex.dta", replace;


****************************************************************************************
* 110_price_unit_flex.do		(end)
****************************************************************************************;


cap log close;
