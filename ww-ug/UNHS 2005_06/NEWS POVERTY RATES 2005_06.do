cd "C:\Users\Templeton\Desktop\GAPP\GAPP-UGANDA-HARUNA\ww-ug\UNHS 2005_06\"
use UNHS2005_HH_georef.dta
rename hh hhid
keep comm ea hhid
sort hhid
save temp8, replace

use cons-2005-06.dta
rename hh hhid
sort hhid
merge using temp8
drop if _merge==2
drop poor

gen poor=1 if welfare<spline
replace poor=0 if poor==.

log using poorpct05_06.log, replace
tab poor
svyset ea [pweight=hmult], strata(regurb) || _n

svy linearized : mean poor
svy: mean poor, over(region)
close log
