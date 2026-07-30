# Personal Skill Installation

This document is the operational cheatsheet for installing this repo's skills
into local assistant runtimes.

## Mental Model

The maintained source of truth is always:

```text
skills/<category>/<skill-name>/
```

Runtime skill directories are adapters:

```text
~/.claude/skills/<skill-name>
~/.codex/skills/<skill-name>
<project>/.claude/skills/<skill-name>
```

The preferred personal install mode is symlink mode:

```text
~/.local/share/ai-toolkit/current
  -> <this repo clone>

~/.claude/skills/<skill-name>
  -> ~/.local/share/ai-toolkit/current/skills/<category>/<skill-name>

~/.codex/skills/<skill-name>
  -> ~/.local/share/ai-toolkit/current/skills/<category>/<skill-name>
```

Only `~/.local/share/ai-toolkit/current` is the repo-level
symlink. Paths under it, such as
`~/.local/share/ai-toolkit/current/skills/engineering/diagnose`,
resolve through `current` into the real repo directory. `ls -ld` on those deeper
paths may look like an ordinary directory and may not show `->`.

In other words, `current` is the pointer:

```text
~/.local/share/ai-toolkit/current -> <this repo clone>
```

`current/skills/<category>/<skill-name>` is not a second symlink created by the
installer. It is the real skill directory reached after the shell follows
`current` into the repo. The repo remains the source of truth because every
runtime symlink points through this stable `current` pointer into
`skills/<category>/<skill-name>/`.

Skill names must be unique across categories because runtime directories still
use `~/.claude/skills/<skill-name>` and `~/.codex/skills/<skill-name>`.

Because the runtime path is also a symlink to a directory, files will appear
inside `~/.claude/skills/<skill-name>` or `~/.codex/skills/<skill-name>`. That
is normal. Do not manually remove those files from the runtime path; if the path
is a symlink, deleting through it deletes files from the source-of-truth
directory.

## Commands

Use the `skills` CLI for the assistant target you want to expose skills to:

| Goal | Command | Scope |
| --- | --- | --- |
| List canonical skills | `./scripts/skills list` | Source repo |
| Show one skill | `./scripts/skills show diagnose` | Source repo |
| Verify source skills and adapters | `./scripts/skills verify` | Source repo |
| Install or repair Claude Code personal skills | `./scripts/skills install user claude -Copy` | `~/.claude/skills/` |
| Install or repair Codex personal skills | `./scripts/skills install user codex -Copy` | `~/.codex/skills/` |
| Install or repair supported personal targets | `./scripts/skills install user all -Copy` | Claude Code and Codex |
| Verify one copied personal target without changing files | `./scripts/skills verify user claude -Copy` | Selected runtime |
| Add one skill to a project profile | `skills add repo query-azure-devops` | `<project>/.ai-toolkit/skills.json` |
| Install one project skill for Claude Code | `skills install repo query-azure-devops claude` | `<project>/.claude/skills/` |
| Install the project profile for Claude Code | `skills install repo claude` | `<project>/.claude/skills/` |
| Verify a project skill profile | `skills verify repo claude` | Selected project repo |
| Apply a preset to a target repo (macOS/Linux) | `baseline apply-preset supabase-vercel-site -TargetRepo /path/to/repo` | Target repo instruction files |
| Apply a preset to a target repo (Windows) | `baseline apply-preset supabase-vercel-site -TargetRepo C:\path\to\repo` | Target repo instruction files |
| Dry-run a preset without writing files | `baseline apply-preset supabase-vercel-site -TargetRepo /path/to/repo -DryRun` | No writes |

Use positional `user` or `repo` to choose the install level, and `codex`,
`claude`, `copilot`, or `all` to choose the target. The explicit `-User`,
`-Repo`, and `-Target` switches are also supported, and the older
`-Scope personal|project` form remains supported for existing scripts. Codex
and Claude personal installs are supported today. Copilot is accepted as a
target name, but this repo does not yet define a
Copilot skills runtime contract; use baselines for Copilot instruction blocks
until that exists.

