
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
        Script created by Andy Kroll, Lead Instructor CDM
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