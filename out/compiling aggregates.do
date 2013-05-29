
use C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC4.dta
duplicates report  hh h4q1
sum
ed
collapse (sum)  h4q13f,by( hh)
la var  h4q13f "total education expense"
save C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\education_total.dta


use C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\HSEC5.dta
tab  h5q12
br  h5q12 h5q13
duplicates report  hh h5q1
collapse (sum)  h5q10  h5q13, by(hh)
egen medical=rowtotal( h5q10 h5q13)
drop  h5q10 h5q13
save C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\medical_cost.dta


use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\ww-ug\UNHS 2009_10 DATASET\SOCIO\HSEC10D.dta"
br  h10dq3
codebook  h10dq3
br
tab  h10dq2
duplicates report  hh h10dq2
duplicates report  hh
collapse (sum) h10dq3,by (hh)
la var  h10dq3 "remittances and others"
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\remittance and other.dta"

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\ww-ug\UNHS 2009_10 DATASET\SOCIO\HSEC11.dta",clear
codebook  h11q2 h11q3 h11q4
tab h11q2
tab h11q2,nol
keep if  h11q2==11
tab  h11q2
ed
tab  h11q3
drop  h11q3
drop  h11q2
la var  h11q4 "imputed rent"
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\imputed rent.dta"

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\ww-ug\UNHS 2009_10 DATASET\SOCIO\HSEC10B_CLN.dta",clear
keep  h10bq2 h10bq5 h10bq7 h10bq9
use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\ww-ug\UNHS 2009_10 DATASET\SOCIO\HSEC10B_CLN.dta",clear
keep  h10bq2 h10bq5 h10bq7 h10bq9 hh
egen small_exp=rowtotal( h10bq5 h10bq7 h10bq9)
ed
ed
drop  h10bq5 h10bq7 h10bq9
collapse (sum)  small_exp, by(hh)
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\utilities_small_exp.dta"

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\ww-ug\UNHS 2009_10 DATASET\SOCIO\HSEC10C_CLN.dta", clear
egen durables=rowtotal ( h10cq3 h10cq4 h10cq5)
duplicates report  hh  durables
collapse (sum)   durables, by(hh)
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\durables.dta"


use C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\durables.dta,clear
destring  hh,force replace
save C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\durables.dta,replace

use "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\remittance and other.dta",clear
destring  hh,force replace
save "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\remittance and other.dta",replace





use C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\education_total.dta,clear
merge 1:1 hh using C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\medical_cost.dta
drop _merge
destring  hh,gen( hh1)
ed
format %14.0g hh1
drop hh
ren  hh1 hh

merge 1:1 hh using C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\utilities_small_exp.dta
drop _merge
merge 1:1 hh using C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\durables.dta
drop _merge
merge 1:1 hh using "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\in\remittance and other.dta"
drop _merge




