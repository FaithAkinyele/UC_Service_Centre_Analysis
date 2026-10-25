/*
Task 2: Data-quality checks
Section 1: Primary and composite key validation

Purpose:
To confirm that fields intended to identify records are populated
and unique at the expected grain of each table.
*/

USE UC_Service_Centre_Analysis
-- Check whether Claim_ID is populated and unique in ClaimsReceived.

SELECT
    COUNT(*) AS Total_Rows
FROM dbo.ClaimsReceived

SELECT
     COUNT(Claim_ID) AS Rows_With_Claim_ID
from dbo.ClaimsReceived
    
SELECT
     COUNT(DISTINCT Claim_ID) AS Distinct_Claim_IDs
FROM dbo.ClaimsReceived

-- Check whether Claim_ID is populated and unique in ClaimsReceived.

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(Claim_ID) AS Rows_With_Claim_ID,
    COUNT(DISTINCT Claim_ID) AS Distinct_Claim_IDs

FROM dbo.ClaimsReceived;
   

/*

What have we discovered?
The difference is: 30,613 - 30,565 = 48
This means there are 48 excess occurrences beyond the unique/distinct Claim_ID count.

Therefore, we must now identify:
1. whether blank-text IDs exist;
2. which Claim_ID values are duplicated;
3. how many times each duplicated ID occurs.

Next check: blank or space-only IDs
--Although COUNT(Claim_ID) confirmed there are no NULL values, 
it may still count '' or spaces as populated text.

*/

-- Count Claim_ID values that are NULL, empty or contain only spaces.

SELECT
    COUNT(*) AS Missing_Claim_ID_Rows
FROM dbo.ClaimsReceived
WHERE Claim_ID IS NULL
   OR LTRIM(RTRIM(Claim_ID)) = '';
-- This query above returned Missing_Claim_ID_Rows as 0 which means that no missing, empty or space-only Claim_ID values.



-- Next thing to do is to identify duplicated claim_IDs

-- Display every Claim_ID that appears more than once.

SELECT
    Claim_ID,
    COUNT(*) AS Occurrence_Count
FROM dbo.ClaimsReceived
WHERE Claim_ID IS NOT NULL
  AND LTRIM(RTRIM(Claim_ID)) <> ''
GROUP BY Claim_ID
HAVING COUNT(*) > 1
ORDER BY Occurrence_Count DESC, Claim_ID;

/*

This means each of these claim identifiers appears in two rows, even though ClaimsReceived is expected to contain one row per claim.

Because the earlier results showed:
- Total rows: 30,613
- Distinct Claim_ID values: 30,565
- Difference: 48

If every affected ID occurs exactly twice, this would mean:
- 48 duplicated Claim_ID groups
- 96 rows involved: 48 expected original rows plus 48 additional occurrences
- 48 excess rows
However, we should verify that every duplicate group occurs exactly twice and determine whether the duplicate rows are identical.

*/

-- Display every complete row belonging to a duplicated Claim_ID.

SELECT *
FROM dbo.ClaimsReceived
WHERE Claim_ID IN
(
    SELECT Claim_ID
    FROM dbo.ClaimsReceived
    WHERE Claim_ID IS NOT NULL
      AND LTRIM(RTRIM(Claim_ID)) <> ''
    GROUP BY Claim_ID
    HAVING COUNT(*) > 1
)
ORDER BY Claim_ID;

/*

The above query worked, however, it has revealed something important: 
these are not all exact duplicate rows.

For example:
- UC100501 has the same information except Submission_Channel is recorded as Telephone in one row and Phone in the other.
- UC101998 is recorded as Phone in one row and Online in the other.
- Some other pairs visible in the results appear completely identical.

Therefore, we have a mixture of:
1. Exact duplicates — every field is identical.
2. Conflicting duplicates — the same Claim_ID has different information in at least one field.

This means we must not simply use SELECT DISTINCT and assume the issue is solved. 
SELECT DISTINCT would remove identical copies, but it would retain conflicting rows because they are not identical.

Why this matters

If both rows are counted:
- claims received could be overstated;
- demand by centre or week could be overstated;
- customer-group figures could be distorted;
- channel analysis could be unreliable;
- joining these rows to contacts or completions could multiply other records.

Next, we check and find which fields conflict.

Two different situations exist

1. Different wording, possibly the same meaning

Telephone and Phone probably represent the same channel using inconsistent labels.
A likely later cleaning rule could standardise both to Telephone. 
However, we should first inspect all channel values and document this assumption.

2. Genuinely conflicting information

Phone and Online are different channels. We cannot determine from this table which value is correct.
We should not arbitrarily keep one of them.

What we can safely conclude now

- Claim_ID is not unique in ClaimsReceived.
- There are 30,613 rows but 30,565 distinct claim IDs.
- Therefore, there are 48 excess occurrences.
- The visible duplicate pairs include both identical and conflicting records.
- At least some conflicts occur in Submission_Channel.
- Counting rows as claims would overstate claims received.
- For claim volume, we should ultimately count distinct valid Claim_ID values, consistent with the exercise brief.
- Channel-level analysis requires additional treatment because a duplicated claim may be associated with competing channel values.

Appropriate proposed treatment

For now, record this approach:
- Preserve every original imported row.
- Use COUNT(DISTINCT Claim_ID) when calculating claims received.
- Remove exact duplicate copies only in a documented cleaned layer.
- Standardise obvious synonymous labels such as Phone and Telephone, subject to confirming the complete list of values.
- Flag genuinely conflicting channel pairs such as Phone and Online.
- Do not use an arbitrary “first row” rule unless agreed with the data owner.
- Report channel analysis as limited until a reliable record-selection rule is established.

*/ 

