#Get Native Variables to maintain integrity 
$NativeVars = Get-Variable | Select-Object -ExpandProperty Name

#Define ComputerName to use for Pester testing
[String]$ComputerName = $ENV:COMPUTERNAME

#Create Session for Pester Test
$Session = New-PSSession -ComputerName $ComputerName

#Create WebRequest and return options
$options = Invoke-WebRequest -Uri 'https://7-zip.org/' | Select-Object -ExpandProperty Links | Where-Object { $_.innerHTML -eq 'download' -and $_.outerhtml -like "*-x64*" } | Select-Object -ExpandProperty href | Sort-Object

#Alpha Version of 7Zip
$Alpha = $options[1] 

#Arguments for installing EXE 7Zip
$ExeArguments = @("/S", '/D="C:\Program Files\7-Zip"')  

#Module Path for PS7zipUtility
$Module = "C:\Source\PS7zipUtility\PS7zipUtility.psd1"

Describe 'Install 7-Zip Alpha Version (EXE)' {

    Context 'Invoke Command to PSSession $ComputerName' {

        It 'Installs Alpha EXE Variant' {

            #Define Install Path
            $InstallationPath = Join-Path -Path "C:\Windows\Temp\" -ChildPath (Split-Path $Alpha -Leaf)

            #Send script block to $ComputerName PSSession
            Invoke-Command -Session $Session -ScriptBlock { 

                #Create WebClient to Download Alpha Version of 7Zip
                $WebClient = New-Object System.Net.WebClient;
                $WebClient.DownloadFile("https://www.7-zip.org/$using:Alpha", "$using:InstallationPath");

                #Initiate Install
                Start-Process -FilePath "$using:InstallationPath" -ArgumentList $using:ExeArguments -Wait -NoNewWindow;

            }
        }
        It 'Verifies Install of Alpha EXE Variant' {

            $Application = "7-Zip"

            $apps = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Select-Object -Property DisplayName, UninstallString, QuietUninstallString | Where-Object { $_.DisplayName -like "*$($Application)*" } | Select-Object -First 1
            
            ($apps).UninstallString | Should -Be ($null -ne $_)
        } 
        AfterAll {

            #Remove PSSession to not have multiple sessions open
            Remove-PSSession -Session $Session

            #Import Module to Uninstall 7Zip
            Import-Module $Module -Force

            #Remove all user defined variables
            Get-Variable -Exclude $NativeVars | Remove-Variable -Force -ErrorAction SilentlyContinue

            #Uninstall 7Zip
            Uninstall-7Zip -ComputerName $ComputerName
        }
    }
}
