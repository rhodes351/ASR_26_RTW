/*capture log close
version 16.1
clear all
set linesize 80
macro drop _all

local pgm pcd-incentives01-upjohn

local date: display %td_CCYY_NN_DD date(c(current_date), "DMY")
local dte = subinstr(trim("`date'"), " " , "-", .)
local time = c(current_time) 
local time = subinstr("`time'",":","",.)
log using `pgm', replace text
di "`pgm' ran `dte'- `time'"
 
//  task:   examine upjohn incentives , association w rtw
//  note:   results primarily found following neg. residual treatment drop    
//  project: pcd

local who tom_vh
local tag  "`pgm' `who' `dte'"

*/

******************************************************************************
//  load data
******************************************************************************
cd "C:\Users\aprhodes\OneDrive - purdue.edu\Buckeyebox\Policy Corporate Demography\Policy Corporate Demography\Writing\ASR Submit\ASR_26_RTW"
import delimited "Data\export_ind_disagg.csv", case(preserve) clear

******************************************************************************
//  Clean Upjohn data
******************************************************************************

encode Industry, gen(ind)

gen sfips = .
replace sfips = 1 if State == "AL" 
replace sfips = 4  if State == "AZ" 
replace sfips = 6 if State == "CA" 
replace sfips = 8 if State == "CO" 
replace sfips = 9 if State == "CT" 
replace sfips = 11 if State == "DC" 
replace sfips = 12 if State == "FL" 
replace sfips = 13 if State == "GA" 
replace sfips = 19 if State == "IA" 
replace sfips = 17 if State == "IL" 
replace sfips = 18 if State == "IN" 
replace sfips = 21 if State == "KY" 
replace sfips = 22 if State == "LA" 
replace sfips = 25 if State == "MA" 
replace sfips = 24 if State == "MD" 
replace sfips = 26 if State == "MI" 
replace sfips = 27 if State == "MN" 
replace sfips = 29 if State == "MO" 
replace sfips = 37 if State == "NC" 
replace sfips = 31 if State == "NE" 
replace sfips = 34 if State == "NJ" 
replace sfips = 35 if State == "NM" 
replace sfips = 32 if State == "NV" 
replace sfips = 36 if State == "NY" 
replace sfips = 39 if State == "OH" 
replace sfips = 41 if State == "OR" 
replace sfips = 42 if State == "PA" 
replace sfips = 45 if State == "SC" 
replace sfips = 47 if State == "TN" 
replace sfips = 48 if State == "TX" 
replace sfips = 51 if State == "VA" 
replace sfips = 53 if State == "WA" 
replace sfips = 55 if State == "WI" 

gen rtw = 0
label var rtw "Is in RTW state"
replace rtw = 1 if sfips == 	21	& BaseYear >= 	(2017+1)
replace rtw = 1 if sfips == 	54	& BaseYear >= 	(2016+1)
replace rtw = 1 if sfips == 	55	& BaseYear >= 	(2015+1)
replace rtw = 1 if sfips == 	18	& BaseYear >= 	(2012+1)
replace rtw = 1 if sfips == 	26	& BaseYear >= 	(2012+1)
replace rtw = 1 if sfips == 	40	& BaseYear >= 	(2001+1)
replace rtw = 1 if sfips == 	16	& BaseYear >= 	(1985+1)
replace rtw = 1 if sfips == 	22	& BaseYear >= 	(1976+1)
replace rtw = 1 if sfips == 	56	& BaseYear >= 	(1963+1)
replace rtw = 1 if sfips == 	49	& BaseYear >= 	(1955+1)
replace rtw = 1 if sfips == 	28	& BaseYear >= 	(1954+1)
replace rtw = 1 if sfips == 	45	& BaseYear >= 	(1954+1)
replace rtw = 1 if sfips == 	1	  & BaseYear >= 	  (1953+1)
replace rtw = 1 if sfips == 	32	& BaseYear >= 	(1952+1)
replace rtw = 1 if sfips == 	13	& BaseYear >= 	(1947+1)
replace rtw = 1 if sfips == 	19	& BaseYear >= 	(1947+1)
replace rtw = 1 if sfips == 	37	& BaseYear >= 	(1947+1)
replace rtw = 1 if sfips == 	38	& BaseYear >= 	(1947+1)
replace rtw = 1 if sfips == 	47	& BaseYear >= 	(1947+1)
replace rtw = 1 if sfips == 	48	& BaseYear >= 	(1947+1)
replace rtw = 1 if sfips == 	51	& BaseYear >= 	(1947+1)
replace rtw = 1 if sfips == 	4	  & BaseYear >= 	  (1946+1)
replace rtw = 1 if sfips == 	20	& BaseYear >= 	(1946+1)
replace rtw = 1 if sfips == 	31	& BaseYear >= 	(1946+1)
replace rtw = 1 if sfips == 	46	& BaseYear >= 	(1946+1)
replace rtw = 1 if sfips == 	5	  & BaseYear >= 	(1944+1)
replace rtw = 1 if sfips == 	12	& BaseYear >= 	(1943+1)
label define rtw 0 "Not RTW" 1 "Is RTW"
label values rtw rtw

