# Posh-Bootstrap

[![latest release][GitHubReleaseBadge]][GitHubReleaseLink]
[![powershellgallery version][PowerShellGalleryBadge]][PowerShellGalleryLink]
[![license][LicenseBadge]][LicenseLink]

A *PowerShell* module that allows for writing clean bootstrapper scripts.

## Installation

### PowerShell Gallery

Run the following command in a *PowerShell* session to install the module:

```PowerShell
Install-Module -Name Posh-Bootstrap
```

This module runs on *Windows PowerShell* 5.1 or greater and *PowerShell Core*.

If you have an earlier version of the `Posh-Bootstrap` module installed from *PowerShell Gallery* and would like to update to the latest version, run the following command in a *PowerShell* session:

```PowerShell
Update-Module -Name Posh-Bootstrap
```

## Usage

To use the module in your scripts, first import it:

```PowerShell
Import-Module -Name Posh-Bootstrap
```

Then create your script structure:

```PowerShell
@(
    $(New-Stage -Name "Build" -Action { }),
    $(New-Stage -Name "Copy" -Action { }),
    $(New-Stage -Name "Run", -Action { })
)
```

These stages will be invoked one after another. You can place your code in the `Action` *ScriptBlock*s as follows:

```PowerShell
New-Stage -Name "Build" -Action {
    Update-Progress -Progress 0 -CurrentOperation "Initializing Build Engine"

    # This cmdlet calls the `OutputDelegate` ScriptBlock every time the process outputs a line to stdout.
    Watch-Process -ProcessFileName "dotnet" -ProcessArgs "publish $BuildPath" -RedirectOutput -OutputDelegate { param($Output)
        if ($Output.Contains("Microsoft (R) Build Engine") -or $Output.Contains("Copyright (C) Microsoft Corporation")) {
            Update-Progress -Progress 5 -CurrentOperation "Initialized Build Engine"
        } elseif ($Output.Contains(" -> ")) {
            Update-Progress -Progress 95 -CurrentOperation "Finished building solution"
        } else {
            Update-Progress -Progress 15 -CurrentOperation "Building solution"
        }
    }
}
```

```PowerShell
New-Stage -Name "Run" -Action {
    Complete-Stage -CurrentOperation "Running from remote at $Address"
    Invoke-Command -Session $script:Session {
        Set-Location $using:ExecutionPath
        dotnet $Executable
    }
}
```

Note the use of the cmdlets `Update-Progress` and `Complete-Stage`. These can be used inside script stages to update their running status.
- `Update-Progress` updates the progress and the current operation of the currently running stage, and reflects these changes in the script's progress bar *(if any)*.
- `Complete-Stage` marks the currently running stage as completed and updates its current operation in the process. This is useful when the script should exit earlier then the end of the final stage *(e.g. when the script prepares an interactive environment and the final stage drops into this environment - the script should be deemed complete even though the final stage is still waiting on the interactive environment to be closed)*.

Finally, invoke the script as follows:

```PowerShell
Invoke-Script @(
    $(New-Stage -Name "Build" -Action {
        [...]
    }),
    $(New-Stage -Name "Copy" -Action {
        [...]
    }),
    $(New-Stage -Name "Run", -Action {
        [...]
    })
)
```

In addition, you can set the progress bar display style to use when running the script:

```PowerShell
Invoke-Script @() -ProgressMode { Full | Compact | None }
```

Below is an example for a complete script:

```PowerShell
#Requires -Modules Posh-Bootstrap
Import-Module Posh-Bootstrap

try {
    Invoke-Script @(
        # Build the project using `dotnet publish`.
        $(New-Stage "Build" {
            Update-Progress 0 "Initializing Build Engine"

            # This cmdlet calls the `OutputDelegate` ScriptBlock every time the process outputs a line to stdout.
            Watch-Process -ProcessFileName "dotnet" -ProcessArgs "publish $BuildPath" -RedirectOutput -OutputDelegate { param($Output)
                if ($Output.Contains("Microsoft (R) Build Engine") -or $Output.Contains("Copyright (C) Microsoft Corporation")) {
                    Update-Progress 5 "Initialized Build Engine"
                } elseif ($Output.Contains(" -> ")) {
                    Update-Progress 95 "Finished building solution"
                } else {
                    Update-Progress 15 "Building solution"
                }
            }
        }),
        # Copy the build files to the remote machine.
        $(New-Stage "Copy" {
            Update-Progress 0 "Establishing connection with the remote"
            $script:Session = New-PSSession -HostName $Address -UserName $User

            Update-Progress 0 "Copying files to remote"
            $Files = Get-ChildItem $Source -File -Recurse
            for ($i = 0; $i -lt $Files.Count; $i++) {
                $File = $Files[$i]

                # This cmdlet returns the path relative to `Root`.
                $RelativePath = Get-RelativePath -Path $File -Root $Source
                $DestinationFile = Split-Path (Join-Path -Path $Destination -ChildPath $RelativePath.Substring(2))

                Update-Progress $($i / $Files.Count * 100) "Copying $RelativePath"
                Copy-Item $File -Destination $DestinationFile -ToSession $script:Session -Force

                Write-Host "Copied $RelativePath"
            }
        }),
        # Run the executable on the remote machine, piping its output back to the host.
        $(New-Stage "Run" {
            Complete-Stage "Running from remote at $Address"
            Write-Host "Running from remote at $Address" -ForegroundColor Yellow
            Invoke-Command -Session $script:Session {
                Set-Location $using:ExecutionPath
                dotnet $Executable
            }
        })
    )
} finally {
    # Terminate the connection with the remote machine even when the script was interrupted.
    Write-Host "Terminating connection with remote." -ForegroundColor Yellow
    Remove-PSSession -Session $script:Session
}
```

### Cmdlet help and examples

To view the help content for a cmdlet, use the `Get-Help` cmdlet:

```PowerShell
# View the basic help content for Invoke-Script
Get-Help -Name Invoke-Script

# View the examples for Invoke-Script
Get-Help -Name Invoke-Script -Examples

# View the full help content for Invoke-Script
Get-Help -Name Invoke-Script -Full
```

## Reporting Issues and Feedback

### Issues

If you find any bugs when using `Posh-Bootstrap`, please file an issue on our [GitHub issues][GitHubIssuesLink] page.

### Feedback

If there is a feature you would like to see in `Posh-Bootstrap`, please file an issue on our [GitHub issues][GitHubIssuesLink] page to provide feedback.

## Contribute Code

Any code contribution is welcome in the form of pull requests through GitHub.

[GitHubReleaseBadge]: https://img.shields.io/github/v/release/zalanlevai/Posh-Bootstrap?style=flat-square
[GitHubReleaseLink]: https://github.com/zalanlevai/Posh-Bootstrap/releases
[PowerShellGalleryBadge]: https://img.shields.io/powershellgallery/v/Posh-Bootstrap?style=flat-square
[PowerShellGalleryLink]: https://www.powershellgallery.com/packages/Posh-Bootstrap
[LicenseBadge]: https://img.shields.io/github/license/zalanlevai/Posh-Bootstrap?style=flat-square
[LicenseLink]: https://github.com/zalanlevai/Posh-Bootstrap/blob/master/LICENSE

[GitHubIssuesLink]: https://github.com/zalanlevai/Posh-Bootstrap/issues