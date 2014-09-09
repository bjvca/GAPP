library(foreign)
dta <- read.dta("/home/bjvca/data/data/UGANDA/UNHS/UNHS2012_13/Poverty2012.dta")
sapply(split(dta,dta$region) ,  function(x) weighted.mean(x$spline,x$hmult, na.rm=T))/30

dta <- read.dta("/home/bjvca/data/data/UGANDA/UNHS/UNHS 2009_10 DATASET/aggr/pov09_05_ubos.dta")
sapply(split(dta,dta$region) ,  function(x) weighted.mean(x$spline,x$hmult, na.rm=T))/30

dta <- read.dta("/home/bjvca/data/data/UGANDA/UNHS/UNHS_2005/cons-2005-06.dta")
dta$poor06 <- as.numeric(dta$poor06)
dta$poor06 <- dta$poor06 == 2
weighted.mean(dta$poor06, dta$hmult,na.rm=T)

sapply(split(dta,dta$region) ,  function(x) weighted.mean(x$spline,x$hmult, na.rm=T))/30

sapply(split(dta,dta$region) ,  function(x) weighted.mean(x$poor06,x$hmult, na.rm=T))

dta$earegion <- NA
dta$earegion[dta$newvar==102] <- "Kampala"
dta$earegion[dta$newvar%in%c(101,105,106,110,111,113,114)] <- "Central 1"
dta$earegion[dta$newvar%in%c(103,104,107,108,109,112,115,116)] <- "Central 2"
dta$earegion[dta$newvar%in%c(201,203,204,205,214,222,224)] <- "East Central"
dta$earegion[dta$newvar%in%c(202,206,207,208,209,210,211,212,213,215,216,217,218,219,220,221,223)] <- "Eastern"
dta$earegion[dta$newvar%in%c(302,304,305,307,312,315,316,317,321)] <- "Mid Northern"
dta$earegion[dta$newvar%in%c(306,308,311,314,318)] <- "North-East"
dta$earegion[dta$newvar%in%c(301,303,309,310,313,319,320)] <- "West Nile"
dta$earegion[dta$newvar%in%c(401,403,405,406,407,409,413,415,416)] <- "Mid-Western"
dta$earegion[dta$newvar%in%c(402,404,408,410,411,412,414,417,418,419)] <- "South-Western"
sapply(split(dta,dta$earegion) ,  function(x) weighted.mean(x$poor06,x$hmult, na.rm=T))

dta <- read.dta("/home/bjvca/data/data/UGANDA/UNHS/UNHS_2002/constructed data/stata/pov0203.dta")
sapply(split(dta,dta$region) ,  function(x) weighted.mean(x$spline,x$hmult, na.rm=T))/30
dta$earegion <- NA
dta$earegion[dta$stratum==102] <- "Kampala"
dta$earegion[dta$stratum%in%c(101,105,106,110,111,113,114)] <- "Central 1"
dta$earegion[dta$stratum%in%c(103,104,107,108,109,112,115,116)] <- "Central 2"
dta$earegion[dta$stratum%in%c(201,203,204,205,214,222,224)] <- "East Central"
dta$earegion[dta$stratum%in%c(202,206,207,208,209,210,211,212,213,215,216,217,218,219,220,221,223)] <- "Eastern"
dta$earegion[dta$stratum%in%c(302,304,305,307,312,315,316,317,321)] <- "Mid Northern"
dta$earegion[dta$stratum%in%c(306,308,311,314,318)] <- "North-East"
dta$earegion[dta$stratum%in%c(301,303,309,310,313,319,320)] <- "West Nile"
dta$earegion[dta$stratum%in%c(401,403,405,406,407,409,413,415,416)] <- "Mid-Western"
dta$earegion[dta$stratum%in%c(402,404,408,410,411,412,414,417,418,419)] <- "South-Western"
weighted.mean(dta$poor,dta$hmult, na.rm=T)
sapply(split(dta,dta$earegion) ,  function(x) weighted.mean(x$poor,x$hmult, na.rm=T))

dta <- read.dta("/home/bjvca/data/data/GAP/Haruna/UNHS_2012/work/povmeas_ent_flex.dta")

weighted.mean(dta$povline_ent_m,dta$popwt, na.rm=T)
sapply(split(dta,dta$urban) ,  function(x) weighted.mean(x$povline_ent_m,x$popwt, na.rm=T))
sapply(split(dta,dta$region) ,  function(x) weighted.mean(x$povline_ent_m,x$popwt, na.rm=T))
sapply(split(dta,dta$strata) ,  function(x) weighted.mean(x$povline_ent_m,x$popwt, na.rm=T))

