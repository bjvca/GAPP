*global path "C:/user/gapp"
clear all
set mem 999m

cap log close
log using "$path/rep/140_iterate.log", replace
clear
set more off
#delimit ;

*global povline_initial "$path/in/povlines_first_iof.dta";

**************************************************************************
* 140_iterate.do	(start)
*
* Purpose: Create flexible food basket and poverty line with iterative procedure
*
* This program will take the results from the first pass at the
* poverty lines and applies the corresponding spatial deflator to
* re-select the relatively poor, their consumption bundles, and
* their prices.
*
* Welfare indicator is here always temporally and spatially adjusted per capita
* expenditure. Here called cr_it< >.
*
* We will iterate this process 5 times which here assures convergence.
*
* CA, Mar 2010: Relatively poor are those below last iterated poverty line
* MAH, Apr 2010: Cleaning
* URB, feb 2012: Commented out "drop if unit~=2"
**************************************************************************;


/*
This file uses:
	    in/povlines_first_new.dta
        work/hhdata.dta
        work/consump_nom.dta
        work/own.dta
        work/daily.dta
        work/temp_index_reg_tpi.dta
        work/cons_cod.dta
        work/food_cat.dta
        work/cons_real.dta
        work/products.dta
        work/match96_02.dta
        new/conversions.do
        
This file creates (where `pass' is the number of the iteration):
        work/codes_food_basket_flex_it`pass'.dta
        work/price_unit_flex_it`pass'.dta
        work/quan_flex_it`pass'.dta
        work/match_cod_flex_it`pass'.csv
        work/relpoor_it`pass'.dta
        work/povlines_it`pass'.dta
        work/foodshares_it`pass'.dta
        work/nat_pov_flex.csv
        work/rur_pov_flex.csv
        work/strata_pov_flex.csv
        work/spdomain_pov_flex.csv
        work/reg_tpi_pov_flex.csv
*/

**************************************************************************;
* Make a key file that will be used over and over, without change
* in every iteration. This will include the TEMPORALLY deflated consumption
* and various HH data such as hhweight, spdomain, etc.
**************************************************************************;
use "$path/work/conpc.dta";
        sort hhid;
        merg hhid using "$path/work/hhdata.dta";
        tab _merge;
        drop _merge;
        sort reg_tpi survquar;
        merge reg_tpi survquar using "$path/work/temp_index_reg_tpi.dta";
        tab _merge;
        drop _merge;
        
        gen food_pc_tpi = food_pc_nom /tpi_trim;
        gen cons_pc_tpi = food_pc_tpi + nf_pc_nom;
        lab var food_pc_tpi "Temp-adjusted per capita food consumption/day";
        lab var cons_pc_tpi "Temp adjusted total consumption/day";

        tempfile contpi;
        sort hhid;
save `contpi', replace;



*use "$path/in/povlines_first_iterate.dta", clear;

*save "$path/work/povlines_first.dta", replace;

**************************************************************************;
* Now set some information pertaining to the iterations. For now we'll
* manually set the number of iterations. Also specify the percentile
* cutpoint that we will use for defining the relatively poor.
**************************************************************************;
local lastpass=0;
local pass=1;

* Use these two lines to manually specify the number of iterations
* and the cutpoint here in the do file.;
  *local maxit=5;
  *local cutpt=50;

* Use these few lines if you want to specify the number of iterations
* and percentile cutpoint by passing them as parameters on the command
* line, e.g.:   wstata do new/iterate1.do 5 50;
if "`1'"=="" | "`2'"=="" {	;
        di in red "Error: you need to specify number of iterations as first parameter";
        di in red "       and percentile cutpoint as second parameter on command line.";
};
local maxit=`1';
local cutpt=`2';

tempfile cutoff;


while `pass' <= `maxit' {;	

**************************************************************************;
**************************************************************************;
* Pick out the bottom X percent in real consumption per capita 
* (temporally & spatially adjusted), as ranked by the previous iteration.
* The percentile to use is defined by "cutpt". This produces a file that
* has the hhid, and a dummy variable indicating if they were below the
* cutpoint on the last iteration.
**************************************************************************;
**************************************************************************;

