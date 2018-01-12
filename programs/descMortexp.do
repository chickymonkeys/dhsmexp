local legendmortexpi  label(1 "lower than now") label(2 "just as high as now") label(3 "higher than now")
local legendhowners   label(1 "tenant") label(2 "home-owner without mortgage") label(3 "home-owner with mortgage")
local legendquintiles label(1 "1st quintile") label(2 "2nd quintile") label(3 "3rd quintile") label(4 "4th quintile") label(5 "5th quintile")
local legendage       label(1 "16-34") label(2 "35-44") label(3 "45-54") label(4 "55-64") label(5 "65-74") label(6 "75+")
local legendeduc      label(1 "Primary") label(2 "Secondary") label(3 "Tertiary")
local legendlabour    label(1 "Employed") label(2 "Self-Employed") label(3 "Retired") label(4 "Other not working")

local vardesc : variable label survey

graph bar mortexpl mortexps mortexph [pw=wgth], over(survey, label(labsize(vsmall))) stack legend(size(vsmall) symxsize(4) row(1) `legendmortexpi') ytitle("") yla(#10, labsize(vsmall) angle(hor)) title("Expectations on mortgages interest rates in two years of Dutch households", size(small)) subtitle("by `vardesc'", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017.", size(vsmall) linegap(*2.5))
graph export "${GRAPHS}/wod52a_tot.${GRAPHFORMAT}", replace

local vardesc2 : variable label incqtile
local vardesc1 : variable label survey

graph bar mortexpl mortexps mortexph [pw=wgth], over(incqtile, relabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5") label(labsize(vsmall))) over(survey, label(labsize(vsmall))) stack legend(size(vsmall) symxsize(4) row(1) `legendmortexpi') ytitle("") yla(#10, labsize(vsmall) angle(hor)) title("Expectations on mortgages interest rates in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2'", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017.", size(vsmall) linegap(*2.5))
graph export "${GRAPHS}/wod52a_inc.${GRAPHFORMAT}", replace

local vardesc2 : variable label nwqtile
local vardesc1 : variable label survey

graph bar mortexpl mortexps mortexph [pw=wgth], over(nwqtile, relabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5") label(labsize(vsmall))) over(survey, label(labsize(vsmall))) stack legend(size(vsmall) symxsize(4) row(1) `legendmortexpi') ytitle("") yla(#10, labsize(vsmall) angle(hor)) title("Expectations on mortgages interest rates in two years of Dutch households", size(small)) subtitle("by `vardesc1' and tenant status", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017.", size(vsmall) linegap(*2.5))
graph export "${GRAPHS}/wod52a_nw.${GRAPHFORMAT}", replace

local vardesc2 : variable label age
local vardesc1 : variable label survey

graph bar mortexpl mortexps mortexph [pw=wgth], over(ageb, label(labsize(tiny) angle(90))) over(survey, label(labsize(vsmall))) stack legend(size(vsmall) symxsize(4) row(1) `legendmortexpi') ytitle("") yla(#10, labsize(vsmall) angle(hor)) title("Expectations on mortgages interest rates in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2'", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017.", size(vsmall) linegap(*2.5))
graph export "${GRAPHS}/wod52a_age.${GRAPHFORMAT}", replace

local vardesc2 : variable label oplzonb
local vardesc1 : variable label survey

graph bar mortexpl mortexps mortexph [pw=wgth], over(oplzonb, relabel(1 "Basic" 2 "Secondary" 3 "Tertiary") label(labsize(vsmall) angle(45))) over(survey, label(labsize(vsmall))) stack legend(size(vsmall) symxsize(4) row(1) `legendmortexpi') ytitle("") yla(#10, labsize(vsmall) angle(hor)) title("Expectations on mortgages interest rates in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2'", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017.", size(vsmall) linegap(*2.5))
graph export "${GRAPHS}/wod52a_educ.${GRAPHFORMAT}", replace

local vardesc2 : variable label empl
local vardesc1 : variable label survey

graph bar mortexpl mortexps mortexph [pw=wgth], over(empl, relabel(1 "Employed" 2 "Self-Employed" 3 "Retired" 4 "Other") label(labsize(tiny) angle(90))) over(survey, label(labsize(vsmall))) stack legend(size(vsmall) symxsize(4) row(1) `legendmortexpi') ytitle("") yla(#10, labsize(vsmall) angle(hor)) title("Expectations on mortgages interest rates in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2'", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017.", size(vsmall) linegap(*2.5))
graph export "${GRAPHS}/wod52a_educ.${GRAPHFORMAT}", replace

local vardesc2 : variable label tenant
local vardesc1 : variable label survey

* tenant have different expectations than non-tenant
* tenants think that interest rates are going to be higher on average
graph bar mortexpl mortexps mortexph [pw=wgth], over(tenant, relabel(1 "Owner" 2 "Tenant") label(labsize(vsmall) angle(45))) over(survey, label(labsize(vsmall))) stack legend(size(vsmall) symxsize(4) row(1) `legendmortexpi') ytitle("") yla(#10, labsize(vsmall) angle(hor)) title("Expectations on mortgages interest rates in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2'", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017.", size(vsmall) linegap(*2.5))
graph export "${GRAPHS}/wod52a_tenant.${GRAPHFORMAT}", replace

local vardesc2 : variable label mortowners
local vardesc1 : variable label survey

graph bar mortexpl mortexps mortexph [pw=wgth] if woning == 1, over(mortowners, relabel(1 "Mortgagors" 2 "Non-Mortgagors") label(labsize(tiny) angle(45))) over(survey, label(labsize(vsmall))) stack legend(size(vsmall) symxsize(4) row(1) `legendmortexpi') ytitle("") yla(#10, labsize(vsmall) angle(hor)) title("Expectations on mortgages interest rates in two years of Dutch households", size(small)) subtitle("by `vardesc1' and mortgage situation on the house", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017.", size(vsmall) linegap(*2.5))
graph export "${GRAPHS}/wod52a_mortown.${GRAPHFORMAT}", replace

* measures composition

graph bar tenant homeowners mortowners [pw=wgth], over(mortexpi, relabel(1 "DK" 2 "L" 3 "S" 4 "H") label(labsize(vsmall))) by(survey, legend(pos(12)) title("Expectations on mortgages interest rates in two years of Dutch households", size(small)) subtitle("by `vardesc1' and housing situation", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. Notes: DK = don't know; L = lower than now; S = just as high; H = higher than now", size(vsmall) linegap(*2.5))) stack ytitle("") yla(#6, labsize(tiny) angle(hor)) subtitle(, size(vsmall)) legend(size(vsmall) symxsize(4) row(1) `legendhowners')
graph export "${GRAPHS}/wod52a_mortown_comp.${GRAPHFORMAT}", replace

preserve

local vardesc2 : variable label incqtile
local vardesc1 : variable label survey

levelsof incqtile, local(levels)
foreach l in `levels' {
    generate inc`l' = (incqtile == `l')
}

graph bar inc1 inc2 inc3 inc4 inc5 [pw=wgth], over(mortexpi, relabel(1 "DK" 2 "L" 3 "S" 4 "H") label(labsize(vsmall))) by(survey, legend(pos(12)) title("Expectations on mortgages interest rates in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2'", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. Notes: DK = don't know; L = lower than now; S = just as high; H = higher than now", size(vsmall) linegap(*2.5))) stack ytitle("") yla(#6, labsize(tiny) angle(hor)) subtitle(, size(vsmall)) legend(size(vsmall) symxsize(4) row(1) `legendquintiles')
graph export "${GRAPHS}/wod52a_inc_comp.${GRAPHFORMAT}", replace

restore

preserve

local vardesc2 : variable label nwqtile
local vardesc1 : variable label survey

levelsof nwqtile, local(levels)
foreach l in `levels' {
    generate nw`l' = (nwqtile == `l')
}

