$roster = Get-Content "E:\GoogleDrive\Classes\ITSE1359-PowerShell\Attendance\roster-lower.txt"
$Region = "ap-southeast-2"
$Class = "ITSE-1359-1001"

New-CFNStack -Stackname "TestingPSCFNStack" -TemplateURL "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/2017283GOL-StudentEnvPrivateDC.yaml" -Parameter @{ ParameterKey="STUDENTNAME"; ParameterValue="testuser" } -Region ap-southeast-2
