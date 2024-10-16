
# Facilities in Syslog

## What are Facilities?
Facilities in syslogs are used to categorize log messages based on their sources or purposes.

| Number | Facility     | Description                                                                                                                                                                                                 |
|--------|--------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 14     | LOG_ALERT    | A general-purpose facility used to indicate alert conditions. However, it’s more of a severity level than a true facility. Ideally, these messages should represent issues with the alerting process rather than actual alerts. |
| 13     | LOG_AUDIT    | Like the Security (4) and Auth (19) facility codes, but primarily appropriate for audit processing, including performance monitoring.                                                                        |
| 19     | LOG_AUTH     | Reserved for authorization errors, such as invalid logins. It overlaps with Security (4) and Audit (13) due to unclear distinctions in the RFC.                                                             |
| 10     | LOG_AUTHPRIV | A separate flag for routing authorization messages to a log file with more restricted permissions than those of the auth facility.                                                                           |
| 15     | LOG_CLOCK    | Originally listed as a clock in the RFC, but often renamed as a lock. Used for locking mechanisms like file locking queues. Sometimes substituted for the Clock (15) facility code and might be identical to Clock (15) on certain systems. |
| 9      | LOG_CRON     | Cron logs its actions to the syslog facility ‘cron,’ and logging can be controlled using the standard syslogd (8) facility.                                                                                  |
| 3      | LOG_DAEMON   | Used for messages processed by other system daemons.                                                                                                                                                        |
| 11     | LOG_FTP      | Related to the Unix ftpd process and FTP program (somewhat deprecated but still in use). This facility is sometimes used for non-FTP protocol messages related to file transfers.                           |
| 0      | LOG_KERN     | Messages related to the Unix kernel process or generated by very low-level driver software and system programs.                                                                                             |
| 16     | LOG_LOCAL0   | User-definable facilities. Vendors like Cisco and Palo Alto use them, and they can be modified by systems/source.                                                                                           |
| 17     | LOG_LOCAL1   | User-definable facilities. Vendors like Cisco and Palo Alto use them, and they can be modified by systems/source.                                                                                           |
| 18     | LOG_LOCAL2   | User-definable facilities. Vendors like Cisco and Palo Alto use them, and they can be modified by systems/source.                                                                                           |
| 19     | LOG_LOCAL3   | User-definable facilities. Vendors like Cisco and Palo Alto use them, and they can be modified by systems/source.                                                                                           |
| 20     | LOG_LOCAL4   | User-definable facilities. Vendors like Cisco and Palo Alto use them, and they can be modified by systems/source.                                                                                           |
| 21     | LOG_LOCAL5   | User-definable facilities. Vendors like Cisco and Palo Alto use them, and they can be modified by systems/source.                                                                                           |
| 22     | LOG_LOCAL6   | User-definable facilities. Vendors like Cisco and Palo Alto use them, and they can be modified by systems/source.                                                                                           |
| 23     | LOG_LOCAL7   | User-definable facilities. Vendors like Cisco and Palo Alto use them, and they can be modified by systems/source.                                                                                           |
| 6      | LOG_LPR      | Messages from the line printer system process.                                                                                                                                                              |
| 2      | LOG_MAIL     | These are messages related to the SMTP system, Microsoft Exchange, as well as mail relay systems, and sometimes e-mail programs.                                                                            |
| 7      | LOG_NEWS     | These are messages related to the Network News processes, that have been deprecated, although they are still found on many Unix and mainframe systems. This facility is sometimes used to indicate low severity news events, such as a system being brought down. |
| -      | LOG_NOPRI    | syslog without priority level. Released part of 1.29.4 Linux Build.                                                                                                                                         |
| 12     | LOG_NTP      | Messages related to the Unix ntpd (News Transport Protocol) processes. Somewhat deprecated but still present on various Unix platforms.                                                                     |
| 5      | LOG_SYSLOG   | System log process messages.                                                                                                                                                                                |
| 1      | LOG_USER     | Typically, user-defined messages that haven’t been otherwise classified.                                                                                                                                    |
| 8      | LOG_UUCP     | Refers either to UUCP (Unix-to-Unix Copy) or network events, such as interface changes.                                                                                                                     |

# Log Levels

## What are Log Levels?
Log levels indicate the severity or importance of log messages. They help prioritize and filter log entries based on their significance.

| Number | Log Level  | Description                                                                                                                                                                                                 |
|--------|------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 7      | Debug      | The lowest severity, reserved strictly for debugging the system. In practice, debug messages can be totally ignored by everyone.                                                                             |
| 6      | Info       | These are informational messages, that can be reviewed later (having some pertinence), but that can be operationally ignored because they have no effect on management activities.                           |
| 5      | Notice     | These are messages that are sent with the intention of being noticed. They have a significant level of importance. A filter should generally not remove arbitrarily remove all messages with this severity. |
| 4      | Warning    | A significant message. It signifies a non-trivial degree of risk. There might not be any corrective action needed with this type of message.                                                                 |
| 3      | Error      | A highly significant message. The message indicates that corrective action, manual intervention, or operational change is necessary.                                                                         |
| 2      | Critical   | A critical situation exists that requires immediate attention. All other activities should be set aside, and the problem addressed as soon as possible. Possible risk to security or data or infrastructure is imminent. |
| 1      | Alert      | An extremely critical condition exists that requires immediate intervention by the highest levels of management, requiring whatever resources necessary to immediately fix. Data has been lost, security has been breached, or infrastructure has been damaged. |
| 0      | Emergency  | This severity should NEVER be used, reserved for situations where human safety or the overall health of the organization has been compromised or is in extreme jeopardy.                                      |
| -      | No Priority| Log data that has no priority flagged in the log file which sends data over to NoPri facility. Released part of 1.29.4 Linux Build.                                                                          |

# Viewing Syslog on Servers

The location of syslog depends on the Linux distribution:
- For Debian and Ubuntu: `/var/log/syslog`
- For Red Hat and CentOS: `/var/log/messages`

# Common Security Setups

| Product    | Default Facility | Documentation Link |
|------------|------------------|--------------------|
| Palo Alto  |                  |                    |
| Fortinet   |                  |                    |
| Cisco ASA  |                  |                    |
| Check Point|                  |                    |

# Content Hub Items

## Syslog

# Detection Rules Recommended

| Rule Name                    | Facility | MITRE Technique       | Content Hub Source |
|------------------------------|----------|-----------------------|--------------------|
| SSH - Potential Brute Force  | Syslog   | T1110 Credential Access| Syslog             |
| Failed logon attempts in authpriv | authpriv | T1110 Credential Access| Syslog             |

# UEBA Rules

*Note: This is a point-in-time snapshot. Always review for new rules and updates.*

| Name                                      | Enrichment Action                | Facility Required |
|-------------------------------------------|----------------------------------|-------------------|
| An account was created on this host       | Account created on Host          | authpriv          |
| An account was deleted on this host       | Account deleted on Host          | authpriv          |
| An account was added to the sudo group    | Account added to the sudo group  | authpriv          |
| An account was removed from the sudo group| Account removed from sudo group  | authpriv          |
| A network connection is made to/from the device | Device network connections (merges number of sources) | syslog |

---

