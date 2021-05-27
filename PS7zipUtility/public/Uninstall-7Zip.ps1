<#
.SYNOPSIS
    Function that uninstalls 7-Zip if it exist on the $ComputerName given.
.DESCRIPTION
    Takes the [String]$ComputerName and runs a series of commands to connect to the device via PSSession. It will then uninstall 7Zip if it finds it installed. 
.PARAMETER ComputerName
    An Alpha-Numric [String] that is provided by the user.
.OUTPUTS 
    <N/A>    
.NOTES
  Version:        1.0
  Author:         Matthew Smith
  Creation Date:  05/25/2021
  Purpose/Change: Interview pre-requisite for QuestionMark
.EXAMPLE
  Uninstall-7Zip -ComputerName $Computer 
#>

#Preferences
$ErrorActionPreference = "Stop"

Function Uninstall-7Zip {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$ComputerName
    )

    #Function Logic
    Try {
        #Uninstall Previous Versions
        $Session = New-PSSession -ComputerName $ComputerName
        Invoke-Command -Session $Session -ScriptBlock { 
            $apps = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Select-Object -Property DisplayName, UninstallString, QuietUninstallString | Where-Object { $_.DisplayName -like "*7-Zip*" }
            if ($null -ne $apps.UninstallString -and $apps.UninstallString -like "*.msi*" -or $apps.uninstallstring -like "*MsiExec.exe*") {
                $UninstallString = $(($apps.uninstallstring | Select-String -Pattern "\{.*\}" -AllMatches).matches.value)
                Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $($UninstallString) /QN REBOOT=ReallySuppress" -Wait -NoNewWindow
            } elseif ($null -ne $apps.UninstallString -and $apps.UninstallString -like "*.exe*" -and $apps.uninstallstring -ne "MsiExec.exe") {
                $UninstallString = "$($apps.UninstallString)"
                Start-Process -FilePath $UninstallString -ArgumentList "/S" -Wait -NoNewWindow
            } else {
                Write-Host "Cannot find previous installs of 7-Zip...attempting install. "
            }
        }
        #Remove Session
        Get-PSSession -ComputerName $ComputerName | Remove-PSSession
    } Catch [System.Management.Automation.ItemNotFoundException] {
        #General exception
        Write-Host "General Error: Unable to uninstall 7Zip from: $($ComputerName)"
    } Catch {
        #Output exception message from where error occured
        $PSItem.Exception.Message
    } Finally {
        #Clear errors
        $Error.Clear() 
        #Make sure all pssessions are terminated
        Get-PSSession | Remove-PSSession 
    }
}