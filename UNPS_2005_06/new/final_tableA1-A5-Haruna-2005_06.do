**     PROGRAMME:    preparing_household data_UNPS_2005-2006 for Uganda_tables_A1_to_A5      
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



**everyting included for food consumption (incl alcohol and tobacco)
**included all non-cons expenditure
** inculded ed expenditure
** included all daily household expenditure on frequently bought commodities

clear
set logtype text
capture log close
set more off
if c(os)=="Unix" {
global path "/home/bjvca/data/data/GAP/Haruna/UNPS_2005_06/"
}
else{
global path "C:\Users\Haruna\Desktop\GAPP\UNPS_2005_06"
}


* ====================Table A1==========================: Household Characteristics and interview details
use "$path/in/GSEC1.dta" 
***------- Primary Sampling Unit
* The primary sampling unit for the 2012 is the comm, using codes as of 2005/6 UNHS and is the enumeration area.
codebook comm 
	/* There are 321 unique values, the UNHS 10/11 report mentions 322, located in C:\Users\Haruna\Desktop\GAPP\UNHS_2011\GAPP3\working-files */
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
*the one below corresponds to this: "tab month year,m" in other versions
tab h1bq2b h1bq2c, m 
drop if h1bq2b == . | h1bq2b == 0
	/* According to the repartition of months and year, the survey ran from November 2011 to January 2013. I will define the
	 * the quarters accordingly */
gen float survquar=1 if h1bq2b>=5 & h1bq2b<=7 & h1bq2c==2005 
replace survquar=2 if h1bq2b>=8 & h1bq2b<=10  & h1bq2c==2005
replace survquar=3 if h1bq2b>=5 & h1bq2b<=6  & h1bq2c==2006 | h1bq2b == 11 & h1bq2c == 2005
replace survquar=4 if h1bq2b>=7 & h1bq2b<=9  & h1bq2c==2006
replace survquar=5 if h1bq2b>=10 & h1bq2b<=11  & h1bq2c==2006
label define lsurvquar 1 "May '05 - Jul-'05" 2 "Aug-Oct 05" 3 "Nov '05 & May-Jun 06" 4 "Jul-Sept 2006" 5 "Oct-Nov '06"
label values survquar lsurvquar
label variable survquar "Sequential Survey Quarter (May-Nov'05 & May-Nov '06)"
tab survquar
***------- Sequential Interview month 
* Following the Mozambique file, I am creating a survey month variable rather than an interview date variable as per the excel sheet
* Number 1 corresponds to the first month of the survey and not to January.
gen float survmon=1 if h1bq2b==5 & h1bq2c==2005
replace survmon=2 if h1bq2b==6 & h1bq2c==2005
replace survmon=3 if h1bq2b==7 & h1bq2c==2005
replace survmon=4 if h1bq2b==8 & h1bq2c==2005
replace survmon=5 if h1bq2b==9 & h1bq2c==2005
replace survmon=6 if h1bq2b==10 & h1bq2c==2005
replace survmon=7 if h1bq2b==11 & h1bq2c==2005
replace survmon=8 if h1bq2b==5 & h1bq2c==2006
replace survmon=9 if h1bq2b==6 & h1bq2c==2006
replace survmon=10 if h1bq2b==7 & h1bq2c==2006
replace survmon=11 if h1bq2b==8 & h1bq2c==2006				
replace survmon=12 if h1bq2b==9 & h1bq2c==2006
replace survmon=13 if h1bq2b==10 & h1bq2c==2006
replace survmon=14 if h1bq2b==11 & h1bq2c==2006 
**** there was only one person in January 2013, hence it is added on to Dec '12
label define lsurvmon 1 "May 05" 2 "Jun 05" 3 "Jul 05" 4 "Aug 05" 5 "Sept 05" 6 "Oct 05" 7 "Nov 05" 8 "May 06" 9 "Jun 06" 10 "Jul 06" 11 "Aug 06" 12 "Sept 06" 13 "Oct 06" 14 "Nov 06"
label values survmon lsurvmon
tab survmon,m
label variable survmon "Sequential Survey Month (November 2011 = January '13)"
***------- Household Sample Weight
rename hmult hhweight
label variable hhweight "Household sample weight"
***------- Household id
codebook HHID /*there are  3,119 unique values and 3,119 observations in the dataset so the variable "hh" uniquely identifies the observations */
rename HHID hhid
label variable hhid "Household ID"
***------- Geographical Stratification during sampling

