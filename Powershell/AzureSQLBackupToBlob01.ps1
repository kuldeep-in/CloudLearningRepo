#NOTE:

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



# Database to export
$DatabaseName = ""
$ServerName = ""
$ServerAdmin = ""
$ResourceGroupName = ""
$serverPassword = ""
$securePassword = ConvertTo-SecureString -String $serverPassword -AsPlainText -Force 
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $serverAdmin, $securePassword

# Generate a unique filename for the BACPAC
$bacpacFilename = $DatabaseName + (Get-Date).ToString("yyyy-MM-dd-HH-mm") + ".bacpac"

# Storage account info for the BACPAC
$BaseStorageUri = ""
$BacpacUri = $BaseStorageUri + "/Daily/" + $bacpacFilename
$StorageKeytype = "StorageAccessKey"
$StorageKey = ""

Write-Output "Bacpack URL:  '$BacpacUri'"

Write-Output "Creating request to backup database '$DatabaseName'"

$exportRequest = New-AzureRmSqlDatabaseExport -ResourceGroupName $ResourceGroupName -ServerName $ServerName `
-DatabaseName $DatabaseName -StorageKeytype $StorageKeytype -StorageKey $StorageKey -StorageUri $BacpacUri `
-AdministratorLogin $creds.UserName -AdministratorLoginPassword $creds.Password

# Check status of the export
$exportStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $exportRequest.OperationStatusLink
Write-Output "Azure SQL DB Export request submitted at $DatabaseName"
#}
#}
