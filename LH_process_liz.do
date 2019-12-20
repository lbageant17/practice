*

blah blah blah

* Liz Bageant
** September 2 2016

** Reshape and organize Livelihood Survey

clear all 
set more off

** Cover

use "$stata/Livelihood_Cover.dta",clear // open original file
	ren *,l
	destring hhid year,replace
	* dropping irrelevant or sensitive variables.
	drop a1 a3 a4 
	* renaming and labeling
	ren a2 enum
	ren a6 int_mon
	ren a7 int_year 
	la var int_year "Year of interview"
	la var int_day "Day of interview"
	la var int_mon "Month of interview"
	ren (a8-a13) (village commune district province cfr_name cfr_num)
	isid hhid year // check identifiers
	la data "Identifiers are hhid year"
saveold"$processed/LH_cover_hhid.dta",replace // saveoldto processed data folder according to naming convention

** A:  Personal Info
use "$stata/Livelivehood_PersonalInfo_Q2.dta",clear
	ren *,l
	* renaming and labeling
	ren (q1-q8) (pid sex age rel educ occ1 occ2 occ3)
	la var pid "Individual ID"
	la var rel "Relationship to household head"
	la var educ "Number of years of education successfully completed"
	la var occ1 "Primary occupation"
	la var occ2 "Secondary occupation 1"
	la var occ3 "Secondary occupation 2"
	la var sex "Sex (1=male)"
	la var age "Age" 

	destring age hhid year pid,replace

	replace sex="1" if sex=="male"
	replace sex="0" if sex=="female"
	destring sex,replace
	* there is a problem with the identifier
	duplicates tag hhid pid year,gen(tag)
	list year pid sex age rel tag if hhid==629,clean noobs
		/*
			year   pid   sex   age               rel   tag  
			2012     1     1    27   Household head      0  <--the household head in 2012 is not the same as the household head in 2015.
			2012     2     0    37           Spouse      0  <--this person is likely the household head in 2015 because sex and age are consistent and the 2012 household head is not listed in the 2015 hh roster.
			2012     3     0    65           Parent      0  
			2015     1     1    35    Household head     1  <--I will assign a new pid to this person to fix the identifier issue. Unclear whether they are a household head (why would there be two?  is that allowed in this survey?)
			2015     1     0    40    Household head     1  
			2015     2     1    22      Son/daughter     0  
			2015     3     1    19      Son/daughter     0 
		*/
	replace pid=4 if pid==1 & year==2015 & hhid==629 & age==35  // 1 change made.  ok for now.  
	isid hhid pid year
	la data "Identifiers are hhid pid year"
saveold "$processed/LH_A_pid.dta",replace

* these are questions in module A that are at the household level, saving separately.
use "$stata/Livelihood_PersonalInfo_Q3-4.dta",clear
	ren *,l
	destring hhid year,replace
	la var q3_1 "Occupation most important for household income 1"
	la var q3_2 "Occupation most important for household income 2"
	la var q4_1 "Occupation most important for hh food security 1"
	la var q4_2 "Occupation most important for hh food security 2"
	isid hhid year
	la data "Identifiers are hhid year"
saveold "$processed/LH_A_hhid.dta",replace

** B1:  Housing and HH Assets
use "$stata/Livelihood_Assets_Q5-12.dta",clear
	ren *,l
	destring hhid year,replace
	ren (q5_7 q6_8 q7_6 q8_6) (q5_other q6_other q7_other q8_other)
	la var q5 "Wall material"
	la var q5_other "Wall material (other)"
	la var q6 "Roof material"
	la var q6_other "Roof material (other)
	la var q7 "Primary drinking water source--wet season"
	la var q7_other "Primary drinking water source--wet season (other)"
	la var q8_other "Primary drinking water source--dry season (other)"
	la var q8 "Primary drinking water source--dry season"
	la var q10 "HH connected to main power line"
	la var q11 "Toilet status of HH"
	la var q11 "Toilet status of HH (inside/outside/none)"
	la var q9_1 "Main type of fuel used for cooking 1"
	la var q9_2 "Main type of fuel used for cooking 2"
	la var q9_3 "Main type of fuel used for cooking 3"
	ren (q12_1 q12_2 q12_3 q12_4 q12_5 q12_6 q12_7 q12_8 q12_9 q12_10 q12_11 q12_12) ///
		(bicycle cell landline mbike car tv radio cd fan stove sewing other)	
	la var bicycle "HH owns bicycle"
	la var cell "HH owns cell phone"
	la var landline "HH owns 'table phone'"
	la var mbike "HH owns motorcycle"
	la var car "HH owns car/truck/van"
	la var tv "HH owns television"
	la var radio "HH owns radio"
	la var cd "HH owns CD/DVD player or karaoke machine"
	la var fan "HH owns electric fan"
	la var sewing "HH owns sewing machine"
	la var stove "HH owns gas stove"
	la var other "Other household asset"
	isid hhid year
	la data "Identifiers are hhid year"
