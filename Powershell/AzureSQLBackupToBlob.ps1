
param(
    [parameter(Mandatory=$true)]
	[String] $ResourceGroupName = "",
    [parameter(Mandatory=$true)]
	[String] $DatabaseServerName = "",
    [parameter(Mandatory=$true)]
    [String]$DatabaseAdminUsername,
	[parameter(Mandatory=$true)]
    [String]$DatabaseAdminPassword,
	[parameter(Mandatory=$true)]
    [String]$DatabaseNames,
    [parameter(Mandatory=$true)]
    [String]$StorageAccountName,
    [parameter(Mandatory=$true)]
    [String]$BlobStorageEndpoint,
    [parameter(Mandatory=$true)]
    [String]$StorageKey,
	[parameter(Mandatory=$true)]
    [string]$BlobContainerName,
	[parameter(Mandatory=$true)]
    [Int32]$RetentionDays
)

$ResourceGroupName = ""
$DatabaseServerName = ""
$DatabaseAdminUsername = ""
$DatabaseAdminPassword = ""
$DatabaseNames = ""
$StorageAccountName = ""
$BlobStorageEndpoint = ""
$StorageKey = ""
$BlobContainerName = ""
$RetentionDays = 10

$ErrorActionPreference = 'stop'

function Login() {
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
}

function Create-Blob-Container([string]$blobContainerName, $storageContext) {
	Write-Verbose "Checking if blob container '$blobContainerName' already exists" -Verbose
	if (Get-AzureStorageContainer -ErrorAction "Stop" -Context $storageContext | Where-Object { $_.Name -eq $blobContainerName }) {
		Write-Verbose "Container '$blobContainerName' already exists" -Verbose
	} else {
		New-AzureStorageContainer -ErrorAction "Stop" -Name $blobContainerName -Permission Off -Context $storageContext
		Write-Verbose "Container '$blobContainerName' created" -Verbose
	}
}

function Export-To-Blob-Storage([string]$resourceGroupName, [string]$databaseServerName, [string]$databaseAdminUsername, [string]$databaseAdminPassword, [string[]]$databaseNames, [string]$storageKey, [string]$blobStorageEndpoint, [string]$blobContainerName) {
	Write-Verbose "Starting database export to databases '$databaseNames'" -Verbose
	$securePassword = ConvertTo-SecureString �String $databaseAdminPassword �AsPlainText -Force 
	$creds = New-Object �TypeName System.Management.Automation.PSCredential �ArgumentList $databaseAdminUsername, $securePassword

	foreach ($databaseName in $databaseNames.Split(",").Trim()) {
		Write-Output "Creating request to backup database '$databaseName'"

		$bacpacFilename = $databaseName + (Get-Date).ToString("yyyyMMddHHmm") + ".bacpac"
		$bacpacUri = $blobStorageEndpoint + $blobContainerName + "/" + $bacpacFilename

		$exportRequest = New-AzureRmSqlDatabaseExport -ResourceGroupName $resourceGroupName �ServerName $databaseServerName `
			�DatabaseName $databaseName �StorageKeytype "StorageAccessKey" �storageKey $storageKey -StorageUri $BacpacUri `
			�AdministratorLogin $creds.UserName �AdministratorLoginPassword $creds.Password -ErrorAction "Stop"
		
		# Print status of the export
		Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $exportRequest.OperationStatusLink -ErrorAction "Stop"
	}
}

function Delete-Old-Backups([int]$retentionDays, [string]$blobContainerName, $storageContext) {
	Write-Output "Removing backups older than '$retentionDays' days from blob: '$blobContainerName'"
	$isOldDate = [DateTime]::UtcNow.AddDays(-$retentionDays)
	$blobs = Get-AzureStorageBlob -Container $blobContainerName -Context $storageContext
	foreach ($blob in ($blobs | Where-Object { $_.LastModified.UtcDateTime -lt $isOldDate -and $_.BlobType -eq "BlockBlob" })) {
		Write-Verbose ("Removing blob: " + $blob.Name) -Verbose
		Remove-AzureStorageBlob -Blob $blob.Name -Container $blobContainerName -Context $storageContext
	}
}

Write-Verbose "Starting database backup" -Verbose

$StorageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey

Login

Create-Blob-Container `
	-blobContainerName $blobContainerName `
	-storageContext $storageContext
	
Export-To-Blob-Storage `
	-resourceGroupName $ResourceGroupName `
	-databaseServerName $DatabaseServerName `
	-databaseAdminUsername $DatabaseAdminUsername `
	-databaseAdminPassword $DatabaseAdminPassword `
	-databaseNames $DatabaseNames `
	-storageKey $StorageKey `
	-blobStorageEndpoint $BlobStorageEndpoint `
	-blobContainerName $BlobContainerName
	
Delete-Old-Backups `
	-retentionDays $RetentionDays `
	-storageContext $StorageContext `
	-blobContainerName $BlobContainerName
	
Write-Verbose "Database backup script finished" -Verbose

