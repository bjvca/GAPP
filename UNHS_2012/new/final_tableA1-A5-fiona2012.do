
*********************************************************************
*********************************************************************
**
**     PROGRAMME:    preparing_hhdata_200 for Uganda_tables_A1_to_A3_vXX       
**     AUTHOR:       Fiona Nattembo (F.Nattembo@cgiar.org)
**     OBJECTIVE:    Create standard tables A1 to A3 for UNHS 2012/23
**
**     DATA IN:      GSEC1cln.dta
**					 GSEC2.dta
**					 GSEC3.dta
**                   GSEC6b.dta
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



**************************************************************
* Table A1: Household Characteristics and interview details
**************************************************************

use "$path/in/GSEC1cln.dta" 
*keep

***------- Primary Sampling Unit
* The primary sampling unit for the 2005/6 UNHS is the enumeration area.
codebook ea 
** There are 747 unique values, the UNHS 12/13 report mentions *****, located in ****
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
tab month year,m 
	** According to the repartition of months and year, the survey ran from May 2005 to April 2006. I will define the
	 ** the quarters accordingly
gen float survquar=1 if month>=6 & month<=8 & year==2012
replace survquar=2 if month>=9 & month<=11  & year==2012
replace survquar=3 if (month==12 & year==2012) | (month>=1 & month<=2 & year==2013)
replace survquar=4 if month>=3 & month<=5  & year==2013
replace survquar=5 if month==6  & year==2013

label define lsurvquar 1 "Jun-Aug 2012" 2 "Sept-Nov 2012" 3 "Dec2012-Feb2013" 4 "Mar-May 2013" 5 "Jun 2013"
label values survquar lsurvquar
label variable survquar "Sequential Survey Quarter (Jun-Aug 2012=1)"
ta survquar


***------- Sequential Interview month 
* Following the Mozambique file, I am creating a survey month variable rather than an interview date variable as per the excel sheet
* Number 1 corresponds to the first month of the survey and not to January.
gen float survmon=1 if month==6 & year==2012
replace survmon=2 if month==7 & year==2012
replace survmon=3 if month==8 & year==2012
replace survmon=4 if month==9 & year==2012
replace survmon=5 if month==10 & year==2012
replace survmon=6 if month==11 & year==2012
replace survmon=7 if month==12 & year==2012
replace survmon=8 if month==1 & year==2013
replace survmon=9 if month==2 & year==2013
replace survmon=10 if month==3 & year==2013
replace survmon=11 if month==4 & year==2013				
replace survmon=12 if month==5 & year==2013
replace survmon=13 if month==6 & year==2013

label define lsurvmon 1 "Jun 2012" 2 "Jul 2012" 3 "Aug 2012" 4 "Sep 2012" 5 " Oct 2012" 6 "Nov 2012" 7 "Dec 2012" 8 "Jan 2013" 9 "Feb 2013" 10 "Mar 2013" 11 "Apr 2013" 12 "May 2013" 13 "Jun 2013"
label values survmon lsurvmon
label variable survmon "Sequential Survey Month (Jun 20121=1)"
tab survmon,m

***------- Household Sample Weight
rename wgt_hh hhweight
label variable hhweight "Household sample weight"

**Note that there's also a weight for consumption expenditure called variable 'wgt'


***------- Household id
codebook HHID
rename HHID hhid
label variable hhid "Household ID"


