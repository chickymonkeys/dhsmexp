clear all

odbc query "sdw64", user(pub) password(pub)

odbc load, exec("SELECT max(period_name) period_name ,max(decode(series_key, 'MIR.M.NL.B.A22.A.R.A.2250.EUR.O',obs_value,null)) val_NL_A FROM (SELECT FIRST_DATE OBS_DATE, period_name, a.SERIES_KEY, a.OBS_VALUE FROM ESDB_PUB.V_MIR_OBS_PLAIN a,common.period_dim b WHERE a.period_id = b.period_id  AND SERIES_KEY IN ('MIR.M.NL.B.A22.A.R.A.2250.EUR.O') ) group by obs_date order by obs_date ") dsn("sdw64") user(pub) password(pub)

rename PERIOD_NAME freq
label variable freq "monthly frequency"
rename VAL_NL_A loanstohholds
label variable loanstohholds "current bank interest rates, loans to households for house purchase"
clonevar month2 = freq
replace month2 = month2 + "01"
gen date = date(month2, "YMD")
drop month2
format date %td
sort date
tsset date
drop freq
order date loanstohholds

global DATA "P:/ECB business areas/DGR/Databases and Programme files/DGR/Alessandro Pizzigolotto/dimitris/dhsmexp/data/sets"

save "${DATA}/mortrseriesSDW.dta", replace

* if missing we assign the average of the months to get the annual level
* we create another dataset for that? same, but different merge after
generate year = year(date)
format year %ty
bysort year : egen loanstohholdsy = mean(loanstohholds)
duplicates drop year, force
keep year loanstohholdsy
rename year survey
tsset survey
order survey loanstohholdsy

save "${DATA}/mortrseriesSDWy.dta", replace
