# After compromising a user identity or a service principal, an actor can send phishing emails to users within the organization. This can potentially lead to the compromise of further identities and facilitate lateral movement.

## Query Information

#### MITRE ATT&CK Technique(s)

| Technique ID | Title    | Link    |
| ---  | --- | --- |
| T1534 | Internal Spearphishing | https://attack.mitre.org/techniques/T1534/ |


#### Description
This query detects the use of sendMail in the URI and lists every email sent using Microsoft Graph API. It distinguishes between delegated and application-based permissions and provides user information by combining it with the IdentityInfo table.

#### Risk
Microsoft Threat Intelligence outlined a similar attack in their blog post [on how threat actors misuse OAuth applications to automate financially driven attacks](https://www.microsoft.com/en-us/security/blog/2023/12/12/threat-actors-misuse-oauth-applications-to-automate-financially-driven-attacks/).

#### References

## Sentinel
```KQL
MicrosoftGraphActivityLogs 
| where ResponseStatusCode == "202"
| where RequestUri endswith "/sendMail"
| extend EmailSentFrom = tostring(parse_url(RequestUri).Path).substring(1).split("/")[-2]
| extend Id = iff(isempty(UserId), ServicePrincipalId, UserId)
| extend Type = iff(isempty(UserId), "ServicePrincipal", "User")
| extend JoinKey = case(Type == "ServicePrincipal", EmailSentFrom, Type == "User", UserId, "")
| join kind=leftouter (IdentityInfo | extend JoinKey = AccountObjectId | summarize arg_max(TimeGenerated, *) by JoinKey ) on  JoinKey
| extend AccountUPN = coalesce(AccountUPN, EmailSentFrom)
| project-reorder TimeGenerated, Type, AppId, MailAddress, RequestUri, ResponseStatusCode, UserAgent, AccountUPN
```
```KQL
//Query: Reviewing the app ID and service principal can help verify that the applications are allowed to send emails. The following query summarizes the emails sent by service principals in the past 30 days.
MicrosoftGraphActivityLogs 
| where ResponseStatusCode == "202"
| where RequestUri endswith "/sendMail" and RequestUri has "/users/"  //Looking for the user's API in terms of ServicePrincipal access
| extend EmailSentFrom =  tostring(split(RequestUri, "/")[-2])
| extend Id = iff(isempty(UserId), ServicePrincipalId, UserId)
| extend Type = iff(isempty(UserId), "ServicePrincipal", "User")
| where Type == "ServicePrincipal"
| join kind=leftouter (IdentityInfo | summarize arg_max(TimeGenerated, *) by AccountObjectId ) on $left.EmailSentFrom == $right.AccountObjectId
| extend AccountUPN = coalesce(AccountUPN, EmailSentFrom)
| summarize EmailsSentCount=count(), SentFromUsers=make_set(AccountUPN), UserAgents=make_set(UserAgent) by AppId
```
