# ADF

## Cost per activity in ADF

```
ADFActivityRun
| where TimeGenerated > ago(7d)
| where Status == "Succeeded"
| where Output has "billingReference"
| extend billingReference = parse_json(Output).billingReference
| project ActivityName, ActivityType, billingReference, PipelineName
| extend duration = toreal(billingReference.billableDuration[0].duration)
| extend meterType = tostring(billingReference.billableDuration[0].meterType)
| extend unit = tostring(billingReference.billableDuration[0].unit)
| summarize sum(duration) by strcat(ActivityType, '-',PipelineName,'-', ActivityName, '-', unit,'-', meterType)
| render piechart
```

# Cosmos DB 
## Diagnostics Queries (KQL)
```
AzureDiagnostics
| where ResourceProvider=="MICROSOFT.DOCUMENTDB" and Category =="DataPlaneRequests"

AzureActivity 
| where ResourceProvider=="Microsoft.DocumentDb" and Category=="DataPlaneRequests" 
| summarize count() by Resource

AzureActivity 
| where Caller == "test@company.com" and ResourceProvider=="Microsoft.DocumentDb" and Category=="DataPlaneRequests" 
| summarize count() by Resource

# RU Consumed per second
AzureDiagnostics
| where Category == "DataPlaneRequests"
| where collectionName_s == "gaming-001" 
| summarize ConsumedRUsPerSec = sum(todouble(requestCharge_s)) by bin(TimeGenerated, 1s)
| project TimeGenerated, ConsumedRUsPerSec
| render timechart

# Max RU consumed per hour
let T = AzureDiagnostics
| where Category == "DataPlaneRequests"
| where collectionName_s == "gaming-001" 
| summarize ConsumedRUsPerSec = sum(todouble(requestCharge_s)) by bin(TimeGenerated, 1s)
| project TimeGenerated, ConsumedRUsPerSec
| render columnchart     
;
T
| summarize MaxRUPerHour = max(ConsumedRUsPerSec) by bin(TimeGenerated, 1h)
| render timechart

# Top resource consuming operations
AzureDiagnostics
| where collectionName_s == "gaming-001" 
| where databaseName_s == "ms-demo-001"
| order by requestCharge_s desc 
| take 10
| project TimeGenerated,regionName_s, operationType_s, partitionKey_s,requestCharge_s,TenantId

| render piechart 

# Requests caller and ip addresses
AzureActivity
| where ActivityStatus  =~ "Succeeded"
| where ResourceProvider =~ "Microsoft.DocumentDB"
| summarize Count = count() by Caller, CallerIpAddress
| project Caller, CallerIpAddress, Count
| render barchart 

# Activity trend
AzureActivity
| where ActivityStatus  =~ "Succeeded"
| where ResourceProvider =~ "Microsoft.DocumentDB"
| summarize ConsumedRUsPerSec = count() by bin(TimeGenerated, 1m)
| render timechart

# 429-request distribution
AzureDiagnostics
| where collectionName_s == "gaming-001" 
| where statusCode_s == "429"
| summarize Count = count() by OperationName
| project OperationName, Count
| render piechart 

# Total Number of requests per minute:
AzureMetrics
| where MetricName == "TotalRequests"
| project TimeGenerated, Count
| render timechart
```

# App Insights
## Custom status code
```
traces
| where message startswith "Status of"
| order by timestamp desc nulls last 
| extend appId = tostring(customDimensions.appId)
| extend status = customDimensions.status
| summarize arg_max(timestamp, status) by appId
//| order by timestamp desc
//| project message, customDimensions.appId, customDimensions.status, customDimensions
//| where isempty(customDimensions.status) == false
```
