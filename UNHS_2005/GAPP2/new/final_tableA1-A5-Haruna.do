
*********************************************************************
*********************************************************************
**
**     PROGRAMME:    preparing_hhdata_200 for Uganda_tables_A1_to_A3_vXX       
**     AUTHOR:       HARUNA SEKABIRA
**     OBJECTIVE:    Create standard tables A1 to A3 for UNHS 2005/2006
**
**     DATA IN:      hsec1b.dta
**					 hsec2.dta
**					 hsec3.dta
**                   hsec14a.dta
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
global path "/home/bjvca/data/data/GAP/Haruna/UNHS_2005/GAPP2/"
}
else{
global path "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\UNHS_2005\GAPP2"
}


**************************************************************
* Table A1: Household Characteristics and interview details
**************************************************************

use "$path/in/hsec1b.dta" 
*keep

***------- Primary Sampling Unit
* The primary sampling unit for the 2005/6 UNHS is the enumeration area.
codebook ea 
	/* There are 39 unique values, the UNHS 05/06 report mentions 600, located in C:\Users\Templeton\Desktop\GAPP\UNHS_2005\GAPP2\working-files */
rename ea psu
label variable psu "Primary Sampling Unit"

***------Interview date
** the interview date was in three propotions, the day, month and year and all these had been entered separately. However, this infromation is 
** replicated below in the survey quarters and months better thus might be a repeat to do it here.

***------- Interview Quarter
* For the Mozambique Data, instead of using the regular quarter definition for their "surquar" variable they defined the quarters
* relative to the time period covered by the survey: the survey ran from Sept 2008 to August 2009 so they defined the quarters
* as follows: Sept-Nov 08, Dec08-Feb09, Mar-May 08 and June-Aug 08.
* I will use the same framework
tab monsurve yrsurve,m 
	/* According to the repartition of months and year, the survey ran from May 2005 to April 2006. I will define the
	 * the quarters accordingly */
gen float survquar=1 if monsurve>=5 & monsurve<=7 & yrsurve==2005
replace survquar=2 if monsurve>=8 & monsurve<=10  & yrsurve==2005
replace survquar=3 if (monsurve>=11 & monsurve<=12  & yrsurve==2005) | (monsurve==1  & yrsurve==2006)
replace survquar=4 if monsurve>=2 & monsurve<=4  & yrsurve==2006
label define lsurvquar 1 "May-Jul 05" 2 "Sept-Oct 05" 3 "Nov05-Jan06" 4 "Feb-Apr 2006"
label values survquar lsurvquar
label variable survquar "Sequential Survey Quarter (May-Jul 05=1)"

***------- Sequential Interview month 
* Following the Mozambique file, I am creating a survey month variable rather than an interview date variable as per the excel sheet
* Number 1 corresponds to the first month of the survey and not to January.
gen float survmon=1 if monsurve==5 & yrsurve==2005
replace survmon=2 if monsurve==6 & yrsurve==2005
replace survmon=3 if monsurve==7 & yrsurve==2005
replace survmon=4 if monsurve==8 & yrsurve==2005
replace survmon=5 if monsurve==9 & yrsurve==2005
replace survmon=6 if monsurve==10 & yrsurve==2005
replace survmon=7 if monsurve==11 & yrsurve==2005
replace survmon=8 if monsurve==12 & yrsurve==2005
replace survmon=9 if monsurve==1 & yrsurve==2006
replace survmon=10 if monsurve==2 & yrsurve==2006
replace survmon=11 if monsurve==3 & yrsurve==2006				
replace survmon=12 if monsurve==4 & yrsurve==2006

label define lsurvmon 1 "May 05" 2 "Jun 05" 3 "Jul 05" 4 "Aug 05" 5 " Sep 05" 6 "Oct 05" 7 "Nov 05" 8 "Dec 05" 9 "Jan 06" 10 "Feb 06" 11 "Mar 06" 12 "Apr 06"

label values survmon lsurvmon
tab survmon,m
label variable survmon "Sequential Survey Month (May 2005=1)"

***------- Household Sample Weight
rename hmult hhweight
label variable hhweight "Household sample weight"

***------- Household id
codebook hh /*there are  7426 different values and 7426 observations in the dataset so the variable "hh" uniquely identifies the observations */
rename hh hhid
label variable hhid "Household ID"

***------- Household Size
rename qhmember hhsize
label variable hhsize "Household Size"

