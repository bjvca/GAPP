
*********************************************************************
*********************************************************************
**
**     PROGRAMME:    preparing_household data_2010-2011 for Uganda_tables_A1_to_A5      
**     AUTHOR:       HARUNA SEKABIRA
**     OBJECTIVE:    Create standard tables A1 to A5 for UNPS 2010/2011
**
**     DATA IN:      GSEC1.dta
**					 GSEC2.dta
**					 GSEC3.dta
**                   GSEC15B.dta
**
**
**
**     DATA OUT:     hhdata.dta (table A1)
**					 indata.dta (table A2)
**					 calperg.dta (table A3)
**                   cons_cod_trans.dta (table A4)
**                   cons_cod.dta (table A5)
**
**     NOTES:		the files in the in folder here have been copied from C:\Users\Templeton\Desktop\GAPP\UNHS_2005\UNHS_III_SOCIO_DATA
**                  originally from UBOS and pasted in the in folder as the original files for use		
**
**************************************************************************

clear
set logtype text
capture log close
set more off

if c(os)=="Unix" {
global path "/home/bjvca/data/data/GAP/Haruna/UNPS_2011/GAPP3/"
}
else{
global path "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\UNPS_2011\GAPP3"
}


**************************************************************
* Table A1: Household Characteristics and interview details
**************************************************************

use "$path/in/GSEC1.dta" 
*keep

***------- Primary Sampling Unit
* The primary sampling unit for the 2011 is the comm, using codes as of 2005/6 UNHS and is the enumeration area.
codebook comm 
	/* There are 324 unique values, the UNHS 10/11 report mentions 322, located in C:\Users\Templeton\Desktop\GAPP\UNHS_2011\GAPP3\working-files */
rename comm psu
label variable psu "Primary Sampling Unit"

***------Interview date
** the interview date was in three propotions, the day, month and year and all these had been entered separately. However, this infromation is 
** replicated below in the survey quarters and months better thus might be a repeat to do it here.

***------- Interview Quarter
* For the Mozambique Data, instead of using the regular quarter definition for their "surquar" variable they defined the quarters
* relative to the time period covered by the survey: the survey ran from Sept 2008 to August 2009 so they defined the quarters
* as follows: Sept-Nov 08, Dec08-Feb09, Mar-May 08 and June-Aug 08.
* I will use the same framework
tab month year,m 
	/* According to the repartition of months and year, the survey ran from Oct 2010 to Sept 2011. I will define the
	 * the quarters accordingly */
gen float survquar=1 if month>=10 & month<=12 & year==2010
replace survquar=2 if month>=1 & month<=3  & year==2011
replace survquar=3 if month>=4 & month<=6  & year==2011
replace survquar=4 if month>=7 & month<=9  & year==2011
label define lsurvquar 1 "Oct-Dec 10" 2 "Jan-Marc 11" 3 "Apr-June 11" 4 "July-Sept 2011"
label values survquar lsurvquar
label variable survquar "Sequential Survey Quarter (Oct-Dec 10 = 1)"

***------- Sequential Interview month 
* Following the Mozambique file, I am creating a survey month variable rather than an interview date variable as per the excel sheet
* Number 1 corresponds to the first month of the survey and not to January.
gen float survmon=1 if month==10 & year==2010
replace survmon=2 if month==11 & year==2010
replace survmon=3 if month==12 & year==2010
replace survmon=4 if month==1 & year==2011
replace survmon=5 if month==2 & year==2011
replace survmon=6 if month==3 & year==2011
replace survmon=7 if month==4 & year==2011
replace survmon=8 if month==5 & year==2011
replace survmon=9 if month==6 & year==2011
replace survmon=10 if month==7 & year==2011
replace survmon=11 if month==8 & year==2011				
replace survmon=12 if month==9 & year==2011
label define lsurvmon 1 "Oct 10" 2 "Nov 10" 3 "Dec 10" 4 "Jan 11" 5 "Feb 11" 6 "Mac 11" 7 "Apr 11" 8 "May 11" 9 "Jun 11" 10 "Jul 11" 11 "Aug 11" 12 "Sep 11"

