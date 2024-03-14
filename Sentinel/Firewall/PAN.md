Collecting Palo Alto Data with Sentinel

1. Configure Panorama based on CEF Format. https://docs.paloaltonetworks.com/resources/cef  Microsoft recommends CEF as it provides an easy to read and parse format that can be used for a wide range of detection rules both in CommonSecurityLog and ASIM based detections.
2. When configuring the logging within Panorama you must decide to not send data to your collector or utilize the default configuration provided by Palo Alto where it sends a wide range of information especially when it comes to Traffic data. Before sending data the organization should decide the importance of the data and if they are going to be using the data to detect threats or use more for incident response. 




//Drop dropped and block traffic
        "transformKql": "source | where DeviceAction !contains \"Deny\" | where DeviceAction !contains \"Reset-both\" | project-away DeviceCustomString3, ExtID, DeviceCustomString3Label, DeviceCustomString6,DeviceCustomString6Label, AdditionalExtensions",
        "outputStream": "Microsoft-CommonSecurityLog"



**Traffic PAN Config**

CEF:0|Palo Alto Networks|PAN-OS|$sender_sw_version|$subtype|$type|1|rt=$cef-formatted-receive_time
deviceExternalId=$serial src=$src dst=$dst sourceTranslatedAddress=$natsrc
destinationTranslatedAddress=$natdst cs1Label=Rule cs1=$rule suser=$srcuser duser=$dstuser app=$app
cs3Label=Virtual System cs3=$vsys cs4Label=Source Zone cs4=$from cs5Label=Destination Zone cs5=$to
deviceInboundInterface=$inbound_if deviceOutboundInterface=$outbound_if cs6Label=LogProfile cs6=$logset
cn1Label=SessionID cn1=$sessionid cnt=$repeatcnt spt=$sport dpt=$dport sourceTranslatedPort=$natsport
destinationTranslatedPort=$natdport flexString1Label=Flags flexString1=$flags proto=$proto act=$action
flexNumber1Label=Total bytes flexNumber1=$bytes in=$bytes_sent out=$bytes_received cn2Label=Packets
cn2=$packets PanOSPacketsReceived=$pkts_received PanOSPacketsSent=$pkts_sent
start=$cef-formatted-time_generated cn3Label=Elapsed time in seconds cn3=$elapsed cs2Label=URL Category
cs2=$category externalId=$seqno reason=$session_end_reason PanOSDGl1=$dg_hier_level_1
PanOSDGl2=$dg_hier_level_2 PanOSDGl3=$dg_hier_level_3 PanOSDGl4=$dg_hier_level_4
dvchost=$device_name cat=$action_source PanOSActionFlags=$actionflags
PanOSSrcUUID=$src_uuid PanOSDstUUID=$dst_uuid PanOSTunnelID=$tunnelid PanOSMonitorTag=$monitortag
PanOSParentSessionID=$parent_session_id PanOSParentStartTime=$parent_start_time PanOSTunnelType=$tunnel
PanOSSCTPAssocID=$assoc_id PanOSSCTPChunks=$chunks PanOSSCTPChunkSent=$chunks_sent
PanOSSCTPChunksRcv=$chunks_received PanOSRuleUUID=$rule_uuid PanOSHTTP2Con=$http2_connection
PanLinkChange=$link_change_count PanDynamicUsrgrp=$dynusergroup_name
