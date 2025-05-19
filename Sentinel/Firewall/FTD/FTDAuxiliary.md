
# Create Firepower Auxiliary Table

## Instructions

Cisco Firepower logs are a great source of information, however can be quite costly when ingesting into Sentinel or other SIEMS. In this document I will walk through creating an Auxilary table in a Sentinel workspace and utilize Cisco ASA/FTD AMA Data Collection Rule to land FTD data into the lower cost table.Follow these steps to create the Firepower Auxiliary table in your Sentinel instance.

### Step 1: Get the following information
- Workspace Name
- Resource Group
- Subscription

### Step 2: Go to the [Create or Update Table API](https://learn.microsoft.com/en-us/rest/api/loganalytics/tables/create-or-update?view=rest-loganalytics-2022-10-01&tabs=HTTP) and select the **Try It** button.

### Step 3: Sign in with an account that has proper permissions to create tables in your Sentinel instance.

### Step 4: Populate the required fields with the data fetched above.

### Step 5: Enter `Firepower_CL` for `tableName`.

### Step 6: Change API version to `2023-01-01-preview`.

![API Version](https://github.com/user-attachments/assets/7a682d84-8b3c-4e44-9b9e-93b38ecbc4bd)

### Step 7: Paste contents of `Firepower.txt` in the Body Section - [Firepower.txt](https://github.com/MSJosh/documentation/blob/main/AMA/Firepower.txt).

### Step 8: Change retention to the desired time period. **Note:** Auxiliary only keeps data hot for 30 days.

### Step 9: Select **Run** and you should receive a `202` status code.

![Run Status](https://github.com/user-attachments/assets/606a1002-a61f-41f5-aeb8-e01f3eda775c)

### Step 10: Validate table's existance by going to the Log Analytics Workspace (LAW), Select Tables, and find the Firepower_CL table.
![image](https://github.com/user-attachments/assets/d41ad831-f403-452b-840d-674ea2460086)

## Create Data Collection Rule for FTD

### Step 1. Go to Content Hub in your Sentinel Instance and download/install 
  - Cisco ASA Solution
  - Data Collection Rule Toolkit 
### Step 2. Create a new data collection rule by going to Data Connectors (Might need to refesh page)
- Follow steps in documentation ensuring you select the facility Cisco FTD logs are being sent.
- Data will land in CommonSecurityLog until transformation in the data collection rule has been updated.
### Step 3. Open Workbooks and Select Data Collection Rule Toolkit ***Needs to be done in Azure Portal at time of me writing this**
- Select proper subscription and workspace
- Select the third option **Review/Modify DCR Rules** (yes it is Data Collection Rules Rules)
- Your DCRs will show up select the DCR created for CISCO FTD ad select **Modify DCR**
  ![image](https://github.com/user-attachments/assets/e70d7a74-0019-46b3-8da1-6a90fabea3e4)
-Scroll to the bottom of the JSON until you find Destination
![image](https://github.com/user-attachments/assets/2ce177cf-8df1-4388-8e0a-6a6b0cf70682)
- Add a , after the ] and enter the two additional rows after the ],
 "transformKql": "source",
 "outputStream": "Custom-Firepower_CL"

It should look like this
### Step 4. Select **Deploy Update** at the bottom of the window. 
- It will pop up a side bar confirming what is being done. When you hit the **Update DCR** button in this section it will do an API call to update the collection rule
- If it is successful you will get a green checkbox in the bell/status area in Azure.  
      
