* set environment paths
* global DHSDATA   "C:/Users/pizzigo/Documents/dhs"
* global DATA      "P:/ECB business areas/DGR/Databases and Programme files/DGR/Alessandro Pizzigolotto/dimitris/dhs/data/sets"
* global PROGRAMS  "P:/ECB business areas/DGR/Databases and Programme files/DGR/Alessandro Pizzigolotto/dimitris/dhs/programs"
* global GRAPHS    "P:/ECB business areas/DGR/Databases and Programme files/DGR/Alessandro Pizzigolotto/dimitris/dhs/data/graphs"

global DHSDATA  "/Users/dubidub/MEGA/Documents/ECB/Data/dhs"
global DATA     "/Users/dubidub/MEGA/Documents/ECB/Projects/Dimitris/dhs/data/sets"
global PROGRAMS "/Users/dubidub/MEGA/Documents/ECB/Projects/Dimitris/dhs/programs"
global GRAPHS   "/Users/dubidub/MEGA/Documents/ECB/Projects/Dimitris/dhs/data/graphs"

global GRAPHFORMAT "pdf"

* starting date of the preferred waves
global STARTDATE 2004
* last wave available is also the last wave we use
global LASTWAVE  2017
* do you want to create the waves?
global GENWAVES  1

set more off

