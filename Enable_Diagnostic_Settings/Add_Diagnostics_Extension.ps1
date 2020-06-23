[CmdletBinding()]
param(    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionName,
    [Parameter(Mandatory=$true)]
    [string]$VMName,
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory=$false)]
    [string]$SettingsFile="$PSScriptRoot\diagnostic_settings_template.json"
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

If(-not (Test-Path $SettingsFile))
{
    Write-Error "diagnostic settings template not present"
    Exit
}

Login $SubscriptionName

Write-Host "Creating System Identity to VM $VMNAme"

$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName
Update-AzVM -ResourceGroupName $ResourceGroupName -VM $vm -AssignIdentity:$SystemAssigned
Write-Host "System Identity created"

Write-Host "Prepare settings from template $SettingsFile"
$context = Get-AzContext
$subscriptionId = $context.Subscription.Id
$settingsText = Get-Content $SettingsFile -Raw 
$settingsText = $settingsText -replace "SUBSCRIPTIONID", $subscriptionId
$settingsText = $settingsText -replace "VMNAME", $VMName
$settingsText = $settingsText -replace "RESOURCEGROUPNAME", $ResourceGroupName
$settingsText | Out-File "$PSScriptRoot\diagnostic_settings_$VMNAME.json"

Write-Host "Settings created into $PSScriptRoot\diagnostic_setting_$VMNAME.json"

$output = set-azvmdiagnosticsExtension -ResourceGroupName $ResourceGroupName -vmName $VMName -StorageAccountName $StorageAccountName -DiagnosticsConfigurationPath "$PSScriptRoot\diagnostic_settings_$VMNAME.json" -Verbose

Write-Host "Created diagnostic settings"

Remove-Item "$PSScriptRoot\diagnostic_settings_$VMNAME.json"

Write-Host "END"