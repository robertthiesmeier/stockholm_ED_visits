/*

Sensitivity analysis: knot specification

- No knots (linear trend only)
- Single knot at 2020 (pandemic onset)
- Two knots at 2020 and 2022 (onset + recovery)

*/ 

clear all
input str6 agegroup year visits popsize

* 20-34
"20_34"  2016  103618  487081
"20_34"  2017   96287  493575
"20_34"  2018   79071  499333
"20_34"  2019   73390  503185
"20_34"  2020   59355  500757
"20_34"  2021   58370  500504
"20_34"  2022   58518  502883
"20_34"  2023   58718  498479
"20_34"  2024   60922  495082
"20_34"  2025       .  488892
"20_34"  2026       .  485176
"20_34"  2027       .  482188
"20_34"  2028       .  480899
"20_34"  2029       .  480490
"20_34"  2030       .  479079
"20_34"  2031       .  479186
"20_34"  2032       .  490257
"20_34"  2033       .  494480
"20_34"  2034       .  497924
"20_34"  2035       .  501571

* 35-49
"35_49"  2016   91195  489331
"35_49"  2017   85139  494784
"35_49"  2018   72437  500543
"35_49"  2019   67521  508109
"35_49"  2020   59553  511749
"35_49"  2021   57614  515730
"35_49"  2022   56514  521073
"35_49"  2023   58092  526002
"35_49"  2024   60210  530946
"35_49"  2025       .  537691
"35_49"  2026       .  544491
"35_49"  2027       .  551466
"35_49"  2028       .  557369
"35_49"  2029       .  561431
"35_49"  2030       .  561775
"35_49"  2031       .  561961
"35_49"  2032       .  560774
"35_49"  2033       .  560079
"35_49"  2034       .  559673
"35_49"  2035       .  558012

* 50-64
"50_64"  2016   94529  391981
"50_64"  2017   92723  400531
"50_64"  2018   82457  408193
"50_64"  2019   77895  415186
"50_64"  2020   68381  421865
"50_64"  2021   68203  429628
"50_64"  2022   68250  438112
"50_64"  2023   68705  446261
"50_64"  2024   70786  455272
"50_64"  2025       .  460174
"50_64"  2026       .  464729
"50_64"  2027       .  467314
"50_64"  2028       .  468780
"50_64"  2029       .  469023
"50_64"  2030       .  471162
"50_64"  2031       .  471930
"50_64"  2032       .  473673
"50_64"  2033       .  475941
"50_64"  2034       .  479383
"50_64"  2035       .  482378

* 65-79
"65_79"  2016  101503  272044
"65_79"  2017  101987  277485
"65_79"  2018   96628  281978
"65_79"  2019   91884  286127
"65_79"  2020   75706  289572
"65_79"  2021   81375  293328
"65_79"  2022   85796  295946
"65_79"  2023   87334  297301
"65_79"  2024   87435  298422
"65_79"  2025       .  298043
"65_79"  2026       .  299416
"65_79"  2027       .  302320
"65_79"  2028       .  306878
"65_79"  2029       .  314479
"65_79"  2030       .  322084
"65_79"  2031       .  330312
"65_79"  2032       .  337448
"65_79"  2033       .  343799
"65_79"  2034       .  349461
"65_79"  2035       .  355673

* 80+
"80+"  2016   68441   86644
"80+"  2017   68062   88105
"80+"  2018   65543   90276
"80+"  2019   64603   93248
"80+"  2020   54093   94260
"80+"  2021   59142   98469
"80+"  2022   66918  104116
"80+"  2023   70335  111123
"80+"  2024   74050  119665
"80+"  2025       .  125729
"80+"  2026       .  132468
"80+"  2027       .  138650
"80+"  2028       .  143910
"80+"  2029       .  148083
"80+"  2030       .  151584
"80+"  2031       .  154082
"80+"  2032       .  156719
"80+"  2033       .  159053
"80+"  2034       .  161088
"80+"  2035       .  163346
end


sort agegroup year

gen ed_rate = 1000 * visits / popsize if visits != .
gen ln_pop  = ln(popsize)

