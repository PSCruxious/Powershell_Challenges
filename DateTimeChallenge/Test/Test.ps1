Describe "DateConverter class tests" {
    Context "ConvertToStandardDate method" {
        It "Converts date 2023-04-14 to standard format" {
            $result = [DateConverter]::ConvertToStandardDate("2023-04-14")
            $result | Should -BeExactly "04-14-2023"
        }

        It "Converts date 04-14-2023 to standard format" {
            $result = [DateConverter]::ConvertToStandardDate("04-14-2023")
            $result | Should -BeExactly "04-14-2023"
        }

        It "Converts date 4-14-23 to standard format" {
            $result = [DateConverter]::ConvertToStandardDate("4-14-23")
            $result | Should -BeExactly "04-14-2023"
        }

        It "Converts date 1681444800 to standard format" {
            $result = [DateConverter]::ConvertToStandardDate("1681444800")
            $result | Should -BeExactly "04-14-2023"
        }

        It "Converts date 2023-04-14T12:34:56+00:00 to standard format" {
            $result = [DateConverter]::ConvertToStandardDate("2023-04-14T12:34:56+00:00")
            $result | Should -BeExactly "04-14-2023"
        }

        It "Converts date 2023-04-14T12:34:56Z to standard format" {
            $result = [DateConverter]::ConvertToStandardDate("2023-04-14T12:34:56Z")
            $result | Should -BeExactly "04-14-2023"
        }
    }
}

Describe "Get-DayOfWeek private function tests" {
    It "Gets day of the week for 2023-04-14" {
        $result = Get-DayOfWeek -inputDate "2023-04-14"
        $result | Should -BeExactly "Friday"
    }
}

Describe "Confirm-DateIsAfterSecondWeekday function tests" {
    It "Confirms if 2023-04-14 is on or after second Friday" {
        $result = Confirm-DateIsAfterSecondWeekday -inputDate '2023-04-14'
        $result.IsSecondOrMoreOccurrence | Should -Be $true
    }

    It "Confirms week number for 2023-04-14" {
        $result = Confirm-DateIsAfterSecondWeekday -inputDate '2023-04-14'
        $result.WeekOfMonth | Should -Be 2
    }
}
