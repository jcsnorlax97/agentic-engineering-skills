# AI Toolkit

Reusable AI agent assets: skills, baselines, workflow definitions, agent role
packs, and supporting templates.

Recommended repository name: `ai-toolkit`.

## Language

Skill: A reusable agent workflow packaged as instructions, and optionally scripts or references. Avoid: prompt, magic command

Workflow: A repeatable multi-step engineering process with entry criteria, exit criteria, and expected outputs. Avoid: vibe, freestyle

Workflow skill: A skill that orchestrates multiple lower-level skills, gates, artifacts, and verification steps for a recurring engineering process. Avoid: macro, one-click automation

Canonical source: The directory that owns the maintained copy of a skill. In this repo, canonical skills live under category directories such as `skills/engineering/` and `skills/media/`. Avoid: duplicate source, copied truth

Skill metadata: Frontmatter inside `SKILL.md` that records AI trigger text and human maintenance fields such as status, problem, when-not-to-use, and maintainer. Avoid: companion metadata file, maturity folder

Adapter: A tool-specific exposure layer that points at or installs from the canonical source. Examples: `.claude/skills/`, `~/.claude/skills/`, `~/.codex/skills/`

Portable baseline: A reusable always-on instruction pack for AI coding agents,
applied through repo-local managed blocks in files such as `AGENTS.md` or
`CLAUDE.md`. It changes the default agent posture without requiring skill
discovery or invocation. Avoid: hidden global prompt, copied prompt dump

Baseline pack: A named portable baseline directory containing `pack.json`,
`baseline.md`, and one or more tool adapters. Avoid: loose snippet, note

Managed baseline block: A bounded downstream insertion between `baseline`
BEGIN/END markers. Legacy `portable-agent-baseline` markers are accepted for
backward compatibility and are migrated by the next apply. Avoid: unmarked paste

Personal link install: A personal tool install where `~/.claude/skills/<skill-name>` or `~/.codex/skills/<skill-name>` is a symlink to the canonical skill through the stable repo link. Avoid: copied install, manual refresh

Personal copy install: A personal tool install where canonical skill directories are copied into `~/.claude/skills/<skill-name>` or `~/.codex/skills/<skill-name>` as runtime snapshots. This is an explicit fallback for environments that cannot create real symlinks. Avoid: stale manual copy, untracked fork

Project skill profile: A repo-local `.ai-toolkit/skills.json` file that lists the toolkit skills intentionally enabled for that project. Avoid: hidden global skill set, accidental personal runtime dependency

Project copy install: A project tool install where canonical skill directories are copied into a repo-local adapter such as `.claude/skills/<skill-name>`. This is the default project-scope mode so each repo owns an explicit snapshot of its intended skill set. Avoid: project symlink, invisible global update

Stable repo link: The machine-local symlink `~/.local/share/ai-toolkit/current` that points to the current clone of this repository. Personal skill links point through this path so repo moves require repairing one stable link, not every installed skill. Avoid: hardcoded clone path

Source registry: A repository document that records each external skill source, imported paths, license, copyright notice, verification date, and obligations. In this repo, the source registry is `docs/upstream-sources.md`. Avoid: informal attribution

Bookshelf: A raw capture surface for unprocessed external resources (skill repos, tools, skill collections, articles, essays) worth remembering before the source expires. Lives at `bookshelf/`, indexed by `bookshelf/INDEX.md`. Distinct from the intake ledger (`docs/intake.md`), which tracks methodology-intake verdicts, and from the source registry (`docs/upstream-sources.md`), which tracks actually-imported material. Avoid: bookmarks, reading list

Bookshelf note: One markdown file per bookshelf resource, following the shape in `bookshelf/_template.md` (title, url, kind, captured date, status, and a short why-it-matters note). Avoid: intake item, capture

Agent team workflow: A repeatable workflow for decomposing a larger goal into bounded agent roles, context packets, handoffs, and acceptance checks. Avoid: agent swarm, autonomous team

Agent workflow pack: A future tool-neutral source tree under `workflows/<workflow-name>/` that owns reusable agent workflow specs, role catalogs, team profiles, execution-packet templates, and handoff contracts. Avoid: hidden skill body, runtime-specific subagent config

Team profile: A reusable selection of agent roles, responsibilities, and context boundaries for a class of work. Avoid: fixed roster, department

Agent role: A reusable responsibility template inside an agent team workflow, such as product manager, frontend engineer, backend engineer, reviewer, or tester. Avoid: persona, bot

Ad hoc worker: A task-specific delegated agent that is not part of the reusable role catalog but receives a bounded context packet and output contract from the coordinator. Avoid: unspecified helper, generic subagent

Subagent runtime: A specific tool's mechanism for running delegated agents or workers. Examples: Codex sub-agents, Claude Code subagents. Avoid: agent team workflow

