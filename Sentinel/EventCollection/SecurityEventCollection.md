## Deploy Azure Monitor Agent (AMA) and associate it with a Data Collection Rule (DCR).

### Windows Systems

With Windows Systems you have options manual installation and assignment and automated through Azure Policy. This document will go through both options. In both options we want to set up the DCR in Sentinel Data Connector page.

1. In Content Hub search for Windows Security Events and install the solution in your environment. This solution currently has two data connectors (AMA and MMA) along with analytic rules and hunting queries that can be used to secure your environment.

<div style="text-align:center"><img src="https://github.com/MSJosh/documentation/assets/120500937/00915350-18ce-49b0-8c5f-ef7debd315f8" alt="image"></div>

2. Once installed go to Data connectors and find the connector named Windows Security Events via AMA. Open the connector page and select +Create data collection rule. This will open a new window where you will enter the DCR name, select subscription and resource group where you want the DCR to be stored. Be sure to put the DCR in a location that can be accessed for Azure Policy or admin(s) to assign to the desired Windows System. 

3. You can select existing resources that exist within Azure/Arc Connected. If you select an entire subscription or resource group any resource compatible will be put into the DCR rule along with installing the Azure Monitor Agent. When using this method any new systems added in the Subscription and/or Resource Group will need to be added manually by changing the DCR. 

4. Define the type of logs needed for this DCR. You can change this rule and add or reduce the amount of event IDs collected after it is saved but be sure to be aware of the data set being collected and ensure use of the collection through UEBA, Analytic Rules, Hunting Rules, and Workbooks. 

<div style="text-align:center"><img src="https://github.com/MSJosh/documentation/assets/120500937/6c429d22-e807-4616-8979-6800abb39b2a" alt="image"></div>

    - Review Events - https://github.com/MSJosh/documentation/Sentinel/EventCollection/SecurityEvents.md
    - Custom/XPath documentation - https://docs.microsoft.com/en-us/azure/azure-monitor/agents/data-sources

5. Finish the creation of the DCR. Once saved the selected machines selected under resource will check and install Azure Monitor Agent (AMA) if not installed already and write the DCR configuration on the machine so that the agent knows what to collect and send to Log Analytics Workspace/Sentinel. 

### Create a policy for Collection.

1. The above steps to create a DCR should be followed as we will require a DCR to be associated with the policy. You do not need to add resources for the DCR to be saved.

2. To get the Data Collection Endpoint Resource ID go to Monitor > Data Collection Rules > Data Collection Name created > Json View (found upper right). Copy the entire Resource ID line. You will use this later in Azure Policy.

<div style="text-align:center"><img src="https://github.com/MSJosh/documentation/assets/120500937/b55cfad3-3f77-48d5-8413-c6c26428ede3" alt="image"></div>

3. Go to Azure Policy in your Azure Tenant. It can be accessed by searching Policy in the search bar. Select Definitions and search for the following Initiative “Configure Windows machines to run Azure Monitor Agent and associate them to a Data Collection Rule” Selecting the Initiative will bring you this page.

<div style="text-align:center"><img src="https://github.com/MSJosh/documentation/assets/120500937/621a8e9c-9a03-4b76-90fb-72e14a86abab" alt="image"></div>

4. Assign the Initiative by selecting the button in the upper left corner of the window. This will bring you to a new page where you can define your scope, parameters, and remediation steps.

<div style="text-align:center"><img src="https://github.com/MSJosh/documentation/assets/120500937/0c92b1d3-fadd-493c-a733-79bc89bf0f30" alt="image"></div>

    - For scope if you want this policy to review and manage. Remember this will inherit down so if you select the management group it will deploy new and existing subscriptions.

5. Select the Parameters tab and enter the Resource ID that you copied from the JSON on the DCR.

<div style="text-align:center"><img src="https://github.com/MSJosh/documentation/assets/120500937/f01d9b17-1243-42c7-af07-f148c3da1b38" alt="image"></div>

6. Select Remediation as the next step. For the first remediation select configure Windows Virtual Machine to run Azure Monitor. We will add other remediation steps in future steps to manage Arc, VMSS, and configure the DCR we created to these systems.

<div style="text-align:center"><img src="https://github.com/MSJosh/documentation/assets/120500937/8f1a0150-f126-41e2-85ed-9d9e665a6d98" alt="image"></div>

    - As part of remediation, a Managed Identity is created and associated with the Azure Policy with the proper permissions to implement the policies.

7. Now that the initiative is applied, and the underlying policies are applied, new Windows systems added to the environment will have the policies applied and enforced.

8. To create other remediation tasks, select Compliance in Policy and find the Initiative created “Configure Windows machines to run Azure Monitor Agent and associate them to a Data Collection Rule”.

9. Select “Create remediation task” on the top of the window.

<div style="text-align:center"><img src="https://github.com/MSJosh/documentation/assets/120500937/2feb217d-c123-4875-8d81-fc7f5c27f418" alt="image"></div>

10. This will bring up a new page where you can select which policy needs to be remediate. You can repeat this task for each policy requiring remediation. This process will use the managed identity created in the earlier steps to resolve the configuration gaps.

<div style="text-align:center"><img src="https://github.com/MSJosh/documentation/assets/120500937/19c0453f-d1a6-4f26-ba87-7ff0860934ba" alt="image"></div>
