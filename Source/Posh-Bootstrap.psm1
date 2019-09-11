# The directories to include in the module. This determines
# - the actions to take on each directory,
# - the files to include and exclude and
# - the order of processing.
# NOTE: The initialisation order matters; classes and enums must be loaded first, before the
#       cmdlets using them are initialised. Otherwise, the class references will fail.
$Directories = @(
    @{
        Path = "Classes"
        Export = $false
        Recurse = $true
        Filter = "*.Class.ps1"
        Exclude = @()
    },
    @{
        Path = "Enums"
        Export = $false
        Recurse = $true
        Filter = "*.Enum.ps1"
        Exclude = @()
    },
    @{
        Path = "Public"
        Export = $true
        Recurse = $true
        Filter = "*-*.ps1"
        Exclude = @()
    },
    @{
        Path = "Private"
        Export = $false
        Recurse = $true
        Filter = "*.ps1"
        Exclude = @()
    }
)

foreach ($Directory in $Directories) {
    $AbsolutePath = Join-Path $PSScriptRoot -ChildPath $Directory.Path

    $AbsolutePath | Get-ChildItem -Filter $Directory.Filter -Exclude $Directory.Exclude -Recurse:$Directory.Recurse -ErrorAction Ignore | ForEach-Object {
        try {
            $Unit = $_.FullName

            # Dot-source the file so that the rest of the module can reference it.
            . $Unit
            # Export members marked public. Note, that this only exports the function with the same
            # name as the file name it resides in.
            if ($Directory.Export) { Export-ModuleMember -Function $_.BaseName }
        } catch {
            throw $("Could not import '$Unit' with exception: `n`n`n$($_.Exception)" -as $_.Exception.GetType())
        }
    }
}