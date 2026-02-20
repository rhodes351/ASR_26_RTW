////////////////////////////////////////////////////////////////////////////////////////////
////// This file contains replication code for Right to Work and Economic Dynamism in U.S. Counties, 1946-2019
////// Author: Alec Rhodes (aprhodes@purdue.edu)
////// Date: 12/16/2025
//////


* set directory
cd "C:\Users\aprhodes\OneDrive - purdue.edu\Buckeyebox\Policy Corporate Demography\Policy Corporate Demography\Writing\ASR Submit\ASR_26_RTW\"

* set graph scheme
set scheme plotplainblind


* Load CBP data
use "Data\cbpco_panel.dta", clear

* Create a five digit county-state identifier called "countyreal" to merge with list of border counties
gen countyreal=fipstate*1000
replace countyreal=countyreal+fipscty

merge m:1 countyreal using "Data\countylistdube.dta"
gen bordercounty=1 if _merge==3
replace bordercounty=0 if _merge==1
drop _merge


* merge in the state-level control variables
merge 1:1 fipstat fipscty year using "Data\pcd-data01-merge_controls2.dta", keepusing(rtw statepop_ipo uin unionflag stateunion policy_updated_social policy_updated_economic policy_updated) gen(_merge2)
drop if _merge2==2
drop _merge2

* replace missing on GA, MO in 1974 for whatever reason...
replace rtw=1 if fipstate==13 & year==1974
replace rtw=0 if fipstate==29 & year==1974


gen fips=fipstate


* merge in county-level population counts
merge 1:1 countyreal year using "Data\CountyPopulationDecennialEstimates.dta", keepusing(deccountypop deccountypop_ipo)
drop if _merge==2
drop _merge


gen state="AL" if fipstate==1
	replace state="AK" if fipstate==2
	replace state="AZ" if fipstate==4
	replace state="AR" if fipstate==5
	replace state="CA" if fipstate==6
	replace state="CO" if fipstate==8
	replace state="CT" if fipstate==9
	replace state="DE" if fipstate==10
	replace state="DC" if fipstate==11
	replace state="FL" if fipstate==12
	replace state="GA" if fipstate==13
	replace state="HI" if fipstate==15
	replace state="ID" if fipstate==16
	replace state="IL" if fipstate==17
	replace state="IN" if fipstate==18
	replace state="IA" if fipstate==19
	replace state="KS" if fipstate==20
	replace state="KY" if fipstate==21
	replace state="LA" if fipstate==22
	replace state="ME" if fipstate==23
	replace state="MD" if fipstate==24
	replace state="MA" if fipstate==25
	replace state="MI" if fipstate==26
	replace state="MN" if fipstate==27
	replace state="MS" if fipstate==28
	replace state="MO" if fipstate==29
	replace state="MT" if fipstate==30
	replace state="NE" if fipstate==31
	replace state="NV" if fipstate==32
	replace state="NH" if fipstate==33
	replace state="NJ" if fipstate==34
	replace state="NM" if fipstate==35
	replace state="NY" if fipstate==36
	replace state="NC" if fipstate==37
	replace state="ND" if fipstate==38
	replace state="OH" if fipstate==39
	replace state="OK" if fipstate==40
	replace state="OR" if fipstate==41
	replace state="PA" if fipstate==42
	replace state="RI" if fipstate==44
	replace state="SC" if fipstate==45
	replace state="SD" if fipstate==46
	replace state="TN" if fipstate==47
	replace state="TX" if fipstate==48
	replace state="UT" if fipstate==49
	replace state="VT" if fipstate==50
	replace state="VA" if fipstate==51
	replace state="WA" if fipstate==53
	replace state="WV" if fipstate==54
	replace state="WI" if fipstate==55
	replace state="WY" if fipstate==56
	
	
* Identify Census divison	
gen division=1 if state=="ME" | state=="VT" | state=="NH" | state=="MA" | state=="CT" | state=="RI"
	replace division=2 if state=="NY" | state=="PA" | state=="NJ" 
	replace division=3 if state=="DE" | state=="MD" | state=="WV" | state=="VA" | state=="NC" | state=="SC" | state=="GA" | state=="FL" | state=="DC"
	replace division=4 if state=="OH" | state=="MI" | state=="IN" | state=="IL" | state=="WI" | state=="IL"
	replace division=5 if state=="MN" | state=="IA" | state=="MO" | state=="ND" | state=="SD" | state=="NE" | state=="KS"
	replace division=6 if state=="KY" | state=="TN" | state=="MS" | state=="AL"
	replace division=7 if state=="AR" | state=="LA" | state=="OK" | state=="TX"
	replace division=8 if state=="MT" | state=="ID" | state=="WY" | state=="NV" | state=="UT" | state=="CO" | state=="AZ" | state=="NM"
	replace division=9 if state=="WA" | state=="CA" | state=="OR" | state=="HI" | state=="AK"
	
la def divlab 1"New England"2"Middle Atlantic"3"South Atlantic"4"East North Central"5"West North Central"6"East South Central"7"West South Central"8"Mountain"9"Pacific"
la val division divlab
la var division "Census Division"	
	


* Merge in identifier for RTW border county status
gen opposing_cnty=substr(countypair_id,9,3)
destring opposing_cnty, replace
gen opposing_state=substr(countypair_id,7,2)
destring opposing_state, replace

gen opposing_cnty2=substr(countypair_id,3,3) if opposing_cnty==fipscty
destring opposing_cnty2, replace
gen opposing_state2=substr(countypair_id,1,2) if opposing_state==fipstate
destring opposing_state2, replace

replace opposing_cnty=opposing_cnty2 if opposing_cnty==fipscty
replace opposing_state=opposing_state2 if opposing_state==fipstate

drop opposing_state2 opposing_cnty2


preserve

keep year opposing_cnty opposing_state fipstate fipscty
keep if opposing_cnty!=.

ren fipstate fipstate2 
ren fipscty fipscty2

gen fipstate=opposing_state
gen fipscty=opposing_cnty

merge m:1 fipstate fipscty year using "Data\pcd-data01-merge_controls2.dta", keepusing(rtw)
drop if _merge==2 | _merge==1
drop _merge

replace fipstate=fipstate2
replace fipscty=fipscty2

drop fipscty2 fipstate2

gen rtwborder=rtw

save "Data\rtw_border_county_id.dta", replace

restore

merge 1:m fipscty fipstat year using "Data\rtw_border_county_id.dta", keepusing(rtwborder)


* Gen an ever RTW flag
bys state: egen ever_rtw=max(rtw)


* code year rtw passed
* dates from TVH
gen year_rtw=1944 if fipstate==5
	replace year_rtw=1943 if fipstate==12
	replace year_rtw=1953 if fipstate==1
	replace year_rtw=1946 if fipstate==4
	replace year_rtw=1947 if fipstate==13
	replace year_rtw=1985 if fipstate==16
	replace year_rtw=2012 if fipstate==18 // IN had a RTW in 57 but repealed in 65 so will treat RTW year as 2012
	replace year_rtw=1947 if fipstate==19
	replace year_rtw=1946 if fipstate==20
	replace year_rtw=2017 if fipstate==21
	replace year_rtw=1976 if fipstate==22
	replace year_rtw=2012 if fipstate==26
	replace year_rtw=1954 if fipstate==28
	replace year_rtw=1946 if fipstate==31
	replace year_rtw=1952 if fipstate==32
	replace year_rtw=1947 if fipstate==37
	replace year_rtw=1948 if fipstate==38
	replace year_rtw=2001 if fipstate==40
	replace year_rtw=1954 if fipstate==45
	replace year_rtw=1946 if fipstate==46
	replace year_rtw=1947 if fipstate==47
	replace year_rtw=1947 if fipstate==48
	replace year_rtw=1955 if fipstate==49
	replace year_rtw=1947 if fipstate==51
	replace year_rtw=2016 if fipstate==54
	replace year_rtw=2015 if fipstate==55
	replace year_rtw=1963 if fipstate==56
	
	
gen earlyrtw=1 if year_rtw<1976
		replace earlyrtw=0 if year_rtw>=1976 & year_rtw!=.

* Create a measure that excludes states with odd RTW timing (LA in 76, ID in 85, OK in 00)		
gen ever_rtw2=0 if ever_rtw==0 // never RTW states
	replace ever_rtw2=1 if earlyrtw==1 // Early RTW states
	replace ever_rtw2=2 if year_rtw>=2010 & year_rtw!=. // Post-2010s RTW states
	
	
gen yearsincertw=year-year_rtw

gen event_rtw=0 if yearsincertw<=-30 & yearsincertw!=.
		replace event_rtw=1 if yearsincertw==-29
		replace event_rtw=2 if yearsincertw==-28
		replace event_rtw=3 if yearsincertw==-27
		replace event_rtw=4 if yearsincertw==-26
		replace event_rtw=5 if yearsincertw==-25
		replace event_rtw=6 if yearsincertw==-24
		replace event_rtw=7 if yearsincertw==-23
		replace event_rtw=8 if yearsincertw==-22
		replace event_rtw=9 if yearsincertw==-21
		replace event_rtw=10 if yearsincertw==-20
		replace event_rtw=11 if yearsincertw==-19
		replace event_rtw=12 if yearsincertw==-18
		replace event_rtw=13 if yearsincertw==-17
		replace event_rtw=14 if yearsincertw==-16
		replace event_rtw=15 if yearsincertw==-15
		replace event_rtw=16 if yearsincertw==-14
		replace event_rtw=17 if yearsincertw==-13
		replace event_rtw=18 if yearsincertw==-12
		replace event_rtw=19 if yearsincertw==-11
		replace event_rtw=20 if yearsincertw==-10
		replace event_rtw=21 if yearsincertw==-9
		replace event_rtw=22 if yearsincertw==-8
		replace event_rtw=23 if yearsincertw==-7
		replace event_rtw=24 if yearsincertw==-6
		replace event_rtw=25 if yearsincertw==-5
		replace event_rtw=26 if yearsincertw==-4
		replace event_rtw=27 if yearsincertw==-3
		replace event_rtw=28 if yearsincertw==-2
		replace event_rtw=29 if yearsincertw==-1
		replace event_rtw=30 if yearsincertw==0
		replace event_rtw=31 if yearsincertw==1
		replace event_rtw=32 if yearsincertw==2
		replace event_rtw=33 if yearsincertw==3
		replace event_rtw=34 if yearsincertw==4
		replace event_rtw=35 if yearsincertw==5
		replace event_rtw=36 if yearsincertw==6
		replace event_rtw=37 if yearsincertw==7
		replace event_rtw=38 if yearsincertw==8
		replace event_rtw=39 if yearsincertw==9
		replace event_rtw=40 if yearsincertw==10
		replace event_rtw=41 if yearsincertw==11
		replace event_rtw=42 if yearsincertw==12
		replace event_rtw=43 if yearsincertw==13
		replace event_rtw=44 if yearsincertw==14
		replace event_rtw=45 if yearsincertw==15
		replace event_rtw=46 if yearsincertw==16
		replace event_rtw=47 if yearsincertw==17
		replace event_rtw=48 if yearsincertw==18
		replace event_rtw=49 if yearsincertw==19
		replace event_rtw=50 if yearsincertw==20
		replace event_rtw=51 if yearsincertw==21
		replace event_rtw=52 if yearsincertw==22
		replace event_rtw=53 if yearsincertw==23
		replace event_rtw=54 if yearsincertw==24
		replace event_rtw=55 if yearsincertw==25
		replace event_rtw=56 if yearsincertw==26
		replace event_rtw=57 if yearsincertw==27
		replace event_rtw=58 if yearsincertw==28
		replace event_rtw=59 if yearsincertw==29
		replace event_rtw=60 if yearsincertw==30 
		replace event_rtw=61 if yearsincertw==31
		replace event_rtw=62 if yearsincertw==32
		replace event_rtw=63 if yearsincertw==33
		replace event_rtw=64 if yearsincertw==34
		replace event_rtw=65 if yearsincertw==35
		replace event_rtw=66 if yearsincertw==36
		replace event_rtw=67 if yearsincertw==37
		replace event_rtw=68 if yearsincertw==38
		replace event_rtw=69 if yearsincertw==39
		replace event_rtw=70 if yearsincertw==40
		replace event_rtw=71 if yearsincertw==41
		replace event_rtw=72 if yearsincertw==42
		replace event_rtw=73 if yearsincertw==43
		replace event_rtw=74 if yearsincertw==44
		replace event_rtw=75 if yearsincertw==45
		replace event_rtw=76 if yearsincertw==46
		replace event_rtw=77 if yearsincertw==47
		replace event_rtw=78 if yearsincertw==48
		replace event_rtw=79 if yearsincertw==49
		replace event_rtw=80 if yearsincertw>=50 & yearsincertw!=.
		
		replace event_rtw=29 if ever_rtw==0 
		
		
gen event_rtwb=0 if yearsincertw<=-10 & yearsincertw!=.
		replace event_rtwb=1 if yearsincertw==-9
		replace event_rtwb=2 if yearsincertw==-8
		replace event_rtwb=3 if yearsincertw==-7
		replace event_rtwb=4 if yearsincertw==-6
		replace event_rtwb=5 if yearsincertw==-5
		replace event_rtwb=6 if yearsincertw==-4
		replace event_rtwb=7 if yearsincertw==-3
		replace event_rtwb=8 if yearsincertw==-2
		replace event_rtwb=9 if yearsincertw==-1
		replace event_rtwb=10 if yearsincertw==0
		replace event_rtwb=11 if yearsincertw==1
		replace event_rtwb=12 if yearsincertw==2
		replace event_rtwb=13 if yearsincertw==3
		replace event_rtwb=14 if yearsincertw==4
		replace event_rtwb=15 if yearsincertw==5
		replace event_rtwb=16 if yearsincertw==6
		replace event_rtwb=17 if yearsincertw==7
		replace event_rtwb=18 if yearsincertw==8
		replace event_rtwb=19 if yearsincertw==9
		replace event_rtwb=20 if yearsincertw>=10 & yearsincertw!=.
		
		replace event_rtwb=9 if ever_rtw==0 	
		
		
gen event_rtwc=0 if yearsincertw<-35 & yearsincertw!=.
			replace event_rtwc=1 if yearsincertw>=-35 & yearsincertw<-30
			replace event_rtwc=2 if yearsincertw>=-30 & yearsincertw<-25
			replace event_rtwc=3 if yearsincertw>=-25 & yearsincertw<-20
			replace event_rtwc=4 if yearsincertw>=-20 & yearsincertw<-15
			replace event_rtwc=5 if yearsincertw>=-15 & yearsincertw<-10
			replace event_rtwc=6 if yearsincertw>=-10 & yearsincertw<-5
			replace event_rtwc=7 if yearsincertw>=-5 & yearsincertw<0
			replace event_rtwc=8 if yearsincertw>=0 & yearsincertw<5
			replace event_rtwc=9 if yearsincertw>=5 & yearsincertw<10
			replace event_rtwc=10 if yearsincertw>=10 & yearsincertw<15
			replace event_rtwc=11 if yearsincertw>=15 & yearsincertw<20
			replace event_rtwc=12 if yearsincertw>=20 & yearsincertw<25
			replace event_rtwc=13 if yearsincertw>=25 & yearsincertw<30
			replace event_rtwc=14 if yearsincertw>=30 & yearsincertw<35
			replace event_rtwc=15 if yearsincertw>=35 & yearsincertw<40
			replace event_rtwc=16 if yearsincertw>=40 & yearsincertw<45
			replace event_rtwc=17 if yearsincertw>=45 & yearsincertw<50
			replace event_rtwc=18 if yearsincertw>=50 & yearsincertw!=.
			
			replace event_rtwc=6 if ever_rtw==0
		

* Trimmed twfe model (Jakiela)
reg rtw i.year i.fipstate if emp!=.

// Collect residuals for state
predict weights, resid

sum weights if e(sample)==1, d

sum weights if e(sample)==1 & rtw==1, d
sum weights if e(sample)==1 & rtw==0, d

gen negtreatmentwts=0 if rtw==0 | (rtw==1 & weights>=0)
	replace negtreatmentwts=1 if rtw==1 & weights<0
	
	
* Trimmed TWFE model for rtwborder counties 
reg rtwborder i.year i.fipstate if emp!=.

predict weights2, resid

gen negtreatmentwts2=0 if rtwborder==0 | (rtwborder==1 & weights2>=0)
		replace negtreatmentwts2=1 if rtwborder==1 & weights2<0
	
	
gen emp_per_est=emp/est	


	
*********************************************************************************************************************************************	
* DiD estimates

drop if cntyid==. 
drop if cntyid==999 // drop employment/establishments observations that can't be geolocated within a given county 
duplicates tag cntyid year, gen(duplicatecountyyears)
duplicates drop cntyid year, force

xtset cntyid year

gen ln_emp=ln(emp)

gen ln_est=ln(est)	

gen empb=emp_imp
replace empb=emp if emp_imp==.

gen emp_20b=emp_imp_20
replace emp_20b=emp_20 if emp_imp_20==.

gen emp_70b=emp_imp_70
replace emp_70b=emp_70 if emp_imp_70==.

gen ln_empb=ln(empb)

gen ln_emp_20b=ln(1+emp_20b)

gen ln_emp_70b=ln(1+emp_70b)

gen ln_est_20=ln(1+est_20)

gen ln_est_70=ln(1+est_70)

gen ln_small_est=ln(1+estsize_1_49)		

gen ln_medium_est=ln(1+estsize_50_99+estsize_100_499)

gen ln_large_est=ln(1+estsize_500)


* ID samples
reg empb rtw i.year i.fipstate /*$demos $att $policy $econ*/ if empb>0 & est>0, vce(cluster cntyid)
gen sample1=1 if e(sample)==1

reg est rtw i.year i.fipstate /*$demos $att $policy $econ*/ if empb>0 & est>0, vce(cluster cntyid)
gen sample2=1 if e(sample)==1


sort countyreal 


// create a measure of non-border county in state neighboring new RTW state
bys fipstate year: egen anyrtwborder=max(rtwborder)
gen rtwnonborder=1 if rtwborder==1 & rtwborder!=1

gen rtwbordernonrtw=1 if rtwborder==0 & rtw==1
gen nonrtwborderrtw=1 if rtw==0 & rtwborder==1

gen ln_deccountypop_ipo=ln(deccountypop_ipo)

// Keep a balanced panel of counties
bys countyreal: egen numobs=count(countyreal)
tab numobs
*keep if numobs==63 

gen ln_emp_20=ln(1+emp_20)

gen ln_est_20c=ln(est_20)

gen ln_emp_20c=ln(emp_20)

gen ln_emp_70=ln(1+emp_70)

gen ln_est_70c=ln(est_70)

gen ln_emp_70c=ln(emp_70)

gen ln_small_estc=ln(estsize_1_49)

gen ln_medium_estc=ln(estsize_50_99+estsize_100_499)

gen ln_large_estc=ln(estsize_500)

sort cntyid year
by cntyid: gen emp_lag1=empb[_n-1]
gen ch_emp=empb-emp_lag1
replace ch_emp=ch_emp/emp_lag1

