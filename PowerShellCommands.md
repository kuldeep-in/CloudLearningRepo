


## Read webpage in loop
```
    For ($i=0; $i -le 800; $i++) {
    $WebResponse9 = Invoke-WebRequest "https://app-ms-dataportal.azurewebsites.net/SQL/Edit/137676763" -UseBasicParsing
    }
```





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
