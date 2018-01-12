* start looking at the wod52b, mortexp2y

capture drop date
gen date = mdy(month, 1, survey)
format date %td

merge m:1 date using "${DATA}/mortrseriesSDW.dta"
drop if _m == 2
drop _m
rename loanstohholds currentrate

merge m:1 survey using "${DATA}/mortrseriesSDWy.dta"
drop if _m == 2
rename loanstohholdsy currentratey
replace currentrate = currentratey if missing(currentrate) == 1
drop _m currentratey

gen exprate = currentrate + mortexp2y
label variable exprate "expected mortgage interest rates in two years on survey basis"
compress

save "${DATA}/dhs_aggr.dta", replace

use "${DATA}/mortrseriesSDW.dta", replace
gen m = month(date)
gen y = year(date)
replace y = y - 2
gen newdate = mdy(m, 1, y)
drop m y date
rename newdate date
sort date
tsset date
format date %td
tab date
order date loanstohholds
label variable loanstohholds "bank interest rates after two years, loans to households for house purchase"

merge 1:m date using "${DATA}/dhs_aggr.dta"
drop if _m == 1
drop _m
sort survey nohhold nomem
order nohhold nomem survey date loanstohholds
rename loanstohholds realrate

save "${DATA}/dhs_aggr.dta", replace

use "${DATA}/mortrseriesSDWy.dta", replace
replace survey = survey - 2
label variable loanstohholdsy "bank interest rates in two years, loans to households for house purchase"
merge 1:m survey using "${DATA}/dhs_aggr.dta"
drop if _m == 1
replace realrate = loanstohholdsy if missing(realrate) == 1
drop date loanstohholdsy _m
order nohhold nomem survey currentrate exprate realrate
sort survey nohhold nomem

label variable survey "dhs wave"

save "${DATA}/dhs_aggr.dta", replace

* this creates missing values but it is fine
generate actgrowth = realrate - currentrate
label variable actgrowth "percentage points of bank interest rates variation in two years, loans to households for house purchase"

local expratelbl     : variable label exprate
local currentratelbl : variable label currentrate
local realratelbl    : variable label realrate
local mortexp2ylbl   : variable label mortexp2y
local actgrowthlbl   : variable label actgrowth

* capture drop date
* gen date = mdy(month, 1, survey)
* format date %td
* gen modate = mofd(date)
* format modate %tm

* TODO : COMBINE GRAPHS WITH MATRICES
* i have aggregated yearly data to monthly data where the month was missing
* could be nice to separate monthly households from yearly households and
* to create a factoring error

preserve
collapse (mean) mortexp2y actgrowth (median) mortexp2y_med = mortexp2y actgrowth_med = actgrowth [pw=wgth], by(survey)
drop if missing(mortexp2y) == 1 | missing(actgrowth) == 1

qui sum survey, meanonly
local minwave = `r(min)'
local maxwave = `r(max)'

local vardesc1 : variable label survey

twoway line mortexp2y survey, lwidth(medthick) || line actgrowth survey, lwidth(medthick) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(hor)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1', mean percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))
* graph export "${GRAPHS}/wod52bm_tot.${GRAPHFORMAT}", replace

twoway line mortexp2y_med survey, lwidth(medthick) || line actgrowth_med survey, lwidth(medthick) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(hor)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1', median percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))
* graph export "${GRAPHS}/wod52bmed_tot.${GRAPHFORMAT}", replace

restore

preserve
collapse (mean) mortexp2y actgrowth (median) mortexp2y_med = mortexp2y actgrowth_med = actgrowth [pw=wgth], by(incqtile survey)
drop if missing(mortexp2y) == 1 | missing(actgrowth) == 1

qui sum survey, meanonly
local minwave = `r(min)'
local maxwave = `r(max)'

local vardesc1 : variable label survey
local vardesc2 : variable label incqtile

