
#region Install-7Zip
<#
.SYNOPSIS
    Function that ensures 7-Zip exist on the $ComputerName given.
.DESCRIPTION
    Takes the [String]$ComputerName and runs a series of commands to connect to the device via PSSession.
    Downloading is performed by .NET WebClient.   
    It will then see which type of 7-Zip to install based on the users input for $Version or $OverrideURI  if it is provided. 
.PARAMETER ComputerName
    An Alpha-Numric [String] that is provided by the user.
.PARAMETER Version
    The user can select 'Stable' vs 'Alpha' to select from to be installed. (Only EXE)
.PARAMETER OverrideURI
    The user can specify a URI that is either EXE or MSI. They can specify the exact version required.
.OUTPUTS 
    <N/A>
.NOTES
  Version:        0.0.5
  Author:         Matthew Smith
  Creation Date:  05/25/2021
  Purpose/Change: Interview pre-requisite for QuestionMark
.EXAMPLE
  Install-7Zip -ComputerName $Computer -Version Stable
  Install-7Zip -ComputerName $Computer -Version Alpha
  Install-7Zip -ComputerName $Computer -OverrideURI "https://www.7-zip.org/a/7z1900-x64.msi"
#>
Function Install-7Zip {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$ComputerName,
        [Parameter(Mandatory = $false)]
        [ValidateSet("Stable", "Alpha")]
        [String]$Version,
        [Parameter(Mandatory = $false)]
        [String]$OverrideURI
    )

    #Function Logic
    Try {

        #Find latest version of 7Zip
        $options = Invoke-WebRequest -Uri 'https://7-zip.org/' | Select-Object -ExpandProperty Links | Where-Object { $_.innerHTML -eq 'download' -and $_.outerhtml -like "*-x64*" } | Select-Object -ExpandProperty href | Sort-Object

        #Version Types
        $Stable = $options[0] 
        $Alpha = $options[1]

        #Install Args
        $ExeArguments = @("/S", '/D="C:\Program Files\7-Zip"')   
        
        #Create Session for Script
        $Session = New-PSSession -ComputerName $ComputerName

        #Check if $OverrideURI has a value
        If ([string]::IsNullOrEmpty($OverrideURI)) {
            
            if ($Version -eq 'Stable' -or $null -eq $Version) {

                #Define Install Path
                $InstallationPath = Join-Path -Path "C:\Windows\Temp\" -ChildPath (Split-Path $Stable -Leaf)

                #Send script block to $ComputerName PSSession
                Invoke-Command -Session $Session -ScriptBlock { 

                    #Create WebClient to Download Stable Version of 7Zip
                    $WebClient = New-Object System.Net.WebClient;
                    $WebClient.DownloadFile("https://www.7-zip.org/$using:Stable", "$using:InstallationPath");

                    #Initiate Install
                    Start-Process -FilePath "$using:InstallationPath" -ArgumentList $using:ExeArguments -Wait -NoNewWindow;

                }

            } else {

                #Define Install Path
                $InstallationPath = Join-Path -Path "C:\Windows\Temp\" -ChildPath (Split-Path $Alpha -Leaf);

                #Send script block to $ComputerName PSSession
                Invoke-Command -Session $Session -ScriptBlock { 

                    #Create WebClient to Download Alpha Version of 7Zip
                    $WebClient = New-Object System.Net.WebClient;
                    $WebClient.DownloadFile("https://www.7-zip.org/$using:Alpha", "$using:InstallationPath");

                    #Initiate Install
                    Start-Process -FilePath "$using:InstallationPath" -ArgumentList $using:ExeArguments -Wait -NoNewWindow; 

                }

            }
        }
        #Check if $OverrideURI has a value
        elseif (-not([string]::IsNullOrEmpty($OverrideURI))) {

            #Verify that $OverrideURI is a URI
            if ($null -ne ($OverrideURI -as [System.URI]).AbsoluteURI -and $OverrideURI -like "*msi*") {

                #Define Install Path
                $InstallationPath = Join-Path -Path "C:\Windows\Temp\" -ChildPath (Split-Path $OverrideURI -Leaf)

                #Send script block to $ComputerName PSSession
                Invoke-Command -Session $Session -ScriptBlock { 

                    #Arguments for installing MSI 7Zip
                    $MsiArguments = @("/i", "$using:InstallationPath", "/quiet", "/norestart")

                    #Create WebClient to Download MSI/Override Version of 7Zip
                    $WebClient = New-Object System.Net.WebClient;
                    $WebClient.DownloadFile("$using:OverrideURI", $using:InstallationPath);

                    #Initiate Install
                    Start-Process "msiexec.exe" -ArgumentList $MsiArguments -Wait -NoNewWindow; 

                }

            } elseif ($null -ne ($OverrideURI -as [System.URI]).AbsoluteURI -and $OverrideURI -like "*exe*") {

                #Define Install Path
                $InstallationPath = Join-Path -Path "C:\Windows\Temp\" -ChildPath (Split-Path $OverrideURI -Leaf)

                #Send script block to $ComputerName PSSession
                Invoke-Command -Session $Session -ScriptBlock { 

                    #Create WebClient to Download EXE/Override Version of 7Zip
                    $WebClient = New-Object System.Net.WebClient;
                    $WebClient.DownloadFile("$using:OverrideURI", "$using:InstallationPath");

                    #Initiate Install
                    Start-Process -FilePath "$using:InstallationPath" -ArgumentList $using:ExeArguments -Wait -NoNewWindow; 

                }
            } else {

                Write-Host "Unable to perform task on $($ComputerName), Check OverrideURI is valid: $($OverrideURI). Check connection to $($ComputerName)"          
            }
        }
    } Catch [System.Management.Automation.ItemNotFoundException] {

        #General exception
        if (-not([string]::IsNullOrEmpty($OverrideURI))) {

            Write-Host "General Error: Unable to perform task on $($ComputerName), Check OverrideURI is valid: $($OverrideURI). Check connection to $($ComputerName)"

        } else {

            Write-Host "General Error: Unable to perform task on $($ComputerName). Check connection to $($ComputerName)"
        }
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
#endregion

#region Uninstall-7Zip
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
  Version:        0.0.5
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
#endregion
