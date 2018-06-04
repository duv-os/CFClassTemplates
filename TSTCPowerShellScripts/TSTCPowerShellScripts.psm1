
#To have PowerShell automatically import this module and cmdlet put the folder
# in C:\Program Files\WindowsPowerShell\Modules
#Or else you can use Import-Module and specify the path to the module folder.
function New-TSTCStudent {
    <#
    .SYNOPSIS
        Creates a new IAM user and password
    .DESCRIPTION
        This cmdlet will create a new IAM user given a roster, setup their profile,
        set their password to P@ssw0rd1, and require the user to change their 
        password when they first login.
    .PARAMETER Roster
        One or more student names in a class roster
    .EXAMPLE
        New-TSTCStudent -Roster "Andy"
        This example will create a new IAM user called Andy
    .EXAMPLE
        New-TSTCStudent -Roster "Andy","Clint","Tonya"
        This example will create 3 new IAM users
    .EXAMPLE
        New-TSTCStudent -Roster (Get-Content C:\Temp\Roster.txt)
        This example will get a roster of student names from a txt file and create
        an IAM user account for each student
    .EXAMPLE
        "Andy","Clint" | New-TSTCStudent
        This example will create 2 new IAM user accounts
    .NOTES
        Version      : 1.0.0
        Last Updated : 12/20/2017
        Script created by Andy Kroll, Lead Instructor CDM Department - TSTC in Waco
    #>

    [cmdletbinding()]
    param(
        
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
        [Alias('Students', 'Name', 'Names')]
        [string[]]$Roster
    )

    BEGIN {
        #intentionally empty
    }

    PROCESS {
        
        #Create IAM Users, set password, require to change password at login
        foreach ($student in $roster) {
                
            try {
    
                Write-Verbose -Message "[TRY]    Creating IAM User called $student"
                $IamUser = New-IAMUser -UserName $student -ErrorAction Stop
                Start-Sleep -Seconds 6
    
                Write-Verbose -Message "[TRY]    Create New IAM Login Profile for $student"
                $loginprofile = New-IAMLoginProfile -UserName $student -Password P@ssw0rd1
                Start-Sleep -Seconds 15
    
                Write-Verbose -Message "[TRY]    Update IAM Login Profile to require password reset for $student"
                Update-IAMLoginProfile -UserName $student -Password P@ssw0rd1 -PasswordResetRequired $true
    
                Write-Verbose -Message "[TRY]    Outputting for $student"
                $properties = @{
                    'Username' = $IamUser.UserName
                    'Arn'      = $IamUser.Arn
                }
                $object = New-Object -TypeName psobject -Property $properties
                Write-Output $object
            } #try

            catch {
                Write-Verbose -Message "[CATCH]    $student already exists"
                $IamUserExists = get-iamuser -UserName $student
                $properties = @{
                    'Username' = $IamUserExists.UserName
                    'Arn'      = $IamUserExists.Arn
                }
                $object = New-Object -TypeName psobject -Property $properties
                Write-Output $object
            } #catch           
   
        } #foreach
        
    } #process

    END {
        #intentionally empty
    }
    
} #function

