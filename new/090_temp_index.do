*global path "C:/Users/Templeton/Desktop/GAPP/GAPP-UGANDA-HARUNA"
clear all
set mem 999m

cap log close
log using "$path/rep/090_temp_index.log", replace
clear
set more off


**************************************************************************
* 090_temp_index.do     (start)
************************************************************************** 

*do "$path/new/010_initial.do" 

**************************************************************************
* Program to compute the temporal price index (intra-survey)
* 
* The index is based on 6 regions (North/Center/South by rural/urban) 
* and four quarters. For IAF 2002/03 (t=t1) it is based on the same 9
* commodities used for the analysis of the 1996 IAF (t=t0), 
* except that we have to go to 8 commodities because the 2002-03 survey 
* does not distinguish between large and small groundnuts, which were 
* separate items in the old index. For IOF 2008/09 (t=t2) we expand the
* the food basket to include the 15 most important food products among
* the poorest.
*
* The commodity weights for the items vary by the 6 regions, and are 
* calculated from the observations in the IAF2002, using the relatively 
* poor households (below median nominal consumption per capita).
*
* The unit values (prices) calculated here are also based on the prices 
* paid by the relatively poor, using the same definition.
*
* K Simler, Sep 2003
* CA
* MAH, April 2010
* URB, Feb 2013 (automatization to any number of n_tpi's)
************************************************************************** 

/*
This file uses:
        work/own.dta
        work/receipts.dta
        work/daily.dta
        work/hhdata
        work/cons_cat.dta

This file creates:
        work/tpi_unit_val_quarterly.dta
        work/tpi_unit_val_monthly.dta
        work/tpi_news_share.dta
        work/tpi_reg_tpi_share.dta
        work/temp_index_news.dta
        work/temp_index_reg_tpi.dta
*/      


**************************************************************************
* Either the products used for intertemporal price index is specified
* explicitly, or they are automatically found as the the n_tpi products
* with the highest weighted expenditure shares among the $bottom % poorest
* part of the population
************************************************************************** 

* Generating the n_tpi most important food items for the poorest $bottom %  
**************************************************************************
* Find the n_tpi most important food products among the lowest $bottom %
* (start)
************************************************************************** 

*------------------------------------------------------------------------*
* Population weights for each HH
*------------------------------------------------------------------------* 
use "$path/work/hhdata.dta", clear 
keep hhid hhweight hhsize 
gen popwt = hhweight*hhsize 
lab var popwt "Population weights = hhsize X hhweight" 
sort hhid 
tempfile popwt 
save `popwt', replace 
sum 

*------------------------------------------------------------------------*
* Make list of all consumed products
*------------------------------------------------------------------------* 
*use "$path/in/cons_cod.dta", clear 
*save "$path/work/cons_cod.dta", replace 
use "$path/work/cons_cod.dta", clear 
keep product descript 

collapse product, by(descript) 

sort product 
tempfile descript 
save `descript', replace 
sum 

*------------------------------------------------------------------------*
* Find the poorest part of the population
*------------------------------------------------------------------------* 
use "$path/work/cons_cod.dta", clear 
*use
*"$path/work/cons_cod.dta", clear 

********************************************check the COICOP categories to create the variable prod_cat, for the moment it is equal to food_cat****** 

keep hhid prod_cat product cod_hh_nom 
sort hhid 

sum 

merge hhid using `popwt' 

sum 

drop _merge 

preserve 


collapse (sum) cod_hh_nom (mean) popwt hhweight hhsize, by(hhid) 

gen cod_pc_nom = cod_hh_nom/hhsize 

        sum cod_pc_nom [aw=popwt] , detail 
        global medcpc_= r(p$tpi_bottom) 
        gen bottom_ = cod_pc_nom <= $medcpc_ 

sum [aw=popwt] 
sum [aw=hhweight] 
sum 

keep if bottom_==1 

keep hhid 
sort hhid 

tempfile hhid 
save `hhid' 

restore 
sort hhid 

sum 

merge hhid using `hhid' 

tab _m 

keep if _m==3 

sum 

*------------------------------------------------------------------------*
* Keep only food product expenditure by the poor. Calculate food product
* share of total food expenditure by the poor
*------------------------------------------------------------------------* 
keep if prod_cat==1 
sum 

sort product 

*preserve 

collapse (sum) cod_hh_nom [aw=hhweight], by(product) 

sort cod 

egen total=sum(cod_hh_nom) 

gen sh=100*cod_hh_nom/total 

*------------------------------------------------------------------------*
* Include product labels
*------------------------------------------------------------------------* 
sum 

sort product 
merge product using `descript' 
tab _merge 
keep if _merge==1 | _merge==3 
drop _merge 

sort sh 

*list 

list in -$product_tpi_n/-1 

list product descript in -$product_tpi_n/-1 
*restore 

*------------------------------------------------------------------------*
* Keep the required number of most important food products
*------------------------------------------------------------------------* 
keep in -$product_tpi_n/-1 

list 

gen product_tpi=1 
keep product product_tpi 
list 

sort product 
tempfile product_tpi 

save `product_tpi', replace 

sum 


clear 

**************************************************************************
* Find the n_tpi most important food products among the lowest $bottom %
* (end)
************************************************************************** 




************************************************************************** 
* First, need to calculate the average prices for the food items, by 
* strata and quarter. For this, we are using the "unit values"
* (value/quantity) for the observations in the consumption questionnaires,
* including daily, own and receipts-in-kind.
*
* The unit values are constructed as sum(value)/sum(quantity), which effectively
* weights them by the quantity and value of the transaction. Sampling
* weights are also used.
*
* Get the own consumption file, and limit analysis to the observations
* in KGs where both value and quantity are available.
************************************************************************** 


use "$path/work/cons_cod.dta" 
drop quantityd 
rename quantity quantityd 

*use "$path/work/cons_cod.dta" 

keep if prod_cat==1 

drop if quantityd==0 | quantityd==. 

*keep if quantityd!=. & cod_hh_nom2!=. 


sum 
sort product 
merge product using `product_tpi' 
tab _merge 
drop _merge 

keep if $product_tpi 


*        replace valued_ac=0 if valued_ac==. 
*        replace quantityd_ac=0 if quantityd_ac==. 

        gen valued_tot=cod_hh_nom 
        gen quantityd_tot=quantityd 
*		replace quantityd_tot=0 if (valued_tot>0 & valued_tot<.) & quantityd_tot==. 

        keep if quantityd_tot!=. & valued_tot!=. 
		
collapse (sum) valued_tot quantityd_tot, by(hhid product) 
		
sort hhid 

tempfile acredd 
save `acredd' , replace 

sum 






/*
************************************************************************** 
* Create a data set with an empty 1 observation. Used to avoid empty data
* sets when the survey do not have the Mozambican set up
************************************************************************** 
use "$path/work/own.dta" 

preserve 
keep in 1 
drop unit valued quantityd 
gen unit=2 
gen valued=0 
gen quantityd=0 
tempfile 1obs 
save `1obs' 
restore 

************************************************************************** 
* Own consumption
************************************************************************** 
sum 
sort product 
merge product using `product_tpi' 
tab _merge 
drop _merge 

keep if $product_tpi 



* Comment out below if IAF 2002/03 ( START )  

rename quantityd quantity 
do "$path/new/110a_conversions.do" 
rename quantity quantityd 

* Comment out below if IAF 2002/03 ( END )  



        keep if unit==2 & quantityd!=. & valued!=. 
        collapse (sum) valued quantityd , by(hhid product) 
        rename valued valued_ac 
        rename quantityd quantityd_ac 
        compress 
        sort hhid product 
        tempfile ac 
save `ac', replace 

************************************************************************** 
* Now do a similar thing with receipts-in-kind file.
************************************************************************** 
use "$path/work/receipts.dta" 

sum 
sort product 
merge product using `product_tpi' 
tab _merge 
drop _merge 



keep if $product_tpi 
append using `1obs' 



* Comment out below if IAF 2002/03 ( START )  

rename quantityd quantity 
do "$path/new/110a_conversions.do" 
rename quantity quantityd 

* Comment out below if IAF 2002/03 ( END )  



        keep if unit==2 & quantityd!=. & valued!=. 
        collapse (sum) valued quantityd , by(hhid product) 
        rename valued valued_re 
        rename quantityd quantityd_re 
        compress 
        sort hhid product 
        tempfile re 
save `re', replace 

************************************************************************** 
* And also with the daily expenditure file.
************************************************************************** 
use "$path/work/daily.dta" 

sum 
sort product 
merge product using `product_tpi' 
tab _merge 
drop _merge 

keep if $product_tpi 



* Comment out below if IAF 2002/03 ( START )  

*rename quantityd quantity 
do "$path/new/110a_conversions.do" 
*rename quantity quantityd 

* Comment out below if IAF 2002/03 ( END )  



        collapse (sum) value quantity days , 
                by(hhid product unit) 

        gen valued=value/7 if days<=7 
        replace valued=value/days if days>7 & days<. 
        gen quantityd=quantity/7 if days<=7 
        replace quantityd=quantity/days if days>7 & days<. 

        keep if unit==2 & quantityd!=. & valued!=. 
        collapse (sum) valued quantityd , by(hhid product) 

        rename valued valued_dd 
        rename quantityd quantityd_dd 
        compress 
        sort hhid product 
        tempfile dd 
save `dd', replace 




************************************************************************** 
* Merge the three components (own, daily, receipts) together at the HH/product level, 
* then aggregate to the regional level, using the sample weights (hhweight).
* We DON'T want to weight by "hhsize" because the quantity and value are
* already for the household (i.e., other things equal, larger households
* are buying larger quantities, and therefore already getting more weight).
* Then calculate sum(val)/sum(quantity) to get the quantity weighted mean
* unit value in each strata in each quarter.
************************************************************************** 
use `ac' 
        sort hhid product 
        merge hhid product using `re' 
        tab _m 
        drop _m 
        
        sort hhid product 
        merge hhid product using `dd' 
        tab _m 
        drop _m 
        
        replace valued_ac=0 if valued_ac==. 
        replace valued_re=0 if valued_re==. 
        replace valued_dd=0 if valued_dd==. 
        replace quantityd_ac=0 if quantityd_ac==. 
        replace quantityd_re=0 if quantityd_re==. 
        replace quantityd_dd=0 if quantityd_dd==. 

        gen valued_tot=valued_ac+valued_re+valued_dd 
        gen quantityd_tot=quantityd_ac+quantityd_re+quantityd_dd 

        sort hhid 

        tempfile acredd 
save `acredd' , replace 
*/



use "$path/work/hhdata.dta" 
        keep strata hhid hhweight hhsize rural survmon survquar news spdomain reg_tpi 

        sort hhid 
        tempfile hhd 
save `hhd' , replace 

use `acredd', clear 
        merge hhid using `hhd' 
        tab _merge 
        drop _merge 
        
        tab survquar , miss 
        
        tab survmon survquar, miss 

        compress 
        sort hhid 
save `acredd', replace 

sum 



************************************************************************** 
* Need to merge with the file that has nominal consumption per household,
* and compute nominal consumption per capita from that, so that we can
* choose the relatively poor (i.e., below median nominal consumption per
* capita).
************************************************************************** 
use "$path/work/conpc.dta", clear 
keep hhid cons_hh_nom 
*use "$path/in/cons_cat.dta"  
*save "$path/work/cons_cat.dta", replace  
*use "$path/work/cons_cat.dta"  

*CA modified to merge in hhdata for bootstrap 
       sort hhid 
        merge hhid using "$path/work/hhdata.dta" 
	  tab _m  
	  drop _m 

        collapse (mean) cons_hh_nom hhsize hhweight , by(hhid) 

        gen cpc=cons_hh_nom/hhsize 
        sum cpc [aw=hhsize*hhweight] , detail 
        global medcpc=r(p$tpi_bottom) 
        gen bottom_tpi=cpc<=$medcpc 
        keep hhid bottom_tpi 
        sort hhid 
        tempfile bottom_tpi 
save `bottom_tpi', replace 
sum 

use `acredd'  
        merge hhid using `bottom_tpi' 
        tab _merge 
        drop _merge 
        keep if bottom_tpi 
sum 



* Drop one HH with extremely high quantity and low value in IAF 2002/03 (t=t1)  
*        drop if hhid==263001 

        preserve 
                collapse (sum) valued_tot quantityd_tot [aw=hhweight] , by(reg_tpi news product survmon) 
                        drop if product==. 
                        gen ppkg=valued_tot/quantityd_tot 
	                lab var ppkg "Unit value per kg" 
                        sort reg_tpi product  
                        compress 
                        tempfile uvm 
                save `uvm', replace 
                save "$path/work/tpi_unit_val_monthly.dta", replace 
        restore 

        preserve 
                collapse (sum) valued_tot quantityd_tot [aw=hhweight] ,  by(reg_tpi news product survquar) 
                               
                        drop if product==. 
                        gen ppkg=valued_tot/quantityd_tot 

                        sort reg_tpi product survquar 
                        list in  1/3 
                        list in -3/-1 

                        tempfile uvq 
                save "$path/work/tpi_unit_val_quarterly.dta", replace 
                save `uvq', replace 
        restore 
        
************************************************************************** 
* Toss out the bottom 5% and top 5% of the HH-LEVEL prices per kg in
* each reg_tpi & product combination. This should eliminate outliers that
* may have an undue influence on the price calculation. Then use sample
* weighting PLUS quantity weighting on those HH-level observations.
************************************************************************** 
        preserve 
                gen hhppkg=valued_tot/quantityd_tot 
                egen lower5=pctile(hhppkg), p(5) by(reg_tpi product) 
                egen upper5=pctile(hhppkg), p(95) by(reg_tpi product) 
                keep if hhppkg>=lower5 & hhppkg<=upper5 
                
                gen hhqtywt=hhweight*quantityd_tot 
                
                collapse (sum) valued_tot quantityd_tot [aw=hhqtywt] ,  by(reg_tpi news product survquar) 
                               
                        drop if product==. 
                        gen ppkg_trim=valued_tot/quantityd_tot 
                        lab var ppkg_trim "90% trimmed unit value per kg" 

                        sort reg_tpi product survquar 
                        list , nol 
                        tempfile uvq2 
                        keep reg_tpi product survquar ppkg_trim 
                save `uvq2', replace 
                
                use `uvq'  
                        merge reg_tpi product survquar using `uvq2' 
                        tab _merge 
                        drop _merge 
                save `uvq', replace 
                save "$path/work/tpi_unit_val_quarterly.dta", replace 
        restore 



************************************************************************** 
* Now calculate the weights for the temporal price index. The weights
* will be based on the bottom 50% of the national nominal consumption
* per capita (see below). We let the weights vary by strata (3 regions X rural/urban).
*
* First, make a small file that has the total nominal HH daily consumption,
* to use as our denominator. We cannot simply use the `bottom_tpi' file that
* was created earlier because we will need some other variables from
* the cons_cat.dta file.
************************************************************************** 
use "$path/work/conpc.dta", clear 
keep hhid cons_hh_nom 
*use "$path/in/cons_cat.dta", clear  

*CA modified to merge in hhdata for bootstrap 
       sort hhid 
        merge hhid using "$path/work/hhdata.dta" 
	  tab _m 

        collapse (mean) cons_hh_nom hhsize strata hhweight rural news survquar reg_tpi, by(hhid) 
               
        lab var cons_hh_nom "Nominal daily HH consumption" 
        rename hhsize   cc_hhs 
        rename strata   cc_reg 
        rename hhweight cc_hhw 
        rename rural    cc_rur 
        rename news     cc_news 
        rename survquar cc_qua 
        rename reg_tpi  cc_reg_tpi 
        sort hhid 
        tempfile thhcons 
save `thhcons', replace 

************************************************************************** 
* Merge the file with consumption on the food products with HH consumption file,
* then use "fillin" to take care of cases where a household did not
* consume all n_tpi commodities. Note that we need to do the merge
* first because there are some households that are not in `acredd' at
* all, because they did not consume *any* of the n_tpi items. Then replace
* missing values in the "filled in" observations with the relevant values 
* for that household.
************************************************************************** 
use `acredd' 
        cap drop _merge 
        drop if product==. 

        merge hhid using `thhcons' 
        tab _merge 
        for var valued_tot quantityd_tot : replace X=0 if _merge==2 
		/*
        for var valued_ac quantityd_ac valued_re quantityd_re valued_dd quantityd_dd 
                valued_tot quantityd_tot : replace X=0 if _merge==2 
				*/

        replace hhsize  =cc_hhs	    if _merge==2 
        replace strata  =cc_reg	    if _merge==2 
        replace hhweight=cc_hhw	    if _merge==2 
        replace rural   =cc_rur	    if _merge==2 
        replace news    =cc_news	if _merge==2 
        replace survquar=cc_qua	    if _merge==2 
        replace reg_tpi =cc_reg_tpi	if _merge==2 

        drop _merge cc_*  
        
        fillin hhid product 
        replace valued_tot=0 if _fillin 
        
                #delimit ;
        
                for var quantityd_tot 
                strata rural hhweight hhsize survquar survmon news reg_tpi cons_hh_nom :
                egen tmp=mean(X), by(hhid) \
                replace X=tmp if _fillin \
                drop tmp;
        
         #delimit cr

************************************************************************** 
* Now calculate the shares, and then the mean shares in each strata, 
* using hhweight*hhsize weighting. 
* Note that we are not doing quantity weighting now for the shares.
************************************************************************** 
        gen share = valued_tot/cons_hh_nom  
        
        
        

        gen popwt = hhsize*hhweight 
        lab var share "HH share in total consumption" 
        lab var popwt "Population weight: hhsize*hhweight" 

************************************************************************** 
* Select the bottom 50% (weighted) of the distribution of nominal per 
* capita consumption.
************************************************************************** 
        gen cpc=cons_hh_nom/hhsize 
        sum cpc [aw=hhweight] , detail 
        global medcpc=r(p$tpi_bottom) 
* MAH   sum  codebook hhid 
        keep if cpc<=$medcpc 
sum 

                collapse (mean) share (median) medshare=share [aw=popwt] ,    by(reg_tpi product) 
                     
                egen sumsh=sum(share) , by(reg_tpi) 
                replace share=share/sumsh 
                drop sumsh 
                egen sumsh=sum(medshare) , by(reg_tpi) 
                replace medshare=medshare/sumsh 
                drop sumsh 
                lab var share "Reg 6: Mean HH share of total consumption" 
                lab var medshare "Reg 6: Median HH share of total consumption" 
                sort reg_tpi product 
                save "$path/work/tpi_reg_tpi_share.dta", replace 
                tempfile tempwt6 
                save `tempwt6', replace 

use `uvq', clear 
        sort reg_tpi product 
save , replace 

use `tempwt6' 
        merge reg_tpi product using `uvq' 
        tab _merge 

        gen tpi1     =ppkg     *share 
        gen tpi1_trim=ppkg_trim*share 

sum 

keep if survquar!=. 
sum 
list in  1/3 
list in -3/-1 
        
************************************************************************** 
* Find TPI level and indexes for non-trimmed and trimmed prices
************************************************************************** 

* Not trimmed  
        collapse (sum) tpi1 tpi1_trim  , by(reg_tpi survquar) 
        #delimit ;
		for num 1/$n_tpi :
                        sum tpi1 if reg_tpi==X & survquar==2 , meanonly \
                        sum tpi1 if reg_tpi==X & survquar==4 , meanonly \
                        global baseX=r(mean);
                lab var tpi1 "Temporal price index before normalization";

				foreach v of numlist 1/$n_tpi { ;
					if `v'==1 { ;
						gen tpi=tpi1/${base`v'} if reg_tpi==`v' ;
					} ;
					if `v'>1 { ;
						replace tpi=tpi1/${base`v'} if reg_tpi==`v' ;
					} ;
				} ;
        #delimit cr						
				
                *gen     tpi=tpi1/$base1 if reg_tpi==1 
                *replace tpi=tpi1/$base2 if reg_tpi==2 
                *replace tpi=tpi1/$base3 if reg_tpi==3 
                *replace tpi=tpi1/$base4 if reg_tpi==4 
                *replace tpi=tpi1/$base5 if reg_tpi==5 
                *replace tpi=tpi1/$base6 if reg_tpi==6 
				
				
                lab var tpi "Temporal price index (Q4=1)" 