***------- Household Size
**HHsize modified by Fiona
preserve
use "$path/in/GSEC2.dta" , clear
ta r04
drop if r04>=2 
gen qhmember=1
collapse(count) qhmember, by(HHID)
sum qhmember 
ren HHID hhid 
rename qhmember hhsize
label variable hhsize "Household Size"
	tempfile hhsize
	save `hhsize', replace
restore

mmerge hhid using `hhsize', type(1:1)
drop _m
***------- Geographical Stratification during sampling
* this was not there as was with 2009, therefore we shall generate "strata" from the distict and region variables here. the 2009 UBOS 
** has explanations for what districts belong to which sub regions, so we shall use that to build our strata variable. UBOS 2009/10 report had described them
** as follows: Notes: Sub-region of North East includes the districts of Kor04o, Moroto, Nakapiripiriti, Katwaki, Amuria, Soroti, Kumi
** and Kaberamaido; Mid-Northern included Gulu, Kitgum, Pader, Apac, and Lira; West Nile includes Moyo, Adjumani, Yumbe, Arua, 
**Koboko, and Nebbi; Mid-Western includes Masindi, Hoima, Kibaale, Bundibugyo, Kabarole, Kasese, Kyenjojo and Kamwenge; South Western includes 
**  Bushenyi, Rukungiri, Kanungu, Kabale, Kisoro, Mbarara, and Ntungamo; Eastern includes Kapchorwa, Mbale,
** Tororo, Sironko, Paliisa, and Busia; Central 1 includes Kalangala, Masaka, Mpigi, Rakai, Sembabule and Wakiso; Central 2 includes
** Kayunga, Kiboga, Luwero, Mubende, Mukono and Nakasongola; East Central includes Jinja, Iganga, Kamuli, Bugiri and 
** Mayuge; and Kampala. We have used the same nomenclature

clonevar strata=sregion
label variable strata "Geographical stratification variable during sampling (ranging from 1 to 10 sub regions)"
clonevar substrat=urb

* to ensure that the right districts had been used for the right sub-regions (strata), we checked this by tabbing these sub-regions with rural/urban description and then
** tabbed the big regions (region) with substrat to ensure that the total numbers of Urban/Rural are the same in both
tab strata substrat
tab region substrat

***------- Rural-Urban Location
* I checked and the variable is substrat, coded as 0=rural and 1=urban. I will create a new variable with a toolkit same coding 
tab substrat,m
gen rural=urban==0
tab rural,m

label define lrural 0 "Urban" 1 "Rural"
label values rural lrural
label variable rural "Rural/Urban Location"
tab rural,m

** just to confirm that the rural urban specification was not changed, we tabbed again to see if totals are still as before with substrat*
**
*tab rural,m
*

	  
***-----Regions used for temporal price index calculations
* in the 2009 data analysis, we used the traditions regions that are east, cetral, western and northern. these are well presented in variable region

tab region,m
clonevar reg_tpi = region 
label variable reg_tpi "Regions used for temporal price index calculations"

***------ Spatial domains (each with its own poverty line)
tab regurb
* In the Arndt & Simler 2010 paper the spatial domains are a combinaison of regions and rural/urban delimitations + the capital
* city as a separate domain (confirmed in the Mozambique data file)
*--> for uganda; urban sub regions of eastern, northern and western had very few households 132, 172, 107 respectively, 
** thus we only separated the central region into rural/urban and others were aggregated for northern, eastern and western to have 5 spatial domains
*gen spdomain = 1 if rural==1
*replace spdomain = 2 if rural ==0
gen spdomain = 1 if regurb==11 & district==102

replace spdomain = 2 if regurb==10

replace spdomain = 3 if regurb==20

replace spdomain = 4 if regurb==30

replace spdomain = 5 if regurb==40

replace spdomain = 6 if (regurb==11 | regurb==21 | regurb==31 | regurb==41)  & district!=102
label define lspdomain 1 "Kampala"  2 "Central Rural" 3  "Eastern Rural" 4 "Northern Rural" 5 "Western Rural" 6 "Other Urban" 
*gen spdomain=1
*clonevar spdomain =  region

tab spdomain rural
ta spdomain region

***-----News; another way to specify variables, is the traditional Uganda regions, North east central and western, represented in region
tab region
clonevar new=regurb
ta new

*gen new = 1 if spdomain==1 & rural==0
*replace new=2 if spdomain==1 & rural==1
*replace new=3 if spdomain==2 & rural==0
*replace new=4 if spdomain==2 & rural==1
*replace new=5 if spdomain==3 & rural==0
*replace new=6 if spdomain==3 & rural==1
*replace new=7 if spdomain==4 & rural==0
*replace new=8 if spdomain==4 & rural==1

*label define lnew 1 "Central Urban" 2 "Central Rural" 3 "Eastern Urban" 4 "Eastern Rural" 5 "Northern Urban" 6 "Northern Rural" 7 "Western Urban" 8 "Western Rural"  
*label values new lnew

