#Get Native Variables to maintain integrity 
$NativeVars = Get-Variable | Select-Object -ExpandProperty Name

#Define ComputerName to use for Pester testing
[String]$ComputerName = $ENV:COMPUTERNAME

#Create Session for Pester Test
$Session = New-PSSession -ComputerName $ComputerName

Describe 'Checking for Artifacts from previous Installs/Uninstalls of 7Zip' {

    Context 'Find Artifacts and removes them' {

        It 'Returns Artifacts' {

            #Send script block to $ComputerName PSSession
            Invoke-Command -Session $Session -ScriptBlock { 
            
                #Define specific application
                $Application = "7-Zip"
                
                #Get registry data for $Application
                $RegistryLocs = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*')
                
                #Get $RegistryLocs of $Application if it exist
                $apps = $RegistryLocs | ForEach-Object { Get-ItemProperty -Path $_  | Where-Object { $_.DisplayName -like "*$($Application)*" }  | Select-Object -Property PSDrive, PSPath, DisplayName, UninstallString | Select-Object -First 1 }

                #If an uninstall string is found in $apps
                if ($null -ne ($apps).UninstallString) {
                            
                    #Get UninstallString from $apps
                    $UninstallString = ($apps).UninstallString -replace '"', ''
                
                    Write-Host "Uninstall String Found: " -ForegroundColor 'Green' -NoNewline
                    Write-Host "$UninstallString" -ForegroundColor 'DarkCyan'

                }

                #Test to see if Uninstall String path is $true if so try standard uninstall
                If ((Test-Path -Path $UninstallString)) {
               
                    Write-Host "Path Exist: " -ForegroundColor 'Green' -NoNewline
                    Write-Host "$UninstallString" -ForegroundColor 'DarkCyan'
                    Write-Host "Try Standard Uninstall " -ForegroundColor 'Green'

                } elseif (-not (Test-Path -Path $UninstallString)) {
               
                    Write-Host "Path Does Not Exist: " -ForegroundColor 'Green' -NoNewline
                    Write-Host "$UninstallString" -ForegroundColor 'DarkCyan'
                    Write-Host "Checking For Registry Artifacts" -ForegroundColor 'Green'
                    
                    #Return Artifacts in Registry 
                    $RegArtifacts = $RegistryLocs | ForEach-Object { Get-ItemProperty -Path $_  | Where-Object { $_.DisplayName -like "*$($Application)*" } | Select-Object -Property PSDrive, PSPath, DisplayName, DisplayIcon, InstallLocation }
                    
                    #Output Artifacts Found
                    $RegArtifacts | ForEach-Object {
                        Write-Host "Artifact Found [Registry]: " -ForegroundColor 'Red' -NoNewline
                        Write-Host "`r`nDisplayName: $($_.DisplayName)`r`nDisplayVersion: $($_.DisplayVersion)`r`nDisplayIcon: $($_.DisplayIcon)`r`nInstallLocation: $($_.InstallLocation)"
                    }

                    #Return Artifacts in Install Location
                    if ((Test-Path -Path ($RegArtifacts).InstallLocation)) {

                        $RegArtifacts | ForEach-Object { 

                            #Find Physical Artifacts based on InstallLocation
                            $SysArtifacts = Get-ChildItem -Path $_.InstallLocation -Recurse | Select-Object -ExpandProperty FullName

                            Write-Host "Checking For FileSystem Artifacts" -ForegroundColor 'Green'

                            #Nested foreach to output FileSystem Artifacts
                            $SysArtifacts | ForEach-Object {

                                Write-Host "Artifact Found [FileSystem]: " -ForegroundColor 'Red' -NoNewline
                                Write-Host "`r`nFilePath : $($_)"

                            }
                        }
                    }
                } else {
                    Write-Host "Unable to Find: " -ForegroundColor 'Green' -NoNewline
                    Write-Host "$Application" -ForegroundColor 'DarkCyan'
                }
            }
        }

        It 'Removes Artifacts' {
            
            Invoke-Command -Session $Session -ScriptBlock { 

                #Define possible running applications from $Application
                $7zApps = @("7zFM", "7zG", "7z")

                #Return Artifacts in Registry 
                $RegArtifacts = $RegistryLocs | ForEach-Object { Get-ItemProperty -Path $_  | Where-Object { $_.DisplayName -like "*$($Application)*" } | Select-Object -Property PSDrive, PSPath, DisplayName, DisplayIcon, InstallLocation }


                #Stop all 7Zip Applications 
                Get-Process | Where-Object { $7zApps -contains $_.Name } | ForEach-Object {
                    Stop-Process -Id $_.Id -Force | Out-Null
                }

                $RegArtifacts | ForEach-Object { 

                    #Find Physical Artifacts based on InstallLocation
                    $SysArtifacts = Get-ChildItem -Path $_.InstallLocation -Recurse | Select-Object -ExpandProperty FullName

                    #Attempt to remove [FileSystem] Artifacts 
                    $SysArtifacts | ForEach-Object {
                    
                        Write-Host "Attempting to Remove [FileSystem] Artifact: " -ForegroundColor 'Red' -NoNewline
                        Write-Host "`r`nFilePath : $($_)"

                        Remove-Item -Path $_ -Force

                    }
                }
                #Attempt to remove [Registry] Artifacts
                $RegArtifacts | ForEach-Object {

                    $RegPath = "$($_.PSDrive):$(($_.PSPath | Select-String -Pattern 'Microsoft\.PowerShell\.Core\\Registry\:\:.*(\\Software.*)' -AllMatches).Matches.Groups[1].Value)"
                    
                    Write-Host "Attempting to Remove [Registry] Artifact: " -ForegroundColor 'Red' -NoNewline
                    Write-Host "`r`nFilePath : $($RegPath)"
                    
                    #Get Item and Remove it 
                    Get-ItemProperty -Path $RegPath | Remove-Item -Force

                }
                
            }
        }
    }
    AfterAll {
        #Remove PSSession to not have multiple sessions open
        Remove-PSSession -Session $Session

        #Remove all user defined variables
        Get-Variable -Exclude $NativeVars | Remove-Variable -Force -ErrorAction SilentlyContinue
    }
}