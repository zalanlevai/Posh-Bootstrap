function Complete-Stage {
    <#
        .SYNOPSIS
            Marks the currently running stage as completed.
        .DESCRIPTION
            Marks the currently running stage as completed, updating its current operation in the
            process. This is useful when the script should exit earlier then the end of the final
            stage (e.g. when the script prepares an interactive environment and the final stage
            drops into this environment - the script should be deemed complete even though the
            final stage is still waiting on the interactive environment to be closed).
        .NOTES
            This operation will not succeed unless a stage is currently running.
        .EXAMPLE
            Complete-Stage "Running from remote at $Address"

            Manually mark the currently running stage as complete, updating its current operation
            to "Running from remote at $Address"
    #>
    param(
        # The current operation being performed by the stage.
        [Parameter(Position = 0,
                   ValueFromPipelineByPropertyName)]
        [string]
        $CurrentOperation
    )

    if ($null -eq $Script) { throw [System.InvalidOperationException] "No script is running." }
    if ($null -eq $Script.CurrentStage) { throw [System.InvalidOperationException] "No active stage found." }

    $Script.CurrentStage.Completed = $true
    Update-Progress 100 $CurrentOperation
}