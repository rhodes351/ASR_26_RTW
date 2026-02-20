///////////////////////////////////////////////////////////////////////////////////
/// Imputed CBP data: Create dataset
/// This file merges in data from the County Business Patterns Surveys using the files created by Eckert et al. 
/// The strategy is to merge in data from the imputed files at the county-level with the raw data. 
/// Create a variable that flags whether the county has an imputed value. We can use this to remove these obs as a robustness check.
/// 

// AR Edit 2/6/2024 -- fix how imputations are handled for 1986-2016 (see if I'm not including any by mistake?)
//							I think we are always using the raw employment counts because suppression is not an issue on the county level
//							Double check to see if an issue for employment counts on the county-by-broad industry level... 
//					-- add new variables for firm size, employment/establishments by broad industry groups

// AR Edit 4/30/2024 -- Recode zeros on employment with no nonzero value on establishments -- likely suppressed cell. Do this after filling in with imputations where available.

// AR Edit 4/07/2025 -- Add weights to earlier CBP files to adjust for shifting industries over time. Start with broad industry definitions as of 2017 NAICS. Use Eckert and colleagues weights for 1997 SIC to 1998 NAICs. Use industry classification scheme as denoted by the 1998 NAICS (for broad industry groups) 


*********************************************************************************************************
* Old CBP Data (1946-1974)

* 1946 - no imputations
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0001\38834-0001-Data.dta", clear
gen year=1946
/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/
drop EMP_IMP

ren *, lower

ren rpunit est

* Drop small county groups and territories
drop if fipscty==.

drop if st_name=="ALASKA"
drop if st_name=="HAWAII"
drop if st_name=="PUERTO RICO"

preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

*gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 /*emp_imp2*/ est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

/*gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')*/

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 /*emp_imp_07*/ est_07 ///
		 emp_10 /*emp_imp_10*/ est_10 ///
		 emp_15 /*emp_imp_15*/ est_15 ///
		 emp_20 /*emp_imp_20*/ est_20 ///
		 emp_40 /*emp_imp_40*/ est_40 ///
		 emp_50 /*emp_imp_50*/ est_50 ///
		 emp_52 /*emp_imp_52*/ est_52 ///
		 emp_60 /*emp_imp_60*/ est_60 ///
		 emp_70 /*emp_imp_70*/ est_70 ///
		 emp_99 /*emp_imp_99*/ est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1946
save `cbp_imp_ind_1946', replace

restore

keep if sic=="----" // this collapses to the county-level

merge 1:1 fipstate fipscty using "`cbp_imp_ind_1946'", gen(_merge1)
drop _merge1
		
* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0 
*recode est_`sic' (0=.) (.=0)		
	
		}


tempfile cbp1946
save `cbp1946', replace


* 1947 
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0002\38834-0002-Data.dta", clear
gen year=1947
/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/
ren EMP EMP_IMP

* Drop small county groups and territories
drop if FIPSCTY==. 

drop if ST_NAME=="ALASKA"
drop if ST_NAME=="HAWAII"
drop if ST_NAME=="PUERTO RICO"

merge 1:1 FIPSTATE FIPSCTY SIC using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0004\38834-0004-Data.dta"

ren EMP EMP_IMPa
ren EMP_IMP EMP
ren EMP_IMPa EMP_IMP

gen ANY_IMP=1 if EMP==. & EMP_IMP!=.
	replace ANY_IMP=0 if EMP==EMP_IMP

ren *, lower

ren rpunit est

preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1947
save `cbp_imp_ind_1947', replace

restore

keep if sic=="----"


merge 1:1 fipstate fipscty using "`cbp_imp_ind_1947'", gen(_merge1)
drop _merge1

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}


tempfile cbp1947
save `cbp1947', replace

* 1948 
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0005\38834-0005-Data.dta", clear
gen year=1948
/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/
ren EMP EMP_IMP

*keep if SIC=="----"

* Drop small county groups and territories
drop if FIPSCTY==. 

drop if ST_NAME=="ALASKA"
drop if ST_NAME=="HAWAII"
drop if ST_NAME=="PUERTO RICO"

merge 1:1 FIPSTATE FIPSCTY SIC using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0007\38834-0007-Data.dta"

ren EMP EMP_IMPa
ren EMP_IMP EMP
ren EMP_IMPa EMP_IMP

gen ANY_IMP=1 if EMP==. & EMP_IMP!=.
	replace ANY_IMP=0 if EMP==EMP_IMP
	
*keep if SIC=="----" // this collapses to the county-level	

ren *, lower

ren rpunit est

preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1948
save `cbp_imp_ind_1948', replace

restore

keep if sic=="----"


merge 1:1 fipstate fipscty using "`cbp_imp_ind_1948'", gen(_merge1)
drop _merge1

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	

		}


tempfile cbp1948
save `cbp1948', replace


* 1949 (Exclude b.c. CBP only reported on manufacturing industries)

* 1950 (Exclude b.c. CBP only reported on manufacturing industries)

* 1951
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0014\38834-0014-Data.dta", clear
gen year=1951
/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/
ren EMP EMP_IMP

*keep if SIC=="----"

* Drop small county groups and territories
drop if FIPSCTY==. 

drop if ST_NAME=="ALASKA"
drop if ST_NAME=="HAWAII"
drop if ST_NAME=="PUERTO RICO"

merge 1:1 FIPSTATE FIPSCTY SIC using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0016\38834-0016-Data.dta"

ren EMP EMP_IMPa
ren EMP_IMP EMP
ren EMP_IMPa EMP_IMP

gen ANY_IMP=1 if EMP==. & EMP_IMP!=.
	replace ANY_IMP=0 if EMP==EMP_IMP
	
*keep if SIC=="----" // this collapses to the county-level	

ren *, lower

ren rpunit est

preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1951
save `cbp_imp_ind_1951', replace

restore

keep if sic=="----"


merge 1:1 fipstate fipscty using "`cbp_imp_ind_1951'", gen(_merge1)
drop _merge1

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}


tempfile cbp1951
save `cbp1951', replace

* 1953
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0017\38834-0017-Data.dta", clear
gen year=1953
/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/
ren EMP EMP_IMP

*keep if SIC=="----"

* Drop small county groups and territories
drop if FIPSCTY==. 

drop if ST_NAME=="ALASKA"
drop if ST_NAME=="HAWAII"
drop if ST_NAME=="PUERTO RICO"

merge 1:1 FIPSTATE FIPSCTY SIC using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0019\38834-0019-Data.dta"

ren EMP EMP_IMPa
ren EMP_IMP EMP
ren EMP_IMPa EMP_IMP

gen ANY_IMP=1 if EMP==. & EMP_IMP!=.
	replace ANY_IMP=0 if EMP==EMP_IMP
	
*keep if SIC=="----" // this collapses to the county-level	

ren *, lower

ren rpunit est

preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1953
save `cbp_imp_ind_1953', replace

restore

keep if sic=="----"


merge 1:1 fipstate fipscty using "`cbp_imp_ind_1953'", gen(_merge1)
drop _merge1

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}


tempfile cbp1953
save `cbp1953', replace


* 1956
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0020\38834-0020-Data.dta", clear
gen year=1956
/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/
ren EMP EMP_IMP

*keep if SIC=="----"

* Drop small county groups and territories
drop if FIPSCTY==. 

drop if ST_NAME=="ALASKA"
drop if ST_NAME=="HAWAII"
drop if ST_NAME=="PUERTO RICO"

merge 1:1 FIPSTATE FIPSCTY SIC using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0022\38834-0022-Data.dta"

ren EMP EMP_IMPa
ren EMP_IMP EMP
ren EMP_IMPa EMP_IMP

gen ANY_IMP=1 if EMP==. & EMP_IMP!=.
	replace ANY_IMP=0 if EMP==EMP_IMP
	
*keep if SIC=="----" // this collapses to the county-level	

ren *, lower

ren rpunit est

preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1956
save `cbp_imp_ind_1956', replace

restore

keep if sic=="----"


merge 1:1 fipstate fipscty using "`cbp_imp_ind_1956'", gen(_merge1)
drop _merge1


* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)		
	
		}


tempfile cbp1956
save `cbp1956', replace


* 1959
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0023\38834-0023-Data.dta", clear
gen year=1959
/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/
ren EMP EMP_IMP

*keep if SIC=="----"

* Drop small county groups and territories
drop if FIPSCTY==. 

drop if ST_NAME=="PUERTO RICO"


merge 1:1 FIPSTATE FIPSCTY SIC using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0025\38834-0025-Data.dta"

ren EMP EMP_IMPa
ren EMP_IMP EMP
ren EMP_IMPa EMP_IMP

gen ANY_IMP=1 if EMP==. & EMP_IMP!=.
	replace ANY_IMP=0 if EMP==EMP_IMP
	
*keep if SIC=="----" // this collapses to the county-level	

ren *, lower

ren rpunit est

preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1959
save `cbp_imp_ind_1959', replace

restore

keep if sic=="----"


merge 1:1 fipstate fipscty using "`cbp_imp_ind_1959'", gen(_merge1)
drop _merge1

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)		
	
		}


