************************************************
*** script to manipulate exogenous predictors **
************************************************


************************************************
************** standard headers ****************
************************************************
cap clear all
cap log close
set more off, perm


************************************************
*** read in base cohort file *******************
************************************************
* change working dir to the local filespace with data
cd "/Users/brianjohnson/Documents/Documents/University_of_Michigan/SOE/Fall_2017/EDUC_771/project/data_flow/"
* read in the excel file for the base cohort: EXOGENOUS_09FL_first-time-undergrad_cohort.xlsx
import excel "EXOGENOUS_09FL_first-time-undergrad_cohort.xlsx", sheet("Sheet1") firstrow clear


************************************************
*** clean up the data **************************
************************************************
* rename zip to be zipCode, because zip is reserved word, and convert to string
rename zip zipCode
tostring zipCode, replace
* drop any records with missing values for any of the variables
foreach x of varlist enrollAge gender raceEthnic zipCode transCred devMath devRead devWrite {
	drop if missing(`x')
}
* drop the zipCode values that are 0
drop if zipCode == "0"
* change variable labels
label variable key "student key identifier"
label variable enrollAge "age in fall of 2009"
label variable gender "gender"
label variable raceEthnic "race except if hispanic"
label variable zipCode "zip code of residence at enroll"
label variable transCred "transfered credits at enroll"
label variable devMath "math placement levels below college-ready"
label variable devRead "reading placement levels below college-ready"
label variable devWrite "writing placement levels below college-ready"


************************************************
*** assign numeric codes to categorical vars ***
************************************************
* for gender
generate male = 0
replace male = 1 if gender == "M"
drop gender
label variable male "student gender"
label define male_ 0 "female" 1 "male"
label values male male_
* for raceEthnic
drop if raceEthnic == "UN" | raceEthnic == "HP" /* drop unknown and Hawaiian-Pac. Is. because of sample size */
generate raceEthnic2 = .
replace raceEthnic2 = 0 if raceEthnic == "WH"
replace raceEthnic2 = 1 if raceEthnic == "BL"
replace raceEthnic2 = 2 if raceEthnic == "HIS"
replace raceEthnic2 = 3 if raceEthnic == "AN"
replace raceEthnic2 = 4 if raceEthnic == "AS"
label define raceEthnic2_ 0 "White" 1 "Black" 2 "Hispanic" 3 "Alaska/Native Am." 4 "Asian"
label values raceEthnic2 raceEthnic2_
drop raceEthnic
rename raceEthnic2 raceEthnic
label variable raceEthnic "student race/ethnicity"


************************************************
*** final recode tasks *************************
************************************************
* merge in the distances associated with zipCode
* dropping any cases (should've been just 1) that did
* not have a valid zip code distance returned in zips.dta
merge m:1 zipCode using "/Users/brianjohnson/Documents/Documents/University_of_Michigan/SOE/Fall_2017/EDUC_771/project/driving_distance/zips.dta", keep(match)
* drop the merge type code auto field
drop _merge
* drop zipCode, which is no longer necessary
drop zipCode
* rename distance to distCampus
rename distance distCampus


****************************************************
* do a check merge of course data, so that you can *
* drop any exogenous records for people who never  *
* had any enrollment records ***********************
****************************************************
gen term = "09/FL"
order key term
merge 1:1 key term using "course_vars.dta"
drop if _merge == 1 | _merge == 2
keep key enrollAge transCred devMath devRead devWrite male raceEthnic distCampus


**************************************************
* last, expand each row 21 additional times so   *
* that each person has 22 terms, enrolled or not *
**************************************************
expand 22
sort key
by key: gen term_num = _n
label variable term_num "number of the semester out of 22-term sequence"
gen term = ""
label variable term "semester label in academic year"
replace term = "09/FL" if term_num == 1 // then give the new terms the proper term labels
replace term = "10/WN" if term_num == 2
replace term = "10/SP" if term_num == 3
replace term = "10/FL" if term_num == 4
replace term = "11/WN" if term_num == 5
replace term = "11/SP" if term_num == 6
replace term = "11/FL" if term_num == 7
replace term = "12/WN" if term_num == 8
replace term = "12/SP" if term_num == 9
replace term = "12/FL" if term_num == 10
replace term = "13/WN" if term_num == 11
replace term = "13/SP" if term_num == 12
replace term = "13/FL" if term_num == 13
replace term = "14/WN" if term_num == 14
replace term = "14/SP" if term_num == 15
replace term = "14/FL" if term_num == 16
replace term = "15/WN" if term_num == 17
replace term = "15/SP" if term_num == 18
replace term = "15/FL" if term_num == 19
replace term = "16/WN" if term_num == 20
replace term = "16/SP" if term_num == 21
replace term = "16/FL" if term_num == 22
order key term term_num


************************************************
*** save out final dataset *********************
************************************************

save "exogenous_vars.dta", replace



