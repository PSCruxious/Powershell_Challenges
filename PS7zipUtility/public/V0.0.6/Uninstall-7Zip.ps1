<#
.SYNOPSIS
    Function that uninstalls 7-Zip if it exist on the $ComputerName given.
.DESCRIPTION
    Takes the [String]$ComputerName and runs a series of commands to connect to the device via PSSession. It will then uninstall 7Zip if it finds it installed.
    It will also remove any artifacts if it finds them both filesystem or registry based 
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
                    
        #Send script block to $ComputerName PSSession
        Invoke-Command -Session $Session -ScriptBlock { 
            
            #Define possible running applications from $Application
            $7zApps = @("7zFM", "7zG", "7z")

            #Define specific application
            $Application = "7-Zip"

            #Registry Locations
            $RegistryLocs = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*')

            #Get registry data for $Application
            $apps = $RegistryLocs | ForEach-Object { Get-ItemProperty -Path $_ | Where-Object { $_.DisplayName -like "*$($Application)*" } | Select-Object -Property PSDrive, PSPath, DisplayName, DisplayIcon, InstallLocation, UninstallString }
            

            #Stop all 7Zip Applications 
            Get-Process | Where-Object { $7zApps -contains $_.Name } | ForEach-Object {
                Stop-Process -Id $_.Id -Force | Out-Null
            }
                    
            #region MSI
            if ($null -ne $apps.UninstallString -and $apps.UninstallString -like "*.msi*" -or $apps.uninstallstring -like "*MsiExec.exe*") {

                #Get UninstallString from $apps
                $UninstallString = $(($apps.uninstallstring | Select-String -Pattern "\{.*\}" -AllMatches).matches.value)

                #Begin Uninstall 
                Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $($UninstallString) /QN REBOOT=ReallySuppress" -Wait -NoNewWindow

                #Return Artifacts in Registry 
                $RegArtifacts = $RegistryLocs | ForEach-Object { Get-ItemProperty -Path $_  | Where-Object { $_.DisplayName -like "*$($Application)*" } | Select-Object -Property PSDrive, PSPath, DisplayName, DisplayIcon, InstallLocation }

                #Stop all 7Zip Applications 
                Get-Process | Where-Object { $7zApps -contains $_.Name } | ForEach-Object {
                    Stop-Process -Id $_.Id -Force | Out-Null
                }

                $RegArtifacts | ForEach-Object { 

                    #Find Physical Artifacts based on InstallLocation
                    $SysArtifacts = Get-ChildItem -Path $_.InstallLocation -Recurse -ErrorAction SilentlyContinue | Where-Object { $_ -isnot $_.PSIsContainer } | Select-Object -ExpandProperty FullName

                    #Attempt to remove [FileSystem] Artifacts 
                    $SysArtifacts | ForEach-Object {
                    
                        #Get Item and Remove it 
                        Remove-Item -Path $_ -Force

                    }
                }

                #Attempt to remove [Registry] Artifacts
                $RegArtifacts | ForEach-Object {

                    $RegPath = "$($_.PSDrive):$(($_.PSPath | Select-String -Pattern 'Microsoft\.PowerShell\.Core\\Registry\:\:.*(\\Software.*)' -AllMatches).Matches.Groups[1].Value)"
                                        
                    #Get Item and Remove it 
                    Get-ItemProperty -Path $RegPath | Remove-Item -Force

                }
                #endregion
                #region EXE
            } elseif ($null -ne $apps.UninstallString -and $apps.UninstallString -like "*.exe*" -and $apps.uninstallstring -ne "MsiExec.exe") {

                #Get UninstallString from $apps
                $UninstallString = ($apps).UninstallString -replace '"', ''

                #Begin Uninstall
                Start-Process -FilePath $UninstallString -ArgumentList "/S" -Wait -NoNewWindow

                #Return Artifacts in Registry 
                $RegArtifacts = $RegistryLocs | ForEach-Object { Get-ItemProperty -Path $_  | Where-Object { $_.DisplayName -like "*$($Application)*" } | Select-Object -Property PSDrive, PSPath, DisplayName, DisplayIcon, InstallLocation }

                #Stop all 7Zip Applications 
                Get-Process | Where-Object { $7zApps -contains $_.Name } | ForEach-Object {
                    Stop-Process -Id $_.Id -Force | Out-Null
                }

                $RegArtifacts | ForEach-Object { 

                    #Find Physical Artifacts based on InstallLocation
                    $SysArtifacts = Get-ChildItem -Path $_.InstallLocation -Recurse -ErrorAction SilentlyContinue | Where-Object { $_ -isnot $_.PSIsContainer } | Select-Object -ExpandProperty FullName

                    #Attempt to remove [FileSystem] Artifacts 
                    $SysArtifacts | ForEach-Object {
                
                        Remove-Item -Path $_ -Force

                    }
                }

                #Attempt to remove [Registry] Artifacts
                $RegArtifacts | ForEach-Object {

                    $RegPath = "$($_.PSDrive):$(($_.PSPath | Select-String -Pattern 'Microsoft\.PowerShell\.Core\\Registry\:\:.*(\\Software.*)' -AllMatches).Matches.Groups[1].Value)"
                    
                    #Get Item and Remove it 
                    Get-ItemProperty -Path $RegPath | Remove-Item -Force

                }
                #endregion
            } else {       
                Write-Host "Cannot find previous installs of 7-Zip...attempting install. "
            }

        }

    } Catch [System.Management.Automation.ItemNotFoundException] {

        #General exception
        Write-Host "General Error: Unable to uninstall 7Zip from: $($ComputerName)"
    } Catch {

        #Output exception message from where error occured
        $PSItem.Exception.Message
    } Finally {

        #Clear errors
        $Error.Clear() 


        #Remove PSSession to not have multiple sessions open
        Remove-PSSession -Session $Session
    }
}