Execution packet: A tool-neutral plan produced by an agent team workflow that defines roles, context packets, ownership boundaries, handoffs, verification, and stop conditions. Avoid: runtime config, prompt dump

Parallelization safety: The execution-packet section that proves delegated workers can proceed in parallel by naming independent ownership, shared contracts, integration order, checkpoint need, and conflict risk. Avoid: just run several agents

Knowledge update requirement: A handoff signal that durable context, docs, ADRs, specs, or glossary entries may need updating after the assigned work. Avoid: save everything, raw transcript

Artifact store: The intended location for durable or temporary outputs such as diagrams, review notes, prototype verdicts, PRDs, ADRs, and handoff notes. Avoid: random output folder

Methodology intake: A read-only workflow for evaluating an external methodology source before deciding whether it should become a rule, skill, context term, ADR, spec, issue, or no-op. Avoid: inspiration dump, prompt collection

External methodology source: An article, repository, paper, tool list, framework, workflow, or public discussion being considered for adoption into this repo's workflow system. Avoid: internet idea, random source

Input note: A redacted inbox artifact created from an external source, such as a Gemini, ChatGPT, or Claude shared conversation, meeting transcript, video notes, article, workflow idea, or copied excerpt. It preserves only enough context for later review, methodology intake, daily work logs, or skill formulation. It is not final knowledge, not a raw transcript, and not a formal skill. Avoid: raw dump, final note, saved chat

Tool-list-only source: An external methodology source that primarily lists tools, SDKs, repositories, or frameworks without enough trigger criteria, workflow steps, outputs, verification, and stop conditions to become a skill. Avoid: tool worship

Social Live Photo card: A social-platform card that must work as a static first
frame and as a short motion asset. It is produced from user-provided video when
one small motion point gives evidence that a still image cannot. Avoid: generic
video edit, animated decoration

Intake destination: The single primary outcome assigned by methodology intake. Valid destinations are Rule, Skill, Context term, ADR, Spec, Issue, and No-op. Avoid: tag pile, mixed outcome

Retention status: The parking decision for an external methodology source after classification, independent from its intake destination. Valid statuses are discard, parked, and revisit-on-trigger. Avoid: destination, triage state

No-op: An intake destination meaning the source should not create or update a formal workflow artifact. A no-op source may still be retained, parked, or revisited according to its retention status. Avoid: delete, forget

Rule: An intake destination for a judgment principle that can be absorbed into an existing workflow without defining a new workflow structure. Avoid: reminder, preference

Spec: An intake destination for source material that should define or change cross-workflow structure, process, contracts, artifact policy, or acceptance rules. Avoid: long note, checklist pile

Context term: An intake destination for stable project language that will be reused across workflows, specs, or skills and affects classification, acceptance, or boundary decisions. Avoid: article jargon, branded term

ADR destination: An intake destination for a hard-to-reverse, surprising-without-context repo decision that comes from a real trade-off surfaced during methodology intake. Avoid: interesting decision, note

Review context bundle: A bounded set of repositories, files, diffs, docs, commands, and constraints provided for PR review. Avoid: whole machine context

Staff-level review: A read-only engineering review checkpoint that evaluates correctness, architecture, security, privacy, performance, test quality, operational risk, maintainability, and requirement compliance. Avoid: staff-review unless referring to an external or private skill

Analysis-only mode: A delegation mode where a role or worker may inspect context and report findings, risks, and proposed plans but may not edit files. Avoid: passive mode

Edit mode: A delegation mode where a role or worker may edit only explicitly assigned files or modules and must report changed files and verification. Avoid: freeform write access

Workspace sandbox: The default safety boundary for an agent team workflow, limiting each role or worker to assigned files, documents, context packets, and write scopes. Avoid: full machine access

External system: A hosted service, API, database, auth provider, email provider, payment provider, package registry, or deployed environment outside the local repo that a workflow may depend on. Avoid: integration thing, outside service

No-secret verification path: A verification route that proves useful behavior without credentials, production data, private vault access, live payments, real email, or state-changing third-party calls. Avoid: fake test, partial proof

Credentialed verification path: A verification route that requires explicit credentials, access tokens, service accounts, test users, or external environment permissions. Avoid: real test, full test

Disposable test environment: A temporary or non-production external environment used for integration verification without production credentials or production data. Avoid: production-like by default, throwaway account

Isolated runtime: An optional hardened execution environment such as Docker, a devcontainer, or an ephemeral worktree used for high-risk or long-running delegated work. Avoid: mandatory container for every task

Manual mode: An agent team workflow mode where the coordinator produces an execution packet and waits for the user to approve or launch workers. Avoid: stalled workflow

