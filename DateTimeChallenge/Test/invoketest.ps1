# Check if Pester is loaded in memory
$pesterModule = Get-Module -Name Pester -ListAvailable

if (-not $pesterModule) {
    # Attempt to import Pester
    try {
        Import-Module -Name Pester -ErrorAction Stop
    } catch {
        Write-Error "Failed to import Pester module. Please ensure you have Pester installed and try again."
        return
    }
}

#Run the tests
Invoke-Pester -Path '.\Test\Test.ps1' -Output Detailed