twoway line mortexp2y survey, lwidth(medthick) || line actgrowth survey, lwidth(medthick) by(incqtile, title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2', mean percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(45)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) subtitle(, size(vsmall))
* graph export "${GRAPHS}/wod52bm_inc.${GRAPHFORMAT}", replace

twoway line mortexp2y_med survey, lwidth(medthick) || line actgrowth_med survey, lwidth(medthick) by(incqtile, title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2', median percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(45)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) subtitle(, size(vsmall))
* graph export "${GRAPHS}/wod52bmed_inc.${GRAPHFORMAT}", replace
restore

preserve
collapse (mean) mortexp2y actgrowth (median) mortexp2y_med = mortexp2y actgrowth_med = actgrowth [pw=wgth], by(nwqtile survey)
drop if missing(mortexp2y) == 1 | missing(actgrowth) == 1

qui sum survey, meanonly
local minwave = `r(min)'
local maxwave = `r(max)'

local vardesc1 : variable label survey
local vardesc2 : variable label nwqtile

twoway line mortexp2y survey, lwidth(medthick) || line actgrowth survey, lwidth(medthick) by(nwqtile, title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2', mean percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(45)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) subtitle(, size(vsmall))
* graph export "${GRAPHS}/wod52bm_nw.${GRAPHFORMAT}", replace

twoway line mortexp2y_med survey, lwidth(medthick) || line actgrowth_med survey, lwidth(medthick) by(nwqtile, title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2', median percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(45)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) subtitle(, size(vsmall))
* graph export "${GRAPHS}/wod52bmed_nw.${GRAPHFORMAT}", replace

restore

preserve
local vardesc2 : variable label age

collapse (mean) mortexp2y actgrowth (median) mortexp2y_med = mortexp2y actgrowth_med = actgrowth [pw=wgth], by(ageb survey)
drop if missing(mortexp2y) == 1 | missing(actgrowth) == 1

qui sum survey, meanonly
local minwave = `r(min)'
local maxwave = `r(max)'

local vardesc1 : variable label survey

twoway line mortexp2y survey, lwidth(medthick) || line actgrowth survey, lwidth(medthick) by(ageb, title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2', mean percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(45)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) subtitle(, size(vsmall))
* graph export "${GRAPHS}/wod52bm_age.${GRAPHFORMAT}", replace

twoway line mortexp2y_med survey, lwidth(medthick) || line actgrowth_med survey, lwidth(medthick) by(ageb, title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2', median percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(45)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) subtitle(, size(vsmall))
* graph export "${GRAPHS}/wod52bmed_age.${GRAPHFORMAT}", replace

restore

preserve
local vardesc2 : variable label oplzonb

collapse (mean) mortexp2y actgrowth (median) mortexp2y_med = mortexp2y actgrowth_med = actgrowth [pw=wgth], by(educ survey)
drop if missing(mortexp2y) == 1 | missing(actgrowth) == 1

qui sum survey, meanonly
local minwave = `r(min)'
local maxwave = `r(max)'

local vardesc1 : variable label survey

twoway line mortexp2y survey, lwidth(medthick) || line actgrowth survey, lwidth(medthick) by(educ, title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2', mean percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(45)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) subtitle(, size(vsmall))
* graph export "${GRAPHS}/wod52bm_educ.${GRAPHFORMAT}", replace

twoway line mortexp2y_med survey, lwidth(medthick) || line actgrowth_med survey, lwidth(medthick) by(educ, title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2', median percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(45)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) subtitle(, size(vsmall))
* graph export "${GRAPHS}/wod52bmed_educ.${GRAPHFORMAT}", replace

restore

preserve
collapse (mean) mortexp2y actgrowth (median) mortexp2y_med = mortexp2y actgrowth_med = actgrowth [pw=wgth], by(empl survey)
drop if missing(mortexp2y) == 1 | missing(actgrowth) == 1

qui sum survey, meanonly
local minwave = `r(min)'
local maxwave = `r(max)'

local vardesc1 : variable label survey
local vardesc2 : variable label empl

twoway line mortexp2y survey, lwidth(medthick) || line actgrowth survey, lwidth(medthick) by(empl, title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2', mean percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(45)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) subtitle(, size(vsmall))
* graph export "${GRAPHS}/wod52bm_empl.${GRAPHFORMAT}", replace

twoway line mortexp2y_med survey, lwidth(medthick) || line actgrowth_med survey, lwidth(medthick) by(empl, title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2', median percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(45)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) subtitle(, size(vsmall))
* graph export "${GRAPHS}/wod52bmed_empl.${GRAPHFORMAT}", replace

restore

preserve
collapse (mean) mortexp2y actgrowth (median) mortexp2y_med = mortexp2y actgrowth_med = actgrowth [pw=wgth], by(tenant survey)
drop if missing(mortexp2y) == 1 | missing(actgrowth) == 1

qui sum survey, meanonly
local minwave = `r(min)'
local maxwave = `r(max)'

local vardesc1 : variable label survey
local vardesc2 : variable label tenant

twoway line mortexp2y survey, lwidth(medthick) || line actgrowth survey, lwidth(medthick) by(tenant, title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2', mean percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(45)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) subtitle(, size(vsmall))
* graph export "${GRAPHS}/wod52bm_tenant.${GRAPHFORMAT}", replace

twoway line mortexp2y_med survey, lwidth(medthick) || line actgrowth_med survey, lwidth(medthick) by(tenant, title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2', median percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(45)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) subtitle(, size(vsmall))
* graph export "${GRAPHS}/wod52bmed_tenant.${GRAPHFORMAT}", replace

restore

preserve
collapse (mean) mortexp2y actgrowth (median) mortexp2y_med = mortexp2y actgrowth_med = actgrowth [pw=wgth], by(mortowners survey)
drop if missing(mortexp2y) == 1 | missing(actgrowth) == 1

qui sum survey, meanonly
local minwave = `r(min)'
local maxwave = `r(max)'

local vardesc1 : variable label survey
local vardesc2 : variable label mortowners

twoway line mortexp2y survey, lwidth(medthick) || line actgrowth survey, lwidth(medthick) by(mortowners, title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2', mean percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(45)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) subtitle(, size(vsmall))
* graph export "${GRAPHS}/wod52bm_mortown.${GRAPHFORMAT}", replace

twoway line mortexp2y_med survey, lwidth(medthick) || line actgrowth_med survey, lwidth(medthick) by(mortowners, title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2', median percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(45)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) subtitle(, size(vsmall))
* graph export "${GRAPHS}/wod52bmed_mortown.${GRAPHFORMAT}", replace

restore

preserve
collapse (mean) mortexp2y actgrowth (median) mortexp2y_med = mortexp2y actgrowth_med = actgrowth [pw=wgth], by(housestatus survey)
drop if missing(mortexp2y) == 1 | missing(actgrowth) == 1

qui sum survey, meanonly
local minwave = `r(min)'
local maxwave = `r(max)'

local vardesc1 : variable label survey
local vardesc2 : variable label housestatus

twoway line mortexp2y survey, lwidth(medthick) || line actgrowth survey, lwidth(medthick) by(housestatus, title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2', mean percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(45)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) subtitle(, size(vsmall))
* graph export "${GRAPHS}/wod52bm_house.${GRAPHFORMAT}", replace

twoway line mortexp2y_med survey, lwidth(medthick) || line actgrowth_med survey, lwidth(medthick) by(housestatus, title("Expectations on mortgages interest rates' growth in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2', median percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(45)) legend(size(vsmall) symxsize(8) col(1) label(1 "`mortexp2ylbl'") label(2 "`actgrowthlbl'")) subtitle(, size(vsmall))
* graph export "${GRAPHS}/wod52bmed_house.${GRAPHFORMAT}", replace

restore

**************************************************************