tab region
gen float strata = 1 if region ==0 & urban == 1 | region == 1 & urban ==1
replace strata = 2 if region ==0 & urban == 0 | region == 1 & urban ==0
replace strata = 3 if region ==2 & urban==1
replace strata = 4 if region ==2 & urban==0
replace strata = 5 if region ==3 & urban==1
replace strata = 6 if region ==3 & urban==0
replace strata = 7 if region ==4 & urban==1
replace strata = 8 if region ==4 & urban==0
la define lstrata 1 "central urban" 2 "central rural" 3 "Eastern urban" 4 "Eastern rural" 5 "Northern urban" 6 "Northern rural" 7 "Western Urban" 8 "Western rural"
la values strata lstrata
label variable strata "Geographical stratification variable during sampling (ranging from 1 to 6 sub regions)"
tab strata
***----------------------rural/urban identifier 
tab urban
gen rural=1 if urban==0
replace rural=0 if urban==1
label define lrural 1 "Rural" 0 "Urban"
la values rural lrural
label variable rural "Rural/Urban Location"
tab rural,m
***-----Regions used for temporal price index calculations
tab region,m 
replace region = 1 if region == 0
la define lregion 1 "Central" 2 "Eastern" 3 "Northern" 4 "Western"
la values region lregion 


***------ Spatial domains (each with its own poverty line)
tab strata
*  Geographical |
*stratification |
*      variable |
*        during |
*      sampling |
 *(ranging from |
 *1 to 6 sub re |      Freq.     Percent        Cum.
*---------------+-----------------------------------
* central urban |        460       14.75       14.75
* central rural |        564       18.08       32.83
* Eastern urban |        135        4.33       37.16
* Eastern rural |        562       18.02       55.18
*Northern urban |        137        4.39       59.57
*Northern rural |        558       17.89       77.46
* Western Urban |        128        4.10       81.56
* Western rural |        575       18.44      100.00
*---------------+-----------------------------------
*         Total |      3,119      100.00

* In the Arndt & Simler 2010 paper the spatial domains are a combinaison of regions and rural/urban delimitations + the capital
* city, however in the 2010/11 some urban sections have far less than 200 respondents, so we shall combine all other regions 
* (rural + urban)except the central since its urban would be boosted by Kampala, getting us 5 spatial domains
gen float spdomain=region

clonevar reg_tpi = region
label variable reg_tpi "Regions used for temporal price index calculations"


***---------------News; another way to specify variables, is the traditional Uganda regions, North east central and western, represented in region
gen float news=1 if region==1 
replace news=2  if region==2 
replace news=3  if region==3 
replace news=4  if region==4 
label define lnews 1 "Central" 2 "Eastern" 3 "Northern" 4 "Western" 
label values news lnews
label variable new "regions north, east, central and western; other ways to dissagregate poverty lines"
tab news
****-------geo1-geo?; other administrative geographical boundariies where a survey is representative is not required as also done in news rural and others
*** -------------------Bootstrap weights: the toolkit requires that this should be=1 for all households and we generate it below
gen float bswt=1
label variable bswt "bootstrap weights; and all equal to 1 for all households, as a toolkit requirement"
sort hhid
save "$path/in/hhdata_hhsize.dta",replace
save "$path/out/hhdata_hhsize.dta",replace
**** --------------------------------Household size
** Since we need Household size in the hhdata.dta, and it was unavailable in the GSEC1.dta, we use the Unique person identifier in GSEC2.dta
clear 
use "$path/in/GSEC2.dta"
keep if tid==1
rename pid indlin
bysort HHID: gen pid=_n
order HH pid
gen counter=1
gen equiv=.
replace equiv=.33 if  (h2q9==0) 
replace equiv=.46 if  (h2q9==1) 
replace equiv=.54 if  (h2q9==2) 
replace equiv=.62 if  (h2q9==3 | h2q9==4) 

replace equiv=.74 if h2q4==1 &  (h2q9==5 | h2q9==6) 
replace equiv=.70 if h2q4==2 &  (h2q9==5 | h2q9==6) 

replace equiv=.84 if h2q4==1 &  (h2q9>6 & h2q9<10) 
replace equiv=.72 if h2q4==2 & (h2q9>6 & h2q9<10) 

replace equiv=.88 if h2q4==1 &  (h2q9==10 | h2q9==11) 
replace equiv=.78 if h2q4==2 &  (h2q9==10 | h2q9==11) 

replace equiv=.96 if h2q4==1 &  (h2q9==12 | h2q9==13) 
replace equiv=.84 if h2q4==2 &  (h2q9==12 | h2q9==13) 

replace equiv=1.06 if h2q4==1 &  (h2q9==14 | h2q9==15) 
replace equiv=.86 if h2q4==2 &  (h2q9==14 | h2q9==15) 

replace equiv=1.14 if h2q4==1 &  (h2q9==16 | h2q9==17) 
replace equiv=.86 if h2q4==2 &  (h2q9==16 | h2q9==17) 

replace equiv=1.04 if h2q4==1 &  (h2q9>17 & h2q9<30) 
replace equiv=.80 if h2q4==2 & (h2q9>17 & h2q9<30) 

replace equiv=1.00 if h2q4==1 &  (h2q9>29 & h2q9<60) 
replace equiv=.82 if h2q4==2 & (h2q9>29 & h2q9<60) 

replace equiv=0.84 if h2q4==1 &  (h2q9>59 ) 
replace equiv=.74 if h2q4==2 & (h2q9>59) 

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
rename  tid resident
tab resident
*drop if resident==7
***------ Household ID
rename HHID hhid
label variable hhid "Household ID"
***------ Individual ID
destring hhid PID, replace
gen double indid = hhid*100 +  PID
codebook indid
* There are 16,759 unique values, and there are 16,759 observations in the dataset so indid uniquely identifies the data
*duplicates report indid
*duplicates list indid
*duplicates drop indid, force
*codebook indid 
*there are now 17043 and 17,043 observations implying that indid now uniquely identifies the data
label variable indid "Individual ID"
***------ Sex
rename  h2q4 sex
label variable sex "Sex"
***------ Age
rename  h2q9 age
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
* There are 16,329 unique values, and there are 16,329 observations in the dataset so indid uniquely identifies data
*duplicates report indid
*duplicates list indid
*duplicates drop indid, force
*codebook indid 
***----- Mother lives in household?
tab h3q6,m
*There are 7,122  (ie 43.1 %) missing responses,: 1: Yes = 6,913 2: No = 1,95 3: Dead = 363 4: Missing = 6,882. I will group them 
gen motherhh=1 if h3q6==1 
replace motherhh=0 if h3q6==2 | h3q6==3 | h3q6==4 | h3q6==.
label variable motherhh "Mother lives in hh"
label define lmoth 0 "No" 1 "Yes"
label values motherhh lmoth
keep indid motherhh
tab motherhh
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
use "$path/in/foodcomp_uganda_PANNELsurvey2005.dta"
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
use "$path/in/GSEC14A.dta"
sort HHID
rename HHID hhid
la var hhid "household id"
** we drop alcoholic and tobacco as these were not considered basic in foods generally and by GAPP, these included beer-152, other alcoholic dricns-153
** cigarettes-155, other tobacco-156 and beer taken in restaurants-159, just like we did in the 2009 poverty calculations
rename h14aq2 itmcd
rename h14aq3 untcd
*drop if inlist( itmcd ,152,153, 155,156, 157, 158,159)

duplicates report  hhid itmcd
*duplicates list  hhid itmcd
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
keep hhid h4q10f
sort hhid
** since total education expenses were clooected in h4q10f and since is at yearly basis, we divided it by 365 to get daily expenses on education
gen educationd = h4q10f/365

*replace educationd=0
la var educationd "daily household expense on education"
drop h4q10f
save "$path/out/hhdeducationexp.dta", replace
clear
**---------------------calculating medical expenses
use "$path/in/GSEC5.dta"
rename HHID hhid
sort hhid
keep hhid h5q10 h5q11 
egen medicalexp = rowtotal (h5q10 h5q11 ) 
gen medicalexpd = medicalexp/30
replace medicalexpd=0
drop h5q10 h5q11
la var medicalexpd "household daily expenditure"
save "$path/out/hhdmedicalexp.dta", replace
clear
****---------------calculating expenses on basic durable assests
use "$path/in/GSEC12A.dta"
des
save "$path/out/hhddurables.dta", replace

*keep if inlist( h12aq2 ,02,03,10,11,12,13) 
*drop if inlist(h12aq2, 1, 2 )

gen assetvalue = h12aq5
** i took land-03, bicycle-10, motor cycle-11 and motorvehicle-12, boat-13 and other buildings-02, as durables and assumed that a year, 
** the household can use 0.1% of these assests, just to limit the influence of assests that were inflating unnecessarily especially the urban poverty estimates,
** house not treated as an asset as the toolkit takes care of imputed rent
gen dassetvalue = (assetvalue*0.1)/365
replace dassetvalue = 0
la var dassetvalue "household daily durables expenditure"
rename HHID hhid
sort hhid
save "$path/out/hhddurablesexp.dta", replace
clear

***-------------------calculating expenses on basic frequently bought items
use "$path/in/GSEC14B.dta"
des
rename HHID hhid
sort hhid
** here we considered rent of rented house-301, imputed rent of own house-302, imputed rent of free given house-303, repair expenses-304, water-305 
** electricity-306, generator fuels-307, parafin-308, charcoal-309, firewood-310, matches-451, washing soap-452, bathing soap-453, toothpaste-454, 
** taxifares-463, and expenditure on phones not owned-468, and we dropped others-311, cosmetics-455, handbags-456, batteries-drycells-457, newspapers-458, 
* others-459, tires-461, petrol-462, bus fares-464, bodaboda fare-465, stamps/envelops-466, mobilephoneairtime-467 and others-469,health fees as 
*consultation-501, medicine-502, hospitalcharges-503, traditionaldoctors-504, others-505 since medical expenses were cosidered in section 5, 
* sports/theater-601, drycleaning-602, houseboys-603, barbers&beauty shops-604 and lodging-605. THESE HAVE BEEN CONSIDERED NON BASIC
*drop if inlist( h14bq2 , 311,459,469, 502,503,601,602,603,605)
egen hhfrequents = rowtotal( h14bq5 h14bq7 h14bq9)
gen dhhfrequents = hhfrequents/30
la var dhhfrequents "daily household expenditure on frequently bought commodities"
tostring hhid, force replace
save "$path/out/hhdfrequentsexp.dta", replace
clear
****------------------calculating basic expenses on semi durables
**   in considering semi durable goods and services, the value of those services and goods recieved in kind, column h15dq9 of GSEC15D.dta has been excluded
**   just as in kind food consumptions were eliminated in table 4 as per the GAPP guidelines, These have also been discounted by 10% usage per year
use "$path/in/GSEC14C.dta"
save "$path/out/hhsemidurables.dta", replace
des
sort HHID
rename HHID hhid
** we have considered the following men clothing-201, womenclothing-202, childrenclothing-203, men footware-206, women footware-207, children footware-208
** bedding mattress-304, blankets-305, charcoal/parafin stoves-402, plastic plates and tumblers-502, and dropped other clothing-204, tailoring materials-205, 
*other footware-209, furniture items-301, carpets-302, curtains&bedsheets-303, others-306, kettles-401, tv&radio-403, byclcles-404, radio-405, motors-406, 
*motorcycles-407,computers-408, phone handsets-409, others-410, jewelry&watches-411,glass/table ware of codes 501 and 503-506, education cost (601-605)
*as education done in section 4, and others like functions & premiums (701-703) ** as these have been consideered NON BASIC
*drop if inlist( h14cq2 ,204,205,208,209,301,302,303,306,401,403,404,405,406,407,408,409,410,411,501,503,504,505,506,601,602,603,604,605,701,702,703)
egen hhsemidurables = rowtotal ( h14cq3 h14cq4 h14cq5)
sort hhid
gen hhdsemidurs = (hhsemidurables)/365
*replace hhdsemidurs=0
la var hhdsemidurs "household daily semi durables goods and seervices expenses"
drop hhsemidurables
tostring hhid, force replace
save "$path/out/hhdsemidurablesexp.dta", replace
clear

use "$path/in/GSEC14D.dta"
save "$path/in/hhnonconsmpexptaxes.dta", replace
sort HHID
rename HHID hhid
** we only considered graduated tax-904, that may cause arrest if not paid and it used to be per head paid to local government annually
** and dropped income tax-901, property tax-902, user fees-903, social security payments-905, remmitances-906, funerals-907 and others-909
drop if inlist( itmcd ,906)
gen hhdnonconsumpexp = value/365
replace hhdnonconsumpexp=0
la var hhdnonconsumpexp "hh daily expenditure on taxes, contributions, donations, duties, etc"
sort hhid 
collapse hhdnonconsumpexp, by (hhid)
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
*use "$path/out/hhdnondurablesexp.dta"
*collapse (sum) dnondurables , by(hhid)
gen dnondurables=0
sort hhid
save "$path/out/hhdnondurablesexp.dta", replace
use "$path/out/hhdeduc&medic&durabex.dta"
merge 1:1 hhid using "$path/out/hhdnondurablesexp.dta"
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
drop _merge
sort hhid

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

replace descript=product if descript==.
drop if descript==1

label drop _all
save "$path/out/cons_cod.dta", replace
save "$path/in/cons_cod.dta", replace

