
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
