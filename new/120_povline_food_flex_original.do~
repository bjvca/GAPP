*global path "C:\user\gapp"
clear all
set mem 999m

cap log close
log using "$path/rep/120_povline_food_flex.log", replace
clear
set more off
#delimit ;


**************************************************************************
* 120_povline_food_flex.do	(start)
*
* Use the file with the food basket (food_basket_flex), which is in shares. 
* Then merge it with the prices file, and then with the calories file.
* Along the way, drop those observations where we have no price information
* or no calorie information.
**************************************************************************;


/*
This file uses:
        work\food_basket_flex.dta
        work\price_unit_flex.dta
        work\calperg.dta
        work\calpp.dta

This file creates:
        work\povline_flex.dta
*/


* start with the quantity information;
use "$path/work/food_basket_flex.dta";
        sort product spdomain;
        * merge in price information;
        merge product spdomain using "$path\work\price_unit_flex.dta";

        tab _merge;
        list product spdomain descript if _merge==1;

        drop if _merge ~=3;
        drop _merge;
        sort product;

        * merge in information on calories per gram;
        merge product using "$path\work\calperg.dta";
        tab _merge;

        * This tells where we are lacking calorie info or are lacking quantity info due to 
        * missing price info above;
        list product spdomain descript if _merge==1;

        drop if _merge~=3;
        drop _merge;
        sort spdomain f_share_w;
        
        * CA modified to handle bootstrap counting;

        * determine if any quantity has fewer than 10 price observations;
        by spdomain: count if round(bswt)<10;
        drop if round(bswt) < 10;

        by spdomain: egen baskshr=sum(f_share_w);
        by spdomain: gen cumshr1=sum(f_share_w);

        * bundle was cut at 92.5 percent- cut back to 90 percent if necessary;
        drop if cumshr1<=baskshr-.9;

        * reobtain the share represented from the average basket- should be slightly more than 90;
        drop baskshr;
        by spdomain: egen baskshr=sum(f_share_w);
        by spdomain: sum baskshr;

        * obtain quantities and calories provided by these quantities;
        gen quan=f_share_w/price_unitw;			/* how many g in 1 MT exp on food item */
        gen cal_ir=quan*calperg;				/* how many cal in 1 MT exp on food item */
        by spdomain: egen calreg=sum(cal_ir);	/* how many cal in 1 MT exp in food basket*/

        * merge in calorie requirements;
        sort spdomain;
        merge spdomain using "$path\work\calpp.dta";
        tab _merge;
        drop _merge;

        * get the expansion factor to hit 95% of calorie requirements;
        gen ratio=.95*calpp/calreg;
		
        replace quan=quan*ratio;
        replace cal_ir=quan*calperg;

        * do a consistency check;
        sort spdomain;
        by spdomain: egen chkcal=sum(cal_ir);
        replace chkcal=chkcal/.95-calpp ;
		
        * these values should be about zero;
        by spdomain: sum chkcal;

        * obtain the value of each good in the bundle;
        gen val_ir=quan*price_unitw;

        * the sum of the value of the goods in the bundle is assumed to represent 90% of expenditure;
        by spdomain: egen povline_f_flex90=sum(val_ir);
        replace povline_f_flex=povline_f_flex90/.9;

        collapse (mean) povline_f_flex, by (spdomain);
		
lab var povline_f_flex "Food poverty line. Flexible basket";

        sort spdomain;
        keep spdomain povline_f_flex;

save "$path\work\povline_food_flex.dta", replace;



/*
* To be used in 140_iterate.do;
gen cutoff = 1.5 * povline_f_flex;
keep spdomain cutoff;
save "$path/work/povlines_first_iterate.dta", replace;
*/

**************************************************************************
* 120_povline_food_flex.do	(end)
**************************************************************************;

log close;
