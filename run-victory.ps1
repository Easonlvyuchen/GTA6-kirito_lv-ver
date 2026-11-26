param(
    [Parameter(Mandatory)][string]$VictorySource,
    [Parameter(Mandatory)][string]$GameExe,
    [Parameter(Mandatory)][string]$GameDir,
    [ValidateSet('0', '1', 'light', 'faults')][string]$Dred = '1',
    [switch]$Execute
)

$ErrorActionPreference = 'Stop'
$source = (Resolve-Path -LiteralPath $VictorySource).Path
$binary = Join-Path $source 'target\diag\victory.exe'
$game = (Resolve-Path -LiteralPath $GameExe).Path
$package = (Resolve-Path -LiteralPath $GameDir).Path
if (-not (Test-Path -LiteralPath $binary -PathType Leaf)) {
    throw "Build VIctory first. Expected $binary"
}
if (-not (Test-Path -LiteralPath $game -PathType Leaf)) {
    throw "GameExe must be a file. Got $game"
}
if (-not (Test-Path -LiteralPath $package -PathType Container)) {
    throw "GameDir must be a directory. Got $package"
}

$state = Join-Path $env:LOCALAPPDATA 'GTA6-kirito_lv-ver'
$settings = @{
    VICTORY_GAME_DIR = $package
    VICTORY_DATA_DIR = Join-Path $state 'data'
    VICTORY_CACHE_DIR = Join-Path $state 'cache'
    VICTORY_D3D12_DRED = $Dred
    VICTORY_TEXTURE_NO_WAIT = '0'
    VICTORY_LATE_WAIT = '0'
    VICTORY_RELAY = '0'
    VICTORY_RELAY_COPY = '0'
    VICTORY_CARD_STEPS = '0'
    VICTORY_JOIN_COPIES = '0'
    VICTORY_WIDE_BACK = '1'
    VICTORY_CARD_REHASH_RUNS = '1'
    VICTORY_INDIRECT_WINDOW = '1'
    VICTORY_INDIRECT_BATCH = '2'
    VICTORY_MAP_THREADS = '1'
    VICTORY_TITLE_PRIORITIES = '0'
    VICTORY_CARD_AWAKE = '1'
    VICTORY_SHOW_AFTER = '1'
    VICTORY_AMBIENT = '0.8'
    VICTORY_UNDER_WIDE = '0'
    VICTORY_LAND_ECHO = '0'
}

$arguments = @('run', $game)
if ($Execute) { $arguments += '--execute' }

$previous = @{}
Push-Location -LiteralPath $source
try {
    foreach ($entry in $settings.GetEnumerator()) {
        $previous[$entry.Key] = [Environment]::GetEnvironmentVariable($entry.Key, 'Process')
        [Environment]::SetEnvironmentVariable($entry.Key, $entry.Value, 'Process')
    }
    & $binary @arguments
    exit $LASTEXITCODE
} finally {
    foreach ($entry in $previous.GetEnumerator()) {
        [Environment]::SetEnvironmentVariable($entry.Key, $entry.Value, 'Process')
    }
    Pop-Location
}
