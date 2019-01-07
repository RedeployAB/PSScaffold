<#
.SYNOPSIS
Combines several strings or paths to a single path.

.DESCRIPTION
Takes one or more strings as an array and merges them into a single path
with the help of [System.IO.Path]::Combine().

Same result can be achieved with Join-Path in PS 6.0 and above, but this
lets us be backwards compatible.

.PARAMETER Paths
Array of paths/strings to merge.

.EXAMPLE
Combine an array of paths into a single path.
Returns "C:\Windows\System32\etc\hosts" (on Windows).

Merge-Path "C:\Windows", "System32", "etc", "hosts"

.NOTES
Written by Lars Åkerlund, Redeploy AB.
#>
function Merge-Path {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Paths
    )

    process {
        [System.IO.Path]::Combine($paths) # The end
    }
}