graph bar nw1 nw2 nw3 nw4 nw5 [pw=wgth], over(mortexpi, relabel(1 "DK" 2 "L" 3 "S" 4 "H") label(labsize(vsmall))) by(survey, legend(pos(12)) title("Expectations on mortgages interest rates in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2'", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. Notes: DK = don't know; L = lower than now; S = just as high; H = higher than now", size(vsmall) linegap(*2.5))) stack ytitle("") yla(#6, labsize(tiny) angle(hor)) subtitle(, size(vsmall)) legend(size(vsmall) symxsize(4) row(1) `legendquintiles')
graph export "${GRAPHS}/wod52a_nw_comp.${GRAPHFORMAT}", replace

restore

preserve

local vardesc2 : variable label age
local vardesc1 : variable label survey

levelsof ageb, local(levels)
foreach l in `levels' {
    generate ageb`l' = (ageb == `l')
}

graph bar ageb1 ageb2 ageb3 ageb4 ageb5 ageb6 [pw=wgth], over(mortexpi, relabel(1 "DK" 2 "L" 3 "S" 4 "H") label(labsize(vsmall))) by(survey, legend(pos(12)) title("Expectations on mortgages interest rates in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2'", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. Notes: DK = don't know; L = lower than now; S = just as high; H = higher than now", size(vsmall) linegap(*2.5))) stack ytitle("") yla(#6, labsize(tiny) angle(hor)) subtitle(, size(vsmall)) legend(size(vsmall) symxsize(4) row(1) `legendage')
graph export "${GRAPHS}/wod52a_age_comp.${GRAPHFORMAT}", replace

restore


preserve

local vardesc2 : variable label oplzonb
local vardesc1 : variable label survey

levelsof oplzonb, local(levels)
foreach l in `levels' {
    generate oplzonb`l' = (oplzonb == `l')
}

graph bar oplzonb1 oplzonb2 oplzonb3 [pw=wgth], over(mortexpi, relabel(1 "DK" 2 "L" 3 "S" 4 "H") label(labsize(vsmall))) by(survey, legend(pos(12)) title("Expectations on mortgages interest rates in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2'", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. Notes: DK = don't know; L = lower than now; S = just as high; H = higher than now", size(vsmall) linegap(*2.5))) stack ytitle("") yla(#6, labsize(tiny) angle(hor)) subtitle(, size(vsmall)) legend(size(vsmall) symxsize(4) row(1) `legendeduc')
graph export "${GRAPHS}/wod52a_educ_comp.${GRAPHFORMAT}", replace

restore

preserve

local vardesc2 : variable label empl
local vardesc1 : variable label survey

levelsof empl, local(levels)
foreach l in `levels' {
    generate empl`l' = (empl == `l')
}

graph bar empl1 empl2 empl3 empl4 [pw=wgth], over(mortexpi, relabel(1 "DK" 2 "L" 3 "S" 4 "H") label(labsize(vsmall))) by(survey, legend(pos(12)) title("Expectations on mortgages interest rates in two years of Dutch households", size(small)) subtitle("by `vardesc1' and `vardesc2'", size(vsmall)) note("Source: DNB Household Survey. Years: 2004 - 2017. Notes: DK = don't know; L = lower than now; S = just as high; H = higher than now", size(vsmall) linegap(*2.5))) stack ytitle("") yla(#6, labsize(tiny) angle(hor)) subtitle(, size(vsmall)) legend(size(vsmall) symxsize(4) row(1) `legendlabour')
graph export "${GRAPHS}/wod52a_empl_comp.${GRAPHFORMAT}", replace

restore
