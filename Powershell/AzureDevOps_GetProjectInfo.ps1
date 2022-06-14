$org="https://dev.azure.com/"
$orgname=""
$key=""

$lstProjetos = New-Object System.Collections.ArrayList
$lstGrupos = New-Object System.Collections.ArrayList
$lstMembros = New-Object System.Collections.ArrayList
$lstGruposOrg = New-Object System.Collections.ArrayList
$lstMembrosGruposOrg = New-Object System.Collections.ArrayList

echo $key | az devops login --org $org

#List all projects in the organization
$allProjects= az devops project list --org $org | ConvertFrom-Json

#List Organization Permission Groups
$orgGroups = az devops security group list --org $org --scope organization --query "graphGroups[?contains(@.principalName, '$orgname')]" | ConvertFrom-Json
foreach($orgGroup in $orgGroups){
  write-host "Grupos da Organizacao: " $orgGroup.displayName
  $og = New-Object System.Object
  $og | Add-Member -MemberType NoteProperty -Name "GroupName" -Value $orgGroup.displayName
  $og | Add-Member -MemberType NoteProperty -Name "Descriptor" -Value $orgGroup.descriptor
  $lstGruposOrg.Add($og) | Out-Null

  #List Permission Group Members
  $orgGroupsMembers=az devops security group membership list --org $org --id $orgGroup.descriptor --relationship members | ConvertFrom-Json
  [array]$orgGroups = ($orgGroupsMembers | Get-Member -MemberType NoteProperty).Name
    foreach($gpmember in $orgGroups){
      write-host "    Membro do Grupo: " $orgGroupsMembers.$gpmember.displayName
      $ogm = New-Object System.Object
      $ogm | Add-Member -MemberType NoteProperty -Name "GroupName" -Value $orgGroup.displayName
      $ogm | Add-Member -MemberType NoteProperty -Name "Description" -Value $orgGroupsMembers.$gpmember.description 
      $ogm | Add-Member -MemberType NoteProperty -Name "GroupMembers" -Value $orgGroupsMembers.$gpmember.displayName
      $lstMembrosGruposOrg.Add($ogm) | Out-Null       
    }
}


foreach($proj in $allProjects.value){
  write-host "Nome do projeto: " $proj.name
  $p = New-Object System.Object
  $p | Add-Member -MemberType NoteProperty -Name "ProjectName" -Value $proj.name
  $p | Add-Member -MemberType NoteProperty -Name "ProjectId" -Value $proj.id
  $lstProjetos.Add($p) | Out-Null

  #List Permission Groups for a Project
  $ProjectsGroup=az devops security group list --org $org --scope project --project $proj.Name | ConvertFrom-Json
  foreach($group in $ProjectsGroup.graphGroups){
    write-host "  Nome do grupo: " $group.displayName 
    $g = New-Object System.Object
    $g | Add-Member -MemberType NoteProperty -Name "GroupName" -Value $group.displayName 
    $g | Add-Member -MemberType NoteProperty -Name "Description" -Value $group.description
    $g | Add-Member -MemberType NoteProperty -Name "GroupId" -Value $group.descriptor
    $g | Add-Member -MemberType NoteProperty -Name "PrincipalName" -Value $group.principalName
    $g | Add-Member -MemberType NoteProperty -Name "ProjectId" -Value $proj.id
    $lstGrupos.Add($g) | Out-Null

    #List Permission Group Members
    $GroupsMembers=az devops security group membership list --org $org --id $group.descriptor --relationship members | ConvertFrom-Json
    [array]$groups = ($GroupsMembers | Get-Member -MemberType NoteProperty).Name
      foreach($member in $groups){
        write-host "    Nome do usuario: " $GroupsMembers.$member.displayName
        $m = New-Object System.Object
        $m | Add-Member -MemberType NoteProperty -Name "GroupName" -Value $group.displayName
        $m | Add-Member -MemberType NoteProperty -Name "Description" -Value $GroupsMembers.$member.description
        $m | Add-Member -MemberType NoteProperty -Name "GroupMembers" -Value $GroupsMembers.$member.displayName
        $m | Add-Member -MemberType NoteProperty -Name "GroupId" -Value $GroupsMembers.$member.descriptor
        $lstMembros.Add($m) | Out-Null
      }
  }
}

$lstProjetos | Select-Object | Export-Csv -Path ".\Projetos.csv" -Delimiter ";" -NoTypeInformation
$lstGrupos | Select-Object | Export-Csv -Path ".\Grupos.csv" -Delimiter ";" -NoTypeInformation
$lstMembros | Select-Object | Export-Csv -Path ".\MembrosGrupos.csv" -Delimiter ";" -NoTypeInformation
$lstGruposOrg | Select-Object | Export-Csv -Path ".\GruposOrg.csv" -Delimiter ";" -NoTypeInformation
$lstMembrosGruposOrg | Select-Object | Export-Csv -Path ".\MembrosGruposOrg.csv" -Delimiter ";" -NoTypeInformation
