#delimit cr
clear
set more off

cap log close
log using "$path/rep/240_compare_nat_acc.log", replace

******************************************************************************************
* 240_compare_nat_acc.do 	(start)
*
* Compares survey aggregates with the National Accounts.
*
* SJ 2010
* (Small revisions by MAH)
******************************************************************************************;


****************************************
********** set up
****************************************
*	clear
*	set more off
*	set mem 100m


*this is where the do files are
*	global path 		/home/sam/WORK/Mozambique/2010 MOZ poverty/Analysis/do_keytabs

*this is where the 2002/03 directory is
*	global path0809 	../../Data/Feb 2010/iof0809

*this is where the 2008/09 directory is
*	global path0203 	../../Data/Jan 2010/iaf0203

*change dirs
*	cd "$path"
*	cd "$path0809"

****************************************
********** IOF 2008/09
****************************************

*** setup
	use "$path/work/cons_cat.dta", clear
	gen foodsh   = 100*share if prod_cat==1
	gen foodbuy = daily_valued+monthly_valued+receipts_valued if prod_cat ==1

	collapse (sum) own_valued rent daily_valued receipts_valued foodbuy (mean) cons_hh_nom foodsh, by(hhid)
	compress
	
	joinby hhid using "$path/work/povmeas_ent_flex.dta"
rename h_ent_m h
	 
	replace popwt = hhsize * hhweight
	gen strata_all = strata + 100*(rural)
	svyset psu [pw = popwt], strata(strata_all) || _n

	replace h = cond(cons_pc_nom - povline_ent_m>=0,0,1,.)
	gen h_tpi	= cond(cons_pc_tpi - povline_ent_m>=0,0,1,.)
	svy : mean h h_tpi

	gen autosh 		= 100 * own_valued / cons_hh_nom
	gen rentsh  		= 100 * rent / cons_hh_nom
	gen foodbuysh 	= 100 * foodbuy / cons_hh_nom
	replace foodbuysh 	= 100*foodbuysh / foodsh
	gen dailysh 		= 100 *daily_valued/cons_hh_nom
	gen transsh 		= 100 *receipts_valued/cons_hh_nom
	
*	svy : mean autosh foodbuysh foodsh rentsh hhsize, over(rural h_tpi)

	gen realcons = cons_pc_tpi / povline_ent_m
	gen cons_pc_nom_annual = cons_pc_nom * 365 / 10^9

*** tpi
	tabout reg_tpi survquar using "$path/work/tpi.txt" [aw = popwt], c(mean tpi_trim) sum format(3) replace

*** povline
	tabout rural using "$path/work/povline.txt" [aw = popwt], c(p50 povline_ent_m p50 food_povline_ent) sum format(3) replace clab("Linha_total" "Linha_alimentos")
	tabout spdomain using "$path/work/povline.txt" [aw = popwt], c(p50 povline_ent_m p50 food_povline_ent) sum format(3) append clab("Linha_total" "Linha_alimentos")
	
*** autoconsumo share
	tabout rural using "$path/work/autosh.txt" [aw = popwt], c(p50 autosh) sum format(3) clab("Autoconsumo") replace
	tabout spdomain using "$path/work/autosh.txt" [aw = popwt], c(p50 autosh) sum format(3) clab("Autoconsumo") append

*** foodsh
	tabout rural using "$path/work/foodsh.txt" [aw = popwt], c(p50 foodsh) sum format(3) clab("Alimentos") replace
	tabout spdomain using "$path/work/foodsh.txt" [aw = popwt], c(p50 foodsh) sum format(3) clab("Alimentos") append

*** dailysh
	tabout rural using "$path/work/dailysh.txt" [aw = popwt], c(p50 dailysh) sum format(3) replace clab("Despesas_diarias")
	tabout spdomain using "$path/work/dailysh.txt" [aw = popwt], c(p50 dailysh) sum format(3) append clab("Despesas_diarias")

