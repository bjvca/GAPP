

if c(os)=="Unix" {
global path "/home/bjvca/data/data/GAP/Haruna/UNHS_2005/GAPP2/"
}
else{
global path "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\UNHS_2005\GAPP2"
}






version 10.1

cd "$path"

cap log close log_total
cap log close log_tot_s
cap log close log_000_boom

log using "$path/rep/log_total.log" , name(log_total) replace
log using "$path/rep/log_total.smcl", name(log_tot_s) replace
log using "$path/rep/000_boom.log"  , name(log_000_boom) replace

display "* # * # * # * # * # * # * # * # * # * # * # * # * # * # * # * # *"
display ""
display "Generel information:"
display "   UGANDA HOUSEHOLD BUDGET SURVEY 2005/06"
display "   Poverty rate estimation"
display "   Methodology: Iterative procedure and revealed preferences tests"
display ""
display "* # * # * # * # * # * # * # * # * # * # * # * # * # * # * # * # *"


**************************************************************************
* 000_boom.do	(start)
*
* Reminders:
*	1) Check very top of this file to make sure you are on the right path! 
*	2) GAMS 22.5 must be placed onto the path. See 190_revpref13_m1.bat.
*	   Typically this needs to be edited.
*   3) In case of implementing a new survey the user must make necessary
*      changes in 010_initial.do, 020_hhdata.do and 030_rawdata.do.
*
* Process:
* - The do-file prefix indicates first time a do-file is called
*
* KS, 2003
* CA, 2005-2006
* MAH, June. 2013
**************************************************************************

clear all
set more off
set mem 700m

noisily display "Start time: " "$S_TIME"



**************************************************************************
* Macros. Region definitions. Demographic definitions.
**************************************************************************
do "$path/new/010_initial.do"

*do "C:\user\gapp\z_data_preb/new/100_collect_expen_moz.do"
*s;

*do "C:\user\gapp\z_data_preb/new/000_boom.do"

*global path "C:\user\gapp"



**************************************************************************;
**************************************************************************;
* This is the block of do files to set up the data to get nominal
* consumption. These DO NOT need to be bootstrapped.
**************************************************************************;
**************************************************************************;
	
	* This code produces some once for all data for the in-folder. Don't
	* run it unless you know what you are doing!!!
		* Produces education expenditure
		*do "$path\new\Create/education_Create.do"
		* Imputation of missing recepts-in-kind. Run the code without this first...
		*do "$path\new\Create/0_code_chain.do"
		* First poverty lines dependent on IAF
		*do "$path\new\Create/povlines_first_iof_Create.do"
		* Match product codes for different surveys
		*do "$path\new\Create/match96_02_Create.do"
		* Basket from previous survey
		*do "$path\new\Create/smallbasket_iof_Create.do"
		* Match product codes between surveys
		*do "$path\new\Create/rev_pref_matchcodes_02-96_iof_Create.do"
		* Update poverty lines
		*do "$path\new\Create/povlines-96-v1-vers7_iof_Create.do"		
		* Food share
		*do "$path\new\Create/foodshr96_iof_Create.do"
		
		*do "$path\new\Create/.do"
		*do "$path\new\Create/.do"

*/
	* This set of files takes the raw data and creates more handy data 
	* sets in the work-folder
	do "$path/new/020_in_2_work_folder.do"
	do "$path/new/final_tableA1-A5-Haruna-2005.do"
	
/*
	* All kind of raw expenditure is handled: daily, own and monthly, rent and use value, education etc.
	do "$path/new/030_rawdata.do"

	* Data set specific changes to each processed raw data set takes place here
	do "$path/new/040_specifities.do"

	* These files summarizes and checks the data. But no temporal deflation done here yet
	do "$path/new/050_consump_nom.do"

	* Bring in data on food product's calories per gram
	do "$path/new/060_calperg.do"
*/
**********************************************************************;
**********************************************************************;

				do "$path/new/070_calpp.do"				/* Calories per person in spatial domains*/
				do "$path/new/080_conpc.do"				/* Nominal food/non-food expenditure */
				do "$path/new/090_temp_index.do"		/* Temporal price index */
				do "$path/new/100_food_basket_flex.do"	/* Flexible food basket */
				do "$path/new/110_price_unit_flex.do"	/* Flexible basket: Prices */
				do "$path/new/120_povline_food_flex_original.do"	/* Flexible basket: Poverty line */
				do "$path/new/130_povmeas_flex.do"		/* Flexible basket: Poverty rates */
				do "$path/new/140_iterate_bjorn.do" $it_n $bottom	/* Flexible basket: Iterations */
				
$no_temp_rev	do "$path/new/150_price_unit_fix.do"	/* Fixed basket: Prices */
$no_temp_rev	do "$path/new/160_food_basket_fix.do"	/* Fixed food basket */
				do "$path/new/170_pref_r_price_bjorn.do"		/* Revealed preference tests */
$no_temp_rev	do "$path/new/180_povline_food_fix.do"	/* Inflating year t1's poverty lines to year t2 */

*** execute as super user:
*sudo ./gams "/home/bjvca/data/data/GAP/Haruna/UNHS_2005/GAPP2/new/190a_revpref13_r_bjorn.gms o=""/home/bjvca/data/data/GAP/Haruna/UNHS_2005/GAPP2/new/list.lst"


/* Adjusting flexible basket: inside pref. constraints */

$no_temp_rev	do "$path/new/200_povmeas_fix.do"		/* Fixed basket: Poverty rates */
				do "$path/new/210_povmeas_ent_flex.do"	/* Flexible basket, adjusted: Poverty rates */

				do "$path/new/220_gen_results.do"		/* Final poverty and inequality rates */
		
*quietly	do "$path/new/230_assets_possession"			/* Extra: Deprivation */
*quietly	do "$path/new/240_compare_nat_acc.do"			/* Extra: Compare survey with national accounts */



**********************************************************************;
* 000_boom.do	(end)
**********************************************************************;

log close log_000_boom
log close log_tot_s
log close log_total