label variable new "other ways to dissagregate poverty lines"
rename new news


****-------geo1-geo?; other administrative geographical boundariies where a survey is representative is not required as also done in news rural and others

*** Bootstrap weights: the toolkit requires that this should be=1 for all households and we generate it below

gen float bswt=1
label variable bswt "bootstrap weights; and all equal to 1 for all households, as a toolkit requirement"
 

drop hhsize 
sort hhid
save "$path/out/hhdata_hhsize.dta",replace
save "$path/in/hhdata_hhsize.dta",replace
save "$path/work/hhdata_hhsize.dta",replace

clear
use "$path/in/GSEC2.dta" 

*REVISIONS TO HH SIZE BY FIONA
drop if r04==2
replace r02=r02==1
gen counter=1
rename HHID hhid
bysort hhid: gen pid2=_N
order hhid pid2 counter


gen equiv=.
replace equiv=.33 if  (r07==0) 
replace equiv=.46 if  (r07==1) 
replace equiv=.54 if  (r07==2) 
replace equiv=.62 if  (r07==3 | r07==4) 

replace equiv=.74 if r02==1 &  (r07==5 | r07==6) 
replace equiv=.70 if r02==0 &  (r07==5 | r07==6) 

replace equiv=.84 if r02==1 &  (r07>6 & r07<10) 
replace equiv=.72 if r02==0 & (r07>6 & r07<10) 

replace equiv=.88 if r02==1 &  (r07==10 | r07==11) 
replace equiv=.78 if r02==0 &  (r07==10 | r07==11) 

replace equiv=.96 if r02==1 &  (r07==12 | r07==13) 
replace equiv=.84 if r02==0 &  (r07==12 | r07==13) 

replace equiv=1.06 if r02==1 &  (r07==14 | r07==15) 
replace equiv=.86 if r02==0 &  (r07==14 | r07==15) 

replace equiv=1.14 if r02==1 &  (r07==16 | r07==17) 
replace equiv=.86 if r02==0 &  (r07==16 | r07==17) 

replace equiv=1.04 if r02==1 &  (r07>17 & r07<30) 
replace equiv=.80 if r02==0 & (r07>17 & r07<30) 

replace equiv=1.00 if r02==1 &  (r07>29 & r07<60) 
replace equiv=.82 if r02==0 & (r07>29 & r07<60) 

replace equiv=0.84 if r02==1 &  (r07>59 ) 
replace equiv=.74 if r02==0 & (r07>59) 

collapse (sum) equiv counter , by (hhid)



rename counter hhsize

la var hhsize "number of household menbers"



sort hhid
save "$path/in/hhsize.dta",replace



clear 
use "$path/in/hhdata_hhsize.dta"
merge 1:1 hhid using "$path/in/hhsize.dta"

drop _m 
sort hhid
destring hhid, replace
destring psu, replace
save "$path/out/hhdata.dta",replace
save "$path/in/hhdata.dta",replace




************************************************************
* Table A2: Individual characteristics - demographics
************************************************************

clear

use "$path/in/GSEC2.dta" 
sort HHID

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

 
* For the purposes of the calculation of a poverty line we'll exclude from the household the members who have left 
* the household permanently or died
*  We'll keep the members away for more than 6 months but present on the day of the interview


rename  r04 resident
drop if resident==7

ta resident
ta resident, nol

***------ Household ID
rename HHID hhid
label variable hhid "Household ID"

***------ Individual ID
*gen double indid=hhid*100 +  pid

gen id=string(pid, "%02.0f")
egen indid=concat(hhid id)
order hhid indid
duplicates report indid
codebook indid
	* There are 36,154 different values, and there are 36,154 observations in the dataset so indid uniquely identifies
		* the individuals
label variable indid "Individual ID"

***------ Sex
rename  r02 sex
label variable sex "Sex"

***------ Age
rename  r07 age
label variable age "Age in Completed years"

* In order to have the information on whether the mother resides in the house or not we need the file "GSEC3"
sort indid
save "$path/in/temp_A2_1.dta",replace

