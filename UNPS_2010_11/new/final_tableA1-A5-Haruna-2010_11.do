**     PROGRAMME:    preparing_household data_2011-2012 for Uganda_tables_A1_to_A5      
**     AUTHOR:       HARUNA SEKABIRA
**     OBJECTIVE:    Create standard tables A1 to A5 for UNPS 2011/2012
**     DATA IN:      GSEC1.dta
**					 GSEC2.dta
**					 GSEC3.dta
**                   GSEC15B.dta, etc.
**     DATA OUT:     hhdata.dta (table A1)
**					 indata.dta (table A2)
**					 calperg.dta (table A3)
**                   cons_cod_trans.dta (table A4)
**                   cons_cod.dta (table A5), 
**     NOTES:		the files in the in folder here have been copied from the World Bank Website (http://go.worldbank.org/VX1NA9WGC0) and original zipped folder put in the "in" folder
clear
set logtype text
capture log close
set more off
if c(os)=="Unix" {
global path "/home/bjvca/data/data/GAP/Haruna/UNPS_2010_11/"
}
else{
global path "C:\Users\Haruna\Desktop\GAPP\UNPS_2012_11"
}


* ====================Table A1==========================: Household Characteristics and interview details
use "$path/in/GSEC1.dta" 
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
codebook HHID 
rename HHID hhid
label variable hhid "Household ID"
***------- Geographical Stratification during sampling

rename  stratum strata
label variable strata "Geographical stratification variable during sampling (ranging from 1 to 6 sub regions)"
***----------------------rural/urban identifier 
tab urban
gen rural=1 if urban==0
replace rural=0 if urban==1
label define lrural 1 "Rural" 0 "Urban"
la values rural lrural
label variable rural "Rural/Urban Location"
tab rural,m

***------ Spatial domains (each with its own poverty line)
tab regurb
*RegionxRural/ |
*        Urban |      Freq.     Percent        Cum.
*--------------+-----------------------------------
*            1 |          1        0.04        0.04
*Central rural |        590       20.70       20.74
*Central urban |        256        8.98       29.72
*   East rural |        566       19.86       49.58
*   East urban |         89        3.12       52.70
*  North rural |        596       20.91       73.61
*  North urban |        143        5.02       78.63
*   West rural |        514       18.04       96.67
*   West urban |         95        3.33      100.00
*--------------+-----------------------------------
*        Total |      2,850      100.00
* In the Arndt & Simler 2010 paper the spatial domains are a combinaison of regions and rural/urban delimitations + the capital
* city, however in the 2010/11 some urban sections have far less than 200 respondents, so we shall combine all other regions 
* (rural + urban)except the central since its urban would be boosted by Kampala, getting us 5 spatial domains


gen float spdomain=1  if regurb==10 | regurb==11 | regurb==.
replace spdomain=2 if regurb==20 | regurb==21
replace spdomain=3 if regurb==30 | regurb==31
replace spdomain=4 if regurb==40 | regurb==41


label define lspdomain 1 "Central" 2 "Eastern" 3 "Northern" 4 "Western" 
label values spdomain lspdomain
label variable spdomain "Spatial domains: each with own poverty line (they are 4)"
*just to confirm allocations

***-----Regions used for temporal price index calculations
tab region,m 


***---------------News; another way to specify variables, is the traditional Uganda regions, North east central and western, represented in region
gen float news=1 if regurb==11 | regurb==10 | regurb==.
replace news=2  if regurb==20 | regurb==21
replace news=3  if regurb==30 | regurb==31
replace news=4  if regurb==40 | regurb==41
label define lnews 1 "Central" 2 "Eastern" 3 "Northern" 4 "Western" 
label values news lnews
label variable new "regions north, east, central and western; other ways to dissagregate poverty lines"

clonevar reg_tpi = news
label variable reg_tpi "Regions used for temporal price index calculations"

****-------geo1-geo?; other administrative geographical boundariies where a survey is representative is not required as also done in news rural and others
*** -------------------Bootstrap weights: the toolkit requires that this should be=1 for all households and we generate it below
gen float bswt=1
label variable bswt "bootstrap weights; and all equal to 1 for all households, as a toolkit requirement"
sort hhid
save "$path/in/hhdata_hhsize.dta",replace
save "$path/out/hhdata_hhsize.dta",replace
**** --------------------------------Household size
** Since we need Household size in the hhdata.dta, and it was unavailable in the GSEC1.dta, we use the Unique person identifier in GSEC2.dta
**** --------------------------------Household size
** Since we need Household size in the hhdata.dta, and it was unavailable in the GSEC1.dta, we use the Unique person identifier in GSEC2.dta

use "$path/in/GSEC2.dta"
keep if h2q7==1
bysort HHID: gen pid=_n
order HH pid
gen counter=1
gen equiv=.
replace equiv=.33 if  (h2q8==0) 
replace equiv=.46 if  (h2q8==1) 
replace equiv=.54 if  (h2q8==2) 
replace equiv=.62 if  (h2q8==3 | h2q8==4) 

replace equiv=.74 if h2q3==1 &  (h2q8==5 | h2q8==6) 
replace equiv=.70 if h2q3==0 &  (h2q8==5 | h2q8==6) 

replace equiv=.84 if h2q3==1 &  (h2q8>6 & h2q8<10) 
replace equiv=.72 if h2q3==0 & (h2q8>6 & h2q8<10) 

replace equiv=.88 if h2q3==1 &  (h2q8==10 | h2q8==11) 
replace equiv=.78 if h2q3==0 &  (h2q8==10 | h2q8==11) 

replace equiv=.96 if h2q3==1 &  (h2q8==12 | h2q8==13) 
replace equiv=.84 if h2q3==0 &  (h2q8==12 | h2q8==13) 

replace equiv=1.06 if h2q3==1 &  (h2q8==14 | h2q8==15) 
replace equiv=.86 if h2q3==0 &  (h2q8==14 | h2q8==15) 

replace equiv=1.14 if h2q3==1 &  (h2q8==16 | h2q8==17) 
replace equiv=.86 if h2q3==0 &  (h2q8==16 | h2q8==17) 

replace equiv=1.04 if h2q3==1 &  (h2q8>17 & h2q8<30) 
replace equiv=.80 if h2q3==0 & (h2q8>17 & h2q8<30) 

replace equiv=1.00 if h2q3==1 &  (h2q8>29 & h2q8<60) 
replace equiv=.82 if h2q3==0 & (h2q8>29 & h2q8<60) 

replace equiv=0.84 if h2q3==1 &  (h2q8>59 ) 
replace equiv=.74 if h2q3==0 & (h2q8>59) 

collapse (sum) equiv counter, by (HHID)



rename counter hhsize

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
*====================== Table A2===================================: Individual characteristics - demographics
clear
use "$path/in/GSEC2.dta" 
sort HHID
***----- Household members
*According to enumerator manual of 2011/12, Usual and Regular household members are defined as : *Usual members: those persons who have been living in the 
*household for 6 months or more during the last 12 months. members who have come to stay in the household permanently usual members, even though they have 
*lived in this household for less than 6 *months. children born to usual members during the last 12 months are usual members. Both these categories will 
*be given code "1" or "2" depending upon whether they are present or absent on the date of the interview. *Regular members refer to those persons who would 
*have been usual members of this household, but have been away for more than six months during the last 12 months, for education purposes, search of
*employment, business transactions etc. and living in boarding schools, lodging houses or hostels etc.*These will be coded "3" or "4" depending upon presence 
*or absence on the date of the interview. For the purposes of the calculation of a poverty line we'll exclude from the household the members who have left 
*the household permanently or died We'll keep the members away for more than 6 months but present on the day of the interview */
rename  h2q7 resident
drop if resident==7
***------ Household ID
rename HHID hhid
label variable hhid "Household ID"
***------ Individual ID
destring hhid PID, replace
gen double indid = hhid*100 +  PID
codebook indid
* There are 17,043 different values, and there are 17,128 observations in the dataset so we drop a few duplicated observations
duplicates report indid
duplicates list indid
duplicates drop indid, force
codebook indid 
*there are now 17043 and 17,043 observations implying that indid now uniquely identifies the data
label variable indid "Individual ID"
***------ Sex
rename  h2q3 sex
label variable sex "Sex"
***------ Age
rename  h2q8 age
label variable age "Age in years"
* In order to have the information on whether the mother resides in the house or not we need the file "GSEC3"
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
* There are 15,998 different values, and there are 16,078 observations in the dataset so duplicates need be eliminated
duplicates report indid
duplicates list indid
duplicates drop indid, force
codebook indid 
*there are now 17,043 unique values and 17,043 observations implying that indid now uniquely identifies the data
***----- Mother lives in household?
tab h3q5a,m
*There are 6,882  (ie 42.8 %) missing responses,: 1: Yes = 6,768 2: No = 2,065 3: Dead = 363 4: Missing = 6,882. I will group them 
gen motherhh=1 if h3q5a==1 
replace motherhh=0 if h3q5a==2 | h3q5a==3 | h3q5a==.
label variable motherhh "Mother lives in hh"
label define lmoth 0 "No" 1 "Yes"
label values motherhh lmoth
keep indid motherhh
sort indid
merge 1:1 indid using "$path/in/temp_A2_1.dta"
tab _merge
drop _merge
keep hhid indid sex age motherhh
save "$path/out/indata.dta",replace
save "$path/in/indata.dta",replace
* ========================Table A3============================: Calorie content of food items
* we compiled the calorie content and edible portion in an excel file then converted that file into a STATA file located in "in" folder
clear
use "$path/in/foodcomp_uganda_PANNELsurvey2011.dta"
* Since they did not include edible portions in the file I assume that the calorie per gram is only for the edible portion.
* ----------- computing calperg that way
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
clear
* ===================Table A4=============: Amount and Quantity of food transactoin - Transaction level
use "$path/in/GSEC15B.dta"
sort HHID
rename HHID hhid
la var hhid "household id"
** we drop alcoholic and tobacco as these were not considered basic in foods generally and by GAPP, these included beer-152, other alcoholic dricns-153
** cigarettes-155, other tobacco-156 and beer taken in restaurants-159, just like we did in the 2009 poverty calculations
*drop if inlist( itmcd ,152,153, 155,156, 157, 158,159)
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
rename itmcd product
la var product "Food product code: numerical"
destring product, replace
save "$path/in/household_table4.dta", replace
save "$path/out/household_table4.dta", replace
count
sort product untcd

replace product=100 if product==101  | product==102  | product==103  | product==104

** to convert quantities of food in standard units, the Kilograms, a file called "conversions_all.dta" generated by Fiona with equivalents of local units into 
* kilograms located in the "in" folder was used. for UNPS 2009, and 2010 data we used "Conversionfactors.dta", by Haruna, also in "in" folder
merge m:1 product untcd using  "/home/bjvca/data/data/GAP/Haruna/conversionfactors_corrected_onlyUNPS.dta"
tab _m
drop _m
*label drop _all
save "$path/in/household_table4cf.dta", replace
save "$path/out/household_table4cf.dta", replace
gen quantity = quantityz * qkg_uca
la var quantity "daily quantity consumed in Kgs per household"
la var value  "daily value of consumption in UGX per per household"
sort hhid
label drop _all
destring hhid, replace
drop if product==.
save "$path/out/cons_cod_trans.dta", replace
save "$path/in/cons_cod_trans.dta", replace
**================ Table 5===============: TOTAL AMOUNT AND QUANTITY OF PRODUCTS: Food as well as non food
**  DATA IN:       GSEC4.dta : On Education costs, column h4q15g which has all total school expenses, it is on 365 dayss basis
**                 GSEC5.dta : On Medical Expenditure, column h5q12, on 30 days basis
**                 GSEC14.dta : On assets Expenditure, column h14q5 on total estimated present value, considering 10% value used per 365 days basis
**                 GSEC15C.dta: On non-durables and frequently purchased items e.g imputed rent, electricity, soap etc,on 30days basis, columns h15cq: 5,7 & 9 for value
**                 GSEC15D.dta: On semi-durable goods and services e.g. clothes, furniture, equipments, column; h15dq:5,7&9, on 365 days basis for value
**                 GSEC15E.dta:     On Non-consumption expenses like taxes, remitances away, subscriptions etc, on 365 days basis, colum 3::file is MISSING in W.B, data supplied
**  DATA OUT: cons_cod.dta
clear
***----------------------calculating Education expenses
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
clear
**---------------------calculating medical expenses
use "$path/in/GSEC5.dta"
rename HHID hhid
sort hhid
keep hhid h5q12 
rename h5q12 medicalexp
gen medicalexpd = medicalexp/30
replace medicalexpd=0
la var medicalexpd "household daily expenditure"
save "$path/out/hhdmedicalexp.dta", replace
clear
****---------------calculating expenses on basic durable assests
use "$path/in/GSEC14.dta"
des
save "$path/out/hhddurables.dta", replace
keep if inlist( h14q2 ,02,03,10,11,12,13) 
gen assetvalue = h14q5
** i took land-03, bicycle-10, motor cycle-11 and motorvehicle-12, boat-13 and other buildings-02, as durables and assumed that a year, 
** the household can use 0.1% of these assests, just to limit the influence of assests that were inflating unnecessarily especially the urban poverty estimates,
** house not treated as an asset as the toolkit takes care of imputed rent
gen dassetvalue = (assetvalue*0.001)/365
replace dassetvalue=0
la var dassetvalue "household daily durables expenditure"
rename HHID hhid
sort hhid
save "$path/out/hhddurablesexp.dta", replace
clear
**----------------------calculating expenses on basic non durable assest
use "$path/in/GSEC14.dta"
save "$path/out/hhnondurables.dta", replace
rename HHID hhid
*drop if inlist(  h14q2 ,01,02,03,10,11,12,13)
gen nondurablevalue = h14q5
** also discounted them by 1% to get rough value used per year, we considered furniture-04, Hh appliances as Kettle,flat iron-05, electronics as tv-06, 
*radio-07, generators-08, solar-panel-09, other transport mean -14, jewelry&watches-15, mobilephone-16, computer-17, internet-18, other elwctronics-19, 
*otherassets as lawn mores-20,  others;-21 & 22, NOTE: figures are codes in data set
la var nondurablevalue "household daily non-durables expenditure"
sort hhid
gen dnondurables = (nondurablevalue)/365
replace dnondurables=0
la var dnondurables "household daily non-durables expenditure"
save "$path/out/hhdnondurablesexp.dta", replace
clear
***-------------------calculating expenses on basic frequently bought items
use "$path/in/GSEC15C.dta"
des
rename HHID hhid
sort hhid
** here we considered rent of rented house-301, imputed rent of own house-302, imputed rent of free given house-303, repair expenses-304, water-305 
** electricity-306, generator fuels-307, parafin-308, charcoal-309, firewood-310, matches-451, washing soap-452, bathing soap-453, toothpaste-454, 
** taxifares-463, and expenditure on phones not owned-468, and we dropped others-311, cosmetics-455, handbags-456, batteries-drycells-457, newspapers-458, 
* others-459, tires-461, petrol-462, bus fares-464, bodaboda fare-465, stamps/envelops-466, mobilephoneairtime-467 and others-469,health fees as 
*consultation-501, medicine-502, hospitalcharges-503, traditionaldoctors-504, others-505 since medical expenses were cosidered in section 5, 
* sports/theater-601, drycleaning-602, houseboys-603, barbers&beauty shops-604 and lodging-605. THESE HAVE BEEN CONSIDERED NON BASIC
*drop if inlist( h15cq2 ,311,455,456,457,458,459,461,462,464,465,466,467,469,501,502,503,504,505,601,602,603,604,605)
egen hhfrequents = rowtotal ( h15cq5 h15cq7 h15cq9)
gen dhhfrequents = hhfrequents/30
la var dhhfrequents "daily household expenditure on frequently bought commodities"
save "$path/out/hhdfrequentsexp.dta", replace
clear
****------------------calculating basic expenses on semi durables
**   in considering semi durable goods and services, the value of those services and goods recieved in kind, column h15dq9 of GSEC15D.dta has been excluded
**   just as in kind food consumptions were eliminated in table 4 as per the GAPP guidelines, These have also been discounted by 10% usage per year
use "$path/in/GSEC15D.dta"
save "$path/out/hhsemidurables.dta", replace
des
sort HHID
rename HHID hhid
** we have considered the following men clothing-201, womenclothing-202, childrenclothing-203, men footware-206, women footware-207, children footware-208
** bedding mattress-304, blankets-305, charcoal/parafin stoves-402, plastic plates and tumblers-502, and dropped other clothing-204, tailoring materials-205, 
*other footware-209, furniture items-301, carpets-302, curtains&bedsheets-303, others-306, kettles-401, tv&radio-403, byclcles-404, radio-405, motors-406, 
*motorcycles-407,computers-408, phone handsets-409, others-410, jewelry&watches-411,glass/table ware of codes 501 and 503-506, education cost (601-605)
*as education done in section 4, and others like functions & premiums (701-703) ** as these have been consideered NON BASIC
*drop if inlist( h15dq2 ,204,205,208,209,301,302,303,306,401,403,404,405,406,407,408,409,410,411,501,503,504,505,506,601,602,603,604,605,701,702,703)
egen hhsemidurables = rowtotal ( h15dq5 h15dq7 h15dq9)
sort hhid
gen hhdsemidurs = (hhsemidurables)/365
*replace hhdsemidurs=0
la var hhdsemidurs "household daily semi durables goods and seervices expenses"
drop hhsemidurables
save "$path/out/hhdsemidurablesexp.dta", replace
clear



use "$path/in/GSEC15D.dta"
keep if h15dq2>800 & h15dq2<900
save "$path/in/hhnonconsmpexptaxes.dta", replace
sort HHID
rename HHID hhid
** we only considered graduated tax-904, that may cause arrest if not paid and it used to be per head paid to local government annually
** and dropped income tax-901, property tax-902, user fees-903, social security payments-905, remmitances-906, funerals-907 and others-909

gen hhdnonconsumpexp = h15dq5/365

replace hhdnonconsumpexp=0
la var hhdnonconsumpexp "hh daily expenditure on taxes, contributions, donations, duties, etc"
sort hhid
save "$path/out/hhdnonconsumpexp.dta", replace
clear


****-----------------------calculating basic non-consumption expenses
** The file GSEC15E.dta, where this information was kept was absent
** after generating all daily non food total household expenditures of various considered items, then we start merging these  SIX hhd--- prefixed files, and ending with sufix exp to get all non food hh daily expenditure
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
replace medicalexpd=0 if medicalexpd==.
replace educationd=0 if educationd==.
drop _merge
sort hhid
save "$path/out/hhdeduc&medicex.dta", replace
use "$path/out/hhddurablesexp.dta"
collapse (sum) dassetvalue , by(hhid)
sort hhid
save "$path/out/hhddurablesexp.dta", replace
use "$path/out/hhdeduc&medicex.dta"
merge 1:1 hhid using "$path/out/hhddurablesexp.dta"
replace dassetvalue=0 if dassetvalue==.
drop _merge
sort hhid
save "$path/out/hhdeduc&medic&durabex.dta", replace

gen dnondurables=0
sort hhid
save "$path/out/hhdnondurablesexp.dta", replace
use "$path/out/hhdeduc&medic&durabex.dta"
merge 1:1 hhid using "$path/out/hhdnondurablesexp.dta"
replace dnondurables=0 if dnondurables==.
drop _merge
sort hhid
save "$path/out/hhdeduc&medic&durab&nondurabex.dta", replace
clear
use "$path/out/hhdfrequentsexp.dta"
tostring hhid, force replace
collapse (sum) dhhfrequents , by(hhid)
sort hhid
tostring hhid, force replace
save "$path/out/hhdfrequentsexp.dta", replace
use "$path/out/hhdeduc&medic&durab&nondurabex.dta"
merge 1:1 hhid using "$path/out/hhdfrequentsexp.dta" 
replace dhhfrequents=0 if dhhfrequents==.
drop _merge
sort hhid
save "$path/out/hhdeduc&medic&durab&nondurab&freqsex.dta", replace

use "$path/out/hhdsemidurablesexp.dta"
tostring hhid, force replace
collapse (sum) hhdsemidurs , by(hhid)
sort hhid
tostring hhid, force replace
save "$path/out/hhdsemidurablesexp.dta", replace
use "$path/out/hhdeduc&medic&durab&nondurab&freqsex.dta"
merge 1:1 hhid using "$path/out/hhdsemidurablesexp.dta"
replace hhdsemidurs=0 if hhdsemidurs==.
drop _merge
sort hhid
save "$path/out/hhdeduc&medic&durab&nondurab&freqs&semidurabex.dta", replace

use "$path/out/hhdnonconsumpexp.dta"
tostring hhid, force replace
collapse (sum) hhdnonconsumpexp , by(hhid)
sort hhid
tostring hhid, force replace
save "$path/out/hhdnonconsumpexp.dta", replace
use "$path/out/hhdeduc&medic&durab&nondurab&freqs&semidurabex.dta"
merge 1:1 hhid using "$path/out/hhdnonconsumpexp.dta"
replace hhdnonconsumpexp= 0 if hhdnonconsumpexp==.
drop _merge
sort hhid
*save "$path/out/hhdeduc&medic&durab&nondurab&freqs&semidurabex.dta", replace

replace educationd=0 if educationd==.
replace medicalexpd=0 if medicalexp==.
replace dassetvalue=0 if dassetvalue==.
replace dnondurables=0 if dnondurables==.
replace dhhfrequents=0 if dhhfrequents==.
replace hhdsemidurs=0 if hhdsemidurs==.
replace hhdnonconsumpexp=0 if hhdnonconsumpexp==.

gen hhnonfoodexp =  educationd+medicalexpd+dassetvalue+dnondurables+dhhfrequents+hhdsemidurs + hhdnonconsumpexp
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
replace descript=product if descript==.
drop if descript==1
*label drop _all
drop if product==.
save "$path/out/cons_cod.dta", replace
save "$path/in/cons_cod.dta", replace