Project-scope install currently supports Claude Code only. It uses copy mode by
default and intentionally does not create project symlinks. The committed
project profile is:

```text
<project>/.ai-toolkit/skills.json
```

The generated project runtime adapter is:

```text
<project>/.claude/skills/<skill-name>/
```

To enable one skill for a project, run from the downstream repo:

```powershell
skills install repo query-azure-devops claude
skills verify repo claude
skills list repo claude
```

If `.ai-toolkit/skills.json` already exists, `skills install repo claude`
installs every skill listed in the profile. Existing project
skill copies must match the canonical source; if a copy differs, the command
stops instead of overwriting or deleting the directory.

Legacy command names live under `scripts/compat/` as compatibility wrappers.
New docs should use `./scripts/skills` (Mac/Linux) or `./scripts/skills.ps1` (Windows) as entry points.
See [ADR 0001](../adr/0001-powershell-as-cross-platform-core.md) for the cross-platform architecture.

Command shims are separate from runtime installs:

| Goal | Command | Scope |
| --- | --- | --- |
| Install macOS/Linux `baseline` shim | `./scripts/baseline shim install` | One shell wrapper in `~/.local/bin` |
| Verify macOS/Linux `baseline` shim | `./scripts/baseline shim verify` | No writes |
| Remove macOS/Linux `baseline` shim | `./scripts/baseline shim remove` | One managed shell wrapper |
| Install macOS/Linux `skills` shim | `./scripts/skills shim install` | One shell wrapper in `~/.local/bin` |
| Verify macOS/Linux `skills` shim | `./scripts/skills shim verify` | No writes |
| Remove macOS/Linux `skills` shim | `./scripts/skills shim remove` | One managed shell wrapper |
| Install Windows `baseline` shim | `./scripts/baseline.ps1 shim install -AddToUserPath` | User PATH and one `.cmd` wrapper |
| Verify Windows `baseline` shim | `./scripts/baseline.ps1 shim verify` | No writes |
| Remove Windows `baseline` shim | `./scripts/baseline.ps1 shim remove` | One managed `.cmd` wrapper |
| Install Windows `skills` shim | `./scripts/skills.ps1 shim install -AddToUserPath` | User PATH and one `.cmd` wrapper |
| Verify Windows `skills` shim | `./scripts/skills.ps1 shim verify` | No writes |
| Remove Windows `skills` shim | `./scripts/skills.ps1 shim remove` | One managed `.cmd` wrapper |

The `baseline` and `skills` shims do not install skills or write to
`~/.claude/skills`, `~/.codex/skills`, or assistant runtime state. They only
make the repo CLIs available as `baseline` and `skills`. Installing the
`baseline` shim also removes older matching
`p-baseline` or `portable-baseline` shims from the same install directory.

Portable baseline verification reports the installed managed-block version for
each target instruction file. If a repo has an older managed block than the
source pack, verification fails with both versions so the operator can rerun
`apply` deliberately. Legacy `portable-agent-baseline` markers still verify;
the next `baseline apply` migrates them to the current `baseline` marker.

The default installer mode is symlink mode. Use `-Copy` from `skills.ps1`, or
`--copy` from the organized shell scripts, as an explicit fallback:

```bash
./scripts/skills install user claude -Copy
```

```bash
./scripts/skills-setup/install-claude-code.sh --link
```

## Platform Commands

### macOS

**Prerequisite:** `baseline` and `skills` require PowerShell. Install it once:

```bash
brew install powershell
```

macOS normally does not need special privileges for skill symlinks:

```bash
./scripts/skills-setup/install-claude-code.sh
./scripts/skills-setup/install-claude-code.sh --verify-only
```

For the `baseline` and `skills` command shims:

```bash
./scripts/baseline shim install
./scripts/skills shim install
baseline list
skills list
```

If `~/.local/bin` is not in `PATH`, add it to the shell profile:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Windows, Git Bash

Windows usually requires Developer Mode or an elevated shell for directory
symlinks. The known-good path for symlink mode is Git Bash opened as
Administrator. Do not use PowerShell or the VS Code integrated terminal for
symlink mode; they may resolve `bash` to WSL or use the wrong home directory.

