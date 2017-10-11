param(
    $region = "ap-southeast-2",
    $Environment
)

Write-Verbose "Deleting CloudFormation Stack"
get-cfnstack -region $region | where {$_.stackname -like "*$Environment*"} | remove-cfnstack -region $region -Force