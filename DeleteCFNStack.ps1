param(
    $region = "ap-southeast-2",
    $Environment
)


get-cfnstack -region $region | where {$_.stackname -like "*$Environment*"} | remove-cfnstack -region $region