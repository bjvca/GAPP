*global path "C:/Users/Templeton/Desktop/GAPP/GAPP-UGANDA-HARUNA"
clear all
set mem 100m

clear
cap log close
log using "$path/rep/080_conpc.log", replace
set more off
#delimit ;

***************************************************************************
* 080_conpc.do		(start)
*
* Creates a file with per capita nominal consumption divided between food
* and non-food categories based on the calorie definition of food
* rather than the COICOP (INE) definition of food. ready for 
* temporal deflation when necessary
****************************************************************************;

/*
This file uses:
        work/hhdata.dta
        work/consump_nom.dta
      
This file creates:
        work/conpc.dta
*/



***************************************************************************
* Food expenditure
****************************************************************************;
*use "$path/in/cons_cod.dta";
use "$path/work/cons_cod.dta";
            *sort product;
            *merge product using "$path/work/food_cat.dta";
            *tab _m;
            *drop _m;
            keep if food_cat==1;
            collapse (sum) cod_hh_nom, by(hhid);
            rename cod_hh_nom food_hh_nom;
                sort hhid;
            keep hhid food_hh_nom;
            tempfile foodexp;
save `foodexp';

***************************************************************************
* Food expenditure merged with all expenditure
****************************************************************************;
use "$path/work/cons_cod.dta";
*use "$path/in/cons_cod.dta";
*use "$path/in/cons_cat.dta";
sum;
collapse (sum) cod_hh_nom, by(hhid);
*gen cons_pc_nom = cons_hh_nom/hhsize;
rename cod_hh_nom cons_hh_nom;
*keep  hhid cons_pc_nom cons_hh_nom ;
*keep hhid cod_hh_nom;
*use "$path/in/cons_cod.dta";
*use "$path/in/consump_nom.dta";
*use "$path/work/consump_nom.dta";
*            keep  hhid cons_hh_nom ;
            display _N;
            keep  hhid cons_hh_nom ;
            sort hhid;
            merge hhid using "$path/work/hhdata.dta";
            tab _m;
            drop _m;
gen cons_pc_nom = cons_hh_nom/hhsize;
            sort hhid;
            merge hhid using `foodexp';
            tab _m;
                drop if _merge==2;
            replace food_hh_nom=0 if _merge==1 & food_hh_nom==.;
            drop _m;
                gen food_pc_nom=food_hh_nom/hhsize;
                gen nf_hh_nom=cons_hh_nom-food_hh_nom;
            gen nf_pc_nom=nf_hh_nom/hhsize;
 
            keep hhid cons_hh_nom food_pc_nom nf_pc_nom cons_pc_nom survquar spdomain news reg_tpi rural hhweight hhsize;
            lab var food_pc_nom "nominal food consumption per capita";
            lab var nf_pc_nom "nominal non-food consumption per capita";
keep hhid cons_hh_nom cons_pc_nom food_pc_nom nf_pc_nom;
            sort hhid;

* MAH ; sum; codebook hhid;
save "$path/work/conpc.dta", replace;


***************************************************************************
* 080_conpc.do		(end)
****************************************************************************;


log close;