saveold "$processed/LH_B1_hhid.dta",replace

** B2: Livelihood Assets
*Q13
use "$stata/Livelihood_Assets_Q13.dta",clear
	ren *,l
	ren item fishasset
	la var fishasset "Type of livelihood asset owned"
	la var q13 "Number of [fishasset] owned"
	isid hhid year fishasset
	la data "Identifiers are hhid year fishasset"
saveold"$processed/LH_B2_fishasset.dta",replace
*Q14
use "$stata/Livelihood_Assets_Q14.dta",clear // This could potentially be combined into Q13 and Q17 
	la var q14 "Number of trap ponds owned"
	isid hhid year
saveold "$processed/LH_B2_hhid.dta",replace
*Q15
use "$stata/Livelihood_Assets_Q15",clear
	ren item pond
	la var q15_1 "Size of trap pond (m2)"
	la var q15_2 "Distance from CFR (m)"
	isid hhid year pond
saveold "$processed/LH_B2_pond.dta",replace
*Q16
use "$stata/Livelihood_Assets_Q16.dta",clear
	ren item farmasset
	la var q16 "Number of [farmasset] owned"
	isid year hhid farmasset
saveold "$processed/LH_B2_farmasset",replace
*Q17 // this could potentially be combined into one file with Q13 and Q14 
use "$stata/Livelihood_Assets_Q17.dta",clear
	ren item aquaasset
	la var aquaasset "Aquaculture asset"
	la var q17 "Number of [aquaasset] owned"
	isid hhid year aquaasset
saveold "$processed/LH_B2_aquaasset.dta",replace

** C: Farming
use "$stata/Livelihood_Farming_Q18-23.dta",clear
	ren *,l
	destring *,replace
	la var q18_2 "Total land area of paddy fields (Ha)"
	la var q18_3 "Inundated/flooded area (Ha)"
	la var q18_4 "Duration of indundation/flooding (months)"
	la var q19_2 "Total area of paddy connected to CFR (Ha)"
	la var q19_3 "Inundated/flooded paddy area connected to CFR (Ha)"
	la var q19_4 "Duration of inundation/flooding in paddy connected to CFR (months)"
	la var q20_2 "Total area of chamka land (Ha)"
	la var q20_3 "Inundated/flooded chamka land area (Ha)"
	la var q20_4 "Duration of inundation/flooding in chamka land (months)"
	la var q21_2 "Total area of fallow land (Ha)"
	la var q21_3 "Inundated/flooded fallow land area (Ha)"
	la var q21_4 "Duration of inundation/flooding in fallow land (months)"
	la var q22 "Total area of home garden (Ha)"
	la var q23_2 "Total ag land owned--incl paddy chamka gardens (Ha)"
	la var q23_3 "Total ag land rented out--incl paddy chamka gardens (Ha)"
	la var q23_4 "Total ag land rented in--incl paddy chamka gardens (Ha)"
	la var q23_5 "Total ag land community owned--incl paddy chamka gardens (Ha)"
	isid hhid year
	la data "Identifiers are hhid year"
saveold"$processed/LH_C_hhid.dta",replace

use "$stata/Livelihood_Farming_Q24",clear
	destring hhid year,replace
	destring q24_2 q24_3 q24_4 q24_5 q24_6,replace
	ren *,l
	ren item crop
	la var crop "Crop type"
	la var q24_2 "Month of harvest"
	duplicates tag hhid crop year,gen(tag)
		// some households are producing multiple harvests of the same crop in 
		// different months.  
	duplicates tag hhid crop year q24_2,gen(tag2)
		// two households produce multiple harvests of the same crop in the same month.
		// for these households I will combine them. 
		collapse (sum) q24_3-q24_6,by(hhid crop year q24_2 tag2)
		drop tag2
		ren q24_2 month
	* identifier for this file is hhid year crop month
	la data "Identifiers are hhid year crop month"	
	la var q24_3 "Quantity harvested (Kg)"
	la var q24_4 "Quantity consumed (Kg)"
	la var q24_5 "Quantity sold (Kg)"
	la var q24_6 "Quantity bartered (Kg)"
	isid hhid year crop month