by cntyid: gen emp_20_lag1=emp_20b[_n-1]
gen ch_emp_20=emp_20b-emp_20_lag1
replace ch_emp_20=ch_emp_20/emp_20_lag1

gen small_est=estsize_1_49

gen medium_est=estsize_50_99+estsize_100_499

gen large_est=estsize_500


* Alternative specification of employment/establishments per population
gen emptopop=empb/(deccountypop_ipo/10000)

gen ln_emptopop=ln(emptopop)

gen esttopop=est/(deccountypop_ipo/10000)

gen ln_esttopop=ln(esttopop)

gen emp20topop=(emp_20b)/(deccountypop_ipo/10000)

gen ln_emp20topop=ln(1+emp20topop)

gen est20topop=(est_20)/(deccountypop_ipo/10000)

gen ln_est20topop=ln(1+est20topop)

gen emp70topop=(emp_70b)/(deccountypop_ipo/10000)

gen ln_emp70topop=ln(1+emp70topop)

gen est70topop=(est_70)/(deccountypop_ipo/10000)

gen ln_est70topop=ln(1+est70topop)

gen small_esttopop=(estsize_1_49)/(deccountypop_ipo/10000)

gen ln_small_esttopop=ln(small_esttopop)

gen medium_esttopop=(estsize_50_99+estsize_100_499)/(deccountypop_ipo/10000)

gen ln_medium_esttopop=ln(1+medium_esttopop)

gen large_esttopop=(estsize_500)/(deccountypop_ipo/10000)

gen ln_large_esttopop=ln(1+large_esttopop)

replace ap=ap*-1 if ap<0 // some payroll obs. are negative!? Can't be right...

gen ap2=ap/1000

gen ln_ap2=ln(1+ap2)

gen imputed_emp_obs=1 if empb!=emp & empb!=.
	replace imputed_emp_obs=0 if empb==emp & empb!=.
	
gen imputed_emp_20_obs=1 if emp_20b!=emp_20 & emp_20b!=.
	replace imputed_emp_20_obs=0 if emp_20b==emp_20 & emp_20b!=.
	
gen imputed_emp_70_obs=1 if emp_70b!=emp_70 & emp_70b!=.
	replace imputed_emp_70_obs=0 if emp_70b==emp_70 & emp_70b!=.
	

* A little example for the text: 
gen empb_1946=empb if year==1946
gen empb_2019=empb if year==2019

bys cntyid: egen empb_1946b=max(empb_1946)
bys cntyid: egen empb_2019b=max(empb_2019)

drop empb_1946 empb_2019
ren empb_1946b empb_1946
ren empb_2019b empb_2019	

gen diff_empb_2019_1946=empb_2019-empb_1946

gen pct_diff_empb_2019_1946=diff_empb_2019_1946/empb_1946


* Replicate outcomes used in prior studies such as the share of employment in manufacturing
gen manuf_emp_share=emp_20b/empb

gen ln_manuf_emp_share=ln(1+(manuf_emp_share)*100)

gen manuf_est_share=est_20/est

replace manuf_est_share=1 if manuf_est_share>1 & manuf_est_share!=.

gen ln_manuf_est_share=ln(1+(manuf_est_share)*100)

gen serv_emp_share=emp_70b/empb

gen ln_serv_emp_share=ln(1+(serv_emp_share)*100)

gen serv_est_share=est_70/est

replace serv_est_share=1 if serv_est_share>1 & serv_est_share!=.

gen ln_serv_est_share=ln(1+(serv_est_share)*100)


*********************************************************************
// merge in bea tax data from Slattery (2019)
*********************************************************************
merge m:1 fips year using "Data\bea_statevars.dta", gen(_beamerge)
drop if _beamerge==2

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
replace gdpcpi = GDP* `cpi`y'' if year == `y'
replace tx_minus_sub_cpi = tx_minus_sub* `cpi`y'' if year== `y'
}

gen statefips=fips

merge m:1 statefips year using "Data\bea-poptot_emptot.dta", gen(_inbea)
drop if _inbea==2

gen sub_gdp = (subcpi / gdpcpi)*100
gen tax_gdp = (taxcpi / gdpcpi)*100
gen net_gdp = (tx_minus_sub_cpi / gdpcpi)*100

gen sub_pc = (subcpi / statepop_ipo)*100
gen tax_pc = (taxcpi / statepop_ipo)*100
gen net_pc = (tx_minus_sub_cpi / statepop_ipo)*100

gen ln_tx_minus_sub_cpi=ln(tx_minus_sub_cpi)
gen ln_taxcpi=ln(taxcpi)
gen ln_subcpi=ln(subcpi)



* merge in tax data from upjohn (collapsed to state level)
preserve

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

rename sfips statefips
gen year = BaseYear

gen ind_type="manuf" if Industry=="Apparel, Leather and allied product Manufacturing" | ///
	                    Industry=="Chemical Manufacturing" | ///
						Industry=="Computer and electronic product manufacturing" | ///
						Industry=="Electrical equipment, appliance, and component manufacturing" | ///
						Industry=="Fabricated Metal Product Manufacturing" | ///
						Industry=="Food, beverage, and tobacco Manufacturing" | ///
						Industry=="Machinery manufacturing" | ///
						Industry=="Other Transportation Equipment" | ///
						Industry=="Paper Manufacturing" | ///
						Industry=="Petroleum and coal products manufacturing" | ///
						Industry=="Plastics and Rubber products manufacturing" | ///
						Industry=="Primary Metal Manufacturing" | ///
						Industry=="Textile Mills and textile product mills" | ///
						Industry=="Wood Product Manufacturing" | ///
						Industry=="Furniture and related product manufacturing" | ///
						Industry=="Miscellaneous manufacturing"
						
replace ind_type="serv" if Industry=="Accommodation" | ///
							Industry=="Administrative and support services" | ///
							Industry=="Amusement, gambling, and recreation industries" | ///
							Industry=="Computer systems design and related services" | ///
							Industry=="Educational Services" | ///
							Industry=="Food services and drinking places" | ///
							Industry=="Hospitals, nursing, and residential care facilities" | ///
							Industry=="Information and data processing services" | ///
							Industry=="Legal Services" | ///
							Industry=="Offices of health practioners and outpatient care centers" | ///
							ind==28 | ///
							Industry=="Performing arts, spectator sports, museums and entertainment"
							

* Overall taxes/incentives across industries
gen NetTax2=NetTax*IndustryValueAdded
gen TotalTax2=TotalTax*IndustryValueAdded
gen TotalIncentive2=TotalIncentive*IndustryValueAdded					
						
* Taxes/incentives for manufacturing alone
gen NetTax2_manuf=NetTax2 if ind_type=="manuf"
gen TotalTax2_manuf=TotalTax2 if ind_type=="manuf"
gen TotalIncentive2_manuf=TotalIncentive2 if ind_type=="manuf"		

* Taxes/incentives for services alone
gen NetTax2_serv=NetTax2 if ind_type=="serv"
gen TotalTax2_serv=TotalTax2 if ind_type=="serv"
gen TotalIncentive2_serv=TotalIncentive2 if ind_type=="serv"								
	
gen IndustryValueAdded_manuf=IndustryValueAdded if ind_type=="manuf"

gen IndustryValueAdded_serv=IndustryValueAdded if ind_type=="serv"	

collapse (sum) NetTax2* TotalTax2* TotalIncentive2* IndustryValueAdded*, by(statefips year)

replace NetTax2=(NetTax2/IndustryValueAdded)*100
replace TotalTax2=(TotalTax2/IndustryValueAdded)*100
replace TotalIncentive2=(TotalIncentive2/IndustryValueAdded)*100

replace NetTax2_manuf=(NetTax2_manuf/IndustryValueAdded_manuf)*100
replace TotalTax2_manuf=(TotalTax2_manuf/IndustryValueAdded_manuf)*100
replace TotalIncentive2_manuf=(TotalIncentive2_manuf/IndustryValueAdded_manuf)*100

replace NetTax2_serv=(NetTax2_serv/IndustryValueAdded_serv)*100
replace TotalTax2_serv=(TotalTax2_serv/IndustryValueAdded_serv)*100
replace TotalIncentive2_serv=(TotalIncentive2_serv/IndustryValueAdded_serv)*100


ren NetTax2 nettax
ren TotalTax2 totaltax
ren TotalIncentive2 totalincentive

ren NetTax2_manuf nettax_manuf
ren TotalTax2_manuf totaltax_manuf
ren TotalIncentive2_manuf totalincentive_manuf

ren NetTax2_serv nettax_serv
ren TotalTax2_serv totaltax_serv
ren TotalIncentive2_serv totalincentive_serv


tempfile upjohn
save `upjohn', replace

restore

merge m:1 statefips year using `upjohn', gen(_upjohn)
drop if _upjohn==2


******************************************************************
* AR Edit (03/18/2025) -- merge in Census Business Dynamism data
* Note: This is available at the county-level for 1977-2022
*       The dynamism measures are similar to those mentioned in "Case for Econ Dynamism" report.
*       https://eig.org/case-for-dynamism/#:~:text=In%20short%2C%20dynamism%20helps%20ensure,American%20workers%20and%20their%20families.

* merge in county-level data
merge 1:1 fipstate fipscty year using "Data\bds_cty_data.dta", gen(_merge5) ///
		  keepusing(estabs_entry estabs_entry_rate estabs_exit estabs_exit_rate reallocation_rate estabs_startups emp_startups peremp_startups perestabs_startups)
drop if _merge5==2
drop _merge5

foreach var in estabs_entry estabs_entry_rate estabs_exit estabs_exit_rate reallocation_rate estabs_startups emp_startups peremp_startups perestabs_startups {
	
gen ln_`var'=ln(1+`var')	
	
	}


stop


	
	
******************************************************** Main Text *******************************************************************************************************	


************************************************************************************************************************
* ID full county sample

* Trimmed twfe model (Jakiela)
reg rtw i.year i.cntyid if empb!=. & ln_deccountypop_ipo!=.

// Collect residuals for state
predict weightsa, resid

gen negtreatmentwtsa=0 if rtw==0 | (rtw==1 & weightsa>=0)
	replace negtreatmentwtsa=1 if rtw==1 & weightsa<0
		
* create indicator for division X year FEs		
egen divyear=group(division year)


save "Data\working_all_county_panel.dta", replace



*********************************************************************************************************************************
* ID County border pair sample

egen cbp_period=group(countypair_id year)

// joinby with Dube et al.'s list of contiguous U.S. counties
joinby countyreal using "Data\county_border_ids.dta"	

egen state_bordersegment=group(fipstate bordersegment)

rifhdreg empb rtw if empb>0 & est>0, rif(mean) abs(cntyid cbp_period) vce(cluster cntyid)

gen sample3=1 if e(sample)==1

rifhdreg est rtw if empb>0 & est>0, rif(mean) abs(cntyid cbp_period) vce(cluster cntyid)

gen sample4=1 if e(sample)==1


rifhdreg empb rtw if cbp_period!=. & empb>0 & est>0, rif(mean) abs(cntyid) vce(cluster cntyid) 

gen sample8=1 if e(sample)==1


/////////////////////////////////////////////////////////////////////////////////////////
//// Mapping counties in the sample (Figure 1)

* Grab sample for mapping with unique number of county-border pairs analyzed (all counties)
preserve

collapse (count) cntyid if sample3==1, by(countyreal)

gen GEOID=string(countyreal,"%05.0f")


save "Data\county_border_sample_countyidcountobs_bycounty_all.dta", replace

restore

* Grab sample for mapping with unique number of county-border pairs analyzed (counties w/ a rtw difference)
preserve

collapse (count) cntyid if (rtwbordernonrtw==1 | nonrtwborderrtw==1) & sample8==1, by(countyreal)

gen GEOID=string(countyreal,"%05.0f")


save "Data\county_border_sample_countyidcountobs_bycounty_rtwdiff.dta", replace

restore


preserve

// this is a map of all counties on borders that have a RTW border
use "Data\usbdcounties.dta", clear
merge 1:1 GEOID using "Data\county_border_sample_countyidcountobs_bycounty_rtwdiff.dta", gen(_merge2)  
drop _merge2
  
save  "Data\usbdcounties_2_`c(current_date)'.dta", replace
  
  
* And we're mapping
use "Data\usbdcounties_2_`c(current_date)'.dta", clear

ren _ID id

// drop territories --- PR, Guam, VI, etc. 
drop if STATEFP=="72" | STATEFP=="78" | STATEFP=="60" | STATEFP=="66" | STATEFP=="69"
 
spmap cntyid using "Data\xy_coor`(current_date)'.dta", id(id) fcolor(Reds) cln(6) legend(ring(0) bplace(se) bmargin(25 0 0 0)) ndf(gs4%10) ndl("No data") legstyle(2)

gr save "Output\Figure_1_`c(current_date)'.gph", replace
gr export "Output\Figure_1_`c(current_date)'.png", replace
gr export "Output\Figure_1_`c(current_date)'.svg", replace
gr export "Output\Figure_1_`c(current_date)'.pdf", replace


restore


* Trimmed twfe model (Jakiela)
reg rtw i.year i.cntyid if empb!=. & ln_deccountypop_ipo!=.

// Collect residuals for state
predict weightsb, resid

gen negtreatmentwtsb=0 if rtw==0 | (rtw==1 & weightsb>=0)
	replace negtreatmentwtsb=1 if rtw==1 & weightsb<0
	
	
* ID Consistent Sample that drops singleton counties in each county-border-by-year combination	
rifhdreg ln_empb i.rtw ln_deccountypop_ipo /*$demos $att*/ if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

gen sample5=1 if e(sample)==1

rifhdreg ln_est i.rtw ln_deccountypop_ipo /*$demos $att*/ if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

gen sample6=1 if e(sample)==1
	
	
save "Data\working_border_county_panel.dta", replace	
	
	
	
******************************************************************************
*** Descriptive Statistics (Table 1)
*** For the all county and the border pair county samples

* all county sample
use "Data\working_all_county_panel.dta", clear

eststo full: estpost sum empb ln_empb emp_20b ln_emp_20b emp_70b ln_emp_70b manuf_emp_share ln_manuf_emp_share serv_emp_share ln_serv_emp_share est ln_est est_20 ln_est_20 est_70 ln_est_70 manuf_est_share ln_manuf_est_share serv_est_share ln_serv_est_share ///
						 small_est ln_small_est medium_est ln_medium_est large_est ln_large_est ///
						 deccountypop_ipo ln_deccountypop_ipo if sample2==1 & ln_deccountypop_ipo!=., d
						 						 
esttab full using "Output\Table_1_All_County_`c(current_date)'.csv", ///
	replace cells ("mean(pattern(1) fmt(1)) p50(pattern(1) fmt(1)) sd(pattern(1) fmt(1))")  ///
	label title (Descriptives) nonumbers mtitles ("All County")
						 

* contiguous border sample
use "Data\working_border_county_panel.dta", clear

eststo full: estpost sum empb ln_empb emp_20b ln_emp_20b emp_70b ln_emp_70b manuf_emp_share ln_manuf_emp_share serv_emp_share ln_serv_emp_share est ln_est est_20 ln_est_20 est_70 ln_est_70 manuf_est_share ln_manuf_est_share serv_est_share ln_serv_est_share ///
						 small_est ln_small_est medium_est ln_medium_est large_est ln_large_est ///
						 deccountypop_ipo ln_deccountypop_ipo if sample3==1 & ln_deccountypop_ipo!=., d
						 						 
esttab full using "Output\Table_1_Border_Counties_`c(current_date)'.csv", ///
	replace cells ("mean(pattern(1) fmt(1)) p50(pattern(1) fmt(1)) sd(pattern(1) fmt(1))")  ///
	label title (Descriptives) nonumbers mtitles ("Contiguous")	
	
	
	
	
********************************************************************************************************************************************
* Descriptive Trends at the State-Level (Figure 2)
* Trends in growth rates of each of the CBP county economic dynamism outcome variables

use "Data\working_all_county_panel.dta", clear

preserve

collapse (sum) emp_20b emp_70b empb est_20 est_70 est (mean) ever_rtw2, by(fipstate year)

sort fipstate year

xtset fipstate year

bys fipstate: gen emp_l1=empb[_n-1]

gen ch_emp=(empb-emp_l1)/emp_l1

bys fipstate: gen emp_20_l1=emp_20b[_n-1]

gen ch_emp_20=(emp_20b-emp_20_l1)/emp_20_l1

bys fipstate: gen emp_70_l1=emp_70b[_n-1]

gen ch_emp_70=(emp_70b-emp_70_l1)/emp_70_l1

bys fipstate: gen est_l1=est[_n-1]

gen ch_est=(est-est_l1)/est_l1

bys fipstate: gen est_20_l1=est_20[_n-1]

gen ch_est_20=(est_20-est_20_l1)/est_20_l1

bys fipstate: gen est_70_l1=est_70[_n-1]

gen ch_est_70=(est_70-est_70_l1)/est_70_l1

collapse ch_emp ch_emp_20 ch_emp_70 ch_est ch_est_20 ch_est_70 if fipstate!=2 & fipstate!=15, by(ever_rtw2 year)


xtset ever_rtw2 year


* Overall employment growth rate
twoway lpoly ch_emp year if ever_rtw2==0 || lpoly ch_emp year if ever_rtw2==1 || lpoly ch_emp year if ever_rtw2==2 ||, legend(order(1 "Never RTW" 2 "Early RTW" 3 "Late RTW") ring(0) pos(1)) ytitle("Growth Rate (Decimal)") xtitle("") title("Total Employment") ylab(, nogrid) xlab(, nogrid)

gr save "Output\Intermediate\Pct_Ch_Emp_byEverRTW_`c(current_date)'.gph", replace
gr export "Output\Intermediate\Pct_Ch_Emp_byEverRTW_`c(current_date)'.png", replace

* Manufacturing employment growth rate
twoway lpoly ch_emp_20 year if ever_rtw2==0 || lpoly ch_emp_20 year if ever_rtw2==1 || lpoly ch_emp_20 year if ever_rtw2==2 ||, legend(order(1 "Never RTW" 2 "Early RTW" 3 "Late RTW") ring(0) pos(1)) ytitle("Growth Rate (Decimal)") xtitle("") title("Manuf. Employment") ylab(, nogrid) xlab(, nogrid)

gr save "Output\Intermediate\Pct_Ch_Emp_20_byEverRTW_`c(current_date)'.gph", replace

* Service employment growth rate
twoway lpoly ch_emp_70 year if ever_rtw2==0 || lpoly ch_emp_70 year if ever_rtw2==1 || lpoly ch_emp_70 year if ever_rtw2==2 ||, legend(order(1 "Never RTW" 2 "Early RTW" 3 "Late RTW") ring(0) pos(1)) ytitle("Growth Rate (Decimal)") xtitle("") title("Service Employment") ylab(, nogrid) xlab(, nogrid)

gr save "Output\Intermediate\Pct_Ch_Emp_70_byEverRTW_`c(current_date)'.gph", replace

* Overall establishment growth rate
twoway lpoly ch_est year if ever_rtw2==0 || lpoly ch_est year if ever_rtw2==1 || lpoly ch_est year if ever_rtw2==2 ||, legend(order(1 "Never RTW" 2 "Early RTW" 3 "Late RTW") ring(0) pos(1)) ytitle("Growth Rate (Decimal)") xtitle("") title("Total Establishments") ylab(, nogrid) xlab(, nogrid)