label values survmon lsurvmon
tab survmon,m
label variable survmon "Sequential Survey Month (Oct 2010 = 1)"

***------- Household Sample Weight
rename wgt10 hhweight
label variable hhweight "Household sample weight"

***------- Household id
codebook HHID /*there are  2,716 different values and 2,716 observations in the dataset so the variable "hh" uniquely identifies the observations */
rename HHID hhid
label variable hhid "Household ID"


***------- Geographical Stratification during sampling

tab stratum

*  UNPS Strata |
*           of |
*Representativ |
*        eness |      Freq.     Percent        Cum.
*--------------+-----------------------------------
*      Kampala |        185        6.81        6.81
*  Other Urban |        427       15.72       22.53
*Central rural |        528       19.44       41.97
*   East rural |        554       20.40       62.37
*  North rural |        568       20.91       83.28
*   West rural |        454       16.72      100.00
*--------------+-----------------------------------
*        Total |      2,716      100.00

* the 2010/2011 survey uses a tratification that aggregates all other urban except kampala and this is an interesting way
* that we have not used before so I choose to maintain it for the tool kit analysis
rename stratum strata
label variable strata "Geographical stratification variable during sampling (ranging from 1 to 6 sub regions)"

***----------------------rural/urban identifier 
tab urban

*Urban/Rural |
* Identifier |      Freq.     Percent        Cum.
*------------+-----------------------------------
*      Rural |      2,105       77.50       77.50
*      Urban |        611       22.50      100.00
*------------+-----------------------------------
*      Total |      2,716      100.00

gen rural=1 if urban==0
replace rural=0 if urban==1
label variable rural "Rural/Urban Location"
tab rural,m

*Rural/Urban |
*   Location |      Freq.     Percent        Cum.
*------------+-----------------------------------
*      Urban |        611       22.50       22.50
*      Rural |      2,105       77.50      100.00
*------------+-----------------------------------
*      Total |      2,716      100.00

** just to confirm that the rural urban specification was not changed, we tabbed again to see if totals are still as before with substrat*

***-----Regions used for temporal price index calculations
tab region,m
replace region=1 if region==0
* Region of |
*  Residence |
* in 2009/10 |      Freq.     Percent        Cum.
*------------+-----------------------------------
*    Kampala |        184        6.77        6.77
*    Central |        657       24.19       30.96
*    Eastern |        647       23.82       54.79
*   Northern |        693       25.52       80.30
*    Western |        535       19.70      100.00
*------------+-----------------------------------
*      Total |      2,716      100.00

** since Kampala has close to 200 respondents and we have so for not experienced a scenario of an index involving Kampala olone, 
** I choose to maintain Kampala for price indices 
clonevar reg_tpi = region 
label variable reg_tpi "Regions used for temporal price index calculations"

***------ Spatial domains (each with its own poverty line)

tab regurb

*RegionXUrban- |
*   Subregions |      Freq.     Percent        Cum.
*--------------+-----------------------------------
*Central rural |        529       19.53       19.53
*Central urban |        304       11.23       30.76
*   East rural |        554       20.46       51.22
*   East urban |         93        3.43       54.65
*  North rural |        568       20.97       75.63
*  North urban |        125        4.62       80.24
*   West rural |        454       16.77       97.01
*   West urban |         81        2.99      100.00
*--------------+-----------------------------------
*        Total |      2,708      100.00

* In the Arndt & Simler 2010 paper the spatial domains are a combinaison of regions and rural/urban delimitations + the capital
* city, however in the 2010/11 some urban sections have far less than 200 respondents, so we shall combine all other regions 
* (rural + urban)except the central since its urban would be boosted by Kampala, getting us 5 spatial domains


