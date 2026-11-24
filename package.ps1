[CmdletBinding()]
param(
    [string]$SdkDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$dist = Join-Path $PSScriptRoot 'dist'
$binary = Join-Path $dist 'BrewedPC\Script\TraderAnywhere.u'
if (-not [string]::IsNullOrWhiteSpace($SdkDir)) {
    & (Join-Path $PSScriptRoot 'build.ps1') -SdkDir $SdkDir -Brew
}

$files = @(
    $binary
    (Join-Path $PSScriptRoot 'install.ps1')
    (Join-Path $PSScriptRoot 'install.cmd')
    (Join-Path $PSScriptRoot 'LICENSE')
)
foreach ($file in $files) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf) -or (Get-Item -LiteralPath $file).Length -eq 0) {
        throw "Missing or empty release file: $file. Build the mod first or supply -SdkDir."
    }
}

$zip = Join-Path $dist 'TraderAnywhere-0.1.0.zip'
$temporary = Join-Path $dist ('TraderAnywhere-' + [guid]::NewGuid().ToString('N') + '.zip')
try {
    Compress-Archive -LiteralPath $files -DestinationPath $temporary
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($temporary)
    try {
        $actual = @($archive.Entries | ForEach-Object { $_.FullName } | Sort-Object)
        $expected = @('install.cmd', 'install.ps1', 'TraderAnywhere.u', 'LICENSE' | Sort-Object)
        if (($actual -join '|') -cne ($expected -join '|')) {
            throw 'Unexpected release archive contents.'
        }
        $entry = $archive.GetEntry('TraderAnywhere.u')
        $stream = $entry.Open()
        $sha = [System.Security.Cryptography.SHA256]::Create()
        try {
            $archivedHash = [BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-', '')
        }
        finally {
            $sha.Dispose()
            $stream.Dispose()
        }
        if ($archivedHash -ne (Get-FileHash -LiteralPath $binary -Algorithm SHA256).Hash) {
            throw 'Packaged binary hash does not match the build output.'
        }
    }
    finally {
        $archive.Dispose()
    }
    Copy-Item -LiteralPath $temporary -Destination $zip -Force
}
finally {
    if (Test-Path -LiteralPath $temporary -PathType Leaf) {
        Remove-Item -LiteralPath $temporary
    }
}

Write-Host "Release archive: $zip" -ForegroundColor Green
