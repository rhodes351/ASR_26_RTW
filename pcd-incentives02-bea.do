/*capture log close
version 16.1
clear all
set linesize 80
macro drop _all

local pgm pcd-incentives02-bea

local date: display %td_CCYY_NN_DD date(c(current_date), "DMY")
local dte = subinstr(trim("`date'"), " " , "-", .)
local time = c(current_time) 
local time = subinstr("`time'",":","",.)
log using `pgm', replace text
di "`pgm' ran `dte'- `time'"
 
//  task:   examine BEA data
//  note:   Are these the right data for our analyses? 
//  project: pcd

local who tom_vh
local tag  "`pgm' `who' `dte'"
*/

******************************************************************************
//  load data
******************************************************************************
cd "C:\Users\aprhodes\OneDrive - purdue.edu\Buckeyebox\Policy Corporate Demography\Policy Corporate Demography\Writing\ASR Submit\ASR_26_RTW"
use "Data\bea_statevars.dta", clear

gen rtw = 0
label var rtw "Is in RTW state"
replace rtw = 1 if fips == 	21	& year >= 	(2017+1)
replace rtw = 1 if fips == 	54	& year >= 	(2016+1)
replace rtw = 1 if fips == 	55	& year >= 	(2015+1)
replace rtw = 1 if fips == 	18	& year >= 	(2012+1)
replace rtw = 1 if fips == 	26	& year >= 	(2012+1)
replace rtw = 1 if fips == 	40	& year >= 	(2001+1)
replace rtw = 1 if fips == 	16	& year >= 	(1985+1)
replace rtw = 1 if fips == 	22	& year >= 	(1976+1)
replace rtw = 1 if fips == 	56	& year >= 	(1963+1)
replace rtw = 1 if fips == 	49	& year >= 	(1955+1)
replace rtw = 1 if fips == 	28	& year >= 	(1954+1)
replace rtw = 1 if fips == 	45	& year >= 	(1954+1)
replace rtw = 1 if fips == 	1	  & year >= 	  (1953+1)
replace rtw = 1 if fips == 	32	& year >= 	(1952+1)
replace rtw = 1 if fips == 	13	& year >= 	(1947+1)
replace rtw = 1 if fips == 	19	& year >= 	(1947+1)
replace rtw = 1 if fips == 	37	& year >= 	(1947+1)
replace rtw = 1 if fips == 	38	& year >= 	(1947+1)
replace rtw = 1 if fips == 	47	& year >= 	(1947+1)
replace rtw = 1 if fips == 	48	& year >= 	(1947+1)
replace rtw = 1 if fips == 	51	& year >= 	(1947+1)
replace rtw = 1 if fips == 	4	  & year >= 	  (1946+1)
replace rtw = 1 if fips == 	20	& year >= 	(1946+1)
replace rtw = 1 if fips == 	31	& year >= 	(1946+1)
replace rtw = 1 if fips == 	46	& year >= 	(1946+1)
replace rtw = 1 if fips == 	5	  & year >= 	(1944+1)
replace rtw = 1 if fips == 	12	& year >= 	(1943+1)
label define rtw 0 "Not RTW" 1 "Is RTW"
label values rtw rtw

local cpi1963	= 246.663	/ 30.6
local cpi1964	= 246.663	/ 31.0
local cpi1965	= 246.663	/ 31.5
local cpi1966	= 246.663	/ 32.4
local cpi1967	= 246.663	/ 33.4
local cpi1968	= 246.663	/ 34.8
local cpi1969	= 246.663	/ 36.7
local cpi1970	= 246.663	/ 38.8
local cpi1971	= 246.663	/ 40.5
local cpi1972	= 246.663	/ 41.8
local cpi1973	= 246.663	/ 44.4
local cpi1974	= 246.663	/ 49.3
local cpi1975	= 246.663	/ 53.8
local cpi1976	= 246.663	/ 56.9
local cpi1977	= 246.663	/ 60.6
local cpi1978	= 246.663	/ 65.2
local cpi1979	= 246.663	/ 72.6
local cpi1980	= 246.663	/ 82.4
local cpi1981	= 246.663	/ 90.9
local cpi1982	= 246.663	/ 96.5
local cpi1983	= 246.663	/ 99.6
local cpi1984	= 246.663	/ 103.9
local cpi1985	= 246.663	/ 107.6
local cpi1986	= 246.663	/ 109.6
local cpi1987	= 246.663	/ 113.6
local cpi1988	= 246.663	/ 118.3
local cpi1989	= 246.663	/ 124.0
local cpi1990	= 246.663	/ 130.7
local cpi1991	= 246.663	/ 136.2
local cpi1992	= 246.663	/ 140.3
local cpi1993	= 246.663	/ 144.5
local cpi1994	= 246.663	/ 148.2
local cpi1995	= 246.663	/ 152.4
local cpi1996	= 246.663	/ 156.9
local cpi1997	= 246.663	/ 160.5
local cpi1998	= 246.663	/ 163.0
local cpi1999	= 246.663	/ 166.6
local cpi2000	= 246.663	/ 172.2
local cpi2001	= 246.663	/ 177.1
local cpi2002	= 246.663	/ 179.9
local cpi2003	= 246.663	/ 184.0
local cpi2004	= 246.663	/ 188.9
local cpi2005	= 246.663	/ 195.3
local cpi2006	= 246.663	/ 201.6
local cpi2007	= 246.663	/ 208.936	 
local cpi2008	= 246.663	/ 216.573	 
local cpi2009	= 246.663	/ 216.177	 
local cpi2010	= 246.663	/ 218.711	 
local cpi2011	= 246.663	/ 226.421	 
local cpi2012	= 246.663	/ 231.317	 
local cpi2013	= 246.663	/ 233.546	 
local cpi2014	= 246.663	/ 237.433	 
local cpi2015	= 246.663	/ 237.838	 
local cpi2016	= 246.663	/ 241.729	 
local cpi2017	= 246.663	/ 246.663	 

