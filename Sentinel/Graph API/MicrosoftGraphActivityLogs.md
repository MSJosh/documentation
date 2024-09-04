
## Optimize Microsoft Graph Activity Logs

Microsoft Graph Activity Logs provide an audit trail of all HTTP requests that the Microsoft Graph service has received and processed for a tenant. These logs are essential for monitoring and analyzing activities within your Microsoft Graph environment. Tenant administrators can enable the collection of these logs and configure downstream destinations using diagnostic settings in Azure Monitor. The logs include API requests made from a variety of sources, including line-of-business applications, API clients, SDKs, and Microsoft applications like Outlook, Microsoft Teams, or the Microsoft Entra admin center.

For more information, see: [Microsoft Graph Activity Logs Overview](https://learn.microsoft.com/en-us/graph/microsoft-graph-activity-logs-overview)

### Storage and Export Options

The logs are stored in Log Analytics for analysis. Additionally, they can be stored in the archive tier for long-term storage in Log Analytics Workspace (LAW). You can also export them to Azure Storage for long-term storage or stream them with Azure Event Hubs to external SIEM tools for alerting, analysis, or archival.

For more details, see: [Manage Data Retention in a Log Analytics Workspace - Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/data-retention-configure?tabs=portal-3%2Cportal-1%2Cportal-2)

### Reviewing and Implementing Detection Methods

Ingesting Microsoft Graph Activity Logs is an effective way to review access via the Graph API. When ingested with Azure Sentinel, organizations can implement detection methods. As with other logs, it's beneficial to regularly review these logs to ensure quality, quantity, and proper configuration of detections. This document will guide you through these considerations and suggest best practices.



## Quality

Like other tables within Azure and Entra, Microsoft provides additional columns in the `MicrosoftGraphActivityLogs` table that may not be beneficial for security teams. As of this writing, Microsoft is creating 24 columns that are written to this table.

For more details, see: [Access Microsoft Graph activity logs - Microsoft Graph | Microsoft Learn](https://learn.microsoft.com/en-us/graph/microsoft-graph-activity-logs-overview#what-data-is-available-in-the-microsoft-graph-activity-logs)

This article focuses on security-related detections and hunting. If an organization needs to retain all items of the log, it's recommended to have a separate pipeline configured to go to lower-cost storage.

### Reduce Ingestion Cost and Noise

To optimize your log ingestion, you can create a table-level transformation rule for the `MicrosoftGraphActivityLogs` table. This will help reduce the amount of unnecessary data written to the table, which might not be needed for security operations. Note that these are general recommendations and each environment may have different requirements. Be sure to understand each column you are excluding.

# Notable Activity Log Fields

The output log contains many fields. The following table lists the fields that are relevant to threat investigations.

| Field                | Details                                                       |
|----------------------|---------------------------------------------------------------|
| **TimeGenerated [UTC]** | The date and time the request was received.                 |
| **AppId**            | The identifier of the application.                            |
| **IPAddress**        | The IP address of the client from where the request occurred. |
| **ServicePrincipalId** | The identifier of the service principal making the request.  |
| **RequestId**        | The identifier that represents the request.                   |
| **RequestMethod**    | The HTTP method of the event.                                 |
| **ResponseStatusCode** | The HTTP response status code for the event.                 |
| **RequestUri**       | The URI of the request.                                      |
| **ResponseSizeBytes** | The size of the response in bytes.                           |
| **Roles**            | The roles in token claims.                                   |


#### Steps to Create a Transformation Rule

1. Access your Log Analytics workspace in Azure and go to **Settings > Tables**.
2. Find `MicrosoftGraphActivityLogs` in the list of tables, click the ellipsis (`...`) to the right of the table name, and select ![image](https://github.com/user-attachments/assets/8f6b2861-3b13-4eab-91c6-eb1a4fc16b71).
3. Create a collection rule (DCR) if one is not already created. This DCR is tied to the Log Analytics workspace and can be used for other table-level transformations. Note that there is currently a limit of 10 transformations per DCR.
4. Once the DCR has been created, select **Next** to proceed to the Schema and Transformation page. This will show a sample set of data, allowing you to decide what is valuable and what might be dropped. Select ![image](https://github.com/user-attachments/assets/5ea11518-8b66-4cf4-a6e0-695853eacf98)
, which will open a new window to enter the transformation rule.
5. Copy and paste the following KQL query to stop ingesting data to these columns:

    ```kql
    Source
    | project-away TenantId, OperationId, ClientRequestId, ApiVersion, AadTenantId, SignInActivityId, Wids
    ```

6. Run the query to validate that the data looks correct and no errors occurred. Select **Apply** and then **Next**.
7. Select the ![image](https://github.com/user-attachments/assets/e8c86f9f-e06a-4bcd-80fb-4cea1f3e17ad) button to apply the transformation rule to the DCR. Allow 5-15 minutes for this rule to take effect in your environment.


## Clean Up Log Data to Be More Readable

To make the `MicrosoftGraphActivityLogs` data more readable, you can transform the log data with the following KQL query. This will parse and organize the data into a more manageable format:

```kql
//Clean up Uri and API path to be more readable 
MicrosoftGraphActivityLogs
| extend ParsedUri = tostring(parse_url(RequestUri))
| extend Host = tostring(parse_json(ParsedUri).Host)
| extend GraphAPIPath = tolower(replace_string(ParsedUri, "//", "/"))
| extend GraphAPIResource = tostring(split(GraphAPIPath, "/")[2])
| project TimeGenerated, RequestMethod, IPAddress, Roles, AppId, ServicePrincipalId, Host, GraphAPIResource
```

```kql
//Join with Identityinfo to align to user.
MicrosoftGraphActivityLogs
| where isnotempty(UserId)
| join kind=leftouter IdentityInfo on $left.UserId == $right.AccountObjectId
| where isnotempty(AccountUPN)
| project-reorder TimeGenerated, AppId, IPAddress, AccountUPN, AccountCreationTime, AssignedRoles, ServicePrincipalId, RequestId, RequestMethod, ResponseStatusCode, RequestUri, ResponseSizeBytes, Roles
```
```kql
//Clean up location information
MicrosoftGraphActivityLogs
| extend GeoIPInfo = geo_info_from_ip_address(IPAddress)
| extend country = tostring(parse_json(GeoIPInfo).country)
| extend state = tostring(parse_json(GeoIPInfo).state)
| extend city = tostring(parse_json(GeoIPInfo).city)
```

## Quantity
The transformation above converts the data into a more readable format and excludes columns that are less relevant for security purposes. The next step is to ensure that your organization is not ingesting excessive data due to specific applications. This document aims to help you stay within the average data ingestion limits based on user activity.

![image](https://github.com/user-attachments/assets/3fad6f01-7799-4cc6-89c5-7a8e7d9e4056)

## Access Microsoft Graph Activity Logs

### Usage

To monitor data usage, you can use the following KQL query to analyze the amount of data ingested over the last 30 days:

```kql
Usage
| where TimeGenerated >= ago(30d)
| where DataType == "MicrosoftGraphActivityLogs"
| summarize DataGB = sum(Quantity) / 1000
```


Once you determine that your data usage is within the average range, you may need to review the types of data sources being ingested. This query pulls a list of published static Entra Application IDs. For non-static application IDs, you will need to map the AppId results with Entra Applications.
```kql
let ApplicationInformation = externaldata (ApplicationName: string, AppId: string, Reference: string ) [h"https://raw.githubusercontent.com/Beercow/Azure-App-IDs/master/Azure_Application_IDs.csv"] with (ignoreFirstRecord=true, format="csv");
MicrosoftGraphActivityLogs
| lookup kind=leftouter ApplicationInformation on $left.AppId == $right.AppId
| project-reorder AppId, ApplicationName
| summarize count() by ApplicationName
```

### Important Note

Since Microsoft Graph API is central to Microsoft 365, many applications access this API. Tools like Abnormal Security, which query the Graph API in near real-time to review behavior, email delivery, and blocked messages, can significantly increase the size of MicrosoftGraphActivityLogs and potentially lead to higher costs.

If an application is found to be generating excessive logs and is not deemed valid, you can update the transformation to exclude the top querying AppId:
```kql
| where AppId != "Appid"
```
## Detections
* [Analyzing Malicious Microsoft Graph API Rate Limit Count](https://github.com/SlimKQL/Hunting-Queries-Detection-Rules/blob/main/Sentinel/Analyzing%20Malicious%20Microsoft%20Graph%20API%20Rate%20Limit%20Count.kql)
* [Azure Hound](https://github.com/Bert-JanP/Hunting-Queries-Detection-Rules/blob/main/Graph%20API/AzureHound.md)
* [Suspicious API Traffic- Entra ID](https://github.com/SlimKQL/Hunting-Queries-Detection-Rules/blob/main/Sentinel/NEW%20Microsoft%20Graph%20API%20Identity%20Protection%20KQL%20Detection.kql)


## Supporting resource
Special thanks to people/blogs below and others in the security community.

* [Bert-Jan Pals](https://kqlquery.com/posts/graphactivitylogs/)
* [Hunting with Microsoft Graph activity logs](https://techcommunity.microsoft.com/t5/microsoft-security-experts-blog/hunting-with-microsoft-graph-activity-logs/ba-p/4234632)
* [Invictus Incident Response](https://www.invictus-ir.com/nieuws/everything-you-need-to-know-about-the-microsoftgraphactivitylogs)
* [Cloudbrothers](https://www.cloudbrothers.info/detect-threats-microsoft-graph-logs-part-1/)
* [KQLSearch](https://www.kqlsearch.com/)
* [Steven Lim](https://www.linkedin.com/in/0x534c/)
