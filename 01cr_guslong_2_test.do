/*==============================================================================
File name:    01cr_guslong.do
Task:         combines Sweeps 1-5 of GUS                                                      
Project:      Sibling addition and child development
Author(s):    Michael Kuehhirt, Markus Klein                                               
Last update:  2016-11-14                                                                                
==============================================================================*/


/*------------------------------------------------------------------------------ 
About this dofile:

#1 combines the relevant information on GUS Birth Cohort 1 from all "sweeps"
#2 recodes variables
#3 defines samples for analysis
#4 labels and orders variables
------------------------------------------------------------------------------*/


/*------------------------------------------------------------------------------
Notes:
------------------------------------------------------------------------------*/

version 14.0   // Stata version control


/*------------------------------------------------------------------------------
#1 Combine relevant variables in one dataset
------------------------------------------------------------------------------*/

* give original data files friendlier names (gus1-gus6) and sort by Idnumber 
local i=1
foreach j in gus_cohort1_sw1_b_v4        /// GUS BC1 Sweep1
             gus_cohort1_sw2_b_nov11     /// GUS BC1 Sweep2
             gus_cohort1_sw3_b_nov11     /// GUS BC1 Sweep3
             gus_cohort1_sw4_b_nov11     /// GUS BC1 Sweep4
             gus_cohort1_sw5_b           /// GUS BC1 Sweep5
             gus_cohort1_sw6_b           /// GUS BC1 Sweep6		 
{                                    
capture use "${origdat}/`j'.dta", clear  //  load data
capture sort Idnumber                    //  sort by Idnumber
capture save "${origdat}/gus`i'.dta"     //  save data with new name
capture erase "${origdat}/`j'.dta"       //  delete data with old name
local i=`i'+1
}  


* load time-constant covariates and auxiliary variables from Sweep 1 data
use "${origdat}/gus1.dta", clear


* inspect data
describe                   // show all variables contained in data
notes                      // show all notes contained in data
*codebook, problems         // potential problems in dataset
duplicates report Idnumber // duplicates?


* keep relevant information 
keep Idnumber   /// child's person ID
     MaHGsx1    ///
	 DaHGnp01   ///
	 DaHGbord   ///
	 DaHGmag5   ///
	 DaAgBMum   ///
	 MaMage01   /// 
	 MaPGpl01   ///	 
	 MaPGil01   /// 
	 MaPGil20   /// 
	 MaPGil29   /// 
	 MaPGan01   ///
     MaPGan04	/// 
	 MaPGan14   /// 
	 MaPGan15   /// 
	 MaBtim01   /// 
	 MaBtim02   /// 
	 MaBtim03   /// 
	 MaBtyp01   /// 
	 MaBneo01   /// 
	 DaLwBWt    ///
	 MaMtmk01   ///
	 MaBFDe01   /// 
	 MaBFDs01   /// 
	 MaBFDl01   /// 
	 MaBFDd01   /// 
	 MaBFDw01   /// 
	 MaBFDm01   ///  
	 MaMkds01   ///
	 MaWsts01   /// 
	 MaWsts02   /// 
	 MaWevr01   /// 
	 MaWprg01   /// 
	 MaWprg02   /// 
	 MaWprg03   /// 
	 MaWpnt01   /// 
	 MaWpnt03   /// 
	 MaWpnt04   /// 
	 MaMorg01   /// 
	 MaBorg01   /// 
	 DaEthGpM   /// 
	 DaEthGpC   /// 
	 DaReligM   /// 
	 DaReligC   /// 
	 DaWTbrth   ///
	 DaGraPar   ///
	 MaGliv01   ///
	 MaGcon02   ///
	 MaIhea05   ///
	 MaIhea06   ///
	 MaIhea07   ///
	 MaIhea08   ///
	 MaIhea09   ///
	 MaIhea10   ///
	 DaCtyp01   ///
	 DaCtyp02   ///
	 DaMedu03   ///
	 MaYevr01   ///
	 MaYnow01   ///
	 MaYtim01   ///
	 MaZhou14   ///
	 MaHalc04   ///
	 MaHcig01   ///
	 MaHdrg*    ///
	 DaCtyp11   ///
	 
	 
	 
* merge cognitive measures at age 3 and 5
local j=3
foreach i in c e {
sort Idnumber
merge 1:1 Idnumber using "$origdat/gus`j'.dta",            ///
      keepusing(D`i'PicRaw D`i'PicSAS D`i'PicSTS D`i'PicSPt  /// picture similarities
	            D`i'NamRaw D`i'NamVAS D`i'NamVTS D`i'NamVPt) /// naming vocabulary
				keep(1 3) nogen nolabel
local j=`j'+2
}
				
		
* merge SDQ-Scores at age 5 and 6
local j=5
foreach i in e f {
sort Idnumber
merge 1:1 Idnumber using "${origdat}/gus`j'.dta", 	///
      keepusing(D`i'Dsdem1 D`i'Dsdco1 D`i'Dsdhy1 	///
				D`i'Dsdpr1 D`i'Dsdps1 D`i'Dsdto1)	///
      keep(1 3) nogen nolabel
local j=`j'+1
}				

				
* expand data to 6 waves to create person-years
gen exp=6
expand exp
drop exp
sort Idnumber
bysort Idnumber: gen wave=_n


* generate variables for time-varying characteristics
for any mothres fullemp partemp onleave marstat mhealth chealth nrsib move  /// 
        mnssec pnssec hhinc incsup homeown pempl pedu regtyp depriv hboard  ///
        concdev emosymp5 emosymp6 conductprob5 conductprob6 hyper5 hyper6 	///
		peerprob5 peerprob6 prosoc5 prosoc6 totalsdq5 totalsdq6 			///
		newpartner newbaby othchild childleft:                                                             ///
        gen X=.

		
label val mothres DAHGRSP0
label val marstat LABE
label val mhealth MAHPGN01
label val chealth MAHGEN01
label val concdev MAHDEV01
label val homeown DAZTEN02
label val regtyp  ALAURIN2
label val pedu    DAYEDU03
label val mnssec  DAMSEC01
label val pnssec  DAYSEC01
label val hboard  ALAHBDBC


forval i=2/10 {
gen hhmem`i'=.
label val hhmem`i' LABG
}

for any fullemp partemp onleave incsup move: label val X LABL


* merge time-varying covariates and aux. variables
local j=1
foreach i in a b c d e f {
sort Idnumber
merge m:1 Idnumber using "${origdat}/gus`j'.dta",                            ///
      keepusing(M`i'West01 M`i'West02 M`i'West03 D`i'HGnmsb                  ///
                D`i'HGrsp01 D`i'HGmr2 M`i'Hgen01 M`i'Hpgn01                  ///
                D`i'Eqvinc D`i'Zten02 M`i'HGr* D`i'Yedu03 M`i'Wben07         ///
                D`i'Ysec01 D`i'Msec01 AL`i'HBdBc)                            ///
	  keep(1 3) nogen nolabel

replace fullemp=M`i'West01 if wave==`j'
replace partemp=M`i'West02 if wave==`j'
replace onleave=M`i'West03 if wave==`j'
replace pedu=D`i'Yedu03 if wave==`j'
replace nrsib=D`i'HGnmsb if wave==`j'
replace mothres=D`i'HGrsp01 if wave==`j'
replace marstat=D`i'HGmr2 if wave==`j'
replace mhealth=M`i'Hpgn01 if wave==`j'
replace chealth=M`i'Hgen01 if wave==`j'
replace mnssec=D`i'Msec01 if wave==`j'
replace pnssec=D`i'Ysec01 if wave==`j'
replace hhinc=D`i'Eqvinc if wave==`j'
replace incsup=M`i'Wben07 if wave==`j'
replace homeown=D`i'Zten02 if wave==`j'
replace hboard=AL`i'HBdBc if wave==`j'
forval k=2/10 {
replace hhmem`k'=M`i'HGr`k'1 if wave==`j'
}

drop M`i'West01 M`i'West02 M`i'West03 D`i'HGnmsb D`i'HGrsp01 D`i'HGmr2       ///
     M`i'Hgen01 M`i'Hpgn01 D`i'Eqvinc D`i'Zten02 M`i'HGr* D`i'Yedu03         ///
     M`i'Wben07 D`i'Ysec01 D`i'Msec01 AL`i'HBdBc

local j=`j'+1
}
	

* rename SDQ-Score
local j=5
foreach i in e f {
sort Idnumber 

replace emosymp`j'=D`i'Dsdem1 if wave==`j'
replace conductprob`j'=D`i'Dsdco1 if wave==`j'
replace hyper`j'=D`i'Dsdhy1 if wave==`j'
replace peerprob`j'=D`i'Dsdpr1 if wave==`j'
replace prosoc`j'=D`i'Dsdps1 if wave==`j'
replace totalsdq`j'=D`i'Dsdto1 if wave==`j'

drop D`i'Dsdem1 D`i'Dsdco1 D`i'Dsdhy1 D`i'Dsdpr1 D`i'Dsdps1 D`i'Dsdto1
local j=`j'+1
}

* lable SDQ-Score-variables
label var emosymp5 "Emotional symptoms score"
label var emosymp6 "Emotional symptoms score"
label var conductprob5 "Conduct problems score"
label var conductprob6 "Conduct problems score"
label var hyper5 "Hyper-activity score"
label var hyper6 "Hyper-activity score"
label var peerprob5 "Peer problems score"
label var peerprob6 "Peer problems score"
label var prosoc5 "Pro-social score"
label var prosoc6 "Pro-social score"
label var totalsdq5 "Total difficulties score"
label var totalsdq6 "Total difficulties score"


* MbOve01 MbOve07 MbOve08 MbOve09: not included in wave 1 and 6
/// M`i'Ove01 new parent/partner 
//M`i'Ove07 new baby 
///M`i'Ove08 other child in HH 
//M`i'Ove09 other child left HH 
local j=2
foreach i in b c d e  {
sort Idnumber 
merge m:1 Idnumber using "${origdat}/gus`j'.dta", /// Sweep 2-5 
	keepusing(M`i'Ove01 M`i'Ove07 M`i'Ove08 M`i'Ove09) ///
	keep(1 3) nogen nolabel

replace newpartner=M`i'Ove01 if wave==`j'
replace newbaby=M`i'Ove07 if wave==`j'
replace othchild=M`i'Ove08 if wave==`j'
replace childleft=M`i'Ove09 if wave==`j'

drop M`i'Ove01 M`i'Ove07 M`i'Ove08 M`i'Ove09

local j=`j'+1
}

* create variable for missing waves
* merge region type and deprivation index (which change name over sweeps)
local j=1
foreach i in a b {
sort Idnumber
merge m:1 Idnumber using "${origdat}/gus`j'.dta", /// Sweep 1+2 
      keepusing(AL`i'URin2 AL`i'SNimd)            ///
	  keep(1 3) nogen nolabel

replace regtyp=AL`i'URin2 if wave==`j'
replace depriv=AL`i'SNimd if wave==`j'

drop AL`i'URin2 AL`i'SNimd

local j=`j'+1
}


local j=3
foreach i in c {
sort Idnumber
merge m:1 Idnumber using "${origdat}/gus`j'.dta", /// Sweep 3
      keepusing(D`i'URind2 D`i'ADsco2)            ///
	  keep(1 3) nogen nolabel

replace regtyp=D`i'URind2 if wave==`j'
replace depriv=D`i'ADsco2 if wave==`j'

drop D`i'URind2 D`i'ADsco2

local j=`j'+1
}


local j=4
foreach i in d {
sort Idnumber
merge m:1 Idnumber using "${origdat}/gus`j'.dta", /// Sweep 4
      keepusing(AL`i'URin2 AL`i'SNimd)            ///
	  keep(1 3) nogen nolabel

replace regtyp=AL`i'URin2 if wave==`j'
replace depriv=AL`i'SNimd if wave==`j'

drop AL`i'URin2 AL`i'SNimd

local j=`j'+1
}


local j=5
foreach i in e {
sort Idnumber
merge m:1 Idnumber using "${origdat}/gus`j'.dta", /// Sweep 5
      keepusing(AL`i'URin2 AL`i'SNim2)            ///
	  keep(1 3) nogen nolabel

replace regtyp=AL`i'URin2 if wave==`j'
replace depriv=AL`i'SNim2 if wave==`j'

drop AL`i'URin2 AL`i'SNim2

local j=`j'+1
}



local j=6
foreach i in f {
sort Idnumber
merge m:1 Idnumber using "${origdat}/gus`j'.dta", /// Sweep 6
      keepusing(AL`i'URin2 AL`i'SNim2)            ///
	  keep(1 3) nogen nolabel

replace regtyp=AL`i'URin2 if wave==`j'
replace depriv=AL`i'SNim2 if wave==`j'

drop AL`i'URin2 AL`i'SNim2

local j=`j'+1
}


* merge concerns about development (also changing name/items over time)
sort Idnumber
merge m:1 Idnumber using "${origdat}/gus1.dta", /// Sweep 1 
      keepusing(MaHdev01)                       ///
	  keep(1 3) nogen nolabel

replace concdev=MaHdev01 if wave==1

drop MaHdev01


local j=2
foreach i in b c d e {
sort Idnumber
merge m:1 Idnumber using "${origdat}/gus`j'.dta", /// Sweep 2-6
      keepusing(M`i'Dgen01)                       ///
	  keep(1 3) nogen nolabel

replace concdev=M`i'Dgen01 if wave==`j'

drop M`i'Dgen01

local j=`j'+1
}

sort Idnumber
merge m:1 Idnumber using "${origdat}/gus6.dta", /// Sweep 6 
      keepusing(MfDcon02 MfDcon03)              ///
	  keep(1 3) nogen nolabel

replace concdev=2  if (MfDcon02==1 | MfDcon03==1) & wave==6
replace concdev=1  if  MfDcon02==2 & MfDcon03==2 & wave==6
replace concdev=-8 if (MfDcon02==-8 | MfDcon03==-8) & wave==6

drop MfDcon02 MfDcon03


* merge partner's employment status and info on moving for sweeps 2-6
local j=2
foreach i in b c d e f {
sort Idnumber
merge m:1 Idnumber using "${origdat}/gus`j'.dta", ///
      keepusing(D`i'Ysta01 M`i'Zhou15)            ///
      keep(1 3) nogen nolabel

replace pempl=D`i'Ysta01 if wave==`j'
replace move=M`i'Zhou15 if wave==`j'

drop D`i'Ysta01 M`i'Zhou15

local j=`j'+1
}


* inspect data
describe                        // show all variables contained in data
notes                           // show all notes contained in data
* codebook, problems              // potential problems in dataset
duplicates report Idnumber      // duplicates?
duplicates report Idnumber wave 


/*------------------------------------------------------------------------------
#2 Recode variables 
------------------------------------------------------------------------------*/

* add values to all value labels (to make recoding easier)
numlabel _all, add


* A: cognitive measures

* recode missings
for var DcNam* DcPic* DeNam* DePic*: replace X=. if X<0

* rename variables
foreach i in Pic Nam {
for any `i'*: rename DcX X3 
for any `i'*: rename DeX X5 
*for any `i':  rename ZDeX sX5
}

* extreme values (13 cases)
scatter PicSAS5 NamVAS5 if wave==5, jitter(10)


corr PicSAS5 NamVAS5 if wave==5



* B: time-invariant covariates

* child's sex
rename MaHGsx1 kidmale0
recode kidmale0 2=0


* study child's birth order
recode DaHGbord                      ///
       (1    = 0 "first")            ///
       (2    = 1 "second")           ///
       (3/15 = 2 "third or higher")  ///
       , gen(brthord0)
tab brthord0, gen(brthord0)	   


* mother's age at birth of first child
rename MaMage01 agebrth0




* age at birth of study child
recode DaHGmag5                         ///
       (-3  = . )                       ///
       ( 2  = 0 "20 to 29")             ///
       ( 3  = 1 "30 to 39")             ///
       ( 1  =98 "under 20")             ///
       ( 4  =99 "40 or older")          ///
       , gen(agebrthc0)
	   

* (un)planned pregnancy
recode MaPGpl01                         ///
       (-9/-1 = .)                      ///
       (1/2   = 0 "planned")            ///
       (3     = 1 "not really planned") ///
       (4     = 2 "not planned at all") ///
       , gen(unplan0)
tab unplan0, gen(unplan0)
	   
	   
* requiring medical attention or treatment during pregnancy?
recode MaPGil01        ///
       (-9/-1 = .)     ///
       (2     = 0)     ///
       , gen(medpreg0)
	   

* mother smoked during pregnancy
recode MaHcig01  -1=.
rename MaHcig01 smoprg0
tab smoprg0, gen(smoprg0)


* mother drank during pregnancy
recode MaHalc04                              ///
       (-1 8  = .)                           /// missings
       (1/4   = 2 "multiple times per week") /// 
       (5/6   = 1 "2-3x per month or less")  /// 
       (7     = 0 "never")                   /// 
       , gen(alcprg0)
tab alcprg0, gen(alcprg0)


* ever taken illegal drugs
gen drugs0=0
forval i=1/9 {
replace drugs0=1 if MaHdrg0`i'==1
}
replace drugs0=. if MaHdrg10==-1


* antenatal classes during (earlier) pregnancy
recode MaPGan01        ///
       (-9/-1 = .)     /// missings
       (1/2   = 1)     /// yes, all/most and some
       (3     = 0)     /// none
       , gen(classes0)
 
replace classes0=1 if MaPGan04==1 // attended class for earlier pregnancy
drop MaPGan04 MaPGan01


* antenatal classes by father?
recode MaPGan14        ///
       (-9/-1 = .)     /// missings
       (1     = 1)     /// yes, all/most and some
       (2     = 0)     /// none
       , gen(classesf0)


* preterm birth?
gen preterm0=0
replace preterm=1 if MaBtim02==1 & MaBtim03>21 | MaBtim02==2 & MaBtim03>3
drop MaBtim01 MaBtim02 MaBtim03


* special care unit?
rename MaBneo01 careunit0
recode careunit -8 -9=. 2=0


* low birth weight
recode DaLwBWt             ///
       (1 = 1 "<2.5 kg")   ///
       (2 = 0 "≥2.5 kg")   ///
       , gen(lbweight0)
	   
	   
* experience with children before pregnancy
rename MaMtmk01 expkid0
replace expkid=. if expkid<0
replace expkid0=1 if brthord0>1 & expkid0==.


* was child breastfed, until when?
gen brstfed0=0 if MaBFDe01==2                                 //  never
replace brstfed0=1 if MaBFDd01<=30 & MaBFDd01>0               /// 1st month
                    | MaBFDw01<=4 & MaBFDw01>0 | MaBFDm01==1
replace brstfed0=2 if MaBFDw01>4 & MaBFDw01<=12               /// 2-3 months
                    | MaBFDm01==2 | MaBFDm01==3
replace brstfed0=3 if MaBFDw01>12 & MaBFDw01<=24              /// 4-6 months
                    | MaBFDm01==4 | MaBFDm01==5 | MaBFDm01==6
replace brstfed0=4 if MaBFDw01>24 & MaBFDw01<. |              /// >6 months
                      MaBFDm01>6 & MaBFDm01<75 | MaBFDs01==1

drop MaBFDe01 MaBFDs01 MaBFDl01 MaBFDd01 MaBFDw01 MaBFDm01


* mother's highest education at birth
rename DaMedu03 educat0
recode educat0 -3 2=.  // no info and "other" to missing
tab educat0, gen(educat0)


* mother's religion?
rename DaReligM relig0
recode relig0 4=3       // pool non-Christian


* twins or triplets?
rename MaBtyp01 mltprg0
recode mltprg0 -8 -9=. 1=0  2 3=1


* grandparents in home or within 20-30 min drive
gen gparen0=.
replace gparen0=1 if DaGraPar==1 | MaGliv01>0
replace gparen0=0 if DaGraPar==0 & MaGliv01==0


* frequency of seeing grandparents
gen visgpar0=.
replace visgpar0=1 if MaGcon02>0 & MaGcon02<3
replace visgpar0=0 if MaGcon02>2 & MaGcon02<.


* advice from family and friends
gen advice0=.
replace advice0=1 if MaIhea05==1 | MaIhea06==1 | MaIhea07==1   ///
                   | MaIhea08==1 | MaIhea09==1 | MaIhea10==1 
replace advice0=0 if MaIhea05==0 & MaIhea06==0 & MaIhea07==0   ///
                   & MaIhea08==0 & MaIhea09==0 & MaIhea10==0 


* childcare from family and friends
gen childcare0=.
replace childcare0=1 if DaCtyp01==1 | DaCtyp02==1 | DaCtyp11==1
replace childcare0=0 if DaCtyp01<1 & DaCtyp02<1 & DaCtyp11<1


* ever worked?
rename MaWevr01 evrwrk0
recode evrwrk0 -8=. 2=0


* worked during pregnancy?
rename  MaWprg01 prgwrk0
recode  prgwrk0 -9 -8 -1=. 2=0 
replace prgwrk0=0 if evrwrk0==0


* went on leave?
rename  MaWprg03 leave0
recode  leave -8 -1=. 1=0 2=1
replace leave0=0 if prgwrk0==0 | evrwrk0==0


* worked since birth?
rename MaWpnt01 wrksbir0
recode wrksbir0 -9 -1=. 2=0


* ethnicity
rename  DaEthGpM nwhite0
replace nwhite0=nwhite0-1


* Mother's country of birth
recode MaMorg01                   ///
       (-9/-8 = .)                ///
       (1     = 0 "Scotland")     ///
       (2/4   = 1 "Rest of UK")   ///
       (5     = 5 "Outside UK")   ///
       , gen(bcountry0)	   
	   
	   
* C: time-dependent covariates at t

* wave-specific employment (for selection models)
gen empl=.
replace empl=1 if fullemp==1 & onleave==0
replace empl=2 if partemp==1 & onleave==0
replace empl=3 if fullemp==0 & partemp==0 | onleave==1


* indicator for missing employment status
gen empmis=1 if empl==.


* missing employment counter for age 5
bysort Idnumber: egen emiscnt5=count(empmis)


* years of full-time and part-time employment for age 5
bysort Idnumber: egen abc=count(wave) if empl==1 & emiscnt5==0
bysort Idnumber: egen ftyrs5=max(abc)
replace ftyrs5=0 if ftyrs5==. & emiscnt5==0
drop abc

bysort Idnumber: egen abc=count(wave) if empl==2 & emiscnt5==0
bysort Idnumber: egen ptyrs5=max(abc)
replace ptyrs5=0 if ptyrs5==. & emiscnt5==0
drop abc
   

* employment indicators for every wave (after first)
forval i=1/5 {
gen empl`i'=empl if wave==`i'+1
sort Idnumber wave
replace empl`i'=empl`i'[_n-1] if Id==Id[_n-1] & wave>`i'+1
}


* partner's employment status for sweep 1 (because of different variable)
replace pempl=3  if wave==1 & (MaYevr01==2 | MaYnow01==2)
replace pempl=1  if wave==1 &  MaYnow01==1 & MaYtim01>=35 & MaYtim01<.
replace pempl=2  if wave==1 &  MaYnow01==1 & MaYtim01<35  & MaYtim01>0
replace pempl=-1 if wave==1 &  marstat>=3 & marstat<=6


* partner's employment status
recode pempl -3=. -1 3=0 2=1    // 

note pempl: "not ideal because it conflates not working with no partner"


* partner status (includes info on partner's education)
gen parstat=.
replace parstat=0 if pedu==-1                       // no partner
replace parstat=1 if pedu>=1 & pedu<=5 & marstat==2 // lower ed. + cohab.
replace parstat=2 if pedu>=1 & pedu<=5 & marstat==1 // lower ed. + married
replace parstat=3 if pedu>=5 & marstat==2           // higher ed. + cohab
replace parstat=4 if pedu>=5 & marstat==1           // higher ed. + married
tab parstat, gen(parstat)


* maximum NSSEC
for any mnssec pnssec: replace X=. if X<0 // no partner also missing

gen nssec=.
replace nssec=mnssec                     // mother's class
replace nssec=pnssec if pnssec<mnssec    // if missing or lower: partner's class

replace nssec=5 if nssec==6              // may be problematic


* household income (in 1,000 GBP)
recode hhinc -1=.
replace hhinc=hhinc/1000


* income support receipt
recode incsup -9 -8 -1=.


* marital status
recode marstat -1=. 3/6=0 1/2=1, gen(partner)
replace partner=0 if parstat==0


* homeownership
recode homeown -9 -8 -3=. 2 3 4=0


* cumulative number of residential moves (since birth)
gen rmove=0 if MaZhou14>1 & wave==1
replace rmove=1 if MaZhou14==1 & wave==1
recode move -8 -1 =. 1=0 2=1
sort Idnumber wave
replace rmove=rmove[_n-1]+move if wave>1 & Idnumber==Idnumber[_n-1]


* child health (not good)
recode chealth          ///
       (-8/-1 = .)      /// missings
       (3/5   = 1 )     /// fair, bad, very bad = not in good health
       (1/2   = 0)      /// very good, good = in good health
       , gen(cldill)


* resp. concerned about child's development
recode concdev -8=. 1=0 2 3=1


* mother's health (not good)
recode mhealth          ///
       (-1 6  = .)      /// missings
       (4/5   = 1 )     /// fair, poor = not in good health
       (1/3   = 0)      /// excellent, very good, good = in good health
       , gen(mumill)


* urban vs. rural
recode regtyp        ///
       (3/6 = 0)     /// small towns, rural (both accessible and remote)
       (1/2 = 1)     /// large urban, other urban
       (-3  = .)     /// missings
       , gen(urban)

	   
* health board
recode hboard -3=.


* grandparents in the home (if one of first 10 HH members is grandparent)
gen gphome=.
forval i=2/10 {
replace gphome=1 if hhmem`i'==20
replace gphome=0 if hhmem`i'!=20 & hhmem`i'!=. & hhmem`i'!=-1
drop hhmem`i'
}


* siblings in household
recode nrsib                     ///
       (0    = 0 "none")         ///
       (1    = 1 "one")          ///
       (2/15 = 2 "two or more")  ///
       , gen(sibcat)
tab sibcat, gen(sibcat)

* 1. Welchen Geburtsrang hat das Kind (bleibt konstant über die Jahre)
* 2. Wann kommt ein weiteres Kind hinzu (beginnt bei 0 und bleibt 1 sobald neues Kind geboren ist)

/*** generate dummy variable: birth of sibling
* including those who already have had a sibling 
sort Id wave
gen sibbirth=. 
replace sibbirth=0 if sibcat1==1 
replace sibbirth=0 if sibbirth[_n-1]==0 & Id==Id[_n-1]
replace sibbirth=1 if sibcat2==1 
replace sibbirth=1 if sibcat3==1
replace sibbirth=1 if sibbirth[_n-1]==1 & Id==Id[_n-1]
*/

*** generate dummy variable: birth of sibling
* Wann kommt ein weiteres Kind hinzu (beginnt bei 0 und bleibt 1 sobald neues Kind geboren ist)
* EXcluding those who already have had a sibling 
sort Id wave
gen sibbirth=0 

replace sibbirth=1 if nrsib>nrsib[_n-1] & nrsib<. & Id==Id[_n-1]

replace sibbirth=1 if sibbirth[_n-1]==1 & Id==Id[_n-1]
replace sibbirth=1 if wave==1 & DaHGbord<=nrsib & nrsib<.


bysort Idnumber: egen aux=min(wave) if sibbirth==1
bysort Idnumber: egen yrbrn=max(aux) 
drop aux

replace yrbrn=0 if yrbrn==.

bysort yrbrn: sum NamVAS5 PicSAS5 if wave==5 

*** alternative variable: new baby in household
sort Id wave
gen sibbirth_2=0
replace sibbirth_2=1 if newbaby==1 &nrsib<.
replace sibbirth_2=1 if sibbirth_2[_n-1]==1 & Id==Id[_n-1]

bysort Idnumber: egen aux2=min(wave) if sibbirth_2==1
bysort Idnumber: egen yrbrn_2=max(aux2)
replace yrbrn_2=0 if yrbrn_2==.
drop aux2


* dummy variable for each year: birth of sibling in year i 
sort Id wave
forval i=1/6 {
gen sibbirth`i'=. if wave==`i'  
replace sibbirth`i'=0 if sibbirth==0 & wave==`i'   
replace sibbirth`i'=1 if sibbirth==1 & wave==`i'   
}
sort Id wave
forval i=2/5 {
gen sibbirth_2`i'=. if wave==`i'  
replace sibbirth_2`i'=0 if sibbirth_2==0 & wave==`i'   
replace sibbirth_2`i'=1 if sibbirth_2==1 & wave==`i'   
}
*** comparison between variables 
*how many children are born in wave 1 and 6 ? 
tab sibbirth wave, matcell(cellcount)
matlist cellcount 
matrix rownames cellcount= 0 1
matrix colnames cellcount= 1 2 3 4 5 6 


tab sibbirth_2 wave, matcell(cellcount2)
matlist cellcount2 
matrix rownames cellcount2= 0 1
matrix colnames cellcount2= 2 3 4 5 

putexcel set vergleich_variablen.xlsx, sheet(tab) replace

putexcel A1 = "Alte variabel 'Sibbirth'"

putexcel A2 = matrix(cellcount), names hcenter
putexcel A5 = "Neue variable 'Sibbirth2'"

putexcel A6 = matrix(cellcount2), names hcenter


				
*use "H:\GUS\_rp_kuehhirt&klein_cd17\data\original\testen.dta" 

* rename missings
foreach var of varlist 	emosymp5 emosymp6 conductprob5 conductprob6 /// 
						hyper5 hyper6 peerprob5 peerprob6 			///
						prosoc5 prosoc6 totalsdq5 totalsdq6 {
	recode `var' (-3=.) 	
}

*** draw boxplot over Sibbirth and Sex year 5
foreach var of varlist	emosymp5 conductprob5 hyper5 				///
						peerprob5 prosoc5 totalsdq5 {
local z: variable label `var'
graph box 	`var', 													///
			over(sibbirth, relabel(1 "No sibling" 2 "Sibling")) 	///
			over(kidmale0, relabel(1 "Female" 2 "Male")) 			///
			ytitle("") 												/// 
			asyvar bar(1, color(sand)) marker(1, mcol (sand))		///
			bar(2, color(emerald)) marker(2, mcol(emerald))			///
			title ("`z'") ///
			name(box`var', replace) 
}

* get grc1leg2 (supresses the legends when combining graphs and uses just one)
findit grc1leg2 	
* combine boxplots year 5
grc1leg2  	boxemosymp5.gph boxconductprob5.gph boxhyper5.gph  		///
			boxpeerprob5.gph boxprosoc5.gph boxtotalsdq5.gph, 		///
			title("Distribution of Difficulties in Year 5") 		///
			saving(${wdir}/tables/boxall_sibbirth5, replace)
			
			
*** draw boxplot over Sibbirth_2 and Sex year 5
foreach var of varlist	emosymp5 conductprob5 hyper5 				///
						peerprob5 prosoc5 totalsdq5 {
local z: variable label `var'
graph box 	`var', 													///
			over(sibbirth_2, relabel(1 "No sibling" 2 "Sibling")) 	///
			over(kidmale0, relabel(1 "Female" 2 "Male")) 			///
			ytitle("") 												/// 
			asyvar bar(1, color(sand)) marker(1, mcol (sand))		///
			bar(2, color(emerald)) marker(2, mcol(emerald))			///
			title ("`z'") ///
			name(box`var', replace) 
}

 	
* combine boxplots year 5
grc1leg2  	boxemosymp5.gph boxconductprob5.gph boxhyper5.gph  		///
			boxpeerprob5.gph boxprosoc5.gph boxtotalsdq5.gph, 		///
			title("Distribution of Difficulties in Year 5") 		///
			saving(${wdir}/tables/boxall_sibbirth5_2, replace)
			
			
* draw boxplot over Sibbirth and Sex year 6
foreach var of varlist	emosymp6 conductprob6 hyper6 				///
						peerprob6 prosoc6 totalsdq6 {
local z: variable label `var'
graph box 	`var', 													///
			over(sibbirth, relabel(1 "No sibling" 2 "Sibling")) 	///
			over(kidmale0, relabel(1 "Female" 2 "Male")) 			///
			ytitle("") 												/// 
			asyvar bar(1, color(sand)) marker(1, mcol (sand))		///
			bar(2, color(emerald)) marker(2, mcol(emerald)) 		///
			title("`z'") 											///
			saving(box`var', replace) 
}
* combine boxplots year 6
grc1leg2 	boxemosymp6.gph boxconductprob6.gph boxhyper6.gph  	///
			boxpeerprob6.gph boxprosoc6.gph boxtotalsdq6.gph, 		///
			title("Distribution of Difficulties in Year 6") 		///
			saving(boxall_sibbirth6, replace)
				
*** Summary of variables for year 5 and 6 	
local j=5
foreach var of varlist 	emosymp`j' conductprob`j' hyper`j' 			///
						peerprob`j' prosoc`j' totalsdq`j' {
	bysort sibbirth: sum `var' 
	local j=`j'+1
}
** ttest: comparison of means 
* between boys with and without sibling in year 5
foreach var of varlist	emosymp5 conductprob5 hyper5 				///
						peerprob5 prosoc5 totalsdq5 {
ttest `var' if kidmale0==1, by(sibbirth)
}

*** Vergleich zu sibbirth_2
** ttest: comparison of means 
* between boys with and without sibling in year 5
foreach var of varlist	emosymp5 conductprob5 hyper5 				///
						peerprob5 prosoc5 totalsdq5 {
ttest `var' if kidmale0==1, by(sibbirth_2)
}

* between girls with and without sibling in year 5
foreach var of varlist	emosymp5 conductprob5 hyper5 				///
						peerprob5 prosoc5 totalsdq5 {
ttest `var' if kidmale0==0, by(sibbirth)
}

*between boys with and without sibling in year 6 
foreach var of varlist	emosymp6 conductprob6 hyper6 				///
						peerprob6 prosoc6 totalsdq6 {
ttest `var' if kidmale0==1, by(sibbirth)
}

*between girls with and without sibling in year 6 
foreach var of varlist	emosymp6 conductprob6 hyper6 				///
						peerprob6 prosoc6 totalsdq6 {
ttest `var' if kidmale0==1, by(sibbirth)
}

* plot means over sibbirth and sex year 5 
foreach var of varlist	emosymp5 conductprob5 hyper5 				///
						peerprob5 prosoc5 totalsdq5 {
local z: variable label `var'
graph bar 	`var', ///
			over(sibbirth, relabel(1 "No sibling" 2 "Sibling") gap(2)) ///
			over(kidmale0, relabel(1 "Female" 2 "Male") gap(12)) 	///
			ytitle("") ///
			asyvar bar(1, color(sand) fintensity(inten50)) 			///
			bar(2, color(emerald) fintensity(inten50)) 				/// 
			title("`z'") ///
			saving(bar`var', replace) 
}	
* combine graphs year 5 
grc1leg2 	baremosymp5.gph barconductprob5.gph barhyper5.gph 		///
			barpeerprob5.gph barprosoc5.gph bartotalsdq5.gph, 		///
			title("Mean in Difficulty Scores Year 5") 				///
			ycommon /// commen y-axis
			saving(barall_sibbirth5, replace)

* plot means over sibbirth and sex year 6 
foreach var of varlist	emosymp6 conductprob6 hyper6 				///
						peerprob6 prosoc6 totalsdq6 {
local z: variable label `var'
graph bar 	`var', ///
			over(sibbirth, relabel(1 "No sibling" 2 "Sibling") gap(2)) ///
			over(kidmale0, relabel(1 "Female" 2 "Male") gap(12)) 	///
			ytitle("") ///
			asyvar bar(1, color(sand) fintensity(inten50)) 			///
			bar(2, color(emerald) fintensity(inten50)) 				/// 
			title("`z'") ///
			saving(bar`var', replace) 
}	
* combine graphs year 6 
grc1leg2 	baremosymp6.gph barconductprob6.gph barhyper6.gph 		///
			barpeerprob6.gph barprosoc6.gph bartotalsdq6.gph, 		///
			title("Mean in Difficulty Scores year 6") 				///
			ycommon 									/// common y-axis
			saving(barall_sibbirth6, replace)

* draw boxplot over birth order (first, second, third or higher) and sex year 5 
foreach var of varlist	emosymp5 conductprob5 hyper5 				///
						peerprob5 prosoc5 totalsdq5 {
local z: variable label `var'
graph box 	`var', 													///
			over(brthord0) 											///
			over(kidmale, relabel (1 "Female" 2 "Male"))			///
			ytitle("") 												///
			asyvar bar(1, color(sand)) marker(1, mcol(sand)) 		///
			bar(2, color(emerald)) marker(2, mcol(emerald)) 		///
			bar(3, color(orange)) marker(3, mcol(orange)) 			///
			title("`z'") 											///
			saving(boxbrthord`var', replace) 
}	
* combine boxplots year 5
grc1leg2 	boxbrthordemosymp5.gph boxbrthordconductprob5.gph 		///
			boxbrthordhyper5.gph  boxbrthordpeerprob5.gph 			///
			boxbrthordprosoc5.gph boxbrthordtotalsdq5.gph,			///
			title("Distribution of Difficulties in year 5") 		///
			saving(boxall_brthord5, replace)

* draw boxplot over birth order (first, second, third or higher) and sex year 6 
foreach var of varlist	emosymp6 conductprob6 hyper6 ///
						peerprob6 prosoc6 totalsdq6 {
local z: variable label `var'
graph box 	`var', 													///
			over(brthord0) 											///
			over(kidmale, relabel (1 "Female" 2 "Male")) 			///
			ytitle("") 												///
			asyvar bar(1, color(sand)) marker(1, mcol(sand))		///
			bar(2, color(emerald)) marker(2, mcol(emerald)) 		///
			bar(3, color(orange)) marker(3, mcol(orange)) 			///
			title("`z'") 											///
			legend(size(small)) 									///
			saving(boxbrthord`var', replace) 
}	
* combine graphs year 6
grc1leg2 	boxbrthordemosymp6.gph boxbrthordconductprob6.gph 		///
			boxbrthordhyper6.gph  boxbrthordpeerprob6.gph 			///
			boxbrthordprosoc6.gph boxbrthordtotalsdq6.gph,
			title("Distribution of Difficulties in year 6") 		///
			legend(size(small)) 									///
			saving(box_all_brthord6, replace)

*** plot mean over birthorder and sex year 5 
foreach var of varlist	emosymp5 conductprob5 hyper5 				///
						peerprob5 prosoc5 totalsdq5 {
local z: variable label `var'
graph bar 	`var', ///
			over(brthord0, gap(2)) ///
			over(kidmale0, relabel(1 "Female" 2 "Male") gap(12)) 	///
			ytitle("") ///
			asyvar bar(1, color(sand) fintensity(inten50)) 			///
			bar(2, color(emerald) fintensity(inten50)) 				/// 
			title("`z'") ///
			saving(barbrthord`var', replace) 
}
* combine bar over birthorder year 5
grc1leg2 	barbrthordemosymp5.gph barbrthordconductprob5.gph 		///
			barbrthordhyper5.gph barbrthordpeerprob5.gph			///
			barbrthordprosoc5.gph barbrthordtotalsdq5.gph, 			///
			title("Mean in Difficulty Scores year 6") 				///
			ycommon 									/// common y-axis
			saving(bar_all_brthord5, replace)

*** plot mean over birthorder and sex year 6 
foreach var of varlist	emosymp6 conductprob6 hyper6 				///
						peerprob6 prosoc6 totalsdq6 {
local z: variable label `var'
graph bar 	`var', ///
			over(brthord0, gap(2)) ///
			over(kidmale0, relabel(1 "Female" 2 "Male") gap(12)) 	///
			ytitle("") ///
			asyvar bar(1, color(sand) fintensity(inten50)) 			///
			bar(2, color(emerald) fintensity(inten50)) 				/// 
			title("`z'") ///
			saving(barbrthord`var', replace) 
}
* combine bar over birthorder year 6 
grc1leg2 	barbrthordemosymp6.gph barbrthordconductprob6.gph 		///
			barbrthordhyper6.gph barbrthordpeerprob6.gph			///
			barbrthordprosoc6.gph barbrthordtotalsdq6.gph, 			///
			title("Mean in Difficulty Scores year 6") 				///
			ycommon 									/// common y-axis
			saving(bar_all_brthord6, replace)

*** ABILITY SCORES  
			
*** Boxplots for year 5 over sibbirth and sex
foreach var of varlist	PicSAS5 NamVAS5 {
local z: variable label `var'
graph box 	`var', 													///
			over(sibbirth, relabel(1 "No sibling" 2 "Sibling")) 	///
			over(kidmale0, relabel(1 "Female" 2 "Male")) 			///
			ytitle("") 												/// 
			asyvar bar(1, color(sand)) marker(1, mcol (sand))		///
			bar(2, color(emerald)) marker(2, mcol(emerald))			///
			title ("`z'") 											///
			saving(box`var', replace) 
}

*** boxplots for year 5 over birthorder and sex
foreach var of varlist PicSAS5 NamVAS5 {
local z: variable label `var'
graph box 	`var', 													///
			over(brthord0) 											///
			over(kidmale, relabel (1 "Female" 2 "Male")) 			///
			ytitle("") 												///
			asyvar bar(1, color(sand)) marker(1, mcol(sand))		///
			bar(2, color(emerald)) marker(2, mcol(emerald)) 		///
			bar(3, color(orange)) marker(3, mcol(orange)) 			///
			title("`z'") 											///
			legend(size(small)) 									///
			saving(boxbrthord`var', replace) 
}	

*** bars 
** over sibbirth and sex 
foreach var of varlist PicSAS5 NamVAS5 {
local z: variable label `var'
graph bar 	`var', 													///
			over(sibbirth, relabel(1 "No sibling" 2 "Sibling") gap(2)) ///
			over(kidmale0, relabel(1 "Female" 2 "Male") gap(12)) 	///
			ytitle("") 												///
			asyvar bar(1, color(sand) fintensity(inten50)) 			///
			bar(2, color(emerald) fintensity(inten50)) 				/// 
			title("`z'") 											///
			saving(bar`var', replace) 
}	
** over birthorder and sex
foreach var of varlist	PicSAS5 NamVAS5{
local z: variable label `var'
graph bar 	`var', 													///
			over(brthord0, gap(2)) 									///
			over(kidmale0, relabel(1 "Female" 2 "Male") gap(12)) 	///
			ytitle("") 												///
			asyvar bar(1, color(sand) fintensity(inten50)) 			///
			bar(2, color(emerald) fintensity(inten50)) 				/// 
			title("`z'") 											///
			saving(barbrthord`var', replace) 
}


* generate time-varying characteristics at t-1, baseline and indiv. mean
foreach m in A B {

foreach v of global tvar`m' {
capture gen `v'_nd=`v'[_n-1] if wave>1 & Id==Id[_n-1]  // t-1
sort Id wave
replace `v'_nd=`v' if wave==1  

capture gen `v'0=`v' if wave==1                        // baseline
sort Id wave
replace `v'0=`v'0[_n-1] if Id==Id[_n-1]

capture bysort Idnumber: egen `v'_av=mean(`v')         // individual mean
}
}


* generate employment status at t-1 and baseline
gen empl_nd=empl if wave==1                  // t-1
sort Id wave
replace empl_nd=empl[_n-1] if Id==Id[_n-1]  

gen empl0=empl if wave==1                    // baseline
sort Id wave
replace empl0=empl0[_n-1] if Id==Id[_n-1]

	   
* D: auxiliary variables

* sample weight
rename DaWTbrth sweight


* same sex couples (ever)
bysort Idnumber: egen samesex=max(marstat)
recode samesex -1/6=0 7=1


* mother respondent at first wave
gen mother1=1 if mothres==1 & wave==1
sort Idnumber wave
replace mother1=mother1[_n-1] if Idnumber==Idnumber[_n-1]


* year of first loss to follow-up (mothres missing or other than mother)
bysort Idnumber: egen abc=min(wave) if mothres!=1 
bysort Idnumber: egen yrcens=min(abc)
replace yrcens=6 if yrcens==.


* attrition indicator
gen attr = 0 if wave < yrcens | yrcens == 6
replace attr = 1 if attr == 0 & wave < 5 & wave == yrcens - 1
replace attr = 1 if attr == 0 & wave == 5 & (PicSAS5==. | NamVAS5==.)


* year of first missing on maternal employment or covariates at t-1
egen miss=rowmiss(empl $tinvarA $tvar_ndA rmove)
bysort Id: egen abcd=min(wave) if miss>0
bysort Id: egen yrmiss_nd=max(abcd)
replace yrmiss_nd=6 if yrmiss_nd==.


* year of first missing on maternal employment or covariates at t
egen missb=rowmiss(empl $tinvarA $tvarA rmove)
bysort Id: egen abcde=min(wave) if missb>0
bysort Id: egen yrmiss=max(abcde)
replace yrmiss=6 if yrmiss==.


* censoring indicator
gen cens=0 if wave<yrcens & wave<yrmiss_nd | yrcens==6 & yrmiss_nd==6
replace cens=1 if cens==0 & wave<5 & (wave==yrcens-1 | wave==yrmiss_nd-1)
replace cens=1 if cens==0 & wave==5 & (PicSAS5==. | NamVAS5==.)


* attrition through missing
gen amis = 0 if wave <= yrmiss_nd | yrmiss_nd == 6
replace amis = 1 if amis == 0 & wave < 6 & wave == yrmiss_nd



/*------------------------------------------------------------------------------
#3 Define samples

Sample A: Target population
Criteria for inclusion
	1. Mother: aged 20-39 at birth, born in UK, respondent at 1st sweep, no same
               sex couple, white, non-religious or Christian, worked before 
			   1st interview  
	2. Child is a singleton birth 

	
Sample B: Estimation of IPTW 
Criteria for inclusion
    1. no loss to follow-up until t 
	2. no missing values on maternal employment and covariates until t


Sample C: Estimation of outcome model for cognitive measures at age 5
Criteria for inclusion
	1. Uncensored until age 5
	2. No missings or "extreme" values on both cognitive measures at 5         
------------------------------------------------------------------------------*/

* A: Generate variable that identifies Sample A
gen sampleA = mother1==1                 /// mother is respondent in 1st wave
            & agebrthc>=0  & agebrthc<=1 /// aged 20-39 at birth of study child
            & samesex==0                 /// no same sex couple
            & nwhite0==0                 /// white
            & relig0<3                   /// no non-Christian religions
            & bcountry0<5                /// born in UK
            & evrwrk0==1                 /// worked before interview
            & mltprg0==0                 //  child is singleton birth

  
* B: generate variable that identifies Sample B
gen sampleB=sampleA==1 & wave<yrcens & wave<yrmiss_nd


* C: generate variable that identifies Sample C
gen sampleC=sampleB==1 & PicSAS5<. & NamVAS5<. & NamVAS5>=40 & PicSAS5>=30 ///
                       & yrcens==6 & yrmiss_nd==6

* number of "outliers" 
scatter PicSAS5 NamVAS5 if wave==5 & yrcens==6 & yrmiss_nd==6 & sampleB==1 ///
      , jitter(10)
sum PicSAS5 NamVAS5 if wave==5 & yrcens==6 & yrmiss_nd==6 & sampleB==1     ///
                     & PicSAS5<. & NamVAS5<., det
* -> 4 cases (+ 4 with missing information)


* distribution of ability scores in different samples
sum PicSAS5 NamVAS5 if wave==5     // Mp = 83 SDp = 12; Mv = 110 SDv = 15
sum PicSAS5 NamVAS5 if wave==5    /// Mp = 83 SDp = 12; Mv = 111 SDv = 14
                     & sampleA==1 
sum PicSAS5 NamVAS5 if wave==5    /// Mp = 83 SDp = 11; Mv = 111 SDv = 14
                     & sampleB==1 
sum PicSAS5 NamVAS5 if wave==5    /// Mp = 84 SDp = 11; Mv = 111 SDv = 14
                     & sampleC==1 
	  
	  
* D: describe case numbers on sample selection variables
capture log close
log using "${tables}/01sampleA.txt", replace text
* Case numbers of sample selection variables (p. 11)
tab1 mother1 samesex agebrthc0 nwhite0 relig0 bcountry0 evrwrk0 mltprg0 ///
     if wave==1, m
* 01cr_guslong.do#3D
log close


/*------------------------------------------------------------------------------
#4 Label and order variables                                                 
------------------------------------------------------------------------------*/

* A: define value labels
label def yesno    0"no" 1"yes"
label def sex      0"Girls" 1"Boys"
label def depriv   1"[1] least deprived" 5"[5] most deprived"
label def parstat  0"no partner" 1"lower ed. + cohab." 2"lower ed. + married" /// 
                   3"higher ed. + cohab." 4"higher ed. + married"
label def empl     1"full-time" 2"part-time" 3"not working"


* B: assign value labels
for any medpreg0 lbweight0 mltprg pempl* incsup* nwhite0 sample*       ///
        gparen0 advice0 childcare0                                     ///
        homeown* urban* gphome* evrwrk0 prgwrk0 leave0 wrksbir0 cens:  ///
        label val X yesno

for any nssec*:                      label val X DAYSEC01
for any pedu*:                       label val X DAYEDU03
for any chealth*:                    label val X MEHGEN01
for any mhealth*:                    label val X MEHPGN01
for any depriv*:                     label val X depriv
for any parstat:                     label val X parstat
for any sibcat*:                     label val X sibcat
for any empl*:                       label val X empl

label val kidmale   sex
label val classesf0 MAPGAN01
label val brstfed0  brstfed


* C: label variables 

* maternal employment variables
for var empl*: label var X "Employment status"
label var ftyrs5           "Years fulltime employed"
label var ptyrs5           "Years parttime employed"


* cognitive measures
label var NamVAS3          "Naming vocabulary score (age 3)"
label var PicSAS3          "Picture similarities score (age 3)"
label var NamVAS5          "Naming vocabulary score"
label var PicSAS5          "Picture similarities score"


* time-invariant covariates
label var agebrth0         "Age at birth of 1st child"
label var agebrthc0        "Aged 30-39 at birth"
label var kidmale0         "Child is male"
label var brthord01        "Child is first-born"
label var brthord02        "Child is second-born"
label var brthord03        "Child is third-born or later"
label var unplan0          "(Un-)Planned pregnancy"
label var unplan01         "Planned"
label var unplan02         "Not really planned"
label var unplan03         "Not planned at all"
label var alcprg01         "Never"
label var alcprg02         "2-3x per month or less"
label var alcprg03         "Multiple times per week"
label var drugs0		   "Mother has taken illegal drugs"
label var medpreg0         "Medical attention during pregnancy"
label var careunit0        "Child in Special Care Unit or Neo-Natal Unit" 
label var lbweight0        "Low birth weight (<2.5 kg)"
label var evrwrk0          "Mother worked before first interview"
label var prgwrk0          "Mother worked during pregnancy"
label var leave0           "Mother went on leave"
label var nwhite0          "Mother non-white"
label var educat0          "Mother's hightest level of education"
label var educat01         "No qualification"
label var educat02         "GCSEs/Standard Grades/NVQ level 2 or below"
label var educat03         "A levels/Highers/NVQ level 3 or equivalent"
label var educat04         "HNC, HND, NVQ level 4 or equivalent"
label var educat05         "Degree / NVQ level 5 or equivalent"
label var relig0           "Mother's religion"
label var bcountry0        "Mother's country of birth"
label var mltprg0          "Multiple births"
label var gparen0          "Grandparents live close-by"
label var childcare0       "Childcare from family and friends"


* time-varying covariates
for var cldill*:   label var X "Child not in good health"
for var concdev*:  label var X "Mother concerned about development"
for var mumill*:   label var X "Mother not in good health"
for var sibcat1*:  label var X "None"
for var sibcat2*:  label var X "One"
for var sibcat3*:  label var X "Two or more"
for var partner*:  label var X "Mother lives with partner"
for var parstat1*: label var X "No partner"
for var parstat2*: label var X "Lower educ. + cohab."
for var parstat3*: label var X "Lower educ. + married"
for var parstat4*: label var X "Higher educ. + cohab."
for var parstat5*: label var X "Higher educ. + married"
for var hhinc*:    label var X "Household income (in 1,000 GBP)"
for var incsup*:   label var X "Receives income support"
for var homeown*:  label var X "Homeowner"
for var urban*:    label var X "Urban area"
for var depriv*:   label var X "Scottish Index of Multiple Deprivation quintiles"
label var rmove "Cumulative no. of residential moves"


* auxiliary variables
label var wave             "Year after birth"
label var cens             "Censored at t+1"
label var sampleA          "Sample: target population"
label var sampleB          "Sample: selection model"
label var sampleC          "Sample: outcome model"
label var sweight          "Sampling weight (SW)"
label var yrcens           "Year of loss to follow-up"
label var yrmiss           "Year of first missing value (covars at t)"
label var yrmiss_nd        "Year of first missing value (covars at t-1)"


* drop unneccessary variables
drop mother1 preterm0 wrksbir0 visgpar0 move mltprg0 samesex Ma* Da* abc*    ///
	 pedu* pempl* hboard* gphome* miss* PicRaw3 PicSTS3 PicSPt3 NamRaw3      ///
	 NamVTS3 NamVPt3 PicRaw5 PicSPt5 NamRaw5 NamVPt5 mothres ///
	 fullemp partemp onleave mnssec pnssec regtyp empmis emiscnt5            ///
	 preterm0 wrksbir0 brstfed0 nssec*


* order variables
order Idnumber wave sample* cens sweight Nam* Pic* /// 
      empl ftyrs* ptyrs* *0* *_nd *_av


* sort data
sort Idnumber wave


* inspect data
describe                        // show all variables contained in data
notes                           // show all notes contained in data
codebook, problems              // potential problems in dataset
duplicates report Idnumber      // duplicates?
duplicates report Idnumber wave


*------------------------------------------------------------------------------*

label data "GUS BC1 Sweeps 1-5"


note: GUS Birth Cohort 1, 2005-2011, 11th Ed. (June 2013), ///
      doi: 10.5255/UKDA-SN-5760-4, Sweeps 1-5 combined


datasignature set, reset


save "${prepdat}/guslong.dta", replace


*==============================================================================*