gr save "Output\Intermediate\Pct_Ch_Est_byEverRTW_`c(current_date)'.gph", replace

* Manufacturing establishment growth rate
twoway lpoly ch_est_20 year if ever_rtw2==0 || lpoly ch_est_20 year if ever_rtw2==1 || lpoly ch_est_20 year if ever_rtw2==2 ||, legend(order(1 "Never RTW" 2 "Early RTW" 3 "Late RTW") ring(0) pos(1)) ytitle("Growth Rate (Decimal)") xtitle("") title("Manuf. Establishments") ylab(, nogrid) xlab(, nogrid)

gr save "Output\Intermediate\Pct_Ch_Est_20_byEverRTW_`c(current_date)'.gph", replace

* Service establishment growth rate
twoway lpoly ch_est_70 year if ever_rtw2==0 || lpoly ch_est_70 year if ever_rtw2==1 || lpoly ch_est_70 year if ever_rtw2==2 ||, legend(order(1 "Never RTW" 2 "Early RTW" 3 "Late RTW") ring(0) pos(1)) ytitle("Growth Rate (Decimal)") xtitle("") title("Service Establishments") ylab(, nogrid) xlab(, nogrid)

gr save "Output\Intermediate\Pct_Ch_Est_70_byEverRTW_`c(current_date)'.gph", replace



* Combine all descriptive growth rates trends - Figure 2
gr combine "Output\Intermediate\Pct_Ch_Emp_byEverRTW_`c(current_date)'.gph" "Output\Intermediate\Pct_Ch_Est_byEverRTW_`c(current_date)'.gph" "Output\Intermediate\Pct_Ch_Emp_20_byEverRTW_`c(current_date)'.gph" "Output\Intermediate\Pct_Ch_Est_20_byEverRTW_`c(current_date)'.gph" "Output\Intermediate\Pct_Ch_Emp_70_byEverRTW_`c(current_date)'.gph" "Output\Intermediate\Pct_Ch_Est_70_byEverRTW_`c(current_date)'.gph", ///
col(2) iscale(.5) imargin(0 0) ycommon ysize(5) xsize(5)

gr save "Output\Figure_2_`c(current_date)'.gph", replace
gr export "Output\Figure_2_`c(current_date)'.png", replace
gr export "Output\Figure_2_`c(current_date)'.svg", replace
gr export "Output\Figure_2_`c(current_date)'.pdf", replace

restore	
	
	
	
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Main TWFE/DiD Models: Overall and manuf, serv employment, establishments and establishments by size category (Tables 2 and 3)

* Trimmed 2WFE 	(all county sample)
use "Data\working_all_county_panel.dta", clear

// log of employment - include state-specific linear trends - Table 2 (Panels A, C, and E)
rifhdreg ln_empb i.rtw ln_deccountypop_ipo i.fipstate#c.year if sample1==1 & negtreatmentwtsa==0, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_2_a_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label replace

rifhdreg ln_emp_20b i.rtw ln_deccountypop_ipo i.fipstate#c.year if sample1==1 & negtreatmentwtsa==0, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_2_c_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label replace

rifhdreg ln_emp_70b i.rtw ln_deccountypop_ipo i.fipstate#c.year if sample1==1 & negtreatmentwtsa==0, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_2_e_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label replace


// log of establishments - include state-specific linear trends - Table 2 (Panels B, D, and F)
rifhdreg ln_est i.rtw ln_deccountypop_ipo i.fipstate#c.year if sample2==1 & negtreatmentwtsa==0, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_2_b_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label replace

rifhdreg ln_est_20 i.rtw ln_deccountypop_ipo i.fipstate#c.year if sample2==1 & negtreatmentwtsa==0, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_2_d_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label replace

rifhdreg ln_est_70 i.rtw ln_deccountypop_ipo i.fipstate#c.year if sample2==1 & negtreatmentwtsa==0, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_2_f_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label replace


// log of establishments by size - Table 3 (Panels A, B, and C)
rifhdreg ln_small_est i.rtw ln_deccountypop_ipo i.fipstate#c.year if sample2==1 & negtreatmentwtsa==0, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_3_a_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label replace

rifhdreg ln_medium_est i.rtw ln_deccountypop_ipo i.fipstate#c.year if sample2==1 & negtreatmentwtsa==0, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_3_b_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label replace

rifhdreg ln_large_est i.rtw ln_deccountypop_ipo i.fipstate#c.year if sample2==1 & negtreatmentwtsa==0, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_3_c_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label replace



* Trimmed 2WFE (county-border-pair sample)
use  "Data\working_border_county_panel.dta", clear

// Log of employment - Table 2 (Panels A, C, and E)
rifhdreg ln_empb i.rtw ln_deccountypop_ipo if sample5==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid year) vce(cluster bordersegment)

outreg2 using "Output\Table_2_a_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_emp_20b i.rtw ln_deccountypop_ipo if sample5==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid year) vce(cluster bordersegment)

outreg2 using "Output\Table_2_c_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_emp_70b i.rtw ln_deccountypop_ipo if sample5==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid year) vce(cluster bordersegment)

outreg2 using "Output\Table_2_e_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append


// Log of establishments - Table 2 (Panels B, D, and F)
rifhdreg ln_est i.rtw ln_deccountypop_ipo if sample6==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid year) vce(cluster bordersegment)

outreg2 using "Output\Table_2_b_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_est_20 i.rtw ln_deccountypop_ipo if sample6==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid year) vce(cluster bordersegment)

outreg2 using "Output\Table_2_d_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_est_70 i.rtw ln_deccountypop_ipo if sample6==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid year) vce(cluster bordersegment)

outreg2 using "Output\Table_2_f_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append


// Log of establishments by size - Table 3 (Panels A, B, and C)
rifhdreg ln_small_est i.rtw ln_deccountypop_ipo if sample6==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid year) vce(cluster bordersegment)

outreg2 using "Output\Table_3_a_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_medium_est i.rtw ln_deccountypop_ipo if sample6==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid year) vce(cluster bordersegment)

outreg2 using "Output\Table_3_b_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_large_est i.rtw ln_deccountypop_ipo if sample6==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid year) vce(cluster bordersegment)

outreg2 using "Output\Table_3_c_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append



* Trimmed 3WFE (county and borderpair-by-year FEs)

// Log of employment - Table 2 (Panels A, C, and E)
rifhdreg ln_empb i.rtw ln_deccountypop_ipo if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_2_a_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_emp_20b i.rtw ln_deccountypop_ipo if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_2_c_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_emp_70b i.rtw ln_deccountypop_ipo if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_2_e_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append


// Log of establishments - Table 2 (Panels B, D, and F)
rifhdreg ln_est i.rtw ln_deccountypop_ipo if sample4==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_2_b_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_est_20 i.rtw ln_deccountypop_ipo if sample4==1 &  negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_2_d_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_est_70 i.rtw ln_deccountypop_ipo if sample4==1 &  negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_2_f_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append


// Log of establishments by size - Table 3 (Panels A, B, and C)
rifhdreg ln_small_est i.rtw ln_deccountypop_ipo if sample4==1 &  negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_3_a_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_medium_est i.rtw ln_deccountypop_ipo if sample4==1 &  negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_3_b_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_large_est i.rtw ln_deccountypop_ipo if sample4==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_3_c_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append



	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// Dynamic estimates and testing parallel trends using event study models (Figures 3, 4, S3, and S4)
///// Test the three major specifications (dropping negative treated obs): 
////			All counties w/ two-way FEs 
////			Border-counties w/ two-way FEs
////			Border-counties w/ three-way FEs

* Start with all counties sample with state-specific linear trends
use "Data\working_all_county_panel.dta", clear


foreach outcome in ln_empb ln_emp_20b ln_emp_70b ln_est ln_est_20 ln_est_70 ln_small_est ln_medium_est ln_large_est {
	
rifhdreg `outcome' ib29.event_rtw ln_deccountypop_ipo c.year#i.fipstate if sample2==1 & negtreatmentwtsa==0, rif(mean) abs(cntyid divyear) vce(cluster fipstate)	

preserve
parmest, label level(95) saving("Output\Intermediate\event_`outcome'_c.dta", replace)	
restore	
	
		}			
		
		
* Contiguous counties sample and two-way county and year FEs
use "Data\working_border_county_panel.dta", clear


foreach outcome in ln_empb ln_emp_20b ln_emp_70b ln_est ln_est_20 ln_est_70 ln_small_est ln_medium_est ln_large_est {
    
rifhdreg `outcome' ib29.event_rtw ln_deccountypop_ipo if sample5==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid year) vce(cluster bordersegment)	

preserve
parmest, label level(95) saving("Output\Intermediate\event_`outcome'_d.dta", replace)	
restore
	
		}	
		
* Contiguous counties sample and three-way county, county-border-pair-by-year FEs		
foreach outcome in ln_empb ln_emp_20b ln_emp_70b ln_est ln_est_20 ln_est_70 ln_small_est ln_medium_est ln_large_est {
    
rifhdreg `outcome' ib29.event_rtw ln_deccountypop_ipo if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)	

preserve
parmest, label level(95) saving("Output\Intermediate\event_`outcome'_e.dta", replace)	
restore
	
		}			

				
				
* Figure 3. Event Study for Total Employment and Establishments	
	
preserve

use "Output\Intermediate\event_ln_empb_c.dta", clear
gen type="All County State Trends: Emp."
append using "Output\Intermediate\event_ln_empb_d.dta", gen("event_ln_empb_d")
append using "Output\Intermediate\event_ln_empb_e.dta", gen("event_ln_empb_e")
append using "Output\Intermediate\event_ln_est_c.dta", gen("event_ln_est_c")
append using "Output\Intermediate\event_ln_est_d.dta", gen("event_ln_est_d")
append using "Output\Intermediate\event_ln_est_e.dta", gen("event_ln_est_e")

replace type="Contiguous 2WFE: Employment" if event_ln_empb_d==1
replace type="Contiguous 3WFE: Employment" if event_ln_empb_e==1
replace type="All County State Trends: Estab." if event_ln_est_c==1
replace type="Contiguous 2WFE: Establishments" if event_ln_est_d==1
replace type="Contiguous 3WFE: Establishments" if event_ln_est_e==1

gen kind=1 if type=="All County State Trends: Emp."
	replace kind=2 if type=="Contiguous 2WFE: Employment"
	replace kind=3 if type=="Contiguous 3WFE: Employment"
	replace kind=4 if type=="All County State Trends: Estab."
	replace kind=5 if type=="Contiguous 2WFE: Establishments"
	replace kind=6 if type=="Contiguous 3WFE: Establishments"
	
keep if strpos(parm, "event_rtw")

gen eventyear=1 if parm=="0.event_rtw"
replace eventyear=2 if parm=="1.event_rtw"
replace eventyear=3 if parm=="2.event_rtw"
replace eventyear=4 if parm=="3.event_rtw"
replace eventyear=5 if parm=="4.event_rtw"
replace eventyear=6 if parm=="5.event_rtw"
replace eventyear=7 if parm=="6.event_rtw"
replace eventyear=8 if parm=="7.event_rtw"
replace eventyear=9 if parm=="8.event_rtw"
replace eventyear=10 if parm=="9.event_rtw"
replace eventyear=11 if parm=="10.event_rtw"
replace eventyear=12 if parm=="11.event_rtw"
replace eventyear=13 if parm=="12.event_rtw"
replace eventyear=14 if parm=="13.event_rtw"
replace eventyear=15 if parm=="14.event_rtw"
replace eventyear=16 if parm=="15.event_rtw"
replace eventyear=17 if parm=="16.event_rtw"
replace eventyear=18 if parm=="17.event_rtw"
replace eventyear=19 if parm=="18.event_rtw"
replace eventyear=20 if parm=="19.event_rtw"
replace eventyear=21 if parm=="20.event_rtw"
replace eventyear=22 if parm=="21.event_rtw"
replace eventyear=23 if parm=="22.event_rtw"
replace eventyear=24 if parm=="23.event_rtw"
replace eventyear=25 if parm=="24.event_rtw"
replace eventyear=26 if parm=="25.event_rtw"
replace eventyear=27 if parm=="26.event_rtw"
replace eventyear=28 if parm=="27.event_rtw"
replace eventyear=29 if parm=="28.event_rtw"
replace eventyear=30 if parm=="29b.event_rtw"
replace eventyear=31 if parm=="30.event_rtw"
replace eventyear=32 if parm=="31.event_rtw"
replace eventyear=33 if parm=="32.event_rtw"
replace eventyear=34 if parm=="33.event_rtw"
replace eventyear=35 if parm=="34.event_rtw"
replace eventyear=36 if parm=="35.event_rtw"
replace eventyear=37 if parm=="36.event_rtw"
replace eventyear=38 if parm=="37.event_rtw"
replace eventyear=39 if parm=="38.event_rtw"
replace eventyear=40 if parm=="39.event_rtw"
replace eventyear=41 if parm=="40.event_rtw"
replace eventyear=42 if parm=="41.event_rtw"
replace eventyear=43 if parm=="42.event_rtw"
replace eventyear=44 if parm=="43.event_rtw"
replace eventyear=45 if parm=="44.event_rtw"
replace eventyear=46 if parm=="45.event_rtw"
replace eventyear=47 if parm=="46.event_rtw"
replace eventyear=48 if parm=="47.event_rtw"
replace eventyear=49 if parm=="48.event_rtw"
replace eventyear=50 if parm=="49.event_rtw"
replace eventyear=51 if parm=="50.event_rtw"
replace eventyear=52 if parm=="51.event_rtw"
replace eventyear=53 if parm=="52.event_rtw"
replace eventyear=54 if parm=="53.event_rtw"
replace eventyear=55 if parm=="54.event_rtw"
replace eventyear=56 if parm=="55.event_rtw"
replace eventyear=57 if parm=="56.event_rtw"
replace eventyear=58 if parm=="57.event_rtw"
replace eventyear=59 if parm=="58.event_rtw"
replace eventyear=60 if parm=="59.event_rtw"
replace eventyear=61 if parm=="60.event_rtw"
replace eventyear=62 if parm=="61.event_rtw"
replace eventyear=63 if parm=="62.event_rtw"
replace eventyear=64 if parm=="63.event_rtw"
replace eventyear=65 if parm=="64.event_rtw"
replace eventyear=66 if parm=="65.event_rtw"
replace eventyear=67 if parm=="66.event_rtw"
replace eventyear=68 if parm=="67.event_rtw"
replace eventyear=69 if parm=="68.event_rtw"
replace eventyear=70 if parm=="69.event_rtw"
replace eventyear=71 if parm=="70.event_rtw"
replace eventyear=72 if parm=="71.event_rtw"
replace eventyear=73 if parm=="72.event_rtw"
replace eventyear=74 if parm=="73.event_rtw"
replace eventyear=75 if parm=="74.event_rtw"
replace eventyear=76 if parm=="75.event_rtw"
replace eventyear=77 if parm=="76.event_rtw"
replace eventyear=78 if parm=="77.event_rtw"
replace eventyear=79 if parm=="78.event_rtw"
replace eventyear=80 if parm=="79.event_rtw"
replace eventyear=81 if parm=="80.event_rtw"

la def kindlab 1"All County (State Trends): Emp."2"Border Pair (TWFE): Emp."3"Border Pair (Pair-by-Year FE): Emp."4"All County (State Trends): Estab."5"Border Pair (TWFE): Estab."6"Border Pair (Pair-by-Year FE): Estab."
la val kind kindlab


gl vars "estimate stderr t min95 max95"