tempfile cbp1959
save `cbp1959', replace


* 1962
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0026\38834-0026-Data.dta", clear
gen year=1962
/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/
ren EMP EMP_IMP

*keep if SIC=="----"

* Drop small county groups and territories
drop if FIPSCTY==. 

drop if ST_NAME=="PUERTO RICO"


merge 1:1 FIPSTATE FIPSCTY SIC using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0028\38834-0028-Data.dta"

ren EMP EMP_IMPa
ren EMP_IMP EMP
ren EMP_IMPa EMP_IMP

gen ANY_IMP=1 if EMP==. & EMP_IMP!=.
	replace ANY_IMP=0 if EMP==EMP_IMP
	
*keep if SIC=="----" // this collapses to the county-level	

ren *, lower

ren rpunit est

preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1962
save `cbp_imp_ind_1962', replace

restore

keep if sic=="----"


merge 1:1 fipstate fipscty using "`cbp_imp_ind_1962'", gen(_merge1)
drop _merge1

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)		
	
		}


tempfile cbp1962
save `cbp1962', replace


* 1964
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0029\38834-0029-Data.dta", clear
gen year=1964
/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/
ren EMP EMP_IMP

*keep if SIC=="----"


* Drop small county groups and territories
drop if FIPSCTY==. 

drop if ST_NAME=="PUERTO RICO"


merge 1:1 FIPSTATE FIPSCTY SIC using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0031\38834-0031-Data.dta"

ren EMP EMP_IMPa
ren EMP_IMP EMP
ren EMP_IMPa EMP_IMP

gen ANY_IMP=1 if EMP==. & EMP_IMP!=.
	replace ANY_IMP=0 if EMP==EMP_IMP
	
*keep if SIC=="----" // this collapses to the county-level	

ren *, lower

ren rpunit est

preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1964
save `cbp_imp_ind_1964', replace

restore

keep if sic=="----"


merge 1:1 fipstate fipscty using "`cbp_imp_ind_1964'", gen(_merge1)
drop _merge1


* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)			
	
		}


tempfile cbp1964
save `cbp1964', replace


* 1965
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0032\38834-0032-Data.dta", clear
gen year=1965
/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/
ren EMP EMP_IMP

*keep if SIC=="----"

* Drop small county groups and territories
drop if FIPSCTY==. 

drop if ST_NAME=="PUERTO RICO"

merge 1:1 FIPSTATE FIPSCTY SIC using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0034\38834-0034-Data.dta"

ren EMP EMP_IMPa
ren EMP_IMP EMP
ren EMP_IMPa EMP_IMP

gen ANY_IMP=1 if EMP==. & EMP_IMP!=.
	replace ANY_IMP=0 if EMP==EMP_IMP
	
*keep if SIC=="----" // this collapses to the county-level

ren *, lower	

ren rpunit est

preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1965
save `cbp_imp_ind_1965', replace

restore

keep if sic=="----"


merge 1:1 fipstate fipscty using "`cbp_imp_ind_1965'", gen(_merge1)
drop _merge1


* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}


tempfile cbp1965
save `cbp1965', replace


* 1966
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0035\38834-0035-Data.dta", clear
gen year=1966
/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/
ren EMP EMP_IMP

*keep if SIC=="----"

* Drop small county groups and territories
drop if FIPSCTY==. 

drop if ST_NAME=="PUERTO RICO"

merge 1:1 FIPSTATE FIPSCTY SIC using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0037\38834-0037-Data.dta"

ren EMP EMP_IMPa
ren EMP_IMP EMP
ren EMP_IMPa EMP_IMP

gen ANY_IMP=1 if EMP==. & EMP_IMP!=.
	replace ANY_IMP=0 if EMP==EMP_IMP
	
*keep if SIC=="----" // this collapses to the county-level	

ren *, lower

ren rpunit est

preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1966
save `cbp_imp_ind_1966', replace

restore

keep if sic=="----"


merge 1:1 fipstate fipscty using "`cbp_imp_ind_1966'", gen(_merge1)
drop _merge1


* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}


tempfile cbp1966
save `cbp1966', replace


* 1967
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0038\38834-0038-Data.dta", clear
gen year=1967

/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/

ren EMP EMP_IMP

*keep if SIC=="----"

* Drop small county groups and territories
drop if FIPSCTY==. 

drop if ST_NAME=="PUERTO RICO"

merge 1:1 FIPSTATE FIPSCTY SIC using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0040\38834-0040-Data.dta"

ren EMP EMP_IMPa
ren EMP_IMP EMP
ren EMP_IMPa EMP_IMP

gen ANY_IMP=1 if EMP==. & EMP_IMP!=.
	replace ANY_IMP=0 if EMP==EMP_IMP
	
*keep if SIC=="----" // this collapses to the county-level

ren *, lower	

ren rpunit est

preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1967
save `cbp_imp_ind_1967', replace

restore

keep if sic=="----"

merge 1:1 fipstate fipscty using "`cbp_imp_ind_1967'", gen(_merge1)
drop _merge1


* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}


tempfile cbp1967
save `cbp1967', replace


* 1968
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0041\38834-0041-Data.dta", clear
gen year=1968
/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/
ren EMP EMP_IMP

*keep if SIC=="----"

* Drop small county groups and territories
drop if FIPSCTY==. 

drop if ST_NAME=="PUERTO RICO"

merge 1:1 FIPSTATE FIPSCTY SIC using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0043\38834-0043-Data.dta"

ren EMP EMP_IMPa
ren EMP_IMP EMP
ren EMP_IMPa EMP_IMP

gen ANY_IMP=1 if EMP==. & EMP_IMP!=.
	replace ANY_IMP=0 if EMP==EMP_IMP
	
*keep if SIC=="----" // this collapses to the county-level

ren *, lower

ren rpunit est	

preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1968
save `cbp_imp_ind_1968', replace

restore

keep if sic=="----"


merge 1:1 fipstate fipscty using "`cbp_imp_ind_1968'", gen(_merge1)
drop _merge1


* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)		
	
		}


tempfile cbp1968
save `cbp1968', replace


* 1969
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0044\38834-0044-Data.dta", clear
gen year=1969
/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/
ren EMP EMP_IMP

*keep if SIC=="----"

* Drop small county groups and territories
drop if FIPSCTY==. 

drop if ST_NAME=="PUERTO RICO"

merge 1:1 FIPSTATE FIPSCTY SIC using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0046\38834-0046-Data.dta"

ren EMP EMP_IMPa
ren EMP_IMP EMP
ren EMP_IMPa EMP_IMP

gen ANY_IMP=1 if EMP==. & EMP_IMP!=.
	replace ANY_IMP=0 if EMP==EMP_IMP
	
*keep if SIC=="----" // this collapses to the county-level	

ren *, lower

ren rpunit est

preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1969
save `cbp_imp_ind_1969', replace

restore

keep if sic=="----"


merge 1:1 fipstate fipscty using "`cbp_imp_ind_1969'", gen(_merge1)
drop _merge1


* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}


tempfile cbp1969
save `cbp1969', replace


* 1970
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0047\38834-0047-Data.dta", clear
gen year=1970
/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/
ren EMP EMP_IMP

*keep if SIC=="----"

* Drop small county groups and territories
drop if FIPSCTY==. 

drop if ST_NAME=="PUERTO RICO"

merge 1:1 FIPSTATE FIPSCTY SIC using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0048\38834-0048-Data.dta"

ren EMP EMP_IMPa
ren EMP_IMP EMP
ren EMP_IMPa EMP_IMP

gen ANY_IMP=1 if EMP==. & EMP_IMP!=.
	replace ANY_IMP=0 if EMP==EMP_IMP
	
*keep if SIC=="----" // this collapses to the county-level	

ren *, lower

ren rpunit est

preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1970
save `cbp_imp_ind_1970', replace

restore

keep if sic=="----"


merge 1:1 fipstate fipscty using "`cbp_imp_ind_1970'", gen(_merge1)
drop _merge1

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}


tempfile cbp1970
save `cbp1970', replace


* 1971
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0049\38834-0049-Data.dta", clear
gen year=1971
/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/
ren EMP EMP_IMP

*keep if SIC=="----"

* Drop small county groups and territories
drop if FIPSCTY==. 

drop if ST_NAME=="PUERTO RICO"

merge 1:1 FIPSTATE FIPSCTY SIC using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0050\38834-0050-Data.dta"

ren EMP EMP_IMPa
ren EMP_IMP EMP
ren EMP_IMPa EMP_IMP

gen ANY_IMP=1 if EMP==. & EMP_IMP!=.
	replace ANY_IMP=0 if EMP==EMP_IMP
	
*keep if SIC=="----" // this collapses to the county-level	

ren *, lower

ren rpunit est

preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1971
save `cbp_imp_ind_1971', replace

restore

keep if sic=="----"


merge 1:1 fipstate fipscty using "`cbp_imp_ind_1971'", gen(_merge1)
drop _merge1

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}


tempfile cbp1971
save `cbp1971', replace


* 1972
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0051\38834-0051-Data.dta", clear
gen year=1972
/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/
ren EMP EMP_IMP

*keep if SIC=="----"

* Drop small county groups and territories
drop if FIPSCTY==. 

drop if ST_NAME=="PUERTO RICO"

merge 1:1 FIPSTATE FIPSCTY SIC using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0052\38834-0052-Data.dta"
drop _merge

ren EMP EMP_IMPa
ren EMP_IMP EMP
ren EMP_IMPa EMP_IMP

gen ANY_IMP=1 if EMP==. & EMP_IMP!=.
	replace ANY_IMP=0 if EMP==EMP_IMP
	
*keep if SIC=="----" // this collapses to the county-level	

ren *, lower

ren rpunit est


preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1972
save `cbp_imp_ind_1972', replace

restore

keep if sic=="----"


