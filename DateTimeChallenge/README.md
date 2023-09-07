# PowerShell Scripting Challenge

This repository contains a PowerShell scripting challenge, complete with functions, classes, and tests. The main purpose of this challenge is to provide practical scenarios for validating PowerShell scripting skills. Below is a comprehensive guide to the repository's contents and their expected outputs.

---

## Table of Contents

- [How to Run the Challenge](#how-to-run-the-challenge)
  - [Running the Challenge](#running-the-challenge)
- [Expected Output for Examples](#expected-output-for-examples)
  - [Public Functions](#public-functions)
  - [Private Functions](#private-functions)
  - [Classes](#classes)
- [Running Tests](#running-tests)
- [Contributions](#contributions)
- [Licensing](#licensing)
- [Acknowledgments](#acknowledgments)

---

## How to Run the Challenge

## Getting Started

These instructions will guide you through setting up the project on your local machine for development and testing purposes.

### Prerequisites

- PowerShell 5.1 or newer

### Invoke-Build

The `Invoke-Build` function is an automation tool for sourcing necessary script files and executing them. It processes scripts from public, private, and class-based directories and then runs the specified example and test scripts.

#### Parameters

- **ExampleScript**: Specifies the path to the examples script. Default is `.\examples.ps1`.
- **TestScript**: Specifies the path to the test script. Default is `.\Test\invoketest.ps1`.

#### Behavior

1. Determines the current script path.
2. Processes scripts from `Public`, `Private`, and `Classes` directories.
3. Executes the test script.
4. Executes the examples script.

#### Running the Challenge

1. Download the challenge to your local machine.
2. Navigate to the root directory of the repository in PowerShell.
3. Type in `Invoke-Build` function to process all the scripts and execute the example and test scripts

```powershell
Invoke-Build
```

### Expected Output for Examples

#### Public Functions

- `Confirm-DateIsAfterSecondWeekday`:
  - Description: This function checks if a given date is on or after the second occurrence of its weekday in the month.
  - Example:
    ```powershell
    $exampleDate = '2023-04-14'
    $publicFunctionResults = Confirm-DateIsAfterSecondWeekday -inputDate $exampleDate
    ```
  - Expected Output: `2023-04-14 is in week 2 and is on or after the second occurrence of Friday in the month.`

#### Private Functions

- `Get-DayOfWeek`:
  - Description: Retrieves the day of the week for a given date.
  - Example:
    ```powershell
    $privateFunctionResults = Get-DayOfWeek -inputDate '2023-04-14'
    ```
  - Expected Output: `The day of the week for 2023-04-14 is Friday.`

### Classes

- `DateConverter`:
  - Description: Provides a static method to convert various date formats to a standard "MM-dd-yyyy" format.
  - Methods and Expected Outputs:
    - ISO 8601:
      ```powershell
      $date1 = "2023-04-14"
      [DateConverter]::ConvertToStandardDate($date1)
      ```
      Expected Output: `Result for 2023-04-14 : 04-14-2023`
    - MM-DD-YYYY:
      ```powershell
      $date2 = "04-14-2023"
      [DateConverter]::ConvertToStandardDate($date2)
      ```
      Expected Output: `Result for 04-14-2023 : 04-14-2023`
    - M-D-YY:
      ```powershell
      $date3 = "4-14-23"
      [DateConverter]::ConvertToStandardDate($date3)
      ```
      Expected Output: `Result for 4-14-23 : 04-14-2023`
    - Unix Timestamp:
      ```powershell
      $date4 = "1694692800"
      [DateConverter]::ConvertToStandardDate($date4)
      ```
      Expected Output: `Result for 1694692800 : 09-14-2023`
    - UTC Date String:
      ```powershell
      $date5 = "2023-04-14T12:34:56+00:00"
      [DateConverter]::ConvertToStandardDate($date5)
      ```
      Expected Output: `Result for 2023-04-14T12:34:56+00:00 : 04-14-2023`
    - Another UTC Date String:
      ```powershell
      $date6 = "2023-04-14T12:34:56Z"
      [DateConverter]::ConvertToStandardDate($date6)
      ```
      Expected Output: `Result for 2023-04-14T12:34:56Z : 04-14-2023`

### Tests

When you run the tests using the provided `invoketest.ps1` script, you should see an output similar to:

If you want to run the `Test.ps1`, run the `invoketest.ps1` in Powershell which handle the module handling as well.

```
Pester v5.4.1
Starting discovery in 1 files.
Discovery found 9 tests in 8ms.
Running tests.
Running tests from 'E:\Source\InterviewChallenges\Test\Test.ps1'
Describing DateConverter class tests
 Context ConvertToStandardDate method
   [+] Converts date 2023-04-14 to standard format 4ms (1ms|3ms)
   [+] Converts date 04-14-2023 to standard format 2ms (1ms|1ms)
   [+] Converts date 4-14-23 to standard format 2ms (1ms|1ms)
   [+] Converts date 1681444800 to standard format 2ms (1ms|1ms)
   [+] Converts date 2023-04-14T12:34:56+00:00 to standard format 2ms (1ms|1ms)
   [+] Converts date 2023-04-14T12:34:56Z to standard format 2ms (1ms|1ms)
Describing Get-DayOfWeek private function tests
  [+] Gets day of the week for 2023-04-14 4ms (1ms|2ms)
Describing Confirm-DateIsAfterSecondWeekday function tests
  [+] Confirms if 2023-04-14 is on or after second Friday 6ms (4ms|3ms)
  [+] Confirms week number for 2023-04-14 2ms (2ms|1ms)
Tests completed in 127ms
Tests Passed: 9, Failed: 0, Skipped: 0 NotRun: 0
```

This markdown guide provides a quick reference to the repository's content and expected outputs. For more details or troubleshooting, please refer to the specific function or class documentation.
