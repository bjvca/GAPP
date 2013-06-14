*global path "C:\user\gapp"
clear all
set mem 999m

cap log close
log using "$path/rep/200_povmeas_fix.log" , replace
clear
set more off
#delimit ;



*********************************************************************************
* 200_povmeas_fix.do		(start)
*
* This file produces poverty measures taking the fixed poverty lines
* as a base. The 1996 bundle is kept and 1996 food shares are kept as well.
*********************************************************************************;


/*
This file uses:
	work\povline_food_ent.csv
	work\conpc.dta
	work\hhdata.dta
	work/temp_index_reg_tpi.dta
    work/foodshr96.dta

This file creates:
	work\povlines_ent.dta

 (for Maputo food share fixed)
	  work\povmeas_fix.dta
      work\nat_pov_ent.csv
      work\rur_pov_ent.csv
      work\news_pov_ent.csv
      work\reg_tpi_pov_ent.csv
      work\strata_pov_ent.csv
      work\spdomain_pov_ent.csv
      work\spdomain_pov_ent.csv

(for Maputo food share flexible)
	work\povlines_ent.dta
      work\nat_pov_ent_m.csv
      work\rur_pov_ent_m.csv
      work\news_pov_ent_m.csv
      work\reg_tpi_pov_ent_m.csv
      work\strata_pov_ent_m.csv
      work\spdomain_pov_ent_m.csv
      work\spdomain_pov_ent_m.csv
	work\povlines_ent.csv
*/



**************************************************************************;
* Bring in data file with nominal consumption per capita, and deflate it
* by temporal price index.
**************************************************************************;
use "$path/work/hhdata.dta", clear;
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
	tempfile contpi;
save `contpi', replace;

**************************************************************************;
* Use (fixed) food shares from last survey
**************************************************************************;

*Bring in fixed food poverty lines;
clear;

insheet using "$path\work\povline_food_ent.csv";
	rename fix food_povline_fix;

     keep spdomain food_povline_fix;
     sort spdomain;

	* MAH: Food share in last survey taken directly from in-folder ;
	merge spdomain using "$foodshr_pastSurvey", keep(spdomain $fdshr_t1);
	tab _m;
	drop _m;

	gen fdshr_t1 = $fdshr_t1;
	drop $fdshr_t1;
	lab var fdshr_t1 "year t1 (e.g. 1996) poverty line food share";

    * Use the (fixed) food share from last survey;
	gen povline_fix=food_povline_fix/fdshr_t1;

	lab var povline_fix   "poverty lines with all regions calculated using fixed bundle non-food shares";

	sort spdomain;
tempfile povlines_ent;
save `povlines_ent', replace;

clear;

**************************************************************************;
* Calculate poverty measures with 2002-03 food shares
**************************************************************************;
use `contpi';
	sort spdomain;
	merge spdomain using `povlines_ent';
	tab _merge;
	drop _merge;

**************************************************************************;
* Create spatial price index, based on the total poverty line, with
* adjustment so that mean (and total) nominal consumption equals
* mean (and total) spatially deflated consumption.
*
* Choose arbitrary strata to be the base at first. The middle of the 13
* codes is code 7 -- that's arbirtary enough.
**************************************************************************;
	gen cr= cons_pc_tpi ;
	gen linpob=povline_fix;

*MAH; *Now only 6 regions, so base is chosen as the 1;
	*qui sum linpob if spdomain==7, meanonly;

	qui sum linpob if spdomain==1, meanonly;
	global spi_base=r(mean);
	gen spi=linpob/$spi_base;
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

	*calculate poverty measures;
	gen h = 100     if cr2 <=(linpobr);
	replace  h = 0 if cr2 > (linpobr);
			gen             pg      = ((linpobr - cr2 )/linpobr) *100;
	replace         pg      = 0             if h==0;
	gen             spg     = ((( linpobr - cr2 )/ linpobr )^2)*100;
	replace         spg     = 0             if h==0;

	gen h_fix=h;
	gen pg_fix=pg;
	gen spg_fix=spg;

	lab var h_fix   "Poverty headcount. Fixed bundle";
	lab var pg_fix  "Poverty gap. Fixed bundle";
	lab var spg_fix "Squared poverty gap. Fixed bundle";

	sort hhid;
	merge hhid using "$path\work\hhdata.dta";
	tab _merge;
	drop if _merge~=3;
	drop _merge;

	gen popwt=hhsize*hhweight;
	lab var popwt "Population weights = hhsize X hhweight";
	
        * Stata 10.1 syntax ;
        svyset , clear;
        svyset [pweight=popwt] , str(strata) psu(psu);

