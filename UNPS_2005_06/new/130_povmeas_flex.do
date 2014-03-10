*global path "C:/user/gapp"
clear all
set mem 999m

cap log close
log using "$path/rep/130_povmeas_flex.log", replace
clear
set more off
#delimit ;



**************************************************************************
* 130_povmeas_flex.do		(start)
*
* Purpose:
* Initial poverty measures calculation for flexible basket. (Before any iteration)
**************************************************************************;


*CA modified to add work/hhdata.dta for bootstrap;

/*
This file uses:
	in/foodshr96.dta
	work/povline_f_flex.dta
	work/consump_nom.dta
	work/hhdata.dta
	work/temp_index_reg_tpi.dta

This file creates:
	work/foodshr96.dta
	work/povmeas.dta
	work/povlines.dta
	work/cons_real.dta
*/



**************************************************************************;
* Bring in data file with nominal consumption per capita, and deflate it
* by temporal price index.
**************************************************************************;
use "$path/work/hhdata.dta", clear;
	keep hhid strata reg_tpi spdomain news rural survmon survquar;

	tab reg_tpi, miss;
	tab survquar, miss;

	keep hhid spdomain reg_tpi survquar;
	sort hhid;
	tempfile spdomainreg_tpi;
save `spdomainreg_tpi', replace;

use "$path/work/conpc.dta", clear;
*use "$path/work/consump_nom.dta", clear;

*CA modified to merge in work/hhdata.dta for bootstrap;
    sort hhid;
    merge hhid using "$path/work/hhdata.dta";
    tab _m;
    drop _m;

	keep hhid hhweight hhsize cons_pc_nom ;

	sort hhid;
	merge hhid using `spdomainreg_tpi';
	tab _merge;
	drop _merge;

	sort reg_tpi survquar;
	merge reg_tpi survquar using "$path/work/temp_index_reg_tpi.dta";
	tab _merge;
	drop _merge;

	sort hhid;
	merge hhid using "$path/work/conpc.dta";
	tab _merge;
	drop _merge;

	gen food_pc_tpi  = food_pc_nom /tpi_trim;
	lab var food_pc_tpi "Temp-adjusted per capita food consumption/day";
	
	gen cons_pc_tpi = food_pc_tpi + nf_pc_nom;
	lab var cons_pc_tpi "Temp adjusted total consumption/day";

	gen one=1;

* TPI deflated per capita consumption ;
	tempfile contpi;
save `contpi', replace;


**************************************************************************
* Calculate non-food expenditure for HH around the food poverty line
*
* Develop a discrete triangular weighted distribution. This gives a
* weight of  1 to HH at +/- 18-20% from food poverty line, and
* weight of  2 to HH at +/- 16-18% from food poverty line, and ...
* weight of 10 to HH at +/-  0- 2% from food poverty line.
* This weight is called triwt below.
**************************************************************************;
use `contpi';
	sort spdomain;
	merge spdomain using "$path/work/povline_food_flex.dta";
	tab _merge;
	drop _merge;

gen     triwt = 0 ;
replace triwt = 11 - round(50*abs(cons_pc_tpi/povline_f_flex-1)+0.5)
                if abs(cons_pc_tpi/povline_f_flex-1)<=0.2;
				
	* Nearness to poverty line and population weights ;
	gen tripopwt=triwt*hhweight*hhsize;

	preserve;
		collapse (mean) nf_pc_nom [aw=tripopwt] ,
			by(spdomain);
			
		rename nf_pc_nom povline_na_flex;
		lab var povline_na_flex "Nonfood poverty line. Flexible bundle";
		
		tempfile znf;
		sort spdomain;
		save `znf', replace;
		tab spdomain;
	restore;

	sort spdomain;
	merge spdomain using `znf';
	tab _merge;
	drop _merge;

**************************************************************************;
* Poverty line is the sum of the food and non-food poverty lines
**************************************************************************;
	gen povline_flex=povline_f_flex + povline_na_flex;
	lab var povline_flex "Poverty line. Flexible bundle";

	sort spdomain;
save "$path/work/povlines.dta", replace;

**************************************************************************;
* Create spatial price index, based on the total poverty line, with
* adjustment so that mean (and total) nominal consumption equals
* mean (and total) spatially deflated consumption.
*
* Choose arbitrary strata to be the base at first: we just use the first stratum.
**************************************************************************;
use `contpi';
	sort spdomain;
	merge spdomain using "$path/work/povlines.dta";
	tab _merge;
	drop _merge;

	* Real consumption pc, temporally deflated ;
	gen cr= cons_pc_tpi ;
	* Poverty line;
	gen linpob=povline_flex;

	*qui sum linpob if spdomain==1, meanonly;
	sum linpob if spdomain==3, meanonly;

	global spi_base=r(mean);
	* Spatial price index ;
	gen spi=linpob/$spi_base;
	* Real consumption pc, temporally and spatially deflated ;
	gen cr2=cr/spi;

	qui sum cr [aw=hhweight*hhsize];
	global sumcr=r(sum);
	qui sum cr2 [aw=hhweight*hhsize];
	global sumcr2=r(sum);
	replace spi=spi*$sumcr2/$sumcr;
	gen linpobr=linpob/spi;

	replace cr2=cr/spi;
	sum cr cr2 linpob linpobr [aw=hhweight*hhsize];
	lab var cr      "Temporally-adjusted cons pc";
	lab var cr2     "Spatially & temporally adjusted cons pc";
	lab var linpob  "Poverty line";
	lab var linpobr "Real poverty line";
	lab var spi     "Spatial price index";

**************************************************************************
* calculate poverty measures with the flexible food bundle
**************************************************************************;
	gen h = 100     if cr <=(linpob);
	replace  h = 0 if cr > (linpob);
			gen             pg      = ((linpob - cr )/linpob) *100;
	replace         pg      = 0             if h==0;
	gen             spg     = ((( linpob - cr )/ linpob )^2)*100;
	replace         spg     = 0             if h==0;

	gen h_flex=h;
	gen pg_flex=pg;
	gen spg_flex=spg;

	lab var h_flex   "Poverty headcount. Flex bundle";
	lab var pg_flex  "Poverty gap. Flex bundle";
	lab var spg_flex "Squared poverty gap. Flex bundle";

	sort hhid;
	merge hhid using "$path/work/hhdata.dta";
	tab _merge;
	drop if _merge~=3;
	drop _merge;

	gen popwt=hhsize*hhweight;
	
        * Stata 10.1 syntax ;
        svyset , clear;
        svyset [pweight=popwt] , str(strata) psu(psu);

	svy: mean h_flex pg_flex spg_flex;
	svy: mean h_flex pg_flex spg_flex , over(rural);
	svy: mean h_flex pg_flex spg_flex , over(news);
	svy: mean h_flex pg_flex spg_flex , over(reg_tpi);
	svy: mean h_flex pg_flex spg_flex , over(strata);
	svy: mean h_flex pg_flex spg_flex , over(spdomain);

	compress;
	sort hhid;
save "$path/work/cons_real.dta" , replace;

	collapse  (mean) h_flex pg_flex spg_flex [aw=hhweight*hhsize];

save "$path/work/povmeas.dta", replace;

*** HARUNA, the file Povmeas.dta gives the headcount poverty rates using flexible food bundle without inflicting reveales preferences
*** therefore specifications in line 226 of this do file have been changed repeatedly to generate these counts for particular
*** classifications of interest including strata spdomain region urban/rural (urban) and national (done by removing the by command 
**************************************************************************
* 130_povmeas_flex.do		(end)
**************************************************************************;


log close;