merge 1:1 fipstate fipscty using "`cbp_imp_ind_1972'", gen(_merge1)
drop _merge1

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}


tempfile cbp1972
save `cbp1972', replace


* 1973
use "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0053\38834-0053-Data.dta", clear
gen year=1973
/*
gen FIPSCTYa=round(FIPSCTY)
drop FIPSCTY
ren FIPSCTYa FIPSCTY
*/
ren EMP EMP_IMP

*keep if SIC=="----"

* Drop small county groups and territories
drop if FIPSCTY==. 

drop if ST_NAME=="PUERTO RICO"

merge 1:1 FIPSTATE FIPSCTY SIC using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-old\ICPSR_38834\DS0054\38834-0054-Data.dta"
drop _merge

ren EMP EMP_IMPa
ren EMP_IMP EMP
ren EMP_IMPa EMP_IMP

gen ANY_IMP=1 if EMP==. & EMP_IMP!=.
	replace ANY_IMP=0 if EMP==EMP_IMP
	
*keep if SIC=="----" // this collapses to the county-level	

ren *, lower

ren rpunit est


preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=sic

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1973
save `cbp_imp_ind_1973', replace

restore

keep if sic=="----"


merge 1:1 fipstate fipscty using "`cbp_imp_ind_1973'", gen(_merge1)
drop _merge1

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)		
	
		}


tempfile cbp1973
save `cbp1973', replace




**************************************************************************************************************************************
* Use NHGIS Data for 1974-1985
* AR Edit 2/6/2024 -- replace with new files that also include variables by large industry category....
* 					  In case not already obvious, only use this new data for establishment counts....

* Note: Use the panel to merge employment count imputations into 1974 CBP from NHGIS
* Using NHGIS for 1974 bc coding of SIC is messed up in Eckert et al. files...
* For now, do not worry about imputations for employment counts in 1974 CBP data...

* Edit AR 04/08/2025
* 	Have to re-shape the data on establishments into county-by-industry group form and then merge in weights to get consistent codes
*	After industry estimates get their appropriate weights, reshape the data back into wide form

cd "C:\Users\rhodes.351\Downloads\PCD\Data\nhgis-75-85-by-industry\

* 1974
foreach year in 1974 {
	
do "C:\Users\rhodes.351\Downloads\PCD\Data\nhgis-75-85-by-industry\nhgis0010_ds101_`year'_county.do"
		
destring statea, gen(fipstate)
destring countya, gen(fipscty2)

ren c4w001 n1_4
ren c4w002 n5_9
ren c4w003 n10_19
ren c4w004 n20_49
ren c4w005 n50_99 
ren c4w006 n100_249
ren c4w007 n250_499
ren c4w008 n500_999
ren c4w009 n1000
ren c4x001 n1000_1
ren c4x002 n1000_2
ren c4x003 n1000_3
ren c4x004 n1000_4

ren c4s001 emp
ren c4t001 qp1
ren c4u001 ap
ren c4v001 est

ren c4saah001 emp_07
ren c4vaah001 est_07
ren c4saax001 emp_10
ren c4vaax001 est_10
ren c4sadh001 emp_15
ren c4vadh001 est_15
ren c4saer001 emp_20
ren c4vaer001 est_20
ren c4sbbp001 emp_40
ren c4vbbp001 est_40
ren c4sbfb001 emp_50
ren c4vbfb001 est_50
ren c4sbih001 emp_52
ren c4vbih001 est_52
ren c4sblv001 emp_60
ren c4vblv001 est_60
ren c4sboe001 emp_70
ren c4vboe001 est_70
ren c4sbvv001 emp_99
ren c4vbvv001 est_99

replace qp1=qp1/1000
replace ap=ap/1000

keep fipstate fipscty2 emp qp1 ap est emp_* est_* n*	
		
				}

preserve	

egen id=group(fipstate fipscty2)
			
* create mini panel to merge in weights to get consistent NAICS industry codes
foreach var in emp_ est_ {
	
ren `var'07 `var'1
ren `var'10 `var'2
ren `var'15 `var'3
ren `var'20 `var'4
ren `var'40 `var'5
ren `var'50 `var'6
ren `var'52 `var'7
ren `var'60 `var'8
ren `var'70 `var'9	
ren `var'99 `var'10	
	
	}

gl vars emp_ est_

reshape long $vars, i(id) j(sic)

tostring sic, replace

replace sic="07--" if sic=="1"
replace sic="10--" if sic=="2"
replace sic="15--" if sic=="3"
replace sic="20--" if sic=="4"
replace sic="40--" if sic=="5"
replace sic="50--" if sic=="6"
replace sic="52--" if sic=="7"
replace sic="60--" if sic=="8"
replace sic="70--" if sic=="9"
replace sic="99--" if sic=="10"

ren sic sic87

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp_* weight_hybrid

*gen emp_imp2=emp_imp* weight_hybrid

gen est2=est_* weight_estabs

collapse (sum) emp2 /*emp_imp2*/ est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

/*gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')*/

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 /*emp_imp_07*/ est_07 ///
		 emp_10 /*emp_imp_10*/ est_10 ///
		 emp_15 /*emp_imp_15*/ est_15 ///
		 emp_20 /*emp_imp_20*/ est_20 ///
		 emp_40 /*emp_imp_40*/ est_40 ///
		 emp_50 /*emp_imp_50*/ est_50 ///
		 emp_52 /*emp_imp_52*/ est_52 ///
		 emp_60 /*emp_imp_60*/ est_60 ///
		 emp_70 /*emp_imp_70*/ est_70 ///
		 emp_99 /*emp_imp_99*/ est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1974
save `cbp_imp_ind_1974', replace

restore

drop emp_* est_*

merge 1:1 fipstate fipscty using "`cbp_imp_ind_1974'", gen(_merge1)
drop _merge1


gen year=1974

*gen any_imp=1 if emp==. & emp_imp!=.
*	replace any_imp=0 if emp==emp_imp
	
gen fipscty=fipscty2

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}


tempfile cbp1974
save `cbp1974', replace
	
	
		

* 1975
foreach year in 1975 {

do "C:\Users\rhodes.351\Downloads\PCD\Data\nhgis-75-85-by-industry\nhgis0010_ds101_`year'_county.do"
		
destring statea, gen(fipstate)
destring countya, gen(fipscty2)

ren c4w001 n1_4
ren c4w002 n5_9
ren c4w003 n10_19
ren c4w004 n20_49
ren c4w005 n50_99 
ren c4w006 n100_249
ren c4w007 n250_499
ren c4w008 n500_999
ren c4w009 n1000
ren c4x001 n1000_1
ren c4x002 n1000_2
ren c4x003 n1000_3
ren c4x004 n1000_4

ren c4s001 emp
ren c4t001 qp1
ren c4u001 ap
ren c4v001 est

ren c4saah001 emp_07
ren c4vaah001 est_07
ren c4saax001 emp_10
ren c4vaax001 est_10
ren c4sadh001 emp_15
ren c4vadh001 est_15
ren c4saer001 emp_20
ren c4vaer001 est_20
ren c4sbbp001 emp_40
ren c4vbbp001 est_40
ren c4sbfb001 emp_50
ren c4vbfb001 est_50
ren c4sbih001 emp_52
ren c4vbih001 est_52
ren c4sblv001 emp_60
ren c4vblv001 est_60
ren c4sboe001 emp_70
ren c4vboe001 est_70
ren c4sbvv001 emp_99
ren c4vbvv001 est_99


replace qp1=qp1/1000
replace ap=ap/1000

keep fipstate fipscty2 emp qp1 ap est emp_* est_* n*
		
				}
				
preserve
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_1975\1975\Final Imputed\efsy_cbp_1975.txt", varn(1) clear

gen emp_imp=ub

ren fipscty fipscty2

*keep if naics=="----"

gen sic=naics

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" "00" {

gen emp_imp_`sic'=emp_imp if sic=="`sic'--"
bys fipstate fipscty2: egen emp_imp_`sic'b=max(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
	
		}
		
keep if sic=="----" // this collapses to the county-level

keep fipstate fipscty2 emp_imp emp_imp_* adjusted

tempfile cbp_imp1975
save `cbp_imp1975', replace

restore

duplicates tag fipstate fipscty2, gen(same)
drop if same==1 & emp==0

merge 1:1 fipstate fipscty2 using "`cbp_imp1975'", gen(_merge1)
drop _merge1

gen year=1975

gen any_imp=1 if emp==. & emp_imp!=.
	replace any_imp=0 if emp==emp_imp
	
	
preserve	

egen id=group(fipstate fipscty2)

			
* create mini panel to merge in weights to get consistent NAICS industry codes
foreach var in emp_ emp_imp_ est_ {
	
ren `var'07 `var'1
ren `var'10 `var'2
ren `var'15 `var'3
ren `var'20 `var'4
ren `var'40 `var'5
ren `var'50 `var'6
ren `var'52 `var'7
ren `var'60 `var'8
ren `var'70 `var'9	
ren `var'99 `var'10	
	
	}

gl vars emp_ emp_imp_ est_

reshape long $vars, i(id) j(sic)

tostring sic, replace

replace sic="07--" if sic=="1"
replace sic="10--" if sic=="2"
replace sic="15--" if sic=="3"
replace sic="20--" if sic=="4"
replace sic="40--" if sic=="5"
replace sic="50--" if sic=="6"
replace sic="52--" if sic=="7"
replace sic="60--" if sic=="8"
replace sic="70--" if sic=="9"
replace sic="99--" if sic=="10"

