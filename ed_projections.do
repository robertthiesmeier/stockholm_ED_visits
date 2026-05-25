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
gen pred_visits = .
gen pred_lb = .
gen pred_ub = .

* Poisson model per age group, write predictions back
levelsof agegroup, local(groups)

foreach k of local groups {

    // fit on observed years
    mkspline s1 2019 s2 2021 s3 = year if agegroup == "`k'"

    poisson visits s1 s2 s3 if agegroup == "`k'" & year <= 2024, /// 
		offset(ln_pop) vce(robust)

    // predict
    tempvar xb se

    predict `xb' if agegroup == "`k'", xb
    predict `se' if agegroup == "`k'", stdp

    replace pred_visits = exp(`xb') if agegroup == "`k'"
    replace pred_lb = exp(`xb' - 1.96 * `se') if agegroup == "`k'"
    replace pred_ub = exp(`xb' + 1.96 * `se') if agegroup == "`k'"
	
    drop s1 s2 s3

}

// get rates
gen pred_rate = (pred_visits / popsize) * 1000
gen predrate_lb = (pred_lb / popsize) * 1000
gen predrate_ub = (pred_ub / popsize) * 1000

export excel "/Users/robert/Library/CloudStorage/OneDrive-KarolinskaInstitutet/Projects/Clara_ED_visits/data", replace firstrow(variables)

// with rate	
tw /// 
	(rarea predrate_lb predrate_ub year if agegroup=="20_34", color("199 223 241%50") lcolor(%0)) ///  
    (line pred_rate year if agegroup=="20_34", lcolor("199 223 241") lwidth(medthick)) ///
    (scatter ed_rate year if agegroup=="20_34" & year<=2024, msize(vsmall) mcolor("199 223 241")) ///
	(rarea predrate_lb predrate_ub year if agegroup=="35_49", color("107 174 214%50") lcolor(%0)) ///  
    (line pred_rate year if agegroup=="35_49", lcolor("107 174 214") lwidth(medthick)) ///
    (scatter ed_rate year if agegroup=="35_49" & year<=2024, msize(vsmall) mcolor("107 174 214")) ///
	(rarea predrate_lb predrate_ub year if agegroup=="50_64", color("49 130 189%50") lcolor(%0)) ///  
    (line pred_rate year if agegroup=="50_64", lcolor("49 130 189") lwidth(medthick)) ///
    (scatter ed_rate year if agegroup=="50_64" & year<=2024, msize(vsmall) mcolor("49 130 189")) ///
	(rarea predrate_lb predrate_ub year if agegroup=="65_79", color("23 78 138%50") lcolor(%0)) ///  
    (line pred_rate year if agegroup=="65_79", lcolor("23 78 138") lwidth(medthick)) ///
    (scatter ed_rate year if agegroup=="65_79" & year<=2024, msize(vsmall) mcolor("23 78 138")) ///
	(rarea predrate_lb predrate_ub year if agegroup=="80+", color("8 37 77%50") lcolor(%0)) ///  
    (line pred_rate year if agegroup=="80+", lcolor("8 37 77") lwidth(medthick)) ///
    (scatter ed_rate year if agegroup=="80+" & year<=2024, msize(vsmall) mcolor("8 37 77")), ///
	legend(label(2 "20–34 years") label(5 "35–49 years") ///
		label(8 "50–64 years") label(11 "65–79 years") label(14 "80+ years") ///
		pos(6) col(5) size(small) order(2 5 8 11 14)) ///
	xline(2024, lwidth(medium) lpattern(dot)) /// 
	xlab(2016(2)2034, nogrid labsize(small)) ylab(#8, format(%9.0fc) nogrid labsize(small)) /// 
	xtitle("Years", size(small)) ytitle("ED visits per 1.000 population", size(small))
	
graph export "/Users/robert/Library/CloudStorage/OneDrive-KarolinskaInstitutet/Projects/Clara_ED_visits/figures/fig1.png", replace width(4000)


// figures
tw /// 
	(rarea pred_lb pred_ub year if agegroup== "20_34", color("199 223 241%50") lcolor(%0)) ///  
    (line pred_visits year if agegroup=="20_34", lcolor("199 223 241") lwidth(medthick)) ///
	(rarea pred_lb pred_ub year if agegroup== "35_49", color("107 174 214%50") lcolor(%0)) ///  
    (line pred_visits year if agegroup=="35_49", lcolor("107 174 214") lwidth(medthick)) ///
	(rarea pred_lb pred_ub year if agegroup== "50_64", color("49 130 189%50") lcolor(%0)) ///  
    (line pred_visits year if agegroup=="50_64", lcolor("49 130 189") lwidth(medthick)) ///
	(rarea pred_lb pred_ub year if agegroup== "65_79", color("23 78 138%50") lcolor(%0)) ///  
    (line pred_visits year if agegroup=="65_79", lcolor("23 78 138") lwidth(medthick)) ///
	(rarea pred_lb pred_ub year if agegroup== "80+", color("8 37 77%50") lcolor(%0)) ///  
    (line pred_visits year if agegroup== "80+", lcolor("8 37 77") lwidth(medthick)), ///
	legend(label(1 "20–34 years") label(3 "35–49 years") /// 
		label(5 "50–64 years") label(7 "65–79 years") label(9 "80+ years") ///
		pos(6) col(5) size(small) order(1 3 5 7 9)) /// 
	xline(2024, lwidth(medium) lpattern(dot)) /// 
	xlab(2016(2)2034, nogrid labsize(small)) ylab(, nogrid labsize(small)) /// 
	xtitle("Years", size(small)) ytitle("Projected number of ED visits", size(small))
	
graph export "/Users/robert/Library/CloudStorage/OneDrive-KarolinskaInstitutet/Projects/Clara_ED_visits/figures/fig2.png", replace width(4000)


// alternative (single graphs)
	
local titles `""20–34 years" "35–49 years" "50–64 years" "65–79 years" "80+ years""'
local figs "fig_2034 fig_3549 fig_5064 fig_6579 fig_80p"
local i = 1
levelsof agegroup, local(groups)

foreach k of local groups {

    local title : word `i' of `titles'
    local fig : word `i' of `figs'

    tw /// 
		(rarea pred_lb pred_ub year if agegroup=="`k'", color("49 130 189%50") lcolor(%0)) ///  
        (line pred_visits year if agegroup=="`k'", lcolor(red) lwidth(medthick)) ///
        (line visits year if agegroup=="`k'" & year<=2024, lcolor(black) lwidth(thin) lpattern(dash)), ///
        xline(2024, lpattern(dash) lcolor(gray)) ylab(, labsize(small) nogrid) xlab(, labsize(small) nogrid) ///
        legend(order(3 "Observed" 2 "Projected") pos(6) row(1) size(small)) ///
        ytitle("ED visits", size(small)) xtitle("Year", size(small)) title("{bf:`title'}", size(small)) name(`fig', replace)

    local ++i
}

grc1leg fig_2034 fig_3549 fig_5064 fig_6579 fig_80p, ///
    title("{bf:ED Visit Projections by Age Group in Stockholm}", size(small)) ///
    name(fig_combined, replace) ycommon col(3)
	
graph export "/Users/robert/Library/CloudStorage/OneDrive-KarolinskaInstitutet/Projects/Clara_ED_visits/figures/fig3.png", replace width(4000)

// tables
// % change between the years
foreach y in 2022 2024 2030 2035 {
    gen v`y' = visits if year == `y' & year <= 2024
    gen p`y' = pred_visits if year == `y'
    bysort agegroup: egen vis`y'  = max(v`y')
    bysort agegroup: egen pred`y' = max(p`y')
    drop v`y' p`y'
}

* % change observed: 2022 to 2024
gen pct_obs_2022_2024 = ((vis2024 - vis2022) / vis2022) * 100

* % change projected: 2024 to 2030 and 2024 to 2035
gen pct_proj_2024_2030 = ((pred2030 - pred2024) / pred2024) * 100
gen pct_proj_2024_2035 = ((pred2035 - pred2024) / pred2024) * 100

bysort agegroup: keep if _n == 1
list agegroup pct_obs_2022_2024 pct_proj_2024_2030 pct_proj_2024_2035, ///
    noobs clean table 

exit 
