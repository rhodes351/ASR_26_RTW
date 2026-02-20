capture log close
version 18
clear all
set linesize 80
macro drop _all
set scheme stgcolor

local pgm pcd-epi-productivity

local date: display %td_CCYY_NN_DD date(c(current_date), "DMY")
local dte = subinstr(trim("`date'"), " " , "-", .)
local time = c(current_time) 
local time = subinstr("`time'",":","",.)
log using `pgm', replace text
di "`pgm' ran `dte'- `time'"
 
//  task:   load productivity data, estimate simple regressions
//  note:      
//  project: 

// 1 Load Data

use epi-productivity, clear

// 2 Simple regressions

* basic
reg productivity i.year i.statefip i.rtw  lnpop ,  cluster(statefip)
eststo m1a
reg productivity i.year  i.statefip i.rtw lnpop if drop == 0,  cluster(statefip)
eststo m1b
reg productivity i.year i.statefip isagric_ipo isflp_ipo pctcol_ipo ispubemp_ipo isunemp_ipo isold_ipo c.ismanuf_ipo stateunion i.rtw  lnpop ,  cluster(statefip)
eststo m2a
reg productivity i.year  i.statefip isagric_ipo isflp_ipo pctcol_ipo ispubemp_ipo isunemp_ipo isold_ipo c.ismanuf_ipo stateunion i.rtw lnpop if drop == 0,  cluster(statefip)
eststo m2b
* region-year
reg productivity i.group i.statefip i.rtw lnpop,  cluster(statefip)
eststo m3a
reg productivity i.group  i.statefip i.rtw lnpop if drop == 0 ,  cluster(statefip)
eststo m3b
reg productivity i.group  isagric_ipo isflp_ipo pctcol_ipo ispubemp_ipo isunemp_ipo isold_ipo c.ismanuf_ipo stateunion i.statefip i.rtw lnpop,  cluster(statefip)
eststo m4a
reg productivity i.group isagric_ipo isflp_ipo pctcol_ipo ispubemp_ipo isunemp_ipo isold_ipo c.ismanuf_ipo stateunion  i.statefip i.rtw lnpop if drop == 0 ,  cluster(statefip)
eststo m4b
* region year + state traj.
reghdfe productivity  i.year i.rtw lnpop  , abs(i.statefip##c.year) cluster(statefip)
eststo m5a
reghdfe productivity  i.year i.rtw lnpop if drop == 0 , abs(i.statefip##c.year) cluster(statefip)
eststo m5b
reghdfe productivity  i.year i.rtw isagric_ipo isflp_ipo pctcol_ipo ispubemp_ipo isunemp_ipo isold_ipo c.ismanuf_ipo stateunion lnpop  , abs(i.statefip##c.year) cluster(statefip)
eststo m6a
reghdfe productivity  i.year i.rtw isagric_ipo isflp_ipo pctcol_ipo ispubemp_ipo isunemp_ipo isold_ipo c.ismanuf_ipo stateunion lnpop if drop == 0 , abs(i.statefip##c.year) cluster(statefip)
eststo m6b

esttab m* using `pgm'.csv, keep(1.rtw) se replace

log close
exit