gen subcpi = .
gen taxcpi = .
gen gdpcpi = .
gen tx_minus_sub_cpi = .
forvalues y = 1963(1)2017 {
replace subcpi = (sub*-1) * `cpi`y'' if year == `y'
replace taxcpi = tx_pd * `cpi`y'' if year == `y'
replace tx_minus_sub_cpi = tx_minus_sub * `cpi`y'' if year == `y'
replace gdpcpi = GDP* `cpi`y'' if year == `y'
}
          
rename fips statefips
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


gen fipstate=statefip

merge 1:m fipstat year using "Data\pcd-data01-merge_controls2.dta", keepusing(statepop_ipo statepop) gen(_inbea)
drop if _inbea==2

drop if fipstate==. 
duplicates drop fipstate year, force


gen sub_gdp = subcpi / gdpcpi
gen tax_gdp = taxcpi / gdpcpi
gen net_gdp = tx_minus_sub_cpi / gdpcpi

gen sub_pc = subcpi / statepop_ipo
gen tax_pc = taxcpi / statepop_ipo
gen net_pc = tx_minus_sub_cpi / statepop_ipo


reg rtw i.year i.statefip 
predict res , res
gen indy = 0
replace indy = 1 if res < 0 & rtw == 1

gen sub_gdp_pos=sub_gdp*-1

egen year_region=group(year region)



***********************************************************
// Median taxes/subsidies (raw dollars)
***********************************************************

glm subcpi i.statefip c.year##i.rtw, family(gamma) link(log)
margins, at(year=(1964(1)2016) rtw=(0 1))
marginsplot , ///
recastci(rarea) ///
ci1opts(lwidth(*0) fcolor(black%50)) ///
ci2opts(lwidth(*0) fcolor(red%50)) ///
plot1opt(lcolor(black) lwidth(*1.5) ms(none)) ///
plot2opt(lcolor(red) lpattern(dash) lwidth(*1.5) ms(none)) ///
xtitle("") ///
ytitle("Subsidies (in $1,000,000s)") ///
title("Subsidies (BEA)") name(g1, replace) legend(off) ///
text(850 2005 "RTW" , color(red) place(e)) ///
text(1500 1990 "non-RTW" , color(black) place(e)) ///
ylab(, nogrid) xlab(, nogrid)


glm taxcpi i.statefip c.year##i.rtw, family(gamma) link(log)
margins, at(year=(1964(1)2016) rtw=(0 1))
marginsplot , ///
recastci(rarea) ///
ci1opts(lwidth(*0) fcolor(black%50)) ///
ci2opts(lwidth(*0) fcolor(red%50)) ///
plot1opt(lcolor(black) lwidth(*1.5) ms(none)) ///
plot2opt(lcolor(red) lpattern(dash) lwidth(*1.5) ms(none)) ///
xtitle("") ///
ytitle("Taxes (in $1,000,000s)") ///
title("Taxes on Production (BEA)") name(g2, replace) legend(off) ///
text(30000 2000 "RTW" , color(red) place(e)) ///
text(20000 2010 "non-RTW" , color(black) place(e)) ///
ylab(, nogrid) xlab(, nogrid)