ren sic sic87

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp_* weight_hybrid

gen emp_imp2=emp_imp_* weight_hybrid

gen est2=est_* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1975
save `cbp_imp_ind_1975', replace

restore

drop est_* emp_imp_* emp_07 emp_10 emp_15 emp_20 emp_40 emp_50 emp_52 emp_60 emp_70 emp_99

merge 1:1 fipstate fipscty using "`cbp_imp_ind_1975'", gen(_merge1)
drop _merge1
		
	
gen fipscty=fipscty2

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)		
	
		}


tempfile cbp1975
save `cbp1975', replace
				


* 1981
foreach year in 1981 {
	
do "C:\Users\rhodes.351\Downloads\PCD\Data\nhgis-75-85-by-industry\nhgis0010_ds101_`year'_county.do"
		
destring statea, gen(fipstate)
destring countya, gen(fipscty2)

ren c4w001 n1_4
ren c4w002 n5_9
ren c4w003 n10_19
ren c4w004 n20_49
ren c4w005 n50_99 
ren c4w006 n100_249
ren c4w007 n250_499
ren c4w008 n500_999
ren c4w009 n1000
ren c4x001 n1000_1
ren c4x002 n1000_2
ren c4x003 n1000_3
ren c4x004 n1000_4

ren c4s001 emp
ren c4t001 qp1
ren c4u001 ap
ren c4v001 est

ren c4saah001 emp_07
ren c4vaah001 est_07
ren c4saax001 emp_10
ren c4vaax001 est_10
ren c4sadh001 emp_15
ren c4vadh001 est_15
ren c4saer001 emp_20
ren c4vaer001 est_20
ren c4sbbp001 emp_40
ren c4vbbp001 est_40
ren c4sbfb001 emp_50
ren c4vbfb001 est_50
ren c4sbih001 emp_52
ren c4vbih001 est_52
ren c4sblv001 emp_60
ren c4vblv001 est_60
ren c4sboe001 emp_70
ren c4vboe001 est_70
ren c4sbvv001 emp_99
ren c4vbvv001 est_99


replace qp1=qp1/1000
replace ap=ap/1000

keep fipstate fipscty2 emp qp1 ap est emp_* est_* n*
		
				}
				
preserve
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_1981\1981\Final Imputed\efsy_cbp_1981.csv", varn(1) clear

gen emp_imp=ub

ren fipscty fipscty2

*keep if naics=="----"

gen sic=naics 

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" "00" {

gen emp_imp_`sic'=emp_imp if sic=="`sic'--"
bys fipstate fipscty2: egen emp_imp_`sic'b=max(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
	
		}
		
keep if sic=="----" // this collapses to the county-level

keep fipstate fipscty2 emp_imp emp_imp_* adjusted

tempfile cbp_imp1981
save `cbp_imp1981', replace

restore

merge 1:1 fipstate fipscty2 using "`cbp_imp1981'", gen(_merge1)
drop _merge1

gen year=1981

gen any_imp=1 if emp==. & emp_imp!=.
	replace any_imp=0 if emp==emp_imp
	
	
preserve	

egen id=group(fipstate fipscty2)

			
* create mini panel to merge in weights to get consistent NAICS industry codes
foreach var in emp_ emp_imp_ est_ {
	
ren `var'07 `var'1
ren `var'10 `var'2
ren `var'15 `var'3
ren `var'20 `var'4
ren `var'40 `var'5
ren `var'50 `var'6
ren `var'52 `var'7
ren `var'60 `var'8
ren `var'70 `var'9	
ren `var'99 `var'10	
	
	}

gl vars emp_ emp_imp_ est_

reshape long $vars, i(id) j(sic)

tostring sic, replace

replace sic="07--" if sic=="1"
replace sic="10--" if sic=="2"
replace sic="15--" if sic=="3"
replace sic="20--" if sic=="4"
replace sic="40--" if sic=="5"
replace sic="50--" if sic=="6"
replace sic="52--" if sic=="7"
replace sic="60--" if sic=="8"
replace sic="70--" if sic=="9"
replace sic="99--" if sic=="10"

ren sic sic87

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp_* weight_hybrid

gen emp_imp2=emp_imp_* weight_hybrid

gen est2=est_* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_1981
save `cbp_imp_ind_1981', replace

restore

drop est_* emp_imp_* emp_07 emp_10 emp_15 emp_20 emp_40 emp_50 emp_52 emp_60 emp_70 emp_99

merge 1:1 fipstate fipscty using "`cbp_imp_ind_1981'", gen(_merge1)
drop _merge1	
	
gen fipscty=fipscty2

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)		
	
		}

tempfile cbp1981
save `cbp1981', replace
				
				
				
			
* 1976
foreach year in /*1975*/ 76 {
	
do "C:\Users\rhodes.351\Downloads\PCD\Data\nhgis-75-85-by-industry\nhgis0010_ds101_19`year'_county.do"
		
destring statea, gen(fipstate)
destring countya, gen(fipscty2)

ren c4w001 n1_4
ren c4w002 n5_9
ren c4w003 n10_19
ren c4w004 n20_49
ren c4w005 n50_99 
ren c4w006 n100_249
ren c4w007 n250_499
ren c4w008 n500_999
ren c4w009 n1000
ren c4x001 n1000_1
ren c4x002 n1000_2
ren c4x003 n1000_3
ren c4x004 n1000_4

ren c4s001 emp
ren c4t001 qp1
ren c4u001 ap
ren c4v001 est

ren c4saah001 emp_07
ren c4vaah001 est_07
ren c4saax001 emp_10
ren c4vaax001 est_10
ren c4sadh001 emp_15
ren c4vadh001 est_15
ren c4saer001 emp_20
ren c4vaer001 est_20
ren c4sbbp001 emp_40
ren c4vbbp001 est_40
ren c4sbfb001 emp_50
ren c4vbfb001 est_50
ren c4sbih001 emp_52
ren c4vbih001 est_52
ren c4sblv001 emp_60
ren c4vblv001 est_60
ren c4sboe001 emp_70
ren c4vboe001 est_70
ren c4sbvv001 emp_99
ren c4vbvv001 est_99


replace qp1=qp1/1000
replace ap=ap/1000

keep fipstate fipscty2 emp qp1 ap est emp_* est_* n*	

tempfile cbp19`year'
save cbp19`year', replace


preserve
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_19`year'\19`year'\Final Imputed\efsy_cbp_19`year'.csv", varn(1) clear

gen emp_imp=ub

ren fipscty fipscty2

*keep if naics=="----"

gen sic=naics 

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" "00" {

gen emp_imp_`sic'=emp_imp if sic=="`sic'--"
bys fipstate fipscty2: egen emp_imp_`sic'b=max(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
	
		}
		
keep if sic=="----" // this collapses to the county-level

keep fipstate fipscty2 emp_imp emp_imp_* adjusted

tempfile cbp_imp19`year'
save `cbp_imp19`year'', replace

restore

merge 1:1 fipstate fipscty2 using "`cbp_imp19`year''", gen(_merge1)
drop _merge1

gen year=19`year'

gen any_imp=1 if emp==. & emp_imp!=.
	replace any_imp=0 if emp==emp_imp

preserve	

egen id=group(fipstate fipscty2)

			
* create mini panel to merge in weights to get consistent NAICS industry codes
foreach var in emp_ emp_imp_ est_ {
	
ren `var'07 `var'1
ren `var'10 `var'2
ren `var'15 `var'3
ren `var'20 `var'4
ren `var'40 `var'5
ren `var'50 `var'6
ren `var'52 `var'7
ren `var'60 `var'8
ren `var'70 `var'9	
ren `var'99 `var'10	
	
	}

gl vars emp_ emp_imp_ est_

reshape long $vars, i(id) j(sic)

tostring sic, replace

replace sic="07--" if sic=="1"
replace sic="10--" if sic=="2"
replace sic="15--" if sic=="3"
replace sic="20--" if sic=="4"
replace sic="40--" if sic=="5"
replace sic="50--" if sic=="6"
replace sic="52--" if sic=="7"
replace sic="60--" if sic=="8"
replace sic="70--" if sic=="9"
replace sic="99--" if sic=="10"

ren sic sic87

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp_* weight_hybrid

gen emp_imp2=emp_imp_* weight_hybrid

gen est2=est_* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_19`year'
save `cbp_imp_ind_19`year'', replace

restore

drop est_* emp_imp_* emp_07 emp_10 emp_15 emp_20 emp_40 emp_50 emp_52 emp_60 emp_70 emp_99

merge 1:1 fipstate fipscty using "`cbp_imp_ind_19`year''", gen(_merge1)
drop _merge1	


gen fipscty=fipscty2
	
* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}


tempfile cbp19`year'
save `cbp19`year'', replace	
		
				}			
				
				
