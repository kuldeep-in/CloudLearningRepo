## Execute SQL
```
$starttime = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")
Write-OutPut  $starttime    
        # Setup credentials   
        $ServerName = ""
        $UserId = ""
        $Password = ""
        $DBName = ""
                
        # Create connection to Master DB
        $MasterDatabaseConnection = New-Object System.Data.SqlClient.SqlConnection
        $MasterDatabaseConnection.ConnectionString = "Server = $ServerName; Database = $DBName; User ID = $UserId; Password = $Password; Connection Timeout=1800; MultipleActiveResultSets=true;"
        
        
        For ($i=0; $i -le 30; $i++) {

            $MasterDatabaseConnection.Open();
        
        # Create command to query the current size of active databases in $ServerName
        $MasterDatabaseCommand = New-Object System.Data.SqlClient.SqlCommand
        $MasterDatabaseCommand.Connection = $MasterDatabaseConnection
        $MasterDatabaseCommand.CommandTimeout = 1800
        $MasterDatabaseCommand.CommandText = "select * from orders500000"

        # Execute reader and return tuples of results <database_name, SizeMB>
        $MasterDbResult = $MasterDatabaseCommand.ExecuteReader()
        # Write-OutPut $MasterDbResult
        Write-OutPut $i

        $endtime = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")
Write-OutPut   $endtime 
        
        # Close connection to Master DB
        $MasterDatabaseConnection.Close() 
        Start-Sleep -s 45
        }
```

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

## Execure Stored Procedure
```
    #$connection = new-object System.Data.SqlClient.SQLConnection("Data Source=$server;Integrated Security= True;Initial Catalog=$database; MultipleActiveResultSets=True;");
    $connection = new-object System.Data.SqlClient.SQLConnection("Server=tcp:xxx.database.windows.net,1433;Database=xxx;User ID=xxx;Password=xxx; Connection Timeout=5000; MultipleActiveResultSets=True;");
    
    $i = 0;

     while ($i -le 5)
        {
            $a = Get-Date

            write-host -ForegroundColor Green "Loop: $i : $a"

            #$connection.Open();
            #$getspDefQuery = "EXEC [UTIL].[UspOptimizeDatabase]"
            #$spDefcmd = new-object System.Data.SqlClient.SqlCommand($getspDefQuery, $connection);
            #$spDefreader = $spDefcmd.ExecuteReader()

            #$connection.Close(); 
            #$scon = New-Object System.Data.SqlClient.SqlConnection
            #$scon.ConnectionString = $connection
    
            $cmd = New-Object System.Data.SqlClient.SqlCommand
            $cmd.Connection = $connection
            $cmd.CommandText = "EXEC [UTIL].[UspOptimizeDatabase]"
            $cmd.CommandTimeout = 5000
    
            $connection.Open()
            $cmd.ExecuteNonQuery()
            $connection.Close()
            $cmd.Dispose()

            $i++;
            
            Start-Sleep -s 10                
        }
```
