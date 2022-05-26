
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
