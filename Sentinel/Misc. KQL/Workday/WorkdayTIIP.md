# Uses ThreatIntelligenceIndicator table and Joins with ASimAuditEventLogs which is where Workday data lands.

## Query Information 

#### MITRE ATT&CK Technique(s)

| Technique ID | Title    | Link    |
| ---  | --- | --- |



#### Description
Looks at signin events of Workday and maps IP address to bad actors IPs based on the Threat Intel table.

#### Risk
The purpose of this query is to identify a signin by a bad actor using TI data.

#### References

## Sentinel
```KQL
let dtLookBack = 1h; // Define the lookback period for audit events
let iocLookBack = 14d; // Define the lookback period for threat intelligence indicators
ThreatIntelligenceIndicator
| where isnotempty(NetworkIP) or isnotempty(EmailSourceIpAddress) or isnotempty(NetworkDestinationIP) or isnotempty(NetworkSourceIP) // Filter for indicators with relevant IP fields
| where TimeGenerated >= ago(iocLookBack) // Filter indicators within the lookback period
| extend TI_ipEntity = coalesce(NetworkIP, NetworkDestinationIP, NetworkSourceIP, EmailSourceIpAddress) // Combine IP fields into a single entity
| summarize LatestIndicatorTime = arg_max(TimeGenerated, *) by IndicatorId, TI_ipEntity // Get the latest indicator time for each entity
| where Active == true and ExpirationDateTime > now() // Filter for active indicators that haven't expired
| join kind=inner (
    ASimAuditEventLogs
    | where EventVendor == "Workday" // Filter for Workday events
    | where TimeGenerated >= ago(dtLookBack) // Filter events within the lookback period
    | where isnotempty(DvcIpAddr) // Filter for events with a device IP address
    | extend WD_TimeGenerated = EventStartTime // Rename the event start time column
    | project WD_TimeGenerated, ActorUsername, DvcIpAddr, Operation, Object // Select relevant columns
) on $left.TI_ipEntity == $right.DvcIpAddr // Join on the IP entity
| project LatestIndicatorTime, Description, ActivityGroupNames, IndicatorId, ThreatType, Url, ExpirationDateTime, ConfidenceScore, WD_TimeGenerated, ActorUsername, DvcIpAddr, Operation, Object // Select relevant columns after the join
| extend timestamp = WD_TimeGenerated, Name = tostring(split(ActorUsername, '@', 0)[0]), UPNSuffix = tostring(split(ActorUsername, '@', 1)[0]) // Add additional fields for timestamp, name, and UPN suffix
```
entityMappings:
  - entityType: Account
    fieldMappings:
      - identifier: FullName
        columnName: ActorUsername
      - identifier: Name
        columnName: Name
      - identifier: UPNSuffix
        columnName: UPNSuffix
  - entityType: IP
    fieldMappings:
      - identifier: Address
        columnName: DvcIpAddr
