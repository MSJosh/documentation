Collecting Palo Alto Data with Sentinel

1. Configure Panorama based on CEF Format. https://docs.paloaltonetworks.com/resources/cef  Microsoft recommends CEF as it provides an easy to read and parse format that can be used for a wide range of detection rules both in CommonSecurityLog and ASIM based detections.
2. When configuring the logging within Panorama you must decide to not send data to your collector or utilize the default configuration provided by Palo Alto where it sends a wide range of information especially when it comes to Traffic data. Before sending data the organization should decide the importance of the data and if they are going to be using the data to detect threats or use more for incident response. 





| Type  |Format | 
| --------------- | ---------- | 
|Traffic| "CEF:0|Palo Alto Networks|PAN-OS|$sender_sw_version|$subtype|$type|1|rt=$cef-formatted-receive_time
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
PanOSVsysName=$vsys_name dvchost=$device_name cat=$action_source PanOSActionFlags=$actionflags
PanOSSrcUUID=$src_uuid PanOSDstUUID=$dst_uuid PanOSTunnelID=$tunnelid PanOSMonitorTag=$monitortag
PanOSParentSessionID=$parent_session_id PanOSParentStartTime=$parent_start_time PanOSTunnelType=$tunnel
PanOSSCTPAssocID=$assoc_id PanOSSCTPChunks=$chunks PanOSSCTPChunkSent=$chunks_sent
PanOSSCTPChunksRcv=$chunks_received PanOSRuleUUID=$rule_uuid PanOSHTTP2Con=$http2_connection
PanLinkChange=$link_change_count PanPolicyID=$policy_id PanLinkDetail=$link_switches
PanSDWANCluster=$sdwan_cluster PanSDWANDevice=$sdwan_device_type
PanSDWANClustype=$sdwan_cluster_type PanSDWANSite=$sdwan_site PanDynamicUsrgrp=$dynusergroup_name
PanXFFIP=$xff_ip PanSrcDeviceCat=$src_category PanSrcDeviceProf=$src_profile PanSrcDeviceModel=$src_model
PanSrcDeviceVendor=$src_vendor PanSrcDeviceOS=$src_osfamily PanSrcDeviceOSv=$src_osversion
PanSrcHostname=$src_host PanSrcMac=$src_mac PanDstDeviceCat=$dst_category PanDstDeviceProf=$dst_profile
PanDstDeviceModel=$dst_model PanDstDeviceVendor=$dst_vendor PanDstDeviceOS=$dst_osfamily
PanDstDeviceOSv=$dst_osversion PanDstHostname=$dst_host PanDstMac=$dst_mac
PanContainerName=$container_id PanPODNamespace=$pod_namespace PanPODName=$pod_name
PanSrcEDL=$src_edl PanDstEDL=$dst_edl PanGPHostID=$hostid PanEPSerial=$serialnumber PanSrcDAG=$src_dag
PanDstDAG=$dst_dag PanHASessionOwner=$session_owner PanTimeHighRes=$high_res_timestamp
PanASServiceType=$nssai_sst PanASServiceDiff=$nssai_sd" |






|aka.ms | Used to resolve the download script during installation | At installation time, only | Public |
| download.microsoft.com  | Used to download the Windows installation package  | At installation time, only  | Public  |
| packages.microsoft.com | Used to download the Linux installation package | At installation time, only | Public  |
| login.windows.net  | Microsoft Entra ID  | Always  | Public |
| login.microsoftonline.com  | Microsoft Entra ID | Always  | Public  |
| pas.windows.net  | Microsoft Entra ID  | Always  | Public  |
