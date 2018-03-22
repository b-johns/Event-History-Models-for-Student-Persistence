************************************************
*** script to manipulate housing data **********
************************************************


************************************************
************** standard headers ****************
************************************************
cap clear all
cap log close
set more off, perm


************************************************
*** read in base housing file ******************
************************************************
* change working dir to the local filespace with data
cd "/Users/brianjohnson/Documents/Documents/University_of_Michigan/SOE/Fall_2017/EDUC_771/project/data_flow/"
* read in the excel file for the base cohort: 09FL_exogenous_cohort.xlsx
import excel "HOUSING_09FL_first-time-undergrad_cohort.xlsx", sheet("Report 1") firstrow clear


************************************************
*** clean up the data **************************
************************************************

* keep only the vars that you need
drop RoomAssignmentBuilding RoomAssignmentCurrentStatus RoomAssignmentCurrentStatusD ///
RoomAssignmentStartDate

* rename and relabel term
rename RoomAssignmentTerm term
label variable term "enrollment term"


************************************************
*** recode vars as necessary *******************
************************************************

* create a dummy for lived on campus in that term with val of 1 for all
gen housed = 1
label variable housed "lived on campus during semester"
label define hous 0 "off-campus" 1 "on-campus"
label values housed hous


************************************************
*** save out final dataset *********************
************************************************
* drop any no-key values and duplicated rows
drop if missing(key)
duplicates drop

save "housing_var.dta", replace
