# Parameters
$SourceDatabaseName = ""
$TargetDatabaseName = ""
$TargetDatabaseSize = ""
$TargetDatabaseEdition = ""
$TargetDatabaseTier = ""
$BackupDatabaseName = $TargetDatabaseName + "_bkp_" + (Get-Date).ToString("yyyy-MM-dd-HH-mm")
$TargetConnectionName = ""
$SourceServerName = ""
$TargetServerName = ""
$ServerAdmin = ""
$SourceResourceGroupName = ""
$TargetResourceGroupName = ""
$ContainerName = ""
$StorageAccountName = ""
$BaseStorageUri = "https://" + $StorageAccountName + ".blob.core.windows.net/"
$SourceSubscriptionId = ""
$TargetSubscriptionId = ""
$StorageKeytype = ""
$StorageKey = ""
$serverPassword = ""
$securePassword = ConvertTo-SecureString -String $serverPassword -AsPlainText -Force 
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $serverAdmin, $securePassword

# Connect to Source Subscription
Write-Output "Connecting to Source Subscription with Id:'$SourceSubscriptionId'"
$connectionName = "AzureRunAsConnection"
	try
	{
		$servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

		Write-Verbose "Logging in to Azure..." -Verbose

		Add-AzureRmAccount `
			-ServicePrincipal `
			-TenantId $servicePrincipalConnection.TenantId `
			-ApplicationId $servicePrincipalConnection.ApplicationId `
			-CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-Null
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

$StorageKey = $(Get-AzureRmStorageAccountKey -ResourceGroupName $SourceResourceGroupName -StorageAccountName $StorageAccountName).Value[0]

# Generate a unique filename for the BACPAC
$bacpacFilename = "/" + $SourceDatabaseName + (Get-Date).ToString("yyyy-MM-dd-HH-mm") + ".bacpac"

# Storage account info for the BACPAC
$BacpacUri = $BaseStorageUri + $ContainerName + $bacpacFilename

#Export database
Write-Output "Exporting Database: '$SourceDatabaseName'"
$exportRequest = New-AzureRmSqlDatabaseExport `
                -ResourceGroupName $SourceResourceGroupName `
                -ServerName $SourceServerName `
                -DatabaseName $SourceDatabaseName `
                -StorageKeytype $StorageKeytype `
                -StorageKey $StorageKey `
                -StorageUri $BacpacUri `
                -AdministratorLogin $creds.UserName -AdministratorLoginPassword $creds.Password

# Check status of the export
$exportStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $exportRequest.OperationStatusLink

Write-Output "Exporting..."
while ($exportStatus.Status -eq "InProgress")
{
    $exportStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $exportStatus.OperationStatusLink
    Write-Output "Exporting..."
    Start-Sleep -s 10
}
Write-Output "Export completed"
###############################
#Import on target server
###############################
Write-Output "Connecting to Target Subscription with Id:'$TargetSubscriptionId'"
$connectionName = $TargetConnectionName
	try
	{
		$servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

		Write-Verbose "Logging in to Azure..." -Verbose

		Add-AzureRmAccount `
			-ServicePrincipal `
			-TenantId $servicePrincipalConnection.TenantId `
			-ApplicationId $servicePrincipalConnection.ApplicationId `
			-CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-Null
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

#Rename existing database
Write-Output "Renaming existing database to '$BackupDatabaseName"
try
{
    $bkpdatabase = Set-AzureRmSqlDatabase `
        -ResourceGroupName $TargetResourceGroupName `
        -DatabaseName $TargetDatabaseName `
        -ServerName $TargetServerName `
        -NewName $BackupDatabaseName
}
catch {
}

Start-Sleep -s 5

# Import bacpac to database with an S1 performance level
Write-Output "Importing database to '$TargetDatabaseName"
$importRequest = New-AzureRmSqlDatabaseImport `
    -ResourceGroupName $TargetResourceGroupName `
    -ServerName $TargetServerName `
    -DatabaseName $TargetDatabaseName `
    -DatabaseMaxSizeBytes $TargetDatabaseSize `
    -StorageKeyType $StorageKeytype `
    -StorageKey $StorageKey `
    -StorageUri $BacpacUri `
    -Edition $TargetDatabaseEdition `
    -ServiceObjectiveName $TargetDatabaseTier `
    -AdministratorLogin $creds.UserName -AdministratorLoginPassword $creds.Password

# Check import status and wait for the import to complete
$importStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink
Write-Output "Importing..."
while ($importStatus.Status -eq "InProgress")
{
    $importStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink
    Write-Output "Importing..."
    Start-Sleep -s 10
}

Write-Output "Database import Completed"
####################
