-- =====================================================
-- UC SERVICE CENTRE ANALYSIS
-- STAGE 2: VALIDATE THE IMPORTED TABLES
-- =====================================================


-- Select the database that contains the imported data.

USE UC_Service_Centre_Analysis;


-- Step 1: Preview the Claims Completed table.
-- TOP 10 displays ten sample rows without changing the data.

SELECT TOP 10 *
FROM dbo.ClaimsCompleted

-- Step 2: Count every row in the Claims Completed table.
-- This helps confirm how many records were imported.


SELECT COUNT(*) AS Total_Rows
FROM dbo.ClaimsCompleted

-- =====================================================
-- COUNT THE ROWS IMPORTED INTO EACH TABLE
-- Each query counts every record in one imported table.
-- The results will form our import-validation record.
-- =====================================================


-- Claims Completed

SELECT COUNT(*) AS ClaimsCompleted_Total_Rows
FROM dbo.ClaimsCompleted;


-- Claims Received

SELECT COUNT(*) AS ClaimsReceived_Total_Rows
FROM dbo.ClaimsReceived;


-- Customer Contacts

SELECT COUNT(*) AS CustomerContacts_Total_Rows
FROM dbo.CustomerContacts;


-- Customer Outcomes

SELECT COUNT(*) AS CustomerOutcomes_Total_Rows
FROM dbo.CustomerOutcomes;


-- Outstanding Caseload

SELECT COUNT(*) AS OutstandingCaseload_Total_Rows
FROM dbo.OutstandingCaseload;


-- Processing Times

SELECT COUNT(*) AS ProcessingTimes_Total_Rows
FROM dbo.ProcessingTimes;


-- Regions

SELECT COUNT(*) AS Regions_Total_Rows
FROM dbo.Regions;


-- Reporting Calendar

SELECT COUNT(*) AS ReportingCalendar_Total_Rows
FROM dbo.ReportingCalendar;


-- Service Centres

SELECT COUNT(*) AS ServiceCentres_Total_Rows
FROM dbo.ServiceCentres;


-- Staffing Capacity

SELECT COUNT(*) AS StaffingCapacity_Total_Rows
FROM dbo.StaffingCapacity;


--We noticed some discrepancy in our row count check different from the information provided in the exercise. 
--So we are now going to check if the inflated row count of 157 for both Region_ID and Centre_ID are as a result of importing blank rows.
--As we ought to have 6 unique Region_ID and 18 unique centre_ID.


-- Check how many Region rows contain a Region_ID.
-- COUNT(*) counts every imported row.
-- COUNT(Region_ID) counts only rows where Region_ID is not NULL.

SELECT
    COUNT(*) AS Total_Imported_Rows,
    COUNT(Region_ID) AS Rows_With_Region_ID
FROM dbo.Regions;


-- Check how many Service Centre rows contain a Centre_ID.

SELECT
    COUNT(*) AS Total_Imported_Rows,
    COUNT(Centre_ID) AS Rows_With_Centre_ID
FROM dbo.ServiceCentres;

--SQL imported 157 rows into each table.
--Only 6 region rows contain a Region_ID.
--Only 18 service-centre rows contain a Centre_ID.
--The remaining rows probably came from Excel’s formatted table range.

--Before concluding that these rows are completely blank, inspect a sample:

-- Preview rows in Regions that have no Region_ID.
-- This helps us check whether they are entirely blank.

SELECT TOP 10 *
FROM dbo.Regions
WHERE Region_ID IS NULL;


-- Preview rows in Service Centres that have no Centre_ID.

SELECT TOP 10 *
FROM dbo.ServiceCentres
WHERE Centre_ID IS NULL;

/*
The result of the query above also reveals an unexpected column called F5 in Regions. 
This was probably created because Excel included an additional blank column in the imported range.
However, we inspected only 10 rows. To prove that all the extra rows are completely blank, we would run the query below:
*/

-- Count completely blank rows in Regions.

SELECT COUNT(*) AS Completely_Blank_Region_Rows
FROM dbo.Regions
WHERE Region_ID IS NULL
  AND Region_Name IS NULL
  AND Directorate IS NULL
  AND Reporting_Group IS NULL
  AND F5 IS NULL;


-- Count completely blank rows in Service Centres.

SELECT COUNT(*) AS Completely_Blank_ServiceCentre_Rows
FROM dbo.ServiceCentres
WHERE Centre_ID IS NULL
  AND Centre_Name IS NULL
  AND Region_ID IS NULL
  AND Region_Name IS NULL
  AND Capacity_Band IS NULL
  AND Target_Processing_Days IS NULL
  AND Operational_Lead_Code IS NULL
  AND Opened_Date IS NULL;

  /*
Conclusion:

The import produced 151 completely blank rows in the Regions table
and 139 completely blank rows in the ServiceCentres table.

An additional empty column named F5 was also imported into Regions.

These are import artefacts, probably caused by the formatted Excel ranges.
They should be excluded from the analytical model without altering
the original Excel source files.
*/  


/*
Before documenting F5 as an entirely empty column, 
we should quantify it rather than rely only on the ten-row sample.
*/

-- Check whether the unexpected F5 column contains any values.
-- COUNT(F5) counts only rows where F5 is not NULL.

SELECT
    COUNT(*) AS Total_Region_Rows,
    COUNT(F5) AS Rows_With_F5_Value
FROM dbo.Regions;

/* 
After executing the query abovw, Rows_With_F5_Value returned  0, 
so we can confidently record that F5 is an entirely empty import artefact with:
- total Regions rows: 157;
- rows containing an F5 value: 0.
*/


