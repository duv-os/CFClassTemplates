param (
    # Parameter help description
    $Environment
)
$roster = Get-Content "E:\GoogleDrive\Classes\ITSE1359-PowerShell\Attendance\roster-lower.txt"
$Region = "ap-southeast-2"
$Class = "ITSE-1359-1001"
$SharedInfTemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/CLASS-sharedinfrastructure.yaml"
$AutoSubnetTemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/autosubnet.yaml"
$PrivateDCTemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/StudentEnvPrivateDC.yaml"
$BastionTemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/StudentEnvPublic.yaml"


if ($Environment -eq "SharedInf") {
    New-CFNStack -StackName "$Class-SharedInf" -TemplateURL $SharedInfTemplateURL 
}

elseif ($Environment -eq "AutoSubnet") {
    New-CFNStack -StackName "$Class-AutoSubnet" -TemplateURL $AutoSubnetTemplateURL
}
elseif ($Environment -eq "Bastion") {
    foreach ($student in $roster) {
        write-host "Creating Public CFN stack for $student"
        New-CFNStack -Stackname "$Class-$student-Bastion" -TemplateURL $BastionTemplateURL -Parameter @{ ParameterKey = "STUDENTNAME"; ParameterValue = "$student" } -Region $region
        Write-Host "Finished creating stack for $student"
        pause
    }
}
elseif ($Environment -eq "Private") {
    foreach ($student in $roster) {
        write-host "Creating Private DC CFN stack for $student"
        New-CFNStack -Stackname "$Class-$student-PrivateServers" -TemplateURL $PrivateDCTemplateURL -Parameter @{ ParameterKey = "STUDENTNAME"; ParameterValue = "$student" } -Region $region
        Write-Host "Finished creating stack for $student"
        pause
    }
}
else {
    Write-Host "No environment to make!" -ForegroundColor Red
}