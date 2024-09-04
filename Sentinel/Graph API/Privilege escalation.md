# Account Manipulation: Additional Cloud Roles

## Query Information

#### MITRE ATT&CK Technique(s)

| Technique ID | Title    | Link    |
| ---  | --- | --- |
| T1098.003 | Account Manipulation: Additional Cloud Roles | https://attack.mitre.org/techniques/T1098/003/ |


#### Description
 In an example of a customer engagement Microsoft IR was engaged on, a threat actor compromised a Service Principal of an Entra application that had the "RoleManagement.ReadWrite.Directory" role. Using these permissions, they granted a Global Administrator role to another compromised user identity.
The following query detects role changes in Microsoft Graph activity logs, which also show when a role is added. Investigators should examine the result using audit logs or other available logs to provide further context and to distinguish between legitimate and unauthorized activity.
#### Risk
Account manipulation: additional cloud roles

#### References

## Sentinel
```KQL
MicrosoftGraphActivityLogs
| where RequestUri has_all ("https://graph.microsoft.com/", "/directoryRoles/", "members/$ref")
| where RequestMethod == "POST"
| where ResponseStatusCode in ("204")
| extend Role = tostring(split(RequestUri, "/")[-3]) //Role can be looked up in Auditlogs
| project  TimeGenerated, IPAddress, RequestUri, ResponseStatusCode, Role, UserAgent, AppId
```
