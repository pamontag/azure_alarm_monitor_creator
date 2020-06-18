[CmdletBinding()]
param(    
    [Parameter(Mandatory=$true)]
    [string]$InputAlarmsCSV,
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionName,
    [Parameter(Mandatory=$false)]
    [string]$WorkspaceName
)
function Login($SubscriptionName)
{
    $context = Get-AzContext

    if (!$context -or ($context.Subscription.Name -ne $SubscriptionName)) 
    {
        Connect-AzAccount -Subscription $SubscriptionName
    } 
    else 
    {
        Write-Host "SubscriptionName '$SubscriptionName' already connected"
    }
}

function BuildParameters($alarm) {
    $alarm.Description = $alarm.Description -replace "\\r\\n", "`r`n"
    if($alarm.Threshold -match "GB") {
       $alarm.Threshold = [int64]($alarm.Threshold -replace "GB","") * 1024 * 1024 * 1024     
    } elseif($alarm.Soglia -match "MB") {
        $alarm.Threshold = [int64]($alarm.Threshold -replace "MB","") * 1024 * 1024
    }
    $params = @{
        "alertName" = $alarm.Name
        "alertDescription" = $alarm.Description
        "alertFrequency" = "PT$($alarm.Frequence)"
        "alertPeriod" = "PT$($alarm.Period)"        
        "alertThreshold" = [int64]$alarm.Threshold
        "alertSeverity" = [int]$alarm.Severity
    }
    if($alarm.Alarm -like "VirtualMachine_*") {        
        $params.Add("vmName", $alarm.Resource)        
    } elseif($alarm.Alarm -like "SqlDatabase_*") {
        $db = $alarm.Resource -split ("/")
        $params.Add("sqlAzureServerName", $db[0])
        $params.Add("databaseName", $db[1])
    } elseif($alarm.Alarm -like "DataFactory_*") {
        $params.Add("dataFactoryName", $alarm.Resource)
    } elseif($alarm.Alarm -like "VirtualMachineLinux_*") {
        $params.Add("vmName", $alarm.Resource)
        $params.Add("workspaceName", $WorkspaceName)
    } elseif($alarm.Alarm -like "StorageAccount_*") {
        $params.Add("storageAccountName", $alarm.Resource)
    }
    $params
}

If(-not (Test-Path $InputAlarmsCSV))
{
    Write-Error "File degli allarmi non esistente"
    Exit
}

Login $SubscriptionName

$alarms = Import-Csv -Path $InputAlarmsCSV
foreach($alarm in $alarms) {
    Write-Host "Creating alarm $($alarm.Name) for resource $($alarm.Resource)"
    Write-Host "Checking existence of alarm type $($alarm.Alarm)"
    $templateFile = "$PSScriptRoot\$($alarm.Alarm)\template.json"
    If(-not (Test-Path $templateFile)) {
        "Deploying template for alarm $($alarm.Alarm) not found into $templatefile. Skip."
        continue 
    }
    $params = BuildParameters($alarm)
    
    Write-Host "Deploying alarm with those settings:"
    $params
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $templateFile -TemplateParameterObject $params
}

Write-Host "END"
