#delimit ;
set more off;
clear;
*set mem 100m;

*cd "C:\iof\Appendix";

cap log close;
log using "$path/rep/230_assets_possession.log", replace;

******************************************************************************************
*	230_assets_possession.do 	(start)
*
* NV 2010
* (Small revisions by MAH)
******************************************************************************************;

use "$path\in\HHdata.dta", clear;

gen id00 = $hhid;

keep id00 af125 af128;

destring af128, replace;

recode af128 1 2 3 6 9=0 4 5=100;
rename af128 better_econ;
sort id00;


tempfile pobreza;
save `pobreza';


use  "$path\in\HHdata.dta", clear;

gen id00 = $hhid;

keep id00 af74 af73 af76 af78 af83 af84 af85;

for var af73 af74 af78 af83 af84 af85: destring X, replace;

gen conc_roof=0;
replace conc_roof=100 if af74==1 | af74==2 | af74==3 | af74==4;

gen durab_wall=0;
replace durab_wall =100 if af73==1 | af73==2;

rename af76 No_rooms;

gen saf_water=0;
replace saf_water=100 if af78==1 | af78==2 | af78==3 | af78==4;

gen sanita=0;
replace sanita=100 if af83==1;

gen cook_elec_gas=0;
replace cook_elec_gas=100 if af84==1 | af84==2;

gen light_elec_gener=0;
replace light_elec_gener=100 if af85==1 | af85==2;

*tab1 conc_roof durab_wall saf_water sanita cook_elec_gas light_elec_gener;

collapse conc_roof durab_wall saf_water sanita cook_elec_gas light_elec_gener No_rooms , by(id00);

sort id00;

merge id00 using `pobreza';

tab _m;

drop _m;

destring af125, replace;

rename af125 No_meals;

sort id00;

save "$path\work/housing.dta", replace;

use "$path\in\BD.dta", clear;

gen id00 = $hhid;

destring codigo, replace;





gen bed=0;
replace bed=100 if codigo==51114 & quantos>0 & quantos!=.;

gen fridge=0;
replace fridge=100 if codigo==53111 & quantos>0 & quantos!=.;

gen iron=0;
replace iron=100 if codigo==53203 & quantos>0 & quantos!=.;

gen fan=0;
replace fan=100 if codigo==53208 & quantos>0 & quantos!=.;

gen bycicle=0;
replace bycicle=100 if codigo==71301 & quantos>0 & quantos!=.;

gen cd_player=0;
replace cd_player=100 if codigo==91112 & quantos>0 & quantos!=.;

gen radio=0;
replace radio=100 if codigo==91113 & quantos>0 & quantos!=.;

gen tv=0;
replace tv=100 if codigo==91121 & quantos>0 & quantos!=.;

gen watch=0;
replace watch=100 if codigo==123103 & quantos>0 & quantos!=.;

gen cellphone=0;
replace cellphone=100 if codigo==82004 & quantos>0 & quantos!=.;











sort id00;

*save "$path\work/bd_VN.dta", replace;

*tab1 bed fridge iron fan bycicle cd_player radio tv watch;
collapse (max) bed fridge iron fan bycicle cd_player radio tv watch cellphone, by(id00);


merge id00 using "$path\work\housing.dta";

tab _m;
drop _merge;

rename id00 hhid;
sort hhid;
merge hhid using "$path\work\hhdata.dta", keep(hhid hhweight hhsize rural strata);
tab _merge;
drop _merge;

sort hhid;

merge hhid using "$path\work\povmeas_ent_flex.dta", keep(h_ent_m);
rename h_ent_m h;

save "$path\work\bd_housing.dta", replace;


collapse conc_roof durab_wall saf_water sanita cook_elec_gas light_elec_gener No_meals better_econ
bed fridge iron fan bycicle cd_player radio tv watch cellphone [aw=hhweight], by(h);


outsheet h conc_roof durab_wall saf_water sanita cook_elec_gas light_elec_gener No_meals better_econ
bed fridge iron fan bycicle cd_player radio tv watch cellphone using "$path\work\assets_national.csv", replace c;

use "$path\work\bd_housing.dta", clear;

collapse conc_roof durab_wall saf_water sanita cook_elec_gas light_elec_gener No_meals better_econ
bed fridge iron fan bycicle cd_player radio tv watch cellphone [aw=hhweight], by(h rural);

outsheet h rural conc_roof durab_wall saf_water sanita cook_elec_gas light_elec_gener No_meals better_econ
bed fridge iron fan bycicle cd_player radio tv watch cellphone using "$path\work\assets_rural_urb.csv", replace c;

use "$path\work\bd_housing.dta", clear;

collapse conc_roof durab_wall saf_water sanita cook_elec_gas light_elec_gener No_meals better_econ
bed fridge iron fan bycicle cd_player radio tv watch cellphone [aw=hhweight], by(h strata);

outsheet h strata conc_roof durab_wall saf_water sanita cook_elec_gas light_elec_gener No_meals better_econ
bed fridge iron fan bycicle cd_player radio tv watch cellphone using "$path\work\assets_provinces.csv", replace c;

******************************************************************************************
	230_assets_possession.do 	(end)
******************************************************************************************;

cap log close;
