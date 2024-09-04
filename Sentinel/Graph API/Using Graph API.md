# Optimizing Microsoft Graph Activity Logs

Microsoft Graph Activity Logs provide an audit trail of all HTTP requests received and processed by the Microsoft Graph service for a tenant. These logs are crucial for monitoring and analyzing activities within your Microsoft Graph environment. Tenant administrators can enable log collection and configure destinations using diagnostic settings in Azure Monitor. Logs include API requests from various sources, including business applications, API clients, SDKs, and Microsoft applications like Outlook, Microsoft Teams, or the Microsoft Entra admin center.

For more information, see: [Microsoft Graph Activity Logs Overview](https://learn.microsoft.com/en-us/graph/microsoft-graph-activity-logs-overview)

## Storage and Export Options

Logs are stored in Log Analytics for analysis and can be archived in the Log Analytics Workspace (LAW) for long-term storage. They can also be exported to Azure Storage for extended retention or streamed via Azure Event Hubs to external SIEM tools for alerting, analysis, or archival.

For more details, see: [Manage Data Retention in a Log Analytics Workspace - Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/data-retention-configure?tabs=portal-3%2Cportal-1%2Cportal-2)

## Reviewing and Implementing Detection Methods

Ingesting Microsoft Graph Activity Logs helps in reviewing access via the Graph API. When integrated with Azure Sentinel, organizations can implement detection methods. Regularly reviewing these logs is important to ensure the quality, quantity, and configuration of detections. This guide will walk you through these considerations and suggest best practices.

## Quality

The `MicrosoftGraphActivityLogs` table includes additional columns that may not be useful for security teams. As of now, Microsoft includes 24 columns in this table.

For more details, see: [Access Microsoft Graph Activity Logs - Microsoft Graph | Microsoft Learn](https://learn.microsoft.com/en-us/graph/microsoft-graph-activity-logs-overview#what-data-is-available-in-the-microsoft-graph-activity-logs)

This guide focuses on security-related detections and hunting. If your organization needs to retain all log items, consider configuring a separate pipeline to store less critical data in lower-cost storage.

### Reducing Ingestion Costs and Noise

To optimize log ingestion, create a table-level transformation rule for the `MicrosoftGraphActivityLogs` table. This reduces unnecessary data written to the table that may not be needed for security operations. Be sure to understand each column you are excluding as requirements may vary by environment.

## Notable Activity Log Fields

The output log contains many fields. The following table highlights fields relevant to threat investigations:

| Field                  | Details                                                      |
|------------------------|--------------------------------------------------------------|
| **TimeGenerated [UTC]** | The date and time the request was received.                |
| **AppId**              | The identifier of the application.                           |
| **IPAddress**          | The IP address of the client making the request.             |
| **ServicePrincipalId** | The identifier of the service principal making the request. |
| **RequestId**          | The unique identifier for the request.                       |
| **RequestMethod**      | The HTTP method used for the request.                        |
| **ResponseStatusCode** | The HTTP response status code for the request.              |
| **RequestUri**         | The URI of the request.                                     |
| **ResponseSizeBytes**  | The size of the response in bytes.                          |
| **Roles**              | The roles in token claims.                                  |

### Steps to Create a Transformation Rule

1. Access your Log Analytics workspace in Azure and go to **Settings > Tables**.
2. Find `MicrosoftGraphActivityLogs`, click the ellipsis (`...`) next to the table name, and select the option to create a collection rule (DCR). If no DCR exists, create one; note that there is a limit of 10 transformations per DCR.
3. After creating the DCR, select **Next** to proceed to the Schema and Transformation page. Review a sample of the data to determine what is valuable and what might be excluded. Click the option to enter the transformation rule.
4. Copy and paste the following KQL query to exclude unwanted columns:

    ```kql
    Source
    | project-away TenantId, OperationId, ClientRequestId, ApiVersion, AadTenantId, SignInActivityId, Wids
    ```

5. Validate the query to ensure correctness, then select **Apply** and **Next**.
6. Apply the transformation rule by selecting the appropriate button and allow 5-15 minutes for the rule to take effect.

## Cleaning Up Log Data for Readability

Transform the `MicrosoftGraphActivityLogs` data for better readability using the following KQL queries:

```kql
// Clean up URI and API path
MicrosoftGraphActivityLogs
| extend ParsedUri = tostring(parse_url(RequestUri))
| extend Host = tostring(parse_json(ParsedUri).Host)
| extend GraphAPIPath = tolower(replace_string(ParsedUri, "//", "/"))
| extend GraphAPIResource = tostring(split(GraphAPIPath, "/")[2])
| project TimeGenerated, RequestMethod, IPAddress, Roles, AppId, ServicePrincipalId, Host, GraphAPIResource
```

```kql
// Join with IdentityInfo to align with user
MicrosoftGraphActivityLogs
| where isnotempty(UserId)
| join kind=leftouter IdentityInfo on $left.UserId == $right.AccountObjectId
| where isnotempty(AccountUPN)
| project-reorder TimeGenerated, AppId, IPAddress, AccountUPN, AccountCreationTime, AssignedRoles, ServicePrincipalId, RequestId, RequestMethod, ResponseStatusCode, RequestUri, ResponseSizeBytes, Roles
```

```kql
// Clean up location information
MicrosoftGraphActivityLogs
| extend GeoIPInfo = geo_info_from_ip_address(IPAddress)
| extend country = tostring(parse_json(GeoIPInfo).country)
| extend state = tostring(parse_json(GeoIPInfo).state)
| extend city = tostring(parse_json(GeoIPInfo).city)
```

## Quantity

The transformations above make the data more readable and exclude less relevant columns for security. Ensure your organization is not ingesting excessive data. This document helps manage data ingestion within average limits based on user activity.

## Monitoring Data Usage

To monitor data usage, use the following KQL query to analyze data ingested over the past 30 days:

```kql
Usage
| where TimeGenerated >= ago(30d)
| where DataType == "MicrosoftGraphActivityLogs"
| summarize DataGB = sum(Quantity) / 1000
```

Review the types of data sources being ingested to ensure they align with your needs. For a list of published static Entra Application IDs, use the query below. For non-static IDs, map the AppId results with Entra Applications.

```kql
let ApplicationInformation = externaldata (ApplicationName: string, AppId: string, Reference: string ) [h"https://raw.githubusercontent.com/Beercow/Azure-App-IDs/master/Azure_Application_IDs.csv"] with (ignoreFirstRecord=true, format="csv");
MicrosoftGraphActivityLogs
| lookup kind=leftouter ApplicationInformation on $left.AppId == $right.AppId
| project-reorder AppId, ApplicationName
| summarize count() by ApplicationName
```

### Important Note

Since Microsoft Graph API is central to Microsoft 365, many applications access this API. Tools like Abnormal Security, which query the Graph API in near real-time, can significantly increase the size of `MicrosoftGraphActivityLogs` and potentially lead to higher costs.

If an application is generating excessive logs and is not deemed valid, update the transformation rule to exclude the top querying AppId:

```kql
| where AppId != "Appid"
```

## Detections

* [Analyzing Malicious Microsoft Graph API Rate Limit Count](https://github.com/SlimKQL/Hunting-Queries-Detection-Rules/blob/main/Sentinel/Analyzing%20Malicious%20Microsoft%20Graph%20API%20Rate%20Limit%20Count.kql)
* [Azure Hound](https://github.com/Bert-JanP/Hunting-Queries-Detection-Rules/blob/main/Graph%20API/AzureHound.md)
* [Suspicious API Traffic - Entra ID](https://github.com/SlimKQL/Hunting-Queries-Detection-Rules/blob/main/Sentinel/NEW%20Microsoft%20Graph%20API%20Identity%20Protection%20KQL%20Detection.kql)
* [Email Collection](https://github.com/MSJosh/documentation/blob/main/Sentinel/Graph%20API/Email%20collection.md)
* [Exfiltration](https://github.com/MSJosh/documentation/blob/main/Sentinel/Graph%20API/Exfiltration.md)
* [Internal Phishing](https://github.com/MSJosh/documentation/blob/main/Sentinel/Graph%20API/Internal%20phishing.md)
* [Account Manipulation](https://github.com/MSJosh/documentation/blob/main/Sentinel/Graph%20API/Privilege%20escalation.md)
* [User Deletion](https://github.com/MSJosh/documentation/blob/main/Sentinel/Graph%20API/User%20Delete.md)

## Supporting Resources

Special thanks to the following contributors and blogs:

* [Bert-Jan Pals](https://kqlquery.com/posts/graphactivitylogs/)
* [Hunting with Microsoft Graph Activity Logs](https://techcommunity.microsoft.com/t5/microsoft-security-experts-blog/hunting-with-microsoft-graph-activity-logs/ba-p/4234632)
* [Invictus Incident Response](https://www.invictus-ir.com/nieuws/everything-you-need-to-

know-about-the-microsoftgraphactivitylogs)
* [Cloudbrothers](https://www.cloudbrothers.info/detect-threats-microsoft-graph-logs-part-1/)
* [KQLSearch](https://www.kqlsearch.com/)
* [Steven Lim](https://www.linkedin.com/in/0x534c/)