***------- Geographical Stratification during sampling
* this was not there as was with 2009, therefore we shall generate "strata" from the distict and region variables here. the 2009 UBOS 
** has explanations for what districts belong to which sub regions, so we shall use that to build our strata variable. UBOS 2009/10 report had described them
** as follows: Notes: Sub-region of North East includes the districts of Kotido, Moroto, Nakapiripiriti, Katwaki, Amuria, Soroti, Kumi
** and Kaberamaido; Mid-Northern included Gulu, Kitgum, Pader, Apac, and Lira; West Nile includes Moyo, Adjumani, Yumbe, Arua, 
**Koboko, and Nebbi; Mid-Western includes Masindi, Hoima, Kibaale, Bundibugyo, Kabarole, Kasese, Kyenjojo and Kamwenge; South Western includes 
**  Bushenyi, Rukungiri, Kanungu, Kabale, Kisoro, Mbarara, and Ntungamo; Eastern includes Kapchorwa, Mbale,
** Tororo, Sironko, Paliisa, and Busia; Central 1 includes Kalangala, Masaka, Mpigi, Rakai, Sembabule and Wakiso; Central 2 includes
** Kayunga, Kiboga, Luwero, Mubende, Mukono and Nakasongola; East Central includes Jinja, Iganga, Kamuli, Bugiri and 
** Mayuge; and Kampala. We have used the same nomenclature

tab district
tab district, nolabel


gen float strata=2 if (district==101|district==105|district==106|district==110|district==111|district==113)
replace strata=1 if (district==102)
replace strata=3 if (district==103|district==104|district==107|district==108|district==109|district==112)
replace strata=4 if (district==201|district==203|district==204|district==205|district==214)
replace strata=5 if (district==202|district==206|district==209|district==210|district==212|district==215)
replace strata=6 if (district==302|district==304|district==305|district==307|district==312)
replace strata=7 if (district==207|district==208|district==211|district==213|district==306|district==308|district==311)
replace strata=8 if (district==301|district==303|district==309|district==310|district==313)
replace strata=9 if (district==401|district==403|district==405|district==406|district==407|district==409|district==413|district==415)
replace strata=10 if (district==402|district==404|district==408|district==410|district==411|district==412|district==414)