saveold"$processed/LH_C_crop.dta",replace

** D: Livestock
* Q25
use "$stata/Livelihood_Livestock_Q25.dta",clear
	isid hhid year // ok
	la var q25 "Bought, sold or owned livestock in past 12 months"
saveold "$processed/LH_D_hhid",replace
* Q26
use "$stata/Livelihood_Livestock_Q26.dta",clear
	ren item animal
	la var q26_2 "Number of [animal] currently owned"
	la var q26_3 "Number of [animal] given away or consumed in past 12 months"
	la var q26_4 "Number of [animal] purchased in past 12 months"
	la var q26_5 "Number of [animal] sold/bartered in past 12 months"
	isid hhid year animal
saveold "$processed/LH_D_animal",replace



** E: Fishing
*Q27
use "$stata/Livelihood_Fishing_Q27.dta",clear
	la var q27 "Did HH go fishing or 'take fish'?  Excl. commercial fisheries"
	isid hhid year
save "$processed/LH_E_hhid.dta",replace
*Q28
use "$stata/Livelihood_Fishing_Q28.dta",clear
	ren item season
	la var groupsp "Fish or OAA"
	la var season Season
	la var q28_1 "Catch from flooded rice fields (% of season/groupsp total)"
	la var q28_2 "Catch from canals and rivers (% of season/groupsp total)"
	la var q28_3 "Catch from Tonle Sap lake open area (% of season/groupsp total)"
	la var q28_4 "Catch from flooded forest (% of season/groupsp total)"
	la var q28_5 "Catch from reservoir and lake (% of season/groupsp total)"
	la var q28_6 "Estimated total catch (kg per season/groupsp)"
	isid hhid year season groupsp
save "$processed/LH_E_groupsp.dta",replace
*Q29
use "$stata/Livelihood_Fishing_Q29.dta",clear
	ren item season
	ren (q29_1_1 q29_1_2 q29_1_3 q29_2_1 q29_2_2 q29_2_3) (q29_fish_1 q29_fish_2 q29_fish_3 q29_oaa_1 q29_oaa_2 q29_oaa_3)
	la var q29_fish_1 "Sold fresh"
	la var q29_fish_2 "Consumed fresh"
	la var q29_fish_3 "Processed"
	la var q29_oaa_1 "Sold fresh"
	la var q29_oaa_2 "Consumed fresh"
	la var q29_oaa_3 "Processed"
	isid hhid year season
save "$processed/LH_E_season.dta",replace
*Q30
use "$stata/Livelihood_Fishing_Q30.dta",clear
	ren item product
	la var q30_2 "Consumed by household (% of HH catch)"
	la var q30_3 "Barter or given (% of HH catch)"
	la var q30_4 "Sold (% of HH catch)"
	la var q30_5 "Stored > 1 year (% of HH catch)"
	la var q30_6 "Months per year with processed fish in storage"
	isid hhid year product
save "$processed/LH_E_product.dta",replace
*Q31
use "$stata/Livelihood_Fishing_Q31.dta",clear
	ren item pond2 
	la var pond2 "Not clear if this corresponds to Q15 'pond' variable"
	la var q31_1 "Catch (annual kg/pond)"
	la var q31_2 "Month of peak catch"
	isid hhid year pond2
save "$processed/LH_E_pond2.dta",replace
*Q32
use "$stata/Livelihood_Fishing_Q32.dta",clear
	la var q32_1 "Primary use of fishing income"
	la var q32_2 "Secondary use of fishing income"
	la var q32_3 "Tertiary use of fishing income"
	isid hhid year
save "$processed/LH_E_hhid.dta",replace


** G: Relative Income / Expenditure




** H: Food and Nutrition
//there might be some weird ordering--G combined with L in questionnaire.


use "$stata/Livelihood_Food_Q41.dta",clear
	ren *,l
	destring hhid year,replace
	ren (q41_1 q41_2 q41_3 q41_4) (season1 season2 season3 season4)
	la var season1 "No water/lowest river flow"
	la var season2 "Water level rising"
	la var season3 "Peak flood"
	la var season4 "Water receding"  
	la var item "Food item"
isid hhid year item
saveold"$processed/LH_H_item.dta",replace


** I:  Income/expenditures shocks

** L:  Health