clear
use "$path/in/GSEC3.dta" 
rename HHID hhid

***------ Individual ID
tostring hhid,replace
gen id=string(pid, "%02.0f")
egen indid=concat(hhid id)
order hhid indid
duplicates report indid 
codebook indid

*gen double indid=hhid*100 +  pid
label variable indid "Individual ID"
	* There are 35,841 different values, and there are 35,841 observations in the dataset so indid uniquely identifies
		* the individuals

***----- Mother lives in household?
tab s07 if s06==1,m

*There are 42  (ie 0.22 %) missing responses, NOT so bad like for the 2009/10 dataset *
*gen motherhh=1 if s07==1 
*replace motherhh=0 if s07==2 | s07==3 | s07==4
gen motherhh=s07==1 
label variable motherhh "Mother lives in hh"
label define lmoth 0 "No" 1 "Yes"
label values motherhh lmoth

keep hhid  pid indid motherhh
sort indid

merge 1:1 indid using "$path/in/temp_A2_1.dta"
tab _merge

	* There are some obs coming only from the using data. The explanation is that Section 3 of the questionnaire 
	* is administered only to usual and regular household members, as is confirmed by the cross tab below
	tab resident _merge, m
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
*use "$path/in/GSEC1cln.dta"
*sort hh
*** I had used the GSEC1cln.dta file here just to carry along the district variable that would enable me
*** the problem associated with the yet very low figures of poverty estimates
*save "$path/in/GSEC1cln.dta", replace

clear

use "$path/in/GSEC6b.dta"
sort HHID
*merge m:1 hh using "$path/in/GSEC1cln.dta"
*tab _m
*drop _m 
rename HHID hhid
la var hhid "household id"
** we drop alcoholic and tobacco as these were not considered basic in foods generally and by GAPP, these included beer-152, other alcoholic dricns-153
** cigarettes-155, other tobacco-156  beer and food taken in restaurants-159, just like we did in the 2009 poverty calculations
**drop if inlist( itmcd ,152,153, 155,156, 157, 158,159)  
ta itmcd

duplicates report  hhid itmcd
duplicates list  hhid itmcd untcd  
codebook hhid
egen quantity=rowtotal( ceb06 ceb08 ceb10 ceb12)
 
la var quantity "quantity of food consumed by the household including purchases, at home, away from home & kind"
** these quantities and values are collected by UBOS at a 7 days basis, thus we divide by 7 to get the daily figures as a requirement by GAPP 
gen quantityd = quantity/7
*replace ceb04=7 if (ceb04<1 | ceb04>7) & ceb04!=.
*gen quantityd = quantity/ceb04

drop quantity ceb06 ceb08 ceb10 ceb12
la var quantityd "daily household food consumption"
egen value=rowtotal ( ceb07 ceb09 ceb11 ceb13 )
la var value "household food consumption in seven days"
gen valuez = value/7 
*gen valuez = value/ceb04 

la var valuez "daily value of food consumed by the household"
*replace valuez = valuez*13 if district==102
rename quantityd quantityz
drop value ceb07 ceb09 ceb11 ceb13 ceb14 ceb15
gen unit = 1
la var unit "set equal to one since all observations are converted into kg"
gen food_cat = 1
la var food_cat "food category equals 1, if product is food and 0 if non food"

des hhid
des food_cat
des valuez
rename itmcd product
format %10.0g product
format %10.0g unit
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

*rename untcd untcd
replace product=100 if product==101  | product==102  | product==103  | product==104
merge m:1 product untcd using  "$path/conversionfactors_corrected_onlyUNPS.dta"

*merge m:1 product untcd using  "$path\in\conversionfactors.dta"

tab _m
drop _m

save "$path/in/household_table4cf.dta", replace
save "$path/out/household_table4cf.dta", replace
save "$path/work/household_table4cf.dta", replace
gen quantity = quantityz*qkg_uca 

la var quantity "daily quantity consumed in Kgs per household"
la var value  "daily value of consumption in UGX per per household"


sort hhid
label drop _all
destring hhid, replace

save "$path/out/cons_cod_trans.dta", replace
save "$path/in/cons_cod_trans.dta", replace
save "$path/work/cons_cod_trans.dta", replace

