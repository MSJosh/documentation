1. Create Data Connector with common security
2. Validate log generation into common security (Add steps)
3. Create Aux Table

## Instructions

Cisco Firepower logs are a great source of information, however can be quite costly when ingesting into Sentinel or other SIEMS. In this document, I will walk through creating an Auxiliary table in a Sentinel workspace and utilize Cisco ASA/FTD AMA Data Collection Rule to land FTD data into the lower cost table. Follow these steps to create the Firepower Auxiliary table in your Sentinel instance.

### Step 1: Get the following information
- Workspace Name
- Resource Group
- Subscription

### Step 2: Go to the [Create or Update Table API](https://learn.microsoft.com/en-us/rest/api/loganalytics/tables/create-or-update?view=rest-loganalytics-2022-10-01&tabs=HTTP) and select the **Try It** button.

### Step 3: Sign in with an account that has proper permissions to create tables in your Sentinel instance.

### Step 4: Populate the required fields with the data fetched above.

### Step 5: Enter `CEF_CL` for `tableName`.

### Step 6: Change API version to `2023-01-01-preview`.

![image](https://github.com/user-attachments/assets/1430ff9c-cc59-4446-b5de-07b2b4112a3e)


### Step 7: Paste contents of `CEFAux.json` in the Body Section - [CEFAux.json](https://github.com/MSJosh/documentation/blob/main/Sentinel/Firewall/CommonSecurityLog/CEFAux.json).

### Step 8: Change retention to the desired time period. **Note:** Auxiliary only keeps data hot for 30 days.

### Step 9: Select **Run** and you should receive a `202` status code.

![Run Status](https://github.com/user-attachments/assets/606a1002-a61f-41f5-aeb8-e01f3eda775c)

### Step 10: Validate table's existence by going to the Log Analytics Workspace (LAW), Select Tables, and find the CEF_CL table.
![image](https://github.com/user-attachments/assets/d3e814d1-c149-4553-879c-af020ced1aab)


## Create Data Collection Rule for CommonSecurityLog

### Step 1: Go to Content Hub in your Sentinel Instance and download/install 
  - Common Event Format
  - Data Collection Rule Toolkit 

### Step 2: Create a new data collection rule by going to Data Connectors (Might need to refresh page)
- Follow steps in documentation ensuring you select the facilities CEF logs are being sent.
  ![image](https://github.com/user-attachments/assets/66bceaa1-aae0-4ff5-addd-220a74b690ed)

- Data will land in CommonSecurityLog until transformation in the data collection rule has been updated.

### Step 3: Open Workbooks and Select Data Collection Rule Toolkit **Needs to be done in Azure Portal at time of me writing this**
- Select proper subscription and workspace
- Select the third option **Review/Modify DCR Rules** (yes it is Data Collection Rules Rules)
- Your DCRs will show up, select the DCR created for  Common Event Formatand select **Modify DCR**
 ![image](https://github.com/user-attachments/assets/121f16a2-0b4f-4f93-b571-d681f237644a)

- Scroll to the bottom of the JSON until you find Destination

![image](https://github.com/user-attachments/assets/b3f18174-92fa-428b-a01a-d07a56746499)

- Add a comma after the closing bracket `]` and enter the two additional rows after the comma:
          "transformKql": "source\n",
          "outputStream": "Custom-CEF_CL"

It should look like this

### Step 4: Select **Deploy Update** at the bottom of the window. 
- It will pop up a side bar confirming what is being done. When you hit the **Update DCR** button in this section it will do an API call to update the collection rule
- If it is successful you will get a green checkbox in the bell/status area in Azure.
