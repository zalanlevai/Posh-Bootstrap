class Stage {
    [int] $Index

    [ValidateNotNullOrEmpty()]
    [string] $Name

    [ValidateNotNull()]
    [scriptblock] $Action

    [string] $CurrentOperation

    [int] $Progress = 0

    [bool] $Completed = $false
}