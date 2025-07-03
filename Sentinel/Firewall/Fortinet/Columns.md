# Fortinet Firewall Log Columns

| Column Name | Data Type | Description | Exists |
|-------------|-----------|-------------|--------|
| EventTime | string | Epoch time the log was triggered by FortiGate. If you convert the epoch time to human readable time, it might not match the Date and Time in the header owing to a small delay between the time the log was triggered and recorded. The Log Time field is the same for the same log among all log devices, but the Date and Time might differ. | |
| TZ | string | Timezone offset (+0000, etc.) | |
| LogID | string | Log identifier (0000000013) | X |
| Subtype | string | Event subtype (forward, etc.) | X |
| Level | string | Log severity level (notice, etc.) | X |
| VD | string | Virtual domain (root) | |
| SrcIntfRole | string | Source interface role (undefined) | |
| DstIntfRole | string | Destination interface role (undefined) | |
| SrcCountry | string | Source country (Reserved) | |
| DstCountry | string | Destination country (Reserved) | |
| Action | string | Action taken (client-rst, etc.) | |
| PolicyID | int | Policy ID (e.g., 16) | |
| PolicyType | string | Policy type (policy) | |
| PolUUID | string | Policy UUID (GUID format) | |
| PolicyName | string | Friendly policy name (ExpressRoute2Indexers) | X |
| TranDisp | string | Transaction disposition (noop) | |
| Duration | int | Duration of the session in seconds (e.g., 94) | |
| SentPkt | int | Number of packets sent (104) | |
| RcvdPkt | int | Number of packets received (87) | |
| AppCat | string | Application category (unscanned) | |

