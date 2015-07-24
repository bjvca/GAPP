library(foreign) 
sec15 <- read.dta("/home/bjvca/data/data/GAP/Haruna/UNHS_2005/GAPP2/in/hsec15.dta") 
sec1 <- read.dta("/home/bjvca/data/data/GAP/Haruna/UNHS_2005/GAPP2/in/hsec11.dta") 

table(sec15$h15q3)/sum(!is.na((sec15$h15q3)))




sec11 <- read.dta("/home/bjvca/data/data/GAP/Haruna/in/HSEC11.dta")

table(sec11$h11q2)/sum(!is.na((sec11$h11q2)))