/*
* Comment out if IOF 2008/09. (This code included instead of below code in order to replicate published figures 2002/03). ( START ) ;

        if "`pass'"=="1" {	;
              use `contpi', clear;
              sort spdomain;
              merge spdomain using "$path/work/povlines_first.dta";
              tab _m;
              drop _m;
*              gen relpoor`pass'= cons_pc_tpi<=cutoff;
               gen relpoor`pass'= cons_pc_tpi if cons_pc_tpi<=cutoff;
              rename cons_pc_tpi cr_it0;
              sort hhid;
         save "$path/work/relpoor_it`pass'.dta", replace;
*        use "$path/work/cons_real.dta", clear;
*              gen cr_it0=cr2;
        };
        

* Comment out if IOF 2008/09. (This code included instead of below code in order to replicate published figures 2002/03). ( END ) ;
*/



* Comment out if IAF 2002/03. (This code below excluded in order to replicate published figures 2002/03). ( START ) ;

        if "`pass'"=="1" { ;
* Find real income at cut point initially;
        	use "$path/work/cons_real.dta", clear;
			
            gen cr_it0=cr2;
			cap drop one;
            gen one=1;
			
            collapse (p`cutpt') one cr_it`lastpass' [aw=popwt] ;
			
            rename cr_it`lastpass' cutoff;
			
            sort one;
            save `cutoff', replace;
 
* Find relatively poor initially;
            use "$path/work/cons_real.dta", clear;
			
			gen cr_it`lastpass'=cr2;
            cap drop one;
            gen one=1;
			
            sort one;
            merge one using `cutoff';
            tab _merge;
            drop _merge;
			
            drop one;               
            gen relpoor`pass'=cr_it`lastpass'<=cutoff;
            *lab var relpoor`pass' "=1 if in bottom of PCE";
			
            tab relpoor`pass' [aw=popwt];
			
            keep hhid cr_it`lastpass' relpoor`pass' popwt;
            sort hhid;
        save $path/work/relpoor_it`pass'.dta, replace;
        };

* Comment out if IAF 2002/03. (This code below excluded in order to replicate published figures 2002/03). ( END ) ;



        
        if `pass'>1 {	;
* Find real income at cut point in iteration number `pass' ;
                use "$path/work/cons_real_it`lastpass'.dta" , clear;
				
                cap drop one;
                gen one=1;
				
				*CA modified from hhweight*hhsize to popwt;
                collapse (p`cutpt') one cr_it`lastpass' [aw=popwt] ;
                        rename cr_it`lastpass' cutoff;
						
                        sort one;
        save `cutoff', replace;
        
* Find relatively poor in iteration number `pass' ;
                use "$path/work/cons_real_it`lastpass'.dta", clear;
				
                cap drop one;
                gen one=1;
				
                sort one;
                merge one using `cutoff';
                tab _merge;
                drop _merge;
				
                drop one;
                gen relpoor`pass'=cr_it`lastpass'<=cutoff;
                *lab var relpoor`pass' "=1 if in bottom of PCE";
				
                tab relpoor`pass' [aw=popwt];

*CA modified to popwt above and to keep popwt below;

                keep hhid cr_it`lastpass' relpoor`pass' popwt;
                sort hhid;
        save "$path/work/relpoor_it`pass'.dta", replace;
        };



        
**************************************************************************;
* Get the consumption file, and select only those codes that are food,
* using our definition of "food", which includes alcoholic beverages.
**************************************************************************;
        use "$path/work/cons_cod.dta", clear;

*CA modified to merge in work/hhdata.dta for bootstrap;
    sort hhid;
    merge hhid using "$path/work/hhdata.dta";
    tab _m;
    drop _m;

	
/*
                sort product;
                merge product using "$path/work/food_cat.dta";
                tab _merge;
                keep if _merge==3;
                drop _merge;
*/

				* Only food transactions ;
                keep if food_cat;
                sort hhid;

**************************************************************************;
* Merge with file that has temporally AND spatially adjusted consumption
* per capita from the previous iteration, and also identifies those below 
* the cutoff. Then select only those who are below the cutoff.
**************************************************************************;
                merge hhid using "$path/work/relpoor_it`pass'.dta";
                tab _merge;
                drop _merge;

				* Keep only transactions by the poor ;
                keep if relpoor`pass';

**************************************************************************;
* Calculate HH level food shares. Since we're only doing shares here, we can
* work with the expenditures without doing temporal adjustment.
**************************************************************************;
                gen  food_expenditure = cod_hh_nom3;
                *gen  food_expenditure= own_valued + daily_valued + monthly_valued + educ_valued;
                egen tot_food_expen= sum (food_expen), by (hhid) ;
                count if food_expenditure==.;
                count if tot_food_expen==.;

                gen food_share= food_expenditure/tot_food_expen;
                count if food_share==.;
                drop if food_share==.;

                sort hhid product;
                tempfile foodshares;
        save `foodshares', replace;

********************************************************************************;
* Now find the total (economy wise, e.g. not by HH) shares by each product in
* order to select the most important goods in each domain's basket.
********************************************************************************;
                collapse (mean) hhweight spdomain, by (hhid);
                sort hhid ; 

                collapse (sum) hhweight , by(spdomain);

                rename hhweight tothhweight;
                tempfile tothhweight;
                sort spdomain;
        save `tothhweight', replace;

        use `foodshares', clear;
                sort spdomain;
                merge spdomain using `tothhweight';
                tab _merge;
                drop _merge;

                sort spdomain product;

                gen f_share_w`pass'=(food_share*hhweight)/tothhweight;

                collapse (sum) f_share_w`pass', by(spdomain product descript);               

                sort spdomain f_share_w`pass';
                by spdomain: gen cumshr`pass'= sum(f_share_w`pass');

                count if cumshr`pass'<=.075;
                drop if cumshr`pass'<=.075;

                lab var f_share_w`pass' "average food share for the 13 spatial domains";

        save `foodshares', replace;
		
				* Number of spatials domains a food product appears ;
                gen numreg=1;
                collapse (sum) numreg cumshr`pass', by (product descript);

                keep product numreg descript;
                display _N;

                sort product;
				* Include food product labels ;
*                merge product using "$path/work/products.dta";
*                tab _merge;
*                keep if _merge==3;
                keep product descript numreg;  
                sort product;     
                display _N;  

        save "$path/work/codes_food_basket_flex_it`pass'.dta", replace;


**************************************************************************;
**************************************************************************;
* That is pretty much the part equivalent to "100_food_basket_flex.do",
* which figures out the food shares for the relevant reference group. Now
* we figure out the prices with a code stream that is adapted from
* "110_price_unit_flex.do".
**************************************************************************;
**************************************************************************;

**************************************************************************************
* Create sorted data set with daily + own expenditure and the matched codes
**************************************************************************************;


use "$path/in/cons_cod_trans.dta", clear;



*save "$path/work/cons_cod_trans.dta", replace;

*drop value   ;
*drop quantity;

keep hhid product food_cat valuez quantityz unit;

rename valuez    value;
rename quantityz quantity;

*drop count;

drop if quantity==0 ;

        tempfile dd_acsort;
        save    `dd_acsort', replace;


/*
        use "$path/work/daily.dta", clear;
                drop days;
                sort product;
                tempfile dd_acsort;
        save `dd_acsort', replace;
        
        use "$path/work/own.dta", clear;
                keep hhid product valued quantityd unit;
                rename valued value;
                rename quantityd quantity;
        
                *CHECK THE ZEROS IN quantity FOR NOW DELETE;
                drop if quantity==0;
        
                append using `dd_acsort';
*/

                *CA modified to insert work/hhdata.dta for bootstrap;
                sort hhid;
                merge hhid using "$path/work/hhdata.dta";
                tab _m; 
                drop if _m==2;
                drop _m;
                
                sort product;
		gen count=1;

        save `dd_acsort', replace;
        
**************************************************************************;
* Merge the basket codes with the dd  and own data sets.
* Drop all codes not a part of the flexible food basket
**************************************************************************;
                merge product using "$path/work/codes_food_basket_flex_it`pass'.dta";
        
                tab _merge;
                drop if _merge~=3;
                drop _merge;

**************************************************************************************
* Drop observations where product code, quantity or value information is unavailable
**************************************************************************************;
                drop if product==. | value==. | quantity==.  ;
        
**************************************************************************************
* Convert non-KG quantities (units, liters) into kilograms
**************************************************************************************;
*do "$path/new/110a_conversions.do"

********************************************************************
* There remain a few difficult to interpret observations such as liters
* of fish and liters of pasta. These are dropped.
********************************************************************;
*                $MZ drop if unit~=2;
        
**************************************************************************;
* Bring in the spdomain and reg_tpi variables, and also the information on
* relatively poor households.
**************************************************************************;
                preserve;
						* Temporally adjusted expenditure ;
                        use `contpi', clear;
                                keep hhid hhweight spdomain reg_tpi survquar tpi_trim cons_pc_tpi ;
                                sort hhid;
                                tempfile hhd2;
                        save `hhd2', replace;
                restore;

				compress;
                sort hhid;
                merge hhid using `hhd2';
                tab _merge;
                drop _merge;

                sort hhid;
                merge hhid using "$path/work/relpoor_it`pass'.dta";
                tab _merge;
                drop _merge;
				
                * Keep nominal food transactions by poor people ;
                keep if relpoor`pass';

                drop if product==.;
				
				* Temporally deflate transaction values ;
                gen value_r=value/tpi_trim;

**************************************************************************;
* Toss out the bottom 5% and top 5% of the HH-LEVEL prices per kg in
* each spdomain & product combination. This should eliminate outliers
* that may have an undue influence on the price calculation. 
**************************************************************************;
                gen hhppkg=value_r/quantity;
                egen lower5=pctile(hhppkg), p(5)  by(spdomain product);
                egen upper5=pctile(hhppkg), p(95) by(spdomain product);
                keep if hhppkg>=lower5 & hhppkg<=upper5;

*********************************************************************
* Note that we do prices in three ways. First, by summing quantity and value 
* This average price price_uw is thus quantity/value weighted. Second, we
* calculate the price and take simple means for a transaction weighted
* price, price_ut. Last we take the median, price_um. But in the end
* we only use price_unitw
*********************************************************************;
                gen price_ut`pass'=value_r/(quantity*1000);
                gen price_um`pass'=price_ut;
                collapse (sum) 
                        quantity value_r count bswt (mean) price_ut (median) price_um [aw=hhweight], 
                        by(spdomain product);

                *Generate weighted price per gram ;
                gen price_uw`pass'=value_r/(quantity*1000);
                drop value_r quantity;

                sort spdomain product;

                lab var price_ut`pass' "Average of calculated prices - transaction weighted";
                lab var price_um`pass' "Median of prices";
                lab var price_uw`pass' "Value share weighted mean prices";

* Get an idea of the difference between the price measures;
                gen ratiotw`pass'=price_ut`pass'/price_uw`pass';
                gen ratiomw`pass'=price_um`pass'/price_uw`pass';

                sum ratiotw`pass' ratiomw`pass';

                sort product;
                merge product using "$path/work/codes_food_basket_flex_it`pass'.dta";
                tab _m;
                count if _merge~=3;
                drop if _merge~=3;
                drop _merge;

                sort product spdomain;
        save "$path/work/price_unit_flex_it`pass'.dta", replace;


**************************************************************************;
**************************************************************************;
* That concludes the prices part. Now we move to calculating the food
* poverty lines, which draws code from "120_povline_flex.do" with very few
* changes:
* - The changes facilitate accumulating vectors
*   of intermediate results across iterations, rather than generating a
*   bunch of new files.
**************************************************************************;
**************************************************************************;

**************************************************************************;
* Use the file with the food basket (`foodshares'), which is in shares. 
* Then merge it with the prices file, and then with the calories file.
* Along the way, drop those observations where we have no price information
* or no calorie information, but list them out.
**************************************************************************;
        use `foodshares', clear;
                sort product spdomain;
                merge product spdomain using "$path/work/price_unit_flex_it`pass'.dta";
        
                tab _merge;
                list product spdomain descript if _merge==1;
        
                drop if _merge ~=3;
                drop _merge;
                sort product;
        
                merge product using "$path/work/calperg.dta";
                tab _merge;
				
                * This tells where we are lacking calorie info or are lacking quantity info due to 
                * missing price info above;
                list product spdomain descript if _merge==1;
        
                drop if _merge~=3;
                drop _merge;
                sort spdomain f_share_w`pass';
                
                *CA modified to change count bswt;
                by spdomain: count if round(bswt)<10;

				sum bswt;
				
                drop if round(bswt) < 10;
				
				* Total food share in spatial domain ;
                by spdomain: egen baskshr=sum(f_share_w`pass');
				* Cumulated food share in spatial domain ;
                by spdomain: gen  cumshr =sum(f_share_w`pass');

                drop if cumshr<=baskshr-.9;
        
                drop baskshr;
                by spdomain: egen baskshr=sum(f_share_w`pass');
                tabstat baskshr , by(spdomain) st(n mean sd min max);
				
				* How many grams in 1 MT exp on food item ;
				gen quan`pass'=f_share_w`pass'/price_uw`pass';
				* How many calories in 1 MT exp on food item ;
                gen cal_ir`pass'=quan`pass'*calperg;
				* how many calories in 1 MT exp in food basket ;
                by spdomain: egen calreg=sum(cal_ir);
        
                sort spdomain;
                merge spdomain using "$path/work/calpp.dta";
                tab _merge;
                drop _merge;
				
		        * get the expansion factor to hit 95% of calorie requirements ;
                gen ratio=.95*calpp/calreg;
        
                replace quan`pass'=quan`pass'*ratio;
                replace cal_ir`pass'=quan`pass'*calperg;
        
                sort spdomain product;
                by spdomain: egen chkcal=sum(cal_ir`pass');
                replace chkcal=chkcal/.95-calpp ;
				
                tabstat chkcal , by(spdomain) st(n mean sd min max);
        
                gen val_ir`pass'=quan`pass'*price_uw`pass';
        
                by spdomain: egen povline_f_flex90_`pass'=sum(val_ir`pass');
                replace povline_f=povline_f_flex90_`pass'/.9;

                *drop product96;
keep product spdomain quan`pass'  price_uw`pass' val_ir`pass' povline_f_flex90_`pass' calpp calperg;
                    save "$path/work/quan_flex_it`pass'.dta", replace;

        
                collapse (mean) povline_f_flex90_`pass', by (spdomain);
				
                keep spdomain povline_f_flex90_`pass';
                sort spdomain;
        
        save "$path/work/povline_food_flex_it`pass'.dta", replace;
        

**************************************************************************;
**************************************************************************;
* Now comes the part that draws the non-food and total poverty lines,
* and generates estimates of poverty measures. This is drawn from 
* "130_povmeas_flex.do" with a few changes.
**************************************************************************;
**************************************************************************;

**************************************************************************
* Calculate non-food expenditure for HH around the food poverty line
*
* Develop a discrete triangular weighted distribution. This gives a
* weight of  1 to HH at +/- 18-20% from food poverty line, and
* weight of  2 to HH at +/- 16-18% from food poverty line, and ...
* weight of 10 to HH at +/-  0- 2% from food poverty line.
* This weight is called triwt below.
**************************************************************************;
        use `contpi', clear;
                sort spdomain;
                merge spdomain using "$path/work/povline_food_flex_it`pass'.dta";
                tab _merge;
                drop _merge;

                gen triwt=0 ;
		replace triwt = 11 - round(50*abs(cons_pc_tpi/povline_f_flex90_`pass'-1)+0.5)
                if abs(cons_pc_tpi/povline_f_flex90_`pass'-1)<=0.2;
				
				* Nearness to poverty line and population weights ;
                gen tripopwt=triwt*hhweight*hhsize;
				
                preserve;
                        collapse (mean) nf_pc_nom [aw=tripopwt] ,
                                by(spdomain);
                        rename nf_pc_nom povline_nf_flex`pass';
                        lab var povline_nf_flex`pass' "Nonfood poverty line. Flexible bundle";
                        tempfile znf;
                        sort spdomain;
                        save `znf', replace;
						
                restore;
                
                sort spdomain;
                merge spdomain using `znf';
                tab _merge;
                drop _merge;

**************************************************************************
* Poverty line is the sum of the food and non-food poverty lines
**************************************************************************;
                gen povline_flex`pass'=povline_f_flex90_`pass' + povline_nf_flex`pass';

keep spdomain povline_flex`pass';
                sort spdomain;
        save "$path/work/povlines_it`pass'.dta", replace;

**************************************************************************;
* Create spatial price index, based on the total poverty line, with
* adjustment so that mean (and total) nominal consumption equals
* mean (and total) spatially deflated consumption.
*
* Choose arbitrary strata to be the base at first: we just use the first stratum.
**************************************************************************;
        use `contpi', clear;
                sort spdomain;
                merge spdomain using "$path/work/povlines_it`pass'.dta";
                tab _merge;
                drop _merge;

                gen cr= cons_pc_tpi ;
                gen linpob`pass'=povline_flex`pass';

                qui sum linpob`pass' if spdomain==1, meanonly;
                global spi_base=r(mean);
                gen spi`pass'=linpob`pass'/$spi_base;
                gen cr_it`pass'=cr/spi`pass';

                qui sum cr [aw=hhweight*hhsize];
                global sumcr=r(sum);
                qui sum cr_it`pass' [aw=hhweight*hhsize];
                global sumcr2=r(sum);
                replace spi`pass'=spi`pass'*$sumcr2/$sumcr;
                gen linpobr`pass'=linpob`pass'/spi`pass';

                replace cr_it`pass'=cr/spi`pass';
                su cr cr_it`pass' linpob`pass' linpobr`pass' [aw=hhweight*hhsize];
                lab var cr "Temporally-adjusted cons pc";
                lab var cr_it`pass' "Spatially & temporally adjusted cons pc";
                lab var linpob`pass' "Poverty line";
                lab var linpobr`pass' "Real poverty line";
                lab var spi`pass' "Spatial price index";

                gen linpob=linpob`pass';

**************************************************************************
* calculate poverty measures with the flexible food bundle
**************************************************************************;
                gen h=100 if cr_it`pass'<=linpobr`pass' & linpobr`pass'~=. & cr_it`pass'~=.;
                replace  h   = 0 if cr_it`pass' > linpobr`pass' & linpobr`pass'~=. & cr_it`pass'~=.;
                gen      pg  = ((linpobr`pass' - cr_it`pass' )/linpobr`pass') *100;
                replace  pg  = 0             if h==0;
                gen      spg = ((( linpobr`pass' - cr_it`pass' )/ linpobr`pass' )^2)*100;
                replace  spg = 0             if h==0;

                gen h_flex`pass'  =h;
                gen pg_flex`pass' =pg;
                gen spg_flex`pass'=spg;
                
                lab var h_flex`pass'   "Poverty headcount. Flexible bundle";
                lab var pg_flex`pass'  "Poverty gap. Flexible bundle";
                lab var spg_flex`pass' "Squared poverty gap. Flexible bundle";

                gen popwt=hhsize*hhweight;

			* Stata 10.1 syntax ;
			svyset , clear;
			svyset [pweight=popwt] , str(strata) psu(psu);

                svy: mean h_flex`pass' pg_flex`pass' spg_flex`pass';
                svy: mean h_flex`pass' pg_flex`pass' spg_flex`pass' , over(rural);
                svy: mean h_flex`pass' pg_flex`pass' spg_flex`pass' , over(strata);
                svy: mean h_flex`pass' pg_flex`pass' spg_flex`pass' , over(strata rural);
                svy: mean h_flex`pass' pg_flex`pass' spg_flex`pass' , over(spdomain);

*preserve;
keep hhid popwt cr_it`pass' h_flex`pass' pg_flex`pass' spg_flex`pass' rural news reg_tpi strata spdomain;
                compress;
                sort hhid;
        save "$path/work/cons_real_it`pass'.dta" , replace;
*restore;
		
		* New cutoff point (percentile) to use in next iteration is equal to the poverty ;
		* rate in this iteration ;
		
		
		sum h_flex`pass' [aw=popwt] ;
		
		* Comment out next line for IAF 2002/03 in order to replicate official figures ( START );

		* URB: In this case, we just use the poorest 50% as there are too few actually poor to calculate the bundle and prices..;
		local cutpt= $tpi_bottom;
*		local cutpt= round(r(mean));
		* Comment out next line for IAF 2002/03 in order to replicate official figures ( END );

*       save foodshares tempfile to disk;
        use `foodshares', clear;
        save "$path/work/foodshares_it`pass'.dta", replace;

        local lastpass = `pass';
        local pass = `pass' + 1;
        
};

**************************************************************************
* Send results to one big csv-file
**************************************************************************;
use "$path/work/cons_real_it`lastpass'.dta", clear ;
        gen dum=1;
        collapse (mean) dum h_flex`lastpass' pg_flex`lastpass' spg_flex`lastpass' [aw=popwt];
gen geo="National";
gen geono=dum;
tempfile nat;
save `nat';
        
use "$path/work/cons_real_it`lastpass'.dta", clear ;
        collapse (mean) h_flex`lastpass' pg_flex`lastpass' spg_flex`lastpass' [aw=popwt], by(rural);
gen geo="Rural/Urban";
gen geono=rural;
tempfile rur;
save `rur';

use "$path/work/cons_real_it`lastpass'.dta", clear ;
        collapse (mean) h_flex`lastpass' pg_flex`lastpass' spg_flex`lastpass' [aw=popwt], by(news);
gen geo="North/Center/South";
gen geono=news;
tempfile new;
save `new';

use "$path/work/cons_real_it`lastpass'.dta", clear ;
        collapse (mean) h_flex`lastpass' pg_flex`lastpass' spg_flex`lastpass' [aw=popwt], by(reg_tpi);
gen geo="TPI - 6 regions";
gen geono=reg_tpi;
tempfile rtp;
save `rtp';

use "$path/work/cons_real_it`lastpass'.dta", clear ;
        collapse (mean) h_flex`lastpass' pg_flex`lastpass' spg_flex`lastpass' [aw=popwt], by(strata);
gen geo="Provinces";
gen geono=strata;
tempfile str;
save `str';

use "$path/work/cons_real_it`lastpass'.dta", clear ;
        collapse (mean) h_flex`lastpass' pg_flex`lastpass' spg_flex`lastpass' [aw=popwt], by(spdomain);
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

outsheet geo geono h_flex`lastpass' pg_flex`lastpass' spg_flex`lastpass' dum rural news reg_tpi strata spdomain using "$path/work/poverty_flexBask.csv", replace c;

**************************************************************************
* Convergence graph (based on 5 iterations)
**************************************************************************;
#delimit cr

clear
set obs 1
gen iteration=.
tempfile converg
save `converg'

forvalues X = 1/5 {
	use "$path/work/cons_real_it`X'.dta", clear
	collapse (mean) h_flex`X' pg_flex`X' spg_flex`X' [aw=popwt], by(strata)
	rename h_flex`X' h_flex
	rename pg_flex`X' pg_flex
	rename spg_flex`X' spg_flex
	gen iteration=`X'
	order iteration
	*sum
	if `X' != 1	{
		append using `converg'
			}
	save `converg', replace
	}

use `converg', clear
sum

twoway (connected h_flex iteration), by(, title(Convergence graph: Poverty rate. %) subtitle(After iterative procedure)) by(strata)
graph export "$path/work/converge_pov_rate.tif", replace

sort strata iteration

for var h_flex pg_flex spg_flex: replace X = round(X,0.01)

list strata iteration h_flex pg_flex spg_flex
	
#delimit ;


**************************************************************************
* 140_iterate.do	(end)
**************************************************************************;


cap log close;