function New-TSTCStudentKeyPair {
    <#
    .SYNOPSIS
        Creates a new Key Pair for a student
    .DESCRIPTION
        This cmdlet will create a new Key Pair given a roster and then save the 
        Key Pair to a location you specify.
    .PARAMETER Roster
        One or more student names in a class roster.   This parameter is required.
    .PARAMETER Region
        One of the AWS Regions.  Use the AWS Region codes for the input.   This parameter is required.
    .PARAMETER Class
        The class and section (ITSE-1359-1001) this resource will be in.   This parameter is required.
    .PARAMETER Path
        Specifies the path to the Key Pair output file.  This parameter is required.
    .EXAMPLE
        New-TSTCStudentKeyPair -Roster "Andy" -Class ITSE-1359-1001 -Region us-west-2 -path C:\temp
        This example will create a new Key pair named ITSE-1359-1001-KP-Andy in the Oregon region
        and save the Pem file to C:\Temp\ITSE-1359-1001-KP-Andy.pem
    .EXAMPLE
        New-TSTCStudent -verbose -Roster "andytest","Clinttest","tonyatest" | New-TSTCStudentKeyPair -Region us-west-2 -Class ITSE-1359-1001 -Path c:\temp -verbose
        This example will create 3 new IAM users and will then create their key pairs
        in the specified class and region.  Verbose output is also included.
    .EXAMPLE
        New-TSTCStudent -verbose -Roster (Get-Content "C:\GoogleDrive\Classes\ITSC1316-Linux\Attendance\1002\Roster.txt")  | New-TSTCStudentKeyPair -Region us-east-2 -Class ITSC-1316-1002 -Path C:\GoogleDrive\Classes\ITSC1316-Linux\KeyPairs\1002 -verbose
        This will import a class roster from a txt file, create the students iam accounts and set their passwords and then 
        pipe the users to New-TSTCStudentKeyPair and you will provide the region, class & Section, and path to store key pairs.
    .EXAMPLE
        New-TSTCStudentKeyPair -Class ITSC-1316-1001 -Region us-west-1 -Roster (Get-Content "E:\GoogleDrive\Classes\ITSC1316-Linux\Attendance\1001\Roster.txt") -Path E:\GoogleDrive\Classes\ITSC1316-Linux\KeyPairs\1001
        This will only make new Key Pairs.  You supply the class roster and give it a local path to save the Key Pairs to
        and it will make the student's key pairs in the region you specify.
    .NOTES
        Version      : 1.0.0
        Last Updated : 1/2/2018
        Script created by Andy Kroll, Lead Instructor CDM Department - TSTC in Waco
    #>
    [cmdletbinding()]
    param(
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [ValidateSet ("us-east-2", "us-east-1", "us-west-1", "us-west-2", "ca-central-1", "ap-south-1", "ap-northeast-2", "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "eu-central-1", "eu-west-1", "eu-west-2", "sa-east-1")]
        $Region,
        
        # Parameter help description
        [Parameter(Mandatory = $true)]
        $Class,

        # Parameter help description
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
        [Alias('Students', 'Name', 'Names', 'UserName')]
        [string[]]$Roster,

        # Parameter help description
        [Parameter(Mandatory = $true)]
        $Path
    )    

    
    BEGIN {
        #intentionally empty
    }
    
    PROCESS {
        foreach ($student in $roster) {
            Write-Verbose -message  "[FOREACH LOOP]    Creating Key Pair for $student"
            (New-EC2KeyPair -Region $Region -KeyName "$Class-KP-$student").KeyMaterial | out-file -Encoding ascii $Path\$Class-KP-$student.pem
            Write-Verbose -Message "[FOREACH LOOP]    Key Pair created for $student and saved at $Path\$Class-KP-$student.pem "
        } #foreach

        
    }
    
    END {
        #intentionally empty
    }
}

function Remove-TSTCStudentKeyPair {
    <#
    .SYNOPSIS
        Removes a new Key Pair for a student
    .DESCRIPTION
        This cmdlet will Remove a Key Pair given a roster
    .PARAMETER Roster
        One or more student names in a class roster.   This parameter is required.
    .PARAMETER Region
        One of the AWS Regions.  Use the AWS Region codes for the input.   This parameter is required.
    .PARAMETER Class
        The class and section (ITSE-1359-1001) this resource will be in.   This parameter is required.
    .EXAMPLE
        Remove-TSTCStudentKeyPair -Region us-west-2 -Class ITSE-1359-1001 -Roster "Clinttest","tonyatest" -Verbose
        This example will remove the key pairs from the Oregon region for the users in the roster and 
        will also provide verbose output
    .NOTES
        Version      : 1.0.0
        Last Updated : 1/2/2018
        Script created by Andy Kroll, Lead Instructor CDM Department - TSTC in Waco
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet ("us-east-2", "us-east-1", "us-west-1", "us-west-2", "ca-central-1", "ap-south-1", "ap-northeast-2", "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "eu-central-1", "eu-west-1", "eu-west-2", "sa-east-1")]
        $Region,
        
        # Parameter help description
        [Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
        $Class,

        # Parameter help description
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
        [Alias('Students', 'Name', 'Names', 'UserName')]
        [string[]]$Roster
    )
    BEGIN {
        #intnetionally blank
    }

    PROCESS {
        foreach ($student in $Roster) {

            Write-Verbose -Message "[FOREACH]    About to run Get-Ec2KeyPair"
            $KPCheck = Get-EC2KeyPair -Region $Region -KeyName "$Class-KP-$student" -ErrorAction SilentlyContinue
            Write-Verbose -Message "[FOREACH]    Finished running Get-Ec2KeyPair"

            if (-Not $KPCheck) {
                Write-Verbose -Message "[IF]    Key Pair $Class-KP-$student does not exist"
            }
            else {   
                Write-Verbose -Message "[ELSE]    Removing $student Key Pair in $Region"
                Remove-EC2KeyPair -Region $Region -KeyName "$Class-KP-$student"
                Write-Verbose -Message "[ELSE]    Key Pair for $student removed" 
            }
        }
    }

    END {
        #intentionally blank
    }
}

function Import-TSTCClassRoster {
    [cmdletbinding()]
    param(
        # Enter the path to a txt file that contains user names for the class
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
        [Alias('Students', 'Name', 'Names', 'UserName', 'Path')]
        [string[]]$Roster
    )

    $CSV = Import-CSV $roster

    #Loop through each row of the csv file, create variables for lowercase names, and save the results to a second csv file that contains lowercase usernames
    foreach ($row in $csv) {
        $FirstName = $row.'Name'.split(" ")[0]
        $LastName = $row.'Name'.split(" ")[1]
        $Username = $FirstName.substring(0, 1) + $lastname
        $UsernameLower = $Username.ToLower()

        $UsernameLower | Add-Content $outfile
    }
}

function New-TSTCCFNStack {
    <#
    .SYNOPSIS
        Creates a CloudFormation stack for student lab environments
    .DESCRIPTION
        This cmdlet will launch CloudFormation stacks to create lab environments
        for students.

        NOTE: As of now, the AutoSubnet stack has issues creating so you will need to manually
        copy the autosubnet.zip file into the bucket the SharedInf stack creates.  You can look 
        at the Outputs section of the SharedInf stack to see the bucket it created.
    .PARAMETER Roster
        One or more student names in a class roster.   This parameter is required.
    .PARAMETER Region
        One of the AWS Regions.  Use the AWS Region codes for the input.   This parameter is required.
    .PARAMETER ClassRoster
        The class and section (ITSE-1359-1001) this resource will be in.   This parameter is optional.
    .PARAMETER Studentname
        The username of a student.  This will deploy just one stack for the specified student instead of
        deploying the stack for the entire class.  This parameter is optional.  Use either the ClassRoster
        parameter or the Studentname parameter.
    .PARAMETER Environment
        One of the CloudFormation environments you want to build.  Available options are SharedInf, AutoSubnet,
        Bastion, Private.  Note: You must have a SharedInf stack before you can create an AutoSubnet stack and
        you must have both of those before you can launch a Bastion or Private server stack.  The valid values
        for this parameter are SharedInf, AutoSubnet, Bastion, Private, Lab5
        This parameter is required.
    .PARAMETER ServerOS
        The OS of the server you want to deploy.  Availalbe options are AMALINUX, SERVER2016, RH.  AMALINUX will deploy
        Amazon Linux, SERVER2016 will deploy Windows Server 2016, RH will deploy Red Hat.
    .EXAMPLE
        New-TSTCCFNStack -Region ap-southeast-2 -Class ITSC-1316-1001 -Environment SharedInf
        This example will create  a new CloudFormation stack in the Sydney region using the SharedInf template.  This 
        will create the infrastructure for the rest of the class to be deployed in.
    .EXAMPLE
        New-TSTCCFNStack -Region us-west-2 -Environment bastion -Class ITSE-1359-1001 -ServerOS AMALINUX -ClassRoster "G:\My Drive\Classes\ITSE1359-PowerShell\Attendance\Roster.txt"
        This example will create new CloudFormation stacks in the Oregon region.  Note that the class roster text file
        should have the student names as first initial last name (ex: akroll) and the key pairs should already exist.
        Use this example if you need to build the entire class's cloud formation templates.
    .EXAMPLE
        New-TSTCCFNStack -Region us-west-2 -Environment bastion -Class ITSE-1359-1001 -ServerOS AMALINUX -studentname akroll
        This is the same as example #2 except this is how you can create just a single stack for one student instead
        of the entire class.
    .EXAMPLE
        New-TSTCCFNStack -Region us-west-2 -Environment Lab5 -Class ITSE-1359-1001 -ServerOS AMALINUX -studentname akroll
        This will launch the Lab5 environment for the student akroll.
    .EXAMPLE
        New-TSTCCFNStack -Region us-west-2 -Environment Lab5 -Class ITSE-1359-1001 -ServerOS AMALINUX -ClassRoster "G:\My Drive\Classes\ITSE1359-PowerShell\Attendance\Roster.txt"
        This will launch the Lab5 environment for all students in the class
    .NOTES
        Version      : 1.0.0
        Last Updated : 6/4/2018
        Script created by Andy Kroll, Lead Instructor CDM Department - TSTC in Waco
    #>
    [cmdletbinding()]
    param(
        # Parameter help description
        [Parameter(Mandatory = $True)]
        [ValidateSet ("SharedInf", "AutoSubnet", "Bastion", "Private", "Lab5")]
        $Environment,

        [Parameter(Mandatory = $True)]
        [ValidateSet ("us-east-2", "us-east-1", "us-west-1", "us-west-2", "ca-central-1", "ap-south-1", "ap-northeast-2", "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "eu-central-1", "eu-west-1", "eu-west-2", "sa-east-1")]
        $Region = "ap-southeast-2",

        [Parameter(Mandatory = $True)]
        $Class = "ITSE-1359-1001",

        $studentname,

        $ClassRoster,

        $ServerSize = "DEV", #This parameter maps to the ENVIRONMENT parameter in the StudentEnvPublic.yaml CloudFormation template.  DEV is a t2.micro PROD is a t2.medium

        [ValidateSet ("AMALINUX", "SERVER2016", "RH")]
        $ServerOS
    )    

    
    BEGIN {

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
        $Lab5TemplateURL = "https://s3-ap-southeast-2.amazonaws.com/cf-templates-1pkm851dfqt55-ap-southeast-2/Lab5.yaml"
    }
    
    PROCESS {

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
                New-CFNStack -Stackname "$Class-$student-$ServerOS-Bastion" -TemplateURL $BastionTemplateURL -Parameter @( @{ ParameterKey = "STUDENTNAME"; ParameterValue = "$student" }, @{ ParameterKey = "SERVEROS"; ParameterValue = "$ServerOS"}, @{ ParameterKey = "CLASS"; ParameterValue = "$class"}, @{ ParameterKey = "ENVIRONMENT"; ParameterValue = "$serversize"}) -Region $region
                Write-Verbose "Finished creating stack for $student"
                pause
            }
        }
        elseif ($Environment -eq "Lab5") {
            foreach ($student in $roster) {
                write-Verbose "Creating Lab5 CFN stack for $student"
                New-CFNStack -Stackname "$Class-$student-$ServerOS-Lab5" -TemplateURL $Lab5TemplateURL -Parameter @( @{ ParameterKey = "STUDENTNAME"; ParameterValue = "$student" }, @{ ParameterKey = "SERVEROS"; ParameterValue = "$ServerOS"}, @{ ParameterKey = "CLASS"; ParameterValue = "$class"}, @{ ParameterKey = "ENVIRONMENT"; ParameterValue = "$serversize"}) -Region $region
                Write-Verbose "Finished creating stack for $student"
                pause
            }
        }
        elseif ($Environment -eq "Private") {
            foreach ($student in $roster) {
                write-Verbose "Creating Private DC CFN stack for $student"
                New-CFNStack -Stackname "$Class-$student-PrivateServers" -TemplateURL $PrivateDCTemplateURL -Parameter @( @{ ParameterKey = "STUDENTNAME"; ParameterValue = "$student" }, @{ ParameterKey = "SERVEROS"; ParameterValue = "$ServerOS"}) -Region $region
                Write-Verbose "Finished creating stack for $student"
                pause
            }
        }
        else {
            Write-Host "No environment to make!" -ForegroundColor Red
        }

    }
    
    END {
        #intentionally empty
    }
}

function Remove-TSTCCFNStack {
    <#
    .SYNOPSIS
        Removes/Deletes a CloudFormation stack for student lab environments
    .DESCRIPTION
        This cmdlet will delete a CloudFormation stack used to make lab environments for students.
    .PARAMETER Region
        One of the AWS Regions.  Use the AWS Region codes for the input.   This parameter is required.
    .PARAMETER Environment
        One of the CloudFormation environments previously built.  Available options are SharedInf, AutoSubnet,
        Bastion, Private.  This parameter is required.
    .EXAMPLE
        Remove-TSTCCFNStack -region ap-southeast-2 -Environment SharedInf
        This example will Remove the SharedInf CloudFormation stack in the Sydney region
    .EXAMPLE
        .EXAMPLE
        Remove-TSTCCFNStack -region ap-southeast-2 -Environment AutoSubnet
        This example will Remove the AutoSubnet CloudFormation stack in the Sydney region
    .NOTES
        Version      : 1.0.0
        Last Updated : 1/2/2018
        Script created by Andy Kroll, Lead Instructor CDM Department - TSTC in Waco
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $True)]
        [ValidateSet ("us-east-2", "us-east-1", "us-west-1", "us-west-2", "ca-central-1", "ap-south-1", "ap-northeast-2", "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "eu-central-1", "eu-west-1", "eu-west-2", "sa-east-1")]
        $region = "ap-southeast-2",
    
        [Parameter(Mandatory = $True)]
        [ValidateSet ("SharedInf", "AutoSubnet", "Bastion", "Private")]
        $Environment
    )    

    
    BEGIN {
        #Intentionally blank
    }
    
    PROCESS {

        if ($Environment -eq "SharedInf") {
            $bucket = get-cfnstack -Region $region | where {$_.StackName -like "*$Environment*"} | select -expand  outputs | Where {$_.OutputKey -eq "lambdabucket"}
            Remove-S3Bucket -BucketName $bucket.OutputValue -deletebucketcontent -Force -Region $region
            get-cfnstack -region $region | where {$_.stackname -like "*$Environment*"} | remove-cfnstack -region $region -Force
        }
        else {
            Write-Verbose "Deleting CloudFormation Stack"
            get-cfnstack -region $region | where {$_.stackname -like "*$Environment*"} | remove-cfnstack -region $region -Force
        }

    }
    
    END {
        #intentionally empty
    }
}