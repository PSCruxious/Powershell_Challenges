function Get-DayOfWeek {
    param (
        [Parameter(Mandatory = $true)]
        [string]$inputDate
    )

    $standardDate = [DateConverter]::ConvertToStandardDate($inputDate)
    $dateTime = [DateTime]::ParseExact($standardDate, "MM-dd-yyyy", $null)
    return $dateTime.DayOfWeek
}