* 1977-1985
foreach year in /*1975 76*/ 77 78 79 80 /*1981*/ 82 83 84 85 {
	
do "C:\Users\rhodes.351\Downloads\PCD\Data\nhgis-75-85-by-industry\nhgis0010_ds101_19`year'_county.do"
		
destring statea, gen(fipstate)
destring countya, gen(fipscty2)

ren c4w001 n1_4
ren c4w002 n5_9
ren c4w003 n10_19
ren c4w004 n20_49
ren c4w005 n50_99 
ren c4w006 n100_249
ren c4w007 n250_499
ren c4w008 n500_999
ren c4w009 n1000
ren c4x001 n1000_1
ren c4x002 n1000_2
ren c4x003 n1000_3
ren c4x004 n1000_4

ren c4s001 emp
ren c4t001 qp1
ren c4u001 ap
ren c4v001 est

ren c4saah001 emp_07
ren c4vaah001 est_07
ren c4saax001 emp_10
ren c4vaax001 est_10
ren c4sadh001 emp_15
ren c4vadh001 est_15
ren c4saer001 emp_20
ren c4vaer001 est_20
ren c4sbbp001 emp_40
ren c4vbbp001 est_40
ren c4sbfb001 emp_50
ren c4vbfb001 est_50
ren c4sbih001 emp_52
ren c4vbih001 est_52
ren c4sblv001 emp_60
ren c4vblv001 est_60
ren c4sboe001 emp_70
ren c4vboe001 est_70
ren c4sbvv001 emp_99
ren c4vbvv001 est_99

replace qp1=qp1/1000
replace ap=ap/1000

keep fipstate fipscty2 emp qp1 ap est emp_* est_* n*	

tempfile cbp19`year'
save cbp19`year', replace


preserve
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_19`year'\19`year'\Final Imputed\efsy_cbp_19`year'.csv", varn(1) clear

gen emp_imp=ub

ren fipscty fipscty2

*keep if naics=="----"

gen sic=naics 

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" "00" {

gen emp_imp_`sic'=emp_imp if sic=="`sic'--"
bys fipstate fipscty2: egen emp_imp_`sic'b=max(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
	
		}
		
keep if sic=="----" // this collapses to the county-level

keep fipstate fipscty2 emp_imp emp_imp_* adjusted


tempfile cbp_imp19`year'
save `cbp_imp19`year'', replace

restore

merge 1:1 fipstate fipscty2 using "`cbp_imp19`year''", gen(_merge1)
drop _merge1

gen year=19`year'

gen any_imp=1 if emp==. & emp_imp!=.
	replace any_imp=0 if emp==emp_imp

	
preserve	

egen id=group(fipstate fipscty2)

			
* create mini panel to merge in weights to get consistent NAICS industry codes
foreach var in emp_ emp_imp_ est_ {
	
ren `var'07 `var'1
ren `var'10 `var'2
ren `var'15 `var'3
ren `var'20 `var'4
ren `var'40 `var'5
ren `var'50 `var'6
ren `var'52 `var'7
ren `var'60 `var'8
ren `var'70 `var'9	
ren `var'99 `var'10	
	
	}

gl vars emp_ emp_imp_ est_

reshape long $vars, i(id) j(sic)

tostring sic, replace

replace sic="07--" if sic=="1"
replace sic="10--" if sic=="2"
replace sic="15--" if sic=="3"
replace sic="20--" if sic=="4"
replace sic="40--" if sic=="5"
replace sic="50--" if sic=="6"
replace sic="52--" if sic=="7"
replace sic="60--" if sic=="8"
replace sic="70--" if sic=="9"
replace sic="99--" if sic=="10"

ren sic sic87

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp_* weight_hybrid

gen emp_imp2=emp_imp_* weight_hybrid

gen est2=est_* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_19`year'
save `cbp_imp_ind_19`year'', replace

restore

drop est_* emp_imp_* emp_07 emp_10 emp_15 emp_20 emp_40 emp_50 emp_52 emp_60 emp_70 emp_99

merge 1:1 fipstate fipscty using "`cbp_imp_ind_19`year''", gen(_merge1)
drop _merge1	


gen fipscty=fipscty2

	
* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}


tempfile cbp19`year'
save `cbp19`year'', replace	
		
				}			
				
			
		
***********************************************************************************************************************************************************		
* 1986-1997

* 1986 
foreach year in 86 {
	
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_19`year'\19`year'\cbp`year'co.txt", varn(1) clear bindquote(strict)

* check matching up of size of dist. establishments vs. count of establishments
gen estestab=n1_4+ n5_9+ n10_19+ n20_49+ n50_99+ n100_249+ n250_499+ n500_999+ n1000+ n1000_1+ n1000_2+ n1000_3+ n1000_4

gen match=1 if estestab==est
	replace match=0 if estestab!=est
tab match

* when summed establishments does not match count of established, go with sum of establishments if non-zero
replace est=estestab if match==0 & estestab!=0

/* use next higher integer when non-integer
gen testab2=ceil(testab)
drop testab		
ren testab2 testab
*/

drop match estestab

*keep if sic=="----"
		
preserve
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_19`year'\19`year'\Final Imputed\efsy_cbp_19`year'.csv", varn(1) clear

gen emp_imp=ub

*keep if naics=="----"

keep fipstate fipscty naics emp_imp

tempfile cbp_imp19`year'
save `cbp_imp19`year'', replace

restore

gen naics=sic

merge 1:1 fipstate fipscty naics using "`cbp_imp19`year''", gen(_merge1)
drop _merge1

gen year=19`year'

gen any_imp=1 if emp==. & emp_imp!=.
	replace any_imp=0 if emp==emp_imp
	
	
preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=naics

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" | naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_19`year'
save `cbp_imp_ind_19`year'', replace

restore

keep if sic=="----"	

merge 1:1 fipstate fipscty using "`cbp_imp_ind_19`year''", gen(_merge1)
drop _merge1

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}

		
tempfile cbp19`year'
save `cbp19`year'', replace

			}
						
			
* 1987-1997			
foreach year in 87 88 89 90 91 92 93 94 95 96 97 {
	
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_19`year'\19`year'\cbp`year'co.txt", varn(1) clear bindquote(strict)

* check matching up of size of dist. establishments vs. count of establishments
gen estestab=n1_4+ n5_9+ n10_19+ n20_49+ n50_99+ n100_249+ n250_499+ n500_999+ n1000+ n1000_1+ n1000_2+ n1000_3+ n1000_4

gen match=1 if estestab==est
	replace match=0 if estestab!=est
tab match

* when summed establishments does not match count of established, go with sum of establishments if non-zero
replace est=estestab if match==0 & estestab!=0

/* use next higher integer when non-integer
gen testab2=ceil(testab)
drop testab		
ren testab2 testab
*/

drop match estestab

*keep if sic=="----"
		
preserve
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_19`year'\19`year'\Final Imputed\efsy_cbp_19`year'.csv", varn(1) clear

gen emp_imp=ub

*keep if naics=="----"

keep fipstate fipscty naics emp_imp

tempfile cbp_imp19`year'
save `cbp_imp19`year'', replace

restore

gen naics=sic

merge 1:1 fipstate fipscty naics using "`cbp_imp19`year''", gen(_merge1)
drop _merge1

gen year=19`year'

gen any_imp=1 if emp==. & emp_imp!=.
	replace any_imp=0 if emp==emp_imp
	
	
preserve	
* Merge in 1998 codes for the NAICs with weights for concordinating 	
gen sic87=naics

joinby sic87 using "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_final_concordances\full_sic87_naics97.dta"	

gen emp2=emp* weight_hybrid

gen emp_imp2=emp_imp* weight_hybrid

gen est2=est* weight_estabs

collapse (sum) emp2 emp_imp2 est2, by(fipstate fipscty naics97)	
	
gen sic="07--" if naics97=="11----" // ag/forestry/fishery
	replace sic="10--" if naics97=="21----" // mining
	replace sic="15--" if naics97=="23----" // construction
	replace sic="20--" if naics97=="31----" | naics97=="32----" | naics97=="33----" // manufacturing
	replace sic="40--" if naics97=="22----" | naics97=="48----" | naics97=="49----" // transportation and public utilities
	replace sic="50--" if naics97=="42----" // wholesale trade
	replace sic="52--" if naics97=="44----" | naics97=="45----" // retail trade
	replace sic="60--" if naics97=="52----" | naics97=="53----" // FIRE
	replace sic="70--" if naics97=="51----" |naics97=="54----" | naics97=="55----" | naics97=="56----" | naics97=="61----" | naics97=="62----" | ///
						  naics97=="71----" | naics97=="72----" | naics97=="81----" // services
	replace sic="99--"  if naics97=="99----" | naics97=="92----" // uncodable industries (including public admin)
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
	
gen emp_`sic'=emp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=sum(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'
replace emp_`sic'=round(emp_`sic')

gen emp_imp_`sic'=emp_imp2 if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=sum(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'
replace emp_imp_`sic'=round(emp_imp_`sic')

gen est_`sic'=est2 if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=sum(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
replace est_`sic'=round(est_`sic')
	
		}		
		
collapse emp_07 emp_imp_07 est_07 ///
		 emp_10 emp_imp_10 est_10 ///
		 emp_15 emp_imp_15 est_15 ///
		 emp_20 emp_imp_20 est_20 ///
		 emp_40 emp_imp_40 est_40 ///
		 emp_50 emp_imp_50 est_50 ///
		 emp_52 emp_imp_52 est_52 ///
		 emp_60 emp_imp_60 est_60 ///
		 emp_70 emp_imp_70 est_70 ///
		 emp_99 emp_imp_99 est_99 ///
		 , by(fipstate fipscty)		
		
tempfile cbp_imp_ind_19`year'
save `cbp_imp_ind_19`year'', replace

restore

keep if sic=="----"	

merge 1:1 fipstate fipscty using "`cbp_imp_ind_19`year''", gen(_merge1)
drop _merge1
		

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)		
	
		}
	

tempfile cbp19`year'
save `cbp19`year'', replace

			}
						

			
