************************************************
** script to manipulate exogenous predictors ***
************************************************


************************************************
************** standard headers ****************
************************************************
cap clear all
cap log close
set more off, perm
cd "/Users/brianjohnson/Documents/Documents/University_of_Michigan/SOE/Fall_2017/EDUC_771/project/data_flow/"


*****************************************************************************
* start with exogenous vars file, with its 22 terms per student, then merge *
* in the enrollment events in the time-variant file to get actual enrollent *
*****************************************************************************
use "exogenous_vars.dta"
merge 1:1 key term using "time-variant_vars.dta"
drop if _merge == 2
drop _merge
sort key term_num


******************************************************************************
* generate an outcome variable stating whether that term was 1 enrollment or *
* 2 non-enrollment or 3 graduation *******************************************
******************************************************************************
gen outcome = .
replace outcome = 1 if creditVal != .
replace outcome = 2 if creditVal == .
replace outcome = 3 if degreeEarn != . //might later break this into 3 & 4 for cert & assoc
label variable outcome "semester outcome for student"
label define outcome_ 1 "enrollment" 2 "non-enrollment" 3 "graduation"
label values outcome outcome_
drop degreeEarn
order key term term_num outcome
sort key term_num


******************************************************************************
* now fill in the time-variant values for non-enrollment terms with 0s for ***
* term-specific measures like creditVal, and freezes of cumulative values ****
* like cumGPA ****************************************************************
******************************************************************************
replace basicSkiCreds = 0 if creditVal == .
replace coopWorkCreds = 0 if creditVal == .
replace exprmntlCreds = 0 if creditVal == .
replace hybridCreds = 0 if creditVal == .
replace internetCreds = 0 if creditVal == .
replace lrningComCreds = 0 if creditVal == .
replace openopexCreds = 0 if creditVal == .
replace standardCreds = 0 if creditVal == .
replace cumGPA = cumGPA[_n - 1] if creditVal == .  // this one is tricky; you're essentially freezing this one while person not enrolled
replace housed = 0 if creditVal == .
replace loans = loans[_n - 1] if creditVal == . // freeze this one too, because this is awarded, likely still eligible for same value when not enrolled
replace schlrshp = schlrshp[_n - 1] if creditVal == . // freeze this one too, because it's awarded, not accepted
replace grants = grants[_n - 1] if creditVal == . // freeze this one too, because award
replace workStud = workStud[_n - 1] if creditVal == . // freeze this one too, because award
replace pell = pell[_n - 1] if creditVal == .  // freeze too, because eligibility likely same when not enrolled
replace creditVal = 0 if creditVal == . // this is last one to fill in, because others above rely on creditVal missing cases to calculate


**************************************************************************
************* save out final, merged dataset for analysis ****************
**************************************************************************

save "O9FL_cohort_final_semesters.dta", replace