Before changing files, verify that this shell is Git Bash and that `$HOME`
points at the Windows user profile:

```bash
bash -lc 'uname -s; echo $HOME'
```

Expected output looks like:

```text
MINGW64_NT...
/c/Users/<WindowsUser>
```

If you see `Linux` and `/home/<user>`, stop. That is WSL, not Git Bash for the
Windows user profile.

After the preflight passes, run the installer from the repo root:

```bash
MSYS=winsymlinks:nativestrict ./scripts/skills-setup/install-claude-code.sh
MSYS=winsymlinks:nativestrict ./scripts/skills-setup/install-claude-code.sh --verify-only
```

### Windows, VS Code PowerShell Or `pwsh`

Do not use PowerShell, `pwsh`, or the VS Code integrated terminal for Windows
symlink mode. Open Git Bash as Administrator and use the commands above.

From PowerShell or VS Code, use copy mode only:

```powershell
./scripts/skills.ps1 install user claude -Copy
./scripts/skills.ps1 verify user claude -Copy
```

If troubleshooting path resolution from PowerShell, confirm whether `bash`
resolves to Git Bash or WSL before running any installer:

```powershell
where.exe bash
bash -lc 'uname -s; echo $HOME'
```

Git Bash output should look like:

```text
MINGW64_NT...
/c/Users/<WindowsUser>
```

If you see `Linux` and `/home/<user>`, that is WSL.

Git Bash may be installed even when `where.exe bash` finds nothing. The normal
Git for Windows executable is:

```powershell
& "C:\Program Files\Git\bin\bash.exe" -lc "uname -s; echo `$HOME"
```

If the preflight is correct but link creation fails with
`Operation not permitted`, enable Windows Developer Mode or run Git Bash as
Administrator. Developer Mode allows a normal user shell to create symbolic
links; an elevated Git Bash session is the fallback when Developer Mode cannot
be enabled.

After enabling Developer Mode, PowerShell can launch the Git Bash installer
explicitly:

```powershell
$env:MSYS = "winsymlinks:nativestrict"
& "C:\Program Files\Git\bin\bash.exe" -lc `
  "cd /c/Users/<WindowsUser>/Documents/a-codex/ai-toolkit && ./scripts/skills-setup/repair-personal-links.sh"
```

If neither option is available, keep using copy mode and rerun the copy
installer after each repository update.

`repair-personal-links.sh` is read-only-detect-then-repair: run it
periodically as a health check (e.g. after moving or renaming this repo, or
when a skill seems to be silently missing) rather than only after noticing a
broken symlink. (Note: 2026-07-23, single occurrence so far — not yet a
dedicated health-check skill; see `process-vs-work-doctrine` rule 1. Promote
if this recurs.)

For the portable baseline command shim, PowerShell is the supported Windows
installer because it creates a `.cmd` wrapper usable from both PowerShell and
CMD:

```powershell
.\scripts\baseline.ps1 shim install -AddToUserPath
baseline list
```

Open a new terminal after `-AddToUserPath`. Remove the shim later with:

```powershell
.\scripts\baseline.ps1 shim remove
```

The Windows `.cmd` shim forwards arguments through CMD, so comma-separated
PowerShell arrays may arrive as one string. The CLI normalizes comma-separated
tool lists, so both the direct `.ps1` script and the global
`baseline` shim support multiple tools in one command:

```powershell
.\scripts\baseline.ps1 apply karpathy-principles -DryRun
baseline apply karpathy-principles -DryRun
baseline apply-all -DryRun
baseline help
```

For narrow changes, one tool per command is also valid:

```powershell
baseline apply karpathy-principles -Tools codex -DryRun
baseline apply karpathy-principles -Tools claude -DryRun
baseline apply karpathy-principles -Tools copilot -DryRun
```

