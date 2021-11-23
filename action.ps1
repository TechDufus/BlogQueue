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
    [System.String]$Destination,

    [Parameter(Mandatory)]
    [System.Object] $CommitterUsername,

    [Parameter(Mandatory)]
    [System.Object] $CommitterEmail
)

Begin {
     #Region Commit-GitRepo
    
     Function Commit-GitRepo() {
        [CmdletBinding()]
        [SuppressMessage('PSUseApprovedVerbs', '')]
        Param(
            [Parameter(Mandatory)]
            [System.Object[]] $CommitMessage,
        
            [Parameter(Mandatory)]
            [System.Object[]] $CommitterUsername,
        
            [Parameter(Mandatory)]
            [System.Object[]] $CommitterEmail
        )
    
        Process {
            git config --local user.name "$CommitterUsername"
            git config --local user.email "$CommitterEmail"
    
            git add -A
            git commit -m "$CommitMessage"
            git push
        }
    }
    #EndRegion Commit-GitRepo
}

Process {
    Try {
        # Get 1 file from the queue
        $QueueFile = Get-ChildItem -Path $Path | Select-Object -First 1

        If ($QueueFile.Count -gt 0) {
            # Move that file to the posts directory
            Move-Item -Path $QueueFile.FullName -Destination $Destination -Force
    
            $commitGitRepoSplat = @{
                CommitMessage     = "Adding new post from queue: $($QueueFile.Name)"
                CommitterUsername = $CommitterUsername
                CommitterEmail    = $CommitterEmail
            }
            
            # Git add commit push that file to github repo to trigger new site deploy
            Push-Location $Destination
            Commit-GitRepo @commitGitRepoSplat
            Pop-Location
        }
    } Catch {
        Throw $_
    }
}

End {}

#EndRegion action.ps1