glm tx_minus_sub_cpi i.statefip c.year##i.rtw, family(gamma) link(log)
margins, at(year=(1964(1)2016) rtw=(0 1))
marginsplot , ///
recastci(rarea) ///
ci1opts(lwidth(*0) fcolor(black%50)) ///
ci2opts(lwidth(*0) fcolor(red%50)) ///
plot1opt(lcolor(black) lwidth(*1.5) ms(none)) ///
plot2opt(lcolor(red) lpattern(dash) lwidth(*1.5) ms(none)) ///
xtitle("") ///
ytitle("Net Taxes (in $1,000,000s)") ///
title("Net Taxes (BEA)") name(g3, replace) legend(off) ///
text(25000 1992 "RTW" , color(red) place(e)) ///
text(17500 2005 "non-RTW" , color(black) place(e)) ///
ylab(, nogrid) xlab(, nogrid)

graph combine g3 g2 g1, row(1) name(combo, replace)
graph display combo, xsize(20) ysize(10) 
graph save "Output\Intermediate\MedianTaxes_BEA_`c(current_date)'.gph", replace 



***********************************************************
// Tax/subsidies as a proportion of GDP
***********************************************************

reg sub_gdp i.statefip c.year##i.rtw
margins, at(year=(1964(1)2016) rtw=(0 1))
marginsplot , ///
recastci(rarea) ///
ci1opts(lwidth(*0) fcolor(black%50)) ///
ci2opts(lwidth(*0) fcolor(red%50)) ///
plot1opt(lcolor(black) lwidth(*1.5) ms(none)) ///
plot2opt(lcolor(red) lpattern(dash) lwidth(*1.5) ms(none)) ///
xtitle("") ///
ytitle("Subsidies Over GDP (Decimal)") ///
title("Subsidies (BEA)") ///
legend(order(3 "Non-RTW" 4 "RTW") ) legend(off) name(g1, replace) ///
text(0.0035 1990 "RTW" , color(red) place(e)) ///
text(0.0059 2010 "non-RTW" , color(black) place(e)) ///
ylab(, nogrid) xlab(, nogrid)

reg tax_gdp i.statefip c.year##i.rtw
margins, at(year=(1964(1)2016) rtw=(0 1))
marginsplot , ///
recastci(rarea) ///
ci1opts(lwidth(*0) fcolor(black%50)) ///
ci2opts(lwidth(*0) fcolor(red%50)) ///
plot1opt(lcolor(black) lwidth(*1.5) ms(none)) ///
plot2opt(lcolor(red) lpattern(dash) lwidth(*1.5) ms(none)) ///
xtitle("") ///
ytitle("Taxes Over GDP (Decimal)") ///
title("Taxes on Production (BEA)") legend(off) name(g2, replace) ///
text(0.080 2013 "RTW" , color(red) place(e)) ///
text(0.073 1962 "non-RTW" , color(black) place(e)) ///
ylab(, nogrid) xlab(, nogrid)

reg net_gdp i.statefip c.year##i.rtw
margins, at(year=(1964(1)2016) rtw=(0 1))
marginsplot , ///
recastci(rarea) ///
ci1opts(lwidth(*0) fcolor(black%50)) ///
ci2opts(lwidth(*0) fcolor(red%50)) ///
plot1opt(lcolor(black) lwidth(*1.5) ms(none)) ///
plot2opt(lcolor(red) lpattern(dash) lwidth(*1.5) ms(none)) ///
xtitle("") ///
ytitle("Net Taxes Over GDP (Decimal)") ///
title("Net Taxes (BEA)") legend(off) name(g3, replace) ///
text(0.0780 2002 "RTW" , color(red) place(e)) ///
text(0.0675 1962 "non-RTW" , color(black) place(e)) ///
ylab(, nogrid) xlab(, nogrid)

graph combine g3 g2 g1, row(1) name(combo, replace)
graph display combo, xsize(20) ysize(10) 
graph save "Output\Intermediate\TaxesOverGDP_BEA_`c(current_date)'.gph", replace 




* Combine all the measures together with the upjohn rates
graph combine "Output\Intermediate\MedianTaxes_BEA_`c(current_date)'.gph" "Output\Intermediate\TaxesOverGDP_BEA_`c(current_date)'.gph" "Output\Intermediate\TaxesOverValueAdded_Upjohn_`c(current_date)'.gph", cols(1) imargin(0)

graph save "Output\Figure_5_`c(current_date)'.gph", replace  
graph export "Output\Figure_5_`c(current_date)'.png", replace 
graph export "Output\Figure_5_`c(current_date)'.svg", replace 
graph export "Output\Figure_5_`c(current_date)'.pdf", replace 


******************************************************************************
//  Exit
******************************************************************************
exit



