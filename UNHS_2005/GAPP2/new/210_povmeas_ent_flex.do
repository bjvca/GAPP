*global path "C:\user\gapp"
clear all
set mem 999m

cap log close
log using "$path/rep/210_povmeas_ent_flex.log" , replace
clear
set more off
#delimit ;



*********************************************************************************
* 210_povmeas_ent_flex.do		(start)
*
* This file produces poverty measures taking the entropy adjusted poverty 
* lines as a base. It produces two sets of poverty measures. In one, 
* Maputo is treated with the logic of the fixed bundle. In the second, the revealed preference logic
* is maintained. Here, the flexible bundle is viewed as being determined by the 
* lower constraint on the value of the food bundle dictated by P_t2*Q_t1. In this case,
* the year t2 food shares are calculated and applied.
*
* Fixed poverty lines/etc. are mentioned here and there. But there are NO fixed
* calculations for Maputo (or other provinces) anymore
*
*********************************************************************************;


/*
This file uses:
	work\povline_food_ent.csv
	work\conpc.dta
	work\hhdata.dta
	work/temp_index_reg_tpi.dta

This file creates:
	work\povlines_ent.dta
	work\povmeas_ent_flex.dta
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
	drop if nf_pc_nom>15000;
	gen food_pc_tpi  = food_pc_nom /tpi_trim;
	lab var food_pc_tpi "Temp-adjusted per capita food consumption/day";
	gen cons_pc_tpi = food_pc_tpi + nf_pc_nom;
	lab var cons_pc_tpi "Temp adjusted total consumption/day";

	gen one=1;
	tempfile contpi;
save `contpi', replace;

**************************************************************************;
* Calculate the food shares for people near the food poverty line
**************************************************************************;

*Bring in entropy estimated flexible lines;
clear;

insheet using "$path/work/povline_food_ent.csv";
	rename ent food_povline_ent;

     keep spdomain food_povline_ent;
     sort spdomain;

*Bring in fixed bundle poverty lines for Maputo ;
*This is the same level for both entropy and fixed bundle analysis;
*since the Q02*P02<=Q96*P02 constraint is binding;

*$no_temp_rev	merge spdomain using "$path/work/povline_food_fix.dta";
*$no_temp_rev    replace food_povline_ent=food_povline_w if spdomain>10;
      keep spdomain food_povline_ent;
      sort spdomain;
      tempfile food_povline_ent;
save `food_povline_ent';

clear;

use `contpi';
	sort spdomain;
	merge spdomain using `food_povline_ent';
	tab _merge;
	drop _merge;

gen     triwt = 0 ;
replace triwt = 11 - round(50*abs(cons_pc_tpi/food_povline_ent-1)+0.5)
                if abs(cons_pc_tpi/food_povline_ent-1)<=0.2;
	



	gen tripopwt=triwt*hhweight*hhsize;

	collapse (mean) nf_pc_nom food_povline_ent [aw=tripopwt] ,
	by(spdomain);
	rename nf_pc_nom povline_nf;
	lab var povline_nf "Nonfood poverty line";
	sort spdomain;

*	merge spdomain using "$foodshr_pastSurvey", keep(spdomain $fdshr_t1);

*	tab _m;
*	drop _m;

*	gen fdshr_t1 = $fdshr_t1;
*	drop $fdshr_t1;
*	lab var fdshr_t1 "year t1 (e.g. 1996) poverty line food share";

     *calculate line for all provinces with flexible food shares;		
	gen povline_ent_m=food_povline_ent + povline_nf;
	gen fdshr=food_povline_ent/povline_ent;
	lab var fdshr "year t2 (e.g. 2002) poverty line food share";

      *redo for maputo inserting the fixed food share;
 *     gen povline_ent=povline_ent_m;
*MAH;
*$no_temp_rev	replace povline_ent=food_povline_ent/fdshr_t1 if spdomain >=11;

*	lab var povline_ent   "poverty lines with Maputo regions calculated using fixed bundle non-food shares";
    lab var povline_ent   "poverty lines with all regions calculated using flexible bundle non-food shares";
*    lab var povline_ent_m "poverty lines with Maputo regions calculated using flexible bundle non-food shares";

	sort spdomain;
tempfile povlines_ent;
save `povlines_ent', replace;

clear;

**************************************************************************;
* Calculate poverty measures with all regions using flexible year t2 food shares
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
	gen linpob=povline_ent;

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
	replace  h = 0  if cr2 > (linpobr);
	gen             pg      = ((linpobr - cr2 )/linpobr) *100;
	replace         pg      = 0             if h==0;
	gen             spg     = ((( linpobr - cr2 )/ linpobr )^2)*100;
	replace         spg     = 0             if h==0;

	gen h_ent  =h;
	gen pg_ent =pg;
	gen spg_ent=spg;

	lab var h_ent   "Poverty headcount entropy bundle with Maputo food share fixed";
	lab var pg_ent  "Poverty gap entropy bundle with Maputo food share fixed";
	lab var spg_ent "Squared poverty gap entropy bundle with Maputo food share fixed";

	sort hhid;
	merge hhid using "$path/work/hhdata.dta";
	tab _merge;
	drop if _merge~=3;
	drop _merge;

	gen popwt=hhsize*hhweight;
	lab var popwt "Population weights = hhsize X hhweight";
	
        * Stata 10.1 syntax ;
        svyset , clear;
        svyset [pweight=popwt] , str(strata) psu(psu);

*MAH: Below at various places the original reg13 has been changed into spdomain or spdomain ;	

	svy: mean h_ent pg_ent spg_ent;
	svy: mean h_ent pg_ent spg_ent , over(rural);
	svy: mean h_ent pg_ent spg_ent , over(strata);
	svy: mean h_ent pg_ent spg_ent , over(spdomain);
	svy: mean h_ent pg_ent spg_ent , over(spdomain);

	
	compress;
      gen dum=1;
	sort hhid;

	*set aside the spatial price index;
      tempfile spi;
*      use "$path/work/povmeas_ent.dta", clear;
      collapse (mean) spi, by(spdomain);
      sort spdomain;
save `spi', replace;

clear;

**************************************************************************;
* Calculate poverty measures with Maputo regions on flexible food shares
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
	gen linpob=povline_ent_m;

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

	gen h_ent_m  =h;
	gen pg_ent_m =pg;
	gen spg_ent_m=spg;

	lab var h_ent_m   "Poverty headcount entropy bundle. Food share flexible. Flexible bundle";
	lab var pg_ent_m  "Poverty gap entropy bundle. Food share flexible. Flexible bundle";
	lab var spg_ent_m "Squared poverty gap entropy. Food share flexible. Flexible bundle";

	sort hhid;
	merge hhid using "$path/work/hhdata.dta";
	tab _merge;
	drop if _merge~=3;
	drop _merge;

	gen popwt=hhsize*hhweight;
	lab var popwt "Population weights = hhsize X hhweight";
	
        * Stata 10.1 syntax ;
        svyset , clear;
        svyset [pweight=popwt] , str(strata) psu(psu);
	
	svy: mean h_ent_m pg_ent_m spg_ent_m;
	svy: mean h_ent_m pg_ent_m spg_ent_m , over(rural);
	svy: mean h_ent_m pg_ent_m spg_ent_m , over(news);
	svy: mean h_ent_m pg_ent_m spg_ent_m , over(reg_tpi);
	svy: mean h_ent_m pg_ent_m spg_ent_m , over(strata);
	svy: mean h_ent_m pg_ent_m spg_ent_m , over(spdomain);
	
drop bswt one h pg spg;
	compress;
label data "Final data set. Official published poverty rates are calculated from this data set";
	sort hhid;
	save "$path/work/povmeas_ent_flex.dta", replace;

gen dum=1;

	*output the national measures;
	collapse  (mean) dum h_ent_m pg_ent_m spg_ent_m [aw=hhweight*hhsize];
gen geo="National";
gen geono=dum;
tempfile nat;
save `nat';

	*output the rural/urban measures;
	use "$path/work/povmeas_ent_flex.dta", clear;
	collapse  (mean) h_ent_m pg_ent_m spg_ent_m [aw=hhweight*hhsize], by(rural);
gen geo="Rural/Urban";
gen geono=rural;
tempfile rur;
save `rur';

	*output the North South Center measures;
	use "$path/work/povmeas_ent_flex.dta", clear;
	collapse  (mean) h_ent_m pg_ent_m spg_ent_m [aw=hhweight*hhsize], by(news);
gen geo="North/Center/South";
gen geono=news;
tempfile new;
save `new';

	*output the North South Center rural/urban measures;
	use "$path/work/povmeas_ent_flex.dta", clear;
	collapse  (mean) h_ent_m pg_ent_m spg_ent_m [aw=hhweight*hhsize], by(reg_tpi);
gen geo="TPI - 6 regions";
gen geono=reg_tpi;
tempfile rtp;
save `rtp';

	*output the provincial measures;
	use "$path/work/povmeas_ent_flex.dta", clear;
	collapse  (mean) h_ent_m pg_ent_m spg_ent_m [aw=hhweight*hhsize], by(strata);
gen geo="Provinces";
gen geono=strata;
tempfile str;
save `str';
	
	*output the dominios espaciais measures;
	use "$path/work/povmeas_ent_flex.dta", clear;
	collapse  (mean) h_ent_m pg_ent_m spg_ent_m [aw=hhweight*hhsize], by(spdomain);
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

outsheet geo geono h_ent_m pg_ent_m spg_ent_m dum rural news reg_tpi strata spdomain using "$path/work/poverty_ent_flexBask.csv", replace c ;



	*set aside the spatial price index;
      tempfile spi_m;
      use "$path/work/povmeas_ent_flex.dta", clear;
      collapse (mean) spi, by(spdomain);
      rename spi spi_m;
      sort spdomain;
save `spi_m', replace;

use `povlines_ent';
       sort spdomain;
       merge spdomain using `spi';
       tab _m; drop _m;
       sort spdomain;
       merge spdomain using `spi_m';
	tab _m; drop _m;
save "$path/work/povlines.dta", replace;

outsheet spdomain food_povline_ent povline_ent fdshr using "$path/work/povlines.csv", replace c; 

*********************************************************************************
* 210_povmeas_ent_flex.do		(end)
*********************************************************************************;

log close;
