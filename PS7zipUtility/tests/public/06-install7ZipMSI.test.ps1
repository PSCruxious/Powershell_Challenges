#Get Native Variables to maintain integrity 
$NativeVars = Get-Variable | Select-Object -ExpandProperty Name

#Define ComputerName to use for Pester testing
[String]$ComputerName = $ENV:COMPUTERNAME

#Create Session for Pester Test
$Session = New-PSSession -ComputerName $ComputerName

#Define Override URI (MSI Package)
$OverrideURI = "https://www.7-zip.org/a/7z1900-x64.msi"

#Module Path for PS7zipUtility
$Module = "C:\Source\PS7zipUtility\PS7zipUtility.psd1"


Describe 'Install 7-Zip OverrideURI Version (MSI)' {
    Context 'Invoke Command to PSSession $ComputerName' {

        It 'Installs OverrideURI MSI Variant' {

            #Define Install Path
            $InstallationPath = Join-Path -Path "C:\Windows\Temp\" -ChildPath (Split-Path  $OverrideURI -Leaf)

            #Send script block to $ComputerName PSSession
            Invoke-Command -Session $Session -ScriptBlock { 

                #Arguments for installing MSI 7Zip
                $MsiArguments = @("/i", "$using:InstallationPath", "/quiet", "/norestart", "REBOOT=ReallySuppress") 

                #Create WebClient to Download MSI/Overide Version of 7Zip
                $WebClient = New-Object System.Net.WebClient;
                $WebClient.DownloadFile("$using:OverrideURI", "$using:InstallationPath");

                #Initiate Install
                Start-Process -FilePath "msiexec.exe" -ArgumentList $MsiArguments -Wait -NoNewWindow;
            }
        }
        It 'Verifies Install of OverrideURI MSI Variant' {

            $Application = "7-Zip"
            
            $apps = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Select-Object -Property DisplayName, UninstallString, QuietUninstallString | Where-Object { $_.DisplayName -like "*$($Application)*" } | Select-Object -First 1
            
            ($apps).UninstallString | Should -Be ($null -ne $_)
        } 
        AfterAll {
            #Remove PSSession to not have multiple sessions open
            Remove-PSSession -Session $Session

            #Remove all user defined variables
            Get-Variable -Exclude $NativeVars | Remove-Variable -Force -ErrorAction SilentlyContinue

            #Import Module to Uninstall 7Zip
            Import-Module $Module -Force

            #Uninstall 7Zip
            #Uninstall-7Zip -ComputerName $ComputerName
        }
    }
}
