param(
    [Parameter(Mandatory=$True)]
    [ValidateSet ("us-east-2", "us-east-1", "us-west-1", "us-west-2", "ca-central-1", "ap-south-1", "ap-northeast-2", "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "eu-central-1", "eu-west-1", "eu-west-2", "sa-east-1")]
    $region = "ap-southeast-2",
    [Parameter(Mandatory=$True)]
    [ValidateSet ("SharedInf","AutoSubnet","Bastion","Private")]
    $Environment
)

if ($Environment -eq "SharedInf") {
    $bucket = get-cfnstack -Region $region | where {$_.StackName -like "*$Environment*"} | select -expand  outputs | Where {$_.OutputKey -eq "lambdabucket"}
    Remove-S3Bucket -BucketName $bucket.OutputValue -deletebucketcontent -Force -Region $region
    get-cfnstack -region $region | where {$_.stackname -like "*$Environment*"} | remove-cfnstack -region $region -Force
}
else {
    Write-Verbose "Deleting CloudFormation Stack"
    get-cfnstack -region $region | where {$_.stackname -like "*$Environment*"} | remove-cfnstack -region $region -Force
    }