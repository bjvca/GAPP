*global path "C:/user/gapp"
clear all
set mem 999m

cap log close
log using "$path/rep/170_pref_r_price.log", replace
clear
set more off
#delimit ;


**************************************************************************
* 170_pref_r_price.do		(start)
*
* This file conducts revealed preference comparisons so that
* we can check the quality of the regional baskets.
* It also exports the price and quantity data for work in GAMS
* Rather than make up for missing prices with shares, we estimate
* a missing price in this case
**************************************************************************;

*global n_spdom "13";

*global it_n "5";


/*
This file uses:
        work/quan_flex_it$it_n.dta
        work/povline_food_flex_it$it_n.dta
        work/price_unit_flex_it$it_n.dta
                
This file creates:
        work/pref_r_price.dta
        work/revpref_price_`i'.dta
        work/product_flex.inc
        work/price_unit_flex.inc
        work/quan_flex.inc
*/



***************************************************************************;
* Export price, codes and quantity data to text
***************************************************************************;

use "$path/work/price_unit_flex_it$it_n.dta";
gen reg=spdomain ;
gen crap=1;
 lab def crap
         1  ".";
 lab val crap crap;

outsheet product crap reg bswt price_uw$it_n using "$path/work/price_unit_flex.inc",  noquote noname replace ;

collapse (min) spdomain, by(product);
outsheet product  using "$path/work/product_flex.inc", noname replace;

use "$path/work/quan_flex_it$it_n.dta", clear;
gen reg=spdomain;
gen crap=1;
 lab def crap
         1  ".";
 lab val crap crap;

format calperg quan$it_n calpp %14.9e;

outsheet  product crap reg calperg quan$it_n  calpp povline_f_flex90_$it_n using "$path/work/quan_flex.inc", noname noquote replace;

clear;


**************************************************************************;
* Revealed preference calculations
* get the basket for the region we want to test
**************************************************************************;

tempfile quanreg;
tempfile getmiss;
tempfile codmiss;

gen crap=0;
save "$path/work/pref_r_price.dta", replace;

forvalues i=1/$n_spdom {		;

        clear;
        gen crap=0;
        save "$path/work/revpref_price_`i'.dta", replace;

        clear;

                use "$path/work/quan_flex_it$it_n.dta", clear;
                keep product spdomain quan$it_n price_uw$it_n val_ir$it_n povline_f_flex90_$it_n calpp;
        gen share=val_ir$it_n/povline_f_flex90_$it_n;
        rename price_uw$it_n pquanreg;
        rename spdomain spdomainq;
        drop if spdomainq~= `i';
        sort product;
		
                *rescale quantities to hit constant calorie target;
                gen ratquan=2150/calpp;

            gen quan_s=quan$it_n*ratquan;
            lab var quan_s "quantities rescaled to hit 2150 calories pp";

        save `quanreg', replace;

**************************************************************************;
* Now get the prices in other regions so that you can use them 
* to build  a new poverty line
**************************************************************************;

        forvalues j= 1/$n_spdom {		;

                use "$path/work/price_unit_flex_it$it_n.dta";
        
                        keep product spdomain price_uw$it_n descript count bswt;
                        sort product;
                keep if spdomain==`j';
                sort product;
                merge product using `quanreg';
    
                *here we have to deal with the fact that not all commodities are consumed in every region;
                *so we might have a quantity from region i but no price in region j;
                *these will have _merge value=2;
                *alternatively the number of observations might be too small;
                *deal with these problems by TAKING THE MAX PRICE OBSERVED ELSEWHERE (excluding Maputo)
                        
                tab _m;
                drop if _m==1;
                
                *CA modified to handle the counting of bswt instead of count
                  replace price_uw$it_n=. if round(bswt)<5;
                        gen pricemiss=0;
                  replace spdomain=`j' if _m==2 ;
                  replace pricemiss=1 if _m==2 | round(bswt)<5;
                        lab var pricemiss "identify those items with no price observation";
                  drop _m;
                        sort product;
*browse;
               *this is the tempfile containing observed quans and prices;
             save `getmiss', replace;

                        keep if pricemiss==1;

                        if _N>0 {
                            keep product;              
                              sort product;
                  
                          *this file contains the price codes that are missing for the region in question;
                            save `codmiss', replace;
*browse;
                
                  use "$path/work/price_unit_flex_it$it_n.dta", clear;
                        sort product;
*browse;
                        merge product using `codmiss';
                        
                        tab _m;
                        keep if _m==3 ;
                                *exclude Maputo province and city from other price calculation;
                                drop if spdomain>10;
                        collapse (max) price_uw$it_n, by(product);

                  *this file contains the code and the max price;
                  save `codmiss', replace;
*browse;
                        use `getmiss';
                              merge product using `codmiss';
*browse;
                        tab _m;
                        drop _m;
                        *end if;
                 };            
                        
                        else use `getmiss', clear;

                        gen val_q=quan_s*price_uw$it_n;
                        
                        collapse (sum) val_q pricemiss (mean) spdomainq ratquan, by(spdomain);
                  gen linf_q=val_q/.9;
                  drop val_q;
                        append using "$path/work/revpref_price_`i'.dta";
                        sort spdomain;
                save "$path/work/revpref_price_`i'.dta", replace;   

*browse;

        *close j loop;
        };

        *aggregate into a big data set;
        append using "$path/work/pref_r_price.dta";
      sort spdomain spdomainq;
      save "$path/work/pref_r_price.dta", replace;
 
*close i loop;
};

*bring in actual flexible bundle numbers;
use "$path/work/povline_food_flex_it$it_n.dta", clear;
        merge spdomain using "$path/work/pref_r_price.dta";
        tab _m; 
        drop crap;
        drop _m;
        order spdomainq spdomain;
      sort spdomainq spdomain;

        *rescale expenditures to hit a constant calorie target;
        gen povline_f5_s=ratquan*povline_f_flex90_$it_n;
      compress;

*browse;

        *categorize revealed preference performance;
      gen pref_r=0;
      replace pref_r=1 if float(linf_q)>float(povline_f5_s);
      replace pref_r=2 if float(linf_q)<float(povline_f5_s);

      lab var pref_r "Fails or passes revealed preference test";
      lab def pref_r
                        0 "comparison of the same region with itself"
                        1 "passes revealed preference test"
                        2 "fails revealed preference test" ;

        lab val pref_r pref_r;
      drop if spdomainq==spdomain;
        tab pref_r;     
        sort spdomainq ;
      by spdomainq: tab pref_r;

save "$path/work/pref_r_price.dta", replace;

*drop comparisons with Maputo ;
drop if spdomain>=11;
drop if spdomainq>=11;
display "this is with maputo dropped";
tab pref_r;

*further drop Nampula rural and urban;
drop if spdomain==3 | spdomain==4;
display "this is with maputo and nampula dropped (MAH: Actually not - experimenting with 6 spatial domains)";
tab pref_r;


**************************************************************************
* 170_pref_r_price.do		(end)
**************************************************************************;

log close;