rename sfips statefips
gen year = BaseYear

******************************************************************************
// Make region indicators  
******************************************************************************

* 1 NE
* 2 MW
* 3 S
* 4 W
gen     region = .
replace region = 3  if statefip == 1  // Alabama	"           ///
replace region = 4  if statefip == 2  // Alaska	"           ///
replace region = 4  if statefip == 4  // Arizona	"           ///
replace region = 3  if statefip == 5  // Arkansas	"         ///
replace region = 4  if statefip == 6  // California	"       ///
replace region = 4  if statefip == 8  // Colorado	"         ///
replace region = 1  if statefip == 9  // Connecticut	"       ///
replace region = 3  if statefip == 10 // "Delaware	"         ///
replace region = 3  if statefip == 11 // "DistrictofColumbia" ///
replace region = 3  if statefip == 12 // "Florida	"           ///
replace region = 3  if statefip == 13 // "Georgia	"           ///
replace region = 4  if statefip == 15 // "Hawaii	"           ///
replace region = 4  if statefip == 16 // "Idaho	"             ///
replace region = 2  if statefip == 17 // "Illinois	"         ///
replace region = 2  if statefip == 18 // "Indiana	"           ///
replace region = 2  if statefip == 19 // "Iowa	"             ///
replace region = 2  if statefip == 20 // "Kansas	"           ///
replace region = 3  if statefip == 21 // "Kentucky	"         ///
replace region = 3  if statefip == 22 // "Louisiana	"         ///
replace region = 1  if statefip == 23 // "Maine	"             ///
replace region = 3  if statefip == 24 // "Maryland	"         ///
replace region = 1  if statefip == 25 // "Massachusetts	"     ///
replace region = 2  if statefip == 26 // "Michigan	"         ///
replace region = 2  if statefip == 27 // "Minnesota	"         ///
replace region = 3  if statefip == 28 // "Mississippi	"       ///
replace region = 2  if statefip == 29 // "Missouri	"         ///
replace region = 4  if statefip == 30 // "Montana	"           ///
replace region = 2  if statefip == 31 // "Nebraska	"         ///
replace region = 4  if statefip == 32 // "Nevada	"           ///
replace region = 1  if statefip == 33 // "NewHampshire	"     ///
replace region = 1  if statefip == 34 // "NewJersey	"         ///
replace region = 4  if statefip == 35 // "NewMexico	"         ///
replace region = 1  if statefip == 36 // "NewYork	"           ///
replace region = 3  if statefip == 37 // "NorthCarolina	"     ///
replace region = 2  if statefip == 38 // "NorthDakota	"       ///
replace region = 2  if statefip == 39 // "Ohio	"             ///
replace region = 3  if statefip == 40 // "Oklahoma	"         ///
replace region = 4  if statefip == 41 // "Oregon	"           ///
replace region = 1  if statefip == 42 // "Pennsylvania	"     ///
replace region = 1  if statefip == 44 // "RhodeIsland	"       ///
replace region = 3  if statefip == 45 // "SouthCarolina	"     ///
replace region = 2  if statefip == 46 // "SouthDakota	"       ///
replace region = 3  if statefip == 47 // "Tennessee	"         ///
replace region = 3  if statefip == 48 // "Texas	"             ///
replace region = 4  if statefip == 49 // "Utah	"             ///
replace region = 1  if statefip == 50 // "Vermont	"           ///
replace region = 3  if statefip == 51 // "Virginia	"         ///
replace region = 4  if statefip == 53 // "Washington	"       ///
replace region = 3  if statefip == 54 // "WestVirginia	"     ///
replace region = 2  if statefip == 55 // "Wisconsin	"         ///
replace region = 4  if statefip == 56 // "Wyoming	"         

