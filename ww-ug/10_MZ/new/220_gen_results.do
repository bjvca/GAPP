*global path "C:\user\gapp"
clear all
set mem 999m

cap log close
log using "$path/rep/220_gen_results.log", text replace
set more off
#delimit ;

*****************************************************************
* 220_gen_results.do		(start)
*
* Do file to generate poverty and inequality results at various
* levels of aggregation, and save the results for each 
* bootstrap replication in a file.
* NOTE: for some reason, -ineqdeco- doesn't generate results
*       for GE(0), GE(1), GE(2), Gini, etc. when an "if" condition
*		is used, so I'm using preserve/restore blocks for
*		sub-groups instead.
*		Also, saving results presented a few wrinkles, but
*		doing it via matrices works.
*****************************************************************;

/*
	This file uses:
		work/povmeas_ent_flex.dta (the bootstrapped version)
		out/bs_results.dta
	
	This file creates:
		out/bs_results.dta (updated)	
*/




* Housecleaning;
cap mat drop rep nat rur urb full;

* Save the poverty lines in data file created for that purpose,;
* and store in a matrix, for saving to a data file later.;
use "$path/work/povmeas_ent_flex.dta", clear;
	foreach reg of numlist 1/13 {;
		qui sum linpob if spdomain==`reg';
		global linpob`reg'=r(mean);
	};
	mat input rep=(0);
	mat input linpob=($linpob1 $linpob2 $linpob3 $linpob4 $linpob5 $linpob6 
		$linpob7 $linpob8 $linpob9 $linpob10 $linpob11 $linpob12 $linpob13);
	mat linpob = rep, linpob;
	mat colnames linpob = rep linpob1 linpob2 linpob3 linpob4 linpob5 linpob6 
		linpob7 linpob8 linpob9 linpob10 linpob11 linpob12 linpob13;
	#delimit cr

	* Change poverty measures from percentage to index terms;
	gen h   = h_ent_   /100
	gen pg  = pg_ent_m /100
	gen spg = spg_ent_m/100

	* National figures;
	sum h [aw=hhweight*hhsize]
	glob p0_nat=r(mean)
	sum pg [aw=hhweight*hhsize]
	glob p1_nat=r(mean)
	sum spg [aw=hhweight*hhsize]
	glob p2_nat=r(mean)
	ineqdeco cr2 [aw=hhweight*hhsize]
	glob gini_nat=$S_gini
	glob ge0_nat =$S_i0
	glob ge1_nat =$S_i1
	glob ge2_nat =$S_i2
	mat input nat=($p0_nat $p1_nat $p2_nat $gini_nat $ge0_nat $ge1_nat $ge2_nat)

	* Rural figures;
	preserve
		keep if rural==1
		sum h [aw=hhweight*hhsize]
		glob p0_rur=r(mean)
		sum pg [aw=hhweight*hhsize]
		glob p1_rur=r(mean)
		sum spg [aw=hhweight*hhsize]
		glob p2_rur=r(mean)
		ineqdeco cr2 [aw=hhweight*hhsize]
		glob gini_rur=$S_gini
		glob ge0_rur =$S_i0
		glob ge1_rur =$S_i1
		glob ge2_rur =$S_i2
	restore
	mat input rur=($p0_rur $p1_rur $p2_rur $gini_rur $ge0_rur $ge1_rur $ge2_rur)

	* Urban figures;
	preserve
		keep if rural==0
		sum h [aw=hhweight*hhsize]
		glob p0_urb=r(mean)
		sum pg [aw=hhweight*hhsize]
		glob p1_urb=r(mean)
		sum spg [aw=hhweight*hhsize]
		glob p2_urb=r(mean)
		ineqdeco cr2 [aw=hhweight*hhsize]
		glob gini_urb=$S_gini
		glob ge0_urb =$S_i0
		glob ge1_urb =$S_i1
		glob ge2_urb =$S_i2
	restore
	mat input urb=($p0_urb $p1_urb $p2_urb $gini_urb $ge0_urb $ge1_urb $ge2_urb)

	* Assemble the matrix pieces and save this set of estimates in the data file;
		#delimit;
		mat full= rep, nat, rur, urb;
		mat colnames full = rep 
					p0_nat  p1_nat  p2_nat  gini_nat  ge0_nat  ge1_nat	ge2_nat
					p0_rur  p1_rur  p2_rur  gini_rur  ge0_rur  ge1_rur	ge2_rur
					p0_urb  p1_urb  p2_urb  gini_urb  ge0_urb  ge1_urb	ge2_urb;
	#delimit cr
	mat list full


drop _all

svmat full , names(col)
	tempfile rep
	compress





*****************************************************************
* 220_gen_results.do		(end)
*****************************************************************;

log close
