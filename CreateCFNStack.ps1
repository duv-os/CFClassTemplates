param (
    # Parameter help description
    [Parameter(Mandatory=$True)]
    [ValidateSet ("SharedInf", "AutoSubnet", "Bastion", "Private")]
    $Environment,
    [Parameter(Mandatory = $True)]
    $Region = "ap-southeast-2",
    [Parameter(Mandatory = $True)]
    $Class = "ITSE-1359-1001"
)
$roster = Get-Content "E:\GoogleDrive\Classes\ITSE1359-PowerShell\Attendance\roster-lower.txt"
$SharedInfTemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/CLASS-sharedinfrastructure.yaml"
$AutoSubnetTemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/autosubnet.yaml"
$PrivateDCTemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/StudentEnvPrivateDC.yaml"
$BastionTemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/StudentEnvPublic.yaml"


if ($Environment -eq "SharedInf") {
    New-CFNStack -StackName "$Class-SharedInf" -TemplateURL $SharedInfTemplateURL -Region $Region 
}

elseif ($Environment -eq "AutoSubnet") {
    Write-Verbose -Message "Getting Outputs from $Class-SharedInfStack"
    $url = get-cfnstack -Region ap-southeast-2 | Where-Object-Object-Object {$_.StackName -like "*$Class*"} | Select-Object -expand  outputs | Where {$_.OutputKey -eq "lambdabucket"}
    Copy-S3Object -BucketName "cf-templates-1pkm851dfqt55-ap-southeast-2" -Key autosubnet.zip -DestinationKey autosubnet.zip -DestinationBucket $url.OutputValue -Region $Region
    New-CFNStack -StackName "$Class-AutoSubnet" -TemplateURL $AutoSubnetTemplateURL -Region $Region -Capability CAPABILITY_IAM
}
elseif ($Environment -eq "Bastion") {
    foreach ($student in $roster) {
        write-Verbose "Creating Public CFN stack for $student"
        New-CFNStack -Stackname "$Class-$student-Bastion" -TemplateURL $BastionTemplateURL -Parameter @{ ParameterKey = "STUDENTNAME"; ParameterValue = "$student" } -Region $region
        Write-Verbose "Finished creating stack for $student"
        pause
    }
}
elseif ($Environment -eq "Private") {
    foreach ($student in $roster) {
        write-Verbose "Creating Private DC CFN stack for $student"
        New-CFNStack -Stackname "$Class-$student-PrivateServers" -TemplateURL $PrivateDCTemplateURL -Parameter @{ ParameterKey = "STUDENTNAME"; ParameterValue = "$student" } -Region $region
        Write-Verbose "Finished creating stack for $student"
        pause
    }
}
else {
    Write-Host "No environment to make!" -ForegroundColor Red
}