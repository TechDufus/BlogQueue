#Region action.ps1

<#
.SYNOPSIS
    This will move a queue'd post to be published.
.DESCRIPTION
    This will move a queue'd post to be published to your blog and trigger a redeployment.
.PARAMETER Path
    The path to the queue of posts to be published.
.PARAMETER Destination
    The path to the blog to publish to.
.EXAMPLE
    action.ps1 -Path "./temp/posts_queue" -Destination "./blog/_posts/"
.NOTES
    Author:  matthewjdegarmo
    GitHub:  https://github.com/matthewjdegarmo
    Sponsor: https://github.com/sponsors/matthewjdegarmo
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [System.String]$Path,
    
    [Parameter(Mandatory)]
    [System.String]$Destination
)

Begin {}

Process {
    Try {
        # Get 1 file from the queue
        $QueueFile = Get-ChildItem -Path $Path | Select-Object -First 1

        # Move that file to the posts directory
        Move-Item -Path $QueueFile.FullName -Destination $Destination -Force

        # Git add commit push that file to github repo to trigger new site deploy
        Push-Location $Destination
        git add -A
        git commit -m "Adding new post from queue: $($QueueFile.Name)"
        git push
        Pop-Location
    } Catch {
        Throw $_
    }
}

End {}

#EndRegion action.ps1