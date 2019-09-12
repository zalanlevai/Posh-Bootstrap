function Invoke-Script {
    <#
        .SYNOPSIS
            Invokes the supplied stages as a script.
        .DESCRIPTION
            Invokes the supplied stages as a script. This cmdlet is especially useful for
            running scripts with a progress bar.
        .EXAMPLE
            Invoke-Script @(New-Stage "Title" { Do-Work })

            Invoke a simple, single-stage script.
        .EXAMPLE
            Invoke-Script @(New-Stage "Title" { Do-Work }) -ProgressMode Compact

            Invoke a simple, single-stage script with the compact progress bar.
        .EXAMPLE
            Invoke-Script @(New-Stage "Title" { Do-Work }) -ProgressMode None

            Invoke a simple, single-stage script with no progress bar being displayed.
        .EXAMPLE
            >
            Invoke-Script @(
                $(New-Stage "Build" {
                    Update-Progress 0 "Building..."
                    dotnet publish Hello.dll
                    Update-Progress 100 "Build complete"
                }),
                $(New-Stage "Copy" {
                    Update-Progress 0 "Copying files to remote"
                    $Files = Get-ChildItem $Source -File -Recurse
                    for ($i = 0; $i -lt $Files.Count; $i++) {
                        $File = $Files[$i]
                        Update-Progress $($i / $Files.Count * 100) "Copying $File"
                        Copy-Item $File -Destination $Destination -ToSession $Session -Force
                    }
                })
            )

            Invoke a script that builds a dotnet project in its first stage, then copies the
            resulting files to a remote computer in its second stage; all with a progress bar
            displaying the actions taking place.
    #>
    [CmdletBinding()]
    param(
        # The stages to invoke as a script.
        [Parameter(Mandatory,
                   Position = 0)]
        [Stage[]]
        $Stages,
        # The display mode to use for the progress bar.
        [Parameter()]
        [ProgressMode]
        $ProgressMode = [ProgressMode]::Full
    )

    Write-Host "Posh-Bootstrap ver. $($Manifest.ModuleVersion)`nCopyright $($Manifest.Copyright)`n"

    # Assign indices to all of the supplied stages. These are used later for the progress display.
    for ($i = 0; $i -lt $Stages.Count; $i++) { $Stages[$i].Index = $i }

    # Prepare a simple hashtable for storing execution information. This is read and manipulated by
    # the other cmdlets.
    $Script = @{
        Progress = 0
        CurrentStage = $null
        StageCount = $Stages.Count
    }

    foreach ($Stage in $Stages) {
        $Script.CurrentStage = $Stage

        # Display the stage invocation in interactive output.
        Write-Host "($($Stage.Index + 1)/$($Script.StageCount))" -ForegroundColor Yellow -NoNewline
        Write-Host " Entering $($Stage.Name) stage." -ForegroundColor Cyan

        # Invoke the stage scriptblock, tunelling its output back to the host.
        Invoke-Command $Stage.Action | Write-Host

        # Make sure the stage is marked as completed (if it wasn't already done manually).
        $Stage.Completed = $true
    }
}