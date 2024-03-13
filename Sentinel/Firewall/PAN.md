Collecting Palo Alto Data with Sentinel

1. Configure Panorama based on CEF Format. https://docs.paloaltonetworks.com/resources/cef  Microsoft recommends CEF as it provides an easy to read and parse format that can be used for a wide range of detection rules both in CommonSecurityLog and ASIM based detections.
2. When configuring the logging within Panorama you must decide to not send data to your collector or utilize the default configuration provided by Palo Alto where it sends a wide range of information especially when it comes to Traffic data. Before sending data the organization should decide the importance of the data and if they are going to be using the data to detect threats or use more for incident response. 





        "transformKql": "source | where DeviceAction !contains \"Deny\" | where DeviceAction !contains \"Reset-both\" | project-away DeviceCustomString3, ExtID, DeviceCustomString3Label, DeviceCustomString6,DeviceCustomString6Label, AdditionalExtensions",
        "outputStream": "Microsoft-CommonSecurityLog"
