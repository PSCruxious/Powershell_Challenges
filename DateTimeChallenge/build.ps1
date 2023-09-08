function Invoke-Build {
    [CmdletBinding()]
    param(
        [string]$TestScript = '.\Test\invoketest.ps1'
    )

    Process {

        $scriptPath = if ($PSScriptRoot) {
            $PSScriptRoot
        } else {
            Split-Path -Parent $MyInvocation.MyCommand.Path
        }

        $foldersToProcess = @("$scriptPath\Public", "$scriptPath\Private", "$scriptPath\Classes")

        foreach ($folder in $foldersToProcess) {
            if (Test-Path $folder) {
                Write-Verbose "Processing folder: $folder"
                Get-ChildItem -Path $folder -Filter "*.ps1" | ForEach-Object {
                    . $_.FullName
                }
            } else {
                Write-Warning "Directory $folder not found."
            }
        }

        if (Test-Path $TestScript) {
            Write-Verbose "Executing $TestScript"
            & $TestScript
        } else {
            Write-Warning "Test script $TestScript not found."
        }
    }
}
#You can add -Verbose to get more verbose outputs
Invoke-Build