gen float spdomain=1  if regurb==10 | regurb==11
replace spdomain=2 if regurb==20 | regurb==21
replace spdomain=3 if regurb==30 | regurb==31
replace spdomain=4 if regurb==40 | regurb==41

tab spdomain


*   spdomain |      Freq.     Percent        Cum.
*------------+-----------------------------------
*          1 |        304       11.23       11.23
*          2 |        529       19.53       30.76
*          3 |        647       23.89       54.65
*          4 |        693       25.59       80.24
*          5 |        535       19.76      100.00
*------------+-----------------------------------
*      Total |      2,708      100.00

label define lspdomain 1 "Central" 2 "Eastern" 3 "Northern" 4 "Western" 
label values spdomain lspdomain
label variable spdomain "Spatial domains: each with own poverty line (they are 4)"
*just to confirm allocations
tab spdomain rural

*      Spatial |
*domains: each |
*     with own |
* poverty line | Rural/Urban Location
* (they are 5) |         0          1 |     Total
*--------------+----------------------+----------
*Central Urban |       304          0 |       304 
*Central Rural |         0        529 |       529 
*      Eastern |        93        554 |       647 
*     Northern |       125        568 |       693 
*      Western |        81        454 |       535 
*--------------+----------------------+----------
*        Total |       603      2,105 |     2,708 


***---------------News; another way to specify variables, is the traditional Uganda regions, North east central and western, represented in region

gen new = spdomain

label define lnew 1 n 1 "Central" 2 "Eastern" 3 "Northern" 4 "Western" 
label values new lnew

label variable new "other ways to dissagregate poverty lines"
rename new news

****-------geo1-geo?; other administrative geographical boundariies where a survey is representative is not required as also done in news rural and others

*** -------------------Bootstrap weights: the toolkit requires that this should be=1 for all households and we generate it below

gen float bswt=1
label variable bswt "bootstrap weights; and all equal to 1 for all households, as a toolkit requirement"
sort hhid
save "$path/in/hhdata_hhsize.dta",replace

**** --------------------------------Household size
** Since we need Household size in the hhdata.dta, and it was unavailable in the GSEC1.dta, we use the Unique person identifier in GSEC2.dta

clear 
use "$path/in/GSEC2.dta"
bysort HHID: gen pid=_n
order HH pid
collapse (count) pid, by (HHID)
rename pid hhsize
la var hhsize "number of household menbers"
rename HHID hhid
sort hhid
save "$path/in/hhsize.dta",replace

clear 
use "$path/in/hhdata_hhsize.dta"
merge 1:1 hhid using "$path/in/hhsize.dta"
tab _m
drop _m 
sort hhid
destring hhid, replace
destring psu, replace
save "$path/out/hhdata.dta",replace
save "$path/in/hhdata.dta",replace
save "$path/work/hhdata.dta",replace


************************************************************
* Table A2: Individual characteristics - demographics
************************************************************

clear

use "$path/in/GSEC2.dta" 
sort HHID

***----- Household members
*According to the enumerator manual of 2010/11, Usual and Regular household members are defined as follows:

*Usual members are defined as those persons who have been living in the household for 6 months or
*more during the last 12 months. However, members who have come to stay in the household permanently
*are to be included as usual members, even though they have lived in this household for less than 6
*months. Furthermore, children born to usual members on any date during the last 12 months will be taken
*as usual members. Both these categories will be given code "1" or "2" depending upon whether they are
*present or absent on the date of the interview.

*Regular members refer to those persons who would have been usual members of this household, but
*have been away for more than six months during the last 12 months, for education purposes, search of
*employment, business transactions etc. and living in boarding schools, lodging houses or hostels etc.
*These categories will be given code "3" or "4" depending upon presence or absence on the date of the
*interview. */

