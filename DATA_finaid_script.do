************************************************
*** script to manipulate finaid data **********
************************************************


************************************************
************** standard headers ****************
************************************************
cap clear all
cap log close
set more off, perm


************************************************
*** read in base finaid file *******************
************************************************
* change working dir to the local filespace with data
cd "/Users/brianjohnson/Documents/Documents/University_of_Michigan/SOE/Fall_2017/EDUC_771/project/data_flow/"
* read in the excel file for the base cohort: 09FL_exogenous_cohort.xlsx
import excel "FINAID_09FL_first-time-undergrad_cohort.xlsx", sheet("Report 1") firstrow clear


************************************************
*** clean up the data **************************
************************************************

* keep only the vars that you need
drop AwardAcademicYear AwardAction AwardActionDesc AwardTransmittedAmount

* rename and relabel term
rename AwardPeriodID term
label variable term "enrollment term"

* rename and relabel awardAmt
rename AwardTermAmount awardAmt
label variable awardAmt "award amuont"

* rename and relabel awardDesc
rename AwardDescriptionJ10 awardDesc
label variable awardDesc "award type description"

* rename and relabel awardId
rename AwardID awardId
label variable awardId "award type ID"

* rename and relabel awardType
rename AwardType awardType
label variable awardType "state, institutional, federal, other award"

* drop any records with missing data
foreach x of varlist awardAmt awardDesc awardId {
	drop if missing(`x')
}


************************************************
*** recode vars as necessary *******************
************************************************

* create dummy vars for loans, scholarships, grants, work-study, Pell-eligible
gen loans = 0
replace loans = awardAmt if awardId == "L153" | awardId == "L155" | awardId == "LDAUN" | ///
awardId == "LDSI1" | awardId == "LDSU1" | awardId == "LDSU2" | awardId == "LDUI1" | ///
awardId == "LDUN1" | awardId == "LDUN2" | awardId == "LDUN3" | awardId == "LDUNJ" | ///
awardId == "LSUB1" | awardId == "LSUB2" | awardId == "LUNS1" | awardId == "LUNS2" | ///
awardId == "LUNS3" 
gen schlrshp = 0
replace schlrshp = awardAmt if awardType == "I"
gen grants = 0
replace grants = awardAmt if awardType == "O" | awardType == "S" | awardId == "ACG1" | awardId == "EMP" | awardId == "EMPS" | ///
awardId == "FPELL" | awardId == "FSEOGG"
gen workStud = 0
replace workStud = awardAmt if awardId == "FWS"
gen pell = 0
replace pell = 1 if awardId == "FPELL"

*label the new dummies
label variable loans "loan amount in term"
label variable schlrshp "scholarship amount in term"
label variable grants "grant amount in term"
label variable workStud "work-study amount in term"
label variable pell "Pell-eligible"

* drop any unneeded and unnecessary vars
drop awardDesc awardId awardAmt awardType

* collapse the loan, scholarship, grant, work study, and Pell variables by student key
* and term
collapse (sum) loans (sum) schlrshp (sum) grants (sum) workStud (sum) pell, by(key term)

* recode Pell into a boolean
label define pellell 0 "not-eligible" 1 "eligible"
label values pell pellell

* relabel the finished variables
label variable loans "loan amount for term"
label variable schlrshp "scholarship amount for term"
label variable grants "grants amount for term"
label variable workStud "work study amount for term"
label variable pell "Pell-eligible for term"


************************************************
*** save out final dataset *********************
************************************************

save "finaid_vars.dta", replace
