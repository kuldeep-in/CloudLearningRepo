
## bypass execution policy
```
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```
## install azure module:
```
 Install-Module -Name Az.Resources -AllowClobber -Scope CurrentUser
 Install-Module -Name Az -AllowClobber -Scope CurrentUser
```

## Read webpage in loop
```
    For ($i=0; $i -le 800; $i++) {
    $WebResponse9 = Invoke-WebRequest "https://app-ms-dataportal.azurewebsites.net/SQL/Edit/137676763" -UseBasicParsing
    }
```

## list all resource group in a subscription
```
$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

#Get all ARM resources from all resource groups
$ResourceGroups = Get-AzureRmResourceGroup 

foreach ($ResourceGroup in $ResourceGroups)
{    
    Write-Output ("Showing resources in resource group " + $ResourceGroup.ResourceGroupName)
    $Resources = Find-AzureRmResource -ResourceGroupNameContains $ResourceGroup.ResourceGroupName | Select ResourceName, ResourceType
    ForEach ($Resource in $Resources)
    {
        Write-Output ($Resource.ResourceName + " of type " +  $Resource.ResourceType)
    }
    Write-Output ("")
} 
```

## Read Key Vault Secrests:
```

Write-Verbose -Message 'Connecting to Azure'
  
$ConnectionName = 'AzureRunAsConnection'
try
{
    $ServicePrincipalConnection = Get-AutomationConnection -Name $ConnectionName      
   
    'Log in to Azure...'
    $null = Connect-AzAccount `
        -ServicePrincipal `
        -TenantId $ServicePrincipalConnection.TenantId `
        -ApplicationId $ServicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint 
}
catch 
{
    if (!$ServicePrincipalConnection)
    {
        # You forgot to turn on 'Create Azure Run As account' 
        $ErrorMessage = "Connection $ConnectionName not found."
        throw $ErrorMessage
    }
    else
    {
        # Something else went wrong
        Write-Error -Message $_.Exception.Message
        throw $_.Exception
    }
}

try
{
    # Setup credentials 
    $VaultName = "vault-ms-001"  
    $ServerName = "sql-ms.database.windows.net"
    $UserId = Get-AzKeyVaultSecret -VaultName $VaultName -Name "DatabaseUser" -AsPlainText 
    $Password = Get-AzKeyVaultSecret -VaultName $VaultName -Name "DatabasePassword" -AsPlainText 
    $DBName = "sqldb-demo-poc01"
                
    # Create connection to DB
    $DatabaseConnection = New-Object System.Data.SqlClient.SqlConnection
    $DatabaseConnection.ConnectionString = "Server = $ServerName; Database = $DBName; User ID = $UserId; Password = $Password; Connection Timeout=1800; MultipleActiveResultSets=true;"
    
    $DatabaseConnection.Open();
    
    # Create command
    $DatabaseCommand = New-Object System.Data.SqlClient.SqlCommand
    $DatabaseCommand.Connection = $DatabaseConnection
    $DatabaseCommand.CommandTimeout = 1800
    $DatabaseCommand.CommandText = "select top 5 CustomerID, FirstName from customer"

    $DbResult = $DatabaseCommand.ExecuteReader()

       
    while ($DbResult.Read()) {
        Write-OutPut $DbResult["CustomerID"] $DbResult["FirstName"]
    }
  
    # Close connection
    $DatabaseConnection.Close() 

 }
 catch
 {
     # Something else went wrong
        Write-Error -Message $_.Exception.Message
        throw $_.Exception
 }

$endtime = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")
Write-OutPut  $endtime       

```
