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

local expratelbl : variable label exprate
local currentratelbl : variable label currentrate
local realratelbl : variable label realrate

generate actgrowth = realrate - currentrate

capture drop date
gen date = mdy(month, 1, survey)
format date %td
gen modate = mofd(date)
format modate %tm

* TODO : COMBINE GRAPHS WITH MATRICES
* i have aggregated yearly data to monthly data where the month was missing
* could be nice to separate monthly households from 
preserve
collapse (mean) mortexp2y actgrowth (median) mortexp2y_med = mortexp2y actgrowth_med = actgrowth [pw=wgth], by(modate)
drop if missing(mortexp2y) == 1 | missing(actgrowth) == 1


restore

preserve
collapse (mean) currentrate exprate realrate (median) currentrate_med = currentrate exprate_med = exprate realrate_med = realrate [pw=wgth], by(survey)

drop if missing(currentrate) == 1 | missing(exprate) == 1 | missing(realrate) == 1

qui sum survey, meanonly
local minwave = `r(min)'
local maxwave = `r(max)'

local vardesc1 : variable label survey

twoway line currentrate survey, lwidth(medthick) || line exprate survey, lwidth(medthick) || line realrate survey, lwidth(medthick) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(hor)) subtitle(, size(vsmall)) legend(size(vsmall) symxsize(8) col(1) label(1 "`currentratelbl'") label(2 "`expratelbl'") label(3 "`realratelbl'")) title("Expectations on mortgages interest rates in two years of Dutch households", size(small)) subtitle("by `vardesc1', mean percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))

twoway line currentrate_med survey || line exprate_med survey || line realrate_med survey, lwidth(medthick) ytitle("") xtitle("") yla(#10, labsize(vsmall) angle(hor)) xla(`minwave'(1)`maxwave', labsize(vsmall) angle(hor)) subtitle(, size(vsmall)) legend(size(vsmall) symxsize(8) col(1) label(1 "`currentratelbl'") label(2 "`expratelbl'") label(3 "`realratelbl'")) title("Expectations on mortgages interest rates in two years of Dutch households", size(small)) subtitle("by `vardesc1', median percent", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. ECB Statistical Data Warehouse (SDW).", size(vsmall) linegap(*2.5))

