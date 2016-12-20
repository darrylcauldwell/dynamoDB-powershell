<#
Run in Powershell session before running script

Import-Module AWSPowershell
Set-AWSCredentials -AccessKey <my-access-key> -SecretKey <my-access-key-secret> -StoreAs DynamoDB
Initialize-AWSDefaults -ProfileName DynamoDB -Region eu-west-1

#>

#create test database table
$dbExist = Get-DDBTable -TableName "myExample"
If ($dbExist -eq $null){
      $exampleSchema = New-DDBTableSchema | Add-DDBKeySchema -KeyName "Name" -KeyDataType "S"
      $exampleTable = New-DDBTable "myExample" -Schema $exampleSchema -ReadCapacity 5 -WriteCapacity 5
}

#create database connection
Add-Type -Path (${env:ProgramFiles(x86)}+"\AWS SDK for .NET\bin\Net45\AWSSDK.DynamoDBv2.dll")
$regionName = 'eu-west-1'
$regionEndpoint=[Amazon.RegionEndPoint]::GetBySystemName($regionName)
$dbClient = New-Object Amazon.DynamoDBv2.AmazonDynamoDBClient($regionEndpoint)

function putDDBItem{
      param (
            [string]$tableName,
            [string]$key,
            [string]$val,
            [string]$key1,
            [string]$val1
            )
      $req = New-Object Amazon.DynamoDBv2.Model.PutItemRequest
      $req.TableName = $tableName
      $req.Item = New-Object 'system.collections.generic.dictionary[string,Amazon.DynamoDBv2.Model.AttributeValue]'
      $valObj = New-Object Amazon.DynamoDBv2.Model.AttributeValue
      $valObj.S = $val
      $req.Item.Add($key, $valObj)
      $val1Obj = New-Object Amazon.DynamoDBv2.Model.AttributeValue
      $val1Obj.S = $val1
      $req.Item.Add($key1, $val1Obj)
      $output = $dbClient.PutItem($req)
      }

function getDDBItem{
        param (
                [string]$tableName,
                [string]$key,
                [string]$keyAttrStr
                )
    $req = New-Object Amazon.DynamoDBv2.Model.GetItemRequest
    $req.TableName = $tableName
    $req.Key = New-Object 'system.collections.generic.dictionary[string,Amazon.DynamoDBv2.Model.AttributeValue]'
    $keyAttrObj = New-Object Amazon.DynamoDBv2.Model.AttributeValue
    $keyAttrObj.S = $keyAttrStr
    $req.Key.Add($key, $keyAttrObj.S)
    $script:resp = $dbClient.GetItem($req)
    }

putDDBItem -tableName 'myExample' -key 'Name' -val 'Bob' -key1 'Age' -val1 '21'
putDDBItem -tableName 'myExample' -key 'Name' -val 'Bert' -key1 'Age' -val1 '22'
putDDBItem -tableName 'myExample' -key 'Name' -val 'Sid' -key1 'Age' -val1 '23'

getDDBItem -tableName 'myExample' -key 'Name' -keyAttrStr 'Bob'

Write-Host 'Hugh is' $script:resp.Item.'Age'.S
$script:resp = $null