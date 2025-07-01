# CommonSecurityLog Auxiliary Table Setup Guide

## Overview

CommonSecurityLog provides valuable security information, but can be costly when ingesting into Microsoft Sentinel or other SIEMs. This guide walks you through creating an Auxiliary table in a Sentinel workspace and configuring the CommonSecurityLog AMA Data Collection Rule to redirect data to a lower-cost table.

> **💡 Key Benefit**: Auxiliary tables offer significant cost savings while maintaining essential security data accessibility.

## Prerequisites

Before starting, ensure you have:
- Administrative access to your Microsoft Sentinel workspace
- Permissions to create tables and data collection rules
- The following information ready:
  - Workspace Name
  - Resource Group
  - Subscription ID

## Part 1: Creating the CEF Auxiliary Table

### Step 1: Gather Required Information
Collect the following details from your Azure environment:
- **Workspace Name**: Your Log Analytics workspace name
- **Resource Group**: The resource group containing your workspace
- **Subscription**: Your Azure subscription ID

### Step 2: Access the Table Creation API
1. Navigate to the [Create or Update Table API](https://learn.microsoft.com/en-us/rest/api/loganalytics/tables/create-or-update?view=rest-loganalytics-2022-10-01&tabs=HTTP)
2. Click the **Try It** button to open the interactive API console

### Step 3: Authenticate
Sign in with an account that has the necessary permissions to create tables in your Sentinel instance.

### Step 4: Configure API Parameters
Fill in the required fields using the information gathered in Step 1:
- **Subscription ID**: Your Azure subscription
- **Resource Group Name**: Your workspace's resource group
- **Workspace Name**: Your Log Analytics workspace name

### Step 5: Set Table Name
Enter `CEF_CL` as the `tableName` parameter.

### Step 6: Update API Version
⚠️ **Important**: Change the API version to `2023-01-01-preview`

![API Configuration](https://github.com/user-attachments/assets/1430ff9c-cc59-4446-b5de-07b2b4112a3e)

### Step 7: Configure Table Schema
1. Paste the contents of the `CEFAux.json` file into the Body Section
2. **Reference**: [CEFAux.json](https://github.com/MSJosh/documentation/blob/main/Sentinel/Firewall/CommonSecurityLog/CEFAux.json)

### Step 8: Set Data Retention
Configure the retention period according to your requirements.

> **📝 Note**: Auxiliary tables keep data "hot" (readily accessible) for only 30 days. Plan your retention strategy accordingly.

### Step 9: Execute the Request
Click **Run** to create the table. You should receive a `202 Accepted` status code indicating successful creation.

![Run Status](https://github.com/user-attachments/assets/606a1002-a61f-41f5-aeb8-e01f3eda775c)

### Step 10: Verify Table Creation
1. Navigate to your Log Analytics Workspace (LAW)
2. Go to **Tables** section
3. Locate the newly created `CEF_CL` table

![Table Verification](https://github.com/user-attachments/assets/d3e814d1-c149-4553-879c-af020ced1aab)


## Part 2: Configuring Data Collection Rule

### Step 1: Install Required Content
Navigate to **Content Hub** in your Sentinel instance and install the following solutions:
- 📦 **Common Event Format**
- 🛠️ **Data Collection Rule Toolkit**

### Step 2: Create Initial Data Collection Rule
1. Go to **Data Connectors** (you may need to refresh the page after installing content)
2. Follow the setup documentation for Common Event Format
3. **Important**: Ensure you select the correct syslog facilities where CEF logs are being sent

![CEF Configuration](https://github.com/user-attachments/assets/66bceaa1-aae0-4ff5-addd-220a74b690ed)

> **⚠️ Temporary Behavior**: Initially, data will land in the standard `CommonSecurityLog` table until we update the transformation rule in the next step.

### Step 3: Modify Data Collection Rule
1. Navigate to **Workbooks** and select **Data Collection Rule Toolkit**
2. Configure the following:
   - Select your **subscription**
   - Select your **workspace**
3. Choose the third option: **Review/Modify DCR Rules**
4. Locate and select the DCR created for **Common Event Format**
5. Click **Modify DCR**

![DCR Selection](https://github.com/user-attachments/assets/121f16a2-0b4f-4f93-b571-d681f237644a)

### Step 4: Update JSON Configuration
1. Scroll to the bottom of the JSON configuration until you find the **Destination** section

![Destination Section](https://github.com/user-attachments/assets/b3f18174-92fa-428b-a01a-d07a56746499)

2. Add a comma after the closing bracket `]`
3. Insert the following two lines after the comma:

```json
"transformKql": "source\n",
"outputStream": "Custom-CEF_CL"
```

**Example of the final configuration:**
```json
{
  // ...existing configuration...
  "destinations": {
    // ...existing destinations...
  },
  "transformKql": "source\n",
  "outputStream": "Custom-CEF_CL"
}
```

### Step 5: Deploy the Updated Configuration
1. Click **Deploy Update** at the bottom of the window
2. A sidebar will appear confirming the changes
3. Click **Update DCR** to execute the API call
4. Monitor the notification bell in Azure for a green checkmark indicating successful deployment

## ✅ Verification and Next Steps

After completing these steps:
- CEF logs will now flow to your cost-effective `CEF_CL` auxiliary table
- Monitor data ingestion in the Log Analytics workspace
- Update any existing queries or alerting rules to reference the new table name
- Consider adjusting retention policies based on your compliance requirements

## 🔍 Troubleshooting

**Common Issues:**
- **API 4xx errors**: Verify permissions and API version
- **Missing table**: Check resource group and workspace names
- **No data flow**: Ensure DCR transformation is correctly configured
- **Permission errors**: Verify account has Log Analytics Contributor role

---

**📚 Additional Resources:**
- [Microsoft Sentinel Documentation](https://docs.microsoft.com/azure/sentinel/)
- [Log Analytics Table Management](https://docs.microsoft.com/azure/azure-monitor/logs/tables-feature-support)
- [Data Collection Rules Overview](https://docs.microsoft.com/azure/azure-monitor/essentials/data-collection-rule-overview)