/* 
* For the purposes of the calculation of a poverty line we'll exclude from the household the members who have left 
the household permanently or died
*  We'll keep the members away for more than 6 months but present on the day of the interview
*/

rename  h2q7 resident
drop if resident==7

***------ Household ID
rename HHID hhid
label variable hhid "Household ID"

***------ Individual ID
destring hhid PID, replace
gen double indid = hhid*100 +  PID

codebook indid
	* There are 16,592 different values, and there are 16,592 observations in the dataset so indid uniquely identifies
		* the individuals
label variable indid "Individual ID"

***------ Sex
rename  h2q3 sex
label variable sex "Sex"

***------ Age
rename  h2q8 age
label variable age "Age in years"

* In order to have the information on whether the mother resides in the house or not we need the file "hsec3"
sort indid
save "$path/in/temp_A2_1.dta",replace

clear
use "$path/in/GSEC3.dta" 

***------ Individual ID
rename HHID hhid
destring hhid PID,replace
gen double indid=hhid*100 +  PID
label variable indid "Individual ID"
codebook indid
	* There are 15,196 different values, and there are 15,196 observations in the dataset so indid uniquely identifies
		* the individuals

***----- Mother lives in household?
tab h3q5a,m
*There are 6,549  (ie 43.2 %) missing responses, 
* They have four categories: 1: Yes = 6,378 2: No = 1,899 3: No, Dead = 370 4: Missing = 6,549. I will group them 
gen motherhh=1 if h3q5a==1 
replace motherhh=0 if h3q5a==2 | h3q5a==3 | h3q5a==.
label variable motherhh "Mother lives in hh"
label define lmoth 0 "No" 1 "Yes"
label values motherhh lmoth

keep indid motherhh
sort indid
merge 1:1 indid using "$path/in/temp_A2_1.dta"
tab _merge
	* There are some obs coming only from the using data. The explanation is that Section 3 of the questionnaire 
	* is administered only to usual and regular household members, as is confirmed by the cross tab below
	tab resident _merge
	* We leave the variable as is, with additional missing values for the variable "motherhh".
drop _merge

keep hhid indid sex age motherhh

save "$path/out/indata.dta",replace
save "$path/in/indata.dta",replace
save "$path/work/indata.dta",replace

**********************************************
* Table A3: Calorie content of food items
**********************************************
* since the food products were the same across the surveys, we compiled the calorie content and edible portion in an excel file then converted that file into a STATA file
* The excel file (with more detailed information, inculding the sources) is in the "in" folder

clear
use "$path/in/foodcomp_uganda_PANNELsurvey2011.dta"

* Since they did not include edible portions in the file I assume that the calorie per gram is only for the edible portion.
* I will therefore compute calperg that way
destring kcal_100g edible, replace
gen double calperg=((kcal_100g*edible)/100)/100
keep product descript calperg
label variable product "Food product code: numerical"
label variable descript "Product Description: incl. product code in the beginning"
label variable calperg "Calorie content of food product: calories per gram"
destring product, replace
sort product
save "$path/out/calperg.dta",replace
save "$path/in/calperg.dta",replace
save "$path/work/calperg.dta",replace

clear
***************************************************************************
* Table A4: Amount and Quantity of food transactoin - Transaction level
***************************************************************************


use "$path/in/GSEC15B.dta"
sort HHID
rename HHID hhid
la var hhid "household id"
** we drop alcoholic and tobacco as these were not considered basic in foods generally and by GAPP, these included beer-152, other alcoholic dricns-153
** cigarettes-155, other tobacco-156 and beer taken in restaurants-159, just like we did in the 2009 poverty calculations
drop if inlist( itmcd ,152,153,155,156,159)
duplicates report  hhid itmcd
duplicates list  hhid itmcd
codebook hhid
egen quantity=rowtotal( h15bq4 h15bq6 h15bq8 h15bq10)
 
