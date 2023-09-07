function Confirm-DateIsAfterSecondWeekday {
    <#
.SYNOPSIS
    Function that checks if a given date is on or after the second occurrence of its weekday in the month.
.DESCRIPTION
    This function determines the week of the month for the given date and checks whether it falls on or after the second occurrence of the same weekday in that month.
.PARAMETER inputDate
    The date string to be checked. The function is designed to handle a variety of date formats. These include:
    - ISO 8601: e.g., "2023-04-14"
    - MM-DD-YYYY: e.g., "04-14-2023"
    - M-D-YY: e.g., "4-14-23"
    - Unix Timestamp: e.g., "1694692800"
    - UTC Date String: e.g., "2023-04-14T12:34:56+00:00" or "2023-04-14T12:34:56Z"
.OUTPUTS
    Hashtable containing:
    - WeekOfMonth: The week number of the month for the given date.
    - IsSecondOrMoreOccurrence: Boolean indicating if the date is on or after the second occurrence of its weekday.
    - DayOfWeek: The day of the week for the input date.
.NOTES
    Version:        1.0
    Author:         Matthew Smith
    Creation Date:  09-27-20023
.EXAMPLE
    Confirm-DateIsAfterSecondWeekday -inputDate '2023-04-14'
    Confirm-DateIsAfterSecondWeekday -inputDate '4-14-23'
    Confirm-DateIsAfterSecondWeekday -inputDate '2023-04-14T12:34:56+00:00'
#>
    param (
        [Parameter(Mandatory = $true)]
        [string]$inputDate
    )

    # Determine the day of the week for the input date
    $dayOfWeek = Get-DayOfWeek -inputDate $inputDate

    # Convert the input date to a DateTime object
    $standardDate = [DateConverter]::ConvertToStandardDate($inputDate)
    $dateTime = [DateTime]::ParseExact($standardDate, "MM-dd-yyyy", $null)

    # Determine which week of the month the date is in
    [int]$weekOfMonth = [Math]::Ceiling($dateTime.Day / 7.0)

    # Find the first day of the month
    $firstDayOfMonth = Get-Date -Year $dateTime.Year -Month $dateTime.Month -Day 1

    # Loop to find the first occurrence of the day of the week
    do {
        $firstDayOfMonth = $firstDayOfMonth.AddDays(1)
    } while ($firstDayOfMonth.DayOfWeek -ne $dayOfWeek)

    # Determine if the input date is the 2nd or more occurrence of the weekday
    $isSecondOrMoreOccurrence = $dateTime -ge $firstDayOfMonth

    return @{
        WeekOfMonth              = $weekOfMonth
        IsSecondOrMoreOccurrence = $isSecondOrMoreOccurrence
        DayOfWeek                = $dayOfWeek
    }
}
