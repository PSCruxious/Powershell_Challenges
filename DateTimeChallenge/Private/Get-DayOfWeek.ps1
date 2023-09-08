function Get-DayOfWeek {
    <#
.SYNOPSIS
    Retrieves the day of the week for a given date.

.DESCRIPTION
    This function accepts a date string, converts it to a standard date format, and then determines the day of the week for that date.

.PARAMETER inputDate
    The date string for which the day of the week is to be determined. This function can handle various date formats, including:
    - ISO 8601: e.g., "2023-04-11"
    - MM-DD-YYYY: e.g., "04-11-2023"
    - M-D-YY: e.g., "4-11-23"
    - Unix Timestamp: e.g., "1681171200" (represents "2023-04-11 00:00:00 UTC")
    - UTC Date String: e.g., "2023-04-11T12:34:56+00:00" or "2023-04-11T12:34:56Z"

.OUTPUTS
    String
    Returns the day of the week for the provided date, e.g., "Tuesday".

.NOTES
    Version:        1.0
    Author:         Matthew Smith
    Creation Date:  09-08-2023

.EXAMPLE
Get-DayOfWeek -inputDate '2023-04-11'
Output: Tuesday

Get-DayOfWeek -inputDate '05-09-2023'
Output: Tuesday

Get-DayOfWeek -inputDate '6-13-23'
Output: Tuesday

Get-DayOfWeek -inputDate '1681171200'
Output: Tuesday

#>
    param (
        [Parameter(Mandatory = $true)]
        [string]$inputDate
    )

    $standardDate = [DateConverter]::ConvertToStandardDate($inputDate)
    $dateTime = [DateTime]::ParseExact($standardDate, "MM-dd-yyyy", $null)
    return $dateTime.DayOfWeek
}
