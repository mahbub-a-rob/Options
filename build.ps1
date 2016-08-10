$DefaultBuildToolsRepo = "aspnet/DnxTools"
$DefaultBuildToolsBranch = "anurse/aspnet-build"
$ErrorActionPreference = "Stop"

$BuildToolsRepo = $env:ASPNETBUILD_TOOLS_REPO
if(!$BuildToolsRepo) {
    $BuildToolsRepo = $DefaultBuildToolsRepo
}

$BuildToolsBranch = $env:ASPNETBUILD_TOOLS_BRANCH
if(!$BuildToolsBranch) {
    $BuildToolsBranch = $DefaultBuildToolsBranch
}

$InstallScriptUrl = $env:ASPNETBUILD_TOOLS_INSTALL_SCRIPT_URL
if(!$InstallScriptUrl) {
    $InstallScriptUrl = "https://raw.githubusercontent.com/$BuildToolsRepo/$BuildToolsBranch/scripts/install/install-aspnet-build.ps1"
}

$InstallScript = Join-Path (Join-Path $PSScriptRoot ".build") "install-aspnet-build.ps1"
if(!(Test-Path $InstallScript))
{
    $Parent = Split-Path -Parent $InstallScript
    if(!(Test-Path $Parent)) {
        mkdir $Parent | Out-Null
    }
    
    Write-Host -ForegroundColor Green "Fetching install script from $InstallScriptUrl ..."
    iwr $InstallScriptUrl -OutFile $InstallScript
}

# Look for a trainfile
$Trainfile = Join-Path $PSScriptRoot "Trainfile"
$Repofile = Join-Path $PSScriptRoot "Repofile"
try {
    if(Test-Path $Trainfile) {
        # Use the trainfile to install the latest tools
        & "$InstallScript" -Trainfile $Trainfile
    } elseif(Test-Path $Repofile) {
        # Use the repofile to install the latest tools
        & "$InstallScript" -Trainfile $Repofile
    } else {
        # Use the specified (or default) branch
        & "$InstallScript" -BuildToolsBranch $BuildToolsBranch
    }
} catch {
    # Unwrap the inner error
    throw $error[0]
}

# Get the Path
$BuildToolsPath = & "$InstallScript" -GetPath -BuildToolsBranch $BuildToolsBranch

# Launch the build tools
& "$BuildToolsPath\bin\aspnet-build.ps1" @args