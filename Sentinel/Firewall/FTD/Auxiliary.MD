


Create Firepower Aux table.


1. Get the following information
	1. Workspace Name
	2. Resource Group
	3 Subscription
2. Go to https://learn.microsoft.com/en-us/rest/api/loganalytics/tables/create-or-update?view=rest-loganalytics-2022-10-01&tabs=HTTP and select Try It button 
3. Sign in with account that has proper permissions to create tables in your sentinel instance 
4. Populate the required fields with the data fetched above.
5. Enter Firepower_CL for tableName
6.Change API version to 2023-01-01-preview
7. Paste contents of FirepowerBody.txt in Body Section
8. Change retention to desired time period. *Note Auxiliary only keeps data hot for 30 days.
9. Select Run and should recieve a 202. 
