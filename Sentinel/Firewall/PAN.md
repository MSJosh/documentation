Collecting Palo Alto Data with Sentinel

1. Configure Panorama based on CEF Format. https://docs.paloaltonetworks.com/resources/cef  Microsoft recommends CEF as it provides an easy to read and parse format that can be used for a wide range of detection rules both in CommonSecurityLog and ASIM based detections.
2. When configuring the logging within Panorama you must decide to not send data to your collector or utilize the default configuration provided by Palo Alto where it sends a wide range of information especially when it comes to Traffic data. Before sending data the organization should decide the importance of the data and if they are going to be using the data to detect threats or use more for incident response. 




**Drop dropped and block traffic

        "transformKql": "source | where DeviceAction !contains \"Deny\" | where DeviceAction !contains \"Reset-both\" | project-away DeviceCustomString3, ExtID, DeviceCustomString3Label, DeviceCustomString6,DeviceCustomString6Label, AdditionalExtensions",
        "outputStream": "Microsoft-CommonSecurityLog"



**Traffic CEF Config - Recommended**
```
CEF:0|Palo Alto Networks|PAN-OS|$sender_sw_version|$subtype|$type|1|rt=$cef-formatted-receive_time deviceExternalId=$serial src=$src dst=$dst sourceTranslatedAddress=$natsrc destinationTranslatedAddress=$natdst cs1=$rule suser=$srcuser duser=$dstuser app=$app cs4=$from cs5Label=Destination Zone cs5=$to deviceInboundInterface=$inbound_if deviceOutboundInterface=$outbound_if cn1Label=SessionID cn1=$sessionid cnt=$repeatcnt spt=$sport dpt=$dport sourceTranslatedPort=$natsport destinationTranslatedPort=$natdport flexString1Label=Flags flexString1=$flags proto=$proto act=$action flexNumber1Label=Total bytes flexNumber1=$bytes in=$bytes_sent out=$bytes_received cn2Label=Packets cn2=$packets start=$cef-formatted-time_generated cn3Label=Elapsed time in seconds cn3=$elapsed cs2Label=URL Category cs2=$category externalId=$seqno reason=$session_end_reason dvchost=$device_name cat=$action_source PanOSSrcUUID=$src_uuid PanOSDstUUID=$dst_uuid PanOSTunnelID=$tunnelid PanOSMonitorTag=$monitortag PanOSParentSessionID=$parent_session_id PanOSParentStartTime=$parent_start_time PanOSTunnelType=$tunnel PanOSSCTPAssocID=$assoc_id PanOSSCTPChunks=$chunks PanOSSCTPChunkSent=$chunks_sent PanOSSCTPChunksRcv=$chunks_received PanOSRuleUUID=$rule_uuid PanOSHTTP2Con=$http2_connection PanDynamicUsrgrp=$dynusergroup_name

```

* What is collected with above config.
  
| Item                               | Description                               |
|------------------------------------|-------------------------------------------|
| $sender_sw_version                 | Firewall Software Version                 |
| $subtype                           | Subtype                                   |
| $type                              | Threat/Content Type  (Traffic)            |
| 1                                  | Numeric value (not labeled)               |
| rt=$cef-formatted-receive_time     | Receive Time formatted in CEF             |
| deviceExternalId=$serial           | Device External ID represented by $serial |
| src=$src                           | Source IP Address                         |
| dst=$dst                           | Destination IP Address                    |
| sourceTranslatedAddress=$natsrc    | Source Translated Address after NAT       |
| destinationTranslatedAddress=$natdst| Destination Translated Address after NAT  |
| cs1=$rule                          | Custom String 1 - Rule                    |
| suser=$srcuser                     | Source User                               |
| duser=$dstuser                     | Destination User                          |
| app=$app                           | Application                               |
| cs4=$from                          | Custom String 4 - Source Zone             |
| cs5Label=Destination Zone          | Custom String 5 Label - Destination Zone  |
| cs5=$to                            | Custom String 5 - Destination Zone        |
| deviceInboundInterface=$inbound_if | Device Inbound Interface                  |
| deviceOutboundInterface=$outbound_if| Device Outbound Interface                |
| cn1Label=SessionID                 | Custom Number 1 Label - Session ID        |
| cn1=$sessionid                     | Custom Number 1 - Session ID              |
| cnt=$repeatcnt                     | Count                                     |
| spt=$sport                         | Source Port                               |
| dpt=$dport                         | Destination Port                          |
| sourceTranslatedPort=$natsport     | Source Translated Port after NAT          |
| destinationTranslatedPort=$natdport| Destination Translated Port after NAT     |
| flexString1Label=Flags             | Flexible String 1 Label - Flags           |
| flexString1=$flags                 | Flexible String 1 - Flags                 |
| proto=$proto                       | Protocol                                  |
| act=$action                        | Action                                    |
| in=$bytes_sent                     | Bytes Sent                                |
| out=$bytes_received                | Bytes Received                            |
| cn2Label=Packets                   | Custom Number 2 Label - Packets           |
| cn2=$packets                       | Custom Number 2 - Packets                 |
| start=$cef-formatted-time_generated| Start Time formatted in CEF               |
| cn3Label=Elapsed time in seconds   | Custom Number 3 Label - Elapsed Time in Seconds |
| cn3=$elapsed                       | Custom Number 3 - Elapsed Time in Seconds |
| cs2Label=URL Category              | Custom String 2 Label - URL Category      |
| cs2=$category                      | Custom String 2 - URL Category            |
| d=$seqno                 | External ID represented by $seqno         |
| reason=$session_end_reason         | Reason for Session End                    |
| dvchost=$device_name               | Device Hostname                           |
| cat=$action_source                 | Category based on Action Source           |
| PanOSSrcUUID=$src_uuid             | PAN-OS Source UUID                        |
| PanOSDstUUID=$dst_uuid             | PAN-OS Destination UUID                   |
| PanOSTunnelID=$tunnelid            | PAN-OS Tunnel ID                          |
| PanOSMonitorTag=$monitortag        | PAN-OS Monitor Tag                        |
| PanOSParentSessionID=$parent_session_id| PAN-OS Parent Session ID               |
| PanOSParentStartTime=$parent_start_time| PAN-OS Parent Session Start Time       |
| PanOSTunnelType=$tunnel            | PAN-OS Tunnel Type                        |
| PanOSSCTPAssocID=$assoc_id         | PAN-OS SCTP Association ID                |
| PanOSSCTPChunks=$chunks            | PAN-OS SCTP Chunks                        |
| PanOSSCTPChunkSent=$chunks_sent    | PAN-OS SCTP Chunks Sent                   |
| PanOSSCTPChunksRcv=$chunks_received| PAN-OS SCTP Chunks Received               |
| PanOSRuleUUID=$rule_uuid           | PAN-OS Rule UUID                          |
| PanOSHTTP2Con=$http2_connection    | PAN-OS HTTP/2 Connection                  |
| PanDynamicUsrgrp=$dynusergroup_name| PAN Dynamic User Group Name               |

Source doc - https://docs.paloaltonetworks.com/pan-os/10-1/pan-os-admin/monitoring/use-syslog-for-monitoring/syslog-field-descriptions/traffic-log-fields
