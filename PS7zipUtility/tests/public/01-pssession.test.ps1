#Get Native Variables to maintain integrity 
$NativeVars = Get-Variable | Select-Object -ExpandProperty Name

#Define ComputerName to use for Pester testing
[String]$ComputerName = $ENV:COMPUTERNAME

Describe 'Checking Session Capaility' {

    Context 'Initiating PSSession with $ComputerName' {
        It 'Creates PSSession' {

            New-PSSession -ComputerName $ComputerName
            #Grab last created session
            (Get-PSSession)[-1].ComputerName | Should -Be $ComputerName

        }
        It 'Removes PSSession' {

            Remove-PSSession -ComputerName $ComputerName
            Get-PSSession | Should -Be $Null
            
        }
    }
    AfterAll {
        #Remove all user defined variables
        Get-Variable -Exclude $NativeVars | Remove-Variable -Force -ErrorAction SilentlyContinue
    }
}