**   Generating Standard Table 5: TOTAL AMOUNT AND QUANTITY OF PRODUCTS: Food as well as non food
**
***********************************************************************************************
**  DATA IN:       GSEC4.dta : On Education costs, column 13f which has all total school expenses, it is on 365 dayss basis
**                 GSEC5.dta : On Medical Expenditure, column 10 and 11, on 30 days basis
**                 hsec12a.dta : On assets Expenditure, column h8q5 on total estimated present value, considering 10% value used per 365 days basis
**                 GSEC6b.dta: On non-durables and frequently purchased items e.g imputed rent, electricity, soap etc, on 30 days basis, columns 5,7 & 9 for value
**                 hsec14c.dta: On semi-durable goods and services, column 3, 4 & 5, on 365 days basis for value
**                 hsec14d.dta:     On Non-consumption expenses like taxes, remitances away, subscriptions etc, on 365 days basis, colum 3
**
**  DATA OUT: cons_cod.dta
******************************************************************************************************************************************************
clear
use "$path/in/GSEC4.dta"
 
rename hh hhid
codebook hhid
keep hhid e20a- e20g

*recreating the total education expenditure (by Fiona Nattembo)
egen totexp=rsum(e20a- e20f)
misschk e20a e20b  e20c e20d e20e e20f , gen(noDetails)
replace totexp=. if totexp==0
replace totexp=e20g if totexp==. & noDetailsnumber==6 & e20g!=. & e20g!=0
***

sort hhid
 ** since total education expenses were clooected in totexp and since is at yearly basis, we divided it by 365 to get daily expenses on education
gen educationd = totexp/365
*replace educationd=0 
*** already included in nonfood expenses
la var educationd "daily household expense on education"
drop totexp
save "$path/out/hhdeducationexp.dta", replace

use "$path/in/GSEC5.dta", clear

des
rename HHID hhid
sort hhid

*recreating the total medical expenditure (by Fiona Nattembo)
*keep hhid h5q10 h5q11
keep hhid he17a- he17g

egen medicalexp = rowtotal ( he17a- he17f)
replace medicalexp=. if medicalexp==0
misschk he17a he17b he17c he17d he17e he17f, gen(empty)
cou if emptynumber==6 & he17g>0 & he17g!=.					
replace medicalexp=he17g if emptynumber==6 & he17g>0 & he17g!=. & medicalexp==.				
***

gen medicalexpd = medicalexp/30
replace medicalexpd = 0 
*** already included in nonfood expenses
la var medicalexpd "household daily expenditure"
keep hhid medicalexpd
save "$path/out/hhdmedicalexp.dta", replace
 
 clear
 set more off 
use "$path/in/GSEC10.dta"

save "$path/out/hhddurables.dta", replace
* keep if inlist( ha02 ,010,011,012)


 drop if ha02==2
drop  if ha02==1
 gen assetvalue = ha06

 **************************************************************************************************************
 ** i took land, bicycle, motor cycle and other transport equipment-012, that in 2009 were motor vehicles, as durables and assumed that a year, the *household can use 1% of these assests. there was no land in 2005 assets
 ** house not treated as an asset as the toolkit takes care of imputed rent
 ************************************************************************************************************************
 gen dassetvalue = (assetvalue)/365
replace dassetvalue=0
la var dassetvalue "household daily durables expenditure"
rename HHID hhid
sort hhid

**Additions by Fiona
*dropping assets not owned by the HH
drop if ha03==3 & ha07==3 
misschk ha04a ha04b ha04c ha05 ha06 ha07 ha08a ha08b ha08c ha09 ha10, gen(empty)	
drop if emptynumber==11 
drop empty*
cou 

save "$path/out/hhddurablesexp.dta", replace