-- Compare the values held within each duplicated Claim_ID.

SELECT
    Claim_ID,
    COUNT(*) AS Row_Count,
    COUNT(DISTINCT Claimant_Key) AS Different_Claimant_Keys,
    COUNT(DISTINCT Centre_ID) AS Different_Centres,
    COUNT(DISTINCT Received_Date) AS Different_Received_Dates,
    COUNT(DISTINCT Reporting_Week_Start) AS Different_Reporting_Weeks,
    COUNT(DISTINCT Claim_Type) AS Different_Claim_Types,
    COUNT(DISTINCT Customer_Group) AS Different_Customer_Groups,
    COUNT(DISTINCT Submission_Channel) AS Different_Channels,
    COUNT(DISTINCT Priority_Flag) AS Different_Priority_Flags,
    COUNT(DISTINCT Evidence_Required) AS Different_Evidence_Values
FROM dbo.ClaimsReceived
GROUP BY Claim_ID
HAVING COUNT(*) > 1
ORDER BY Claim_ID;

/*
The result of the executed query above confirms my observation.

For every duplicated Claim_ID shown:

- Row_Count = 2
- all tested fields have a distinct count of 1 except 
  Different_Channels that sometimes has a value of 2

Therefore:
- every duplicated claim appears twice;
- the records agree on all tested fields;
- some pairs are exact duplicates;
- some pairs differ only in Submission_Channel.

Now we need one final number: 
how many of the 48 duplicated claim IDs have conflicting submission channels?

Your results confirm your observation.

For every duplicated Claim_ID shown:
- Row_Count = 2
- all tested fields have a distinct count of 1
- only Different_Channels sometimes has a value of 2

Therefore:

- every duplicated claim appears twice;
- the records agree on all tested fields;
- some pairs are exact duplicates;
- some pairs differ only in Submission_Channel.

Now we need one final number:
how many of the 48 duplicated claim IDs have conflicting submission channels?
*/

-- Count duplicated claims with different Submission_Channel values.

SELECT
    COUNT(*) AS Claims_With_Conflicting_Channels
FROM
(
    SELECT Claim_ID
    FROM dbo.ClaimsReceived
    GROUP BY Claim_ID
    HAVING COUNT(*) > 1
       AND COUNT(DISTINCT Submission_Channel) > 1
) AS Conflicting_Claims;

/* 
How this works

The query inside the brackets after the FROM statement finds claims that:
- appear more than once; and
- have more than one submission-channel value.

The outside query then counts how many claim IDs that inner query found
AS Conflicting_Claims is simply a required temporary name for the bracketed result. 
This bracketed result is called a subquery or derived table.

Once we have that number:
    Exact duplicate groups = 48 - claims with conflicting channels
*/

--- The number of claims with conflicting channels = 16

/*
Conclusion:

ClaimsReceived contains 30,613 rows but only 30,565 distinct Claim_ID
values. This represents 48 duplicated Claim_ID groups and 48 excess rows.

Each duplicated Claim_ID occurs twice, meaning 96 rows are involved.

Of the 48 duplicated Claim_ID groups:
- 32 are exact duplicate groups across the tested fields.
- 16 contain conflicting Submission_Channel values.
- No differences were detected in the other tested fields.

Impact:
Counting rows would overstate claims received by 48. Duplicate records
could also multiply rows when ClaimsReceived is joined to other tables.
Submission-channel analysis may be unreliable for the 16 conflicting claims.

Proposed treatment:
Preserve the imported records unchanged. Use distinct valid Claim_ID values
when calculating claims received. Remove exact duplicates in a documented
cleaned layer. Investigate and standardise synonymous channel labels, but
do not arbitrarily select between genuinely conflicting channel values.
*/