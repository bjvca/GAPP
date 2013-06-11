
*********************************************************************
*********************************************************************
**
**     PROGRAMME:    preparation of tables_A1_to_A3       
**     AUTHOR:       HARUNA SEKABIRA
**     OBJECTIVE:    Create standard tables A1 to A3 for UNHS 2009/2010
**
**     DATA IN:      HSEC1.dta
**					 HSEC2.dta
**					 HSEC3.dta
**					 
**
**     DATA OUT:     hhdata.dta (table A1)
**					 indata.dta (table A2)
**					 calperg.dta (table A3)
**					
**
**     NOTES:				
**
**************************************************************************

clear
set logtype text
capture log close
set more off

global path"C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA"

**************************************************************
* Table A1: Household Characteristics and interview details
**************************************************************

use "$path\in\HSEC1.dta" 
*keep

***------- Primary Sampling Unit
* The primary sampling unit for the 2009 UNHS is the enumeration area.
codebook ea 
	/* There are 711 unique values, the UNHS report mentions 712 */
rename ea psu
label variable psu "Primary Sampling Unit"

***------- Interview Quarter
* For the Mozambique Data, instead of using the regular quarter definition for their "surquar" variable they defined the quarters
* relative to the time period covered by the survey: the survey ran from Sept 2008 to August 2009 so they defined the quarters
* as follows: Sept-Nov 08, Dec08-Feb09, Mar-May 08 and June-Aug 08.
* I will use the same framework
tab month Year,m 
	/* According to the repartition of months and year, the survey ran from May 2009 to April 2010. I will define the
	 * the quarters accordingly. It should be noted that no data was collected in August 2009 so the 2nd quarter I am 
	 * defining only has two months's worth of survey data */
gen float survquar=1 if month>=5 & month<=7 & Year==2009
replace survquar=2 if month>=8 & month<=10  & Year==2009
replace survquar=3 if (month>=11 & month<=12  & Year==2009) | (month==1  & Year==2010)
replace survquar=4 if month>=2 & month<=4  & Year==2010
label define lsurvquar 1 "May-Jul 09" 2 "Sept-Oct 09" 3 "Nov09-Jan10" 4 "Feb-Apr 10"
label values survquar lsurvquar
label variable survquar "Sequential Survey Quarter May-Jun 09=1)"

***------- Sequential Interview month 
* Following the Mozambique file, I am creating a survey month variable rather than an interview date variable as per the excel sheet
* Number 1 corresponds to the first month of the survey and not to January.
gen float survmon=1 if month==5 & Year==2009
replace survmon=2 if month==6 & Year==2009
replace survmon=3 if month==7 & Year==2009
replace survmon=4 if month==8 & Year==2009
replace survmon=5 if month==9 & Year==2009
replace survmon=6 if month==10 & Year==2009
replace survmon=7 if month==11 & Year==2009
replace survmon=8 if month==12 & Year==2009
replace survmon=9 if month==1 & Year==2010
replace survmon=10 if month==2 & Year==2010
replace survmon=11 if month==3 & Year==2010
replace survmon=12 if month==4 & Year==2010
#delim;
label define lsurvmon 1 "May 09" 2 "Jun 09" 3 "Jul 09" 4 "Aug 09" 5 " Sep 09" 6 "Oct 09"
						7 "Nov 09" 8 "Dec 09" 9 "Jan 10" 10 "Feb 10" 11 "Mar 10" 12 "Apr 10";
#delim cr
label values survmon lsurvmon
tab survmon month,m
label variable survmon "Sequential Survey Month (May 2009=1)"

***------- Household Sample Weight
rename hmult hhweight
label variable hhweight "Household sample weight"

***------- Household id
codebook hh /*there are  6775 different values and 6775 observations in the dataset so the variable "hh" uniquely identifies the observations */
rename hh hhid
label variable hhid "Household ID"

***------- Household Size
rename hsize hhsize
label variable hhsize "Household Size"

***------- Geographical Stratification during sampling
* As indicated in the survey report, EAS were drawn from a geographical grouping into regions and rural-urban location.
* A variable in the file is already identified as the strata, and there are indeed 10 of them as indicated in the report
tab sregion,m
rename sregion strata
label variable strata "Strata"

***------- Rural-Urban Location
* I checked and the code is the opposite of the one in the Mozambique data file: 1=rural 0=urban. I will create a new variable
* that has the same coding 
tab urban,m
gen float rural=(urban==0)
replace rural=0 if urban==1
tab rural,m
label define lrural 0 "Urban" 1 "Rural"
label values rural lrural
label variable rural "Rural/Urban Location"

***-----Regions used for temporal price index calculations
*  we used the traditions regions that are east, cetral, western and northern. these are well presented in variable region
tab region,m
clonevar reg_tpi = region 
label variable reg_tpi "Regions used for temporal price index calculations"


***------ Spatial domains (each with its own poverty line)
tab regurb
* In the Arndt & Simler 2010 paper the spatial domains are a combinaison of regions and rural/urban delimitations + the capital
* city as a separate domain (confirmed in the Mozambique data file)
*--> for uganda; urban sub regions of eastern, northern and western had very few households 132, 172, 107 respectively, 
** thus we only separated the central region into rural/urban and others were aggregated for northern, eastern and western to have 5 spatial domains
gen float spdomain=1 if regurb==10
replace spdomain=2 if regurb==11
replace spdomain=3 if regurb==20 | regurb==21
replace spdomain=4 if regurb==30 | regurb==31
replace spdomain=5 if regurb==40 | regurb==41

