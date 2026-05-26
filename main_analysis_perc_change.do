*** create tables with 95% CI for % change in ED visits ***
  
gen pct_2024_2030_est = .
gen pct_2024_2030_lb = .
gen pct_2024_2030_ub = .
gen pct_2024_2035_est = .
gen pct_2024_2035_lb = .
gen pct_2024_2035_ub = .

local groups "20_34 35_49 50_64 65_79 80+"

foreach k of local groups {

    mkspline s1 2019 s2 2021 s3 = year if agegroup == "`k'"

    poisson visits s1 s2 s3 if agegroup == "`k'" & year <= 2024, ///
        offset(ln_pop) vce(robust)
    quietly sum year if agegroup == "`k'" & year == 2024

    tempvar xb_all
    predict `xb_all' if agegroup == "`k'", xb
    quietly sum `xb_all' if agegroup == "`k'" & year == 2024
    local xb24 = r(mean)
    drop `xb_all'

    tempvar diff30 se30 diff35 se35

    predictnl `diff30' = predict(xb) - `xb24' ///
        if agegroup == "`k'" & year == 2030, se(`se30')

    predictnl `diff35' = predict(xb) - `xb24' ///
        if agegroup == "`k'" & year == 2035, se(`se35')

    quietly sum `diff30' if agegroup == "`k'" & year == 2030
    local d30 = r(mean)
    quietly sum `se30' if agegroup == "`k'" & year == 2030
    local s30 = r(mean)

    quietly sum `diff35' if agegroup == "`k'" & year == 2035
    local d35 = r(mean)
    quietly sum `se35' if agegroup == "`k'" & year == 2035
    local s35 = r(mean)

    * % change = 100*(exp(d) - 1), CI on log scale then exponentiate
    replace pct_2024_2030_est = 100*(exp(`d30') - 1) if agegroup == "`k'" & year == 2030
    replace pct_2024_2030_lb = 100*(exp(`d30' - 1.96*`s30') - 1) if agegroup == "`k'" & year == 2030
    replace pct_2024_2030_ub = 100*(exp(`d30' + 1.96*`s30') - 1) if agegroup == "`k'" & year == 2030

    replace pct_2024_2035_est = 100*(exp(`d35') - 1) if agegroup == "`k'" & year == 2035
    replace pct_2024_2035_lb = 100*(exp(`d35' - 1.96*`s35') - 1) if agegroup == "`k'" & year == 2035
    replace pct_2024_2035_ub  = 100*(exp(`d35' + 1.96*`s35') - 1) if agegroup == "`k'" & year == 2035

    drop s1 s2 s3
}

foreach var of varlist pct_2024_2030_est pct_2024_2030_lb pct_2024_2030_ub ///
                       pct_2024_2035_est pct_2024_2035_lb pct_2024_2035_ub {
    bysort agegroup: egen `var'_fill = max(`var')
    drop `var'
    rename `var'_fill `var'
}

foreach k of local groups {
    quietly sum pct_2024_2030_est if agegroup == "`k'"
    local e30: di %5.1f r(mean)
    quietly sum pct_2024_2030_lb if agegroup == "`k'"
    local l30: di %5.1f r(mean)
    quietly sum pct_2024_2030_ub if agegroup == "`k'"
    local u30: di %5.1f r(mean)
    quietly sum pct_2024_2035_est if agegroup == "`k'"
    local e35: di %5.1f r(mean)
    quietly sum pct_2024_2035_lb if agegroup == "`k'"
    local l35: di %5.1f r(mean)
    quietly sum pct_2024_2035_ub if agegroup == "`k'"
    local u35: di %5.1f r(mean)

    di "`k' | `e30'% (`l30' to `u30') | `e35'% (`l35' to `u35')"
}

*** % change for observed data ***
gen pct_obs_est = .
gen pct_obs_lb = .
gen pct_obs_ub = .

local groups "20_34 35_49 50_64 65_79 80+"

foreach k of local groups {
    quietly sum visits if agegroup == "`k'" & year == 2022
    local n22 = r(mean)

    quietly sum visits if agegroup == "`k'" & year == 2024
    local n24 = r(mean)
    local logratio = ln(`n24' / `n22')
    local se_log = sqrt(1/`n24' + 1/`n22')

    * % change and CI
    quietly replace pct_obs_est = 100*(exp(`logratio') - 1) if agegroup == "`k'"
    quietly replace pct_obs_lb = 100*(exp(`logratio' - 1.96*`se_log') - 1) if agegroup == "`k'"
    quietly replace pct_obs_ub = 100*(exp(`logratio' + 1.96*`se_log') - 1) if agegroup == "`k'"
}


foreach k of local groups {
    quietly sum pct_obs_est if agegroup == "`k'"
    local e: di %5.1f r(mean)
    quietly sum pct_obs_lb if agegroup == "`k'"
    local l: di %5.1f r(mean)
    quietly sum pct_obs_ub if agegroup == "`k'"
    local u: di %5.1f r(mean)
    di "`k' | `e'% (`l' to `u')"
}
