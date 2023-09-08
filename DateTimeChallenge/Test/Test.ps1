Describe "DateConverter class tests" {
    Context "ConvertToStandardDate method" {
        It "Converts date 2023-04-04 (First Tuesday of April) to standard format" {
            $result = [DateConverter]::ConvertToStandardDate("2023-04-04")
            $result | Should -BeExactly "04-04-2023"
        }

        It "Converts date 2023-04-11 (Second Tuesday of April) to standard format" {
            $result = [DateConverter]::ConvertToStandardDate("2023-04-11")
            $result | Should -BeExactly "04-11-2023"
        }

        It "Converts date 2023-04-18 (Third Tuesday of April) to standard format" {
            $result = [DateConverter]::ConvertToStandardDate("2023-04-18")
            $result | Should -BeExactly "04-18-2023"
        }

        It "Converts date 2023-04-25 (Fourth Tuesday of April) to standard format" {
            $result = [DateConverter]::ConvertToStandardDate("2023-04-25")
            $result | Should -BeExactly "04-25-2023"
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
    It "Gets day of the week for 2023-04-04 (First Tuesday of April)" {
        $result = Get-DayOfWeek -inputDate "2023-04-04"
        $result | Should -BeExactly "Tuesday"
    }

    It "Gets day of the week for 2023-04-11 (Second Tuesday of April)" {
        $result = Get-DayOfWeek -inputDate "2023-04-11"
        $result | Should -BeExactly "Tuesday"
    }

    It "Gets day of the week for 2023-04-18 (Third Tuesday of April)" {
        $result = Get-DayOfWeek -inputDate "2023-04-18"
        $result | Should -BeExactly "Tuesday"
    }

    It "Gets day of the week for 2023-04-25 (Fourth Tuesday of April)" {
        $result = Get-DayOfWeek -inputDate "2023-04-25"
        $result | Should -BeExactly "Tuesday"
    }

    It "Gets day of the week for 2023-04-14" {
        $result = Get-DayOfWeek -inputDate "2023-04-14"
        $result | Should -BeExactly "Friday"
    }
}

Describe "Confirm-DateIsSecondTuesday function tests" {

    It "Confirms if 2023-04-11 is the second Tuesday of April" {
        $result = Confirm-DateIsSecondTuesday -inputDate '2023-04-11'
        $result | Should -Be $true
    }

    It "Confirms if 2023-05-09 is the second Tuesday of May" {
        $result = Confirm-DateIsSecondTuesday -inputDate '2023-05-09'
        $result | Should -Be $true
    }

    It "Confirms if 2023-06-13 is the second Tuesday of June" {
        $result = Confirm-DateIsSecondTuesday -inputDate '2023-06-13'
        $result | Should -Be $true
    }

    It "Confirms that 2023-04-04 (first Tuesday of April) is not on or after the second Tuesday" {
        $result = Confirm-DateIsSecondTuesday -inputDate '2023-04-04'
        $result | Should -Be $false
    }

    It "Confirms that 2023-05-16 (third Tuesday of May) is not on or after the second Tuesday" {
        $result = Confirm-DateIsSecondTuesday -inputDate '2023-05-16'
        $result | Should -Be $false
    }

    It "Confirms that 2023-06-27 (fourth Tuesday of June) is not on or after the second Tuesday" {
        $result = Confirm-DateIsSecondTuesday -inputDate '2023-06-27'
        $result | Should -Be $false
    }
}

