First of the customer needs to understand what they are missing by dropping the column. Ideally, they should send the raw logs somewhere else too, that way if they ever need that column again for whatever reason, they will be able to query it. The cheapest way to do that is to send the table to a blob storage container using Data Export rules. But if they also have that data forked into an ADX cluster, then that’s even better.
![image](https://github.com/MSJosh/documentation/assets/120500937/4e5f7159-91a0-4b24-b3d6-96553903676a)
 

At this point if they don’t already have a workspace DCR, they’ll have to create one. The DCR needs to be in the same region as the workspace.
![image](https://github.com/MSJosh/documentation/assets/120500937/2e1291da-8eca-47ff-b8c2-b8d1024d8f2e)
Once you have it, click Next. Then click on </> Transformation editor on the top and use the following query:
![image](https://github.com/MSJosh/documentation/assets/120500937/c18da45c-a386-4353-9733-6ca6adb877f4)
source

| project-away ConditionalAccessPolicies
![image](https://github.com/MSJosh/documentation/assets/120500937/25286902-2cb9-475b-b74d-bf1679cabd2b)
And finally Create.
Note that it doesn’t delete the value for already ingested logs. Only for the new one that will get ingested. Also doesn’t take place immediately, Usually it takes about five minutes.