label define lspdomain 1 "central rural" 2 "Central urban" 3 "Eastern" 4 "Northern" 5 "Western"  
label values spdomain lspdomain
label variable spdomain "Spatial domains: each with own poverty line (they are 5)"

***-----News; another way to specify variables, is the traditional Uganda regions, North east central and western, represented in region
tab region
clonevar new = region
label variable new "regions north, east, central and western; other ways to dissagregate poverty lines"
rename new news

****-------geo1-geo?; other administrative geographical boundariies where a survey is representative is not required as also done in news rural and others

*** Bootstrap weights: the toolkit requires that this should be=1 for all households and we generate it below

gen float bswt=1
label variable bswt "bootstrap weights; and all equal to 1 for all households, as a toolkit requirement"

sort hhid
save "$path\out\hhdata.dta",replace
save "$path\in\hhdata.dta",replace
save "$path\work\hhdata.dta",replace

************************************************************
* Table A2: Individual characteristics - demographics
************************************************************

clear
use "$path\in\HSEC2.dta" 


***----- Household members
/* According to the enumerator manual, Usual and Regular household members are defined as follows:

Usual members are defined as those persons who have been living in the household for 6 months or
more during the last 12 months. However, members who have come to stay in the household permanently
are to be included as usual members, even though they have lived in this household for less than 6
months. Furthermore, children born to usual members on any date during the last 12 months will be taken
as usual members. Both these categories will be given code "1" or "2" depending upon whether they are
present or absent on the date of the interview.

Regular members refer to those persons who would have been usual members of this household, but
have been away for more than six months during the last 12 months, for education purposes, search of
employment, business transactions etc. and living in boarding schools, lodging houses or hostels etc.
These categories will be given code "3" or "4" depending upon presence or absence on the date of the
interview. */

/* 
* For the purposes of the calculation of a poverty line we'll exclude from the household the members who have left 
the household permanently or died
*  We'll keep the members away for more than 6 months but present on the day of the interview
--> We'll remove some of these members later on depending on the expenditure aggregates being computed
*/

rename  h2q5 resident
drop if resident==7

***------ Household ID
rename hh hhid
label variable hhid "Household ID"

***------ Individual ID
gen double indid=hhid*100 +  h2q1
codebook indid
	* There are 35,945 different values, and there are 35,945 observations in the dataset so indid uniquely identifies
		* the individuals
label variable indid "Individual ID"

***------ Sex
rename  h2q3 sex
label variable sex "Sex"

***------ Age
rename  h2q8 age
label variable age "Age in years completed"

* In order to have the information on whether the mother resides in the house or not we need the file "HSEC3"
sort indid
save "$path\work\temp_A2_1.dta",replace

clear
use "$path\in\HSEC3.dta" 

***------ Individual ID
rename hh hhid
destring hhid,replace
gen double indid=hhid*100 +  h3q1
label variable indid "Individual ID"
codebook indid
	* There are 35,945 different values, and there are 35,945 observations in the dataset so indid uniquely identifies
		* the individuals

***----- Mother lives in household?
tab h3q3,m
*!!!! There are 14,795  (ie 42.47 %) missing responses  !!!!*
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*
* They have four categories: 1: Yes 2: No, Alive 3: No, Dead 4:No, Don't know. I will group them 
gen motherhh=1 if h3q3==1 
replace motherhh=0 if h3q3==2 | h3q3==3 | h3q3==4
label variable motherhh "Mother lives in hh"
label define lmoth 0 "No" 1 "Yes"
label values motherhh lmoth

keep indid motherhh
sort indid
merge 1:1 indid using "$path\work\temp_A2_1.dta"
tab _merge
	* There are some obs coming only from the using data. The explanation is that Section 3 of the questionnaire 
	* is administered only to usual and regular household members, as is confirmed by the cross tab below
	tab resident _merge
	* We leave the variable as is, with additional missing values for the variable "motherhh".
drop _merge

keep hhid indid sex age motherhh
save "$path\in\inddata.dta",replace
save "$path\out\inddata.dta",replace
save "$path\work\inddata.dta",replace


**********************************************
* Table A3: Calorie content of food items
**********************************************
* I compiled the calorie content and edible portion in an excel file then converted that file into a STATA file
* The excel file (with more detailed information, inculding the sources) is in the "in" folder

* Note: in order to have the description of the food items in a separable variable (in the STATA file they are a label of the
* variable "produc"), I created an excel file called fooditems_2009_excel that I used to compile the calorie content.

clear
use "$path\in\foodcomp_uganda_HHsurvey2009_v5.dta", replace

* Since they did not include edible portions in the file I assume that the calorie per gram is only for the edible portion.
* I will therefore compute calperg that way
gen double calperg=((kcal_100g*edible)/100)/100
keep product descript calperg
label variable product "Food product code: numerical"
label variable descript "Product Description: incl. product code in the beginning"
label variable calperg "Calorie content of food product: calories per gram"
sort product 

save "$path\out\calperg.dta",replace
save "$path\in\calperg.dta",replace
save "$path\work\calperg.dta",replace

