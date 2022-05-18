# CosmosDB Workshop - SQL Queries

## Exercise 1 - Create CosmosDB Account
In this exercise we will use the Azure portal to create an Azure Cosmos DB SQL API account, create a document database and container and add data to the container.

You can refer ["Microsoft Docs - Create an Azure Cosmos account, container, and items"](https://docs.microsoft.com/en-us/azure/cosmos-db/create-cosmosdb-resources-portal) for this excercise.

### Steps

In the Azure portal...
1. Create an Azure Cosmos DB account. 
   * Click on **+ Create a resource** and search for `Azure Cosmos DB`. Click **Create**.
   * Select below options while creating Cosmos DB account
       * *Resource Group:* **Create new**
         * *Name:* `az{your_id}-cosmosdb-rg`
       * *Account Name*: `az{your_id}-cosmosdb`
       * *API*: `Core (SQL)`
       * *Location*: `West Europe`
       * *Capacity Mode*: `Provisioned throughput`
       * *Account Type*: `Non-Production`
       * *Geo-Redundancy*: `Disabled`
       * *Multi-region Writes*: `Disabled`
    
    **NOTE:** The database account will take approx. 5-10 minutes to be created.
2. Create a database in the Cosmos DB account. In the CosmosDB's select **Data Explorer** to open the data explorer blade.
    * From the drop dwon at the top of the blade, select **New Database**
    * *Database Id*: `DemoDatabase`
    * *Provision throughput*: `Enabled`
    * *Throughput*: `400 (Manual)`
3. Add a container. From the drop dwon at the top of the blade, select **New Container**
    * *Database Id*: **Use Existing** `DemoDatabase`
    * *Container Id*: `Families`
    * *Partition Key*: `/id`
4. Add data to your container.
    * Copy the json snippet from [WakefieldFamily](./Data/WakefieldFamily.json).
    * Select the `Families` container created, Click on Items under `Families` node.
    * From the menu at the top of the blade click **New Item**.
    * Paste the copied json.
    * Click **Save**
5. Repeat above step for below families data.
    * [TheSmiths](./Data/TheSmiths.json)
    * [TheAlexanders](./Data/TheAlexanders.json)
    * [MeyerAndFamily](./Data/MeyerAndFamily.json)
    * [AndersenFamily](./Data/AndersenFamily.json)
 
**Note:** After saving the document you will notice several fields have been automatically added by Cosmos DB. `_rid`, `_self`, `_etag`, `_attachments`, and `_ts`.
You can read more about these tags [here](https://docs.microsoft.com/en-us/rest/api/cosmos-db/collections).

## Exercise 2 - Write SQL queries to get below results:
1. Return `AndersenFamily` data.
2. Return Family Name, City, County and State in below format.
   ```json
   [
      {
          "Family": {
              "Name": "WakefieldFamily",
              "City": "Miami",
              "State": "FL"
          }
      },
      {
          "Family": {
              "Name": "TheSmiths",
              "City": "The Bronx",
              "State": "NY",
              "County": "Bronx"
          }
      }
   ]
   ```
3. Return Given Names of all the childern in the family along with their gender.

4. Return all the Zip codes in below format.
   ```json
   [
        33011,
        10453,
        98033,
        98033,
        90210
   ]
   ```
5. Return the 2nd child from all the families.
  
6. Return family name, address and zip in below format.
   ```json
   [
      {
          "Name": "WakefieldFamily",
          "Address": {
              "state": "FL",
              "city": "Miami"
          },
          "zip": 33011
      },
      {
          "Name": "TheSmiths",
          "Address": {
              "state": "NY",
              "city": "The Bronx"
          },
          "zip": 10453
      }
   ]
   ```

7. Check if the family is from CA state and return the result in below format.
   ```json
   [
      {
          "id": "WakefieldFamily",
          "IsFromCAState": false
      },
      {
          "id": "TheSmiths",
          "IsFromCAState": true
      }
   ]
   ```
8. Return Parent Child name in below format :
   ```json
   [
    {
        "Name": {
            "ParentName": "Robin",
            "ChildName": "Jesse"
        }
    },
    {
        "Name": {
            "ParentName": "Ben",
            "ChildName": "Jesse"
        }
    },
    {
        "Name": {
            "ParentName": "Robin",
            "ChildName": "Lisa"
        }
    },
    {
        "Name": {
            "ParentName": "Ben",
            "ChildName": "Lisa"
        }
    }
   ]
   ```
9. Return all childern with the grade greater than 2.

10. Retun All the childern with the pets in below format.
   ```json
   [
    {
        "familyName": "WakefieldFamily",
        "childName": "Jesse",
        "petName": "Goofy"
    },
    {
        "familyName": "WakefieldFamily",
        "childName": "Jesse",
        "petName": "Shadow"
    }
   ]
   ```

## Exercise 3 - Create an application using Cosmos DB SQL API
1. Open [Visual studio Code](https://code.visualstudio.com/Download).
2. From top Menu bar select `Terminal` and click on `New Terminal`.
3. From `Terminal` window navigate to your working directory.
   ```
   cd C:
   ```
4. Create a new folder for your application
   ```
   C:\> mkdir Workshop2610
   C:\> cd Workshop2610
   C:\Workshop2610>
   ```
5. Create new console application.
   ```
   C:\Workshop2610> dotnet new console -n FamilyApp
   ```
6. Navigate to the project folder
   ```
   C:\Workshop2610> cd FamilyApp
   C:\Workshop2610\FamilyApp>
   ```
7. Build project
   ```
   C:\Workshop2610\FamilyApp> dotnet build
   ```
8. From top Menu bar select `File` and click on `Open Folder`. Navigate to C:\Workshop2610\FamilyApp and click `Select Folder` from dialog box.

9. From top Menu bar select `Terminal` and click on `New Terminal`.

10. Make sure that you are at Project directory
   ```
   C:\Workshop2610\FamilyApp>
   ```
11. Install Cosmos DB package.
   ```
   C:\Workshop2610\FamilyApp> dotnet add package Azure.Cosmos --version 4.0.0-preview3
   ```
12. Build project
   ```
   C:\Workshop2610\FamilyApp> dotnet build
   ``` 
13. Write below code in `Program.cs`
   ```
    using System;
    using System.Collections.Generic;
    using System.Net;
    using System.Threading.Tasks;
    using Azure.Cosmos;
    using System.Text.Json;
    using System.Text.Json.Serialization;

    namespace FamilyApp
    {
        class Program
        {
            private const string EndpointUrl = "https://<your-account>.documents.azure.com:443/";
            private const string AuthorizationKey = "<your-account-key>";
            private const string DatabaseId = "DemoDatabase";
            private const string ContainerId = "Families";

            static async Task Main(string[] args)
            {
                CosmosClient cosmosClient = new CosmosClient(EndpointUrl, AuthorizationKey);
                await Program.QueryItemsAsync(cosmosClient);
            }

            private static async Task QueryItemsAsync(CosmosClient cosmosClient)
            {
                var sqlQueryText = "SELECT * FROM c";

                Console.WriteLine("Running query: {0}\n", sqlQueryText);

                CosmosContainer container = cosmosClient.GetContainer(Program.DatabaseId, Program.ContainerId);

                QueryDefinition queryDefinition = new QueryDefinition(sqlQueryText);

                List<Family> families = new List<Family>();

                await foreach (Family family in container.GetItemQueryIterator<Family>(queryDefinition))
                {
                    families.Add(family);
                    Console.WriteLine("\tRead {0}\n", family);
                }
            }
        }

        public class Family
        {
            [JsonPropertyName("id")]
            public string Id { get; set; }
            [JsonPropertyName("lastName")]
            public string LastName { get; set; }
            [JsonPropertyName("isRegistered")]
            public bool IsRegistered { get; set; }
            public override string ToString()
            {
                return JsonSerializer.Serialize(this);
            }
        }
    }
   ```
14. Run your project
   ```
   C:\Workshop2610\FamilyApp> dotnet run
   ``` 
15. Observe the response from Terminal screen.

## Exercise 4 - Optional
1. Update your application to execute the queries from Exercise 2.