use "$path/in/GSEC10.dta", clear
save "$path/out/hhnondurables.dta", replace
rename HHID hhid
 *drop if inlist(  ha02 ,010,011,012 ,001)
 gen nondurablevalue = ha06
 **h12aq4 multiple has been dropped since UBOS had recorded ha06 as total estimated value in Ush and also discounted them by 1% to get rough value *used per year
 *** we considered other buildings-002, furniture-003, Bednets-005, Hh appliances as Kettle,flat iron-006, electronics as tv,radio-007, *generators-008, solar-panel-009
 *** , jewelry&watches-013, mobilephone-014, otherassets as lawn mores-015, Enterprise assests like; home-101, ploughs-102, wheelbarrows-104, **pangas-103
 **  others-105, 106 and 107 and financial assets-201, NOTE: figures are codes in data set
 la var nondurablevalue "household daily non-durables expenditure"
 sort hhid
 gen dnondurables = (nondurablevalue)/365
 replace dnondurables = 0
 la var dnondurables "household daily non-durables expenditure"
 save "$path/out/hhdnondurablesexp.dta", replace

use "$path/in/GSEC6c.dta", clear
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
*drop if inlist( cec02 ,502, 501, 462)
** drop if inlist( itmcd ,311,455,456,457,458,459,461,462,464,465,466,467,469,501,502,503,504,509,701,702,703,704,705)

egen hhfrequents = rowtotal ( cec05 cec07 cec09)
gen dhhfrequents = hhfrequents/30
*replace dhhfrequents= 0

la var dhhfrequents "daily household expenditure on frequently bought commodities"


save "$path/out/hhdfrequentsexp.dta", replace

clear

*******************************************************************************************
**   in considering semi durable goods and services, the value of those services and goods recieved in kind, column 5 of hsec14c.dta has been excluded
**   just as in kind food consumptions were eliminated in table 4 as per the GAPP guidelines, These have also been discounted by 10% usage per year
***************************************************************************************************************************************************

use "$path/in/GSEC6d.dta"
save "$path/out/hhsemidurables.dta", replace
des
sort HHID
rename HHID hhid
** we have considered the following men clothing-201, womenclothing-202, childrenclothing-203, men footware-221, women footware-222, children footware-223
** bedding mattress-404, blankets-405, charcoal/parafin stoves-422, plastic plates and tumblers-442
** and dropped other clothing-209, tailoring materials-210, other footware-229, furniture items-401, carpets-402, curtains&bedsheets-403, others-409
** kettles-421, tv&radio-423, byclcles-424, radio-425, motors-426, motorcycles-427,computers-428, phone handsets-429, others-430, jewelry&watches-431, 
** glass/table ware of codes 441-449, education cost (601-609) as education done in section 4, and others like functions & premiums (801-809)
** as these have been consideered NON BASIC

egen hhsemidurables = rowtotal( ced03 ced04 ced05)
sort hhid
gen hhdsemidurs = (hhsemidurables)/365
*replace hhdsemidurs = 0
la var hhdsemidurs "household daily semi durables goods and seervices expenses"

save "$path/out/hhdsemidurablesexp.dta", replace

clear

use "$path/in/GSEC6e.dta"
save "$path/in/hhnonconsmpexptaxes.dta", replace
sort HHID
rename HHID hhid
** we only considered graduated tax-904, that may cause arrest if not paid and it used to be per head paid to local government annually
** and dropped income tax-901, property tax-902, user fees-903, social security payments-905, remmitances-906, funerals-907 and others-909
*drop if h14dq2==906

gen hhdnonconsumpexp = cee03/365

replace hhdnonconsumpexp = 0
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
replace hhdnonconsumpexp=0 if hhdnonconsumpexp==.
sort hhid
save "$path/out/hhdnonconsumpexp.dta", replace




use "$path/out/hhdeduc&medic&durab&nondurab&freqs&semidurabex.dta"
merge 1:1 hhid using "$path/out/hhdnonconsumpexp.dta"
drop _merge
replace hhdnonconsumpexp=0 if hhdnonconsumpexp==.
sort hhid
save "$path/out/hhdeduc&medic&durab&nondurab&freqs&semidurab&nonconsmpex.dta", replace

gen hhnonfoodexp = educationd + medicalexpd+ dassetvalue +dnondurables+ dhhfrequents +hhdsemidurs +hhdnonconsumpexp
la var hhnonfoodexp "household total non food expenditure"
*drop if hhnonfoodexp>45000 & hhnonfoodexp!=.
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


