# Agent Orchestration Baseline

Status: active
Version: 0.1.0

Always-on discipline for dispatching, coordinating, and communicating around
AI sub-agents and background agents — the mechanics of handing work to another
agent and getting a trustworthy result back, not the content of the work
itself. This is a distinct concern from `repo-context-grounding`, which is
about starting work correctly in a single repo the current session is already
in; this baseline is about crossing that boundary — into another repo, into a
parallel agent, into a blocked tool call, into a shared log another session
might also be writing to.

## Principles

1. Verify a dispatched sub-agent's "worktree isolation" actually covers the
   target repo before relying on it.
   Before relying on a dispatched sub-agent's `isolation: "worktree"` option
   to cover work in a repo other than the current session's own, don't assume
   it covers that other repo — verify the mechanism's actual scope (which
   repo it creates the worktree in), or create the worktree explicitly in the
   target repo yourself and hand the agent that literal path. An isolation
   option scoped to the wrong repo gives false confidence that mutations are
   contained when they are not.

2. Hand a continuation dispatch the concrete specifics already discovered,
   not a cold open-ended prompt.
   When dispatching a background/sub-agent to continue work already partially
   investigated, include concrete already-discovered specifics — file paths,
   class/symbol names, ruled-out candidates, commands already tried — in the
   dispatch prompt. A prompt that re-poses the original open-ended question
   forces the new agent to re-derive ground already covered, wasting its
   budget and risking a different (and possibly contradictory) path through
   the same investigation.

3. Post a labeled partial synthesis as soon as any parallel branch is solid,
   layering later completions on top.
   When multiple parallel background agents are working toward one
   time-sensitive answer, post an interim synthesis of whatever is already
   solid as soon as it exists, explicitly labeled partial/incomplete, then
   layer each subsequent agent's completion on as a scoped update rather than
   withholding everything until the last agent finishes. Silence until full
   completion is the wrong default when the answer is time-sensitive and part
   of it is already trustworthy.

4. Stop at a safety-classifier block on an IAM- or secret-adjacent write and
   hand over the exact command — don't route around it.
   When a safety-classifier block hits an IAM- or secret-adjacent write, stop
   and hand the user the exact command/value rather than routing around it
   via another tool, another phrasing, or another approach that reaches the
   same effect. Also don't assume a later identical attempt will fail the
   same way — classifier behavior isn't fully deterministic, so a blocked
   command isn't evidence that retrying (or asking the user to run it
   themselves) is pointless.

5. Grep a shared append-only log for ordinal collisions immediately before
   writing, not from a value read earlier in the conversation.
   Before appending a sequentially-numbered entry to a shared memory/log file
   that more than one concurrent session could touch, grep the file for that
   exact ordinal immediately before writing — not a "next number" value
   computed or read earlier in the conversation, which can be stale by the
   time the write actually happens. On collision, disambiguate explicitly
   (e.g. a suffix or a note) rather than inventing a corrected total order
   that silently renumbers another session's entry.

## Priority

Apply this baseline before dispatching, coordinating, or reporting on
sub-agent/background-agent work, but never use it to override explicit user
instructions, safety rules, privacy boundaries, or stricter repo-local
instructions.

## Non-Goals

- This does not cover which agent type or model to pick for a task — that is
  a capability/cost decision made per task, not a dispatch-mechanics rule.
- This does not cover prompt-engineering content quality (how to phrase a
  good task description) beyond principle 2's narrow requirement to include
  already-known specifics — it is not a general prompting guide.
- This does not cover single-session, single-repo work at all — see
  `repo-context-grounding` for that.
