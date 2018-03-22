************************************************
*** script to manipulate awards data ***********
************************************************


************************************************
************** standard headers ****************
************************************************
cap clear all
cap log close
set more off, perm


************************************************
*** read in base awards file *******************
************************************************
* change working dir to the local filespace with data
cd "/Users/brianjohnson/Documents/Documents/University_of_Michigan/SOE/Fall_2017/EDUC_771/project/data_flow/"
* read in the excel file for the base cohort: 09FL_exogenous_cohort.xlsx
import excel "AWARDS_09FL_first-time-undergrad_cohort.xlsx", sheet("Sheet1") firstrow clear


************************************************
*** clean up the data **************************
************************************************

* drop unneeded columns
drop CredentialAcademicProgram ProgramTitle

* rename terms
rename CredentialTermJ10 term
label variable term "enrollment term"

* rename the degree fields
rename CredentialCCD1 skillsCerts
rename CredentialDegree associates


************************************************
*** recode vars as necessary *******************
************************************************

* create a combined degree field and recode weird codes
gen degreeEarn = skillsCerts
replace degreeEarn = associates if missing(degreeEarn)
replace degreeEarn = "AGS" if degreeEarn == "202"

* drop the prior two degrees fields
drop skillsCerts associates

* recode the combined degree to just be associates and certificates
replace degreeEarn = "Assoc" if degreeEarn == "AA" | degreeEarn == "AAS" | ///
degreeEarn == "AGS" | degreeEarn == "AS"
replace degreeEarn = "Cert" if degreeEarn == "CERT"

* drop all records of skill sets and concentrations
foreach x of varlist degreeEarn {
	drop if degreeEarn == "SSC" | degreeEarn == "COND" | degreeEarn == "SSET"
}

* recode the new combined degree field
encode degreeEarn, generate(degreeEarn2)
drop degreeEarn
rename degreeEarn2 degreeEarn

* prioritize the entries by person so associate's degree is privileged by giving
* certificates a 0 and associate's a 1 and then summing by person and term
replace degreeEarn = 0 if degreeEarn == 2
label define deg 1 "Assoc" 0 "Cert"
label values degreeEarn deg

* collapse the variables by person and term using a sum
collapse (sum) degreeEarn, by(key term)

* relabel the final degreeEarn variable
label variable degreeEarn "highest degree earned in term if any"
replace degreeEarn = 1 if degreeEarn > 1
label values degreeEarn deg


************************************************
*** save out final dataset *********************
************************************************

save "awards_vars.dta", replace




