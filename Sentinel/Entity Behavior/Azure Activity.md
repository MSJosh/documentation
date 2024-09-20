 

1 - From General, Select the entity type.
![image](https://github.com/user-attachments/assets/a58978af-25fe-43d1-8b56-de55f11d7984)


2 - From Activity Configuration, Select the entity identifier & replaced it with '{{AzureResource_ResourceId}}'.

![image](https://github.com/user-attachments/assets/eb9a6fdb-2e8e-4aa5-9de2-3fcb627ec384)


![image](https://github.com/user-attachments/assets/067fb831-c58e-415f-86eb-f9db06ee3de7)

 

3 - Click on review and create and then create. After you will be able to create a new activity from template.



KQL query  reference

AzureActivity
| where OperationNameValue =~ "MICROSOFT.COMPUTE/VIRTUALMACHINES/EXTENSIONS/WRITE"
| where _ResourceId =~ '{{Host_AzureID}}'
| extend resBody = parse_json(Properties).responseBody
| where resBody != ""
| extend resBody = parse_json(tostring(resBody))
| extend extName = tostring(resBody.name), extType = resBody.properties.type
| where extType in ("CustomScriptExtension", "CustomScript", "CustomScriptForLinux")
| project TimeGenerated, Caller, _ResourceId, OperationNameValue, Resource, extType, extName  
| project Caller, _ResourceId, extName, TimeGenerated
