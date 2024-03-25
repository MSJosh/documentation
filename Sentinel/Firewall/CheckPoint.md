Collecting CheckPoint FIrewall data with Sentinel

**Preface**
Configuring CheckPoint to send data to a syslog server is similar to other firewall solutions. Similar to Palo Alto, CheckPoint has a centralized collection tool. This solution is not as flexible with renaming or dropping custom columns/data sets unique to CheckPoint. What this means is we will need to ensure that we create a transform rule so that it doesn't land in AdditionalExtensions.  Pending on the deployment there is a total of 80+ columns that can be put into the AdditionalExtensions column in CommonSecurityLog table.  This can balloon your security budget and in a number of cases this data might not be valuable for a security alert or investigation. 



1. Configure Logger to send data as CEF - https://sc1.checkpoint.com/documents/R80.40/WebAdminGuides/EN/CP_R80.40_LoggingAndMonitoring_AdminGuide/Topics-LMG/Log-Exporter.htm
2. If you are making changes in any enviroment ensure that you have a good backup as mistakes can happen - https://support.checkpoint.com/results/sk/sk127653
3. Validate data is coming in correctly. 
```
CommonSecurityLog  \\Table where CEF should come in from
| where DeviceVendor contains "Check"  \\No need to get fancy we are just looking for data
|take 100 \\get a small sample to review
```

![image](https://github.com/MSJosh/documentation/assets/120500937/acd81113-98f6-4fed-9685-f1f132d065c4)






Source doc - https://support.checkpoint.com/results/sk/sk144192)https://support.checkpoint.com/results/sk/sk144192