*** receiptsh
	tabout rural using "$path/work/transh.txt" [aw = popwt], c(mean transsh) sum format(3) replace clab("Tranferencias")
	tabout spdomain using "$path/work/transh.txt" [aw = popwt], c(mean transsh) sum format(3) append clab("Tranferencias")

*** consumption
	tabout rural using "$path/work/cons.txt" [aw = popwt], c(p50 realcons p50 cons_pc_nom) sum format(3) clab("Consumo_real" "Consumo_nominal") replace
	tabout rural using "$path/work/cons.txt" [aw = popwt], c(p25 realcons p25 cons_pc_nom) sum format(3) clab("Consumo_real" "Consumo_nominal") append

/*
*** tpi
	tabout reg_tpi survquar using "$path/work/tpi.txt" [aw = popwt], c(mean tpi_trim) sum format(3) replace topf($path/work/2008.txt)

*** povline
	tabout rural using "$path/work/povline.txt" [aw = popwt], c(p50 povline_ent_m p50 food_povline_ent) sum format(3) replace clab("Linha_total" "Linha_alimentos") topf($path/work/2008)
	tabout spdomain using "$path/work/povline.txt" [aw = popwt], c(p50 povline_ent_m p50 food_povline_ent) sum format(3) append clab("Linha_total" "Linha_alimentos") topf($path/work/2008)
	
*** autoconsumo share
	tabout rural using "$path/work/autosh.txt" [aw = popwt], c(p50 autosh) sum format(3) clab("Autoconsumo") replace topf($path/work/2008)
	tabout spdomain using "$path/work/autosh.txt" [aw = popwt], c(p50 autosh) sum format(3) clab("Autoconsumo") append topf($path/work/2008)

*** foodsh
	tabout rural using "$path/work/foodsh.txt" [aw = popwt], c(p50 foodsh) sum format(3) clab("Alimentos") replace topf($path/work/2008)
	tabout spdomain using "$path/work/foodsh.txt" [aw = popwt], c(p50 foodsh) sum format(3) clab("Alimentos") append topf($path/work/2008)

*** dailysh
	tabout rural using "$path/work/dailysh.txt" [aw = popwt], c(p50 dailysh) sum format(3) replace clab("Despesas_diarias") topf($path/work/2008)
	tabout spdomain using "$path/work/dailysh.txt" [aw = popwt], c(p50 dailysh) sum format(3) append clab("Despesas_diarias") topf($path/work/2008)

*** receiptsh
	tabout rural using "$path/work/transh.txt" [aw = popwt], c(mean transsh) sum format(3) replace clab("Tranferencias") topf($path/work/2008)
	tabout spdomain using "$path/work/transh.txt" [aw = popwt], c(mean transsh) sum format(3) append clab("Tranferencias") topf($path/work/2008)

*** consumption
	tabout rural using "$path/work/cons.txt" [aw = popwt], c(p50 realcons p50 cons_pc_nom) sum format(3) clab("Consumo_real" "Consumo_nominal") replace topf($path/work/2008)
	tabout rural using "$path/work/cons.txt" [aw = popwt], c(p25 realcons p25 cons_pc_nom) sum format(3) clab("Consumo_real" "Consumo_nominal") append topf($path/work/2008)
*/

*** nominal cons comparison
	local compareat = 193.046773
	gen cons_pc_nom_annual_pov = cons_pc_nom  / (povline_ent_m)
	quie summ cons_pc_nom_annual [aw = popwt], d

	noi dis "The IAF/IOF As % INE <year> consumo privado: " string(100 * r(sum) / `compareat',"%9.2f") "%"
	gen cons_pc_nom_annual_pct = 100*cons_pc_nom_annual / r(sum)
	noi table strata [pw = popwt], c(sum cons_pc_nom_annual sum cons_pc_nom_annual_pct p50 cons_pc_nom_annual_pov) format(%9.2f) row
	
****************************************************************************************************

******************************************************************************************
* 240_compare_nat_acc.do 	(end)
******************************************************************************************;

cap log close;