Positional pack names are the preferred shorthand; `-Pack` remains supported
for existing scripts. `apply-all` is shorthand for applying every baseline pack.
When `-Tools` is omitted, baseline commands use every supported tool:
`codex`, `claude`, and `copilot`. Missing instruction files are created by
default. Use `-SkipMissing` when you want baseline apply to update only
instruction files that already exist in the target repo.

Portable baseline placement is intentionally conservative. The installer
updates an existing managed block in place; when a block is missing, it appends
the block to the target instruction file. Top-vs-bottom placement should not be
treated as a reliable model weighting control. Use explicit instruction text
for priority and conflict behavior. If a team intentionally wants the portable
baseline near the top, move the managed block there once; later updates preserve
the block's location.

### WSL

Use WSL only when Claude Code is also running inside WSL:

```bash
./scripts/skills-setup/install-claude-code.sh
./scripts/skills-setup/install-claude-code.sh --verify-only
```

If Claude Code is the Windows app, do not use WSL's default
`~/.claude/skills`; it points to the WSL home directory, not the Windows user's
Claude Code profile.

## Symlink Verification

Installer verification:

```bash
./scripts/skills-setup/install-claude-code.sh --verify-only
```

Manual Git Bash verification:

```bash
ls -ld ~/.local/share/ai-toolkit/current
ls -ld ~/.claude/skills/diagnose
readlink ~/.local/share/ai-toolkit/current
readlink ~/.claude/skills/diagnose
realpath ~/.claude/skills/diagnose
test -L ~/.claude/skills/diagnose
```

Manual PowerShell verification:

```powershell
Get-Item "$HOME\.claude\skills\diagnose" | Format-List FullName,LinkType,Target
```

`LinkType` should report a symbolic link when symlink mode is active.

## Symlink Mode Behavior

Default symlink mode is deterministic:

| Scenario | Behavior |
| --- | --- |
| Fresh machine, no stable repo link | Create `~/.local/share/ai-toolkit/current -> <this repo>`. |
| Fresh machine, no runtime skill target | Create `~/.claude/skills/<skill-name>` or `~/.codex/skills/<skill-name>` as a symlink through `current`. |
| New skill added under `skills/<category>/` | Rerun the relevant installer; it creates the missing runtime symlink. |
| Runtime skill symlink already correct | Leave it as-is and report it as verified. |
| Runtime skill symlink points elsewhere, is stale, or is broken | Replace it with the expected symlink through `current`. |
| Runtime skill exists as a real directory or copied install | Move it to `.ai-toolkit-backups/<timestamp>/<skill-name>`, then create the symlink. |
| Runtime skill exists as a real directory and `--keep-existing` is passed | Leave it untouched and do not create the symlink for that skill. |
| Stable `current` symlink points at this repo | Leave it as-is. |
| Stable `current` symlink points at an old repo path | Replace it to point at the current clone. |
| Stable `current` symlink is broken | Replace it to point at the current clone. |
| Stable `current` path exists but is not a symlink | Move it to `.ai-toolkit-backups/<timestamp>/current`, then create the real symlink. |
| Repo is moved or renamed | Run `scripts/skills-setup/repair-personal-links.sh` from the new clone. |
| Repo content changes after `git pull` | Existing linked skills see changes immediately; rerun installer only for new skills or repair. |
| `--verify-only` | Check current state and fail if any expected symlink is missing, stale, or broken; do not mutate files. |

## Copy Fallback

Use copy mode only if a machine cannot create real symlinks:

```bash
./scripts/skills-setup/install-claude-code.sh --copy
./scripts/skills-setup/install-claude-code.sh --copy --verify-only
```

Copy mode behavior differs from symlink mode:

| Scenario | Behavior |
| --- | --- |
| Fresh machine, no runtime skill target | Copy `skills/<category>/<skill-name>/` into the runtime skills directory. |
| Runtime skill copy matches canonical source | Leave it as-is and report it as verified. |
| Runtime skill copy differs from canonical source | Move it to `.ai-toolkit-backups/<timestamp>/<skill-name>`, then copy the canonical source. |
| Repo content changes after `git pull` | Rerun the installer to refresh copied snapshots. |
| Stable `current` symlink | Not used in copy mode. |