label define region 1 "Northeast" 2 "Midwest" 3 "South" 4 "West"
label values region region
numlabel region, add mask(#_)

******************************************************************************
//  move in BEA data, make RTW border data
******************************************************************************

merge m:m statefip year using "Data\bea-poptot_emptot.dta", gen(_inbea)
*include rtw-borderinfo.doi

******************************************************************************
// Analysis - Drop residuals
******************************************************************************

** create neg residuals
reg rtw i.statefip i.BaseYear // i.ind 
predict res , res
gen indy = 0
replace indy = 1 if res < 0 & rtw == 1

* regress - net tax
reg NetTax i.year i.ind i.statefip i.rtw if indy == 0
reg NetTax  i.ind i.statefip c.year##i.rtw
margins, at(year=(1990(1)2015) rtw=(0 1))
marginsplot , ///
recastci(rarea) ///
ci1opt(fcolor(black%50) lwidth(*0)) ///
ci2opt(fcolor(red%50) lwidth(*0)) ///
plot1opt(color(black) lwidth(*1.5) ms(none) ) ///
plot2opt(color(red) lwidth(*1.5) ms(none) lpattern(dash)  )  ///
ytitle("Net Rate (Decimal)") ///
xtitle("") ///
title("Net Tax Rates (Upjohn)")  name(g1, replace) legend(off) ///
text(0.0525 2000 "non-RTW" , color(black) place(e)) ///
text(0.0450 1985 "RTW" , color(red) place(e)) ///
xlab(1960(20)2020) ///
xlab(, nogrid) ylab(, nogrid)

* regress - total tax
reg TotalTax i.year i.ind i.statefip i.rtw if indy == 0
reg TotalTax  i.ind i.statefip c.year##i.rtw
margins, at(year=(1990(1)2015) rtw=(0 1))
marginsplot , ///
recastci(rarea) ///
ci1opt(fcolor(black%50) lwidth(*0)) ///
ci2opt(fcolor(red%50) lwidth(*0)) ///
plot1opt(color(black) lwidth(*1.5) ms(none) ) ///
plot2opt(color(red) lwidth(*1.5) ms(none) lpattern(dash)  )   ///
ytitle("Tax Rate (Decimal)") ///
xtitle("") ///
title("Total Tax Rates (Upjohn)")  name(g2, replace) legend(off) ///
text(0.0515 1980 "RTW" , color(red) place(e)) ///
text(0.0615 2000 "non-RTW" , color(black) place(e)) ///
xlab(1960(20)2020) ///
xlab(, nogrid) ylab(, nogrid)

* regress - total incentive
reg TotalIncentive i.year i.ind i.statefip i.rtw if indy == 0
reg TotalIncentive  i.ind i.statefip c.year##i.rtw
margins, at(year=(1990(1)2015) rtw=(0 1))
marginsplot , ///
recastci(rarea) ///
ci1opt(fcolor(black%50) lwidth(*0)) ///
ci2opt(fcolor(red%50) lwidth(*0)) ///
plot1opt(color(black) lwidth(*1.5) ms(none) ) ///
plot2opt(color(red) lwidth(*1.5) ms(none)  lpattern(dash) )   ///
ytitle("Incentive Rate (Decimal)") ///
xtitle("") ///
title("Total Incentive Rates (Upjohn)")  name(g3, replace) legend(off) ///
text(0.0125 1985 "non-RTW" , color(black) place(e)) ///
text(0.005 2005 "RTW" , color(red) place(e)) ///
xlab(1960(20)2020) ///
xlab(, nogrid) ylab(, nogrid)

graph combine g1 g2 g3, row(1) name(combo, replace)
graph display combo, xsize(20) ysize(10) 
graph save "Output\Intermediate\TaxesOverValueAdded_Upjohn_`c(current_date)'.gph", replace 
graph export "Output\Intermediate\TaxesOverValueAdded_Upjohn_`c(current_date)'.png", replace 



******************************************************************************
//  Exit
******************************************************************************
exit


Notes:

