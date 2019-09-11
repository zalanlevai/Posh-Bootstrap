function New-Stage {
    <#
        .SYNOPSIS
            Creates a new stage.
        .DESCRIPTION
            Creates a new stage from the specified parameters. This cmdlet is used when defining
            scripts to invoke.
        .EXAMPLE
            New-Stage "Title" { Write-Host "Running from stage!" }

            Create a new stage with the name "Title" that writes a message to the interactive
            console when run.
    #>
    [CmdletBinding()]
    param(
        # The name of the stage.
        [Parameter(Mandatory,
                   Position = 0,
                   ValueFromPipelineByPropertyName)]
        [string]
        $Name,
        # The scriptblock to execute when the stage is running.
        [Parameter(Mandatory,
                   Position = 1,
                   ValueFromPipelineByPropertyName)]
        [scriptblock]
        $Action
    )

    return @{
        Name = $Name
        Action = $Action
    }
}