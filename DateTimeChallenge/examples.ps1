# Example Usage
# Output identifier to quickly find the examples output
Write-Host "--Examples Start--" -ForegroundColor "DarkMagenta"
# Confirm-DateIsAfterSecondWeekday
$exampleDate = '2023-04-14'
$publicFunctionResults = Confirm-DateIsAfterSecondWeekday -inputDate $exampleDate

Write-Host "Example 1: " -ForegroundColor "Green" -NoNewline
if ($publicFunctionResults.IsSecondOrMoreOccurrence) {
    Write-Output "$exampleDate is in week $($publicFunctionResults.WeekOfMonth) and is on or after the second occurrence of $($publicFunctionResults.DayOfWeek) in the month."
} else {
    Write-Output "$exampleDate is in week $($publicFunctionResults.WeekOfMonth) and is before the second occurrence of $($publicFunctionResults.DayOfWeek) in the month."
}

# Example Usage
# Get-DayOfWeek
$privateFunctionResults = Get-DayOfWeek -inputDate $exampleDate
Write-Host "Example 2: " -ForegroundColor "Green" -NoNewline
Write-Output "The day of the week for $exampleDate is $privateFunctionResults."

# Example Usage
# DateConverter
# Using the DateConverter class
# ISO 8601
Write-Host "Example 3: " -ForegroundColor "Green" -NoNewline
$date1 = "2023-04-14"
$result1 = [DateConverter]::ConvertToStandardDate($date1)
Write-Output "Result for $date1 : $result1"  # Should output "04-14-2023"

# MM-DD-YYYY
Write-Host "Example 4: " -ForegroundColor "Green" -NoNewline
$date2 = "04-14-2023"
$result2 = [DateConverter]::ConvertToStandardDate($date2)
Write-Output "Result for $date2 : $result2"  # Should output "04-14-2023"

# M-D-YY
Write-Host "Example 5: " -ForegroundColor "Green" -NoNewline
$date3 = "4-14-23"
$result3 = [DateConverter]::ConvertToStandardDate($date3)
Write-Output "Result for $date3 : $result3"  # Should output "04-14-2023"

# Unix Timestamp (Seconds since 1970-01-01 00:00:00 UTC)
# This represents "2023-04-14 00:00:00 UTC"
Write-Host "Example 6: " -ForegroundColor "Green" -NoNewline
$date4 = "1694692800"
$result4 = [DateConverter]::ConvertToStandardDate($date4)
Write-Output "Result for $date4 : $result4"  # Should output "04-14-2023"

# UTC Date String
Write-Host "Example 7: " -ForegroundColor "Green" -NoNewline
$date5 = "2023-04-14T12:34:56+00:00"
$result5 = [DateConverter]::ConvertToStandardDate($date5)
Write-Output "Result for $date5 : $result5"

# Another UTC Date String
Write-Host "Example 8: " -ForegroundColor "Green" -NoNewline
$date6 = "2023-04-14T12:34:56Z"
$result6 = [DateConverter]::ConvertToStandardDate($date6)
Write-Output "Result for $date6 : $result6"
Write-Host "--Examples End--" -ForegroundColor "DarkMagenta"