foreach var in $vars {
	
	replace `var'=0 if parm=="29b.event_rtw"
	
		}
				
gen double eventyear2=eventyear
drop eventyear
ren eventyear2 eventyear


sort kind eventyear


graph twoway (line max95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || (line min95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || ///
	(line estimate eventyear, mc(cranberry) lc(cranberry) lp(solid)) || if kind<4, ///
	by(kind, note("") legend(off) cols(1) yr) yline(0, lc(black)) xline(30, lp(dash) lc(black)) xtitle("") ///
	xlab(1 "T<=-30" 2 "." 3 "." 4 "." 5 "." 6 "." 7 "." 8 "." 9 "." 10 "." 11 "T-20" 12 "." 13 "." 14 "." 15 "." 16 "." 17 "." 18 "." 19 "." 20 "." ///
		 21 "T-10" 22 "." 23 "." 24 "." 25 "." 26 "." 27 "." 28 "." 29 "." 30 "." 31 "RTW" 32 "." 33 "." 34 "." 35 "." 36 "." 37 "." 38 "." 39 "." 40 "." ///
		 41 "T+10" 42 "." 43 "." 44 "." 45 "." 46 "." 47 "." 48 "." 49 "." 50 "." 51 "T+20" 52 "." 53 "." 54 "." 55 "." 56 "." 57 "." 58 "." 59 "." 60 "." 61 "T+30" ///
		 62 "." 63 "." 64 "." 65 "." 66 "." 67 "." 68 "." 69 "." 70 "." 71 "T+40" 72 "." 73 "." 74 "." 75 "." 76 "." 77 "." 78 "." 79 "." 80 "." 81 "T>=+50", nogrid) ///
		 xlab(, angle(90)) ///
	ytitle("") ylab(-0.4(0.2)0.4, nogrid) ///
	legend(position(7) ring(0)) xsize(1) ysize(3)

gr save "Output\Intermediate\Event_Study_DropNegObs_Emp_All_Years_`c(current_date)'.gph", replace
gr export "Output\Intermediate\Event_Study_DropNegObs_Emp_All_Years_`c(current_date)'.png", replace


graph twoway (line max95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || (line min95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || ///
	(line estimate eventyear, mc(cranberry) lc(cranberry) lp(solid)) || if kind>=4, ///
	by(kind, note("") legend(off) cols(1) yr) yline(0, lc(black)) xline(30, lp(dash) lc(black)) xtitle("") ///
	xlab(1 "T<=-30" 2 "." 3 "." 4 "." 5 "." 6 "." 7 "." 8 "." 9 "." 10 "." 11 "T-20" 12 "." 13 "." 14 "." 15 "." 16 "." 17 "." 18 "." 19 "." 20 "." ///
		 21 "T-10" 22 "." 23 "." 24 "." 25 "." 26 "." 27 "." 28 "." 29 "." 30 "." 31 "RTW" 32 "." 33 "." 34 "." 35 "." 36 "." 37 "." 38 "." 39 "." 40 "." ///
		 41 "T+10" 42 "." 43 "." 44 "." 45 "." 46 "." 47 "." 48 "." 49 "." 50 "." 51 "T+20" 52 "." 53 "." 54 "." 55 "." 56 "." 57 "." 58 "." 59 "." 60 "." 61 "T+30" ///
		 62 "." 63 "." 64 "." 65 "." 66 "." 67 "." 68 "." 69 "." 70 "." 71 "T+40" 72 "." 73 "." 74 "." 75 "." 76 "." 77 "." 78 "." 79 "." 80 "." 81 "T>=+50", nogrid) ///
		 xlab(, angle(90)) ///
	ytitle("") ylab(-0.4(0.2)0.4, nogrid) ///
	legend(position(7) ring(0)) xsize(1) ysize(3)

gr save "Output\Intermediate\Event_Study_DropNegObs_Est_All_Years_`c(current_date)'.gph", replace
gr export "Output\Intermediate\Event_Study_DropNegObs_Est_All_Years_`c(current_date)'.png", replace

restore


gr combine "Output\Intermediate\Event_Study_DropNegObs_Emp_All_Years_`c(current_date)'.gph" "Output\Intermediate\Event_Study_DropNegObs_Est_All_Years_`c(current_date)'.gph", col(2) ysize(8) xsize(8) ///
		imargin(0 0) iscale(0.5) ///
		l1("%-Point Difference vs. Year Before RTW", size(vsmall)) b1("Years Since RTW Passage", size(vsmall))

gr save "Output\Figure_3_`c(current_date)'.gph", replace
gr export "Output\Figure_3_`c(current_date)'.png", replace
gr export "Output\Figure_3_`c(current_date)'.svg", replace
gr export "Output\Figure_3_`c(current_date)'.pdf", replace



* Figure 4. Event Study for Manufacturing Employment and Establishments

preserve

use "Output\Intermediate\event_ln_emp_20b_c.dta", clear
gen type="All County State Trends: Emp."
append using "Output\Intermediate\event_ln_emp_20b_d.dta", gen("event_ln_emp_20b_d")
append using "Output\Intermediate\event_ln_emp_20b_e.dta", gen("event_ln_emp_20b_e")
append using "Output\Intermediate\event_ln_est_20_c.dta", gen("event_ln_est_20_c")
append using "Output\Intermediate\event_ln_est_20_d.dta", gen("event_ln_est_20_d")
append using "Output\Intermediate\event_ln_est_20_e.dta", gen("event_ln_est_20_e")

replace type="Contiguous 2WFE: Employment" if event_ln_emp_20b_d==1
replace type="Contiguous 3WFE: Employment" if event_ln_emp_20b_e==1
replace type="All County State Trends: Estab." if event_ln_est_20_c==1
replace type="Contiguous 2WFE: Establishments" if event_ln_est_20_d==1
replace type="Contiguous 3WFE: Establishments" if event_ln_est_20_e==1

gen kind=1 if type=="All County State Trends: Emp."
	replace kind=2 if type=="Contiguous 2WFE: Employment"
	replace kind=3 if type=="Contiguous 3WFE: Employment"
	replace kind=4 if type=="All County State Trends: Estab."
	replace kind=5 if type=="Contiguous 2WFE: Establishments"
	replace kind=6 if type=="Contiguous 3WFE: Establishments"
	
	
	
keep if strpos(parm, "event_rtw")

gen eventyear=1 if parm=="0.event_rtw"
replace eventyear=2 if parm=="1.event_rtw"
replace eventyear=3 if parm=="2.event_rtw"
replace eventyear=4 if parm=="3.event_rtw"
replace eventyear=5 if parm=="4.event_rtw"
replace eventyear=6 if parm=="5.event_rtw"
replace eventyear=7 if parm=="6.event_rtw"
replace eventyear=8 if parm=="7.event_rtw"
replace eventyear=9 if parm=="8.event_rtw"
replace eventyear=10 if parm=="9.event_rtw"
replace eventyear=11 if parm=="10.event_rtw"
replace eventyear=12 if parm=="11.event_rtw"
replace eventyear=13 if parm=="12.event_rtw"
replace eventyear=14 if parm=="13.event_rtw"
replace eventyear=15 if parm=="14.event_rtw"
replace eventyear=16 if parm=="15.event_rtw"
replace eventyear=17 if parm=="16.event_rtw"
replace eventyear=18 if parm=="17.event_rtw"
replace eventyear=19 if parm=="18.event_rtw"
replace eventyear=20 if parm=="19.event_rtw"
replace eventyear=21 if parm=="20.event_rtw"
replace eventyear=22 if parm=="21.event_rtw"
replace eventyear=23 if parm=="22.event_rtw"
replace eventyear=24 if parm=="23.event_rtw"
replace eventyear=25 if parm=="24.event_rtw"
replace eventyear=26 if parm=="25.event_rtw"
replace eventyear=27 if parm=="26.event_rtw"
replace eventyear=28 if parm=="27.event_rtw"
replace eventyear=29 if parm=="28.event_rtw"
replace eventyear=30 if parm=="29b.event_rtw"
replace eventyear=31 if parm=="30.event_rtw"
replace eventyear=32 if parm=="31.event_rtw"
replace eventyear=33 if parm=="32.event_rtw"
replace eventyear=34 if parm=="33.event_rtw"
replace eventyear=35 if parm=="34.event_rtw"
replace eventyear=36 if parm=="35.event_rtw"
replace eventyear=37 if parm=="36.event_rtw"
replace eventyear=38 if parm=="37.event_rtw"
replace eventyear=39 if parm=="38.event_rtw"
replace eventyear=40 if parm=="39.event_rtw"
replace eventyear=41 if parm=="40.event_rtw"
replace eventyear=42 if parm=="41.event_rtw"
replace eventyear=43 if parm=="42.event_rtw"
replace eventyear=44 if parm=="43.event_rtw"
replace eventyear=45 if parm=="44.event_rtw"
replace eventyear=46 if parm=="45.event_rtw"
replace eventyear=47 if parm=="46.event_rtw"
replace eventyear=48 if parm=="47.event_rtw"
replace eventyear=49 if parm=="48.event_rtw"
replace eventyear=50 if parm=="49.event_rtw"
replace eventyear=51 if parm=="50.event_rtw"
replace eventyear=52 if parm=="51.event_rtw"
replace eventyear=53 if parm=="52.event_rtw"
replace eventyear=54 if parm=="53.event_rtw"
replace eventyear=55 if parm=="54.event_rtw"
replace eventyear=56 if parm=="55.event_rtw"
replace eventyear=57 if parm=="56.event_rtw"
replace eventyear=58 if parm=="57.event_rtw"
replace eventyear=59 if parm=="58.event_rtw"
replace eventyear=60 if parm=="59.event_rtw"
replace eventyear=61 if parm=="60.event_rtw"
replace eventyear=62 if parm=="61.event_rtw"
replace eventyear=63 if parm=="62.event_rtw"
replace eventyear=64 if parm=="63.event_rtw"
replace eventyear=65 if parm=="64.event_rtw"
replace eventyear=66 if parm=="65.event_rtw"
replace eventyear=67 if parm=="66.event_rtw"
replace eventyear=68 if parm=="67.event_rtw"
replace eventyear=69 if parm=="68.event_rtw"
replace eventyear=70 if parm=="69.event_rtw"
replace eventyear=71 if parm=="70.event_rtw"
replace eventyear=72 if parm=="71.event_rtw"
replace eventyear=73 if parm=="72.event_rtw"
replace eventyear=74 if parm=="73.event_rtw"
replace eventyear=75 if parm=="74.event_rtw"
replace eventyear=76 if parm=="75.event_rtw"
replace eventyear=77 if parm=="76.event_rtw"
replace eventyear=78 if parm=="77.event_rtw"
replace eventyear=79 if parm=="78.event_rtw"
replace eventyear=80 if parm=="79.event_rtw"
replace eventyear=81 if parm=="80.event_rtw"

la def kindlab 1"All County (State Trends): Emp."2"Border Pair (TWFE): Emp."3"Border Pair (Pair-by-Year FE): Emp."4"All County (State Trends): Estab."5"Border Pair (TWFE): Estab."6"Border Pair (Pair-by-Year FE): Estab."

la val kind kindlab


gl vars "estimate stderr t min95 max95"

foreach var in $vars {
	
	replace `var'=0 if parm=="29b.event_rtw"
	
		}
				
gen double eventyear2=eventyear
drop eventyear
ren eventyear2 eventyear


sort kind eventyear


graph twoway (line max95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || (line min95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || ///
	(line estimate eventyear, mc(cranberry) lc(cranberry) lp(solid)) || if kind<4, ///
	by(kind, note("") legend(off) cols(1) yr) yline(0, lc(black)) xline(30, lp(dash) lc(black)) xtitle("") ///
	xlab(1 "T<=-30" 2 "." 3 "." 4 "." 5 "." 6 "." 7 "." 8 "." 9 "." 10 "." 11 "T-20" 12 "." 13 "." 14 "." 15 "." 16 "." 17 "." 18 "." 19 "." 20 "." ///
		 21 "T-10" 22 "." 23 "." 24 "." 25 "." 26 "." 27 "." 28 "." 29 "." 30 "." 31 "RTW" 32 "." 33 "." 34 "." 35 "." 36 "." 37 "." 38 "." 39 "." 40 "." ///
		 41 "T+10" 42 "." 43 "." 44 "." 45 "." 46 "." 47 "." 48 "." 49 "." 50 "." 51 "T+20" 52 "." 53 "." 54 "." 55 "." 56 "." 57 "." 58 "." 59 "." 60 "." 61 "T+30" ///
		 62 "." 63 "." 64 "." 65 "." 66 "." 67 "." 68 "." 69 "." 70 "." 71 "T+40" 72 "." 73 "." 74 "." 75 "." 76 "." 77 "." 78 "." 79 "." 80 "." 81 "T>=+50", nogrid) ///
		 xlab(, angle(90)) ///
	ytitle("") ylab(-1(.5)1, nogrid) ///
	legend(position(7) ring(0)) xsize(1) ysize(3)

gr save "Output\Intermediate\Event_Study_DropNegObs_Emp_20_All_Years_`c(current_date)'.gph", replace
gr export "Output\Intermediate\Event_Study_DropNegObs_Emp_20_All_Years_`c(current_date)'.png", replace


graph twoway (line max95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || (line min95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || ///
	(line estimate eventyear, mc(cranberry) lc(cranberry) lp(solid)) || if kind>=4, ///
	by(kind, note("") legend(off) cols(1) yr) yline(0, lc(black)) xline(30, lp(dash) lc(black)) xtitle("") ///
	xlab(1 "T<=-30" 2 "." 3 "." 4 "." 5 "." 6 "." 7 "." 8 "." 9 "." 10 "." 11 "T-20" 12 "." 13 "." 14 "." 15 "." 16 "." 17 "." 18 "." 19 "." 20 "." ///
		 21 "T-10" 22 "." 23 "." 24 "." 25 "." 26 "." 27 "." 28 "." 29 "." 30 "." 31 "RTW" 32 "." 33 "." 34 "." 35 "." 36 "." 37 "." 38 "." 39 "." 40 "." ///
		 41 "T+10" 42 "." 43 "." 44 "." 45 "." 46 "." 47 "." 48 "." 49 "." 50 "." 51 "T+20" 52 "." 53 "." 54 "." 55 "." 56 "." 57 "." 58 "." 59 "." 60 "." 61 "T+30" ///
		 62 "." 63 "." 64 "." 65 "." 66 "." 67 "." 68 "." 69 "." 70 "." 71 "T+40" 72 "." 73 "." 74 "." 75 "." 76 "." 77 "." 78 "." 79 "." 80 "." 81 "T>=+50", nogrid) ///
		 xlab(, angle(90)) ///
	ytitle("") ylab(-1(.5)1, nogrid) ///
	legend(position(7) ring(0)) xsize(1) ysize(3)

gr save "Output\Intermediate\Event_Study_DropNegObs_Est_20_All_Years_`c(current_date)'.gph", replace
gr export "Output\Intermediate\Event_Study_DropNegObs_Est_20_All_Years_`c(current_date)'.png", replace

restore


gr combine "Output\Intermediate\Event_Study_DropNegObs_Emp_20_All_Years_`c(current_date)'.gph" "Output\Intermediate\Event_Study_DropNegObs_Est_20_All_Years_`c(current_date)'.gph", col(2) ysize(8) xsize(8) ///
		imargin(0 0) iscale(.5) ///
		l1("%-Point Difference vs. Year Before RTW", size(vsmall)) b1("Years Since RTW Passage", size(vsmall))


gr save "Output\Figure_4_`c(current_date)'.gph", replace
gr export "Output\Figure_4_`c(current_date)'.png", replace
gr export "Output\Figure_4_`c(current_date)'.svg", replace
gr export "Output\Figure_4_`c(current_date)'.pdf", replace



* Figure S3. Event Study for Service Employment and Establishments

preserve

use "Output\Intermediate\event_ln_emp_70b_c.dta", clear
gen type="All County State Trends: Emp."
append using "Output\Intermediate\event_ln_emp_70b_d.dta", gen("event_ln_emp_70b_d")
append using "Output\Intermediate\event_ln_emp_70b_e.dta", gen("event_ln_emp_70b_e")
append using "Output\Intermediate\event_ln_est_70_c.dta", gen("event_ln_est_70_c")
append using "Output\Intermediate\event_ln_est_70_d.dta", gen("event_ln_est_70_d")
append using "Output\Intermediate\event_ln_est_70_e.dta", gen("event_ln_est_70_e")

replace type="Contiguous 2WFE: Employment" if event_ln_emp_70b_d==1
replace type="Contiguous 3WFE: Employment" if event_ln_emp_70b_e==1
replace type="All County State Trends: Estab." if event_ln_est_70_c==1
replace type="Contiguous 2WFE: Establishments" if event_ln_est_70_d==1
replace type="Contiguous 3WFE: Establishments" if event_ln_est_70_e==1

gen kind=1 if type=="All County State Trends: Emp."
	replace kind=2 if type=="Contiguous 2WFE: Employment"
	replace kind=3 if type=="Contiguous 3WFE: Employment"
	replace kind=4 if type=="All County State Trends: Estab."
	replace kind=5 if type=="Contiguous 2WFE: Establishments"
	replace kind=6 if type=="Contiguous 3WFE: Establishments"
	
	
keep if strpos(parm, "event_rtw")

gen eventyear=1 if parm=="0.event_rtw"
replace eventyear=2 if parm=="1.event_rtw"
replace eventyear=3 if parm=="2.event_rtw"
replace eventyear=4 if parm=="3.event_rtw"
replace eventyear=5 if parm=="4.event_rtw"
replace eventyear=6 if parm=="5.event_rtw"
replace eventyear=7 if parm=="6.event_rtw"
replace eventyear=8 if parm=="7.event_rtw"
replace eventyear=9 if parm=="8.event_rtw"
replace eventyear=10 if parm=="9.event_rtw"
replace eventyear=11 if parm=="10.event_rtw"
replace eventyear=12 if parm=="11.event_rtw"
replace eventyear=13 if parm=="12.event_rtw"
replace eventyear=14 if parm=="13.event_rtw"
replace eventyear=15 if parm=="14.event_rtw"
replace eventyear=16 if parm=="15.event_rtw"
replace eventyear=17 if parm=="16.event_rtw"
replace eventyear=18 if parm=="17.event_rtw"
replace eventyear=19 if parm=="18.event_rtw"
replace eventyear=20 if parm=="19.event_rtw"
replace eventyear=21 if parm=="20.event_rtw"
replace eventyear=22 if parm=="21.event_rtw"
replace eventyear=23 if parm=="22.event_rtw"
replace eventyear=24 if parm=="23.event_rtw"
replace eventyear=25 if parm=="24.event_rtw"
replace eventyear=26 if parm=="25.event_rtw"
replace eventyear=27 if parm=="26.event_rtw"
replace eventyear=28 if parm=="27.event_rtw"
replace eventyear=29 if parm=="28.event_rtw"
replace eventyear=30 if parm=="29b.event_rtw"
replace eventyear=31 if parm=="30.event_rtw"
replace eventyear=32 if parm=="31.event_rtw"
replace eventyear=33 if parm=="32.event_rtw"
replace eventyear=34 if parm=="33.event_rtw"
replace eventyear=35 if parm=="34.event_rtw"
replace eventyear=36 if parm=="35.event_rtw"
replace eventyear=37 if parm=="36.event_rtw"
replace eventyear=38 if parm=="37.event_rtw"
replace eventyear=39 if parm=="38.event_rtw"
replace eventyear=40 if parm=="39.event_rtw"
replace eventyear=41 if parm=="40.event_rtw"
replace eventyear=42 if parm=="41.event_rtw"
replace eventyear=43 if parm=="42.event_rtw"
replace eventyear=44 if parm=="43.event_rtw"
replace eventyear=45 if parm=="44.event_rtw"
replace eventyear=46 if parm=="45.event_rtw"
replace eventyear=47 if parm=="46.event_rtw"
replace eventyear=48 if parm=="47.event_rtw"
replace eventyear=49 if parm=="48.event_rtw"
replace eventyear=50 if parm=="49.event_rtw"
replace eventyear=51 if parm=="50.event_rtw"
replace eventyear=52 if parm=="51.event_rtw"
replace eventyear=53 if parm=="52.event_rtw"
replace eventyear=54 if parm=="53.event_rtw"
replace eventyear=55 if parm=="54.event_rtw"
replace eventyear=56 if parm=="55.event_rtw"
replace eventyear=57 if parm=="56.event_rtw"
replace eventyear=58 if parm=="57.event_rtw"
replace eventyear=59 if parm=="58.event_rtw"
replace eventyear=60 if parm=="59.event_rtw"
replace eventyear=61 if parm=="60.event_rtw"
replace eventyear=62 if parm=="61.event_rtw"
replace eventyear=63 if parm=="62.event_rtw"
replace eventyear=64 if parm=="63.event_rtw"
replace eventyear=65 if parm=="64.event_rtw"
replace eventyear=66 if parm=="65.event_rtw"
replace eventyear=67 if parm=="66.event_rtw"
replace eventyear=68 if parm=="67.event_rtw"
replace eventyear=69 if parm=="68.event_rtw"
replace eventyear=70 if parm=="69.event_rtw"
replace eventyear=71 if parm=="70.event_rtw"
replace eventyear=72 if parm=="71.event_rtw"
replace eventyear=73 if parm=="72.event_rtw"
replace eventyear=74 if parm=="73.event_rtw"
replace eventyear=75 if parm=="74.event_rtw"
replace eventyear=76 if parm=="75.event_rtw"
replace eventyear=77 if parm=="76.event_rtw"
replace eventyear=78 if parm=="77.event_rtw"
replace eventyear=79 if parm=="78.event_rtw"
replace eventyear=80 if parm=="79.event_rtw"
replace eventyear=81 if parm=="80.event_rtw"

la def kindlab 1"All County (State Trends): Emp."2"Border Pair (TWFE): Emp."3"Border Pair (Pair-by-Year FE): Emp."4"All County (State Trends): Estab."5"Border Pair (TWFE): Estab."6"Border Pair (Pair-by-Year FE): Estab."
la val kind kindlab


gl vars "estimate stderr t min95 max95"

foreach var in $vars {
	
	replace `var'=0 if parm=="29b.event_rtw"
	
		}
				
gen double eventyear2=eventyear
drop eventyear
ren eventyear2 eventyear


sort kind eventyear


graph twoway (line max95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || (line min95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || ///
	(line estimate eventyear, mc(cranberry) lc(cranberry) lp(solid)) || if kind<4, ///
	by(kind, note("") legend(off) cols(1) yr) yline(0, lc(black)) xline(30, lp(dash) lc(black)) xtitle("") ///
	xlab(1 "T<=-30" 2 "." 3 "." 4 "." 5 "." 6 "." 7 "." 8 "." 9 "." 10 "." 11 "T-20" 12 "." 13 "." 14 "." 15 "." 16 "." 17 "." 18 "." 19 "." 20 "." ///
		 21 "T-10" 22 "." 23 "." 24 "." 25 "." 26 "." 27 "." 28 "." 29 "." 30 "." 31 "RTW" 32 "." 33 "." 34 "." 35 "." 36 "." 37 "." 38 "." 39 "." 40 "." ///
		 41 "T+10" 42 "." 43 "." 44 "." 45 "." 46 "." 47 "." 48 "." 49 "." 50 "." 51 "T+20" 52 "." 53 "." 54 "." 55 "." 56 "." 57 "." 58 "." 59 "." 60 "." 61 "T+30" ///
		 62 "." 63 "." 64 "." 65 "." 66 "." 67 "." 68 "." 69 "." 70 "." 71 "T+40" 72 "." 73 "." 74 "." 75 "." 76 "." 77 "." 78 "." 79 "." 80 "." 81 "T>=+50", nogrid) ///
		 xlab(, angle(90)) ///
	ytitle("") ylab(-1(0.5)0.5, nogrid) ///
	legend(position(7) ring(0)) xsize(1) ysize(3)

gr save "Output\Intermediate\Event_Study_DropNegObs_Emp_70_All_Years_`c(current_date)'.gph", replace
gr export "Output\Intermediate\Event_Study_DropNegObs_Emp_70_All_Years_`c(current_date)'.png", replace


graph twoway (line max95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || (line min95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || ///
	(line estimate eventyear, mc(cranberry) lc(cranberry) lp(solid)) || if kind>=4, ///
	by(kind, note("") legend(off) cols(1) yr) yline(0, lc(black)) xline(30, lp(dash) lc(black)) xtitle("") ///
	xlab(1 "T<=-30" 2 "." 3 "." 4 "." 5 "." 6 "." 7 "." 8 "." 9 "." 10 "." 11 "T-20" 12 "." 13 "." 14 "." 15 "." 16 "." 17 "." 18 "." 19 "." 20 "." ///
		 21 "T-10" 22 "." 23 "." 24 "." 25 "." 26 "." 27 "." 28 "." 29 "." 30 "." 31 "RTW" 32 "." 33 "." 34 "." 35 "." 36 "." 37 "." 38 "." 39 "." 40 "." ///
		 41 "T+10" 42 "." 43 "." 44 "." 45 "." 46 "." 47 "." 48 "." 49 "." 50 "." 51 "T+20" 52 "." 53 "." 54 "." 55 "." 56 "." 57 "." 58 "." 59 "." 60 "." 61 "T+30" ///
		 62 "." 63 "." 64 "." 65 "." 66 "." 67 "." 68 "." 69 "." 70 "." 71 "T+40" 72 "." 73 "." 74 "." 75 "." 76 "." 77 "." 78 "." 79 "." 80 "." 81 "T>=+50", nogrid) ///
		 xlab(, angle(90)) ///
	ytitle("") ylab(-1(0.5)0.5, nogrid) ///
	legend(position(7) ring(0)) xsize(1) ysize(3)

gr save "Output\Intermediate\Event_Study_DropNegObs_Est_70_All_Years_`c(current_date)'.gph", replace
gr export "Output\Intermediate\Event_Study_DropNegObs_Est_70_All_Years_`c(current_date)'.png", replace

restore


gr combine "Output\Intermediate\Event_Study_DropNegObs_Emp_70_All_Years_`c(current_date)'.gph" "Output\Intermediate\Event_Study_DropNegObs_Est_70_All_Years_`c(current_date)'.gph", col(2) ysize(8) xsize(8) ///
		imargin(0 0) iscale(.5) ///
		l1("%-Point Difference vs. Year Before RTW", size(vsmall)) b1("Years Since RTW Passage", size(vsmall))


gr save "Output\Figure_S3_`c(current_date)'.gph", replace
gr export "Output\Figure_S3_`c(current_date)'.png", replace
gr export "Output\Figure_S3_`c(current_date)'.svg", replace
gr export "Output\Figure_S3_`c(current_date)'.pdf", replace




* Figure S4 - Event Study for Establishments by Size Category
preserve

use "Output\Intermediate\event_ln_small_est_c.dta", clear
gen type="All County State Trends: Small Est."
append using "Output\Intermediate\event_ln_small_est_d.dta", gen("event_ln_small_est_d")
append using "Output\Intermediate\event_ln_small_est_e.dta", gen("event_ln_small_est_e")
append using "Output\Intermediate\event_ln_medium_est_c.dta", gen("event_ln_medium_est_c")
append using "Output\Intermediate\event_ln_medium_est_d.dta", gen("event_ln_medium_est_d")
append using "Output\Intermediate\event_ln_medium_est_e.dta", gen("event_ln_medium_est_e")
append using "Output\Intermediate\event_ln_large_est_c.dta", gen("event_ln_large_est_c")
append using "Output\Intermediate\event_ln_large_est_d.dta", gen("event_ln_large_est_d")
append using "Output\Intermediate\event_ln_large_est_e.dta", gen("event_ln_large_est_e")

replace type="Contiguous 2WFE: Small Est." if event_ln_small_est_d==1
replace type="Contiguous 3WFE: Small Est." if event_ln_small_est_e==1
replace type="All County State Trends: Medium Est." if event_ln_medium_est_c==1
replace type="Contiguous 2WFE: Medium Est." if event_ln_medium_est_d==1
replace type="Contiguous 3WFE: Medium Est." if event_ln_medium_est_e==1
replace type="All County State Trends: Large Est." if event_ln_large_est_c==1
replace type="Contiguous 2WFE: Large Est." if event_ln_large_est_d==1
replace type="Contiguous 3WFE: Large Est." if event_ln_large_est_e==1

gen kind=1 if type=="All County State Trends: Small Est."
	replace kind=2 if type=="Contiguous 2WFE: Small Est."
	replace kind=3 if type=="Contiguous 3WFE: Small Est."
	replace kind=4 if type=="All County State Trends: Medium Est."
	replace kind=5 if type=="Contiguous 2WFE: Medium Est."
	replace kind=6 if type=="Contiguous 3WFE: Medium Est."
	replace kind=7 if type=="All County State Trends: Large Est."
	replace kind=8 if type=="Contiguous 2WFE: Large Est."
	replace kind=9 if type=="Contiguous 3WFE: Large Est."

keep if strpos(parm, "event_rtw")

gen eventyear=1 if parm=="0.event_rtw"
replace eventyear=2 if parm=="1.event_rtw"
replace eventyear=3 if parm=="2.event_rtw"
replace eventyear=4 if parm=="3.event_rtw"
replace eventyear=5 if parm=="4.event_rtw"
replace eventyear=6 if parm=="5.event_rtw"
replace eventyear=7 if parm=="6.event_rtw"
replace eventyear=8 if parm=="7.event_rtw"
replace eventyear=9 if parm=="8.event_rtw"
replace eventyear=10 if parm=="9.event_rtw"
replace eventyear=11 if parm=="10.event_rtw"
replace eventyear=12 if parm=="11.event_rtw"
replace eventyear=13 if parm=="12.event_rtw"
replace eventyear=14 if parm=="13.event_rtw"
replace eventyear=15 if parm=="14.event_rtw"
replace eventyear=16 if parm=="15.event_rtw"
replace eventyear=17 if parm=="16.event_rtw"
replace eventyear=18 if parm=="17.event_rtw"
replace eventyear=19 if parm=="18.event_rtw"
replace eventyear=20 if parm=="19.event_rtw"
replace eventyear=21 if parm=="20.event_rtw"
replace eventyear=22 if parm=="21.event_rtw"
replace eventyear=23 if parm=="22.event_rtw"
replace eventyear=24 if parm=="23.event_rtw"
replace eventyear=25 if parm=="24.event_rtw"
replace eventyear=26 if parm=="25.event_rtw"
replace eventyear=27 if parm=="26.event_rtw"
replace eventyear=28 if parm=="27.event_rtw"
replace eventyear=29 if parm=="28.event_rtw"
replace eventyear=30 if parm=="29b.event_rtw"
replace eventyear=31 if parm=="30.event_rtw"
replace eventyear=32 if parm=="31.event_rtw"
replace eventyear=33 if parm=="32.event_rtw"
replace eventyear=34 if parm=="33.event_rtw"
replace eventyear=35 if parm=="34.event_rtw"
replace eventyear=36 if parm=="35.event_rtw"
replace eventyear=37 if parm=="36.event_rtw"
replace eventyear=38 if parm=="37.event_rtw"
replace eventyear=39 if parm=="38.event_rtw"
replace eventyear=40 if parm=="39.event_rtw"
replace eventyear=41 if parm=="40.event_rtw"
replace eventyear=42 if parm=="41.event_rtw"
replace eventyear=43 if parm=="42.event_rtw"
replace eventyear=44 if parm=="43.event_rtw"
replace eventyear=45 if parm=="44.event_rtw"
replace eventyear=46 if parm=="45.event_rtw"
replace eventyear=47 if parm=="46.event_rtw"
replace eventyear=48 if parm=="47.event_rtw"
replace eventyear=49 if parm=="48.event_rtw"
replace eventyear=50 if parm=="49.event_rtw"
replace eventyear=51 if parm=="50.event_rtw"
replace eventyear=52 if parm=="51.event_rtw"
replace eventyear=53 if parm=="52.event_rtw"
replace eventyear=54 if parm=="53.event_rtw"
replace eventyear=55 if parm=="54.event_rtw"
replace eventyear=56 if parm=="55.event_rtw"
replace eventyear=57 if parm=="56.event_rtw"
replace eventyear=58 if parm=="57.event_rtw"
replace eventyear=59 if parm=="58.event_rtw"
replace eventyear=60 if parm=="59.event_rtw"
replace eventyear=61 if parm=="60.event_rtw"
replace eventyear=62 if parm=="61.event_rtw"
replace eventyear=63 if parm=="62.event_rtw"
replace eventyear=64 if parm=="63.event_rtw"
replace eventyear=65 if parm=="64.event_rtw"
replace eventyear=66 if parm=="65.event_rtw"
replace eventyear=67 if parm=="66.event_rtw"
replace eventyear=68 if parm=="67.event_rtw"
replace eventyear=69 if parm=="68.event_rtw"
replace eventyear=70 if parm=="69.event_rtw"
replace eventyear=71 if parm=="70.event_rtw"
replace eventyear=72 if parm=="71.event_rtw"
replace eventyear=73 if parm=="72.event_rtw"
replace eventyear=74 if parm=="73.event_rtw"
replace eventyear=75 if parm=="74.event_rtw"
replace eventyear=76 if parm=="75.event_rtw"
replace eventyear=77 if parm=="76.event_rtw"
replace eventyear=78 if parm=="77.event_rtw"
replace eventyear=79 if parm=="78.event_rtw"
replace eventyear=80 if parm=="79.event_rtw"
replace eventyear=81 if parm=="80.event_rtw"

la def kindlab 1"All County (State Trends): Small"2"Border Pair (TWFE): Small"3"Border Pair (Pair-by-Year FE): Small"4"All County (State Trends): Medium"5"Border Pair (TWFE): Medium"6"Border Pair (Pair-by-Year FE): Medium"7"All County (State Trends): Large"8"Border Pair (TWFE): Large"9"Border Pair (Pair-by-Year FE): Large"
la val kind kindlab


gl vars "estimate stderr t min95 max95"

foreach var in $vars {
	
	replace `var'=0 if parm=="29b.event_rtw"
	
		}
				
gen double eventyear2=eventyear
drop eventyear
ren eventyear2 eventyear


sort kind eventyear


graph twoway (line max95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || (line min95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || ///
	(line estimate eventyear, mc(cranberry) lc(cranberry) lp(solid)) || if kind<4, ///
	by(kind, note("") legend(off) cols(1) yr) yline(0, lc(black)) xline(30, lp(dash) lc(black)) xtitle("") ///
	xlab(1 "T<=-30" 2 "." 3 "." 4 "." 5 "." 6 "." 7 "." 8 "." 9 "." 10 "." 11 "T-20" 12 "." 13 "." 14 "." 15 "." 16 "." 17 "." 18 "." 19 "." 20 "." ///
		 21 "T-10" 22 "." 23 "." 24 "." 25 "." 26 "." 27 "." 28 "." 29 "." 30 "." 31 "RTW" 32 "." 33 "." 34 "." 35 "." 36 "." 37 "." 38 "." 39 "." 40 "." ///
		 41 "T+10" 42 "." 43 "." 44 "." 45 "." 46 "." 47 "." 48 "." 49 "." 50 "." 51 "T+20" 52 "." 53 "." 54 "." 55 "." 56 "." 57 "." 58 "." 59 "." 60 "." 61 "T+30" ///
		 62 "." 63 "." 64 "." 65 "." 66 "." 67 "." 68 "." 69 "." 70 "." 71 "T+40" 72 "." 73 "." 74 "." 75 "." 76 "." 77 "." 78 "." 79 "." 80 "." 81 "T>=+50", nogrid) ///
		 xlab(, angle(90)) ///
	ytitle("") ylab(-0.5(0.5)1, nogrid) ///
	legend(position(7) ring(0)) xsize(1) ysize(1)

gr save "Output\Intermediate\Event_Study_DropNegObs_Small_Est_All_Years_`c(current_date)'.gph", replace
gr export "Output\Intermediate\Event_Study_DropNegObs_Small_Est_All_Years_`c(current_date)'.png", replace


graph twoway (line max95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || (line min95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || ///
	(line estimate eventyear, mc(cranberry) lc(cranberry) lp(solid)) || if kind>=4 & kind<7, ///
	by(kind, note("") legend(off) cols(1) yr) yline(0, lc(black)) xline(30, lp(dash) lc(black)) xtitle("") ///
	xlab(1 "T<=-30" 2 "." 3 "." 4 "." 5 "." 6 "." 7 "." 8 "." 9 "." 10 "." 11 "T-20" 12 "." 13 "." 14 "." 15 "." 16 "." 17 "." 18 "." 19 "." 20 "." ///
		 21 "T-10" 22 "." 23 "." 24 "." 25 "." 26 "." 27 "." 28 "." 29 "." 30 "." 31 "RTW" 32 "." 33 "." 34 "." 35 "." 36 "." 37 "." 38 "." 39 "." 40 "." ///
		 41 "T+10" 42 "." 43 "." 44 "." 45 "." 46 "." 47 "." 48 "." 49 "." 50 "." 51 "T+20" 52 "." 53 "." 54 "." 55 "." 56 "." 57 "." 58 "." 59 "." 60 "." 61 "T+30" ///
		 62 "." 63 "." 64 "." 65 "." 66 "." 67 "." 68 "." 69 "." 70 "." 71 "T+40" 72 "." 73 "." 74 "." 75 "." 76 "." 77 "." 78 "." 79 "." 80 "." 81 "T>=+50", nogrid) ///
		 xlab(, angle(90)) ///
	ytitle("") ylab(-0.5(0.5)1, nogrid) ///
	legend(position(7) ring(0)) xsize(1) ysize(1)

gr save "Output\Intermediate\Event_Study_DropNegObs_Medium_Est_All_Years_`c(current_date)'.gph", replace
gr export "Output\Intermediate\Event_Study_DropNegObs_Medium_Est_All_Years_`c(current_date)'.png", replace


graph twoway (line max95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || (line min95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || ///
	(line estimate eventyear, mc(cranberry) lc(cranberry) lp(solid)) || if kind>6, ///
	by(kind, note("") legend(off) cols(1) yr) yline(0, lc(black)) xline(30, lp(dash) lc(black)) xtitle("") ///
	xlab(1 "T<=-30" 2 "." 3 "." 4 "." 5 "." 6 "." 7 "." 8 "." 9 "." 10 "." 11 "T-20" 12 "." 13 "." 14 "." 15 "." 16 "." 17 "." 18 "." 19 "." 20 "." ///
		 21 "T-10" 22 "." 23 "." 24 "." 25 "." 26 "." 27 "." 28 "." 29 "." 30 "." 31 "RTW" 32 "." 33 "." 34 "." 35 "." 36 "." 37 "." 38 "." 39 "." 40 "." ///
		 41 "T+10" 42 "." 43 "." 44 "." 45 "." 46 "." 47 "." 48 "." 49 "." 50 "." 51 "T+20" 52 "." 53 "." 54 "." 55 "." 56 "." 57 "." 58 "." 59 "." 60 "." 61 "T+30" ///
		 62 "." 63 "." 64 "." 65 "." 66 "." 67 "." 68 "." 69 "." 70 "." 71 "T+40" 72 "." 73 "." 74 "." 75 "." 76 "." 77 "." 78 "." 79 "." 80 "." 81 "T>=+50", nogrid) ///
		 xlab(, angle(90)) ///
	ytitle("") ylab(-0.5(0.5)1, nogrid) ///
	legend(position(7) ring(0)) xsize(1) ysize(1)

gr save "Output\Intermediate\Event_Study_DropNegObs_Large_Est_All_Years_`c(current_date)'.gph", replace
gr export "Output\Intermediate\Event_Study_DropNegObs_Large_Est_All_Years_`c(current_date)'.png", replace

restore


gr combine "Output\Intermediate\Event_Study_DropNegObs_Small_Est_All_Years_`c(current_date)'.gph" "Output\Intermediate\Event_Study_DropNegObs_Medium_Est_All_Years_`c(current_date)'.gph" "Output\Intermediate\Event_Study_DropNegObs_Large_Est_All_Years_`c(current_date)'.gph", col(3) ysize(5) xsize(7) ///
		imargin(0 0 0) iscale(.5) ///
		l1("%-Point Difference vs. Year Before RTW", size(vsmall)) b1("Years Since RTW Passage", size(vsmall))

gr save "Output\Figure_S4_`c(current_date)'.gph", replace
gr export "Output\Figure_S4_`c(current_date)'.png", replace
gr export "Output\Figure_S4_`c(current_date)'.svg", replace
gr export "Output\Figure_S4_`c(current_date)'.pdf", replace

	



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// Test CBP models using the measures of state tax incentives from Slattery/BEA
/////   Just focus on the preferred model that includes the CBP-by-period FEs

* Table 4	
	
use "Data\working_border_county_panel.dta", clear	
	
	
* Log of net incentives (taxes minus subsidies) (Table 4, Panel A)
rifhdreg ln_empb ln_tx_minus_sub_cpi ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_a_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label replace

rifhdreg ln_emp_20b ln_tx_minus_sub_cpi ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_a_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_emp_70b ln_tx_minus_sub_cpi ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_a_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_est ln_tx_minus_sub_cpi ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_a_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_est_20 ln_tx_minus_sub_cpi ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_a_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_est_70 ln_tx_minus_sub_cpi ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_a_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_small_est ln_tx_minus_sub_cpi ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_a_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_medium_est ln_tx_minus_sub_cpi ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_a_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_large_est ln_tx_minus_sub_cpi ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_a_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append


* net incentives (taxes - subsidies) as % of state GDP (Table 4, Panel B)
rifhdreg ln_empb net_gdp ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_b_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label replace

rifhdreg ln_emp_20b net_gdp ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_b_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_emp_70b net_gdp ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_b_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_est net_gdp ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_b_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_est_20 net_gdp ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_b_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_est_70 net_gdp ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_b_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_small_est net_gdp ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_b_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_medium_est net_gdp ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_b_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_large_est net_gdp ln_deccountypop_ipo, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_4_b_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append
	
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// Test CBP models using the measures of state tax incentives from Upjohn
//////   This is all industry subsidies/taxes combined and as a percentage of the total value added across all industries in the data in each state-year
//////   Use all county sample because Upjohn data is not available for all states (so county-border-FE approach is less feasible)

use "Data\working_all_county_panel.dta", clear


* net incentives (taxes - subsidies) as percent of value-added (Table 4, Panel C)
* include state-specific linear trend to control for time-varying confounders
rifhdreg ln_empb nettax ln_deccountypop_ipo i.fipstate#c.year, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_4_c_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label replace

rifhdreg ln_emp_20b nettax ln_deccountypop_ipo i.fipstate#c.year, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_4_c_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_emp_70b nettax ln_deccountypop_ipo i.fipstate#c.year, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_4_c_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_est nettax ln_deccountypop_ipo i.fipstate#c.year, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_4_c_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_est_20 nettax ln_deccountypop_ipo i.fipstate#c.year, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_4_c_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_est_70 nettax ln_deccountypop_ipo i.fipstate#c.year, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_4_c_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_small_est nettax ln_deccountypop_ipo i.fipstate#c.year, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_4_c_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_medium_est nettax ln_deccountypop_ipo i.fipstate#c.year, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_4_c_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_large_est nettax ln_deccountypop_ipo i.fipstate#c.year, rif(mean) abs(cntyid divyear) vce(cluster fipstate)

outreg2 using "Output\Table_4_c_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

	
	

*************************************************************************************************************************************
* Aside: Test for supression across decades using on the RTW effects
* interactions b/t decade and tax as controls, marginal effects for decade and RTW interactions
* these models include county-border-pair-specific, or state-specific, linear trends to control for time

* Figure 6, Figure S5, and Figure S6

foreach outcome in ln_empb ln_emp_20b ln_emp_70b ln_est ln_est_20 ln_est_70 ln_small_est ln_medium_est ln_large_est {
	
	
* set working directory
cd "C:\Users\aprhodes\OneDrive - purdue.edu\Buckeyebox\Policy Corporate Demography\Policy Corporate Demography\Writing\ASR Submit\ASR_26_RTW"
    
	
***************************************************************************************************	
* all county sample (include state-specific linear trends)
use "Data\working_all_county_panel.dta", clear

* aside: test decades (5/22/2025)
gen decade=1 if year<=1950
	replace decade=2 if year>1950 & year<=1960
	replace decade=3 if year>1960 & year<=1970
	replace decade=4 if year>1970 & year<=1980
	replace decade=5 if year>1980 & year<=1990
	replace decade=6 if year>1990 & year<=2000
	replace decade=7 if year>2000 & year<=2010
	replace decade=8 if year>2010 & year<=2019

	
* set working directory
cd "C:\Users\aprhodes\OneDrive - purdue.edu\Buckeyebox\Policy Corporate Demography\Policy Corporate Demography\Writing\ASR Submit\ASR_26_RTW\Output\Intermediate"	
	
	
* version 1: without controls for tax policy
rifhdreg `outcome' ln_deccountypop_ipo i.rtw##i.decade i.fipstate#c.year if sample2==1 & negtreatmentwtsa==0, rif(mean) abs(cntyid /*cbp_period*/) vce(cluster fipstate)
margins, dydx(rtw) at(decade=(1 2 3 4 5 6 7 8)) saving(`outcome'_allcnty_e, replace)

* version 2: including ln_tx_minus_sub_cpi
rifhdreg `outcome' c.ln_tx_minus_sub_cpi##i.decade ln_deccountypop_ipo i.rtw##i.decade i.fipstate#c.year if sample2==1 & negtreatmentwtsa==0, rif(mean) abs(cntyid /*cbp_period*/) vce(cluster fipstate)
margins, dydx(rtw) at(decade=(3 4 5 6 7 8)) saving(`outcome'_allcnty_b, replace)
	
* version 3: including net tax as percent of gdp	
rifhdreg `outcome' c.net_gdp##i.decade ln_deccountypop_ipo i.rtw##i.decade i.fipstate#c.year if sample2==1 & negtreatmentwtsa==0, rif(mean) abs(cntyid /*cbp_period*/) vce(cluster fipstate)
margins, dydx(rtw) at(decade=(3 4 5 6 7 8)) saving(`outcome'_allcnty_c, replace)	

* version 4: including nettax as percent of VAD
rifhdreg `outcome' c.nettax##i.decade ln_deccountypop_ipo i.rtw##i.decade i.fipstate#c.year if sample2==1 & negtreatmentwtsa==0, rif(mean) abs(cntyid /*cbp_period*/) vce(cluster fipstate)
margins, dydx(rtw) at(decade=(6 7 8)) saving(`outcome'_allcnty_d, replace)		


***************************************************************************************************	
* county-border-pair sample (include border-pair linear trends)

* set working directory
cd "C:\Users\aprhodes\OneDrive - purdue.edu\Buckeyebox\Policy Corporate Demography\Policy Corporate Demography\Writing\ASR Submit\ASR_26_RTW"


use "Data\working_border_county_panel.dta", clear

* aside: test decades (5/22/2025)
gen decade=1 if year<=1950
	replace decade=2 if year>1950 & year<=1960
	replace decade=3 if year>1960 & year<=1970
	replace decade=4 if year>1970 & year<=1980
	replace decade=5 if year>1980 & year<=1990
	replace decade=6 if year>1990 & year<=2000
	replace decade=7 if year>2000 & year<=2010
	replace decade=8 if year>2010 & year<=2019
	
egen countypair_id2=group(countypair_id)	

* set working directory
cd "C:\Users\aprhodes\OneDrive - purdue.edu\Buckeyebox\Policy Corporate Demography\Policy Corporate Demography\Writing\ASR Submit\ASR_26_RTW\Output\Intermediate"		
	
* version 1: without controls for tax policy
rifhdreg `outcome' ln_deccountypop_ipo i.rtw##i.decade c.year#i.countypair_id2 if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid /*cbp_period*/) vce(cluster bordersegment)
margins, dydx(rtw) at(decade=(1 2 3 4 5 6 7 8)) saving(`outcome'_borderp_e, replace)	

* version 2: including ln_tx_minus_sub_cpi
rifhdreg `outcome' c.ln_tx_minus_sub_cpi##i.decade ln_deccountypop_ipo i.rtw##i.decade c.year#i.countypair_id2 if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid /*cbp_period*/) vce(cluster bordersegment)
margins, dydx(rtw) at(decade=(3 4 5 6 7 8)) saving(`outcome'_borderp_b, replace)
	
* version 3: including net tax as percent of gdp	
rifhdreg `outcome' c.net_gdp##i.decade ln_deccountypop_ipo i.rtw##i.decade c.year#i.countypair_id2 if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid /*cbp_period*/) vce(cluster bordersegment)
margins, dydx(rtw) at(decade=(3 4 5 6 7 8)) saving(`outcome'_borderp_c, replace)	

* version 4: including nettax as percent of VAD
rifhdreg `outcome' c.nettax##i.decade ln_deccountypop_ipo i.rtw##i.decade c.year#i.countypair_id2 if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid /*cbp_period*/) vce(cluster bordersegment)
margins, dydx(rtw) at(decade=(6 7 8)) saving(`outcome'_borderp_d, replace)

		
* combine no tax controls models - v1
combomarginsplot `outcome'_allcnty_e `outcome'_borderp_e, recastci(rarea) ///
ci1opts(lwidth(*0) fcolor(black%50)) ///
ci2opts(lwidth(*0) fcolor(red%50)) ///
plot1opt(lcolor(black) lwidth(*1.5) ms(none)) ///
plot2opt(lcolor(red) lpattern(dash) lwidth(*1.5) ms(none)) ///
yline(0, lcolor(black) lpattern(dash) lwidth(*2)) ///
xtitle("") ytitle("") xlab(1"40s"2"50s"3"60s"4"70s"5"80s"6"90s"7"00s"8"10s", angle(45)) ///
legend(order(3 "All County" 4 "Border Pair") position(8) ring(0) region(color(none))) ///
title("`outcome'") ///
xlab(, nogrid) ylab(, nogrid) ///
name(`outcome'_combo_e, replace)



* combine no tax controls models - v2
combomarginsplot `outcome'_allcnty_e `outcome'_borderp_e, recastci(rarea) ///
ci1opts(lwidth(*0) fcolor(black%50)) ///
ci2opts(lwidth(*0) fcolor(red%50)) ///
plot1opt(lcolor(black) lwidth(*1.5) ms(none)) ///
plot2opt(lcolor(red) lpattern(dash) lwidth(*1.5) ms(none)) ///
yline(0, lcolor(black) lpattern(dash) lwidth(*2)) ///
xtitle("") ytitle("") xlab(1"40s"2"50s"3"60s"4"70s"5"80s"6"90s"7"00s"8"10s", angle(45)) ///
legend(order(3 "All County" 4 "Border Pair") position(8) ring(0) region(color(none))) ///
title("No Tax Controls") ///
xlab(, nogrid) ylab(, nogrid) ///
name(`outcome'_combo_e_2, replace)

* ln_tx_minus_sub_cpi tax controls - v2
combomarginsplot `outcome'_allcnty_b `outcome'_borderp_b, recastci(rarea) ///
ci1opts(lwidth(*0) fcolor(black%50)) ///
ci2opts(lwidth(*0) fcolor(red%50)) ///
plot1opt(lcolor(black) lwidth(*1.5) ms(none)) ///
plot2opt(lcolor(red) lpattern(dash) lwidth(*1.5) ms(none)) ///
yline(0, lcolor(black) lpattern(dash) lwidth(*2)) ///
xtitle("") ytitle("") xlab(1"40s"2"50s"3"60s"4"70s"5"80s"6"90s"7"00s"8"10s", angle(45)) ///
legend(order(3 "All County" 4 "Border Pair") position(8) ring(0) region(color(none))) ///
title("Net Taxes (in $1s)") ///
xlab(, nogrid) ylab(, nogrid) ///
name(`outcome'_combo_b, replace)

* net tax as % gdp - v2
combomarginsplot `outcome'_allcnty_c `outcome'_borderp_c, recastci(rarea) ///
ci1opts(lwidth(*0) fcolor(black%50)) ///
ci2opts(lwidth(*0) fcolor(red%50)) ///
plot1opt(lcolor(black) lwidth(*1.5) ms(none)) ///
plot2opt(lcolor(red) lpattern(dash) lwidth(*1.5) ms(none)) ///
yline(0, lcolor(black) lpattern(dash) lwidth(*2)) ///
xtitle("") ytitle("") xlab(1"40s"2"50s"3"60s"4"70s"5"80s"6"90s"7"00s"8"10s", angle(45)) ///
legend(order(3 "All County" 4 "Border Pair") position(8) ring(0) region(color(none))) ///
title("Net Taxes (%-GDP)") ///
xlab(, nogrid) ylab(, nogrid) ///
name(`outcome'_combo_c, replace)

* net tax as % VAD - v2
combomarginsplot `outcome'_allcnty_d `outcome'_borderp_d, recastci(rarea) ///
ci1opts(lwidth(*0) fcolor(black%50)) ///
ci2opts(lwidth(*0) fcolor(red%50)) ///
plot1opt(lcolor(black) lwidth(*1.5) ms(none)) ///
plot2opt(lcolor(red) lpattern(dash) lwidth(*1.5) ms(none)) ///
yline(0, lcolor(black) lpattern(dash) lwidth(*2)) ///
xtitle("") ytitle("") xlab(1"40s"2"50s"3"60s"4"70s"5"80s"6"90s"7"00s"8"10s", angle(45)) ///
legend(order(3 "All County" 4 "Border Pair") position(8) ring(0) region(color(none))) ///
title("Net Taxes (%-VAD)") ///
xlab(, nogrid) ylab(, nogrid) ///
name(`outcome'_combo_d, replace)

	
				}

				
* set working directory
cd "C:\Users\aprhodes\OneDrive - purdue.edu\Buckeyebox\Policy Corporate Demography\Policy Corporate Demography\Writing\ASR Submit\ASR_26_RTW\Output"				
		
* combine panels into 1 figure for employment outcomes - Figure 6
gr combine ln_empb_combo_e_2 ln_empb_combo_b ln_empb_combo_c ln_empb_combo_d, ///
			col(4) ycommon xcommon t1("Total Employment") name(g1a, replace) imargins(0)
gr combine ln_emp_20b_combo_e_2 ln_emp_20b_combo_b ln_emp_20b_combo_c ln_emp_20b_combo_d, ///
			col(4) ycommon xcommon t1("Manufacturing Employment") name(g2a, replace) imargins(0)
gr combine ln_emp_70b_combo_e_2 ln_emp_70b_combo_b ln_emp_70b_combo_c ln_emp_70b_combo_d, ///
			col(4) ycommon xcommon t1("Service Employment") name(g3a, replace) imargins(0)

gr combine g1a g2a g3a, col(1) ysize(9) xsize(8) l1("Effect of RTW (in Percentage Points)", size(verysmall)) b1("Decade", size(verysmall)) imargins(0) ycommon

gr save "Figure_6_`c(current_date)'.gph", replace	
gr export "Figure_6_`c(current_date)'.png", replace
gr export "Figure_6_`c(current_date)'.svg", replace	
gr export "Figure_6_`c(current_date)'.pdf", replace	

* combine panels into 1 figure for establishments by type - Figure S5
gr combine ln_est_combo_e_2 ln_est_combo_b ln_est_combo_c ln_est_combo_d, ///
			col(4) ycommon xcommon t1("Total Establishments") name(g1b, replace) imargins(0)
gr combine ln_est_20_combo_e_2 ln_est_20_combo_b ln_est_20_combo_c ln_est_20_combo_d, ///
			col(4) ycommon xcommon t1("Manufacturing Establishments") name(g2b, replace) imargins(0)
gr combine ln_est_70_combo_e_2 ln_est_70_combo_b ln_est_70_combo_c ln_est_70_combo_d, ///
		    col(4) ycommon xcommon t1("Service Establishments") name(g3b, replace) imargins(0)

gr combine g1b g2b g3b, col(1) ysize(9) xsize(8) l1("Effect of RTW (in Percentage Points)", size(verysmall)) b1("Decade", size(verysmall)) imargins(0) ycommon

gr save "Figure_S5_`c(current_date)'.gph", replace	
gr export "Figure_S5_`c(current_date)'.png", replace
gr export "Figure_S5_`c(current_date)'.svg", replace	
gr export "Figure_S5_`c(current_date)'.pdf", replace

* combine panels into 1 figure for establishments by size - Figure S6
gr combine ln_small_est_combo_e_2 ln_small_est_combo_b ln_small_est_combo_c ln_small_est_combo_d, ///
			col(4) ycommon xcommon t1("Small Establishments") name(g1c, replace) imargins(0)
gr combine ln_medium_est_combo_e_2 ln_medium_est_combo_b ln_medium_est_combo_c ln_medium_est_combo_d, ///
			col(4) ycommon xcommon t1("Medium Establishments") name(g2c, replace) imargins(0)
gr combine ln_large_est_combo_e_2 ln_large_est_combo_b ln_large_est_combo_c ln_large_est_combo_d, ///
			col(4) ycommon xcommon t1("Large Establishments") name(g3c, replace) imargins(0)

gr combine g1c g2c g3c, col(1) ysize(9) xsize(8) l1("Effect of RTW (in Percentage Points)", size(verysmall)) b1("Decade", size(verysmall)) imargins(0) ycommon

gr save "Figure_S6_`c(current_date)'.gph", replace	
gr export "Figure_S6_`c(current_date)'.png", replace	
gr export "Figure_S6_`c(current_date)'.svg", replace
gr export "Figure_S6_`c(current_date)'.pdf", replace



******************************************************** Online Supplement *******************************************************************************************************

* set working directory
cd "C:\Users\aprhodes\OneDrive - purdue.edu\Buckeyebox\Policy Corporate Demography\Policy Corporate Demography\Writing\ASR Submit\ASR_26_RTW"


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// Use alternative measure of est/emp to population (county/10000 per-person) and manuf/service shares
///// And no control for population
///// These outcomes are closer to what Holmes (1999) and Austin and Lilley (2021) use in their papers

// Table S1

* Trimmed 3WFE (county and borderpair-by-year FEs)

use "Data\working_border_county_panel.dta", clear

// Log of employment/10k residents
rifhdreg ln_emptopop i.rtw if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S1_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label replace

// Log of manuf. emp/10k residents
rifhdreg ln_emp20topop i.rtw if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S1_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

// Log of service emp/10k residents
rifhdreg ln_emp70topop i.rtw if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S1_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

// Log of establishments/10k residents
rifhdreg ln_esttopop i.rtw if sample4==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S1_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

// Log of manuf. estab./10k residents
rifhdreg ln_est20topop i.rtw if sample4==1 &  negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S1_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

// Log of service estab./10k residents
rifhdreg ln_est70topop i.rtw if sample4==1 &  negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S1_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

// Log of small estab./10k residents
rifhdreg ln_small_esttopop i.rtw if sample4==1 &  negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S1_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

// Log of medium estab./10k residents
rifhdreg ln_medium_esttopop i.rtw if sample4==1 &  negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S1_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

// Log of large estab./10k residents
rifhdreg ln_large_esttopop i.rtw if sample4==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S1_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

// Log of manuf. emp share - all years
rifhdreg ln_manuf_emp_share i.rtw if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S1_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

// Log of manuf. share of establishments - all years
rifhdreg ln_manuf_est_share i.rtw if sample4==1 &  negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S1_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

// Log of service emp share - all years
rifhdreg ln_serv_emp_share i.rtw if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S1_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

// Log of service share of establishments - all years
rifhdreg ln_serv_est_share i.rtw if sample4==1 &  negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S1_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// Test More Direct Measures of Economic Dynamism from Census Business Dynamism dataset, 1978-2019
///// This is at the county-by-year unit of observation level
///// Outcomes: - Log of... firm entry rate, firm exit rate, job reallocation rate, employees in start-ups, estabs that are start-ups
/////			- Percent of employees in startups, percent of estabs that are start-ups

// Table S2

use "Data\working_border_county_panel.dta", clear

///// Trimmed 3-way FE models

* Log of estab entry rate
rifhdreg ln_estabs_entry_rate i.rtw ln_deccountypop_ipo if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

est store est_entry

outreg2 using "Output\Table_S2_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label replace

* Log of estab exit rate
rifhdreg ln_estabs_exit_rate i.rtw ln_deccountypop_ipo if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

est store est_exit

outreg2 using "Output\Table_S2_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

* Log of job reallocation rate
rifhdreg ln_reallocation_rate i.rtw ln_deccountypop_ipo if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

est store reallocat

outreg2 using "Output\Table_S2_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

* Log of employees in start-ups
rifhdreg ln_emp_startups i.rtw ln_deccountypop_ipo if sample4==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

est store emp_startups

outreg2 using "Output\Table_S2_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

* Log of estabs that are start-ups
rifhdreg ln_estabs_startups i.rtw ln_deccountypop_ipo if sample4==1 &  negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

est store est_startups

outreg2 using "Output\Table_S2_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

* Percent of employees in start-ups
rifhdreg peremp_startups i.rtw ln_deccountypop_ipo if sample4==1 &  negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

est store pct_emp_start

outreg2 using "Output\Table_S2_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

* Percent of estabs that are start-ups
rifhdreg perestabs_startups i.rtw ln_deccountypop_ipo if sample4==1 &  negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

est store pct_est_start

outreg2 using "Output\Table_S2_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append


est table est_entry est_exit reallocat est_startups pct_est_start emp_startups pct_emp_start, b(%7.3f) keep(i.rtw) stats(N) star(0.001, 0.01, 0.05) ///
	title("Table 2. County-Border Pair FE Models Predicting Alternative Business Dynamism Outcomes")

						 

						 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Test for problematic heterogeneity by leaving out one treated cohort at a time
//// Just the CBP discontinuities sample

// Figure S1

use "Data\working_border_county_panel.dta", clear

la var rtw "."
la def rtwlab 0"."1"."
la val rtw rtwlab

set scheme cleanplots

* Use preferred Spec (County-border pair sample with three-way FEs) 
foreach cohort in 1943 1944 1946 1947 1948 1952 1953 1954 1955 1963 1976 1985 2001 2012 2015 2016 2017 {
    
// Log of employment
rifhdreg ln_empb i.rtw ln_deccountypop_ipo if sample3==1 & negtreatmentwtsb==0 & year_rtw!=`cohort', rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

est store Cem`cohort'

		}

foreach cohort in 1943 1944 1946 1947 1948 1952 1953 1954 1955 1963 1976 1985 2001 2012 2015 2016 2017 {
    
// Log of manufacturing emp
rifhdreg ln_emp_20b i.rtw ln_deccountypop_ipo if sample3==1 & negtreatmentwtsb==0 & year_rtw!=`cohort', rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

est store Cef`cohort'

		}
		
foreach cohort in 1943 1944 1946 1947 1948 1952 1953 1954 1955 1963 1976 1985 2001 2012 2015 2016 2017 {
    
// Log of service emp
rifhdreg ln_emp_70b i.rtw ln_deccountypop_ipo if sample3==1 & negtreatmentwtsb==0 & year_rtw!=`cohort', rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

est store Ced`cohort'

		}
		
foreach cohort in 1943 1944 1946 1947 1948 1952 1953 1954 1955 1963 1976 1985 2001 2012 2015 2016 2017 {
    
// Log of est
rifhdreg ln_est i.rtw ln_deccountypop_ipo if sample4==1 & negtreatmentwtsb==0 & year_rtw!=`cohort', rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

est store Ces`cohort'

		}
		
foreach cohort in 1943 1944 1946 1947 1948 1952 1953 1954 1955 1963 1976 1985 2001 2012 2015 2016 2017 {
    
// Log of manufacturing est
rifhdreg ln_est_20 i.rtw ln_deccountypop_ipo if sample4==1 & negtreatmentwtsb==0 & year_rtw!=`cohort', rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

est store Csf`cohort'

		}
		
foreach cohort in 1943 1944 1946 1947 1948 1952 1953 1954 1955 1963 1976 1985 2001 2012 2015 2016 2017 {
    
// Log of service est
rifhdreg ln_est_70 i.rtw ln_deccountypop_ipo if sample4==1 & negtreatmentwtsb==0 & year_rtw!=`cohort', rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

est store Csd`cohort'

		}
	
foreach cohort in 1943 1944 1946 1947 1948 1952 1953 1954 1955 1963 1976 1985 2001 2012 2015 2016 2017 {			
			
// Log of small est
rifhdreg ln_small_est i.rtw ln_deccountypop_ipo if sample4==1 & negtreatmentwtsb==0 & year_rtw!=`cohort', rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

est store Cs`cohort'

		}
		
foreach cohort in 1943 1944 1946 1947 1948 1952 1953 1954 1955 1963 1976 1985 2001 2012 2015 2016 2017 {

// Log of medium est
rifhdreg ln_medium_est i.rtw ln_deccountypop_ipo if sample4==1 & negtreatmentwtsb==0 & year_rtw!=`cohort', rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

est store Cm`cohort'

		}

foreach cohort in 1943 1944 1946 1947 1948 1952 1953 1954 1955 1963 1976 1985 2001 2012 2015 2016 2017 {

// Log of large est
rifhdreg ln_large_est i.rtw ln_deccountypop_ipo if sample4==1 & negtreatmentwtsb==0 & year_rtw!=`cohort', rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

est store Cl`cohort'

		}
		
		
* Figure S1. For all outcomes for the county-border-pair FE models
coefplot Cem1943 Cem1944 Cem1946 Cem1947 Cem1948 Cem1952 Cem1953 Cem1954 Cem1955 Cem1963 Cem1976 Cem1985 Cem2001 Cem2012 Cem2015 Cem2016 Cem2017 || ///
		Ces1943 Ces1944 Ces1946 Ces1947 Ces1948 Ces1952 Ces1953 Ces1954 Ces1955 Ces1963 Ces1976 Ces1985 Ces2001 Ces2012 Ces2015 Ces2016 Ces2017 || ///
		Cef1943 Cef1944 Cef1946 Cef1947 Cef1948 Cef1952 Cef1953 Cef1954 Cef1955 Cef1963 Cef1976 Cef1985 Cef2001 Cef2012 Cef2015 Cef2016 Cef2017 || ///
		Csf1943 Csf1944 Csf1946 Csf1947 Csf1948 Csf1952 Csf1953 Csf1954 Csf1955 Csf1963 Csf1976 Csf1985 Csf2001 Csf2012 Csf2015 Csf2016 Csf2017 || ///
		Ced1943 Ced1944 Ced1946 Ced1947 Ced1948 Ced1952 Ced1953 Ced1954 Ced1955 Ced1963 Ced1976 Ced1985 Ced2001 Ced2012 Ced2015 Ced2016 Ced2017 || ///
		Csd1943 Csd1944 Csd1946 Csd1947 Csd1948 Csd1952 Csd1953 Csd1954 Csd1955 Csd1963 Csd1976 Csd1985 Csd2001 Csd2012 Csd2015 Csd2016 Csd2017 || ///
		Cs1943 Cs1944 Cs1946 Cs1947 Cs1948 Cs1952 Cs1953 Cs1954 Cs1955 Cs1963 Cs1976 Cs1985 Cs2001 Cs2012 Cs2015 Cs2016 Cs2017 || ///
		Cm1943 Cm1944 Cm1946 Cm1947 Cm1948 Cm1952 Cm1953 Cm1954 Cm1955 Cm1963 Cm1976 Cm1985 Cm2001 Cm2012 Cm2015 Cm2016 Cm2017 || ///
		Cl1943 Cl1944 Cl1946 Cl1947 Cl1948 Cl1952 Cl1953 Cl1954 Cl1955 Cl1963 Cl1976 Cl1985 Cl2001 Cl2012 Cl2015 Cl2016 Cl2017, ///
		yline(0) vertical drop(_cons ln_deccountypop_ipo) byopts(yrescale) col(3) ///
		legend(order(1 "1943:FL" 3 "1944:AR" 5 "1946:AZ,KS,NE,SD" 7 "1947:GA,IA,NC,TN,TX,VA" 9 "1948:ND" 11 "1952:NV" 13 "1953:AL" 15 "1954:MS,SC" 17 "1955:UT" 19 "1963:WY" ///
					 21 "1976:LA" 23 "1985:ID" 25 "2001:OK" 27 "2012:IN,MI" 29 "2015:WI" 31 "2016:WV" 33 "2017:KY")) ///
		legend(title("Excluded RTW Cohort")) legend(size(vsmall)) legend(col(6)) ytitle("Coefficient on RTW") ///
		bylabels("Total Employment" "Total Establishments" "Manuf. Employment" "Manuf. Establishments" "Serv. Employment" "Serv. Establishments" "Small Establishments" "Medium Establishments" "Large Establishments") ///
		ylab(, nogrid)
		
gr save "Output\Figure_S1_`c(current_date)'.gph", replace
gr export "Output\Figure_S1_`c(current_date)'.png", replace
gr export "Output\Figure_S1_`c(current_date)'.svg", replace
gr export "Output\Figure_S1_`c(current_date)'.pdf", replace



********************************************************************************************************************************************
* Check spillovers into non-RTW states on border counties relative to non-RTW counties on the interrior
* These models tell us how RTW laws across the border impact the focal county in a non-rtw state relative to the other non-border counties
* in the same non-RTW state

* Table S4 and Figure S2

use "Data\working_all_county_panel.dta", clear

gen nonrtwborderrtw2=1 if rtwborder==1 & rtw==0
	replace nonrtwborderrtw2=0 if (rtwborder==0 & rtw==0) | (bordercounty==0 & rtw==0)
	
gen nonrtwborderrtw3=nonrtwborderrtw2 // includes RTW counties in the control group
	recode nonrtwborderrtw3 (.=0) if (rtw==1)
		
sort cntyid year	
bys cntyid: gen year_border_rtw=1 if nonrtwborderrtw2==1 & nonrtwborderrtw2[_n-1]==0
replace year_border_rtw=year if year_border_rtw==1
bys cntyid: egen year_border_rtwb=max(year_border_rtw)
drop year_border_rtw
ren year_border_rtwb year_border_rtw

bys cntyid: egen ever_border_rtw=max(nonrtwborderrtw2)

gen yearsince_border_rtw=year-year_border_rtw

gen event_border_rtw=0 if yearsince_border_rtw<=-30 & yearsince_border_rtw!=.
		replace event_border_rtw=1 if yearsince_border_rtw==-29
		replace event_border_rtw=2 if yearsince_border_rtw==-28
		replace event_border_rtw=3 if yearsince_border_rtw==-27
		replace event_border_rtw=4 if yearsince_border_rtw==-26
		replace event_border_rtw=5 if yearsince_border_rtw==-25
		replace event_border_rtw=6 if yearsince_border_rtw==-24
		replace event_border_rtw=7 if yearsince_border_rtw==-23
		replace event_border_rtw=8 if yearsince_border_rtw==-22
		replace event_border_rtw=9 if yearsince_border_rtw==-21
		replace event_border_rtw=10 if yearsince_border_rtw==-20
		replace event_border_rtw=11 if yearsince_border_rtw==-19
		replace event_border_rtw=12 if yearsince_border_rtw==-18
		replace event_border_rtw=13 if yearsince_border_rtw==-17
		replace event_border_rtw=14 if yearsince_border_rtw==-16
		replace event_border_rtw=15 if yearsince_border_rtw==-15
		replace event_border_rtw=16 if yearsince_border_rtw==-14
		replace event_border_rtw=17 if yearsince_border_rtw==-13
		replace event_border_rtw=18 if yearsince_border_rtw==-12
		replace event_border_rtw=19 if yearsince_border_rtw==-11
		replace event_border_rtw=20 if yearsince_border_rtw==-10
		replace event_border_rtw=21 if yearsince_border_rtw==-9
		replace event_border_rtw=22 if yearsince_border_rtw==-8
		replace event_border_rtw=23 if yearsince_border_rtw==-7
		replace event_border_rtw=24 if yearsince_border_rtw==-6
		replace event_border_rtw=25 if yearsince_border_rtw==-5
		replace event_border_rtw=26 if yearsince_border_rtw==-4
		replace event_border_rtw=27 if yearsince_border_rtw==-3
		replace event_border_rtw=28 if yearsince_border_rtw==-2
		replace event_border_rtw=29 if yearsince_border_rtw==-1
		replace event_border_rtw=30 if yearsince_border_rtw==0
		replace event_border_rtw=31 if yearsince_border_rtw==1
		replace event_border_rtw=32 if yearsince_border_rtw==2
		replace event_border_rtw=33 if yearsince_border_rtw==3
		replace event_border_rtw=34 if yearsince_border_rtw==4
		replace event_border_rtw=35 if yearsince_border_rtw==5
		replace event_border_rtw=36 if yearsince_border_rtw==6
		replace event_border_rtw=37 if yearsince_border_rtw==7
		replace event_border_rtw=38 if yearsince_border_rtw==8
		replace event_border_rtw=39 if yearsince_border_rtw==9
		replace event_border_rtw=40 if yearsince_border_rtw==10
		replace event_border_rtw=41 if yearsince_border_rtw==11
		replace event_border_rtw=42 if yearsince_border_rtw==12
		replace event_border_rtw=43 if yearsince_border_rtw==13
		replace event_border_rtw=44 if yearsince_border_rtw==14
		replace event_border_rtw=45 if yearsince_border_rtw==15
		replace event_border_rtw=46 if yearsince_border_rtw==16
		replace event_border_rtw=47 if yearsince_border_rtw==17
		replace event_border_rtw=48 if yearsince_border_rtw==18
		replace event_border_rtw=49 if yearsince_border_rtw==19
		replace event_border_rtw=50 if yearsince_border_rtw==20
		replace event_border_rtw=51 if yearsince_border_rtw==21
		replace event_border_rtw=52 if yearsince_border_rtw==22
		replace event_border_rtw=53 if yearsince_border_rtw==23
		replace event_border_rtw=54 if yearsince_border_rtw==24
		replace event_border_rtw=55 if yearsince_border_rtw==25
		replace event_border_rtw=56 if yearsince_border_rtw==26
		replace event_border_rtw=57 if yearsince_border_rtw==27
		replace event_border_rtw=58 if yearsince_border_rtw==28
		replace event_border_rtw=59 if yearsince_border_rtw==29
		replace event_border_rtw=60 if yearsince_border_rtw==30 
		replace event_border_rtw=61 if yearsince_border_rtw==31
		replace event_border_rtw=62 if yearsince_border_rtw==32
		replace event_border_rtw=63 if yearsince_border_rtw==33
		replace event_border_rtw=64 if yearsince_border_rtw==34
		replace event_border_rtw=65 if yearsince_border_rtw==35
		replace event_border_rtw=66 if yearsince_border_rtw==36
		replace event_border_rtw=67 if yearsince_border_rtw==37
		replace event_border_rtw=68 if yearsince_border_rtw==38
		replace event_border_rtw=69 if yearsince_border_rtw==39
		replace event_border_rtw=70 if yearsince_border_rtw==40
		replace event_border_rtw=71 if yearsince_border_rtw==41
		replace event_border_rtw=72 if yearsince_border_rtw==42
		replace event_border_rtw=73 if yearsince_border_rtw==43
		replace event_border_rtw=74 if yearsince_border_rtw==44
		replace event_border_rtw=75 if yearsince_border_rtw==45
		replace event_border_rtw=76 if yearsince_border_rtw==46
		replace event_border_rtw=77 if yearsince_border_rtw==47
		replace event_border_rtw=78 if yearsince_border_rtw==48
		replace event_border_rtw=79 if yearsince_border_rtw==49
		replace event_border_rtw=80 if yearsince_border_rtw>=50 & yearsince_border_rtw!=.
		
		replace event_border_rtw=29 if ever_border_rtw==0 
		
gen event_border_rtw_2=event_border_rtw // includes rtw in the control group
		replace event_border_rtw_2=29 if rtw==1 & event_border_rtw==.
	

* create indicator for state X year FEs		
egen stateyear=group(fipstate year)


* Trimmed twfe model (Jakiela)
reg nonrtwborderrtw2 i.year i.cntyid if empb!=. & ln_deccountypop_ipo!=.

// Collect residuals for state
predict weightsx, resid

gen negtreatmentwtsx=0 if nonrtwborderrtw2==0 | (nonrtwborderrtw2==1 & weightsx>=0)
	replace negtreatmentwtsx=1 if nonrtwborderrtw2==1 & weightsx<0

gen negtreatmentwtsy=0 if nonrtwborderrtw3==0 | (nonrtwborderrtw2==1 & weightsx>=0)
	replace negtreatmentwtsy=1 if nonrtwborderrtw2==1 & weightsx<0

	
ren nonrtwborderrtw3 rtwborder3


// Table S4	
	
// log of employment - include state-by-year FEs	
rifhdreg ln_empb i.rtwborder3 ln_deccountypop_ipo if sample1==1 & negtreatmentwtsy==0, rif(mean) abs(cntyid stateyear) vce(cluster fipstate)

outreg2 using "Output\Table_S4_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label replace

rifhdreg ln_emp_20b i.rtwborder3 ln_deccountypop_ipo if sample1==1 & negtreatmentwtsy==0, rif(mean) abs(cntyid stateyear) vce(cluster fipstate)

outreg2 using "Output\Table_S4_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_emp_70b i.rtwborder3 ln_deccountypop_ipo if sample1==1 & negtreatmentwtsy==0, rif(mean) abs(cntyid stateyear) vce(cluster fipstate)

outreg2 using "Output\Table_S4_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append


// log of estabs - include state-by-year FEs
rifhdreg ln_est i.rtwborder3 ln_deccountypop_ipo if sample1==1 & negtreatmentwtsy==0, rif(mean) abs(cntyid stateyear) vce(cluster fipstate)

outreg2 using "Output\Table_S4_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_est_20 i.rtwborder3 ln_deccountypop_ipo if sample1==1 & negtreatmentwtsy==0, rif(mean) abs(cntyid stateyear) vce(cluster fipstate)

outreg2 using "Output\Table_S4_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_est_70 i.rtwborder3 ln_deccountypop_ipo if sample1==1 & negtreatmentwtsy==0, rif(mean) abs(cntyid stateyear) vce(cluster fipstate)

outreg2 using "Output\Table_S4_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_small_est i.rtwborder3 ln_deccountypop_ipo if sample1==1 & negtreatmentwtsy==0, rif(mean) abs(cntyid stateyear) vce(cluster fipstate)

outreg2 using "Output\Table_S4_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_medium_est i.rtwborder3 ln_deccountypop_ipo if sample1==1 & negtreatmentwtsy==0, rif(mean) abs(cntyid stateyear) vce(cluster fipstate)

outreg2 using "Output\Table_S4_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_large_est i.rtwborder3 ln_deccountypop_ipo if sample1==1 & negtreatmentwtsy==0, rif(mean) abs(cntyid stateyear) vce(cluster fipstate)

outreg2 using "Output\Table_S4_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append


	
// Event study estimates --> Include state-by-year FEs in all models

// Figure S2

foreach outcome in ln_empb ln_emp_20b ln_emp_70b ln_est ln_est_20 ln_est_70 ln_small_est ln_medium_est ln_large_est {
    
rifhdreg `outcome' ib29.event_border_rtw_2 ln_deccountypop_ipo if sample1==1 & negtreatmentwtsy==0, rif(mean) abs(cntyid stateyear) vce(cluster fipstate)

preserve
parmest, label level(95) saving("Output\Intermediate\event_`outcome'_nonrtwborder.dta", replace)	
restore
	
		}			

				
preserve

use "Output\Intermediate\event_ln_empb_nonrtwborder.dta", clear
gen type="Total Employment"
append using "Output\Intermediate\event_ln_emp_20b_nonrtwborder.dta", gen("event_ln_emp_20b_nonrtwborder")
append using "Output\Intermediate\event_ln_emp_70b_nonrtwborder.dta", gen("event_ln_emp_70b_nonrtwborder")
append using "Output\Intermediate\event_ln_est_nonrtwborder.dta", gen("event_ln_est_nonrtwborder")
append using "Output\Intermediate\event_ln_est_20_nonrtwborder.dta", gen("event_ln_est_20_nonrtwborder")
append using "Output\Intermediate\event_ln_est_70_nonrtwborder.dta", gen("event_ln_est_70_nonrtwborder")
append using "Output\Intermediate\event_ln_small_est_nonrtwborder.dta", gen("event_ln_small_est_nonrtwborder")
append using "Output\Intermediate\event_ln_medium_est_nonrtwborder.dta", gen("event_ln_medium_est_nonrtwborder")
append using "Output\Intermediate\event_ln_large_est_nonrtwborder.dta", gen("event_ln_large_est_nonrtwborder")

replace type="Manuf Employment" if event_ln_emp_20b_nonrtwborder==1
replace type="Serv Employment" if event_ln_emp_70b_nonrtwborder==1
replace type="Total Establishments" if event_ln_est_nonrtwborder==1
replace type="Manuf Establishments" if event_ln_est_20_nonrtwborder==1
replace type="Serv Establishments" if event_ln_est_70_nonrtwborder==1
replace type="Small Establishments" if event_ln_small_est_nonrtwborder==1
replace type="Medium Establishments" if event_ln_medium_est_nonrtwborder==1
replace type="Large Establishments" if event_ln_large_est_nonrtwborder==1

gen kind=1 if type=="Total Employment"
	replace kind=2 if type=="Manuf Employment"
	replace kind=3 if type=="Serv Employment"
	replace kind=4 if type=="Total Establishments"
	replace kind=5 if type=="Manuf Establishments"
	replace kind=6 if type=="Serv Establishments"
	replace kind=7 if type=="Small Establishments"
	replace kind=8 if type=="Medium Establishments"
	replace kind=9 if type=="Large Establishments"
	
keep if strpos(parm, "event_border_rtw_2")

gen eventyear=1 if parm=="0.event_border_rtw_2"
replace eventyear=2 if parm=="1.event_border_rtw_2"
replace eventyear=3 if parm=="2.event_border_rtw_2"
replace eventyear=4 if parm=="3.event_border_rtw_2"
replace eventyear=5 if parm=="4.event_border_rtw_2"
replace eventyear=6 if parm=="5.event_border_rtw_2"
replace eventyear=7 if parm=="6.event_border_rtw_2"
replace eventyear=8 if parm=="7.event_border_rtw_2"
replace eventyear=9 if parm=="8.event_border_rtw_2"
replace eventyear=10 if parm=="9.event_border_rtw_2"
replace eventyear=11 if parm=="10.event_border_rtw_2"
replace eventyear=12 if parm=="11.event_border_rtw_2"
replace eventyear=13 if parm=="12.event_border_rtw_2"
replace eventyear=14 if parm=="13.event_border_rtw_2"
replace eventyear=15 if parm=="14.event_border_rtw_2"
replace eventyear=16 if parm=="15.event_border_rtw_2"
replace eventyear=17 if parm=="16.event_border_rtw_2"
replace eventyear=18 if parm=="17.event_border_rtw_2"
replace eventyear=19 if parm=="18.event_border_rtw_2"
replace eventyear=20 if parm=="19.event_border_rtw_2"
replace eventyear=21 if parm=="20.event_border_rtw_2"
replace eventyear=22 if parm=="21.event_border_rtw_2"
replace eventyear=23 if parm=="22.event_border_rtw_2"
replace eventyear=24 if parm=="23.event_border_rtw_2"
replace eventyear=25 if parm=="24.event_border_rtw_2"
replace eventyear=26 if parm=="25.event_border_rtw_2"
replace eventyear=27 if parm=="26.event_border_rtw_2"
replace eventyear=28 if parm=="27.event_border_rtw_2"
replace eventyear=29 if parm=="28.event_border_rtw_2"
replace eventyear=30 if parm=="29b.event_border_rtw_2"
replace eventyear=31 if parm=="30.event_border_rtw_2"
replace eventyear=32 if parm=="31.event_border_rtw_2"
replace eventyear=33 if parm=="32.event_border_rtw_2"
replace eventyear=34 if parm=="33.event_border_rtw_2"
replace eventyear=35 if parm=="34.event_border_rtw_2"
replace eventyear=36 if parm=="35.event_border_rtw_2"
replace eventyear=37 if parm=="36.event_border_rtw_2"
replace eventyear=38 if parm=="37.event_border_rtw_2"
replace eventyear=39 if parm=="38.event_border_rtw_2"
replace eventyear=40 if parm=="39.event_border_rtw_2"
replace eventyear=41 if parm=="40.event_border_rtw_2"
replace eventyear=42 if parm=="41.event_border_rtw_2"
replace eventyear=43 if parm=="42.event_border_rtw_2"
replace eventyear=44 if parm=="43.event_border_rtw_2"
replace eventyear=45 if parm=="44.event_border_rtw_2"
replace eventyear=46 if parm=="45.event_border_rtw_2"
replace eventyear=47 if parm=="46.event_border_rtw_2"
replace eventyear=48 if parm=="47.event_border_rtw_2"
replace eventyear=49 if parm=="48.event_border_rtw_2"
replace eventyear=50 if parm=="49.event_border_rtw_2"
replace eventyear=51 if parm=="50.event_border_rtw_2"
replace eventyear=52 if parm=="51.event_border_rtw_2"
replace eventyear=53 if parm=="52.event_border_rtw_2"
replace eventyear=54 if parm=="53.event_border_rtw_2"
replace eventyear=55 if parm=="54.event_border_rtw_2"
replace eventyear=56 if parm=="55.event_border_rtw_2"
replace eventyear=57 if parm=="56.event_border_rtw_2"
replace eventyear=58 if parm=="57.event_border_rtw_2"
replace eventyear=59 if parm=="58.event_border_rtw_2"
replace eventyear=60 if parm=="59.event_border_rtw_2"
replace eventyear=61 if parm=="60.event_border_rtw_2"
replace eventyear=62 if parm=="61.event_border_rtw_2"
replace eventyear=63 if parm=="62.event_border_rtw_2"
replace eventyear=64 if parm=="63.event_border_rtw_2"
replace eventyear=65 if parm=="64.event_border_rtw_2"
replace eventyear=66 if parm=="65.event_border_rtw_2"
replace eventyear=67 if parm=="66.event_border_rtw_2"
replace eventyear=68 if parm=="67.event_border_rtw_2"
replace eventyear=69 if parm=="68.event_border_rtw_2"
replace eventyear=70 if parm=="69.event_border_rtw_2"
replace eventyear=71 if parm=="70.event_border_rtw_2"
replace eventyear=72 if parm=="71.event_border_rtw_2"
replace eventyear=73 if parm=="72.event_border_rtw_2"
replace eventyear=74 if parm=="73.event_border_rtw_2"
replace eventyear=75 if parm=="74.event_border_rtw_2"
replace eventyear=76 if parm=="75.event_border_rtw_2"
replace eventyear=77 if parm=="76.event_border_rtw_2"
replace eventyear=78 if parm=="77.event_border_rtw_2"
replace eventyear=79 if parm=="78.event_border_rtw_2"
replace eventyear=80 if parm=="79.event_border_rtw_2"
replace eventyear=81 if parm=="80.event_border_rtw_2"

la def kindlab 1"Total Employment"2"Manuf. Employment"3"Service Employment"4"Total Establishments"5"Manuf. Establishments"6"Service Establishments"7"Small Establishments"8"Medium Establishments"9"Large Establishments"
la val kind kindlab


gl vars "estimate stderr t min95 max95"

foreach var in $vars {
	
	replace `var'=0 if parm=="29b.event_border_rtw_2"
	
		}
				
gen double eventyear2=eventyear
drop eventyear
ren eventyear2 eventyear


sort kind eventyear


graph twoway (line max95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || (line min95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || ///
	(line estimate eventyear, mc(cranberry) lc(cranberry) lp(solid)) || if kind<=3, ///
	by(kind, note("") legend(off) cols(3) yr) yline(0, lc(black)) xline(30, lp(dash) lc(black)) xtitle("") ///
	xlab(1 "T<=-30" 2 "." 3 "." 4 "." 5 "." 6 "." 7 "." 8 "." 9 "." 10 "." 11 "T-20" 12 "." 13 "." 14 "." 15 "." 16 "." 17 "." 18 "." 19 "." 20 "." ///
		 21 "T-10" 22 "." 23 "." 24 "." 25 "." 26 "." 27 "." 28 "." 29 "." 30 "." 31 "RTW" 32 "." 33 "." 34 "." 35 "." 36 "." 37 "." 38 "." 39 "." 40 "." ///
		 41 "T+10" 42 "." 43 "." 44 "." 45 "." 46 "." 47 "." 48 "." 49 "." 50 "." 51 "T+20" 52 "." 53 "." 54 "." 55 "." 56 "." 57 "." 58 "." 59 "." 60 "." 61 "T+30" ///
		 62 "." 63 "." 64 "." 65 "." 66 "." 67 "." 68 "." 69 "." 70 "." 71 "T+40" 72 "." 73 "." 74 "." 75 "." 76 "." 77 "." 78 "." 79 "." 80 "." 81 "T>=+50", nogrid) ///
		 xlab(, angle(90)) ///
	ytitle("") ylab(-0.5(0.25)0.5, nogrid) ///
	legend(position(7) ring(0)) xsize(1) ysize(3)

gr save "Output\Intermediate\Event_Study_DropNegObs_Emp_All_Years_BorderNonRTW_`c(current_date)'.gph", replace
gr export "Output\Intermediate\Event_Study_DropNegObs_Emp_All_Years_BorderNonRTW_`c(current_date)'.png", replace


graph twoway (line max95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || (line min95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || ///
	(line estimate eventyear, mc(cranberry) lc(cranberry) lp(solid)) || if kind>3 & kind<=6, ///
	by(kind, note("") legend(off) cols(3) yr) yline(0, lc(black)) xline(30, lp(dash) lc(black)) xtitle("") ///
	xlab(1 "T<=-30" 2 "." 3 "." 4 "." 5 "." 6 "." 7 "." 8 "." 9 "." 10 "." 11 "T-20" 12 "." 13 "." 14 "." 15 "." 16 "." 17 "." 18 "." 19 "." 20 "." ///
		 21 "T-10" 22 "." 23 "." 24 "." 25 "." 26 "." 27 "." 28 "." 29 "." 30 "." 31 "RTW" 32 "." 33 "." 34 "." 35 "." 36 "." 37 "." 38 "." 39 "." 40 "." ///
		 41 "T+10" 42 "." 43 "." 44 "." 45 "." 46 "." 47 "." 48 "." 49 "." 50 "." 51 "T+20" 52 "." 53 "." 54 "." 55 "." 56 "." 57 "." 58 "." 59 "." 60 "." 61 "T+30" ///
		 62 "." 63 "." 64 "." 65 "." 66 "." 67 "." 68 "." 69 "." 70 "." 71 "T+40" 72 "." 73 "." 74 "." 75 "." 76 "." 77 "." 78 "." 79 "." 80 "." 81 "T>=+50", nogrid) ///
		 xlab(, angle(90)) ///
	ytitle("") ylab(-0.5(0.25)0.5, nogrid) ///
	legend(position(7) ring(0)) xsize(1) ysize(3)

gr save "Output\Intermediate\Event_Study_DropNegObs_Est_1_All_Years_BorderNonRTW_`c(current_date)'.gph", replace
gr export "Output\Intermediate\Event_Study_DropNegObs_Est_1_All_Years_BorderNonRTW_`c(current_date)'.png", replace


graph twoway (line max95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || (line min95 eventyear, mc(cranberry) lc(cranberry) lp(shortdash)) || ///
	(line estimate eventyear, mc(cranberry) lc(cranberry) lp(solid)) || if kind>=7, ///
	by(kind, note("") legend(off) cols(3) yr) yline(0, lc(black)) xline(30, lp(dash) lc(black)) xtitle("") ///
	xlab(1 "T<=-30" 2 "." 3 "." 4 "." 5 "." 6 "." 7 "." 8 "." 9 "." 10 "." 11 "T-20" 12 "." 13 "." 14 "." 15 "." 16 "." 17 "." 18 "." 19 "." 20 "." ///
		 21 "T-10" 22 "." 23 "." 24 "." 25 "." 26 "." 27 "." 28 "." 29 "." 30 "." 31 "RTW" 32 "." 33 "." 34 "." 35 "." 36 "." 37 "." 38 "." 39 "." 40 "." ///
		 41 "T+10" 42 "." 43 "." 44 "." 45 "." 46 "." 47 "." 48 "." 49 "." 50 "." 51 "T+20" 52 "." 53 "." 54 "." 55 "." 56 "." 57 "." 58 "." 59 "." 60 "." 61 "T+30" ///
		 62 "." 63 "." 64 "." 65 "." 66 "." 67 "." 68 "." 69 "." 70 "." 71 "T+40" 72 "." 73 "." 74 "." 75 "." 76 "." 77 "." 78 "." 79 "." 80 "." 81 "T>=+50", nogrid) ///
		 xlab(, angle(90)) ///
	ytitle("") ylab(-0.5(0.25)0.5, nogrid) ///
	legend(position(7) ring(0)) xsize(1) ysize(3)

gr save "Output\Intermediate\Event_Study_DropNegObs_Est_2_All_Years_BorderNonRTW_`c(current_date)'.gph", replace
gr export "Output\Intermediate\Event_Study_DropNegObs_Est_2_All_Years_BorderNonRTW_`c(current_date)'.png", replace

restore


gr combine "Output\Intermediate\Event_Study_DropNegObs_Emp_All_Years_BorderNonRTW_`c(current_date)'.gph" "Output\Intermediate\Event_Study_DropNegObs_Est_1_All_Years_BorderNonRTW_`c(current_date)'.gph" "Output\Intermediate\Event_Study_DropNegObs_Est_2_All_Years_BorderNonRTW_`c(current_date)'.gph", col(1) ysize(8) xsize(8) ///
		imargin(0 0) iscale(0.5) ///
		l1("%-Point Difference vs. Year Before RTW", size(vsmall)) b1("Years Since RTW Passage", size(vsmall))

gr save "Output\Figure_S2_`c(current_date)'.gph", replace
gr export "Output\Figure_S2_`c(current_date)'.png", replace
gr export "Output\Figure_S2_`c(current_date)'.svg", replace
gr export "Output\Figure_S2_`c(current_date)'.pdf", replace



**************************************************************************************************************************************
** Tax data descriptives (Table S5)

** Descriptives for border-pair sample for BEA and Upjohn tax measures (county-border pair sample)

use "Data\working_border_county_panel.dta", clear	

eststo full: estpost sum tx_minus_sub_cpi ln_tx_minus_sub_cpi net_gdp net_pc nettax if sample4==1 & ln_deccountypop_ipo!=., d

eststo rtw: estpost sum tx_minus_sub_cpi ln_tx_minus_sub_cpi net_gdp net_pc nettax if sample4==1 & ln_deccountypop_ipo!=. & rtw==1, d
		
eststo non: estpost sum tx_minus_sub_cpi ln_tx_minus_sub_cpi net_gdp net_pc nettax if sample4==1 & ln_deccountypop_ipo!=. & rtw==0, d		
		
esttab full rtw non using "Output\Table_S5_Border_`c(current_date)'.csv", ///
	replace cells ("mean(pattern(1) fmt(1 1 1)) p50(pattern(1 1 1) fmt(1)) sd(pattern(1 1 1) fmt(1)) min(pattern(1 1 1) fmt(1)) max(pattern(1 1 1) fmt(1))")  ///
	label title (Descriptives) nonumbers mtitles ("Full sample" "RTW" "Non-RTW")
	
	
** Descriptives for all county sample for BEA and Upjohn tax measures (all county sample)

use "Data\working_all_county_panel.dta", clear


eststo full: estpost sum tx_minus_sub_cpi ln_tx_minus_sub_cpi net_gdp net_pc nettax if sample2==1 & ln_deccountypop_ipo!=., d
						 						 
eststo rtw: estpost sum tx_minus_sub_cpi ln_tx_minus_sub_cpi net_gdp net_pc nettax if sample2==1 & ln_deccountypop_ipo!=. & rtw==1, d

eststo non: estpost sum tx_minus_sub_cpi ln_tx_minus_sub_cpi net_gdp net_pc nettax if sample2==1 & ln_deccountypop_ipo!=. & rtw==0, d
												 
												 
esttab full rtw non using "Output\Table_S5_All_County_`c(current_date)'.csv", ///
	replace cells ("mean(pattern(1 1 1) fmt(1)) p50(pattern(1 1 1) fmt(1)) sd(pattern(1 1 1) fmt(1)) min(pattern(1 1 1) fmt(1)) max(pattern(1 1 1) fmt(1))")  ///
	label title (Descriptives) nonumbers mtitles ("Full sample" "RTW" "Non-RTW")


	
	
******************************************************************************************************************************************
** Test main RTW --> Economic Dynamism Models including controls for right-leaning state economic policy (Caughey and Warshaw 2016)

* To include in conditional accept response memo


* county-border pair FE models
use "Data\working_border_county_panel.dta", clear


// Log of employment - Table 2 (Panels A, C, and E)
rifhdreg ln_empb i.rtw ln_deccountypop_ipo policy_updated_economic if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S6_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label replace

rifhdreg ln_emp_20b i.rtw ln_deccountypop_ipo policy_updated_economic if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S6_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_emp_70b i.rtw ln_deccountypop_ipo policy_updated_economic if sample3==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S6_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append


// Log of establishments - Table 2 (Panels B, D, and F)
rifhdreg ln_est i.rtw ln_deccountypop_ipo policy_updated_economic if sample4==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S6_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_est_20 i.rtw ln_deccountypop_ipo policy_updated_economic if sample4==1 &  negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S6_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_est_70 i.rtw ln_deccountypop_ipo policy_updated_economic if sample4==1 &  negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S6_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append


// Log of establishments by size - Table 3 (Panels A, B, and C)
rifhdreg ln_small_est i.rtw ln_deccountypop_ipo policy_updated_economic if sample4==1 &  negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S6_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_medium_est i.rtw ln_deccountypop_ipo policy_updated_economic if sample4==1 &  negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S6_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append

rifhdreg ln_large_est i.rtw ln_deccountypop_ipo policy_updated_economic if sample4==1 & negtreatmentwtsb==0, rif(mean) abs(cntyid cbp_period) vce(cluster bordersegment)

outreg2 using "Output\Table_S6_`c(current_date)'.xls", ///
excel auto(3) dec(4) sdec(4) 2aster alpha (.001, .01, .05, .1) symbol (***, **, *, +) label append





