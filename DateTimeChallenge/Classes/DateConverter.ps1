class DateConverter {

    static [string] ConvertToStandardDate([string]$inputDate) {
        # Initialize a default DateTimeOffset
        $dateTimeOffset = [DateTimeOffset]::MinValue

        # Attempt to parse the date using various formats
        $parsedSuccessfully = [DateTimeOffset]::TryParse($inputDate, [ref]$dateTimeOffset)

        if (-not $parsedSuccessfully) {
            $parsedSuccessfully = [DateTimeOffset]::TryParseExact($inputDate, "yyyy-MM-dd", $null, 'None', [ref]$dateTimeOffset)
        }

        if (-not $parsedSuccessfully) {
            $parsedSuccessfully = [DateTimeOffset]::TryParseExact($inputDate, "MM-dd-yyyy", $null, 'None', [ref]$dateTimeOffset)
        }

        if (-not $parsedSuccessfully) {
            $parsedSuccessfully = [DateTimeOffset]::TryParseExact($inputDate, "M-d-yy", $null, 'None', [ref]$dateTimeOffset)
        }

        # Handle Unix Timestamp
        if (-not $parsedSuccessfully) {
            try {
                # Convert Unix timestamp directly to DateTime
                $baseDate = [DateTime]::new(1970, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)
                $dateTimeOffset = $baseDate.AddSeconds([double]$inputDate)
                $parsedSuccessfully = $true
            } catch {
                $parsedSuccessfully = $false
            }
        }

        if ($parsedSuccessfully) {
            return "{0:MM-dd-yyyy}" -f $dateTimeOffset.Date
        } else {
            throw "Failed to parse the date format."
        }
    }
}