la var quantity "quantity of food consumed by the household including purchases, at home, away from home & kind"
** these quantities and values are collected by UBOS at a 7 days basis, thus we divide by 7 to get the daily figures as a requirement by GAPP 
gen quantityd = quantity/7
drop quantity h15bq10 h15bq8 h15bq6 h15bq4
la var quantityd "daily household food consumption"
egen value=rowtotal ( h15bq5 h15bq7 h15bq9 h15bq11 )
la var value "household food consumption in seven days"
gen valuez = value/7 
la var valuez "daily value of food consumed by the household"
rename quantityd quantityz
drop value h15bq11 h15bq9 h15bq7 h15bq5 h15bq13 h15bq12
gen unit = 1
la var unit "set equal to one since all observations are converted into kg"
gen food_cat = 1
la var food_cat "food category equals 1, if product is food and 0 if non food"

des hhid
des food_cat
des valuez
rename itmcd product
la var product "Food product code: numerical"
destring product, replace
save "$path/in/household_table4.dta", replace
save "$path/out/household_table4.dta", replace
save "$path/work/household_table4.dta", replace
set more off
count
sort product untcd

** to the quantities of the food in standard unite, the Kilograms, a file called conversion factors was generated in excel with details
** of the sources of information, located in the "in" folder named "ucf_uganda_UNSH2005.xls" and a STATA extract of both excel and STATA use named
** "conversionfactors.xls AND .dta" is also in the in folder for use below. The file has equivalents of local units into kilograms and 
** we need it to convert the local units used in food consumption bundles into kilograms. Since the foods and the local units were the same, this file is 
** similar to the one used for the 2009 data
merge m:1 product untcd using  "$path/in/Conversionfactors.dta"
tab _m
drop _m
** I had to destring all the variables of the "conversionfactors.dta" file to match type with that of "--table4.dta" to enable the merge successful
save "$path/in/household_table4cf.dta", replace
save "$path/out/household_table4cf.dta", replace
save "$path/work/household_table4cf.dta", replace
gen quantity = quantityz* convfactor

la var quantity "daily quantity consumed in Kgs per household"
la var value  "daily value of consumption in UGX per per household"

drop convfactor
sort hhid
label drop _all
destring hhid, replace

save "$path/out/cons_cod_trans.dta", replace
save "$path/in/cons_cod_trans.dta", replace
save "$path/work/cons_cod_trans.dta", replace

**   Generating Standard Table 5: TOTAL AMOUNT AND QUANTITY OF PRODUCTS: Food as well as non food
**
***********************************************************************************************
**  DATA IN:       hsec4.dta : On Education costs, column 13f which has all total school expenses, it is on 365 dayss basis
**                 hsec5.dta : On Medical Expenditure, column 10 and 11, on 30 days basis
**                 hsec12a.dta : On assets Expenditure, column h8q5 on total estimated present value, considering 10% value used per 365 days basis
**                 hsec14b.dta: On non-durables and frequently purchased items e.g imputed rent, electricity, soap etc, on 30 days basis, columns 5,7 & 9 for value
**                 hsec14c.dta: On semi-durable goods and services, column 3, 4 & 5, on 365 days basis for value
**                 hsec14d.dta:     On Non-consumption expenses like taxes, remitances away, subscriptions etc, on 365 days basis, colum 3
**
**  DATA OUT: cons_cod.dta
******************************************************************************************************************************************************
clear
use "$path/in/GSEC4.dta"
 
rename HHID hhid
codebook hhid
keep hhid h4q15g
sort hhid
 ** since total education expenses were clooected in h4q10f and since is at yearly basis, we divided it by 365 to get daily expenses on education
gen educationd = h4q15g/365
la var educationd "daily household expense on education"
drop h4q15g
save "$path/out/hhdeducationexp.dta", replace
// 
// clear
// 
use "$path/in/GSEC5.dta"
// 
des
rename HHID hhid
sort hhid
keep hhid h5q12
gen medicalexp = h5q12
gen medicalexpd = medicalexp/30
la var medicalexpd "household daily expenditure"
drop h5q12 medicalexp
save "$path/out/hhdmedicalexp.dta", replace
 
 clear
 set more off 