label define lstrata  1 "Kampala" 2 "Central 1" 3 "Central 2" 4 "East Central" 5 "Eastern" 6 "Mid Northern" 7 "North East" 8 "West Nile" 9 "Mid Western" 10 "South Western"
label values strata lstrata
label variable strata "Geographical stratification variable during sampling (ranging from 1 to 10 sub regions)"
* to ensure that the right districts had been used for the right sub-regions (strata), we checked this by tabbing these sub-regions with rural/urban description and then
** tabbed the big regions (region) with substrat to ensure that the total numbers of Urban/Rural are the same in both
tab strata substrat
tab region substrat
* tab strata substrat
*
* Geographical |
*stratificatio |
*   n variable |
*       during |
*     sampling |
*(ranging from |      substratum
*1 to 10 sub r |     urban      rural |     Total
*--------------+----------------------+----------
*      Kampala |       324          0 |       324 
*    Central 1 |        79        461 |       540 
*    Central 2 |       113      1,123 |     1,236 
* East Central |       203        747 |       950 
*      Eastern |       162        602 |       764 
* Mid Northern |       218        730 |       948 
*   North East |        68        273 |       341 
*    West Nile |       107        446 |       553 
*  Mid Western |       212        482 |       694 
*South Western |       213        863 |     1,076 
*--------------+----------------------+----------
*        Total |     1,699      5,727 |     7,426 
*
*
* tab region substrat
*
*           |      substratum
*    region |     urban      rural |     Total
*-----------+----------------------+----------
*   Central |       516      1,584 |     2,100 
*  Eastern |       414      1,518 |     1,932 
* Northern |       344      1,280 |     1,624 
*  Western |       425      1,345 |     1,770 
*-----------+----------------------+----------
*    Total |     1,699      5,727 |     7,426 
*
***------- Rural-Urban Location
* I checked and the variable is substrat, coded as 3=rural and 1=urban. I will create a new variable with a toolkit same coding 
tab substrat,m
gen rural=1 if substrat==3
replace rural=0 if substrat==1

tab rural,m


label define lrural 0 "Urban" 1 "Rural"
label values rural lrural
label variable rural "Rural/Urban Location"
tab rural,m

** just to confirm that the rural urban specification was not changed, we tabbed again to see if totals are still as before with substrat*
**
*tab rural,m
*
*Rural/Urban |
*   Location |      Freq.     Percent        Cum.
*------------+-----------------------------------
*      Urban |      1,699       22.88       22.88
*      Rural |      5,727       77.12      100.00
*------------+-----------------------------------
*      Total |      7,426      100.00
* 
***-----Regions used for temporal price index calculations
* in the 2009 data analysis, we used the traditions regions that are east, cetral, western and northern. these are well presented in variable region

tab region,m
clonevar reg_tpi = region 
label variable reg_tpi "Regions used for temporal price index calculations"

***------ Spatial domains (each with its own poverty line)
* In the Arndt & Simler 2010 paper the spatial domains are a combinaison of regions and rural/urban delimitations + the capital
* city, however in the 2009/10 data urban sections of the north east and western regions were very small to about 100 observations, yet
** in 2005 data, the smallest section is the northern urban which has 344, households; therefore, we would generate the spatial domains on the 
** region, and rural/urban demarcations, however since Kampala is all urban and has 324 households, and is the capital, we shall consider it alone as 
** in Mozambique, so we have 9 spatial domains
tab region rural,m
tab district rural,m
gen float spdomain=2 if region==1 & rural==0
replace spdomain=3 if region==1 & rural==1
replace spdomain=4 if region==2 & rural==0
replace spdomain=5 if region==2 & rural==1
replace spdomain=6 if region==3 & rural==0
replace spdomain=7 if region==3 & rural==1
replace spdomain=8 if region==4 & rural==0
replace spdomain=9 if region==4 & rural==1
replace spdomain=1 if district==102


label define lspdomain 1 "Kampala" 2 "Central urban" 3 "Central rural" 4 "Eastern urban" 5 "Eastern rural" 6 "Northern urban" 7 "Northern rural" 8 "Western urban" 9 "Western rural" 
label values spdomain lspdomain
label variable spdomain "Spatial domains: each with own poverty line (they are 9)"

tab spdomain rural

***-----News; another way to specify variables, is the traditional Uganda regions, North east central and western, represented in region
clonevar new = region
label variable new "regions north, east, central and western; other ways to dissagregate poverty lines"
rename new news

****-------geo1-geo?; other administrative geographical boundariies where a survey is representative is not required as also done in news rural and others

*** Bootstrap weights: the toolkit requires that this should be=1 for all households and we generate it below

gen float bswt=1
label variable bswt "bootstrap weights; and all equal to 1 for all households, as a toolkit requirement"
 
sort hhid
save "$path/out/hhdata.dta",replace
save "$path/in/hhdata.dta",replace
save "$path/work/hhdata.dta",replace


************************************************************
* Table A2: Individual characteristics - demographics
************************************************************

clear

use "$path/in/hsec2.dta" 


***----- Household members
*According to the enumerator manual of 2005/06, Usual and Regular household members are defined as follows:

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

rename  tid resident
drop if resident==7

***------ Household ID
rename hh hhid
label variable hhid "Household ID"

***------ Individual ID
gen double indid=hhid*100 +  pid
codebook indid
	* There are 42,227 different values, and there are 42,227 observations in the dataset so indid uniquely identifies
		* the individuals
label variable indid "Individual ID"

***------ Sex
rename  h2q4 sex
label variable sex "Sex"

***------ Age
rename  h2q9 age
label variable age "Age in years"

* In order to have the information on whether the mother resides in the house or not we need the file "hsec3"
sort indid
save "$path/in/temp_A2_1.dta",replace

clear
use "$path/in/hsec3.dta" 

***------ Individual ID
rename hh hhid
destring hhid,replace
gen double indid=hhid*100 +  pid
label variable indid "Individual ID"
codebook indid
	* There are 39,434 different values, and there are 39,434 observations in the dataset so indid uniquely identifies
		* the individuals

***----- Mother lives in household?
tab h3q6,m
*There are 60  (ie 0.15 %) missing responses, NOT so bad like for the 2009/10 dataset *
* They have four categories: 1: Yes = 19,715 2: No, Alive = 12,057 3: No, Dead = 7,500 4:No, Don't know = 106. I will group them 
gen motherhh=1 if h3q6==1 
replace motherhh=0 if h3q6==2 | h3q6==3 | h3q6==4
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
use "$path/in/foodcomp_uganda_HHsurvey2005.dta", replace

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

use "$path/in/hsec14a.dta"
sort hh
rename hh hhid
la var hhid "household id"
** we drop alcoholic and tobacco as these were not considered basic in foods generally and by GAPP, these included beer-152, other alcoholic dricns-153
** cigarettes-155, other tobacco-156 and beer taken in restaurants-159, just like we did in the 2009 poverty calculations
drop if inlist( h14aq2 ,152,153,155,156,159)
duplicates report  hhid h14aq2
duplicates list  hhid h14aq2
codebook hhid
egen quantity=rowtotal( h14aq4 h14aq6 h14aq8 h14aq10)
 
la var quantity "quantity of food consumed by the household including purchases, at home, away from home & kind"
** these quantities and values are collected by UBOS at a 7 days basis, thus we divide by 7 to get the daily figures as a requirement by GAPP 
gen quantityd = quantity/7
drop quantity h14aq10 h14aq8 h14aq6 h14aq4
la var quantityd "daily household food consumption"
egen value=rowtotal ( h14aq5 h14aq7 h14aq9 h14aq11 )
la var value "household food consumption in seven days"
gen valuez = value/7
la var valuez "daily value of food consumed by the household"
rename quantityd quantityz
drop value h14aq11 h14aq9 h14aq7 h14aq5 h14aq13 h14aq12
gen unit = 1
la var unit "set equal to one since all observations are converted into kg"
gen food_cat = 1
la var food_cat "food category equals 1, if product is food and 0 if non food"

des hhid
des food_cat
des valuez
rename h14aq2 product
format %10.0g product
format %9.0g hhid
format %10.0g unit
la var product "Food product code: numerical"
destring product, replace
save "$path/in/household_table4.dta", replace
save "$path/out/household_table4.dta", replace
save "$path/work/household_table4.dta", replace
set more off
count
sort product h14aq3

** to the quantities of the food in standard unite, the Kilograms, a file called conversion factors was generated in excel with details
** of the sources of information, located in the "in" folder named "ucf_uganda_UNSH2005.xls" and a STATA extract of both excel and STATA use named
** "conversionfactors.xls AND .dta" is also in the in folder for use below. The file has equivalents of local units into kilograms and 
** we need it to convert the local units used in food consumption bundles into kilograms. Since the foods and the local units were the same, this file is 
** similar to the one used for the 2009 data
merge m:1 product h14aq3 using  "$path/in/conversionfactors.dta"
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
use "$path/in/hsec4.dta"

rename hh hhid
codebook hhid
keep hhid h4q10f
sort hhid
** since total education expenses were clooected in h4q10f and since is at yearly basis, we divided it by 365 to get daily expenses on education
gen educationd = h4q10f/365
la var educationd "daily household expense on education"
drop h4q10f
save "$path/out/hhdeducationexp.dta", replace

clear

use "$path/in/hsec5.dta"

des
rename hh hhid
sort hhid
keep hhid h5q10 h5q11
egen medicalexp = rowtotal ( h5q10 h5q11)
gen medicalexpd = medicalexp/30
la var medicalexpd "household daily expenditure"
drop h5q10 h5q11 medicalexp
save "$path/out/hhdmedicalexp.dta", replace

clear
set more off 
use "$path/in/hsec12a.dta"
des
save "$path/out/hhddurables.dta", replace
keep if inlist( h12aq2 ,010,011,012)
 
gen assetvalue = h12aq5

**************************************************************************************************************
** i took land, bicycle, motor cycle and other transport equipment-012, that in 2009 were motor vehicles, as durables and assumed that a year, the household can use 10% of these assests. there was no land in 2005 assets
** house not treated as an asset as the toolkit takes care of imputed rent
************************************************************************************************************************
gen dassetvalue = (assetvalue*0.1)/365
la var dassetvalue "household daily durables expenditure"
rename hh hhid
sort hhid
save "$path/out/hhddurablesexp.dta", replace

clear

use "$path/in/hsec12a.dta"
save "$path/out/hhnondurables.dta", replace
rename hh hhid
drop if inlist(  h12aq2 ,010,011,012 ,001)
gen nondurablevalue = h12aq5
**h12aq4 multiple has been dropped since UBOS had recorded h12aq5 as total estimated value in Ush and also discounted them by 10% to get rough value used per year
*** we considered other buildings-002, furniture-003, Bednets-005, Hh appliances as Kettle,flat iron-006, electronics as tv,radio-007, generators-008, solar-panel-009
*** , jewelry&watches-013, mobilephone-014, otherassets as lawn mores-015, Enterprise assests like; home-101, ploughs-102, wheelbarrows-104, pangas-103
**  others-105, 106 and 107 and financial assets-201, NOTE: figures are codes in data set
la var nondurablevalue "household daily non-durables expenditure"
sort hhid
gen dnondurables = (nondurablevalue*0.1)/365
la var dnondurables "household daily non-durables expenditure"
save "$path/out/hhdnondurablesexp.dta", replace

clear

use "$path/in/hsec14b.dta"
des
rename hh hhid
sort hhid
** here we considered rent of rented house-301, imputed rent of own house-302, imputed rent of free given house-303, repair expenses-304, water-305 
** electricity-306, generator fuels-307, parafin-308, charcoal-309, firewood-310, matches-451, washing soap-452, bathing soap-453, toothpaste-454, 
** taxifares-463, and expenditure on phones not owned-468
** and we dropped others-311, cosmetics-455, handbags-456, batteries-drycells-457, newspapers-458, others-459, tires-461, petrol-462, 
*** bus fares-464, bodaboda fare-465, stamps/envelops-466, mobilephoneairtime-467 and others-469,health fees as consultation-501, medicine-502
*** hospitalcharges-503, traditionaldoctors-504, others-509 since medical expenses were cosidered in section 5, sports/theater-701,
**  drycleaning-702, houseboys-703, barbers&beauty shops-704 and lodging-705. THESE HAVE BEEN CONSIDERED NON BASIC

drop if inlist( h14bq2 ,311,455,456,457,458,459,461,462,464,465,466,467,469,501,502,503,504,509,701,702,703,704,705)
 
egen hhfrequents = rowtotal ( h14bq5 h14bq7 h14bq9)
gen dhhfrequents = hhfrequents/30
la var dhhfrequents "daily household expenditure on frequently bought commodities"

save "$path/out/hhdfrequentsexp.dta", replace

clear

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
gen hhdsemidurs = (hhsemidurables*0.1)/365
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

use "$path/out/hhdnondurablesexp.dta"
collapse (sum) dnondurables , by(hhid)
sort hhid
save "$path/out/hhdnondurablesexp.dta", replace

use "$path/out/hhdeduc&medic&durabex.dta"
merge 1:1 hhid using "$path/out/hhdnondurablesexp.dta"
drop _merge
sort hhid
save "$path/out/hhdeduc&medic&durab&nondurabex.dta", replace



use "$path/out/hhdfrequentsexp.dta"
collapse (sum) dhhfrequents , by(hhid)
sort hhid
save "$path/out/hhdfrequentsexp.dta", replace

use "$path/out/hhdeduc&medic&durab&nondurabex.dta"
merge 1:1 hhid using "$path/out/hhdfrequentsexp.dta" 
drop _merge
sort hhid
save "$path/out/hhdeduc&medic&durab&nondurab&freqsex.dta", replace

use "$path/out/hhdsemidurablesexp.dta"
collapse (sum) hhdsemidurs , by(hhid)
sort hhid
save "$path/out/hhdsemidurablesexp.dta", replace

use "$path/out/hhdeduc&medic&durab&nondurab&freqsex.dta"
merge 1:1 hhid using "$path/out/hhdsemidurablesexp.dta"
drop _merge
replace hhdsemidurs=0 if hhdsemidurs==.
sort hhid
save "$path/out/hhdeduc&medic&durab&nondurab&freqs&semidurabex.dta", replace

use "$path/out/hhdnonconsumpexp.dta"
collapse (sum) hhdnonconsumpexp , by(hhid)
sort hhid
save "$path/out/hhdnonconsumpexp.dta", replace

use "$path/out/hhdeduc&medic&durab&nondurab&freqs&semidurabex.dta"
merge 1:1 hhid using "$path/out/hhdnonconsumpexp.dta"
drop _merge
replace hhdnonconsumpexp=0 if hhdnonconsumpexp==.
sort hhid
save "$path/out/hhdeduc&medic&durab&nondurab&freqs&semidurab&nonconsmpex.dta", replace

gen hhnonfoodexp =  educationd+medicalexpd+dassetvalue+dnondurables+dhhfrequents+hhdsemidurs+hhdnonconsumpexp
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
drop h14aq3
replace descript=1 if descript==.
label drop _all
save "$path/out/cons_cod.dta", replace
save "$path/work/cons_cod.dta", replace
save "$path/in/cons_cod.dta", replace


