# Read #JSON / #ADF

```
ADFActivityRun
| where ActivityType  == "Copy"
| where isnotempty( Output)
| extend AllProperties = todynamic(Output)
| project PipelineName, RowsRead = AllProperties["rowsRead"]
```

Failed pipeline count
```
ADFPipelineRun
| where Status =~ "Failed"
| where TimeGenerated > ago(7d)
| summarize Count = count() by PipelineName
| render piechart  
```

# #PowerBI Kusto query
```
= Kusto.Contents("https://ade.loganalytics.io/subscriptions/00000000-0000-0000-0000-666cfa995c66/resourcegroups/rg-ms-monitor/providers/microsoft.operationalinsights/workspaces/log-ms-cosmosdb-001", "log-ms-cosmosdb-001", "AzureMetrics", [MaxRows=null, MaxSize=null, NoTruncate=null, AdditionalSetStatements=null])

https://ade.applicationinsights.io/subscriptions/<subscription-id>/resourcegroups/<resource-group-name>/providers/microsoft.insights/components/<ai-app-name>
```

# #CosmosDB Diagnostics Queries
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
