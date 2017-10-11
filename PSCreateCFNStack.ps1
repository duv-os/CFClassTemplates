param (
    # Parameter help description
    $Environment
)
$roster = Get-Content "C:\temp\roster-lower.txt"
$Region = "ap-southeast-2"
$Class = "ITSE-1359-1001"
$PrivateDCTemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/2017284IB9-StudentEnvPrivateDC.yaml"
$PublicTemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/2017283GiX-StudentEnvPublic.yaml"


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
