param(
    [Parameter(Position = 0)]
    [ValidateSet("list", "show", "add", "install", "apply", "verify", "shim", "help")]
    [string] $Command = "list",

    [Parameter(Position = 1)]
    [string] $Name = "",

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $RemainingArgs = @(),

    [ValidateSet("codex", "claude", "copilot", "all")]
    [string] $Target = "all",

    [ValidateSet("personal", "project")]
    [string] $Scope = "personal",

    [switch] $User,

    [switch] $Repo,

    [string] $TargetRepo = (Get-Location).Path,

    [switch] $Copy,

    [switch] $Link,

    [switch] $KeepExisting,

    [string] $InstallDir = "",

    [switch] $AddToUserPath
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$skillsRoot = Join-Path $repoRoot "skills"
$targetWasProvided = $PSBoundParameters.ContainsKey("Target")
$scopeWasProvided = $PSBoundParameters.ContainsKey("Scope")
$positionalTargetWasProvided = $false
$positionalScopeWasProvided = $false

function Stop-WithMessage($Message, $Suggestion = "") {
    [Console]::Error.WriteLine("skills: $Message")
    if ($Suggestion) {
        [Console]::Error.WriteLine("Suggestion: $Suggestion")
    }
    exit 1
}

if ($User -and $Repo) {
    Stop-WithMessage "choose either -User or -Repo, not both."
}

function Set-PositionalScope($NextScope) {
    if ($User -and $NextScope -ne "personal") {
        Stop-WithMessage "positional scope conflicts with -User." "Use either -User or repo/project, not both."
    }
    if ($Repo -and $NextScope -ne "project") {
        Stop-WithMessage "positional scope conflicts with -Repo." "Use either -Repo or user/personal, not both."
    }
    if ($scopeWasProvided -and $Scope -ne $NextScope) {
        Stop-WithMessage "positional scope conflicts with -Scope $Scope." "Use one scope: user or repo."
    }

    $script:Scope = $NextScope
    $script:scopeWasProvided = $true
    $script:positionalScopeWasProvided = $true
}

function Set-PositionalTarget($NextTarget) {
    if ($targetWasProvided -and $Target -ne $NextTarget) {
        Stop-WithMessage "positional target conflicts with -Target $Target." "Use one target: codex, claude, copilot, or all."
    }

    $script:Target = $NextTarget
    $script:targetWasProvided = $true
    $script:positionalTargetWasProvided = $true
}

function Resolve-PositionalSkillArgs {
    if (@("install", "apply", "add", "list", "verify") -notcontains $Command) {
        return
    }

    $tokens = @()
    if ($Name) {
        $tokens += $Name
    }
    $tokens += @($RemainingArgs)
    $script:Name = ""

    $skillNames = @()
    foreach ($token in $tokens) {
        $normalized = $token.ToLowerInvariant()
        if ($normalized -eq "user" -or $normalized -eq "personal") {
            Set-PositionalScope "personal"
        } elseif ($normalized -eq "repo" -or $normalized -eq "project") {
            Set-PositionalScope "project"
        } elseif (@("codex", "claude", "copilot", "all") -contains $normalized) {
            Set-PositionalTarget $normalized
        } else {
            $skillNames += $token
        }
    }

    if ($skillNames.Count -gt 1) {
        Stop-WithMessage "too many skill names: $($skillNames -join ', ')." "Use one skill name, for example: skills install repo query-azure-devops claude"
    }

    if ($skillNames.Count -eq 1) {
        $script:Name = $skillNames[0]
    }
}

Resolve-PositionalSkillArgs

if ($User) {
    $Scope = "personal"
    $scopeWasProvided = $true
}

if ($Repo) {
    $Scope = "project"
    $scopeWasProvided = $true
}

function Require-ExplicitScope($Action) {
    if ($scopeWasProvided -or $positionalScopeWasProvided) {
        return
    }

    Stop-WithMessage "choose where to $Action skills." "Use -User/-Repo, or positional user/repo. Examples: skills install user codex; skills install repo query-azure-devops claude"
}

function Read-Utf8Text($Path) {
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Write-Utf8Text($Path, $Text) {
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $encoding)
}

function Get-SkillDirs {
    if (-not (Test-Path -LiteralPath $skillsRoot)) {
        throw "Missing skills directory: $skillsRoot"
    }

    $skillDirs = @()
    Get-ChildItem -LiteralPath $skillsRoot -Directory | Sort-Object Name | ForEach-Object {
        $categoryDir = $_
        Get-ChildItem -LiteralPath $categoryDir.FullName -Directory | Sort-Object Name | Where-Object {
            Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md")
        } | ForEach-Object {
            $skillDirs += $_
        }
    }

    $seen = @{}
    foreach ($skillDir in $skillDirs) {
        if ($seen.ContainsKey($skillDir.Name)) {
            throw "Duplicate canonical skill name across categories: $($skillDir.Name)"
        }
        $seen[$skillDir.Name] = $skillDir.FullName
    }

    return @($skillDirs)
}

function Resolve-SkillDir($SkillName) {
    if (-not $SkillName) {
        throw "Pass a skill name."
    }

    $matches = @(Get-SkillDirs | Where-Object { $_.Name -eq $SkillName })
    if ($matches.Count -eq 0) {
        throw "Unknown skill: $SkillName"
    }
    if ($matches.Count -gt 1) {
        throw "Duplicate canonical skill name across categories: $SkillName"
    }

    return $matches[0].FullName
}

function Get-FrontmatterValue($Content, $Field) {
    $pattern = "(?m)^$([regex]::Escape($Field)):\s*(.+?)\s*$"
    $match = [regex]::Match($Content, $pattern)
    if ($match.Success) {
        return $match.Groups[1].Value
    }

    return ""
}

function Get-FrontmatterMetadataValue($Content, $Field) {
    $frontmatter = [regex]::Match($Content, "(?s)^---\s*(.*?)\s*---")
    if (-not $frontmatter.Success) {
        return ""
    }

    $pattern = "(?m)^\s{2}$([regex]::Escape($Field)):\s*(.+?)\s*$"
    $match = [regex]::Match($frontmatter.Groups[1].Value, $pattern)
    if ($match.Success) {
        return $match.Groups[1].Value
    }

    return ""
}

function Get-BashPath {
    $gitBash = "C:\Program Files\Git\bin\bash.exe"
    if (Test-Path -LiteralPath $gitBash) {
        return $gitBash
    }

    $bashCommand = Get-Command bash -ErrorAction SilentlyContinue
    if ($bashCommand) {
        return $bashCommand.Source
    }

    throw "Git Bash or bash is required for personal skill installation."
}

function Convert-ToBashPath($Path) {
    $bashPath = $Path -replace "\\", "/"
    if ($bashPath -match "^([A-Za-z]):/(.*)$") {
        $drive = $matches[1].ToLowerInvariant()
        $rest = $matches[2]
        return "/$drive/$rest"
    }

    return $bashPath
}

function Invoke-SkillInstallScript($ScriptName, $VerifyOnly) {
    $scriptPath = Join-Path $scriptDir $ScriptName
    if (-not (Test-Path -LiteralPath $scriptPath)) {
        throw "Missing install script: $scriptPath"
    }

    $bash = Get-BashPath
    $bashScriptPath = Convert-ToBashPath $scriptPath

    $args = @()
    if ($VerifyOnly) {
        $args += "--verify-only"
    }
    if ($Copy) {
        $args += "--copy"
    }
    if ($Link) {
        $args += "--link"
    }
    if ($KeepExisting) {
        $args += "--keep-existing"
    }

    & $bash $bashScriptPath @args
    if ($LASTEXITCODE -ne 0) {
        throw "$ScriptName failed with exit code $LASTEXITCODE"
    }
}

function Get-Targets {
    if ($Target -eq "all") {
        return @("codex", "claude", "copilot")
    }

    return @($Target)
}

function Get-DefaultTargetsForList {
    if ($targetWasProvided -or $positionalTargetWasProvided) {
        return Get-Targets
    }

    return @("claude", "codex", "copilot")
}

function Get-PersonalSkillTargetPath($TargetName, $SkillName) {
    switch ($TargetName) {
        "codex" {
            $root = if ($env:CODEX_SKILLS_DIR) { $env:CODEX_SKILLS_DIR } else { Join-Path $HOME ".codex\skills" }
            return Join-Path $root $SkillName
        }
        "claude" {
            $root = if ($env:CLAUDE_SKILLS_DIR) { $env:CLAUDE_SKILLS_DIR } else { Join-Path $HOME ".claude\skills" }
            return Join-Path $root $SkillName
        }
        "copilot" {
            return ""
        }
    }
}

function Get-ProjectSkillTargetPath($TargetName, $SkillName) {
    switch ($TargetName) {
        "claude" {
            return (Join-Path (Join-Path $TargetRepo ".claude\skills") $SkillName)
        }
        default {
            return ""
        }
    }
}

function Get-ProjectProfilePath {
    return (Join-Path (Join-Path $TargetRepo ".ai-toolkit") "skills.json")
}

function Read-ProjectProfile {
    $profilePath = Get-ProjectProfilePath
    if (-not (Test-Path -LiteralPath $profilePath)) {
        return [ordered]@{
            version = 1
            skills = @()
        }
    }

    $profile = Read-Utf8Text $profilePath | ConvertFrom-Json
    $skills = @()
    if ($profile.PSObject.Properties.Name -contains "skills") {
        $skills = @($profile.skills)
    }

    return [ordered]@{
        version = if ($profile.version) { $profile.version } else { 1 }
        skills = @($skills | Where-Object { $_ } | Sort-Object -Unique)
    }
}

function Write-ProjectProfile($Profile) {
    $profilePath = Get-ProjectProfilePath
    $profileDir = Split-Path -Parent $profilePath
    if (-not (Test-Path -LiteralPath $profileDir)) {
        New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
    }

    $normalized = [ordered]@{
        version = 1
        skills = @($Profile.skills | Where-Object { $_ } | Sort-Object -Unique)
    }
    $json = ($normalized | ConvertTo-Json -Depth 4)
    Write-Utf8Text $profilePath ($json + [Environment]::NewLine)
}

function Add-ProjectSkill($SkillName) {
    $null = Resolve-SkillDir $SkillName
    $profile = Read-ProjectProfile
    if ($profile.skills -notcontains $SkillName) {
        $profile.skills = @($profile.skills + $SkillName | Sort-Object -Unique)
        Write-ProjectProfile $profile
        Write-Output "project profile added: $SkillName"
        return
    }

    Write-Output "project profile already contains: $SkillName"
}

function Resolve-ProjectSkillNames($SkillName) {
    if ($SkillName) {
        $null = Resolve-SkillDir $SkillName
        return @($SkillName)
    }

    $profilePath = Get-ProjectProfilePath
    if (-not (Test-Path -LiteralPath $profilePath)) {
        throw "Missing project skill profile: $profilePath. Run: skills add repo <skill-name>"
    }

    $profile = Read-ProjectProfile
    if ($profile.skills.Count -eq 0) {
        throw "Project skill profile has no skills: $profilePath"
    }

    foreach ($skillName in $profile.skills) {
        $null = Resolve-SkillDir $skillName
    }

    return @($profile.skills)
}

function Get-RelativeFileHashes($RootPath) {
    $rootFull = (Resolve-Path -LiteralPath $RootPath).Path.TrimEnd("\", "/")
    $files = @{}
    Get-ChildItem -LiteralPath $rootFull -Recurse -File | ForEach-Object {
        $relative = $_.FullName.Substring($rootFull.Length).TrimStart("\", "/") -replace "\\", "/"
        $files[$relative] = (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash
    }

    return $files
}

function Test-SkillSnapshotMatches($SourcePath, $TargetPath) {
    if (-not (Test-Path -LiteralPath $TargetPath)) {
        return $false
    }

    $targetItem = Get-Item -Force -LiteralPath $TargetPath
    if (($targetItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "Project skill target is a link, but project installs require real copied directories: $TargetPath"
    }
    if (-not $targetItem.PSIsContainer) {
        throw "Project skill target is not a directory: $TargetPath"
    }

    $sourceHashes = Get-RelativeFileHashes $SourcePath
    $targetHashes = Get-RelativeFileHashes $TargetPath
    $sourceKeys = @($sourceHashes.Keys | Sort-Object)
    $targetKeys = @($targetHashes.Keys | Sort-Object)

    if (($sourceKeys -join "`n") -ne ($targetKeys -join "`n")) {
        return $false
    }

    foreach ($key in $sourceKeys) {
        if ($sourceHashes[$key] -ne $targetHashes[$key]) {
            return $false
        }
    }

    return $true
}

function Test-SkillInstalled($TargetName, $SkillName) {
    $targetPath = if ($Scope -eq "personal") {
        Get-PersonalSkillTargetPath $TargetName $SkillName
    } else {
        Get-ProjectSkillTargetPath $TargetName $SkillName
    }

    return ($targetPath -and (Test-Path -LiteralPath $targetPath))
}

function Format-StatusCell($TargetName, $Installed) {
    $marker = if ($Installed) { "+" } else { " " }
    return ("[{0} {1}]" -f $TargetName, $marker)
}

function Install-PersonalTarget($TargetName, $VerifyOnly) {
    switch ($TargetName) {
        "codex" {
            Invoke-SkillInstallScript "skills-setup/install-codex.sh" $VerifyOnly
        }
        "claude" {
            Invoke-SkillInstallScript "skills-setup/install-claude-code.sh" $VerifyOnly
        }
        "copilot" {
            if ($Target -eq "all") {
                Write-Warning "Skipping Copilot personal install: this repo does not define a Copilot skills runtime directory yet."
                return
            }
            throw "Copilot does not have a supported personal skills runtime directory in this repo yet."
        }
    }
}

function Install-ProjectTarget($TargetName, $VerifyOnly) {
    switch ($TargetName) {
        "claude" {
            $skillNames = Resolve-ProjectSkillNames $Name
            if (-not $VerifyOnly -and $Name) {
                Add-ProjectSkill $Name
            }
            foreach ($skillName in $skillNames) {
                $source = Resolve-SkillDir $skillName
                $target = Get-ProjectSkillTargetPath $TargetName $skillName
                if (Test-Path -LiteralPath $target) {
                    if (Test-SkillSnapshotMatches $source $target) {
                        Write-Output "project claude skill ok: $skillName"
                        continue
                    }

                    throw "Project Claude skill copy differs from canonical source: $target. Remove or refresh that explicit skill directory before reinstalling."
                }

                if ($VerifyOnly) {
                    throw "Missing project Claude skill copy: $target"
                }

                $parent = Split-Path -Parent $target
                if (-not (Test-Path -LiteralPath $parent)) {
                    New-Item -ItemType Directory -Force -Path $parent | Out-Null
                }
                Copy-Item -LiteralPath $source -Destination $target -Recurse
                Write-Output "project claude skill copied: $skillName"
            }

            return
        }
        "codex" {
            if ($Target -eq "all") {
                Write-Warning "Skipping Codex project install: this repo does not define project-local Codex skills yet."
                return
            }
            throw "Codex project-local skills are not supported by this repo yet."
        }
        "copilot" {
            if ($Target -eq "all") {
                Write-Warning "Skipping Copilot project install: use baselines for Copilot instruction blocks until a skills contract exists."
                return
            }
            throw "Copilot project-local skills are not supported by this repo yet; use baselines for Copilot instruction blocks."
        }
    }
}

switch ($Command) {
    "list" {
        $listTargets = Get-DefaultTargetsForList
        $scopeLabel = if ($Scope -eq "project") {
            "scope: project, target: $((Resolve-Path -LiteralPath $TargetRepo).Path)"
        } else {
            "scope: personal"
        }

        Write-Output "Available skills  ($scopeLabel)"
        Write-Output ""
        Get-SkillDirs | ForEach-Object {
            $skillFile = Join-Path $_.FullName "SKILL.md"
            $content = Read-Utf8Text $skillFile
            $status = Get-FrontmatterValue $content "status"
            if (-not $status) {
                $status = Get-FrontmatterMetadataValue $content "status"
            }
            if (-not $status) {
                $status = "unknown"
            }
            $cells = @()
            foreach ($targetName in $listTargets) {
                $cells += Format-StatusCell $targetName (Test-SkillInstalled $targetName $_.Name)
            }
            Write-Output ("{0,-40} [{1,-8}] {2}" -f $_.Name, $status, ($cells -join "  "))
        }
        Write-Output ""
        Write-Output "Legend: [+ installed]  [ absent]"
    }
    "show" {
        $skillDir = Resolve-SkillDir $Name
        Write-Output (Read-Utf8Text (Join-Path $skillDir "SKILL.md")).Trim()
    }
    "add" {
        Require-ExplicitScope "record"
        if ($Scope -ne "project") {
            throw "skills add currently supports only repo, -Repo, or -Scope project."
        }
        Add-ProjectSkill $Name
    }
    "install" {
        Require-ExplicitScope "install"
        foreach ($targetName in (Get-Targets)) {
            if ($Scope -eq "personal") {
                Install-PersonalTarget $targetName $false
            } else {
                Install-ProjectTarget $targetName $false
            }
        }
    }
    "apply" {
        Require-ExplicitScope "install"
        foreach ($targetName in (Get-Targets)) {
            if ($Scope -eq "personal") {
                Install-PersonalTarget $targetName $false
            } else {
                Install-ProjectTarget $targetName $false
            }
        }
    }
    "verify" {
        $verifyScript = Join-Path $scriptDir "skills-setup/verify.sh"
        if (-not (Test-Path -LiteralPath $verifyScript)) {
            throw "Missing verify script: $verifyScript"
        }

        & (Get-BashPath) (Convert-ToBashPath $verifyScript)
        if ($LASTEXITCODE -ne 0) {
            throw "scripts/skills-setup/verify.sh failed with exit code $LASTEXITCODE"
        }

        $verifyInstall = $PSBoundParameters.ContainsKey("Target") -or $PSBoundParameters.ContainsKey("Scope")
        if (-not $verifyInstall -and ($User -or $Repo -or $positionalScopeWasProvided -or $positionalTargetWasProvided)) {
            $verifyInstall = $true
        }
        if ($verifyInstall) {
            Require-ExplicitScope "verify installed"
            foreach ($targetName in (Get-Targets)) {
                if ($Scope -eq "personal") {
                    Install-PersonalTarget $targetName $true
                } else {
                    Install-ProjectTarget $targetName $true
                }
            }
        }
    }
    "shim" {
        $shimAction = if ($Name) { $Name } else { "install" }
        if (@("install", "verify", "remove") -notcontains $shimAction) {
            throw "Unknown shim action: $shimAction. Use install, verify, or remove."
        }

        if ($IsMacOS -or $IsLinux) {
            $shimScript = Join-Path $scriptDir "skills-setup/install-shim.sh"
            $bashArgs = @()
            if ($InstallDir) { $bashArgs += "--install-dir"; $bashArgs += $InstallDir }
            if ($shimAction -eq "verify") { $bashArgs += "--verify-only" }
            if ($shimAction -eq "remove") { $bashArgs += "--remove" }
            & (Get-BashPath) $shimScript @bashArgs
        } else {
            $shimScript = Join-Path $scriptDir "skills-setup\install-shim.ps1"
            $shimArgs = @{}
            if ($InstallDir) { $shimArgs.InstallDir = $InstallDir }
            if ($AddToUserPath) { $shimArgs.AddToUserPath = $true }
            if ($shimAction -eq "verify") { $shimArgs.VerifyOnly = $true }
            if ($shimAction -eq "remove") { $shimArgs.Remove = $true }
            & $shimScript @shimArgs
        }
    }
    "help" {
        Write-Output @"
Usage:
  skills list [-Target codex|claude|copilot|all] [-Scope personal|project] [-TargetRepo <path>]
  skills show <name>
  skills add <name> [-Target codex|claude|copilot|all] [-Scope personal|project] [-User|-Repo] [-Copy|-Link] [-KeepExisting]
  skills apply  [-Target codex|claude|copilot|all] [-Scope personal|project] [-User|-Repo] [-Copy|-Link] [-KeepExisting]
  skills install [-Target codex|claude|copilot|all] [-Scope personal|project] [-User|-Repo] [-Copy|-Link] [-KeepExisting]  (alias for apply)
  skills verify [-Target codex|claude|copilot|all] [-Scope personal|project] [-User|-Repo]
  skills shim [install|verify|remove] [-InstallDir <path>] [-AddToUserPath]
  skills help
"@
    }
}
