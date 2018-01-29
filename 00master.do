/*==============================================================================
File name:    00master.do
Task:         Sets up and executes analysis                                                      
Paper:        Early maternal employment and children’s vocabulary 
              and inductive reasoning ability: A dynamic approach
Author(s):    Michael Kuehhirt, Markus Klein                                               
Last update:  2018-01-24                                                                               
==============================================================================*/


/*------------------------------------------------------------------------------ 
About this dofile:

#1 installs ado files used in the analysis
#2 specifies directories in globals
#3 specifies globals for groups of variables (different model specifications)
#4 specifies order and task of code files and runs them
------------------------------------------------------------------------------*/


/*------------------------------------------------------------------------------
Notes:
------------------------------------------------------------------------------*/

version 14.2         // Stata version control

clear all            // clear memory

macro drop _all      // delete all macros

set linesize 82      // result window has room for 82 chars in one line

set more off, perm   // prevents pause in results window

set scheme plotplain // sets color scheme for graphs

set matsize 1000     // size of data matrix


/*------------------------------------------------------------------------------
#1 Install ado files                                                         
------------------------------------------------------------------------------*/

*ssc install estout, replace
*ssc install blindschemes, replace all

net from http://digital.cgdev.org/doc/stata/MO/Misc
net install grc1leg2, replace
 


/*------------------------------------------------------------------------------
#2 Specify folder directories
------------------------------------------------------------------------------*/

* clear memory
clear all 

* working directory (for replication, specify your own path)
global wdir "/Users/wmb222/Dropbox/Arbeit/projects/015sibadd"


* directory for original data (for replication, use commented path below)
global origdat "/Users/wmb222/Documents/Research Data/GUS"
*global origdat "${wdir}/data/original"


* directory for R (for replication, specify your own path)
global rpath "/usr/local/bin/R"


* subfolders in work directory
global code    "${wdir}/code"               // for code files
global prepdat "${wdir}/data/prepared"      // for prepared data
global tables  "${wdir}/tables"             // for tables
global graphs  "${wdir}/figures"            // for figures
global cbook   "${wdir}/docu/codebooks"     // for codebooks


/*------------------------------------------------------------------------------
#3 Specify globals for covariate names

!!! no of residential moves (rmove) needs to be added manually !!!
------------------------------------------------------------------------------*/

* time-invariant covariates 
#delimit ;
global tinvarA "
kidmale0
careunit0
lbweight0
medpreg0
unplan01
unplan02
unplan03
agebrthc0
educat01
educat02
educat03
educat04
educat05
prgwrk0
childcare0
"
;                   
#delimit cr


* time-varying covariates 
#delimit ;
global tvarA "
cldill
concdev
mumill
sibcat1
sibcat2
sibcat3
parstat1
parstat2
parstat3
parstat4
parstat5
hhinc
homeown
urban
depriv
"
;                   
#delimit cr


* Generated covariates (tvar at baseline, t-1, mean-centered etc)
foreach m in A {
global tvar0`m'      ""                         // tvar at baseline
global tvar_nd`m'    ""                         // tvar at t-1
global tvar_av`m'    ""                         // tvar averaged over waves
foreach v of global tvar`m' {
global tvar0`m'      "${tvar0`m'} `v'0"
global tvar_nd`m'    "${tvar_nd`m'} `v'_nd"
global tvar_av`m'    "${tvar_av`m'} `v'_av"
}
foreach g in tinvar tvar0 tvar_av{
global `g'_mc`m'   ""                           // mean-centered
foreach v of global `g'`m' {
global `g'_mc`m'   "${`g'_mc`m'} `v'_mc"
}
}
}


/*------------------------------------------------------------------------------
#4 Specify name, task and sequence of code files to run
------------------------------------------------------------------------------*/

/*
do "${code}/01cr_guslong.do"           // combines Sweeps 1-5 of GUS
do "${code}/02cr_emphist.do"           // maternal employment sequences 
* run R script for sequence analysis
cd "$wdir"
shell "${rpath}" CMD BATCH            /// sequence complexity and clusters
      "$code/03cr_clust.R"
do "${code}/04cr_clust.do"             // converts cluster data to Stata format
do "${code}/05cr_guswgt.do"            // produces treatment models and weights 
do "${code}/06cr_andata.do"            // combines GUS, clusters, weights
do "${code}/07an_verify.do"            // consistency checks
do "${code}/08an_sample.do"            // sample description and codebook 
do "${code}/09an_outmod.do"            // produces outcome model results
*/

*==============================================================================*
