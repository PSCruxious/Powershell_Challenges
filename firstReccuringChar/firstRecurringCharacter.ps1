<#
.SYNOPSIS
    Function that outputs the first char to repeat in any length of a string provided. 
.DESCRIPTION
    Takes [String]$InputString and itterates the index of the string by referencing $InputString.Length returning the strings char count. It will compare the current character ($InputString[$i)
    and compare it against the $histroy (ArrayList). If $history contains $char, it has found a match and can return the first character it found. 
.PARAMETER InputString
    An Alpha-Numric [String] that is provided by the user. 
.OUTPUTS
  The first recurring character is: $char
.NOTES
  Version:        1.0
  Author:         Matthew Smith
  Creation Date:  05/25/2021
  Purpose/Change: Interview pre-requisite for Loan Depot
.EXAMPLE
  Get-RecurringChar -InputString "y1ag1dgsyasdy"
#>

#To handle error handling properly, $ErrorActionPreference will be set to 'STOP'
$ErrorActionPreference = "STOP"

Function Get-RecurringChar {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$InputString
    )
    #Function Logic
    Try {

        #Declare ArrayList
        $history = [System.Collections.ArrayList]@()

        #For Loop to itterate over string
        for ([int]$i = 0; $i -le $InputString.Length; $i++) {

            #Casting $InputString to return a single char based on $i count
            [char]$char = $InputString[$i]
    
            #If $history ArrayList contains the current character, Return the answer.
            if ($history -contains $char) {
                Return "The first recurring character is: $char" 
            }
            else {
                [void]$history.Add($char)
            }
    
        }
        #If no patternis found output to console a message with the given string
        Write-Host "Unable to find a pattern in the InputString: $($InputString)"
    }
    Catch [System.Management.Automation.ItemNotFoundException] {
        #General exception
        Write-Host "General Error, please check $($InputString)"
    }
    Catch {
        #Output exception message from where error occured
        $PSItem.Exception.Message
    }
    Finally {
        #Clear errors
        $Error.Clear() 
    }

}

#region Examples
#Example 1 with numbers
Get-RecurringChar -InputString "a1b1bcdefg"
#Expected Outcome: 1

#Example 2 without numbers
Get-RecurringChar -InputString "abbcdefg"
#Expected Outcome: b

#Example 3 with only symbols
Get-RecurringChar -InputString "!@#$!%^&*("
#Expected Outcome: !

#Example 4 with no repeatable character
Get-RecurringChar -InputString "abcdefg"
#Expected Outcome: Unable to find a pattern in the InputString: abcdefg
#endregion