Checkpointed autonomous mode: An agent team workflow mode where the coordinator may delegate and continue work within explicit budgets, sandboxes, and checkpoint rules. Avoid: fully autonomous until done

Vertical slice: The thinnest end-to-end change that proves one behavior through a real interface. Avoid: layer task, partial plumbing

ADR: A short decision record for an architectural choice that is hard to reverse and needs future context. Avoid: note dump

Issue: A tracked unit of work. In this repo the default issue tracker is local markdown under `.scratch/issues/`. Avoid: ticket, todo blob

## Relationships

- A workflow can be captured as one or more skills.
- A workflow skill may orchestrate lower-level skills and select a team profile.
- A skill should improve repeatability, not just verbosity.
- A skill should be edited in its canonical source, then exposed through adapters.
- Skill metadata should live in `SKILL.md` frontmatter so each skill has one
  maintained interface instead of a paired companion metadata file.
- A portable baseline should be edited in `baselines/`, then applied
  to downstream repo instruction files through managed baseline blocks.
- A portable baseline is not a skill because it is always-on and has no trigger,
  workflow-specific inputs, or stop condition.
- A skill should not become a portable baseline unless its guidance is safe and
  useful as default behavior in ordinary chats.
- Personal link installs expose canonical skills through the stable repo link so pulling the repo updates installed skills without copying or deleting existing skill directories.
- Personal copy installs avoid symlink privileges but require rerunning the installer after pulling repo changes.
- Project skill profiles keep project-specific skill sets explicit, repo-local,
  and independent from the user's personal runtime skill set.
- Project copy installs intentionally avoid symlinks so a project sees a stable
  snapshot until the project skill profile is reinstalled deliberately.
- Imported skills must be backed by the source registry and required license notices.
- An agent team workflow may define agent roles, but a subagent runtime is tool-specific.
- A team profile defines who should work; a workflow defines when and why they work.
- An agent workflow pack should own reusable multi-agent workflow definitions
  when the workflow must be shared across tools or coordinators; a skill may
  adapt or invoke that workflow, but should not hide the reusable definition.
- Staff-level review is the canonical review checkpoint term; external `staff-review` skills are optional dependencies until their source and license are verified.
- An agent team workflow may use ad hoc workers when a task needs delegation without a reusable role.
- An agent team workflow should be used when work is multi-domain, parallelizable, and context-heavy.
- An agent team workflow should first produce an execution packet before targeting a subagent runtime.
- An agent team execution packet should include parallelization safety before parallel workers are launched.
- Agent handoffs should state whether durable knowledge or documentation updates are required.
- A methodology intake assigns one intake destination and one retention status.
- An input note can feed methodology intake, daily work logs, or later skill formulation, but it does not itself promote source material into durable knowledge.
- Capture-input-note and methodology-intake are separate stages: capture-input-note preserves a redacted source note; methodology-intake classifies whether that source should change repo artifacts.
- Methodology-intake belongs in this repo as an engineering artifact admission gate.
- Capture-input-note lives in `../ai-second-brain` (migrated 2026-07-03); this repo's methodology intake consumes its captured input notes as an optional input but does not own the capture skill.
- A tool-list-only source may be retained for later reference without being promoted into a formal workflow artifact.
- An external methodology source should be classified as Skill only when it defines a repeatable workflow with trigger criteria, inputs, steps, outputs, verification, stop conditions, and repo fit.
- A no-op source does not create or update skills, specs, ADRs, issues, or glossary terms.
- A rule fits inside an existing workflow; a spec changes structure or contracts across workflows.
- A context term belongs in the glossary only when it stabilizes recurring project language rather than preserving one source's jargon.
- An ADR destination is for the repo decision caused by a source, not for the source merely being interesting.
- An issue destination is for a source that can already become a tracked, scoped, independently verifiable work item.
- A social Live Photo card workflow belongs in a skill, not a portable baseline,
  because it is triggered media-production work rather than always-on agent
  posture.
- Agent roles and ad hoc workers default to analysis-only mode unless an execution packet explicitly grants edit mode.
- Agent roles and ad hoc workers operate inside a workspace sandbox by default.
- An agent team workflow should identify external systems and separate no-secret verification paths from credentialed verification paths before delegation.
- Credentialed verification should use disposable test environments unless the user explicitly approves a specific production or live-system use.
- Isolated runtimes are optional hardening for high-risk or long-running delegated work.
- Agent team workflows may run in manual mode or checkpointed autonomous mode, but not unrestricted autonomous mode.
- An issue may produce code, documentation, or a new skill.
- A vertical slice should be small enough to implement and verify in one focused loop.

## Flagged Ambiguities

- "skill" can mean a personal capability or an agent capability. In this repo it means an agent capability unless explicitly stated otherwise.
