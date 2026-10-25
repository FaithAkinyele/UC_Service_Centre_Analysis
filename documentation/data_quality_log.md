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

