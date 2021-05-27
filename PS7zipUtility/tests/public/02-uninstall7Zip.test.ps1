#Get Native Variables to maintain integrity 
$NativeVars = Get-Variable | Select-Object -ExpandProperty Name

#Define ComputerName to use for Pester testing
[String]$ComputerName = $ENV:COMPUTERNAME

#Create Session for Pester Test
$Session = New-PSSession -ComputerName $ComputerName


Describe 'Checking for Uninstall String return and Uninstall 7Zip' {

    Context 'Find UninstallString and Uninstall Application if it exist' {

        It 'Stops Application Processes and Uninstalls Application' {
            #See if $apps found $Application in the registry
            if ($null -ne ($apps).UninstallString) {

                #Send script block to $ComputerName PSSession
                Invoke-Command -Session $Session -ScriptBlock { 

                    #Registry Locations
                    $RegistryLocs = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*')

                    #Define specific application
                    $Application = "7-Zip"

                    #Define possible running applications from $Application
                    $7zApps = @("7zFM", "7zG", "7z")
    
                    #Get registry data for $Application
                    $apps = $RegistryLocs | ForEach-Object { Get-ItemProperty -Path $_ | Where-Object { $_.DisplayName -like "*$($Application)*" } | Select-Object -Property PSDrive, PSPath, DisplayName, DisplayIcon, InstallLocation, UninstallString }
            
                    #Get UninstallString from $apps
                    $UninstallString = ($apps).UninstallString -replace '"', ''

                    #Stop all 7Zip Applications 
                    Get-Process | Where-Object { $7zApps -contains $_.Name } | ForEach-Object {
                        Stop-Process -Id $_.Id -Force | Out-Null
                    }
                        
                    #See if the $Application is an MSI
                    if ($null -ne $UninstallString -and $UninstallString -like "*.msi*" -or $uninstallstring -like "*MsiExec.exe*") {
                        
                        #Define UninstallString returned from $apps
                        $UninstallString = $(($uninstallstring | Select-String -Pattern "\{.*\}" -AllMatches).matches.value)
                        
                        Write-Host "Uninstalling MSI Variant: " -ForegroundColor 'Green' -NoNewline
                        Write-Host "$UninstallString" -ForegroundColor 'DarkCyan'
                        
                        #Begin Uninstall 
                        Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $($UninstallString) /QN REBOOT=ReallySuppress" -Wait -NoNewWindow

                        #See if the $Application is an EXE 
                    } elseif ($null -ne $UninstallString -and $UninstallString -like "*.exe*" -and $uninstallstring -ne "MsiExec.exe") {
                        
                        #Define UninstallString returned from $apps
                        $UninstallString = "$($UninstallString)"
                        
                        Write-Host "Uninstalling EXE Variant: " -ForegroundColor 'Green' -NoNewline
                        Write-Host "$UninstallString" -ForegroundColor 'DarkCyan'
                        
                        #Begin Uninstall
                        Start-Process -FilePath $UninstallString -ArgumentList "/S" -Wait -NoNewWindow                    
                    } 
                }
            } else {

                Write-Host "Unable to Find: " -ForegroundColor 'Green' -NoNewline
                Write-Host "$Application" -ForegroundColor 'DarkCyan'
                
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