************************************************
*** script to manipulate courses data **********
************************************************


************************************************
************** standard headers ****************
************************************************
cap clear all
cap log close
set more off, perm


************************************************
*** read in base course file *******************
************************************************
* change working dir to the local filespace with data
cd "/Users/brianjohnson/Documents/Documents/University_of_Michigan/SOE/Fall_2017/EDUC_771/project/data_flow/"
* read in the excel file for the base cohort: 09FL_exogenous_cohort.xlsx
import excel "COURSES_09FL_first-time-undergrad_cohort.xlsx", sheet("Sheet1") firstrow clear


************************************************
*** clean up the data **************************
************************************************

* drop unnecessary columns
drop EnrolledCourseSubject EnrolledCourseName EnrolledCourseLocation EnrollmentCurrentStatus

* rename variables
rename EnrollmentTerm term
rename SectionCreditValueJ10 creditVal
rename EnrollmentCourseTypeJ10 courseType
rename EnrolledVerifiedGradeJ10 courseGrade

* drop any records with missing values for any of the variables
foreach x of varlist term creditVal courseType {
	drop if missing(`x')
} // note that did not drop missing grade values because these represent audits, withdrawals, pass/fail

* change variable labels
label variable key "student key identifier"
label variable term "enrollment term"
label variable creditVal "course credit value"
label variable courseType "course format"
label variable courseGrade "grade earned in course"


************************************************
*** recode vars as necessary *******************
************************************************

* change non-GPA-scale grades to missing values
replace courseGrade = "" if courseGrade == "21" 
replace courseGrade = "0" if courseGrade == "27" 
replace courseGrade = "" if courseGrade == "28" 
replace courseGrade = "" if courseGrade == "55" 
replace courseGrade = "" if courseGrade == "E" 
replace courseGrade = "" if courseGrade == "I" 
replace courseGrade = "" if courseGrade == "P" 
replace courseGrade = "" if courseGrade == "Y"

* change courseGrade to a number
destring courseGrade, replace


************************************************
* collapse vars to one record per student per term 
************************************************
 
 * generate dummy variables for each courseType option
gen basicSkiCreds = 0
replace basicSkiCreds = creditVal if courseType == "B"
gen coopWorkCreds = 0
replace coopWorkCreds = creditVal if courseType == "COOP"
gen exprmntlCreds = 0
replace exprmntlCreds = creditVal if courseType == "EXP"
gen hybridCreds = 0
replace hybridCreds = creditVal if courseType == "HYB" | courseType == "HYBýSTND"
gen internetCreds = 0
replace internetCreds = creditVal if courseType == "IBL"
gen lrningComCreds = 0
replace lrningComCreds = creditVal if courseType == "COM"
gen openopexCreds = 0
replace openopexCreds = creditVal if courseType == "OEOE"
gen standardCreds = 0
replace standardCreds = creditVal if courseType == "STND" | courseType == "STNDýEXP" | courseType == "STNDýIBL"

* label the new dummy variables
label variable basicSkiCreds "basic skills credits"
label variable coopWorkCreds "cooperative work experience creds"
label variable exprmntlCreds "experimental credits"
label variable hybridCreds "hybrid credits"
label variable internetCreds "internet credits"
label variable lrningComCreds "learning community credits"
label variable openopexCreds "open entry exit credits"
label variable standardCreds "standard-type credits"

* drop courseType after generating the dummies but before collapsing
drop courseType

* collapse by student and term, taking the sum of creditVal, avg of courseGrade,
* and the sum of dummies
collapse (sum) creditVal (mean) courseGrade (sum) basicSkiCreds (sum) coopWorkCreds ///
(sum) exprmntlCreds (sum) hybridCreds (sum) internetCreds (sum) lrningComCreds ///
(sum) openopexCreds (sum) standardCreds, by(key term)
* relabel the variables
label variable creditVal "credits taken in term"
label variable courseGrade "GPA for term"
label variable basicSkiCreds "basic skills format credits taken in term"
label variable coopWorkCreds "cooperative work format credits taken in term"
label variable exprmntlCreds "experimental format credits taken in term"
label variable hybridCreds "hybrid format credits taken in term"
label variable internetCreds "internet format credits taken in term"
label variable lrningComCreds "learning community format credits taken in term"
label variable openopex "open entry exit format credits taken in term"
label variable standardCreds "standard format credits taken in term"


************************************************
*** save out final dataset *********************
************************************************

save "course_vars.dta", replace
