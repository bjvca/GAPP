*global path "C:/user/gapp"
clear all
set mem 999m

cap log close
log using "$path/rep/100_food_basket_flex.log", replace
clear
set more off
#delimit ;



**************************************************************************
* 100_food_basket_flex.do     (start)
*
* This file is to get the data from the cons_cod.dta in work and then 
* to create the do file with the 90% of the consumption expenditures 
* using a flexible basket of goods.
*
* NOTE: we actually keep goods representing 95% of expenditure
* in order to facilitate dropping of some goods (such as rats) where
* quantity and nutrition information is unknown.
*
* We base our basket on the bottom 60 percent of consumption per capita
* (weighted by hhweight*hhsize). We use the TEMPORALLY-ADJUSTED
* NOMINAL consumption because we don't have a spatial adjustment yet.
*
* (Then we iterate this process to arrive at a final food bundle in later code)
**************************************************************************;

*CA modified to bring in hhdata into bootstrap;

/*
This file uses:
                work/cons_cod.dta
                work/hhdata.dta
                work/products.dta
                work/consump_nom.dta
                work/temp_index_reg_tpi.dta
                work/food_cat.dta

This file creates:
                work/food_basket_flex.dta
                work/codes_food_basket_flex.dta
*/



*do "$path/new/010_initial.do";


**************************************************************************;
* First, make a small temp file that has the temporally adjusted 
* nominal consumption per capita, using work/consump_nom and 
* work/temp_index_reg_tpi.dta. Make a dummy variable indicating
* whether they are in the bottom 60%.
**************************************************************************;
use "$path/work/conpc.dta", clear;
*use "$path/work/consump_nom.dta", clear;

*CA modified to merge in work/hhdata.dta for bootstrap;
        sort hhid;
        merge hhid using "$path/work/hhdata.dta";
        tab _m;
        drop _m;


        keep hhid hhweight hhsize cons_pc_nom reg_tpi rural survquar;

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
        gen cons_pc_tpi = food_pc_tpi + nf_pc_nom;
        lab var cons_pc_tpi "Temp adjusted total consumption/day";

        gen one=1;

        tempfile contpi;
        save `contpi', replace;

        collapse (p$bottom) one cons_pc_tpi [aw=hhsize*hhweight] ;
        rename cons_pc_tpi pctile_60;
        tempfile 60pct;
        sort one;
        save `60pct', replace;
        
        use `contpi';
                sort one;
                merge one using `60pct';
                tab _merge;
                drop _merge;
                drop one;
        
                gen bottom_basket=cons_pc_tpi< pctile_60;
                tab bottom_basket [aw=hhsize*hhweight];
                lab var bottom_basket "=1 if in bottom 60% of PCE";
                
                sort hhid;
save `contpi' , replace;


**************************************************************************;
* Next, need to keep only the food products in order to calculate the 
* food poverty line, and then calculate the food expenses by code.
**************************************************************************;

use "$path/work/cons_cod.dta";
/*
        sort product;
        merge product using "$path/work/food_cat.dta";
        tab _merge;
        keep if _merge==3;
        drop _merge;
*/
        
        keep if food_cat;
        codebook hhid;
        sort hhid;

**************************************************************************;
* Next, merge in the consumption information, and select those in bottom
* 60% of nominal distribution, after making temporal adjustment. 
**************************************************************************;
        merge hhid using `contpi';
        tab _merge;
        keep if _merge==3;
        drop _merge;

        keep if bottom_basket==1;
     

**************************************************************************;
* Calculate food shares. Since we're only doing shares here, we can
* work with the expenditures without doing temporal adjustment.
**************************************************************************;

          gen  food_expenditure= cod_hh_nom3;
		  
          *gen  food_expenditure= own_valued + daily_valued + monthly_valued + educ_valued;
          egen tot_food_expen= sum (food_expen), by (hhid) ;
          count if food_expenditure==.;
          count if tot_food_expen==.;
          
          gen food_share= food_expenditure/tot_food_expen;
          count if food_share==.;
          drop if food_share==.;

          sort hhid product;
                        tempfile food_basket_flex;
save `food_basket_flex', replace;

********************************************************************************;
* Now prepare to get the variable spdomain to the using dataset, and then find the 
* total shares by each product in order to select the most important goods in the 
* basket.
********************************************************************************;
                preserve;
                use "$path/work/hhdata.dta", clear;
                        keep hhid spdomain;
                        sort hhid;
                        tempfile spdomain;
                save `spdomain' , replace;
                restore;
                
           collapse (mean) hhweight, by (hhid);
           sort hhid ; 
           merge hhid using `spdomain';
           tab _merge;
           drop if _m==2;
           drop _merge; 
           collapse (sum) hhweight , by(spdomain);

           rename hhweight tothhweight;
           tempfile tothhweight;
save `tothhweight';


use `food_basket_flex';
          sort hhid;

          merge hhid using `spdomain';
          tab _merge;
          sort _m;
          drop if _m==2;
          drop _m;


          sort spdomain;
            merge spdomain using `tothhweight';
          tab _merge;
          drop _merge;

            sort spdomain product;

            gen f_share_w=(food_share*hhweight)/tothhweight;
			
			*drop descript;
			*gen descript = 0;

            collapse (sum) f_share_w, by(spdomain product descript);         

            sort spdomain f_share_w;
          by spdomain: gen cumshr= sum(f_share_w);
          

          count if cumshr<=.075;
          drop if cumshr<=.075;

            lab var f_share_w "average food share for the 13 regions";

save "$path/work/food_basket_flex.dta", replace;

* List first spatial region to get an idea about contents;
list product spdomain f_share_w cumshr if spdomain==1;
          
          gen numreg=1;
          collapse (sum) numreg cumshr, by (product descript);
                
          keep product descript numreg;
          display _N;
          
          lab var numreg "number of goods in the basket";

/*
          merge product using "$path/work/products.dta";
            tab _merge;
          keep if _merge==3;
*/
          keep product descript numreg;  
          sort product;     
          display _N;  

save "$path/work/codes_food_basket_flex.dta", replace;



**************************************************************************
* 100_food_basket_flex.do     (end)
**************************************************************************;

cap log close;