use "$path/in/GSEC14.dta"
// des
save "$path/out/hhddurables.dta", replace
* keep if inlist( h14q2 ,010,011,012)
  
 gen assetvalue = h14q7
// 
// **************************************************************************************************************
// ** i took land, bicycle, motor cycle and other transport equipment-012, that in 2009 were motor vehicles, as durables and assumed that a year, the household can use 1% of these assests. there was no land in 2005 assets
// ** house not treated as an asset as the toolkit takes care of imputed rent
// ************************************************************************************************************************
 gen dassetvalue = (assetvalue*0.2)/365
la var dassetvalue "household daily durables expenditure"
rename HHID hhid
sort hhid
save "$path/out/hhddurablesexp.dta", replace
// 
// clear
// 
// use "$path/in/hsec12a.dta"
// save "$path/out/hhnondurables.dta", replace
// rename hh hhid
// drop if inlist(  h12aq2 ,010,011,012 ,001)
// gen nondurablevalue = h12aq5
// **h12aq4 multiple has been dropped since UBOS had recorded h12aq5 as total estimated value in Ush and also discounted them by 1% to get rough value used per year
// *** we considered other buildings-002, furniture-003, Bednets-005, Hh appliances as Kettle,flat iron-006, electronics as tv,radio-007, generators-008, solar-panel-009
// *** , jewelry&watches-013, mobilephone-014, otherassets as lawn mores-015, Enterprise assests like; home-101, ploughs-102, wheelbarrows-104, pangas-103
// **  others-105, 106 and 107 and financial assets-201, NOTE: figures are codes in data set
// la var nondurablevalue "household daily non-durables expenditure"
// sort hhid
// gen dnondurables = (nondurablevalue*0.01)/365
// la var dnondurables "household daily non-durables expenditure"
// save "$path/out/hhdnondurablesexp.dta", replace
// 
// clear

use "$path/in/GSEC15C.dta"
des
rename HHID hhid
sort hhid


** here we considered rent of rented house-301, imputed rent of own house-302, imputed rent of free given house-303, repair expenses-304, water-305 
** electricity-306, generator fuels-307, parafin-308, charcoal-309, firewood-310, matches-451, washing soap-452, bathing soap-453, toothpaste-454, 
** taxifares-463, and expenditure on phones not owned-468
** and we dropped others-311, cosmetics-455, handbags-456, batteries-drycells-457, newspapers-458, others-459, tires-461, petrol-462, 
*** bus fares-464, bodaboda fare-465, stamps/envelops-466, mobilephoneairtime-467 and others-469,health fees as consultation-501, medicine-502
*** hospitalcharges-503, traditionaldoctors-504, others-509 since medical expenses were cosidered in section 5, sports/theater-701,
**  drycleaning-702, houseboys-703, barbers&beauty shops-704 and lodging-705. THESE HAVE BEEN CONSIDERED NON BASIC

// drop if inlist( h14bq2 ,311,455,456,457,458,459,461,462,464,465,466,467,469,501,502,503,504,509,701,702,703,704,705)
 
egen hhfrequents = rowtotal ( h15cq5 h15cq7 h15cq9)
gen dhhfrequents = hhfrequents/30
la var dhhfrequents "daily household expenditure on frequently bought commodities"


save "$path/out/hhdfrequentsexp.dta", replace

