
## Optimize Microsoft Graph Activity Logs

Microsoft Graph Activity Logs provide an audit trail of all HTTP requests that the Microsoft Graph service has received and processed for a tenant. These logs are essential for monitoring and analyzing activities within your Microsoft Graph environment. Tenant administrators can enable the collection of these logs and configure downstream destinations using diagnostic settings in Azure Monitor. The logs include API requests made from a variety of sources, including line-of-business applications, API clients, SDKs, and Microsoft applications like Outlook, Microsoft Teams, or the Microsoft Entra admin center.

For more information, see: [Microsoft Graph Activity Logs Overview](https://learn.microsoft.com/en-us/graph/microsoft-graph-activity-logs-overview)

### Storage and Export Options

The logs are stored in Log Analytics for analysis. Additionally, they can be stored in the archive tier for long-term storage in Log Analytics Workspace (LAW). You can also export them to Azure Storage for long-term storage or stream them with Azure Event Hubs to external SIEM tools for alerting, analysis, or archival.

For more details, see: [Manage Data Retention in a Log Analytics Workspace - Azure Monitor](https://learn.microsoft.com/en-us/graph/microsoft-graph-activity-logs-overview)

### Reviewing and Implementing Detection Methods

Ingesting Microsoft Graph Activity Logs is an effective way to review access via the Graph API. When ingested with Azure Sentinel, organizations can implement detection methods. As with other logs, it's beneficial to regularly review these logs to ensure quality, quantity, and proper configuration of detections. This document will guide you through these considerations and suggest best practices.



## Quality

Like other tables within Azure and Entra, Microsoft provides additional columns in the `MicrosoftGraphActivityLogs` table that may not be beneficial for security teams. As of this writing, Microsoft is creating 24 columns that are written to this table.

For more details, see: [Access Microsoft Graph activity logs - Microsoft Graph | Microsoft Learn](https://learn.microsoft.com/en-us/graph/microsoft-graph-activity-logs-overview)

This article focuses on security-related detections and hunting. If an organization needs to retain all items of the log, it's recommended to have a separate pipeline configured to go to lower-cost storage.

### Reduce Ingestion Cost and Noise

To optimize your log ingestion, you can create a table-level transformation rule for the `MicrosoftGraphActivityLogs` table. This will help reduce the amount of unnecessary data written to the table, which might not be needed for security operations. Note that these are general recommendations and each environment may have different requirements. Be sure to understand each column you are excluding.

#### Steps to Create a Transformation Rule

1. Access your Log Analytics workspace in Azure and go to **Settings > Tables**.
2. Find `MicrosoftGraphActivityLogs` in the list of tables, click the ellipsis (`...`) to the right of the table name, and select **Edit**.
3. Create a collection rule (DCR) if one is not already created. This DCR is tied to the Log Analytics workspace and can be used for other table-level transformations. Note that there is currently a limit of 10 transformations per DCR.
4. Once the DCR has been created, select **Next** to proceed to the Schema and Transformation page. This will show a sample set of data, allowing you to decide what is valuable and what might be dropped. Select **Add Transformation**, which will open a new window to enter the transformation rule.
5. Copy and paste the following KQL query to stop ingesting data to these columns:

    ```kql
    Source
    | project-away TenantId, OperationId, ClientRequestId, ApiVersion, AadTenantId, SignInActivityId, Wids
    ```

6. Run the query to validate that the data looks correct and no errors occurred. Select **Apply** and then **Next**.
7. Select the **Save** button to apply the transformation rule to the DCR. Allow 5-15 minutes for this rule to take effect in your environment.