* 1998-1999
foreach year in 98 99 {
	
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_19`year'\19`year'\cbp`year'co.txt", varn(1) clear bindquote(strict)

* check matching up of size of dist. establishments vs. count of establishments
gen estestab=n1_4+ n5_9+ n10_19+ n20_49+ n50_99+ n100_249+ n250_499+ n500_999+ n1000+ n1000_1+ n1000_2+ n1000_3+ n1000_4

gen match=1 if estestab==est
	replace match=0 if estestab!=est
tab match

* when summed establishments does not match count of established, go with sum of establishments
replace est=estestab if match==0 & estestab!=0

/* use next higher integer when non-integer
gen testab2=ceil(testab)
drop testab		
ren testab2 testab
*/

drop match estestab

*keep if naics=="------"
		
preserve
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_19`year'\19`year'\Final Imputed\efsy_cbp_19`year'.csv", varn(1) clear

gen emp_imp=ub

*keep if naics=="------"

keep fipstate fipscty naics emp_imp

// drop one duplicate obs in 1999 -- > not sure why this is...
duplicates drop fipstate fipscty naics, force

tempfile cbp_imp19`year'
save `cbp_imp19`year'', replace

restore

// drop one duplicate obs in 1999 -- > not sure why this is...
duplicates drop fipstate fipscty naics, force

merge 1:1 fipstate fipscty naics using "`cbp_imp19`year''", gen(_merge1)
drop _merge1
/*
gen twodigitnaics=substr(naics,3,4)
gen twodigitnaicsb=1 if twodigitnaics=="----"
drop twodigitnaics
ren twodigitnaicsb twodigitnaics

keep if twodigitnaics==1 

drop twodigitnaics
*/

// code sic by hand bc easier
// note: naics is 2017 vintage
gen sic="07--" if naics=="11----" // ag/forestry/fishery
	replace sic="10--" if naics=="21----" // mining
	replace sic="15--" if naics=="23----" // construction
	replace sic="20--" if naics=="31----" | naics=="32----" | naics=="33----" // manufacturing
	replace sic="40--" if naics=="22----" | naics=="48----" | naics=="49----" // transportation and public utilities
	replace sic="50--" if naics=="42----" // wholesale trade
	replace sic="52--" if naics=="44----" | naics=="45----" // retail trade
	replace sic="60--" if naics=="52----" | naics=="53----" // FIRE
	replace sic="70--" if naics=="51----" | naics=="54----" | naics=="55----" | naics=="56----" | naics=="61----" | naics=="62----" | ///
						  naics=="71----" | naics=="72----" | naics=="81----" // services
	replace sic="99--"  if naics=="99----" | naics=="92----" // uncodable industries (including public admin)

gen year=19`year'

gen any_imp=1 if emp==. & emp_imp!=.
	replace any_imp=0 if emp==emp_imp 
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" "00" {
	
bys fipstate fipscty: egen emp_`sic'=sum(emp) if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=max(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'

bys fipstate fipscty: egen emp_imp_`sic'=sum(emp_imp) if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=max(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'

bys fipstate fipscty: egen est_`sic'=sum(est) if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=max(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
	
		}
		
keep if naics=="------"		

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}

	
tempfile cbp19`year'
save `cbp19`year'', replace

			}	
			
			
			
*2000-2001
foreach year in 00 01 {
	
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_20`year'\20`year'\cbp`year'co.txt", varn(1) clear bindquote(strict)

* check matching up of size of dist. establishments vs. count of establishments
gen estestab=n1_4+ n5_9+ n10_19+ n20_49+ n50_99+ n100_249+ n250_499+ n500_999+ n1000+ n1000_1+ n1000_2+ n1000_3+ n1000_4

gen match=1 if estestab==est
	replace match=0 if estestab!=est
tab match

* when summed establishments does not match count of established, go with sum of establishments
replace est=estestab if match==0 & estestab!=0

/* use next higher integer when non-integer
gen testab2=ceil(testab)
drop testab		
ren testab2 testab
*/

drop match estestab

*keep if naics=="------"
		
preserve
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_20`year'\20`year'\Final Imputed\efsy_cbp_20`year'.csv", varn(1) clear

gen emp_imp=ub

*keep if naics=="------"

keep fipstate fipscty naics emp_imp

tempfile cbp_imp20`year'
save `cbp_imp20`year'', replace

restore

merge 1:1 fipstate fipscty naics using "`cbp_imp20`year''", gen(_merge1)
drop _merge1

gen year=20`year'

gen twodigitnaics=substr(naics,3,4)
gen twodigitnaicsb=1 if twodigitnaics=="----"
drop twodigitnaics
ren twodigitnaicsb twodigitnaics

keep if twodigitnaics==1 

drop twodigitnaics


// code sic by hand bc easier
// note: naics is 2017 vintage
gen sic="07--" if naics=="11----" // ag/forestry/fishery
	replace sic="10--" if naics=="21----" // mining
	replace sic="15--" if naics=="23----" // construction
	replace sic="20--" if naics=="31----" | naics=="32----" | naics=="33----" // manufacturing
	replace sic="40--" if naics=="22----" | naics=="48----" | naics=="49----" // transportation and public utilities
	replace sic="50--" if naics=="42----" // wholesale trade
	replace sic="52--" if naics=="44----" | naics=="45----" // retail trade
	replace sic="60--" if naics=="52----" | naics=="53----" // FIRE
	replace sic="70--" if naics=="51----" | naics=="54----" | naics=="55----" | naics=="56----" | naics=="61----" | naics=="62----" | ///
						  naics=="71----" | naics=="72----" | naics=="81----" // services
	replace sic="99--"  if naics=="99----" | naics=="92----" // uncodable industries (including public admin)

gen any_imp=1 if emp==. & emp_imp!=.
	replace any_imp=0 if emp==emp_imp
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" "00" {
	
bys fipstate fipscty: egen emp_`sic'=sum(emp) if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=max(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'

bys fipstate fipscty: egen emp_imp_`sic'=sum(emp_imp) if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=max(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'

bys fipstate fipscty: egen est_`sic'=sum(est) if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=max(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
	
		}
		
keep if naics=="------"		

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}


tempfile cbp20`year'
save `cbp20`year'', replace

			}		
			
* 2002-2006			
foreach year in 02 03 04 05 06 {
	
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_20`year'\20`year'\cbp`year'co.txt", varn(1) clear bindquote(strict)

* check matching up of size of dist. establishments vs. count of establishments
gen estestab=n1_4+ n5_9+ n10_19+ n20_49+ n50_99+ n100_249+ n250_499+ n500_999+ n1000+ n1000_1+ n1000_2+ n1000_3+ n1000_4

gen match=1 if estestab==est
	replace match=0 if estestab!=est
tab match

* when summed establishments does not match count of established, go with sum of establishments
replace est=estestab if match==0 & estestab!=0

/* use next higher integer when non-integer
gen testab2=ceil(testab)
drop testab		
ren testab2 testab
*/

drop match estestab

*keep if naics=="------"
		
preserve
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_20`year'\20`year'\Final Imputed\efsy_cbp_20`year'.csv", varn(1) clear

gen emp_imp=ub

*keep if naics=="------"

keep fipstate fipscty naics emp_imp

tempfile cbp_imp20`year'
save `cbp_imp20`year'', replace

restore

merge 1:1 fipstate fipscty naics using "`cbp_imp20`year''", gen(_merge1)
drop _merge1

gen year=20`year'

gen twodigitnaics=substr(naics,3,4)
gen twodigitnaicsb=1 if twodigitnaics=="----"
drop twodigitnaics
ren twodigitnaicsb twodigitnaics

keep if twodigitnaics==1 

drop twodigitnaics


// code sic by hand bc easier
// note: naics is 2017 vintage
gen sic="07--" if naics=="11----" // ag/forestry/fishery
	replace sic="10--" if naics=="21----" // mining
	replace sic="15--" if naics=="23----" // construction
	replace sic="20--" if naics=="31----" | naics=="32----" | naics=="33----" // manufacturing
	replace sic="40--" if naics=="22----" | naics=="48----" | naics=="49----" // transportation and public utilities
	replace sic="50--" if naics=="42----" // wholesale trade
	replace sic="52--" if naics=="44----" | naics=="45----" // retail trade
	replace sic="60--" if naics=="52----" | naics=="53----" // FIRE
	replace sic="70--" if naics=="51----" | naics=="54----" | naics=="55----" | naics=="56----" | naics=="61----" | naics=="62----" | ///
						  naics=="71----" | naics=="72----" | naics=="81----" // services
	replace sic="99--"  if naics=="99----" | naics=="92----" // other industries (including public admin)
	
gen any_imp=1 if emp==. & emp_imp!=.
	replace any_imp=0 if emp==emp_imp
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" "00" {
	
bys fipstate fipscty: egen emp_`sic'=sum(emp) if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=max(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'

bys fipstate fipscty: egen emp_imp_`sic'=sum(emp_imp) if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=max(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'

bys fipstate fipscty: egen est_`sic'=sum(est) if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=max(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
	
		}
		
keep if naics=="------"		

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)		
	
		}


tempfile cbp20`year'
save `cbp20`year'', replace

			}		
			
			
			
