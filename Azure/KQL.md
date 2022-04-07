# Read #JSON / #ADF

```
ADFActivityRun
| where ActivityType  == "Copy"
| where isnotempty( Output)
| extend AllProperties = todynamic(Output)
| project PipelineName, RowsRead = AllProperties["rowsRead"]
```
