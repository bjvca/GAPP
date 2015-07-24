library(foreign) 
sec4 <- read.dta("/home/bjvca/data/data/GAP/Haruna/UNHS_2005/GAPP2/in/hsec4.dta")
sec2 <- read.dta("/home/bjvca/data/data/GAP/Haruna/UNHS_2005/GAPP2/in/hsec2.dta")
sec1 <- read.dta("/home/bjvca/data/data/GAP/Haruna/UNHS_2005/GAPP2/in/hsec1b.dta")

edu <- merge(sec2,sec4,by.x=c("hh", "pid"), by.y=c("hh", "pid") )
edu <- subset(edu,edu$h2q8a>=18)
edu <- merge(edu, sec1)

weighted.mean(edu$h4q12=="unable to read and write", edu$hmult, na.rm=T)
tapply(edu$h4q12=="unable to read and write",edu$h2q4, FUN=weighted.mean, na.rm=T)



library(foreign) 
sec4 <- read.dta("/home/bjvca/data/data/GAP/Haruna/in/HSEC4.dta")
sec2 <- read.dta("/home/bjvca/data/data/GAP/Haruna/in/HSEC2.dta")
sec1 <- read.dta("/home/bjvca/data/data/GAP/Haruna/in/HSEC1.dta")

edu <- merge(sec2,sec4,by.x=c("hh", "h2q1"), by.y=c("hh", "h4q1") )
edu <- subset(edu,edu$h2q8>=18)
edu <- merge(edu, sec1)
edu <- subset(edu,!is.na(edu$hmult))
summary(na.omit(edu$h4q2))/length(na.omit(edu$h4q2))
weighted.mean(edu$h4q2=="Unable to read and write", edu$hmult, na.rm=T)
 tapply(edu$h4q2=="Unable to read and write",edu$h2q3, FUN=weighted.mean, na.rm=T)


library(foreign) 
sec4 <- read.dta("/home/bjvca/data/data/GAP/Haruna/UNPS_2010_11/in/GSEC4.dta")
sec2 <- read.dta("/home/bjvca/data/data/GAP/Haruna/UNPS_2010_11/in/GSEC2.dta")
sec1 <- read.dta("/home/bjvca/data/data/GAP/Haruna/UNPS_2010_11/in/GSEC1.dta")

edu <- merge(sec2,sec4,by.x=c("HHID", "PID"), by.y=c("HHID", "PID") )
edu <- subset(edu,edu$h2q8>=18)
edu <- merge(edu, sec1)
edu <- subset(edu,!is.na(edu$wgt10))

weighted.mean(edu$h4q4=="Unable to read and write", edu$wgt10, na.rm=T)
 tapply(edu$h4q4=="Unable to read and write",edu$h2q3, FUN=weighted.mean, na.rm=T)


library(foreign) 
sec4 <- read.dta("/home/bjvca/data/data/GAP/Haruna/UNPS_2011_12/in/GSEC4.dta")
sec2 <- read.dta("/home/bjvca/data/data/GAP/Haruna/UNPS_2011_12/in/GSEC2.dta")
sec1 <- read.dta("/home/bjvca/data/data/GAP/Haruna/UNPS_2011_12/in/GSEC1.dta")

edu <- merge(sec2,sec4,by.x=c("HHID", "PID"), by.y=c("HHID", "PID") )
edu <- subset(edu,edu$h2q8>=18)
edu <- merge(edu, sec1)
edu <- subset(edu,!is.na(edu$mult))

weighted.mean(edu$h4q4=="Unable to read and write", edu$mult, na.rm=T)

 tapply(edu$h4q4=="Unable to read and write",edu$h2q3, FUN=weighted.mean, na.rm=T)


library(foreign) 
sec4 <- read.dta("/home/bjvca/data/data/GAP/Haruna/UNHS_2012/in/GSEC4.dta")
sec2 <- read.dta("/home/bjvca/data/data/GAP/Haruna/UNHS_2012/in/GSEC2.dta")
sec1 <- read.dta("/home/bjvca/data/data/GAP/Haruna/UNHS_2012/in/GSEC1cln.dta")

edu <- merge(sec2,sec4,by.x=c("HHID", "pid"), by.y=c("HHID", "pid") )
edu <- subset(edu,edu$r07>=18)
edu <- merge(edu, sec1)
edu <- subset(edu,!is.na(edu$mult))
weighted.mean(edu$e02=="Unable to read and write", edu$mult, na.rm=T)

 tapply(edu$e02=="Unable to read and write",edu$r02, FUN=weighted.mean, na.rm=T)
