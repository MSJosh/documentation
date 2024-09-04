# Email collection

## Query Information

#### MITRE ATT&CK Technique(s)

| Technique ID | Title    | Link    |
| ---  | --- | --- |
| T1114 | Email Collection | https://attack.mitre.org/techniques/T1114/ |


#### Description
The following query can be used to hunt for Microsoft Graph API calls which are used to read mail from a users’ mailbox. The application ID (AppId) represents the application that Microsoft Graph uses to access the emails.

#### Risk
In our scenario, the threat actor abused an application with excessive permissions, which allowed them to gain unauthorized access to the mailboxes of users.

#### References

## Sentinel
```KQL
MicrosoftGraphActivityLogs
| where RequestMethod == "GET"
| where RequestUri has_all ("https://graph.microsoft.com", "/users/", "/messages")
| where ResponseStatusCode in ("200")
| project AppId, UserAgent, RequestUri
```
```KQL
//Query: The query below reveals statistics about the applications or users used for reading emails, along with the number of unique mailboxes accessed and their respective timeframes. Note that this query also uses the IdentityInfo table.
MicrosoftGraphActivityLogs
| where RequestMethod == "GET"
| where RequestUri has_all ("https://graph.microsoft.com", "/users/", "/messages")
| where ResponseStatusCode == "200"
| extend Id = iff(isempty(UserId), ServicePrincipalId, UserId)
| extend ObjectType = iff(isempty(UserId), "ServicePrincipal", "User")
| extend MailboxTargetUPN = tostring(extract_all( @'https://graph.microsoft.com/v.../users/([^/]*)/', RequestUri)[0]) //Parses the AccountUPN
| extend UserGuid= tostring(extract_all( @'*.(\b[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}\b-[0-9a-fA-F]{12}).*', RequestUri)[0]) //Parses the object-ID of an targeted identity
| join kind=leftouter (IdentityInfo |  where TimeGenerated > ago(30d) | summarize arg_max(TimeGenerated, *) by AccountObjectId | project TargetUPN=AccountUPN, AccountObjectId) on $left.UserGuid==$right.AccountObjectId
| extend TargetUPN = coalesce(TargetUPN, MailboxTargetUPN)
| summarize MinTime=min(TimeGenerated), MaxTime=max(TimeGenerated), MailBoxAccessCount=dcount(TargetUPN), Targets=make_set(TargetUPN) by AppId, ObjectType, Id 
```
