function Update-Progress {
    <#
        .SYNOPSIS
            Updates the progress of the currently running stage.
        .DESCRIPTION
            Updates the progress and the current operation of the currently running stage,
            reflecting these changes in the script's progress bar (if any).
        .NOTES
            This operation will not succeed unless a stage is currently running.
        .EXAMPLE
            Update-Progress 15 "Updating firmware"

            Update the currently running stage's progress to 15% and its current operation to
            "Updating firmware"
    #>
    param(
        # The progress (in percentage) of the stage.
        [Parameter(Mandatory,
                   Position = 0,
                   ValueFromPipelineByPropertyName)]
        [int]
        $Progress,
        # The current operation being performed by the stage.
        [Parameter(Mandatory,
                   Position = 1,
                   ValueFromPipelineByPropertyName)]
        [string]
        $CurrentOperation
    )

    if ($null -eq $Script) { throw [System.InvalidOperationException] "No script is running." }
    if ($null -eq $Script.CurrentStage) { throw [System.InvalidOperationException] "No active stage found." }

    $Script.CurrentStage.Progress = $Progress
    $Script.CurrentStage.CurrentOperation = $CurrentOperation

    Update-ProgressDisplay
}