clear
/*
*******************************************************************************************
**   in considering semi durable goods and services, the value of those services and goods recieved in kind, column 5 of hsec14c.dta has been excluded
**   just as in kind food consumptions were eliminated in table 4 as per the GAPP guidelines, These have also been discounted by 10% usage per year
***************************************************************************************************************************************************

use "$path/in/hsec14c.dta"
save "$path/out/hhsemidurables.dta", replace
des
sort hh
rename hh hhid
** we have considered the following men clothing-201, womenclothing-202, childrenclothing-203, men footware-221, women footware-222, children footware-223
** bedding mattress-404, blankets-405, charcoal/parafin stoves-422, plastic plates and tumblers-442
** and dropped other clothing-209, tailoring materials-210, other footware-229, furniture items-401, carpets-402, curtains&bedsheets-403, others-409
** kettles-421, tv&radio-423, byclcles-424, radio-425, motors-426, motorcycles-427,computers-428, phone handsets-429, others-430, jewelry&watches-431, 
** glass/table ware of codes 441-449, education cost (601-609) as education done in section 4, and others like functions & premiums (801-809)
** as these have been consideered NON BASIC
drop if inlist( h14cq2 ,209,210,229,401,402,403,409,421,423,424,425,426,427,428,429,430,431,441,443,444,445,449,601,602,603,604,609,801,802,803)
egen hhsemidurables = rowtotal ( h14cq3 h14cq4)
sort hhid
gen hhdsemidurs = (hhsemidurables*0.01)/365
la var hhdsemidurs "household daily semi durables goods and seervices expenses"
drop hhsemidurables
save "$path/out/hhdsemidurablesexp.dta", replace

clear

use "$path/in/hsec14d.dta"
save "$path/in/hhnonconsmpexptaxes.dta", replace
sort hh
rename hh hhid
** we only considered graduated tax-904, that may cause arrest if not paid and it used to be per head paid to local government annually
** and dropped income tax-901, property tax-902, user fees-903, social security payments-905, remmitances-906, funerals-907 and others-909
drop if inlist( h14dq2 ,901,902,903,905,906,907,909)
gen hhdnonconsumpexp = h14dq3/365
la var hhdnonconsumpexp "hh daily expenditure on taxes, contributions, donations, duties, etc"
sort hhid
save "$path/out/hhdnonconsumpexp.dta", replace
clear
******************************************************************************
** after generating all daily non food total household expenditures of various considered items, then we start merging these  seven hhd--- prefixed files, and ending with sufix exp to get all non food hh daily expenditure
**
**********************************************************************************************

*/

use "$path/out/hhdeducationexp.dta", clear
collapse (sum) educationd , by(hhid)
sort hhid
save "$path/out/hhdeducationexp.dta", replace

use "$path/out/hhdmedicalexp.dta", clear
collapse (sum) medicalexpd , by(hhid)
sort hhid
save "$path/out/hhdmedicalexp.dta", replace

use "$path/out/hhdeducationexp.dta", clear
merge 1:1 hhid using "$path/out/hhdmedicalexp.dta"
drop _merge
sort hhid
save "$path/out/hhdeduc&medicex.dta", replace


use "$path/out/hhddurablesexp.dta"
collapse (sum) dassetvalue , by(hhid)
sort hhid
save "$path/out/hhddurablesexp.dta", replace

use "$path/out/hhdeduc&medicex.dta"
merge 1:1 hhid using "$path/out/hhddurablesexp.dta"
drop _merge
sort hhid
save "$path/out/hhdeduc&medic&durabex.dta", replace

// use "$path/out/hhdnondurablesexp.dta"
// collapse (sum) dnondurables , by(hhid)
// sort hhid
// save "$path/out/hhdnondurablesexp.dta", replace
// 
// use "$path/out/hhdeduc&medic&durabex.dta"
// merge 1:1 hhid using "$path/out/hhdnondurablesexp.dta"
// drop _merge
// sort hhid
// save "$path/out/hhdeduc&medic&durab&nondurabex.dta", replace



use "$path/out/hhdfrequentsexp.dta"
collapse (sum) dhhfrequents , by(hhid)

sort hhid
save "$path/out/hhdfrequentsexp.dta", replace

