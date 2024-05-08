<#
.SYNOPSIS
    This command will generate a CSV file containing the information about all the Azure Sentinel
    Analytic rules templates. Place an X in the first column of the CSV file for any template
    that should be used to create a rule and then call New-RulesFromTemplateCSV.ps1 to generate
    the rules.
.DESCRIPTION
    This command will generate a CSV file containing the information about all the Azure Sentinel
    Analytic rules templates. Place an X in the first column of the CSV file for any template
    that should be used to create a rule and then call New-RulesFromTemplateCSV.ps1 to generate
    the rules.
.PARAMETER WorkspaceName
    Enter the Log Analytics workspace name, this is a required parameter.
.PARAMETER ResourceGroupName
    Enter the Log Analytics workspace name, this is a required parameter.
.PARAMETER FileName
    Enter the file name to use. Defaults to "ruletemplates". ".csv" will be appended to all filenames.
.NOTES
    AUTHOR: Gary Bushey
    LASTEDIT: 16 Jan 2020
.EXAMPLE
    Export-AzSentinelAnalyticsRuleTemplates -WorkspaceName "workspacename" -ResourceGroupName "rgname"
    In this example, you will get the file named "ruletemplates.csv" generated containing all the rule templates.
.EXAMPLE
    Export-AzSentinelAnalyticsRuleTemplates -WorkspaceName "workspacename" -ResourceGroupName "rgname" -FileName "test"
    In this example, you will get the file named "test.csv" generated containing all the rule templates.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$WorkspaceName,

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [string]$FileName = "ruletemplates"
)

Function Export-AzSentinelAnalyticsRuleTemplates {
    param (
        [string]$WorkspaceName,
        [string]$ResourceGroupName,
        [string]$FileName
    )

    # Setup the Authentication header needed for the REST calls
    $context = Get-AzContext
    $profile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    $profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($profile)
    $token = $profileClient.AcquireAccessToken($context.Subscription.TenantId)
    $authHeader = @{
        'Content-Type'  = 'application/json' 
        'Authorization' = 'Bearer ' + $token.AccessToken 
    }
    
    $SubscriptionId = (Get-AzContext).Subscription.Id

    # Load the templates so that we can copy the information as needed
    $url = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$WorkspaceName/providers/Microsoft.SecurityInsights/alertruletemplates?api-version=2019-01-01-preview"
    $results = (Invoke-RestMethod -Method "Get" -Uri $url -Headers $authHeader).value

    foreach ($result in $results) {
        # Escape the description field so it does not cause any issues with the CSV file
        $description = $result.properties.Description -replace '"', '""'

        # Generate the list of data connectors. Using the pipe as the delimiter since it does not appear in any data connector name
        $requiredDataConnectors = $result.properties.requiredDataConnectors -join "|"

        # Generate the list of tactics. Using the pipe as the delimiter since it does not appear in any tactic name
        $tactics = $result.properties.tactics -join "|"

        # Translate the query frequency and period text into something more readable
        $frequencyText = ConvertISO8601ToText -queryFrequency $result.properties.queryFrequency -type "Frequency"
        $queryText = ConvertISO8601ToText -queryFrequency $result.properties.queryPeriod -type "Query"

        # Translate the threshold values into something more readable
        $ruleThresholdText = RuleThresholdText -triggerOperator $result.properties.triggerOperator -triggerThreshold $result.properties.triggerThreshold

        # Create and output the line of information
        [pscustomobject]@{
            Selected              = " "
            Severity              = $result.properties.severity
            DisplayName           = $result.properties.displayName
            Kind                  = $result.kind
            Name                  = $result.Name
            Description           = $description
            Tactics               = $tactics
            RequiredDataConnectors = $requiredDataConnectors
            RuleFrequency         = $frequencyText
            RulePeriod            = $queryText
            RuleThreshold         = $ruleThresholdText
            Status                = $result.properties.status
        } | Export-Csv "$FileName.csv" -Append -NoTypeInformation
    }
}

Function ConvertISO8601ToText {
    param (
        [string]$queryFrequency,
        [string]$type
    )

    $returnText = ""

    if ($null -ne $queryFrequency) {
        # Extract only the numeric part from the string
        $timeLength = [regex]::Match($queryFrequency, '\d+').Value

        $timeDesignation = $queryFrequency[-1]

        $returnText = "Every $timeLength"

        if ($type -eq "Query") {
            $returnText = "Last $timeLength"
        }

        switch ($timeDesignation) {
            "M" { $returnText += " minute"; if ([int]$timeLength -gt 1) { $returnText += "s" } }
            "H" { $returnText += " hour"; if ([int]$timeLength -gt 1) { $returnText += "s" } }
            "D" { $returnText += " day"; if ([int]$timeLength -gt 1) { $returnText += "s" } }
        }
    }
    
    return $returnText
}

Function RuleThresholdText {
    param (
        [string]$triggerOperator,
        [string]$triggerThreshold
    )

    $returnText = ""

    if ($null -ne $triggerOperator) {
        $returnText = "Trigger alert if query returns "

        switch ($triggerOperator) {
            "GreaterThan"   { $returnText += "more than" }
            "FewerThan"     { $returnText += "less than" }
            "EqualTo"       { $returnText += "exactly" }
            "NotEqualTo"    { $returnText += "different than" }
        }

        $returnText += " $triggerThreshold results"
    }
    
    return $returnText
}

# Execute the code
Export-AzSentinelAnalyticsRuleTemplates -WorkspaceName $WorkspaceName -ResourceGroupName $ResourceGroupName -FileName $FileName
