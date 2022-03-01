
# Queue to Storage Table

### Function code
```
#r "Newtonsoft.Json"
using System;
using Newtonsoft.Json;

public class DataModel
{
 public string PartitionKey {get;set;} 
 public string RowKey{get;set;}
 public string Id { get; set; }
 public string Name { get; set; }
 public string Location {get; set;}
}

//public static void Run(string myQueueItem, ILogger log)
public static async Task Run(string myQueueItem, ILogger log, IAsyncCollector<DataModel> outputTable)
{
    DataModel e = JsonConvert.DeserializeObject<DataModel>(myQueueItem);
    log.LogInformation($"C# Q: ID is {e.Id}");
    log.LogInformation($"C# Q: Name is {e.Name}");
    e.PartitionKey = e.Location;
    e.RowKey = e.Id;

    await outputTable.AddAsync(e);

    log.LogInformation($"C# Queue trigger function processed: {myQueueItem}");
}

```

### Queue Message
```
{"Id": 1, "Name": "John", "Location": "London"}
```

# Blob to Queue
### function code
```
#r "Newtonsoft.Json"
using System;
using Newtonsoft.Json;

public class DataModel
{
 public string Id { get; set; }
 public string Description { get; set; }
}

public static void Run(Stream myBlob, string name, ILogger log, ICollector<string> outputQueueItem)
{
    StreamReader sr = new StreamReader(myBlob);
    string json = sr.ReadToEnd();

    DataModel e = JsonConvert.DeserializeObject<DataModel>(json);

    log.LogInformation($"C# Q: ID is {e.Id}");
    log.LogInformation($"C# Q: Desc is {e.Description}");

    outputQueueItem.Add("File processed by the function: " + name);
    outputQueueItem.Add(json);

    log.LogInformation($"C# Blob trigger function Processed blob\n Name:{name} \n Size: {myBlob.Length} Bytes");
}
```

### Json File
```
{
  "Id": "12",
  "Description": "This is an order for some pasta"
}
```
