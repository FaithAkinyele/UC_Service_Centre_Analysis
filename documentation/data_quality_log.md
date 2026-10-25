\# Data Quality Log



\## Project



UC Service Centre Analysis



\## Purpose



This log records each identified data-quality issue, the supporting evidence, its possible effect on the analysis, the proposed treatment and any remaining limitation.



The original Excel source files will not be silently altered. Data-quality treatments will be applied through documented and reproducible SQL.



\## Identified Issues



\### DQ-001: Completely blank imported rows



\*\*Affected tables:\*\* Regions and ServiceCentres



\*\*Evidence:\*\*



\- Regions contained 157 imported rows.

\- Only 6 rows contained a Region\_ID.

\- 151 rows were confirmed as completely NULL across all columns.

\- ServiceCentres contained 157 imported rows.

\- Only 18 rows contained a Centre\_ID.

\- 139 rows were confirmed as completely NULL across all columns.



\*\*Likely cause:\*\*



The formatted Excel table ranges probably extended beyond the populated records, causing blank rows to be imported into SQL Server.



\*\*Possible effect:\*\*



Using COUNT(\*) without filtering would incorrectly report 157 regions and 157 service centres. The blank rows also contain no valid keys and cannot participate reliably in table relationships.



\*\*Proposed treatment:\*\*



Retain the imported tables as evidence of the source import. Exclude records with NULL Region\_ID or Centre\_ID from the analytical model through documented SQL cleaning or staging logic.



\*\*Status:\*\*



Identified and quantified. Treatment not yet applied.



\*\*Remaining limitation:\*\*



The cause is inferred from the imported data and Excel formatting. It has not been confirmed with a source-system owner.





\### DQ-002: Unexpected empty F5 column



\*\*Affected table:\*\* Regions



\*\*Evidence:\*\*



\- An unexpected column named F5 was imported.

\- Regions contained 157 rows.

\- COUNT(F5) returned 0, confirming that the column contains no values.



\*\*Likely cause:\*\*



An additional blank Excel column was included in the worksheet import range.



\*\*Possible effect:\*\*



The column does not currently alter calculated results because it contains no values. However, retaining unexplained fields could confuse users and make the analytical model less clear.



\*\*Proposed treatment:\*\*



Exclude F5 from the cleaned analytical table or view. Do not change the original Excel source file silently.



\*\*Status:\*\*



Identified and quantified. Treatment not yet applied.



\*\*Remaining limitation:\*\*



The cause is inferred from the import structure and has not been confirmed with a source-system owner.





\## DQ-003 — Duplicate Claim\_ID values in ClaimsReceived



\*\*Table:\*\* `dbo.ClaimsReceived`  

\*\*Field:\*\* `Claim\_ID`  

\*\*Issue type:\*\* Primary-key uniqueness and conflicting records



\*\*Evidence:\*\*  

The table contains 30,613 rows and 30,565 distinct Claim\_ID values. SQL checks identified 48 duplicated Claim\_ID groups, each occurring twice, meaning 96 rows are involved and there are 48 excess occurrences.



Of the 48 duplicated Claim\_ID groups, 32 are exact duplicates across the tested fields. The remaining 16 contain different raw Submission\_Channel values while the other tested fields agree.



\*\*Likely effect:\*\*  

Counting rows would overstate claims received by 48. Duplicate claims could multiply records when joined to completion, outcome or contact tables. Submission-channel analysis may also be unreliable for the conflicting records.



\*\*Proposed treatment:\*\*  

Preserve the imported source table unchanged. Use distinct valid Claim\_ID values for claims-received measures. Remove exact duplicate copies only within a documented cleaned layer. Review and standardise synonymous channel labels, such as Phone and Telephone, while retaining genuinely conflicting channel values for investigation rather than selecting one arbitrarily.



\*\*Remaining limitation:\*\*  

The supplied data does not identify which submission-channel value is authoritative where genuinely different channels are recorded for the same claim.



\*\*Status:\*\*  

Quantified; cleaning rule partly agreed, with conflicting channels requiring further review.


### DQ-004 — Completely blank rows in ClaimsCompleted

- **Table:** ClaimsCompleted

- **Issue:** The imported table contains 3,585 completely blank rows.

- **Evidence:** There are 30,613 imported rows, but only 27,028 contain a Completion_ID. All 3,585 rows without a Completion_ID are blank across every completion field, and none are partially populated.

- **Effect:** Counting all imported rows would overstate the number of completion records by 3,585 and could distort completion measures.

- **Treatment:** Preserve the original source data, but exclude completely blank rows from the cleaned analytical layer.

- **Remaining limitation:** The blank rows appear to be Excel-import artefacts caused by the formatted worksheet range. This interpretation should be confirmed against the source workbook and import process.