use "$path/out/hhdeduc&medic&durabex.dta"
merge 1:1 hhid using "$path/out/hhdfrequentsexp.dta"
drop _merge
sort hhid
save "$path/out/hhdeduc&medic&durabex&freq.dta", replace

// use "$path/out/hhdeduc&medic&durab&nondurabex.dta"
// merge 1:1 hhid using "$path/out/hhdfrequentsexp.dta" 
// drop _merge
// sort hhid
// save "$path/out/hhdeduc&medic&durab&nondurab&freqsex.dta", replace
// 
// use "$path/out/hhdsemidurablesexp.dta"
// collapse (sum) hhdsemidurs , by(hhid)
// sort hhid
// save "$path/out/hhdsemidurablesexp.dta", replace
// 
// use "$path/out/hhdeduc&medic&durab&nondurab&freqsex.dta"
// merge 1:1 hhid using "$path/out/hhdsemidurablesexp.dta"
// drop _merge
// replace hhdsemidurs=0 if hhdsemidurs==.
// sort hhid
// save "$path/out/hhdeduc&medic&durab&nondurab&freqs&semidurabex.dta", replace
// // use "$path/in/HSEC5.dta"
// use "$path/out/hhdnonconsumpexp.dta"
// collapse (sum) hhdnonconsumpexp , by(hhid)
// replace hhdnonconsumpexp=0 if hhdnonconsumpexp==.
// sort hhid
// save "$path/out/hhdnonconsumpexp.dta", replace
// 
// use "$path/out/hhdeduc&medic&durabex&freq.dta"
// merge 1:1 hhid using "$path/out/hhdnonconsumpexp.dta"
// drop _merge
// sort hhid
// save "$path/out/hhdeduc&medic&durabex&noncons.dta", replace

// 
// use "$path/out/hhdeduc&medic&durab&nondurab&freqs&semidurabex.dta"
// merge 1:1 hhid using "$path/out/hhdnonconsumpexp.dta"
// drop _merge
// replace hhdnonconsumpexp=0 if hhdnonconsumpexp==.
// sort hhid
// save "$path/out/hhdeduc&medic&durab&nondurab&freqs&semidurab&nonconsmpex.dta", replace

gen hhnonfoodexp = educationd+medicalexpd+dassetvalue+dhhfrequents
la var hhnonfoodexp "household total non food expenditure"
keep hhid hhnonfoodexp


gen product = 0
la var product "product code equal to 1 for food and 0 for non food"
gen food_cat = 0
la var food_cat "food product or not equals 1 for foods and 0 for non foods"
gen prod_cat = 2
la var prod_cat "COICOP product categories, 2 for all non food"
replace product = 2 if product==0
replace food_cat = 2 if food_cat==0
gen descript = 2
la var descript "product description including product code but equals 2 for all non-foods"
save "$path/out/hhtotalnonfoodexp.dta", replace
label define descrip 2 " non food", add
label values descript descrip
label define descrip 1 " food", add
replace descript = 1 in 6
replace descript = 2 in 6
sort hhid
destring hhid, replace
save "$path/out/hhtotalnonfoodexp.dta", replace

use "$path/out/hhtotalnonfoodexp.dta"
append using  "$path/out/cons_cod_trans.dta"


rename quantityz quantityd
egen cod_hh_nom = rowtotal( hhnonfoodexp valuez)
la var cod_hh_nom "total household daily expenditure"
la var quantityd "housedhold daily quantity of food consumed in Kgs"
drop unit
drop hhnonfoodexp
sort hhid
replace product = 999 if product==2
la var product "product code is 999, if product is non food"
replace prod_cat = 1 if prod_cat==.

replace descript=1 if descript==.
label drop _all
save "$path/out/cons_cod.dta", replace
save "$path/work/cons_cod.dta", replace
save "$path/in/cons_cod.dta", replace