*MAH: Below at various places the original reg13 has been changed into spdomain or spdomain ;	

	svy: mean h_fix pg_fix spg_fix;
	svy: mean h_fix pg_fix spg_fix , over(rural);
	svy: mean h_fix pg_fix spg_fix , over(news);
	svy: mean h_fix pg_fix spg_fix , over(reg_tpi);
	svy: mean h_fix pg_fix spg_fix , over(strata);
	svy: mean h_fix pg_fix spg_fix , over(spdomain);
	svy: mean h_fix pg_fix spg_fix , over(spdomain);

	
drop bswt one h pg spg;
	compress;
	sort hhid;
	save "$path\work\povmeas_fix.dta", replace;

      gen dum=1;


	*output the national measures;
	collapse  (mean) dum h_fix pg_fix spg_fix [aw=hhweight*hhsize];
gen geo="National";
gen geono=dum;
tempfile nat;
save `nat';

	*output the rural/urban measures;
	use "$path\work\povmeas_fix.dta", clear;
	collapse  (mean) h_fix pg_fix spg_fix [aw=hhweight*hhsize], by(rural);
gen geo="Rural/Urban";
gen geono=rural;
tempfile rur;
save `rur';

	*output the dominios espaciais measures;
	use "$path\work\povmeas_fix.dta", clear;
	collapse  (mean) h_fix pg_fix spg_fix [aw=hhweight*hhsize], by(news);
gen geo="North/Center/South";
gen geono=news;
tempfile new;
save `new';

	*output the North South Center measures;
	use "$path\work\povmeas_fix.dta", clear;
	collapse  (mean) h_fix pg_fix spg_fix [aw=hhweight*hhsize], by(reg_tpi);
gen geo="TPI - 6 regions";
gen geono=reg_tpi;
tempfile rtp;
save `rtp';

	*output the provincial measures;
	use "$path\work\povmeas_fix.dta", clear;
	collapse  (mean) h_fix pg_fix spg_fix [aw=hhweight*hhsize], by(strata);
gen geo="Provinces";
gen geono=strata;
tempfile str;
save `str';
	
	*output the dominios espaciais measures;
	use "$path\work\povmeas_fix.dta", clear;
	collapse  (mean) h_fix pg_fix spg_fix [aw=hhweight*hhsize], by(spdomain);
gen geo="Spatial domains";
gen geono=spdomain;
tempfile r13;
save `r13';

clear;
set obs 1;
gen geo=" ";
tempfile one;
save `one';

use          `nat';
append using `one';
append using `rur';
append using `one';
append using `new';
append using `one';
append using `rtp';
append using `one';
append using `str';
append using `one';
append using `r13';

outsheet geo geono h_fix   pg_fix   spg_fix   dum rural news reg_tpi strata spdomain using "$path/work/poverty_fixedBask.csv", replace c ;



	*set aside the spatial price index;
      tempfile spi;
      use "$path\work\povmeas_fix.dta", clear;
      collapse (mean) spi, by(spdomain);
      sort spdomain;
save `spi', replace;

clear;

**************************************************************************;

use `povlines_ent';
       sort spdomain;
       merge spdomain using `spi';
       tab _m; drop _m;
save "$path\work\povlines_fix.dta", replace;

outsheet spdomain food_povline_fix fdshr_t1 povline_fix using "$path\work\povlines_fix.csv", replace c ; 


*********************************************************************************
* 200_povmeas_fix.do		(end)
*********************************************************************************;

log close;