foreach spec in noknot knot1 knot2 knot3 {
    gen pred_rate_`spec'  = .
    gen predrate_lb_`spec' = .
    gen predrate_ub_`spec' = .
}

levelsof agegroup, local(groups)

foreach k of local groups {

    * 1. no knots (linear trend only)
    poisson visits year if agegroup == "`k'" & year <= 2024, ///
        offset(ln_pop) vce(robust)

    tempvar xb se
    predict `xb' if agegroup == "`k'", xb
    predict `se' if agegroup == "`k'", stdp

    replace pred_rate_noknot = (exp(`xb') / popsize) * 1000 if agegroup == "`k'"
    replace predrate_lb_noknot = (exp(`xb' - 1.96*`se') / popsize) * 1000 if agegroup == "`k'"
    replace predrate_ub_noknot = (exp(`xb' + 1.96*`se') / popsize) * 1000 if agegroup == "`k'"
    drop `xb' `se'


    * 2. single knot at 2020 (pandemic onset)
    mkspline s1 2020 s2 = year if agegroup == "`k'"

    poisson visits s1 s2 if agegroup == "`k'" & year <= 2024, ///
        offset(ln_pop) vce(robust)

    tempvar xb se
    predict `xb' if agegroup == "`k'", xb
    predict `se' if agegroup == "`k'", stdp

    replace pred_rate_knot1 = (exp(`xb') / popsize) * 1000 if agegroup == "`k'"
    replace predrate_lb_knot1 = (exp(`xb' - 1.96*`se') / popsize) * 1000 if agegroup == "`k'"
    replace predrate_ub_knot1 = (exp(`xb' + 1.96*`se') / popsize) * 1000 if agegroup == "`k'"
    drop `xb' `se' s1 s2


    * 3. two knots at 2020 and 2022 (onset + recovery)
    mkspline s1 2020 s2 2022 s3 = year if agegroup == "`k'"

    poisson visits s1 s2 s3 if agegroup == "`k'" & year <= 2024, ///
        offset(ln_pop) vce(robust)

    tempvar xb se
    predict `xb' if agegroup == "`k'", xb
    predict `se' if agegroup == "`k'", stdp

    replace pred_rate_knot2 = (exp(`xb') / popsize) * 1000 if agegroup == "`k'"
    replace predrate_lb_knot2 = (exp(`xb' - 1.96*`se') / popsize) * 1000 if agegroup == "`k'"
    replace predrate_ub_knot2 = (exp(`xb' + 1.96*`se') / popsize) * 1000 if agegroup == "`k'"
    drop `xb' `se' s1 s2 s3


    * 4. comparison from the orginal analysis: two knots at 2019 and 2021 (before and after onset of pandemic)
    mkspline s1 2019 s2 2021 s3 = year if agegroup == "`k'"

    poisson visits s1 s2 s3 if agegroup == "`k'" & year <= 2024, ///
        offset(ln_pop) vce(robust)

    tempvar xb se
    predict `xb' if agegroup == "`k'", xb
    predict `se' if agegroup == "`k'", stdp

    replace pred_rate_knot3 = (exp(`xb') / popsize) * 1000 if agegroup == "`k'"
    replace predrate_lb_knot3 = (exp(`xb' - 1.96*`se') / popsize) * 1000 if agegroup == "`k'"
    replace predrate_ub_knot3 = (exp(`xb' + 1.96*`se') / popsize) * 1000 if agegroup == "`k'"
    drop `xb' `se' s1 s2 s3

}

* Observed rate (all groups)
gen ed_rate_obs = 1000 * visits / popsize if visits != .

* Plot: one panel per age group
// define age group labels for titles
local label_20_34 "20–34 years"
local label_35_49 "35–49 years"
local label_50_64 "50–64 years"
local label_65_79 "65–79 years"
local label_80p "80+ years"

local gcount = 0
foreach k in 20_34 35_49 50_64 65_79 80+ {
    local ++gcount

    local klabel "`k'"
    if "`k'" == "80+" local klabel "80p"

    twoway ///
        (line pred_rate_noknot year if agegroup == "`k'", ///
            lcolor(red) lwidth(medium) lpattern(solid)) ///
        (line pred_rate_knot1 year if agegroup == "`k'", ///
            lcolor(orange) lwidth(medium) lpattern(dash)) ///
        (line pred_rate_knot2 year if agegroup == "`k'", ///
            lcolor(green) lwidth(medium) lpattern(shortdash)) ///
        (line pred_rate_knot3 year if agegroup == "`k'", ///
            lcolor(blue) lwidth(medium) lpattern(longdash)) ///
        (scatter ed_rate_obs year if agegroup == "`k'" & year <= 2024, ///
            msize(vsmall) mcolor(black) msymbol(circle)), ///
        xline(2024, lwidth(thin) lpattern(dot) lcolor(gray)) ///
        legend(order(1 "No knots" 2 "Knot: 2020" ///
                     3 "Knots: 2020+2022" 4 "Knots: 2019+2021") pos(6) col(5) size(small)) ///
        xlab(2016(2)2034, nogrid labsize(vsmall)) ///
        ylab(#6, format(%9.0fc) nogrid labsize(vsmall)) ///
        xtitle("Year", size(vsmall)) ///
        ytitle("ED visits per 1,000 population", size(vsmall)) ///
        title("`label_`klabel''", size(medsmall)) ///
        name(g`gcount', replace) nodraw
}

grc1leg g1 g2 g3 g4 g5, ///
    cols(3) ycommon ///
    title("Sensitivity analysis: knot specification", size(medium)) ///
    note("Dots = observed. Dashed vertical line = start of projection (2025)." ///
         "All models: Poisson with population offset, robust SE.", size(vsmall))
