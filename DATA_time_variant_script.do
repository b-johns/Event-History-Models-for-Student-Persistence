************************************************
** script to manipulate exogenous predictors ***
************************************************


************************************************
************** standard headers ****************
************************************************
cap clear all
cap log close
set more off, perm


**************************************************************************
* first read in, number, and sort enrollment events from course_vars.dta *
**************************************************************************
cd "/Users/brianjohnson/Documents/Documents/University_of_Michigan/SOE/Fall_2017/EDUC_771/project/data_flow/"

use "course_vars.dta"

* first create a variable that is the ordering of the term within the scope of the study
gen term_num = 0
replace term_num = 1 if term == "09/FL"
replace term_num = 2 if term == "10/WN"
replace term_num = 3 if term == "10/SP"
replace term_num = 4 if term == "10/FL"
replace term_num = 5 if term == "11/WN"
replace term_num = 6 if term == "11/SP"
replace term_num = 7 if term == "11/FL"
replace term_num = 8 if term == "12/WN"
replace term_num = 9 if term == "12/SP"
replace term_num = 10 if term == "12/FL"
replace term_num = 11 if term == "13/WN"
replace term_num = 12 if term == "13/SP"
replace term_num = 13 if term == "13/FL"
replace term_num = 14 if term == "14/WN"
replace term_num = 15 if term == "14/SP"
replace term_num = 16 if term == "14/FL"
replace term_num = 17 if term == "15/WN"
replace term_num = 18 if term == "15/SP"
replace term_num = 19 if term == "15/FL"
replace term_num = 20 if term == "16/WN"
replace term_num = 21 if term == "16/SP"
replace term_num = 22 if term == "16/FL"

* label term_num
label variable term_num "order of term within entire 22 term sequence"

* calculate running mean of courseGrade then drop it
sort key term_num
by key: gen cumGPA = sum(courseGrade) / _n
drop courseGrade


**************************************************************************
************* merge in housing data **************************************
**************************************************************************
merge 1:1 key term using "housing_var.dta"
* drop those records from housing that had no corresponding key term pair in master
drop if _merge == 2
* change the missing values in housed to 0 (i.e. key term had no corresponding housing
* record in the housing file)
replace housed = 0 if housed == .
* drop the _merge codes auto generated column
drop _merge


**************************************************************************
************* merge in finaid data ***************************************
**************************************************************************
merge 1:1 key term using "finaid_vars.dta"
* drop those records from fin aid that had no corresponding key term pair in master
drop if _merge == 2
* change the missing values for all the new fin aid variables (i.e. had no 
* corresponding key term match in fin aid) to 0
replace loans = 0 if loans == .
replace schlrshp = 0 if schlrshp == .
replace grants = 0 if grants == .
replace workStud = 0 if workStud == .
replace pell = 0 if pell == .
* drop the _merge codes auto generated column
drop _merge


*******************************************************************************
************* merge in graduation data ****************************************
*******************************************************************************
merge 1:1 key term using "awards_vars.dta"
* drop graduation events that did not have a key term match in master
drop if _merge == 2
* drop _merge
drop _merge
* resort vars after all of the manipulation you just did
sort key term_num


**************************************************************************
************* final misc steps *******************************************
**************************************************************************
* label and rescale cumGPA
label variable cumGPA "student cumulative GPA at each enrollment term multiplied by 10"
replace cumGPA = cumGPA * 10
* rescale all fin aid vars to units of $1000 for interpretability
foreach x of varlist loans schlrshp grants workStud {
	replace `x' = `x' / 1000
}
* rescale all core credit vars to 3-credit units, which is a typical class
replace creditVal = creditVal / 3
replace standardCreds = standardCreds / 3
replace internetCreds = internetCreds / 3
replace hybridCreds = hybridCreds /3



**************************************************************************
************* save out final, merged time-variant dataset for analysis ***
**************************************************************************

save "time-variant_vars.dta", replace