if $GENWAVES == 1 {

    forvalues i = $STARTDATE/$LASTWAVE {

        * move all zip files of the wave in another folder  'zip'
        cd "${DHSDATA}/`i'"
        !mkdir zip
        !mv *.zip ./zip

        * individual level ; n.b. to select the reference person -> positie == 1
        * open hhi general household information : format dataset xxxYEAR.dta
        * sted is degree of urbanization, then we have regio and prov as well
        local zipdta : dir "${DHSDATA}/`i'/zip" files "hhi*.zip"
        cd "${DHSDATA}/`i'/zip"
        unzipfile `zipdta', replace
        local myfile : dir "." files "hhi*.dta"
        local subfile = substr(`zipdta', 1, 7) + ".dta"
        * !rename `myfile' "`subfile'"
        * !mv `subfile' ../`subfile'
        !mv `myfile' ../`subfile'
        use "${DHSDATA}/`i'/hhi`i'.dta", clear

        * add aggregate data on income
        local zipdta : dir "${DHSDATA}/`i'/zip" files "agi*.zip"
        cd "${DHSDATA}/`i'/zip"
        unzipfile `zipdta', replace
        local myfile : dir "." files "agi*.dta"
        local subfile = substr(`zipdta', 1, 7) + ".dta"
        * !rename `myfile' "`subfile'"
        * !mv `subfile' ../`subfile'
        !mv `myfile' ../`subfile'
        merge m:1 nohhold nomem using "${DHSDATA}/`i'/agi`i'.dta"
        drop if _m == 2
        drop _m

        * add aggregate data on assets, liabilities and mortgages
        local zipdta : dir "${DHSDATA}/`i'/zip" files "agw*.zip"
        cd "${DHSDATA}/`i'/zip"
        unzipfile `zipdta', replace
        local myfile : dir "." files "agw*.dta"
        local subfile = substr(`zipdta', 1, 7) + ".dta"
        * !rename `myfile' "`subfile'"
        * !mv `subfile' ../`subfile'
        !mv `myfile' ../`subfile'
        merge m:1 nohhold nomem using "${DHSDATA}/`i'/agw`i'.dta"
        drop if _m == 2
        drop _m

        * add data on health and income at individual level
        local zipdta : dir "${DHSDATA}/`i'/zip" files "inc*.zip"
        cd "${DHSDATA}/`i'/zip"
        unzipfile `zipdta', replace
        local myfile : dir "." files "inc*.dta"
        local subfile = substr(`zipdta', 1, 7) + ".dta"
        * !rename `myfile' "`subfile'"
        * !mv `subfile' ../`subfile'
        !mv `myfile' ../`subfile'
        merge m:1 nohhold nomem using "${DHSDATA}/`i'/inc`i'.dta"
        drop if _m == 2
        drop _m

        * add data on accomodation and mortgages at individual level
        * only one person answers
        * wod52a wod52b wod52c expectations regarding mortgages
        * wod205 wod206 wod207 expectations regarding house prices
        local zipdta : dir "${DHSDATA}/`i'/zip" files "hse*.zip"
        cd "${DHSDATA}/`i'/zip"
        unzipfile `zipdta', replace
        local myfile : dir "." files "hse*.dta"
        local subfile = substr(`zipdta', 1, 7) + ".dta"
        * !rename `myfile' "`subfile'"
        * !mv `subfile' ../`subfile'
        !mv `myfile' ../`subfile'
        merge m:1 nohhold nomem using "${DHSDATA}/`i'/hse`i'.dta"
        drop if _m == 2
        drop _m

        * add data on economic and psychological concepts (one person answers)
        * kunde gives the level of self-evaluated financial knowledge 1-4
        * conxx are human behaviour variables
        * geluk happiness
        * zon chance to have a sunny day (optimism)
        * jeugdx parsimony and financial education when younger
        local zipdta : dir "${DHSDATA}/`i'/zip" files "psy*.zip"
        cd "${DHSDATA}/`i'/zip"
        unzipfile `zipdta', replace
        local myfile : dir "." files "psy*.dta"
        local subfile = substr(`zipdta', 1, 7) + ".dta"
        * !rename `myfile' "`subfile'"
        * !mv `subfile' ../`subfile'
        !mv `myfile' ../`subfile'
        merge m:1 nohhold nomem using "${DHSDATA}/`i'/psy`i'.dta"
        drop if _m == 2
        drop _m

        if `i' == 2000 {
            * the weights were introduced from 2001
            * to run the code we introduce equal weights to 1 for each individual
            generate wgth = 1
        }
        else {
            * household level : aggregate income and wealth, household weights
            * owner indicates main residence ownership, idink net disposable income
            * wgth is the household weight
            local zipdta : dir "${DHSDATA}/`i'/zip" files "weights*.zip"
            cd "${DHSDATA}/`i'/zip"
            unzipfile `zipdta', replace
            local myfile : dir "." files "weights*.dta"
            local subfile = substr(`zipdta', 1, 11) + ".dta"
            * !rename `myfile' "`subfile'"
            * !mv `subfile' ../`subfile'
            !mv `myfile' ../`subfile'
            merge m:1 nohhold using "${DHSDATA}/`i'/weights`i'.dta"
            * just in case (should be _m == 3 for all the hholds)
            drop if _m != 3
            drop _m
        }


        ****************************************************************************
        *                                                                          *
        * from here : cleaning data                                                *
        *                                                                          *
        ****************************************************************************

        * add an personal id pd for each individual
        sort nohhold nomem
        generate pid = nohhold * 100 + nomem
        label variable pid "personal index"
        * rename nohhold the household id as id
        * rename nohhold id
        * generate a variable to save the year of the wave when we pool
        generate survey = `i'
        label variable survey "dhs wave"
        * generate age of individuals
        generate age = survey - gebjaar

        * generate aggregate data at household level
        * there are more than 2k households with zero gross income
        * btot = loon + vut + pens + wao + ww + wg + aow + aww + abw + waz + wajong + ioaw + alim + max(winst,0) + hprem + hwf
        if `i' == 2000 {
            local incomes "loon vut pens wao ww wg aow aww abw aaw ioaw alim hprem hwf"
        }
        else {
            local incomes "loon vut pens wao ww wg aow aww abw waz wajong ioaw alim hprem hwf"
        }

        foreach y in `incomes' {
            replace `y' = 0 if `y' == -1
        }

        egen ginc = rowtotal(`incomes')
        replace ginc = ginc + max(winst, 0)
        label variable ginc "total gross income at individual level (corrected)"

        * remember to use household weights
        bysort nohhold : egen ginch = total(ginc), missing
        label variable ginch "total gross income at household level"

        * generate income quintiles at household level
        xtile incqtile = ginch [pw=wgth], n(5)
        label variable incqtile "gross income quintiles"
        label define quintiles 1 "1st quintile" 2 "2nd quintile" 3 "3rd quintile" 4 "4th quintile" 5 "5th quintile"
        label values incqtile quintiles

        * household wealth
        if `i' > 2007 & `i' < 2011 {
            * no information about growth funds b11 (probably included in mutual funds)
            local finassets "b1b b3b b4b b6b b7b b8b b25b b12b b13b b14b"
        }
        else {
            local finassets "b1b b3b b4b b6b b7b b8b b25b b11b b12b b13b b14b"
        }

        egen fassets = rowtotal(`finassets'), missing
        * a lot of checking accounts are negative (deficit balance)
        label variable fassets "outstanding balance of financial assets at individual level"
        replace fassets = . if fassets == 0

        * remember to use household weights
        bysort nohhold : egen fassetsh = total(fassets), missing
        label variable fassetsh "outstanding balance of financial assets at household level"

        if `i' == 2000 {
            local realassets "b26ogb b27ogb b19ogb b20b b21b b22b b23b"
        }
        else {
            local realassets "b26ogb b27ogb b19ogb b20b b21b b22b b23b b29b b30b"
        }

        * wo34 value of accomodation is exprressed in thousands of euros
        * replace wo34 = wo34 * 1000
        egen rassets = rowtotal(`realassets'), missing
        label variable rassets "value of real assets at individual level"
        replace rassets = . if rassets == 0

        * remember to use household weights
        bysort nohhold : egen rassetsh = total(rassets), missing
        label variable rassetsh "value of real assets at household level"

        * gather mortgages : first and second residence + other
        gen morti = ((b19hya > 0 & missing(b19hya) == 0) | (b26hya > 0 & missing(b26hya) == 0) | (b27hya > 0 & missing(b27hya) == 0))
        label variable morti "person has mortgages"

        * remember to use household weights
        bysort nohhold : egen mortih = max(morti)
        label variable mortih "household has mortgages"

        egen tmort = rowtotal(b19hyb b26hyb b27hyb), missing
        label variable tmort "outstanding balance of mortgages at individual level"
        replace tmort = . if tmort == 0
        * remember to use household weights
        bysort nohhold : egen tmorth = total(tmort), missing
        label variable tmorth "outstanding balance of mortgages at household level"

        * household liabilities
        egen tliab = rowtotal(tmort s*b), missing
        label variable tliab "outstanding balance of liabilities at individual level"
        replace tliab = . if tliab == 0
        * remember to use household weights
        bysort nohhold : egen tliabh = total(tliab), missing
        label variable tliabh "outstanding balance of liabilities at household level"

        * total net wealth
        egen auxAssets = rowtotal(rassets fassets)
        gen auxLiab   = (-1) * tliab
        replace auxLiab = min(0,auxLiab)
        gen nwealth = auxAssets - auxLiab
        drop auxAssets auxLiab
        label variable nwealth "individual net wealth"
        * remember to use household weights
        bysort nohhold : egen nwealthh = total(nwealth)
        label variable nwealthh "household net wealth"

        * generate net wealth quintiles at household level
        xtile nwqtile = nwealthh [pw=wgth], n(5)
        label variable nwqtile "net wealth quintiles"

        * keep only variables at household level for the aggregates
        * it was cool to have individual level for wealth, but unsuccessful (sori siita)
        drop fassets rassets morti tmort tliab nwealth
        rename (fassetsh rassetsh mortih tmorth tliabh nwealthh) (fassets rassets morti tmort tliab nwealth)

        * expectations on mortgages copied at household level
        bysort nohhold : egen mortexpi   = total(wod52a), missing
        bysort nohhold : egen mortexp2y  = total(wod52b), missing
        bysort nohhold : egen mortexp10y = total(wod52c), missing

        replace mortexpi   = . if mortexpi   ==  9
        replace mortexp2y  = . if (mortexp2y  == -9) | (abs(mortexp2y) > 100)
        replace mortexp10y = . if mortexp10y == -9

        * percentage correction using dummies (lower expectation in negative perc)
        replace mortexp2y = (-1)*mortexp2y if missing(wod52b) == 0 & missing(wod52a) == 0 & wod52b > 0 & wod52a == 1

        label variable mortexpi   "expectations on mortgages interest rates in two years"
        label variable mortexp2y  "percentage points of expected mortgage interest rates variation in two years"
        label variable mortexp10y "expected mortgage interest rates in ten years"
        label values mortexpi wod52a

        * expectations on house prices copied at household level
        * bysort nohhold : egen housexpi   = total(wod205), missing
        * bysort nohhold : egen housexp2y  = total(wod206), missing
        * bysort nohhold : egen housexp10y = total(wod207), missing
        *
        * replace housexpi   = . if housexpi   == -9
        * replace housexp2y  = . if housexp2y  == -9
        * replace housexp10y = . if housexp10y == -9
        *
        * * percentage correction using dummies
        * replace housexp2y = (-1)*housexp2y if missing(wod206) == 0 & missing(wod205) == 0 & wod206 > 0 & wod205 == 1
        *
        * label variable housexpi   "expectations on house prices in two years"
        * label variable housexp2y  "percentage of expected house prices variation in two years"
        * label variable housexp10y "percentage of expected house prices variation in ten years"
        * label values housexpi wod205

        * are you a tenant?
        replace woning = . if woning == -9
        generate tenant = (woning == 2 | woning == 3)
        label variable tenant "the household is a tenant"
        label define tenantlbl 0 "Non-Tenant" 1 "Tenant"
        label values tenant tenantlbl
        * are you a houseowner with a mortgage on the main accomodation (poor boy) ?
        bysort nohhold : egen auxm = min(b26hya)
        replace auxm = 0 if missing(auxm) == 1
        generate mortowners = (auxm > 0 & woning == 1)
        label variable mortowners "the household has a mortgage over the owned accomodation"
        generate homeowners = (tenant == 0 & mortowners == 0)
        generate housestatus = .
        replace housestatus = 3 if (woning == 2 | woning == 3)
        replace housestatus = 2 if (auxm > 0 & woning == 1)
        replace housestatus = 1 if (tenant == 0 & mortowners == 0)
        label variable housestatus "house status"
        label define hstatuslbl 1 "house-owner" 2 "house-owner with mortgage" 3 "tenant"
        label values housestatus hstatuslbl
        drop auxm

        * some psychological variables at individual level
        * degree of happiness : clean don't know values (~ 2 over 5)
        replace geluk = . if geluk == -9
        * degee of optimism (sunny day tomorrow) : clean don't know values (~ 44 %)
        replace zon = . if zon == -9
        * financial knowledge self-assessment
        replace kunde = . if kunde == -9
        * did your parents taught to save money btwn 12 and 16 yold (jeugd6)


        * we consider individuals from 16 years old
        * drop if age < 16

        * generate age brackets
        generate ageb = 1 if age > 15 & age < 35
        replace  ageb = 2 if age > 34 & age < 45
        replace  ageb = 3 if age > 44 & age < 55
        replace  ageb = 4 if age > 54 & age < 65
        replace  ageb = 5 if age > 64 & age < 75
        replace  ageb = 6 if age > 74

        * generate education categories using isced97
        * consider highest level of education attended as reference
        replace oplzon = . if oplzon < 1 & oplzon > 9
        * primary education (isced0-2) if no education, pre-vocational, kindergarden
        generate oplzonb = 1 if oplzon == 2 | oplzon == 3 | oplzon == 8
        * secondary education (isced3) if havo/vwo and mbo
        replace oplzonb = 2 if oplzon == 4 | oplzon == 5
        * tertiary education (isced5) if hbo or wo
        replace oplzonb = 3 if oplzon == 6 | oplzon == 7

        * generate labour status categories

        * rename the variable of labour status before 2008
        if `i' < 2007 {
            rename belbezig bezighei
        }

        replace bezighei = . if bezighei < 1 & bezighei > 13
        * in employed we include also volunteers (?)
        generate empl = 1 if bezighei == 1 | bezighei == 11
        * in self-employed we have own business workers, free profession, freelancers
        replace  empl = 2 if bezighei == 2 | bezighei == 3
        * retired included also pre-retired and disabled
        replace  empl = 3 if bezighei == 8 | bezighei == 9
        * other not working has job seekers, students, unpaid workers, other
        * other unclassificable occupations, too young to work (removed), housekeepers
        replace  empl = 4 if bezighei == 4 | bezighei == 5 | bezighei == 6 | bezighei == 7 | bezighei == 10 | bezighei == 12 | bezighei == 13

        * generate labels for age, education, labour status, to be applied
        label define ageRange     1 "16-34" 2 "35-44" 3 "45-54" 4 "55-64" 5 "65-74" 6 "75+"
        label define educLevel    1 "Basic Education" 2 "Secondary" 3 "Tertiary"
        label define labourStatus 1 "Employee" 2 "Self-Employed" 3 "Retired" 4 "Other not working"

        label variable age  "age"
        label variable ageb "age in brackets"
        label variable oplzonb "highest level of education attended"
        label variable empl "employment status"

        label values ageb ageRange
        label values oplzonb educLevel
        label values empl labourStatus

        * drop the entire household if we have issues with the year of birth (?)
        * levelsof nohhold if missing(gebjaar) == 1, local(droph)
        * foreach hid in `droph' {
        *     drop if nohhold == `hid'
        * }

        * output compl
        cd "${DHSDATA}/`i'"
        tostring weeknr, gen(weeknr2)
        replace weeknr2 = substr(weeknr2, 5, 6)
        destring(weeknr2), gen(auxweek)
        gen month = mofd(dofw(auxweek))
        drop auxweek weeknr2
        order nohhold nomem survey
        sort nohhold nomem survey
        save "compl`i'.dta" , replace

        * keep only needed values and put it in the project folder
        keep if positie == 1
        save "${DATA}/hhead`i'.dta", replace

    }

}

* append altogether the waves
* use, append, order nohhold nomem year, sort year nohhold nomem

use "${DATA}/hhead${STARTDATE}.dta", clear
local pointer = $STARTDATE+1
forvalues i = `pointer'/$LASTWAVE {
    append using "${DATA}/hhead`i'.dta", force
}

* correct values of prov for 2004 wave
replace prov = prov + 19 if survey == 2004

generate mortexpl = (mortexpi == 1)
label variable mortexpl "lower than now"
generate mortexph = (mortexpi == 3)
label variable mortexph "higher than now"
generate mortexps = (mortexpi == 2)
label variable mortexps "just as high as now"
generate mortexpno = (mortexpi == -9)
label variable mortexpno "don't know"

compress

save "${DATA}/dhs_aggr.dta", replace

* sdw does not work on my stata
* do "${PROGRAMS}/sdw64intr.do"

* do "${PROGRAMS}/descMortexp.do"
* do "${PROGRAMS}/expgrowthMort.do"
