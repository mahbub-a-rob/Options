[CmdletBinding(PositionalBinding=$false)]
param(
    [switch]$SkipKoreBuildUpdate,
    [switch]$RecloneKoreBuild,
    [string]$KoreBuildRepo,
    [string]$KoreBuildBranch = "anurse/msbuild", # TEMPORARY until this is merged to dev
    [string]$KoreBuildDestination = "$PSScriptRoot\.build",
    [Parameter(ValueFromRemainingArguments=$true)][string[]]$KoreBuildArgs)

if($RecloneKoreBuild -or !$SkipKoreBuildUpdate) {
    if($RecloneKoreBuild) {
        del -rec -for $KoreBuildDestination
    }

    if(Test-Path "$KoreBuildDestination\.git") {
        Write-Host -ForegroundColor Green "Updating KoreBuild..."
        pushd $KoreBuildDestination
        git checkout $KoreBuildBranch 2>&1 | ForEach-Object { Write-Host -ForegroundColor DarkGray $_ }
        git pull origin $KoreBuildBranch 2>&1 | ForEach-Object { Write-Host -ForegroundColor DarkGray $_ }
        popd
    } else {
        if(Test-Path $KoreBuildDestination) {
            del -rec -for $KoreBuildDestination
        }
        Write-Host -ForegroundColor Green "Fetching KoreBuild..."

        if(!$KoreBuildRepo) {
            # Check what the origin is for this repo so we can match the type (SSL/HTTPS)
            pushd $PSScriptRoot
            $ThisRepo = git remote get-url origin
            popd

            if($ThisRepo.StartsWith("http")) {
                $KoreBuildRepo = "https://github.com/aspnet/KoreBuild"
            } else {
                $KoreBuildRepo = "git@github.com:aspnet/KoreBuild"
            }
        }

        git clone $KoreBuildRepo -b $KoreBuildBranch $KoreBuildDestination 2>&1 | ForEach-Object { Write-Host -ForegroundColor DarkGray $_ }
    }
}

if(($KoreBuildArgs -contains "-t:") -or ($KoreBuildArgs -contains "-p:")) {
    throw "Due to PowerShell weirdness, you need to use '/t:' and '/p:' to pass targets and properties to MSBuild"
}

# Launch KoreBuild
try {
    pushd $PSScriptRoot
    & "$KoreBuildDestination\build\KoreBuild.ps1" @KoreBuildArgs
} finally {
    popd
}
