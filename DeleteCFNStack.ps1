param(
    [Parameter(Mandatory=$True)]
    $region = "ap-southeast-2",
    [Parameter(Mandatory=$True)]
    [ValidateSet ("SharedInf","AutoSubnet","Bastion","Private")]
    $Environment
)

if ($Environment -eq "SharedInf") {
    $bucket = get-cfnstack -Region $region | where {$_.StackName -like "*$Environment*"} | select -expand  outputs | Where {$_.OutputKey -eq "lambdabucket"}
    Remove-S3Bucket -BucketName $bucket.OutputValue -deletebucketcontent -Force
    get-cfnstack -region $region | where {$_.stackname -like "*$Environment*"} | remove-cfnstack -region $region -Force
}
else {
    Write-Verbose "Deleting CloudFormation Stack"
    get-cfnstack -region $region | where {$_.stackname -like "*$Environment*"} | remove-cfnstack -region $region -Force
    }