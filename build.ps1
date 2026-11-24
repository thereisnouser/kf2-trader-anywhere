param(
    [Parameter(Mandatory = $true)]
    [string]$SdkDir,

    [string]$UserKFGameDir = (Join-Path (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'My Games\KillingFloor2') 'KFGame'),

    [switch]$Brew
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$packageName = 'W4AllTraders'
$editorDir = Join-Path $SdkDir 'Binaries\Win64'
$editorExe = Join-Path $editorDir 'KFEditor.exe'
$sourceDir = Join-Path $projectRoot "$packageName\Classes"
$targetDir = Join-Path $UserKFGameDir "Src\$packageName\Classes"
$editorIni = Join-Path $UserKFGameDir 'Config\KFEditor.ini'

if (-not (Test-Path -LiteralPath $editorExe -PathType Leaf)) {
    throw "KFEditor.exe not found: $editorExe"
}
if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) {
    throw "Source directory not found: $sourceDir"
}
if (-not (Test-Path -LiteralPath $editorIni -PathType Leaf)) {
    throw "KFEditor.ini not found: $editorIni. Run the KF2 SDK once first."
}

# Сохраняем байты INI без изменения кодировки и существующих настроек.
# Старый шаблон не учитывал CRLF, поэтому добавлял [ModPackages] при каждой сборке.
$configEncoding = [System.Text.Encoding]::GetEncoding(28591)
$iniText = $configEncoding.GetString([System.IO.File]::ReadAllBytes($editorIni))
$updatedIni = $iniText
$linePattern = '(?im)^[ \t]*ModPackages[ \t]*=[ \t]*W4AllTraders[ \t]*(?:\r?\n|$)'
$packageLines = [regex]::Matches($iniText, $linePattern)
$lineEnding = if ($iniText.Contains("`r`n")) { "`r`n" } else { "`n" }

if ($packageLines.Count -gt 1) {
    # Удаляем только повторные строки нашего пакета, не затрагивая другие моды.
    for ($i = $packageLines.Count - 1; $i -ge 1; $i--) {
        $updatedIni = $updatedIni.Remove($packageLines[$i].Index, $packageLines[$i].Length)
    }
}
elseif ($packageLines.Count -eq 0) {
    $sectionPattern = '(?im)^[ \t]*\[ModPackages\][ \t]*(?:\r?\n|$)'
    $sections = [regex]::Matches($updatedIni, $sectionPattern)

    if ($sections.Count -gt 0) {
        $section = $sections[0]
        $prefix = if ($section.Value.EndsWith("`n")) { '' } else { $lineEnding }
        $updatedIni = $updatedIni.Insert(
            $section.Index + $section.Length,
            $prefix + 'ModPackages=W4AllTraders' + $lineEnding
        )
    }
    else {
        if (!$updatedIni.EndsWith("`n")) {
            $updatedIni += $lineEnding
        }
        $updatedIni += '[ModPackages]' + $lineEnding + 'ModPackages=W4AllTraders' + $lineEnding
    }
}

if ($updatedIni -cne $iniText) {
    $backupName = $editorIni + '.w4alltraders-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.bak'
    Copy-Item -LiteralPath $editorIni -Destination $backupName -ErrorAction Stop
    [System.IO.File]::WriteAllBytes($editorIni, $configEncoding.GetBytes($updatedIni))
    Write-Host "SDK config repaired (backup: $backupName)"
}

$registrationCount = [regex]::Matches($updatedIni, $linePattern).Count
if ($registrationCount -ne 1) {
    throw "Unexpected W4AllTraders registration count: $registrationCount in $editorIni"
}

New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
Copy-Item -Path (Join-Path $sourceDir '*.uc') -Destination $targetDir -Force

Write-Host 'Compiling W4AllTraders...'
$compile = Start-Process -FilePath $editorExe -WorkingDirectory $editorDir `
    -ArgumentList 'make -useunpublished -log' -Wait -PassThru
if ($compile.ExitCode -ne 0) {
    throw "KFEditor compile exit code: $($compile.ExitCode)"
}

$unpublished = Join-Path $UserKFGameDir 'Unpublished\BrewedPC\Script\W4AllTraders.u'
if (-not (Test-Path -LiteralPath $unpublished -PathType Leaf)) {
    throw "Compiled package not found: $unpublished. See KF2 SDK logs."
}

Write-Host "Compiled package: $unpublished"

if ($Brew) {
    Write-Host 'Brewing W4AllTraders...'
    $brewStartedUtc = [DateTime]::UtcNow
    $brewProcess = Start-Process -FilePath $editorExe -WorkingDirectory $editorDir `
        -ArgumentList 'brewcontent -platform=PC W4AllTraders -log' -Wait -PassThru
    if ($brewProcess.ExitCode -ne 0) {
        throw "KFEditor brew exit code: $($brewProcess.ExitCode)"
    }

    $publishedCandidates = @(
        (Join-Path $SdkDir 'KFGame\Published\BrewedPC\W4AllTraders.u'),
        (Join-Path $SdkDir 'KFGame\Published\BrewedPC\Script\W4AllTraders.u'),
        (Join-Path $UserKFGameDir 'Published\BrewedPC\Script\W4AllTraders.u'),
        (Join-Path $UserKFGameDir 'Published\BrewedPC\W4AllTraders.u')
    )
    $published = $publishedCandidates |
        Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
        ForEach-Object { Get-Item -LiteralPath $_ } |
        Where-Object { $_.LastWriteTimeUtc -ge $brewStartedUtc.AddSeconds(-5) } |
        Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -First 1
    if (-not $published) {
        throw 'Fresh brewed W4AllTraders.u not found in SDK or user Published folders. See SDK logs.'
    }

    $distDir = Join-Path $projectRoot 'dist\BrewedPC\Script'
    New-Item -ItemType Directory -Force -Path $distDir | Out-Null
    Copy-Item -LiteralPath $published.FullName -Destination (Join-Path $distDir 'W4AllTraders.u') -Force
    Write-Host "Brewed package: $(Join-Path $distDir 'W4AllTraders.u')"
}

Write-Host 'Done. No dedicated server files were modified.'
