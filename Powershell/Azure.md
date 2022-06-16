
## bypass execution policy
```
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```
## install azure module:
```
 Install-Module -Name Az.Resources -AllowClobber -Scope CurrentUser
 Install-Module -Name Az -AllowClobber -Scope CurrentUser
```

## Sign In
```
Connect-AzAccount
```

## Gets the Azure PowerShell context for the current PowerShell session
```
Get-AzContext
Get-AzContext -ListAvailable
```

## Get all of the Azure subscriptions in your current Azure tenant
```
Get-AzSubscription
Get-AzSubscription -TenantId $TenantId
```

## Set the Azure PowerShell context to a specific Azure subscription
```
Set-AzContext -TenantId '000000-000000-0000000-00000'
Set-AzContext -SubscriptionId '000000-000000-0000000-00000'

get-azresourcegroup | format-table -groupby location
new-azresourcegroup -name 'rg-demo01' -location 'eastus'
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

## Get Azure Powershell Module version
```
$name='Azure'

if(Get-Module -ListAvailable | 
    Where-Object { $_.name -eq $name }) 
{ 
    (Get-Module -ListAvailable | Where-Object{ $_.Name -eq $name }) | 
    Select Version, Name, Author, PowerShellVersion  | Format-List; 
} 
else 
{ 
    "The Azure PowerShell module is not installed."
}
```

## Update all powershell modules for Azure Automation Account
- https://docs.microsoft.com/en-us/azure/automation/automation-update-azure-modules


## Azure Data Factory (ADF)
```
get-azdatafactoryv2
set-azdatafactoryv2 -name 'demo-adf941' -location 'eastus' -resourcegroup 'rg-demo01'
```

## Read Azure Key Vault Secrets:
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