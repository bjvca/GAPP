clear all
global path "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA"
set mem 999m

cap log close
log using "$path/rep/020_hhdata.log", replace
clear
set more off
#delimit ;

**************************************************************************
* 020_hhdata.do		(start)
*
* Organize the hhid identifier in the HHData file the same way, and keep
* only the relevant variables.
*
* This file sets:
* - interview month, quarter and year
* - regions: make all needed regions. But in the end only the one specified
*            in initial.do are kept. These are
*            - rural: 0=urban, 1=rural
*            - news: speficifying North, East, West, South. But combinations
*                    are also possible, eg. North-East, Center,...
*            - reg_tpi: regions with own TPI
*            - strata: strata regions
*            - spdomain: spatial domains (regions with own poverty line)
*            - news_ru_ur: combination of news and rural
**************************************************************************;

use "$path\in\hhdata.dta", clear;


*recode spdomain 10=1 11=2 20=3 30=4 40=5 these have been set to five for Uganda to ensure hwe have at least 1000 households per domain;
tab spdomain, missing;
	sort hhid;
	save "$path\work\hhdata.dta", replace;
	sum;

use "$path\in\indata.dta", clear;
	*sort hhid;
	save "$path\work\indata.dta", replace;
	sum;

use "$path\in\calperg.dta", clear;
	*sort hhid;
	save "$path\work\calperg.dta", replace;
	sum;

use "$path\in\cons_cod.dta", clear;
	*sort hhid;
	save "$path\work\cons_cod.dta", replace;
	sum;

use "$path\in\cons_cod_trans.dta", clear;
	*sort hhid;
	save "$path\work\cons_cod_trans.dta", replace;
	sum;

/*
use "$path\in\cons_cod_trans.dta", clear;
	*sort hhid;
	sum;
for var value quantityd cod_hh_nom cod_hh_nom2 cod_hh_nom3: replace X=0 if X==.;
collapse food_cat prod_cat (sum) value quantityd cod_hh_nom cod_hh_nom2 cod_hh_nom3, by(hhid product descript);
	save "$path\work\cons_cod.dta", replace;
	sum;
*/
 
**************************************************************************
* 020_hhdata.do		(end)
**************************************************************************;

cap log close;
