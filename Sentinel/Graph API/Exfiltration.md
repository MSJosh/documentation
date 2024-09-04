# Exfiltration

## Query Information

#### MITRE ATT&CK Technique(s)

| Technique ID | Title    | Link    |
| ---  | --- | --- |
| T1567 | Exfiltration Over Web Service | [https://attack.mitre.org/techniques/T1114/](https://attack.mitre.org/techniques/T1567/) |


#### Description
Actors can use Microsoft Graph to download sensitive files or data from any user’s OneDrive accounts or SharePoint. By illegitimately using file capabilities in Microsoft Graph, a bad actor can access and download confidential documents even without direct access to those files.


#### Risk
 In one of our customer engagements, Microsoft Incident Response observed compromised identities accessing files on SharePoint Online and OneDrive through Microsoft Graph API.

#### References
Query: The following query is a good starting point for investigating Microsoft Graph API calls related to download activities. Analyze the UserAgent and AppID to determine whether these activities are expected in your environment. Note that the Item ID cannot be resolved to identify the downloaded item, but CloudApp events can be correlated to provide further context for this download activity.


## Sentinel
```KQL
MicrosoftGraphActivityLogs
| where RequestMethod == "GET" 
| where ResponseStatusCode in ("302", "200")       // https://learn.microsoft.com/en-us/graph/api/driveitem-get-content?view=graph-rest-1.0&tabs=http#response, normal response code returns a "302 Found" response redirecting to a preauthenticated download URL. 
| where RequestUri matches regex @"https://graph\.microsoft\.com/.*/items/.*/content" and RequestUri matches regex @"/drives?/.*" and RequestUri !has "/thumbnails/"
| project  TimeGenerated, ResponseStatusCode, RequestMethod, IPAddress, UserAgent, RequestUri, AppId 
```
