psmatch2 Impr_LS dep_ratio hh_size Educ_yrs age_hh Sex Central West D_Road Val_Assets T_Land Landsq maleshr Agesq urban D_off_farmY, out(MilkYield) common kernel kerneltype (normal)
gen MILK=MilkYield-_MilkYield if _support==1 & _treated==1
 rbounds MILK, gamma(1 (.5) 2) alpha(.95)

psmatch2 Impr_LS dep_ratio hh_size Educ_yrs age_hh Sex Central West D_Road Val_Assets T_Land Landsq maleshr Agesq urban D_off_farmY, out(PEC_aem30) common kernel kerneltype (normal)
 gen PCE=PEC_aem30-_PEC_aem30 if _support==1 & _treated==1
rbounds PCE, gamma(1 (.5) 2)

psmatch2 Impr_LS dep_ratio hh_size Educ_yrs age_hh Sex Central West D_Road Val_Assets T_Land Landsq maleshr Agesq urban D_off_farmY, out(haz06) common kernel kerneltype (normal)
 gen HAZ=haz06-_haz06 if _support==1 & _treated==1
rbounds HAZ, gamma(1 (.5) 2)

psmatch2 Impr_LS dep_ratio hh_size Educ_yrs age_hh Sex Central West D_Road Val_Assets T_Land Landsq maleshr Agesq urban D_off_farmY, out(waz06) common kernel kerneltype (normal)
 gen WAZ=waz06-_waz06 if _support==1 & _treated==1
rbounds WAZ, gamma(1 (.5) 3)

psmatch2 Impr_LS dep_ratio hh_size Educ_yrs age_hh Sex Central West D_Road Val_Assets T_Land Landsq maleshr Agesq urban D_off_farmY, out(whz06) common kernel kerneltype (normal)
 gen WHZ=whz06-_whz06 if _support==1 & _treated==1
rbounds WHZ, gamma(1 (.2) 2)

psmatch2 Impr_LS dep_ratio hh_size Educ_yrs age_hh Sex Central West D_Road Val_Assets T_Land Landsq maleshr Agesq urban D_off_farmY, out(fpov09) common kernel kerneltype (normal)
 gen FPOV=fpov09-_fpov09 if _support==1 & _treated==1
rbounds FPOV, gamma(1 (.2) 2)

psmatch2 Impr_LS dep_ratio hh_size Educ_yrs age_hh Sex Central West D_Road Val_Assets T_Land Landsq maleshr Agesq urban D_off_farmY, out(spov09) common kernel kerneltype (normal)
 gen SPOV=spov09-_spov09 if _support==1 & _treated==1
rbounds SPOV, gamma(1 (.2) 2)

psmatch2 Impr_LS dep_ratio hh_size Educ_yrs age_hh Sex Central West D_Road Val_Assets T_Land Landsq maleshr Agesq urban D_off_farmY, out(meals) common kernel kerneltype (normal)
 gen MEAL=meals-_meals if _support==1 & _treated==1
rbounds MEAL, gamma(1 (.2) 2)
