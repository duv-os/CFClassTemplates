
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