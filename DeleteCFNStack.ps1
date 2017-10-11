param(
    $region = "ap-southeast-2",
    $Environment
)

if ($Environment -eq "SharedInf") {
    $bucket = get-cfnstack -Region $region | where {$_.StackName -like "*$Environment*"} | select -expand  outputs | Where {$_.OutputKey -eq "lambdabucket"}
    Remove-S3Bucket -BucketName $bucket.OutputValue -deletebucketcontent
    get-cfnstack -region $region | where {$_.stackname -like "*$Environment*"} | remove-cfnstack -region $region -Force
}
else {
    Write-Verbose "Deleting CloudFormation Stack"
    get-cfnstack -region $region | where {$_.stackname -like "*$Environment*"} | remove-cfnstack -region $region -Force
    }