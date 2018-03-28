#test
param (
    # Parameter help description
    [Parameter(Mandatory=$True)]
    [ValidateSet ("SharedInf", "AutoSubnet", "Bastion", "Private", "Lab11")]
    $Environment,

    [Parameter(Mandatory = $True)]
    [ValidateSet ("us-east-2", "us-east-1", "us-west-1", "us-west-2", "ca-central-1", "ap-south-1", "ap-northeast-2", "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "eu-central-1", "eu-west-1", "eu-west-2", "sa-east-1")]
    $Region = "ap-southeast-2",

    [Parameter(Mandatory = $True)]
    $Class = "ITSE-1359-1001",

    $studentname,

    $ClassRoster,

    [ValidateSet ("AMALINUX", "SERVER2016", "RH", "UBUNTU")]
    $ServerOS,

    [ValidateSet ("AMALINUX", "SERVER2016", "RH", "UBUNTU")]
    $ServerOS2
)

if ($ClassRoster) {
    $roster = Get-Content $ClassRoster
}
elseif ($studentname) {
    $roster = $studentname
}


$SharedInfTemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/CLASS-sharedinfrastructure.yaml"
$AutoSubnetTemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/autosubnet.yaml"
$PrivateDCTemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/StudentEnvPrivateDC.yaml"
$BastionTemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/StudentEnvPublic.yaml"
$Lab11TemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/Lab11.yaml"


if ($Environment -eq "SharedInf") {
    New-CFNStack -StackName "$Class-SharedInf" -TemplateURL $SharedInfTemplateURL -Region $Region 
}

elseif ($Environment -eq "AutoSubnet") {
    Write-Verbose -Message "Getting Outputs from $Class-SharedInfStack"
    $url = get-cfnstack -Region $Region | Where-Object {$_.StackName -like "*$Class*"} | Select-Object -expand  outputs | Where-Object {$_.OutputKey -eq "lambdabucket"}
    Write-Verbose -Message "Copying autosubnet.zip file to s3 bucket"
    Copy-S3Object -BucketName "cf-templates-1pkm851dfqt55-ap-southeast-2" -Key autosubnet.zip -DestinationKey autosubnet.zip -DestinationBucket $url.OutputValue -Region $Region
    Write-Verbose -Message "Creating AutoSubnet CFN Stack"
    New-CFNStack -StackName "$Class-AutoSubnet" -TemplateURL $AutoSubnetTemplateURL -Region $Region -Capability CAPABILITY_IAM
}
elseif ($Environment -eq "Bastion") {
    foreach ($student in $roster) {
        write-Verbose "Creating Public CFN stack for $student"
        New-CFNStack -Stackname "$Class-$student-$ServerOS-Bastion" -TemplateURL $BastionTemplateURL -Parameter @( @{ ParameterKey = "STUDENTNAME"; ParameterValue = "$student" }, @{ ParameterKey = "SERVEROS"; ParameterValue = "$ServerOS"}, @{ ParameterKey = "CLASS"; ParameterValue = "$class"}) -Region $region
        Write-Verbose "Finished creating stack for $student"
        pause
    }
}
elseif ($Environment -eq "Lab11") {
    foreach ($student in $roster) {
        write-Verbose "Creating Lab11 CFN stack for $student"
        New-CFNStack -Stackname "$Class-$student-Lab11" -TemplateURL $Lab11TemplateURL -Parameter @( @{ ParameterKey = "STUDENTNAME"; ParameterValue = "$student" }, @{ ParameterKey = "SERVEROS"; ParameterValue = "$ServerOS"}, @{ ParameterKey = "SERVEROS2"; ParameterValue = "$SERVEROS2"}, @{ ParameterKey = "CLASS"; ParameterValue = "$class"}) -Region $region
        Write-Verbose "Finished creating stack for $student"
        pause
    }
}
elseif ($Environment -eq "Private") {
    foreach ($student in $roster) {
        write-Verbose "Creating Private DC CFN stack for $student"
        New-CFNStack -Stackname "$Class-$student-PrivateServers" -TemplateURL $PrivateDCTemplateURL -Parameter @( @{ ParameterKey = "STUDENTNAME"; ParameterValue = "$student" }, @{ ParameterKey = "SERVEROS"; ParameterValue = "$ServerOS"}, @{ ParameterKey = "SERVEROS2"; ParameterValue = "$ServerOS2"}) -Region $region
        Write-Verbose "Finished creating stack for $student"
        pause
    }
}
else {
    Write-Host "No environment to make!" -ForegroundColor Red
}