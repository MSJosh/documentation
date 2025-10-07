Signinlogs Transform
# Overview
Entra ID logs offer valuable insights for security detection and troubleshooting. However, the volume of logs can lead to high storage costs in Log Analytics and Microsoft Sentinel. While Microsoft 365 E5 customers benefit from a 5 MB/user/day Sentinel allotment, verbose logs can quickly exceed this limit.
This guide explains how to:
- Create auxiliary tables for SigninLogs and AADNonInteractiveUserSignInLogs
- Apply table transformations
- Reduce ingestion costs using transformation rules
🔗 For more information, see: https://learn.microsoft.com/en-us/entra/identity/monitoring-health/concept-log-monitoring-integration-options-considerations#estimate-your-costs
# Step 1: Create Auxiliary Tables
## Information Needed
- Sentinel Workspace Name
- Resource Group Name (Log Analytics Workspace location)
- Subscription Name
- Sample JSON files:
- - SigninLogs:[Signinlogs.json](https://github.com/MSJosh/documentation/blob/main/Sentinel/Entra%20ID/Signinlogs.json)
- - AADNonInteractiveUserSignInLogs:[AADNON.json](https://github.com/MSJosh/documentation/blob/main/Sentinel/Entra%20ID/AADNON.json)
## Instructions
- Go to the [Create or Update Table API](https://learn.microsoft.com/en-us/rest/api/loganalytics/tables/create-or-update?view=rest-loganalytics-2022-10-01&tabs=HTTP)
- Use an authorized account to create tables in Sentinel.
- For each table:
- - Set api-version to 2023-01-01-preview
- - Ensure tableName matches the JSON body (append _CL)
- - Adjust retention settings (default hot retention is 30 days; extendable up to 12 years)
- - Paste the full JSON into the request body
- Click Run. A 202 response indicates success.
- Repeat for the non-interactive table, adjusting names and retention accordingly.
![image](https://github.com/user-attachments/assets/75a4dfdf-25ab-4d26-ab8c-4537db3bc3b7)

# Step 2: Create the Table Transform Rule
## Instructions
- Navigate to your Log Analytics Workspace at portal.azure.com.
- Go to Settings > Tables.
- Ensure you have Contributor access.
- Locate SigninLogs in the table list.
- Click the ellipsis (...) and select Create Transformation.
- If no existing Data Collection Rule (DCR) exists:
- - Create a new one (only one DCR per workspace is allowed)
- - Name it clearly for future reference
- Click Next through the wizard without changes.
- Validate creation under Monitor > Settings > Data Collection Rules.
![image](https://github.com/user-attachments/assets/ad3622dc-6647-4f75-8fb7-ff1e3fb17233)

# Step 3: Use Data Collection Tool Kit Workbook
## Instructions
- [Data Collection Toolkit](https://techcommunity.microsoft.com/blog/microsoftsentinelblog/create-edit-and-monitor-data-collection-rules-with-the-data-collection-rule-tool/3810987)
- Go to Content Hub and search for Data Collection Toolkit.
- Install the workbook.
- Navigate to Threat Management > Workbooks and open the toolkit.
- Select Review/Modify DCR Rules.
- Click the whitespace next to the DCR name (not the name itself).
- Select Modify DCR.
- Scroll to the bottom of the JSON to find:
- - "Microsoft-Table-SigninLogs"
- - "Microsoft-Table-AADNonInteractiveUserSignInLogs"
- Follow the sample : [DCR.json](https://github.com/MSJosh/documentation/blob/main/Sentinel/Entra%20ID/DCR.json)
- - Stream data to both Log Analytics and Auxiliary tables
- Click Deploy Update, then Update DCR.
- If successful, a green check will appear. If not, check Azure Activity Logs for error details.

## Final Step
Once data is confirmed in the auxiliary tables, use transformKql to drop or modify data in the main Analytics tables to reduce ingestion costs.
