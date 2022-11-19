* importing the SAS naming conventions ;
options validvarname=v7;												


* Use every row to guess the type of column (because the CSV file has a lot of missing values) so we want SAS to use every row it can to determine 
  the type of column ;
proc import datafile='/home/u60849613/ECRB94/data/TSAClaims2002_2017.csv'
			dbms=csv
			out=t1.claims_cleaned
			replace;
	guessingrows=max;													
run;



/* E x p l o r e   D a t a */
* Use varnum in the proc contents to see the order the columns are in the table and not alphabetic order 
  Look at the total number of obs and variables, then look at the "Variable in Creation Order" look at the Format and see BEST12. to later change ;
proc print data=t1.claims_cleaned (obs=20);
run;

proc contents data=t1.claims_cleaned varnum;							
run;																	

* Explore the columns that need fixing and use the proc freq procedure since all the columns are categorical ;
* the FREQ proc allows you to see distinct values in each column and you can format date columns here too especially if you want to see a date
  column by year or by month which would be better since you would have a TON of distinct date values to comb thru ;
proc freq data=t1.claims_cleaned;
	tables claim_site													
			disposition
			claim_type
			date_received
			incident_date / nocum nopercent;
	format date_received incident_date year4.;							
run;

* Checking to see if the incident date happens before the date received 
  where "date recieved is prior to incident date" ;
proc print data=t1.claims_cleaned;
	where date_received < incident_date;								
	format date_received incident_date date9. ;
run;
		
proc freq data=t1.claims_cleaned;
	tables claim_site disposition claim_type ;
run;


/* P r e p a r e   D a t a */ *
	- Remove duplicate rows
	- sort the data by acsending Incident_Date
	- Clean the Claim_Site column 
	- Clean the disposition column
	- Clean the claim_type column
	- Convert State values to UPPERCASE and Statename to Propcase
	- Create a new column to indicate date issues.
	- Add permanet labels and formats
	- Exclude County and City from the output.  ;
	
* remove entirely duplicated rows, 27 rows were removed;
proc sort data=t1.claims_cleaned
		out=t1.table1 nodupkey 
		dupout=duppies ;
	by _all_;
run;

* sort the data by acsending Incident_date ;
proc sort data=t1.table1;
	by Incident_date;
run;

* Add permanent labels to columns by replacing any underscore with a space ;
data t1.table2;
	set t1.table1;
	if claim_site  IN ('','-') 											then claim_site='Unknown' ;
	if disposition IN ('','-') 											then disposition='Unknown' ;
		else if disposition= 'losed: Contractor Claim' 					then disposition='Closed:Contractor Claim';
		else if disposition= 'Closed: Canceled' 						then disposition='Closed:Canceled';
	if claim_type  IN ('','-') 											then claim_type='Unknown' ;
		if find(Claim_Type, '/') ne 0 then Claim_Type = SCAN(Claim_Type, 1,'/');
	State=upcase(State);
	StateName=propcase(StateName);
	if (Incident_Date > Date_received or
	    Date_received = .             or
	    Incident_Date = .			  or
	    year(Incident_Date) < 2002    or
	    year(Incident_Date) > 2017    or
	    year(Date_received) < 2002    or
	    year(Date_received) > 2017) then Date_Issues="Needs Review";
	format Incident_Date Date_Received date9. Close_Amount dollar20.2;
	label Airport_Code=  "Airport Code"																			
	      Airport_Name=  "Airport Name"
	      Claim_Number=  "Claim Number"
	      Claim_Site=    "Claim Site"
	      Claim_Type=    "Claim Type"
	      Close_Amount=  "Close Amount"
	      Date_Received= "Date Received"
	      StateName=     "State Name"
	      Incident_Date= "Incident Date"
	      Item_Category= "Item Category"
	      Date_Issues=   "Date Issues";
	drop County City;     
run;

proc freq data=t1.table2;
	table claim_type;
	run;

* Checking to see if everything we did above actually worked ;
proc freq data=t1.table2 order=freq;
	tables claim_site
			disposition
			claim_type
			date_issues / nocum nopercent;
run;

/* A n a l y z e   D a t a */
* The final output should be PDF
	1. How many date issues are in the data ?                     = 4,421 date issues
	For the remaining analysis remove all rows with date issues   = 516,587 records remaining
	2. How many claims per year of Incident Date ? INCLUDE PLOT   = 15 diff years of claims per year
	3. Create a dynamic code where inputting a specific state value can answer the following:
		- What are the freq for Claim Type for a selected state?
		- what are the freq values for Claim Site for a state?
		- What are the freq values for Disposition for a state?
		- What is the mean, min, max, and sum of Close Amount for a state? (round no decimals) ;

* Add proclabel for each procedure this will clean up the sections in the PDF;


/**********************/		
/* P D F  O U T P U T */
/**********************/		
%let outpath=/home/u60849613/TSA Claims Data/Output Tables ;
ods pdf file="&outpath/ClaimsReport.pdf" pdftoc=1 startpage=off;
ods noproctitle;

ods proclabel "Overall Data Issues";
title "Overall Date Issues in the Data";
proc freq data=t1.table2 ;
	table Date_Issues / missing nocum nopercent;
run;
title;

* Instead of having to create a new column called year that would group by each year,  just format the column name at the bottom with the year4. format ;
* Remember you must have ods graphics on before you do plots and you have to do slash plots=  then you can change the default vertical graph to horizontal
  and change the default freq counts to a graph that shows percentages. ;
ods graphics on;
ods proclabel "Overall Claims Per Year";
title 'Claims Per Year';
proc freq data=t1.table2 order= formatted ;
	table Incident_Date /nocum nopercent plots=freqplot(orient=horizontal /*scale=percent*/) ;
	format Incident_Date year4. ;
	where Date_Issues is null;
run;
title;


%let state=Hawaii;
ods proclabel "&state Claims Overview";
title "Frequency for Claim Type, Claim Site & Disposition For &state" ;
proc freq data=t1.table2 order=freq nlevels ;
	table claim_type claim_site disposition / nocum nopercent;
	where statename="&state" AND Date_Issues is null;
run;
title;

* Dont need the BY statement because of the WHERE statement ;	
ods proclabel "Close Amount Statistics";
title "Close Amount Statistics for &state";
proc means data=t1.table2 mean min max maxdec=0 sum;
	var close_amount;
	where statename="&state" and Date_Issues is null;
run;
title;

ods pdf close;


* Export Data (above)
	
	- Export to PDF using an ODS statement
	- Customize the procedure labels in your report ;
	
*	- the ods pdf needs the file= to tell SAS where the file should go 
  	- then ods noproctitle to get rid of the "The FREQ Procedure" 
  	- add title ''
  	- adding the title at the bottom ends the title statement and also close the pdf statement at the end
  	- style= adjusts the style duh
  	- dftoc determines the number of levels that is opened in the bookmarks tab
  	- customize the bookmark labels before the proc means and sgplots then use the ods proclabel statement;	
	
	

