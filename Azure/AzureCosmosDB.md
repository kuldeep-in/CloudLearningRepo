# Learn Cosmos DB in 2 Days

### Day 1
- Architecture overview.
- Consistency levels
    - Consistence, availability and performance tradeoffs.
- How to query using SQL
    - [Demo]
    - [Lab]
- Creation of stored procedures and triggers and UDFs.
    - [Demo]
    - [Labs]
- Partitioning, key choice, horizonal scaling.
- Data Modeling
- Pricing
- Limitations
- Conflict Resolution
- Change feeds.
    - Set up change feeds
    - [Demo]

### Day 2 
- Performance Monitoring.
    - Azure monitor
    - Setup cosmos metrics in Azure monitor
    - Query tuning
    - [Demo]
- Backup and recovery.
- Migrating data to CosmosDB
    - Data migration tool to migrate data to CosmosDB
    - [Demo]
- Security
- Database Throughput?
    - Throughput for database and containers.
    - Distribution based on partition key
    - [Demo]

# Learning Resources

- https://docs.microsoft.com/en-us/azure/cosmos-db/sql-api-get-started
- https://docs.microsoft.com/en-us/azure/cosmos-db/sql-api-dotnet-application
- https://docs.microsoft.com/en-us/azure/cosmos-db/import-data
- https://docs.microsoft.com/en-us/azure/cosmos-db/tutorial-sql-api-dotnet-bulk-import
- https://docs.microsoft.com/en-us/azure/cosmos-db/tutorial-query-sql-api
- https://docs.microsoft.com/en-us/azure/cosmos-db/create-notebook-visualize-data
- https://docs.microsoft.com/en-us/azure/cosmos-db/tutorial-global-distribution-sql-api?tabs=dotnetv2%2Capi-async

### Hands on Lab
- https://azurecosmosdb.github.io/labs/


## Set region in .net code
```
CosmosClient cosmosClient = new CosmosClient(
    "<connection-string-from-portal>", 
    new CosmosClientOptions()
    {
        ApplicationRegion = Regions.WestUS2,
    });
```

## SQL api query
```
SELECT VALUE COUNT(1) FROM c

SELECT * from f where f.id = "AndersenFamily"

SELECT 
{
    "Name":f.id, 
    "City":f.address.city, 
    "State":f.address.state
} AS Family 
FROM Families f

SELECT c.givenName, c.gender FROM c IN f.children

select * from Families.address.zip

SELECT * FROM Families.children[1]

SELECT 
f.id AS Name,
{ "state": f.address.state, "city": f.address.city } AS Address, 
f.address.zip 
FROM Families f

SELECT f.id, f.address.state = "CA" AS IsFromCAState FROM Families f

SELECT {"ParentName":p.givenName, "ChildName":c.givenName} AS Name
FROM Families f 
JOIN c IN f.children 
JOIN p IN f.parents

SELECT * 
FROM c IN Families.children
WHERE c.grade > 2

SELECT 
    f.id AS familyName,
    c.givenName AS childGivenName,
    c.firstName AS childFirstName,
    p.givenName AS petName 
FROM Families f 
JOIN c IN f.children 
JOIN p IN c.pets

```
### Stored Procedure
```
function createFamily(id, isregistered) { 
    var context = getContext(); 
    var collection = context.getCollection(); 
    var options = { disableAutomaticIdGeneration: true }; 
    var isAccepted = collection.createDocument(collection.getSelfLink(),
      { 
      "id": id,
      "isRegistered": isregistered
    },options,
    function (err, documentCreated) { 
		    if (err) throw new Error('Error' + err.message);
	      context.getResponse().setBody(documentCreated.id);
	    }
    );
    if (!isAccepted) return;
}
```

### UDF
```
function getName(document) {
    if (document.familyName != undefined ) {
        return document.familyName;
    }
    if (document.lastName != undefined ) {
        return document.lastName;
    }
    throw new Error("Document with id " + document.id + " does not contain name format.");
}
```
```
SELECT udf.unf02(c) FROM c
```

## PowerBI Kusto query
```
= Kusto.Contents("https://ade.loganalytics.io/subscriptions/00000000-0000-0000-0000-666cfa995c66/resourcegroups/rg-ms-monitor/providers/microsoft.operationalinsights/workspaces/log-ms-cosmosdb-001", "log-ms-cosmosdb-001", "AzureMetrics", [MaxRows=null, MaxSize=null, NoTruncate=null, AdditionalSetStatements=null])

https://ade.applicationinsights.io/subscriptions/<subscription-id>/resourcegroups/<resource-group-name>/providers/microsoft.insights/components/<ai-app-name>
```

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

