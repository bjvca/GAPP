cap log close
log using "$path/rep/010_initial.log", replace
clear
set more off
#delimit ;



******************************************************************************
* 010_initial.do		(start)
******************************************************************************;

******************************************************************************
* Purpose: Set some globals
******************************************************************************;

******************************************************************************
* TPI basket
******************************************************************************;

* Number of items;
global product_tpi_n "15";

* Code choose $product_tpi_n ;
global product_tpi   "product_tpi==1";

* Initial (arbitrary) quantile defining poor for price index calculations.
* Mozambique: bottom 60%. Vietnam: bottom 20%. Tanzania: bottom 40% ;
global tpi_bottom "50";

* Set the number of regions in the TPI calc;
global n_tpi "6";

******************************************************************************
* Initial (arbitrary) quantile defining the (relatively) poor.
******************************************************************************;
global bottom "60";

******************************************************************************
* Number of iterations in 140_iterate.do
******************************************************************************;
global it_n "5";

******************************************************************************
* Set the number of regions in the spatial domain;
******************************************************************************;
global n_spdom "13";

******************************************************************************
* Revealed preferences choices
******************************************************************************;

* Activate GAMS program according to number of regions in spatial domain;
*global revpref "190_revpref13_m1.bat";
*global no_temp_rev " ";

* k spatial regions and no intertemporal revealed preference condition:
  Activate the next two lines below;
global no_temp_rev "*";
global revpref "190_revpref13_r.bat";
 
**************************************************************************
* 010_initial.do		(end)
**************************************************************************;

log close;
