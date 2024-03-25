Collecting CheckPoint FIrewall data with Sentinel

**Preface**

Configuring CheckPoint to send data to a syslog server is similar to other firewall solutions. Similar to Palo Alto, CheckPoint has a centralized collection tool. This solution is not as flexible with renaming or dropping custom columns/data sets unique to CheckPoint. What this means is we will need to ensure that we create a transform rule so that it doesn't land in AdditionalExtensions.  Pending on the deployment there is a total of 80+ columns that can be put into the AdditionalExtensions column in CommonSecurityLog table.  This can balloon your security budget and in a number of cases this data might not be valuable for a security alert or investigation. 



1. Configure Logger to send data as CEF - [CheckPoint CEF Doc](https://sc1.checkpoint.com/documents/R80.40/WebAdminGuides/EN/CP_R80.40_LoggingAndMonitoring_AdminGuide/Topics-LMG/Log-Exporter.htm)
2. If you are making changes in any enviroment ensure that you have a good backup as mistakes can happen - [CheckPoint Backup](https://support.checkpoint.com/results/sk/sk127653)
3. Validate data is coming in correctly. 
```
CommonSecurityLog  \\Table where CEF should come in from
| where DeviceVendor contains "Check"  \\No need to get fancy we are just looking for data
|take 100 \\get a small sample to review
```

![image](https://github.com/MSJosh/documentation/assets/120500937/acd81113-98f6-4fed-9685-f1f132d065c4)


4. Now that you have data coming into Sentinel you can begin the process of mapping data that is valuable begin the process to get rid of data that you dont want or need.  This should be decided before sending to Sentinel to reduce cost but in some cases it is nice to have some sample data in Sentinel to test with, just be sure to stop Log Exporter once you have your sample data set.
5. 


**Remove AdditionalExtensions**

As mentioned alot of data from Check Point comes into the AdditionalExtensions will take about 30 - 40 percent of your ingest costs with Sentinel.
1. Using Transform KQL and creating new columns for data you care about will help reduce the amount of data.
2. To create a new column go to the log analytics workspace that you are sending Check Point data to and select Tables and search for "CommonSecurityLog"
3. Once the table shows up select the three ... and select "Edit schema"
4. Scroll to the bottom to create a Custom Column.
5. Taking the data from the table below you can map the map the proper Column information like Type, Description and Name. *Note that column names can't have space and Microsoft adds _CF to the end of the column name.  The last part is the most important part as in the transform when we extend the data we will put it the ColumnName_CF.
6. 



| Field Name           | Field Display Name           | Type     | Description                                                 | Transform KQL                                                                             |
|----------------------|------------------------------|----------|-------------------------------------------------------------|-------------------------------------------------------------------------------------------|
| bytes                | Total Bytes                  | int      | Number of bytes received during a connection               |                                                                                           |
| confidence_level     | Confidence Level             | int      | Confidence level determined by ThreatCloud   Possible values: 0 - N/A, 1 - Low, 2 - Medium-Low, 3 - Medium, 4 - Medium-High, 5 - High              |  |
| calc_desc            | Description                  | string   | Log description                                             |                                                                                           |
| dst                  | Destination                  | ipaddr   | Destination IP address                                      |                                                                                           |
| dst_country          | Destination Country          | string   | Destination country                                         |                                                                                           |
| dst_ip               | N/A                          | ipaddr   | Destination IP address                                      |                                                                                           |
| dst_user_name        | Destination User Name        | string   | Connected username for the destination IP                   |                                                                                           |
| email_id             | Email ID                     | string   | Email number in SMTP connection                             |                                                                                           |
| email_subject        | Email Subject                | string   | Original email subject                                      |                                                                                           |
| email_session_id     | Email Session ID             | string   | Connection UUID                                             |                                                                                           |
| event_count          | Event Count                  | int      | Number of events associated with the log                    |                                                                                           |
| failure_impact       | Failure Impact               | string   | The impact of update service failure                        |                                                                                           |
| file_id              | File Id                      | int      | Unique file identifier                                      |                                                                                           |
| file_type            | File Type                    | string   | Classified file type                                        |                                                                                           |
| file_name            | File Name                    | string   | Malicious file name / Matched file size                     |                                                                                           |
| file_size            | File Size                    | int      | Attachment file size / Matched file size                    |                                                                                           |
| file_md5             | File MD5                     | string   | File MD5 checksum                                           |                                                                                           |
| file_sha1            | File SHA1                    | string   | File SHA1 checksum                                          |                                                                                           |
| file_sha256          | File SHA-256                 | string   | File SHA256 checksum                                        |                                                                                           |
| from                 | Sender                       | string   | Source mail address                                         |                                                                                           |
| to                   | Recipient                    | string   | Source mail recipient                                       |                                                                                           |
| id                   | N/A                          | int      | Override application ID                                     |                                                                                           |
| information          | Information                  | string   | Status of policy installation for a specific Software Blade (used only for Anti-Bot and Anti-Virus)      |                                              |
| interface_name       | Interface                    | string   | The name of the Security Gateway interface                  |                                                                                           |
| interfacedir         | Direction                    | string   | Connection direction                                        |                                                                                           |
| layer_name           | Layer Name                   | string   | Layer name (match table, Threat Prevention match table)     |extend 
layer_name_CF = extract(\"layer_name=([^;]+);\", 1, AdditionalExtensions)                                                                                          |
| layer_uuid           | N/A                          | string   | Layer UUID (match table, Threat Prevention match table)     |                                                                                           |
| log_id               | Log ID                       | int      | Unique identity for logs includes: Type, Family,   Product/Blade, Category |                                                                            |
| loguid               | N/A                          | luuid    | UUID of unified logs                                        |                                                                                           |
| malware_action       | Malware Action               | string   | Description of detected malware activity                    |                                                                                           |
| malware_family       | Malware Family               | string   | Additional information on protection                        |                                                                                           |
| malware_rule_id      | Threat Prevention Rule ID    | string   | Threat Prevention rule ID (Threat Prevention match table)   |                                                                                           |
| malware_rule_name    | Threat Prevention Rule Name  | string   | Threat Prevention rule name (Threat Prevention match table) |                                                                                           |
| app_category         | Primary Category             | string   | Application category                                        |                                                                                           |
| matched_category     | Matched Category            | string   | Name of the matched category (match table)                  |                                                                                           |
| origin               | Orig                         | string   | Name of the first Security Gateway that reported this event |                                                                                           |
| origin_ip            | N/A                          | ipaddr   | IP address of the Security Gateway that generated this log  |                                                                                           |
| origin_sic_name      | N/A                          | string   | SIC name of the Security Gateway                            |                                                                                           |
| policy               | Threat Prevention Policy     | string   | Name of the Threat Policy that this Security Gateway fetched|                                                                                           |
| policy_mgmt          | Policy Management            | string   | Name of the Management Server that manages this Security GW|                                                                                           |
| policy_name          | Policy Name                  | string   | Name of the last policy that this Security Gateway fetched |                                                                                           |
| product              | Blade                        | string   | Product name                                                |                                                                                           |
| product_family       | Product Family               | int      | The product family the blade/product belongs to   Possible values: 0 - Network, 1 - Endpoint, 2 - Access, 3 - Threat, 4 - Mobile     |        |
| protection_id        | Protection ID                | string   | Protection malware ID                                       |                                                                                           |
| protection_name      | Protection Name              | string   | Specific signature name of the attack                       |                                                                                           |
| protection_type      | Protection Type              | string   | Type of protection used to detect the attack                |                                                                                           |
| proto                | IP Protocol                  | int      | Protocol                                                    |                                                                                           |
| protocol             | Protocol                     | string   | Protocol detected on the connection                         |                                                                                           |
| proxy_src_ip         | Proxied Source IP            | ipaddr   | Sender source IP (even when using proxy)                    |                                                                                           |
| reason               | Reason                       | string   | Information on the error occurred                           |                                                                                           |
| received_bytes       | Received Bytes               | int      | Number of bytes received during connection                  |                                                                                           |
| resource             | Resource                     | string   | Resource from the HTTP request                              |                                                                                           |
| rule                 | Rule                         | int      | Matched rule number (match table)                           |                                                                                           |
| rule_action          | Action                       | string   | Action of the matched rule in the Access Control policy     |                                                                                           |
| rule_name            | Access Rule Name             | string   | Name of the Access Control rule (match table)               |                                                                                           |
| rule_uid             | Policy Rule UID              | string   | Rule ID in the Access Control policy to which the connect...|                                                                                           |
| scan_direction       | File-Direction               | string   | Scan direction  Possible options: From external / dmz / internal to external / dmz / internal, To/from this Security Gateway |                          |
| sent_bytes           | Sent Bytes                   | int      | Number of bytes sent during the connection                 | extend sent_bytes_CF = toint(extract("sent_bytes=([^;]+);", 1, AdditionalExtensions))     |
| session_id           | Session Identification       | luuid    | Log UID                                                     |                                                                                           |




Source doc - https://support.checkpoint.com/results/sk/sk144192)https://support.checkpoint.com/results/sk/sk144192

