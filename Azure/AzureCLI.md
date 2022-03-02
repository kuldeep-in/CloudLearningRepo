```
## Get and set subscription
$id = convertfrom-json (az account list --query "[?isDefault].id | [0]")
echo "##vso[task.setvariable variable=SubscriptionId]$id"

## Check if new deployment
$storageName= "$(uniqueString)" + 'storageqa'
$sa = az storage account check-name --name $storageName --query "nameAvailable "

echo "##vso[task.setvariable variable=createNewSA]$sa"
```
