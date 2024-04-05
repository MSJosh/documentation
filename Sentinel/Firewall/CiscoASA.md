Cisco ASA does not support CEF.  This can cause confusion as it is not like other modern firewalls like PAN, Fortinet that have easy configurations to CEF. The Sentinel  Cisco ASA DCR looks at syslog data that is coming across as  %ASA%  and from there AMA does some magic behind the scenes and make it CEF.  If you look at the DCR created for the AMA Cisco ASA solution, we are actually sending the stream to 


**Here is a sample DCR** 


   "syslog": [
        {
          "streams": [
            "Microsoft-CiscoAsa"

This takes the syslog data and makes it CEF for us.  The call out here is if they are collecting syslog data to that same facility we are going to want to do a transform similar to CEF documentation as it will lead to double logs.

[Ingest Syslog and CEF messages to Microsoft Sentinel with the Azure Monitor Agent | Microsoft Learn](https://learn.microsoft.com/en-us/azure/sentinel/connect-cef-syslog-ama?tabs=single%2Csyslog%2Cportal#avoid-data-ingestion-duplication)
'''
        "transformKql": "source | where ProcessName !contains \"%ASA%\"",
        "outputStream": "Microsoft-Syslog"
'''



For setup on Cisco ASA the user can follow these steps. 


Configuring the Cisco Device to Send Events
To configure the Cisco device to send syslog events to a syslog server:
Telnet to your Cisco machine.
Within the console, enter enable mode by specifying the following command: hostname(config)# enable or hostname(config)# en.
Enter configuration mode by specifying the following command: hostname(config)# configure terminal or hostname(config)# conf t.
Enter the following lines:
hostname(config)# logging on
hostname(config)# logging timestamp
hostname(config)# no logging standby
hostname(config)# no logging console
hostname(config)# no logging monitor
hostname(config)# no logging buffered debugging
hostname(config)# logging trap debug
hostname(config)# no logging history
hostname(config)# logging facility <syslog server logging directory>
hostname(config)# logging queue 512
hostname(config)# logging host inside <syslog server ip address>

The logging facility can be one of the following:

| Cisco Config | Facility   |
| ------ | ------- |
| 16     | local0  |
| 17     | local1  |
| 18     | local2  |
| 19     | local3  |
| 20     | local4  |
| 21     | local5  |
| 22     | local6  |
| 23     | local7  |

For example, to log to syslog facility local6, create the following entry on the device:
logging facility 22


For the logging host, replace syslog server ip address with the syslog server's IP
address. You can use multiple logging host commands to specify additional servers.
For the logging Log severity level, the debug level is specified, which logs the following
message types:
     0–emergencies–System unusable messages
     1–alert–Take immediate action
     2–critical–Critical condition
     3–error–Error message
     4–warning–Warning message
     5–notification–Normal but significant condition
     6–informational–Information message
     7–debugging–Debug messages and log FTP commands and WWW URLs
