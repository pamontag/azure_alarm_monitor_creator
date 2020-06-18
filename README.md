
# Azure Alarm Monitor Automatic Creator

## Description

The powershell script takes in input a CSV file with the alarm to be created inside a resource group.
Depends of the alarm type, the script choose the correct ARM template for deploying the correct alarm, passing as a TemplateParameterObject the parameters for deploying the correct alarm

## How to use

Execute alarm creator launching the powershell script .\Create_Alarms.ps1.
Input parameters:

* InputAlarmCSV
  * The path of the CSV files that contains the alarm to be created
* ResourceGroupName
  * The name of the resource group where are inside the resources to monitor
* SubscriptionName
  * The name of the subscription where is the resource group
* WorkspaceName *(Optional)*
  * The name of the Log Analytics workspace, used for collecting metrics from Linux Virtual Machines

The input csv file columns are:

* Alarm
  * The type of the alarm to create
* Name
  * The name of the alarm to create
* Resource
  * The name of the resource to monitor
* Description
  * The description of the alarm
* Frequence
  * The frequence of execution of the alarm
* Period
  * The period of time where to monitor the metric of the resource
* Threshold
  * The threshold of the metric for triggering the alarm
* Severity
  * The severity level of the alarm

## Alarms implemented

### Virtual Machine Windows

* CPU Percentage

* Available MBytes

* Logical Disk Free Space Percentage

### Virtual Machine Linux

* CPU Percentage

* Available MBytes

* Logical Disk Free Space Percentage

### Storage Account

* File Capacity

### Sql Database

* Data Space Percentage Used

* Dead Locks

* Failed Connections

* Sessions Percentage Used

* Tempdb Space Percentage Used

* Worker Process Percentage Used

### Data Factory

* Failed Activities

* Failed Pipelines

* Failed Triggers

*More alarms and documentation coming soon...*
