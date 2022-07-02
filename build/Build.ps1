
# Copyright (c) @asmichi (https://github.com/asmichi). Licensed under the MIT License. See LICENCE in the project root for details.

# Build the package.

#Requires -Version 7.0

param(
    [parameter()]
    [switch]
    $AllowRetailRelease = $false
)

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

$worktreeRoot = Resolve-Path "$PSScriptRoot\.."

function Get-VersionInfo {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CommitHash,
        [Parameter(Mandatory = $true)]
        [string]
        $BranchName,
        [parameter()]
        [switch]
        $AllowRetailRelease
    )

    $isProtectedBranch = $BranchName -eq "master" -or $BranchName -clike "release/*"
    $shortCommitHash = $CommitHash.Substring(0, 10)
    $recentTag = $(git describe --abbrev=0)
    $commitCount = $(git rev-list --count "${recentTag}..HEAD")
    $baseVersion = Get-Content "$worktreeRoot\build\Version.txt"
    $retailRelease = $false
    if ($AllowRetailRelease) {
        [System.Object[]]$tags = $(git tag --points-at HEAD)
        $retailRelease = $null -ne $tags -and $tags.Length -gt 0
    }
    $packageVersion = if ($retailRelease) {
        return @{
            PackageVersion          = $baseVersion;
            PackageReferenceVersion = $baseVersion;
        }
    }
    elseif ($isProtectedBranch) {
        return @{
            PackageVersion          = "$baseVersion-pre.$commitCount+g$shortCommitHash";
            PackageReferenceVersion = "$baseVersion-pre.$commitCount";
        }
    }
    else {
        # On non-protected branches (typically feature branches), the commit hash should be included in the prerelease version
        # (not in the build metadata) so that versions from different branches will be correctly distinguished.
        return @{
            PackageVersion          = "$baseVersion-pre.$commitCount.g$shortCommitHash";
            PackageReferenceVersion = "$baseVersion-pre.$commitCount.g$shortCommitHash";
        }
    }

    return @{
        PackageVersion          = $packageVersion;
        PackageReferenceVersion = $packageReferenceVersion;
    }
}

$commitHash = $(git rev-parse HEAD)
$branchName = $(git rev-parse --abbrev-ref HEAD)
$versionInfo = Get-VersionInfo -CommitHash $commitHash -BranchName $branchName -AllowRetailRelease:$AllowRetailRelease

$versionInfo | Out-Host

$binDir = "${worktreeRoot}/bin"
$contentsDir = "${worktreeRoot}/bin/contents"
$contentsBuildDir = "${worktreeRoot}/bin/contents/build"

New-Item -ItemType Directory -Path $binDir -Force | Out-Null
New-Item -ItemType Directory -Path $contentsDir -Force | Out-Null
New-Item -ItemType Directory -Path $contentsBuildDir -Force | Out-Null

$propsTemplateText = Get-Content "${worktreeRoot}/src/Asmichi.InjectNativeFileDepsHack.template.props"
$propsText = $propsTemplateText.Replace("[insert_version_here]", $versionInfo.PackageReferenceVersion)
Set-Content -LiteralPath "$contentsBuildDir/Asmichi.InjectNativeFileDepsHack.props" -Value $propsText
Copy-Item "${worktreeRoot}/src/Asmichi.InjectNativeFileDepsHack.targets" "$contentsBuildDir/Asmichi.InjectNativeFileDepsHack.targets"

nuget pack "${worktreeRoot}/src/Asmichi.InjectNativeFileDepsHack.nuspec" -BasePath $contentsDir -OutputDirectory $binDir -Version $versionInfo.PackageVersion
