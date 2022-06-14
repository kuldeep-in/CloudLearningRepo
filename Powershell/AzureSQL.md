## Execute SQL Scripts
```
$starttime = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")
Write-OutPut   $starttime    
        # Setup credentials   
        $ServerName = ""
        $UserId = "dbadmin"
        $Password = ""
        $DBName = ""
                
        # Create connection to Master DB
        $MasterDatabaseConnection = New-Object System.Data.SqlClient.SqlConnection
        $MasterDatabaseConnection.ConnectionString = "Server = $ServerName; Database = $DBName; User ID = $UserId; Password = $Password; Connection Timeout=1800;"
        $MasterDatabaseConnection.Open();
        
        # Create command to query the current size of active databases in $ServerName
        $MasterDatabaseCommand = New-Object System.Data.SqlClient.SqlCommand
        $MasterDatabaseCommand.Connection = $MasterDatabaseConnection
        $MasterDatabaseCommand.CommandTimeout = 1800
        $MasterDatabaseCommand.CommandText = "SELECT * from SalesLT.vProductAndDescription a inner join SalesLT.vProductAndDescription b on a.ProductID = b.ProductID"
        
        #$MasterDatabaseCommand.CommandText = 
        #    "
        #       DECLARE @i INT 
        #            SET @i = 1 
        #            WHILE @i <= 500 
        #            BEGIN 
        #            INSERT INTO orders 
        #            (
        #            OrderDesc ,
        #            Quantity ,
        #            OrderValue 
        #            )
        #            VALUES (
        #                REPLICATE('abc', 100),
        #                @i % 8, 
        #                RAND() * 800000
        #            ) 
        #            SET @i = @i + 1 
        #
        #            SELECT * FROM Orders
        #            END 
        #            
        #    "

        # Execute reader and return tuples of results <database_name, SizeMB>
        $MasterDbResult = $MasterDatabaseCommand.ExecuteReader()
        # Write-OutPut $MasterDbResult
        
$endtime = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")
Write-OutPut    $endtime 
        
        # Close connection to Master DB
        $MasterDatabaseConnection.Close() 
```
