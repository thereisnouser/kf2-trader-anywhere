[CmdletBinding()]
param(
    [string]$ServerDir,
    [string]$PackagePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($PackagePath)) {
    $PackagePath = Join-Path $PSScriptRoot 'TraderAnywhere.u'
}

if (-not (Test-Path -LiteralPath $PackagePath -PathType Leaf)) {
    throw 'TraderAnywhere.u not found. Extract the complete release ZIP or pass -PackagePath.'
}
$package = Get-Item -LiteralPath $PackagePath
if ($package.Name -ine 'TraderAnywhere.u' -or $package.Length -eq 0) {
    throw 'Expected a non-empty TraderAnywhere.u package.'
}

if ([string]::IsNullOrWhiteSpace($ServerDir)) {
    $ServerDir = Read-Host 'Enter the KF2 dedicated server folder (containing KFGame and Binaries)'
}
$ServerDir = $ServerDir.Trim().Trim('"')
if ([string]::IsNullOrWhiteSpace($ServerDir)) {
    throw 'No server folder supplied.'
}
$root = Get-Item -LiteralPath $ServerDir
if (-not $root.PSIsContainer) {
    throw 'Select a directory, not a file.'
}
$exe = Join-Path $root.FullName 'Binaries\Win64\KFServer.exe'
$targetDir = Join-Path $root.FullName 'KFGame\BrewedPC'
if (-not (Test-Path -LiteralPath $exe -PathType Leaf) -or
    -not (Test-Path -LiteralPath $targetDir -PathType Container)) {
    throw "Not a KF2 dedicated server installation: $($root.FullName)"
}

$destination = Join-Path $targetDir 'TraderAnywhere.u'
$sourceHash = (Get-FileHash -LiteralPath $package.FullName -Algorithm SHA256).Hash
$existing = Test-Path -LiteralPath $destination -PathType Leaf

if ($existing -and (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -eq $sourceHash) {
    Write-Host 'Trader Anywhere is already installed (identical package).'
}
else {
    # Instances can share one installation. Do not replace files under a running server.
    $running = @(Get-CimInstance Win32_Process -Filter "Name='KFServer.exe'" |
        Where-Object {
            [string]::IsNullOrWhiteSpace($_.ExecutablePath) -or
            [string]::Equals($_.ExecutablePath, $exe, [StringComparison]::OrdinalIgnoreCase)
        })
    if ($running.Count -gt 0) {
        throw 'Stop all KF2 server instances using this installation first. If process paths are inaccessible, run with appropriate privileges.'
    }

    $backup = $null
    if ($existing) {
        $backupDir = Join-Path $root.FullName 'TraderAnywhere-backups'
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        $backup = Join-Path $backupDir ('TraderAnywhere-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N') + '.u')
        Copy-Item -LiteralPath $destination -Destination $backup
        Write-Host "Previous package backed up to: $backup"
    }

    try {
        Copy-Item -LiteralPath $package.FullName -Destination $destination -Force
        if ((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -ne $sourceHash) {
            throw 'Installed package hash does not match source.'
        }
    }
    catch {
        if ($backup) {
            Copy-Item -LiteralPath $backup -Destination $destination -Force
        }
        elseif (Test-Path -LiteralPath $destination -PathType Leaf) {
            Remove-Item -LiteralPath $destination
        }
        throw
    }
    Write-Host "Installed: $destination" -ForegroundColor Green
}

# Create a separate basic launcher without touching any existing server scripts.
$launcherText = @'
@echo off
setlocal
pushd "%~dp0" || exit /b 1
if not exist "Binaries\Win64\KFServer.exe" (
    echo KFServer.exe not found. Keep this launcher in your KF2 server folder.
    pause
    popd
    exit /b 1
)
if not exist "KFGame\BrewedPC\TraderAnywhere.u" (
    echo Trader Anywhere is not installed. Run install.cmd from the release ZIP first.
    pause
    popd
    exit /b 1
)
echo Trader Anywhere - basic Survival server on Spillway
echo Uses the default launch settings, not your existing custom launcher.
echo Stop any other KF2 servers using the same ports before continuing.
choice /C YN /N /M "Start the server now? [Y/N] "
if not "%ERRORLEVEL%"=="1" (
    popd
    exit /b 0
)
".\Binaries\Win64\KFServer.exe" "KF-Spillway?Game=KFGameContent.KFGameInfo_Survival?Mutator=TraderAnywhere.TA_Mutator"
set "result=%ERRORLEVEL%"
if not "%result%"=="0" (
    echo Server exited with error %result%. Check KFGame\Logs.
    pause
)
popd
exit /b %result%
'@
$launcherText = ($launcherText -replace '\r?\n', "`r`n") + "`r`n"
$launcherPath = $null

try {
    foreach ($name in @('StartServer.cmd', 'StartServer-TraderAnywhere.cmd')) {
        $candidate = Join-Path $root.FullName $name
        if (Test-Path -LiteralPath $candidate) {
            if ((Test-Path -LiteralPath $candidate -PathType Leaf) -and
                [System.IO.File]::ReadAllText($candidate) -ceq $launcherText) {
                $launcherPath = $candidate
                break
            }
            continue
        }

        # CreateNew prevents overwriting even if a file appears after the check.
        $stream = [System.IO.File]::Open($candidate, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
        try {
            $bytes = [System.Text.Encoding]::ASCII.GetBytes($launcherText)
            $stream.Write($bytes, 0, $bytes.Length)
        }
        finally {
            $stream.Dispose()
        }
        $launcherPath = $candidate
        break
    }
    if ($launcherPath) {
        Write-Host ''
        Write-Host "Basic server launcher: $launcherPath" -ForegroundColor Green
        Write-Host 'Open your server folder and double-click this file to start a basic Survival server.'
    }
    else {
        Write-Warning 'Both launcher filenames are already in use. Existing files were preserved. Use your existing launcher as described below.'
    }
}
catch {
    Write-Warning "The mod is installed, but the optional basic launcher could not be created: $($_.Exception.Message)"
}

Write-Host ''
Write-Host 'To keep your existing custom server settings, add this to your normal launch URL:'
Write-Host '  ?Mutator=TraderAnywhere.TA_Mutator' -ForegroundColor Cyan
Write-Host 'Already using mutators? Append ,TraderAnywhere.TA_Mutator to the existing Mutator list instead.'
Write-Host 'Existing launch scripts and server configuration were not changed.'
Write-Host 'This is an unofficial mod for modded servers; Ranked progression is not supported.'
