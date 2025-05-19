
# Create Firepower Auxiliary Table

## Instructions

Follow these steps to create the Firepower Auxiliary table in your Sentinel instance.

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
