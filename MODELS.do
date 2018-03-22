********************************************************************************
* script for creating stop-out stcox regressions with graduation competing risk
* using a 1-, 2-, and 3-semester-non-enrolled definition of stop-out
********************************************************************************

* setup
set more off
capture clear
local data_path "/Users/brianjohnson/Documents/Documents/University_of_Michigan/SOE/Fall_2017/EDUC_771/project/data_flow/"
local out_path "/Users/brianjohnson/Documents/Documents/University_of_Michigan/SOE/Fall_2017/EDUC_771/project/analysis/"
cap log close
log using "`out_path'stopout_results.log", replace

* load data
use "`data_path'O9FL_cohort_final_semesters.dta"

* drop not appropriate for this particular run of regressions
drop creditVal internetCreds hybridCreds standardCreds basicSkiCreds coopWorkCreds exprmntlCreds lrningComCreds openopexCreds // drop these because of colinearity issue that they track too closely with enrollment; if not enrolled, these are always 0
drop housed // same colinearaity issue as with credits enrolled vars: this tracks too closely with enrollment, as in when not enrolled this is 0 always
drop pell // drop because redundant with other fin aid vars
drop workStud // drop this because too few people had it

* build up list of regressors to use in each model
local xvar_1 "c.enrollAge c.transCred c.distCampus i.devMath i.devRead i.devWrite i.male i.raceEthnic"
local xvar_1 "`xvar_1' c.cumGPA c.loans c.schlrshp c.grants"


********* creating different outcomes based on different definitions of stopout ******

* 1-semester definition
// already included in outcome, as originally defined

* 2-semester defintion
gen outcome2 = . // gen the new outcome
by key: replace outcome2 = 2 if outcome[_n] == 2 & outcome[_n - 1] == 2
replace outcome2 = 3 if outcome == 3
replace outcome2 = 1 if outcome2 == .
label variable outcome2 "2-term stopout definition semester outcome for student"
label values outcome2 outcome_
order key term term_num outcome outcome2

* 3-semester definition
gen outcome3 = .
by key: replace outcome3 = 2 if outcome[_n] == 2 & outcome[_n - 1] == 2 & outcome[_n - 2] == 2
replace outcome3 = 3 if outcome == 3
replace outcome3 = 1 if outcome3 == .
label variable outcome3 "3-term stopout definition semester outcome for student"
label values outcome3 outcome_
order key term term_num outcome outcome2 outcome3


************************* models ******************************

* 1-semester stop-out definition competing against graduation
stset term_num, failure(outcome = 2) id(key) exit(outcome = 2 3) // set data
sts graph, title("1-Semester Stop-Out Kaplan-Meier Survivor Function",size(medium)) ///
xlabel(0(5)20) saving("`out_path'1-semester_non-param_survivor.gph",replace) // non-parametric survivor function estimate
graph save g1.gph
stcrreg `xvar_1', compete(outcome = 3) tvc(`xvar_1') texp(_t) // run the competing-risk cox
eststo // store results for writing out

* 2-semester stop-out definition competing against graduation
stset term_num, failure(outcome2 = 2) id(key) exit(outcome2 = 2 3)
sts graph, title("2-Semester Stop-Out Kaplan-Meier Survivor Function",size(medium)) ///
xlabel(0(5)20) saving("`out_path'2-semester_non-param_survivor.gph",replace)
graph save g2.gph
stcrreg `xvar_1', compete(outcome2 = 3) tvc(`xvar_1') texp(_t)
eststo

* 3-semester stop-out definition competing against graduation
stset term_num, failure(outcome3 = 2) id(key) exit(outcome3 = 2 3)
sts graph, title("3-Semester Stop-Out Kaplan-Meier Survivor Function",size(medium)) ///
xlabel(0(5)20) saving("`out_path'3-semester_non-param_survivor.gph",replace)
graph save g3.gph
stcrreg `xvar_1', compete(outcome3 = 3) tvc(`xvar_1') texp(_t)
eststo

* create a combined graph for the Kaplan-Meier survival function estimates of all stop-out definitions
graph combine g1.gph g2.gph g3.gph, colfirst saving("`out_path'all-def_non-param_survivors.gph",replace)

* write out results for models
esttab using "`out_path'results.csv", se eform replace