*2007-2013
foreach year in 07 08 09 10 11 12 13 {
	
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_20`year'\20`year'\cbp`year'co.txt", varn(1) clear bindquote(strict)

* check matching up of size of dist. establishments vs. count of establishments
gen estestab=n1_4+ n5_9+ n10_19+ n20_49+ n50_99+ n100_249+ n250_499+ n500_999+ n1000+ n1000_1+ n1000_2+ n1000_3+ n1000_4

gen match=1 if estestab==est
	replace match=0 if estestab!=est
tab match

* when summed establishments does not match count of established, go with sum of establishments
replace est=estestab if match==0 & estestab!=0

/* use next higher integer when non-integer
gen testab2=ceil(testab)
drop testab		
ren testab2 testab
*/

drop match estestab

*keep if naics=="------"
		
preserve
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_20`year'\20`year'\Final Imputed\efsy_cbp_20`year'.csv", varn(1) clear

gen emp_imp=ub

*keep if naics=="------"

keep fipstate fipscty naics emp_imp

tempfile cbp_imp20`year'
save `cbp_imp20`year'', replace

restore

merge 1:1 fipstate fipscty naics using "`cbp_imp20`year''", gen(_merge1)
drop _merge1

gen year=20`year'

gen twodigitnaics=substr(naics,3,4)
gen twodigitnaicsb=1 if twodigitnaics=="----"
drop twodigitnaics
ren twodigitnaicsb twodigitnaics

keep if twodigitnaics==1 

drop twodigitnaics


// code sic by hand bc easier
// note: naics is 2017 vintage
gen sic="07--" if naics=="11----" // ag/forestry/fishery
	replace sic="10--" if naics=="21----" // mining
	replace sic="15--" if naics=="23----" // construction
	replace sic="20--" if naics=="31----" | naics=="32----" | naics=="33----" // manufacturing
	replace sic="40--" if naics=="22----" | naics=="48----" | naics=="49----" // transportation and public utilities
	replace sic="50--" if naics=="42----" // wholesale trade
	replace sic="52--" if naics=="44----" | naics=="45----" // retail trade
	replace sic="60--" if naics=="52----" | naics=="53----" // FIRE
	replace sic="70--" if naics=="51----" | naics=="54----" | naics=="55----" | naics=="56----" | naics=="61----" | naics=="62----" | ///
						  naics=="71----" | naics=="72----" | naics=="81----" // services
	replace sic="99--"  if naics=="99----" | naics=="92----" // uncodable industries (including public admin)
 
gen any_imp=1 if emp==. & emp_imp!=.
	replace any_imp=0 if emp==emp_imp
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" "00" {
	
bys fipstate fipscty: egen emp_`sic'=sum(emp) if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=max(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'

bys fipstate fipscty: egen emp_imp_`sic'=sum(emp_imp) if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=max(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'

bys fipstate fipscty: egen est_`sic'=sum(est) if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=max(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
	
		}
		
keep if naics=="------"		

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}


tempfile cbp20`year'
save `cbp20`year'', replace

			}	
			
			
			
*2014
foreach year in 14 {
	
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_20`year'\20`year'\cbp`year'co.txt", varn(1) clear bindquote(strict)

* check matching up of size of dist. establishments vs. count of establishments
gen estestab=n1_4+ n5_9+ n10_19+ n20_49+ n50_99+ n100_249+ n250_499+ n500_999+ n1000+ n1000_1+ n1000_2+ n1000_3+ n1000_4

gen match=1 if estestab==est
	replace match=0 if estestab!=est
tab match

* when summed establishments does not match count of established, go with sum of establishments
replace est=estestab if match==0 & estestab!=0

/* use next higher integer when non-integer
gen testab2=ceil(testab)
drop testab		
ren testab2 testab
*/

drop match estestab

*keep if naics=="------"
		
preserve
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_20`year'\20`year'\Final Imputed\efsy_cbp_20`year'.csv", varn(1) clear

gen emp_imp=ub

*keep if naics=="------"

keep fipstate fipscty naics emp_imp

tempfile cbp_imp20`year'
save `cbp_imp20`year'', replace

restore

merge 1:1 fipstate fipscty naics using "`cbp_imp20`year''", gen(_merge1)
drop _merge1

gen year=20`year'

gen twodigitnaics=substr(naics,3,4)
gen twodigitnaicsb=1 if twodigitnaics=="----"
drop twodigitnaics
ren twodigitnaicsb twodigitnaics

keep if twodigitnaics==1 

drop twodigitnaics


// code sic by hand bc easier
// note: naics is 2017 vintage
gen sic="07--" if naics=="11----" // ag/forestry/fishery
	replace sic="10--" if naics=="21----" // mining
	replace sic="15--" if naics=="23----" // construction
	replace sic="20--" if naics=="31----" | naics=="32----" | naics=="33----" // manufacturing
	replace sic="40--" if naics=="22----" | naics=="48----" | naics=="49----" // transportation and public utilities
	replace sic="50--" if naics=="42----" // wholesale trade
	replace sic="52--" if naics=="44----" | naics=="45----" // retail trade
	replace sic="60--" if naics=="52----" | naics=="53----" // FIRE
	replace sic="70--" if naics=="51----" | naics=="54----" | naics=="55----" | naics=="56----" | naics=="61----" | naics=="62----" | ///
						  naics=="71----" | naics=="72----" | naics=="81----" // services
	replace sic="99--"  if naics=="99----" | naics=="92----" // uncodable industries (including public admin)

gen any_imp=1 if emp==. & emp_imp!=.
	replace any_imp=0 if emp==emp_imp
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" "00" {
	
bys fipstate fipscty: egen emp_`sic'=sum(emp) if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=max(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'

bys fipstate fipscty: egen emp_imp_`sic'=sum(emp_imp) if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=max(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'

bys fipstate fipscty: egen est_`sic'=sum(est) if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=max(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
	
		}

keep if naics=="------"

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}


tempfile cbp20`year'
save `cbp20`year'', replace

			}		
			
			
*2015-2016
foreach year in 15 16 {
	
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_20`year'\20`year'\cbp`year'co.txt", varn(1) clear bindquote(strict)

* check matching up of size of dist. establishments vs. count of establishments
gen estestab=n1_4+ n5_9+ n10_19+ n20_49+ n50_99+ n100_249+ n250_499+ n500_999+ n1000+ n1000_1+ n1000_2+ n1000_3+ n1000_4

gen match=1 if estestab==est
	replace match=0 if estestab!=est
tab match

* when summed establishments does not match count of established, go with sum of establishments
replace est=estestab if match==0 & estestab!=0

/* use next higher integer when non-integer
gen testab2=ceil(testab)
drop testab		
ren testab2 testab
*/

drop match estestab

*keep if naics=="------"
		
preserve
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-74-16\efsy_20`year'\20`year'\Final Imputed\efsy_cbp_20`year'.csv", varn(1) clear

gen emp_imp=ub

*keep if naics=="------"

keep fipstate fipscty naics emp_imp

tempfile cbp_imp20`year'
save `cbp_imp20`year'', replace

restore

merge 1:1 fipstate fipscty naics using "`cbp_imp20`year''", gen(_merge1)
drop _merge1

gen year=20`year'

gen twodigitnaics=substr(naics,3,4)
gen twodigitnaicsb=1 if twodigitnaics=="----"
drop twodigitnaics
ren twodigitnaicsb twodigitnaics

keep if twodigitnaics==1 

drop twodigitnaics


// code sic by hand bc easier
// note: naics is 2017 vintage
gen sic="07--" if naics=="11----" // ag/forestry/fishery
	replace sic="10--" if naics=="21----" // mining
	replace sic="15--" if naics=="23----" // construction
	replace sic="20--" if naics=="31----" | naics=="32----" | naics=="33----" // manufacturing
	replace sic="40--" if naics=="22----" | naics=="48----" | naics=="49----" // transportation and public utilities
	replace sic="50--" if naics=="42----" // wholesale trade
	replace sic="52--" if naics=="44----" | naics=="45----" // retail trade
	replace sic="60--" if naics=="52----" | naics=="53----" // FIRE
	replace sic="70--" if naics=="51----" | naics=="54----" | naics=="55----" | naics=="56----" | naics=="61----" | naics=="62----" | ///
						  naics=="71----" | naics=="72----" | naics=="81----" // services
	replace sic="99--"  if naics=="99----" | naics=="92----" // uncodable industries (including public admin)
	
gen any_imp=1 if emp==. & emp_imp!=.
	replace any_imp=0 if emp==emp_imp
	
foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" "00" {
	
bys fipstate fipscty: egen emp_`sic'=sum(emp) if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=max(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'

bys fipstate fipscty: egen emp_imp_`sic'=sum(emp_imp) if sic=="`sic'--"
bys fipstate fipscty: egen emp_imp_`sic'b=max(emp_imp_`sic')
drop emp_imp_`sic'
ren emp_imp_`sic'b emp_imp_`sic'

bys fipstate fipscty: egen est_`sic'=sum(est) if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=max(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
	
		}

keep if naics=="------"

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}


tempfile cbp20`year'
save `cbp20`year'', replace

			}
			
			
**************************************************************************************************************************************************			
** Merge in 2017-2019
** Downloaded from the Census
			
