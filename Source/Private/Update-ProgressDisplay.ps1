function Update-ProgressDisplay {
    <#
        .SYNOPSIS
            Updates the progress bar of the currently running stage.
        .DESCRIPTION
            Updates the script's overall progress value, reflecting these changes in its progress
            bar (if any).
    #>
    [CmdletBinding()]
    param()

    # Update overall script progress.
    [int]$Script.Progress = $Script.CurrentStage.Index / $Script.StageCount * 100 + $Script.CurrentStage.Progress / $Script.StageCount
    Write-Verbose "Updating progress to: ($CurrentStageDisplayIndex/$($Script.StageCount)) $($Script.CurrentStage.Name)`: $CurrentOperation ($($Script.CurrentStage.Progress)% - $($Script.Progress)% overall)"

    # Nothing to do if no progress is being displayed.
    if ($ProgressMode -eq [ProgressMode]::None) { return }

    # Display the one-based index instead of the zero-based one that is stored internally.
    $CurrentStageDisplayIndex = $Script.CurrentStage.Index + 1
    # Make sure the current operation is at least an empty string (not null).
    [string]$CurrentOperation = Get-Coalesce $Script.CurrentStage.CurrentOperation ""
    # Determines wether the 'overall' progress bars should be deemed completed.
    $AllStagesCompleted = [System.Linq.Enumerable]::All([Stage[]] $Stages, [Func[Stage, bool]] { $args[0].Completed })

    # Display the progress depending on the set display mode.
    if ($ProgressMode -eq [ProgressMode]::Full) {
        # Display a two-layer progress bar with the first one showing the overall progress of the
        # script and the second one - nested under the first one - showing the progress of the
        # currently running stage.

        # Display the first progress bar about overall status.
        Write-Progress -Id 1 `
            -Activity "($CurrentStageDisplayIndex/$($Script.StageCount)) $($Script.CurrentStage.Name)" `
            -Status "$($Script.Progress)% complete" `
            -CurrentOperation " " `
            -PercentComplete $Script.Progress `
            -Completed:$AllStagesCompleted

        # Display the second, nested progress bar about the status of the current stage and the
        # currently running operation.
        Write-Progress -Id 2 -ParentId 1 `
            -Activity $Script.CurrentStage.Name `
            -Status "$($Script.CurrentStage.Progress)% complete" `
            -CurrentOperation $CurrentOperation `
            -PercentComplete $Script.CurrentStage.Progress `
            -Completed:$Script.CurrentStage.Completed
    } else {
        # Display a single-layer progress bar that shows information about the script's overall
        # progress and the current operation being performed at the same time.

        # Display the compact progress bar.
        Write-Progress -Id 1 `
            -Activity "($CurrentStageDisplayIndex/$($Script.StageCount)) $($Script.CurrentStage.Name)" `
            -Status "$($Script.Progress)% complete" `
            -CurrentOperation $(if (-not [string]::IsNullOrEmpty($CurrentOperation)) { "$CurrentOperation ($($Script.CurrentStage.Progress)% complete)" } else { "$($Script.CurrentStage.Progress)% complete" }) `
            -PercentComplete $Script.Progress `
            -Completed:$AllStagesCompleted
    }
}