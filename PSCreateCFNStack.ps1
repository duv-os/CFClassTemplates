$roster = Get-Content "E:\GoogleDrive\Classes\ITSE1359-PowerShell\Attendance\roster-lower.txt"
$Region = "ap-southeast-2"
$Class = "ITSE-1359-1001"
$PrivateDCTemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/2017283GOL-StudentEnvPrivateDC.yaml"
$PublicTemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/2017283pun-StudentEnvPublic.yaml"

param(
    # Parameter help description
    [String]
    $Environment
)

foreach ($student in $roster)
{
    if ($Environment -eq "Public") {
        
        write-host "Creating Public CFN stack for $student"
        New-CFNStack -Stackname "$Class-$student-Public" -TemplateURL $PublicTemplateURL -Parameter @{ ParameterKey="STUDENTNAME"; ParameterValue="$student" } -Region $region
        Write-Host "Finished creating stack for $student"
        pause
    }

    elseif ($Environment -eq "DC") {
        
        write-host "Creating Private DC CFN stack for $student"
        New-CFNStack -Stackname "$Class-$student-PrivateDC" -TemplateURL $PrivateDCTemplateURL -Parameter @{ ParameterKey="STUDENTNAME"; ParameterValue="$student" } -Region $region
        Write-Host "Finished creating stack for $student"
        pause
    }

    }    