foreach year in 17 18 19 { 
	
import delimited "C:\Users\rhodes.351\Downloads\PCD\Data\cbp-17-19\cbp_`year'\cbp`year'co.txt", varn(1) clear	
	
foreach var in n5 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000 n1000_1 n1000_2 n1000_3 n1000_4 {
	
gen `var'_b=real(`var')	

drop `var'

ren `var'_b `var'	
	
recode `var' (.=0) if est!=. 	
	
		}	
		
*keep if naics=="------"		
		
gen year=20`year'

ren n5 n1_5

gen twodigitnaics=substr(naics,3,4)
gen twodigitnaicsb=1 if twodigitnaics=="----"
drop twodigitnaics
ren twodigitnaicsb twodigitnaics

keep if twodigitnaics==1 

drop twodigitnaics

// code sic by hand bc easier
// note: naics is 2017 vintage
gen sic="07--" if naics=="11----" // ag/forestry/fishery
	replace sic="10--" if naics=="21----" // mining
	replace sic="15--" if naics=="23----" // construction
	replace sic="20--" if naics=="31----" | naics=="32----" | naics=="33----" // manufacturing
	replace sic="40--" if naics=="22----" | naics=="48----" | naics=="49----" // transportation and public utilities
	replace sic="50--" if naics=="42----" // wholesale trade
	replace sic="52--" if naics=="44----" | naics=="45----" // retail trade
	replace sic="60--" if naics=="52----" | naics=="53----" // FIRE
	replace sic="70--" if naics=="51----" | naics=="54----" | naics=="55----" | naics=="56----" | naics=="61----" | naics=="62----" | ///
						  naics=="71----" | naics=="72----" | naics=="81----" // services
	replace sic="99--"  if naics=="99----" | naics=="92----" // uncodable industries (including public admin)

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" "00" {
	
bys fipstate fipscty: egen emp_`sic'=sum(emp) if sic=="`sic'--"
bys fipstate fipscty: egen emp_`sic'b=max(emp_`sic')
drop emp_`sic'
ren emp_`sic'b emp_`sic'

bys fipstate fipscty: egen est_`sic'=sum(est) if sic=="`sic'--"
bys fipstate fipscty: egen est_`sic'b=max(est_`sic')
drop est_`sic'
ren est_`sic'b est_`sic'
	
		}

keep if naics=="------"

* recode missing values indicated by "." to be zero for a given industry in a given county if valid

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" { 
	
recode emp_`sic' (0=.) if est_`sic'==0
*recode emp_imp_`sic'
*recode est_`sic' (.=0)	
	
		}

tempfile cbp20`year'
save `cbp20`year'', replace		
	
	
		}
		
		
		
		
*****************************************************************************************************************************************************		
** Append county-level data into county-year panel
** Years: 1946, 1947, 1951, 1953, 1956, 1959, 1962, 1964-2019	
		
append using `cbp1946'
append using `cbp1947'
append using `cbp1951'
append using `cbp1953'
append using `cbp1956'
append using `cbp1959'
append using `cbp1962'
append using `cbp1964'
append using `cbp1965'
append using `cbp1966'
append using `cbp1967'
append using `cbp1968'
append using `cbp1969'
append using `cbp1970'
append using `cbp1971'
append using `cbp1972'
append using `cbp1973'
append using `cbp1974'		
append using `cbp1975'		
append using `cbp1976'		
append using `cbp1977', force		
append using `cbp1978', force		
append using `cbp1979', force		
append using `cbp1980', force		
append using `cbp1981', force		
append using `cbp1982', force		
append using `cbp1983', force		
append using `cbp1984', force		
append using `cbp1985', force		
append using `cbp1986', force		
append using `cbp1987', force		
append using `cbp1988', force		
append using `cbp1989', force		
append using `cbp1990', force		
append using `cbp1991', force		
append using `cbp1992', force		
append using `cbp1993', force		
append using `cbp1994', force
append using `cbp1995', force
append using `cbp1996', force
append using `cbp1997', force
append using `cbp1998', force
append using `cbp1999', force
append using `cbp2000', force
append using `cbp2001', force
append using `cbp2002', force
append using `cbp2003', force		
append using `cbp2004', force	
append using `cbp2005', force	
append using `cbp2006', force	
append using `cbp2007', force	
append using `cbp2008', force	
append using `cbp2009', force	
append using `cbp2010', force	
append using `cbp2011', force	
append using `cbp2012', force	
append using `cbp2013', force
append using `cbp2014', force	
append using `cbp2015', force	
append using `cbp2016', force	
append using `cbp2017', force	
append using `cbp2018', force

drop if year==.




* Code establishment counts by establishment size categories
* Version 1 accomodates all years....
gen estsize_1_49=0
gen estsize_50_99=0
gen estsize_100_499=0
gen estsize_500=0

replace estsize_1_49=n1+n2+n3+n4 if year==1946
replace estsize_1_49=n0_3+n4_7+n8_19+n20_49 if year>1946 & year<=1973
replace estsize_1_49=n1_4+n5_9+n10_19+n20_49 if year>1973 & year<=2016
replace estsize_1_49=n1_5+n5_9+n10_19+n20_49 if year>2016 & year<=2019

replace estsize_50_99=n5 if year==1946
replace estsize_50_99=n50_99 if year>1946

replace estsize_100_499=n6 if year==1946
replace estsize_100_499=n100_499 if year>1946 & year<=1950
replace estsize_100_499=n100_249+n250_499 if year>1950 & year<=2019

replace estsize_500=n7 if year==1946
replace estsize_500=n500 if year>1946 & year<=1973
replace estsize_500=n500_999+n1000 if year>1973 & year<=2019

* Version 2 -- can use from 1974 onwards....
gen estsize_500_999=0
gen estsize_1000=0

replace estsize_500_999=n500_999 if year>1973 & year<=2019

replace estsize_1000=n1000 if year>1973 & year<=2019


keep fipscty year fipstate emp emp_* emp_imp emp_imp_* any_imp est est_* qp1 ap cty* estsize*
order fipscty year fipstate emp emp_* emp_imp emp_imp_* any_imp est est_* qp1 ap cty* estsize*				
		
sort fipstate fipscty year

egen cntyid=group(fipstate fipscty)



cd "C:\Users\rhodes.351\Downloads\PCD\Output\"

tab year
tabstat emp emp_imp, by(year) stats(mean n)
bys year: egen emp_national=sum(emp)
bys year: egen emp_imp_national=sum(emp_imp)

replace emp_national=emp_national/1000000
replace emp_imp_national=. if emp_imp_national==0
replace emp_imp_national=emp_imp_national/1000000

line emp_national emp_imp_national year, name(gr1, replace) ytitle(Million) xtitle("") ///
	 legend(order(1 "National Employment" 2 "Imputed National Empl.")) ///
	 title("Number of Employees")
	 
gr export "NumberofEmployees.png", replace	 
	 
bys year: egen est_national=sum(est)

replace est_national=est_national/1000000

line est_national year, name(gr2, replace) ytitle(Million) xtitle("")	///
	 title("Number of Establishments")
	 
gr export "NumberofEstablishments.png", replace	 	 
	 
bys year: egen imp_rate=mean(any_imp)
	 	 
line imp_rate year, name(gr3, replace) ytitle("Percent") xtitle("") ///
	 title("Counties with Imputed Employment")
	 
gr export "ImputationRate.png", replace	

gen emp_national_2=emp_07+emp_10+emp_15+emp_20+emp_40+emp_50+emp_52+emp_60+emp_70+emp_99
bys year: egen emp_national_2b=sum(emp_national_2)
drop emp_national_2
ren emp_national_2b emp_national_2
replace emp_national_2=emp_national_2/1000000

gen emp_imp_national_2=emp_imp_07+emp_imp_10+emp_imp_15+emp_imp_20+emp_imp_40+emp_imp_50+emp_imp_52+emp_imp_60+emp_imp_70+emp_imp_99
bys year: egen emp_imp_national_2b=sum(emp_imp_national_2)
drop emp_imp_national_2
ren emp_imp_national_2b emp_imp_national_2
replace emp_imp_national_2=emp_imp_national_2/1000000

gen est_national_2=est_07+est_10+est_15+est_20+est_40+est_50+est_52+est_60+est_70+est_99
bys year: egen est_national_2b=sum(est_national_2)
drop est_national_2
ren est_national_2b est_national_2
replace est_national_2=est_national_2/1000000 	 

foreach sic in "07" "10" "15" "20" "40" "50" "52" "60" "70" "99" {
bys year: egen emp_`sic'_national=sum(emp_`sic')
	replace emp_`sic'_national=emp_`sic'_national/1000000
bys year: egen emp_imp_`sic'_national=sum(emp_imp_`sic')
	replace emp_imp_`sic'_national=emp_imp_`sic'_national/1000000
	replace emp_imp_`sic'_national=. if emp_imp_`sic'_national==0
bys year: egen est_`sic'_national=sum(est_`sic')
	replace est_`sic'_national=est_`sic'_national/1000000
	
gen emp_`sic'_share_nat=emp_`sic'_national/emp_national
gen emp_imp_`sic'_share_nat=emp_imp_`sic'_national/emp_imp_national
gen est_`sic'_share_nat=est_`sic'_national/est_national

				}
				
line emp_07_share_nat emp_10_share_nat emp_15_share_nat emp_20_share_nat emp_40_share_nat emp_50_share_nat emp_52_share_nat emp_60_share_nat emp_70_share_nat emp_99_share_nat year, name(gr4, replace) ytitle("Percent") xtitle("") ///
	 title("Employment Share by Industry") ///
	 legend(order(1 "Agriculture" 2 "Mining" 3 "Construction" 4 "Manufacturing" 5 "Transportation & Utilities" 6 "Wholesale Trade" 7 "Retail Trade" 8 "FIRE" 9 "Services" 10 "Nonclassifiable"))
	 
gr export "EmpSharebyIndustry.png", replace	 

drop emp_national emp_imp_national est_national imp_rate emp_*_share_nat emp_*_national est_*_national est_*_share_nat
drop emp_national_2 emp_imp_national_2 est_national_2





save "C:\Users\rhodes.351\Downloads\PCD\Data\cbpco_panel.dta", replace

	
		
		
		
		
