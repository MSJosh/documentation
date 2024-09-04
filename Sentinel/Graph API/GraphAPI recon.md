# Microsoft Incident Response often assists external customers where tools for reconnaissance are used to collect data of a tenant to determine ways to elevate privileges

## Query Information

#### MITRE ATT&CK Technique(s)

| Technique ID | Title    | Link    |
| ---  | --- | --- |
| T1087.004 | Account Discovery: Cloud Account | https://attack.mitre.org/techniques/T1087/004/ |


#### Description
Microsoft Incident Response often assists external customers where tools for reconnaissance are used to collect data of a tenant to determine ways to elevate privileges

#### Risk
The purpose of this query is to identify a surge in standard calls within a brief period that are characteristics of reconnaissance tools.

#### References

## Sentinel
```KQL
let calls = dynamic([
    "https://graph.microsoft.com/v1.0/users/<UUID>",
    "https://graph.microsoft.com/v1.0/search/query",
    "https://graph.microsoft.com/beta/policies/authorizationPolicy",
    "https://graph.microsoft.com/v1.0/users",
    "https://graph.microsoft.com/v1.0/groups",
    "https://graph.microsoft.com/v1.0/groups/<UUID>/members",
    "https://graph.microsoft.com/v1.0/servicePrincipals",
    "https://graph.microsoft.com/v1.0/servicePrincipals/<UUID>",
    "https://graph.microsoft.com/v1.0/applications",
    "https://graph.microsoft.com/v1.0/servicePrincipals(appId='<UUID>')/appRoleAssignedTo",
    "https://graph.microsoft.com/v1.0/organization",
    "https://graph.microsoft.com/beta/servicePrincipals",
    "https://graph.microsoft.com/beta/servicePrincipals/<UUID>/owners",
    "https://graph.microsoft.com/beta/groups/<UUID>/owners",
    "https://graph.microsoft.com/beta/groups/<UUID>/members",
    "https://graph.microsoft.com/v1.0/servicePrincipals/<UUID>/appRoleAssignedTo",
    "https://graph.microsoft.com/beta/applications/<UUID>/owners",
    "https://graph.microsoft.com/beta/devices/<UUID>/registeredOwners",
    "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments",
    "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions",
    "https://graph.microsoft.com/v1.0/devices",
    "https://graph.microsoft.com/beta/users/<UUID>/roleManagement/directorytransitiveRoleAssignments",
    "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions/<UUID>",
    "https://graph.microsoft.com/beta/roleManagement/directory/estimateAccess",
    "https://graph.microsoft.com/beta/users"
]);
MicrosoftGraphActivityLogs
| where ResponseStatusCode == '200'
| extend GeneralizedUri = replace_regex(RequestUri, @'\b[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}\b-[0-9a-fA-F]{12}', @'<UUID>')
| extend GeneralizedUri = replace_string(GeneralizedUri, @"//", @"/")
| extend GeneralizedUri = replace_string(GeneralizedUri, @"https:/", @"https://")
| extend GeneralizedUri = replace_regex(GeneralizedUri, @'\?.*$', @"")
| extend GeneralizedUri = replace_regex(GeneralizedUri, @'/$', @"")
| where GeneralizedUri in (calls)
| extend Id = iff(isempty(UserId), ServicePrincipalId, UserId)
| extend ObjectType = iff(isempty(UserId), "ServicePrincipal", "User")
| summarize 
    MinTime = min(TimeGenerated), 
    MaxTime = max(TimeGenerated), 
    UniqueCalls = dcount(GeneralizedUri), 
    CallsMade = count(), 
    UserAgents = make_set(UserAgent)
    by IPAddress, bin(TimeGenerated, 2m), Id, ObjectType
| where datetime_diff('second', MaxTime, MinTime) < 100 
    and ((UniqueCalls >= 3 and CallsMade >= 40) or CallsMade > 100)
```