* Trimmed  
        #delimit ;
                for num 1/$n_tpi :
                        sum tpi1_trim if reg_tpi==X & survquar==2 , meanonly \
                        sum tpi1_trim if reg_tpi==X & survquar==4 , meanonly \
                        global baseX=r(mean) ;
                lab var tpi1_trim "Six regions: TRIMMED Temporal price index before normalization" ;

				foreach v of numlist 1/$n_tpi {  ;
					if `v'==1 {;  
						gen tpi_trim=tpi1_trim/${base`v'} if reg_tpi==`v';  
					};  
					if `v'>1 {;  
						replace tpi_trim=tpi1_trim/${base`v'} if reg_tpi==`v';  
					};  
				};  
	 #delimit cr		

                lab var tpi_trim "TRIMMED Temporal price index (Q4=1)" 

                sort reg_tpi survquar 
            drop if reg_tpi<1 | reg_tpi>$n_tpi 


gen tpi_diff = tpi - tpi_trim 
lab var tpi_diff "TPI difference btw trimmed/untrimmed" 

twoway (connected tpi_trim survquar),yline(1) by(, title("TPI: Trimmed"))
by(reg_tpi) sav("$path/work/reg_tpi-tpi_trim", replace) 
graph export "$path/work/reg_tpi-tpi_trim.tif", replace 


list reg_tpi survquar tpi tpi_trim tpi_diff 

                sort reg_tpi survquar 

keep reg_tpi survquar tpi_trim 

save "$path/work/temp_index_reg_tpi.dta", replace                        



**************************************************************************
* 090_temp_index.do     (end)
************************************************************************** 


cap log close 
