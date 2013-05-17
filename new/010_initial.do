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
* Mozambique: bottom 60%. Vietnam: bottom 20%. Tanzania: bottom 40% . Uganda: headcount 2009 24.5% ;
global tpi_bottom "50"; 

* Set the number of regions in the TPI calc for Uganda are set to east central north and east;
global n_tpi "4";

* To reproduce the mozambique 10 numbers, the following global should be commented out. It controls a line in 140_iterate.do 
* where observations not measured in kg are dropped. For all other datasets, all observations should be converted to kg's before
* the toolkit is run. For all other datasets, this line should therefore be included.
global MZ "*";


******************************************************************************
* Initial (arbitrary) quantile defining the (relatively) poor.
******************************************************************************;
global bottom "50";

******************************************************************************
* Number of iterations in 140_iterate.do
******************************************************************************;
global it_n "5";

******************************************************************************
* Set the number of regions in the spatial domain;
******************************************************************************;
global n_spdom "5";

******************* we deleted East urban, North urban and West urban because too few observations were in those spatial domains; 


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
