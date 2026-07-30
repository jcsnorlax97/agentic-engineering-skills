param(
    [string] $TargetRepo = (Get-Location).Path,

    [string] $Pack = "karpathy-principles",

    [string[]] $Tools = @("codex", "claude"),

    [switch] $CreateMissing,

    [switch] $SkipMissing,

    [switch] $DryRun
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)
$packRoot = Join-Path $repoRoot "baselines/$Pack"

if (-not (Test-Path -LiteralPath $packRoot)) {
    throw "Unknown portable baseline pack: $Pack"
}

$toolMap = @{
    codex = @{ Target = "AGENTS.md"; Adapter = "AGENTS.md.block" }
    claude = @{ Target = "CLAUDE.md"; Adapter = "CLAUDE.md.block" }
    copilot = @{ Target = ".github/copilot-instructions.md"; Adapter = "copilot-instructions.md.block" }
}

function Read-Utf8Text($Path) {
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Write-Utf8Text($Path, $Text) {
    $encoding = [System.Text.UTF8Encoding]::new($false)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Text, $encoding)
}

$resolvedTarget = (Resolve-Path -LiteralPath $TargetRepo).Path
$packName = [regex]::Escape($Pack)

function Get-BlockPattern($Marker, $EscapedPackName) {
    $escapedMarker = [regex]::Escape($Marker)
    return "<!-- BEGIN ${escapedMarker}:$EscapedPackName v[^>]+ -->.*?<!-- END ${escapedMarker}:$EscapedPackName -->"
}

$newPattern = Get-BlockPattern "baseline" $packName
$legacyPattern = Get-BlockPattern "portable-agent-baseline" $packName

foreach ($tool in $Tools) {
    if (-not $toolMap.ContainsKey($tool)) {
        throw "Unsupported tool '$tool'. Supported tools: $($toolMap.Keys -join ', ')"
    }

    $targetRel = $toolMap[$tool].Target
    $adapterRel = $toolMap[$tool].Adapter
    $targetPath = Join-Path $resolvedTarget $targetRel
    $adapterPath = Join-Path (Join-Path $packRoot "adapters") $adapterRel
    $block = (Read-Utf8Text $adapterPath).Trim()

    if (-not (Test-Path -LiteralPath $targetPath)) {
        if ($SkipMissing) {
            Write-Output "skip missing $targetRel for $tool in $resolvedTarget"
            continue
        }

        if ($DryRun) {
            Write-Output "would create $targetRel with $Pack for $tool"
            continue
        }

        Write-Utf8Text $targetPath ($block + [Environment]::NewLine)
        Write-Output "created $targetRel with $Pack for $tool"
        continue
    }

    $current = Read-Utf8Text $targetPath
    $hasNewBlock = [regex]::IsMatch($current, $newPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $hasLegacyBlock = [regex]::IsMatch($current, $legacyPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

    if ($hasNewBlock -and $hasLegacyBlock) {
        throw "Both baseline and legacy portable-agent-baseline blocks exist for $Pack in $targetRel; resolve the duplicate manually."
    }

    if ($hasNewBlock -or $hasLegacyBlock) {
        $pattern = if ($hasNewBlock) { $newPattern } else { $legacyPattern }
        $next = [regex]::Replace($current, $pattern, $block, [System.Text.RegularExpressions.RegexOptions]::Singleline)
        $pastAction = if ($hasLegacyBlock) { "migrated" } else { "updated" }
        $planAction = if ($hasLegacyBlock) { "migrate" } else { "update" }
    } else {
        $next = $current.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine + $block + [Environment]::NewLine
        $pastAction = "added"
        $planAction = "add"
    }

    if ($DryRun) {
        Write-Output "would $planAction $Pack in $targetRel for $tool"
        continue
    }

    Write-Utf8Text $targetPath $next
    Write-Output "$pastAction $Pack in $targetRel for $tool"
}
