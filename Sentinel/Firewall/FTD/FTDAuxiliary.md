
Create Firepower Aux table.

Get the following information
Workspace Name
Resource Group 3 Subscription
Go to https://learn.microsoft.com/en-us/rest/api/loganalytics/tables/create-or-update?view=rest-loganalytics-2022-10-01&tabs=HTTP and select Try It button
Sign in with account that has proper permissions to create tables in your sentinel instance
Populate the required fields with the data fetched above.
Enter Firepower_CL for tableName 6.Change API version to 2023-01-01-preview
![image](https://github.com/user-attachments/assets/7a682d84-8b3c-4e44-9b9e-93b38ecbc4bd)

Paste contents of Firepower.txt in Body Section - https://github.com/MSJosh/documentation/blob/main/AMA/Firepower.txt
Change retention to desired time period. *Note Auxiliary only keeps data hot for 30 days.
Select Run and should recieve a 202.
![image](https://github.com/user-attachments/assets/606a1002-a61f-41f5-aeb8-e01f3eda775c)


