function Confirm-DateIsSecondTuesday {
    <#
.SYNOPSIS
    Checks if a given date is the second Tuesday of the month.

.DESCRIPTION
    Determines the week of the month for the given date and checks if it falls on the second Tuesday in that month.

.PARAMETER inputDate
    The date string to be checked. This function can handle various date formats, specifically for a Tuesday example. Supported formats are:
    - ISO 8601: e.g., "2023-04-11"
    - MM-DD-YYYY: e.g., "04-11-2023"
    - M-D-YY: e.g., "4-11-23"
    - Unix Timestamp: e.g., "1681171200" (represents "2023-04-11 00:00:00 UTC")
    - UTC Date String: e.g., "2023-04-11T12:34:56+00:00" or "2023-04-11T12:34:56Z"

.OUTPUTS
    Boolean
    Returns $true if the input date is the second Tuesday in the month. Otherwise, returns $false.

.NOTES
    Version:        1.1
    Author:         Matthew Smith
    Creation Date:  09-08-2023

.EXAMPLE
# Second Tuesday of April 2023 in ISO 8601 format
Confirm-DateIsSecondTuesday -inputDate '2023-04-11'
Output: True

# Second Tuesday of May 2023 in MM-DD-YYYY format
Confirm-DateIsSecondTuesday -inputDate '05-09-2023'
Output: True

# Second Tuesday of June 2023 in M-D-YY format
Confirm-DateIsSecondTuesday -inputDate '6-13-23'
Output: True

# First Tuesday of April 2023 in Unix Timestamp format (represents "2023-04-04 00:00:00 UTC")
Confirm-DateIsSecondTuesday -inputDate '1680566400'
Output: False

# Third Tuesday of May 2023 in UTC Date String format
Confirm-DateIsSecondTuesday -inputDate '2023-05-16T12:34:56+00:00'
Output: False

# Fourth Tuesday of June 2023 in another UTC Date String format
Confirm-DateIsSecondTuesday -inputDate '2023-06-27T12:34:56Z'
Output: False

#>

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$inputDate
    )

    Process {
        try {
            # Determine the day of the week for the input date
            $dayOfWeek = Get-DayOfWeek -inputDate $inputDate

            # Convert the input date to a DateTime object
            $standardDate = [DateConverter]::ConvertToStandardDate($inputDate)
            $dateTime = [DateTime]::ParseExact($standardDate, "MM-dd-yyyy", $null)

            # Determine which week of the month the date is in
            [int]$weekOfMonth = [Math]::Ceiling($dateTime.Day / 7.0)

            # Determine if the input date is the second Tuesday of the month
            $isSecondTuesday = ($weekOfMonth -eq 2) -and ($dayOfWeek -eq "Tuesday")

            if ($isSecondTuesday) {
                $true
            } else {
                $false
            }
        } catch {
            Write-Error "An error occurred: $_"
        }
    }
}
