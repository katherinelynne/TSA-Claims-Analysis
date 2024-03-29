# TSA Claims Case Study
> **NOTE:** *This project is an EDA for a dataset provided by SAS.*

## What is the purpose of this project? 
This dataset was apart of a Courseara course that allows you to do real-world analysis on TSA claims while providing a follow-along analysis. I however, did not follow-along with the case-study solutions provided by SAS as I wanted to see if I could properly analyze the dataset myself. 

## Where did the dataset come from?
The dataset is provided by SAS as a CSV file named TSA Claims 2002 to 2017. This file was created from publicly available data from the TSA and the Federal Aviation Administration, or FAA. The TSA data has information about claims and the FAA data has information about USA airport facilities. The case study data was prepared & simplified by SAS by concatenating individual TSA airport claims data, removing some extra columns, and then joining the concatenated TSA claims data with the FAA airport facilities data, this was to make it customized to the SAS Coursera Case Study specific questions. The TSA Claims 2002 to 2017 CSV file has 14 columns and over 220,000 rows. 

### Column Descriptions:
  *The Claim_Number column has a number for each claim. Some claims can have duplicate claim numbers, but different information for each claim. Those         claims are considered valid for this case study.* 

  *Incident_Date and Date_Received columns have the date the incident occurred and the date the claim was filed.*

  *Claim_Type has a type of the claim. There are 14 valid claim types.* 

  *The Claim_Site column has where the claim occurred. There are 8 valid values for claims site.* 

  *The Disposition column has a final settlement of the claim.* 

  *The Close_Amount column has dollar amount of the settlement.* 

  *The Item_Category column has a type of items in the claim. The values in this column vary by year, so you won't work with this column in this case         study.*

  *Airport_Code and Airport_Name columns have the code and the name where the incident occurred.* 

  *The County, City, State, and Statename columns have the location of the airport. The State column has a two letter state code and Statename has the full   state name.*

### Recommended Case Study Analysis:
1. How many date issues are in the overall data?
For the remaining analyses, exclude all rows with date issues.

2. How many claims per year of Incident_Date are in the overall data? Be sure to include a plot.

3. Lastly, a user should be able to dynamically input a specific state value and answer the following:

-  What are the frequency values for Claim_Type for the selected state?

-  What are the frequency values for Claim_Site for the selected state?

-  What are the frequency values for Disposition for the selected state?

-  What is the mean, minimum, maximum, and sum of Close_Amount for the selected state?

>The statistics should be rounded to the nearest integer.



## What is included in this project?
In this repo I provide my code written in SAS, and my final report exported as a PDF.
