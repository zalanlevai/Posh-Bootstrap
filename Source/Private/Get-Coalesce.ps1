function Get-Coalesce() {
    <#
        .SYNOPSIS
            Returns the result of the null coalescing operator.
        .DESCRIPTION
            Returns the result of the null coalescing operator, which returns the result of its
            left-most operand if it exists and is not null, and otherwise returns the right-most
            operand.

            It replicates the behaviour of the null coalescing operator (??) in C#:

            possibleNullValue ?? valueIfNull
        .EXAMPLE
            Get-Coalesce "first" "second"

            Return "first".
        .EXAMPLE
            Get-Coalesce $null "second"

            Return "second".
        .EXAMPLE
            Get-Coalesce $Value "default"

            Return the value of $Value if it is not null, otherwise return "default".
    #>
    [CmdletBinding()]
    param(
        # The first parameter of the operator.
        [Parameter(Position = 0)]
        [psobject]
        $First,
        # The second parameter of the operator,
        [Parameter(Position = 1)]
        [psobject]
        $Second
    )

    if ($null -ne $First) { $First } else { $Second }
}