@{
    # Author information
    Author = 'Zalán Bálint Lévai'
    CompanyName = 'zalanlevai'
    Copyright = '(c) Zalán Bálint Lévai. All rights reserved.'

    # ID used to uniquely identify this module
    GUID = '515d756b-310f-42f5-aeb8-0121580dd1df'

    # Description of the functionality provided by this module
    Description = 'A PowerShell module that allows for writing clean bootstrapper scripts.'

    # Version number of this module
    ModuleVersion = '1.0.1'

    # Script module or binary module file associated with this manifest
    RootModule = 'Posh-Bootstrap.psm1'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'
    CompatiblePSEditions = @( 'Desktop', 'Core' )

    # Third-party metadata
    PrivateData = @{
        # PowerShell Gallery metadata
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @( 'Bootstrap', 'Bootstrapping', 'Script', 'Scripting', 'Authoring', 'Progress', 'Progressbar', 'ProgressBar' )

            # URIs
            ProjectUri = 'https://github.com/zalanlevai/Posh-Bootstrap'
            LicenseUri = 'https://github.com/zalanlevai/Posh-Bootstrap/blob/master/LICENSE'
        }
    }
}