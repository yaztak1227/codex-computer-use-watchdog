---
name: computer-use-watchdog
description: Monitor OpenAI's macOS SkyComputerUseService, safely refresh stale high-CPU Computer Use helpers, and create or modify its recurring Codex schedule. Use when Computer Use remains resident after a task, consumes CPU or WindowServer/GPU resources with no client connected, needs a read-only health check, or when a user asks to create, repair, pause, resume, remove, reschedule, or change the model of the Computer Use watchdog automation.
---

# Computer Use Watchdog

Use the bundled scripts for process decisions. Never invoke Computer Use or screen capture to inspect the service because those operations change the load being measured.

## Inspect or maintain the service

Resolve this installed skill directory and run one of:

```bash
/bin/bash scripts/computer-use-watchdog --status
/bin/bash scripts/computer-use-watchdog --dry-run
/bin/bash scripts/computer-use-watchdog --run
```

- Use `--status` for a read-only snapshot.
- Use `--dry-run` to evaluate eligibility without writing state or sending signals.
- Use `--run` for maintenance. It submits one detached one-shot rechecker and exits immediately.

Do not replace the guarded scripts with `pkill`, broad process-name matching, or forced termination.

## Manage the recurring schedule

Read [references/automation.md](references/automation.md) before creating or changing an automation.

Use the Codex automation-management tool exposed in the current session. Do not edit `automation.toml` by hand.

For a new installation, default to:

- standalone local scheduled task (`cron`), so model and reasoning can be pinned
- every 10 minutes
- `gpt-5.6-luna` with `low` reasoning when available; otherwise the smallest available model with `low` reasoning
- local execution in the user's selected project
- failed-run notifications only
- permanently delete each standalone scheduled-run task after it finishes
- one `/bin/bash` call with this skill's absolute `scripts/computer-use-watchdog --run` path
- one guarded `/bin/bash` call to `scripts/delete-current-watchdog-thread --run` as the final action

Resolve a local project with the project-listing tool before creating a standalone task. If there is no suitable saved local project, ask the user to select or add one; do not silently choose an unrelated project.

When updating an existing automation:

1. Inspect the automation through the automation tool and its local configuration when available.
2. Preserve all fields the user did not ask to change.
3. Send the full updated field set required by the tool.
4. Verify the persisted configuration after the update.

For automatic run cleanup, invoke the bundled `scripts/delete-current-watchdog-thread --run` helper with `CU_WATCHDOG_DELETE_CURRENT_THREAD=computer-use-watchdog` as the final action. The helper derives the matching Codex home from its installed location, uses `CODEX_THREAD_ID` when it is a valid matching automation UUID, and otherwise requires exactly one recent, unarchived thread whose stored automation name and automation ID both match. It then schedules a delayed deletion by that UUID so the automation turn can finish first. Never delete by repeated task name.

Keep a thread heartbeat only when the user explicitly needs existing-chat continuity. A heartbeat may inherit the chat model and may not support a pinned model. Explain that limitation before converting between heartbeat and standalone scheduling.

## Safety model

The rechecker may send only `TERM`, never `KILL`. It acts only when all conditions hold:

1. The executable is `SkyComputerUseService` inside the current user's `.codex` or `.codex_*` Computer Use bundle.
2. The bundle identifier is `com.openai.sky.CUAService` and the signing team is OpenAI's `2DC432GLL2`.
3. No other process holds the service's `computeruse.sock` endpoint.
4. The service has no child processes, is old enough, and remains above the CPU threshold.
5. One separate batch rechecker waits and confirms every detected PID; multiple targets still use only one waiting process.

Recheck identity and client absence immediately before sending `TERM`. If the service does not exit within five seconds, report the timeout and leave it running. Treat a zombie (`Z`) target as terminated with parent reaping pending because it no longer consumes CPU, GPU, or resident memory.

## Execution model

The first checker evaluates all matching processes. If any are eligible, it stores every validated PID and executable path in one snapshot, submits exactly one detached `launchd` rechecker, and exits. The rechecker waits for the configured delay inside its own Bash process, reevaluates every recorded PID, removes transient state, and exits.

Environment overrides:

- `CU_WATCHDOG_MIN_AGE_SECONDS` — minimum process age, default `60`
- `CU_WATCHDOG_RECHECK_DELAY_SECONDS` — detached recheck delay, default `60`
- `CU_WATCHDOG_MIN_CPU` — average CPU threshold, default `2.0`
- `CU_WATCHDOG_STATE_DIR` — state and log directory

Keep defaults unless the user explicitly asks to tune them.
