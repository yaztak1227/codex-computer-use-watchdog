# Automation management

Use this reference only for creating or modifying the recurring watchdog schedule.

## Default scheduled task

Prefer a standalone local scheduled task because it can pin a lightweight model independently from the user's active chat. Resolve these values at runtime:

- `id`: reuse an existing matching ID; for a new task use a stable descriptive ID such as `computer-use-watchdog`
- `kind`: standalone/cron
- `name`: `Computer Use watchdog`
- `projectId`: the local project selected by the user or matching the current project
- `executionEnvironment`: local
- `destination`: local
- `model`: `gpt-5.6-luna` when supported
- `reasoningEffort`: `low`
- `notificationPolicy`: failed runs only
- `status`: active
- `rrule`: ten-minute interval unless the user provides another cadence

The saved prompt must use the installed skill's resolved absolute script path, not a path copied from documentation:

```text
Computer Useや画面キャプチャは呼ばず、/bin/bash {absolute-skill-directory}/scripts/computer-use-watchdog --run を1回だけ実行する。スクリプトは変更しない。status=errorの場合だけ理由と結果を簡潔に報告し、それ以外は追加作業を行わず静かに終了する。
```

Always invoke the script through `/bin/bash`. GitHub archive downloads used by `skill-installer` may not preserve executable bits.

Do not place local usernames, thread IDs, or machine-specific paths in the distributed skill or README. A generated local automation may necessarily contain the local installed path.

## Create

1. Search for the automation-management tool before doing anything else.
2. List saved projects and resolve the intended local project.
3. Resolve the absolute path of this installed skill.
4. Check whether an automation with the same purpose already exists. Update it instead of creating a duplicate.
5. Create the task with the complete default field set.
6. Inspect the persisted automation and report cadence, model, reasoning, and notification behavior.

## Change cadence

Translate the requested cadence to the recurrence format accepted by the automation tool. Preserve the prompt, model, reasoning, project, notification policy, and status. Examples:

- every minute: `FREQ=MINUTELY;INTERVAL=1`
- every 10 minutes: `FREQ=MINUTELY;INTERVAL=10`
- every 30 minutes: `FREQ=MINUTELY;INTERVAL=30`
- hourly: `FREQ=HOURLY;INTERVAL=1`

Do not show raw recurrence syntax to the user unless they ask for it.

## Change model or reasoning

Keep `gpt-5.6-luna` and `low` reasoning for routine watchdog runs when available. If the user selects another model, preserve their explicit choice and validate that the requested reasoning level is supported.

If an existing task is a thread heartbeat and the tool rejects model fields, explain that a heartbeat inherits chat execution settings. Convert it to a standalone local scheduled task only when the user agrees or their request clearly prioritizes an independently pinned lightweight model. Preserve cadence, prompt, status, and notification behavior during conversion.

## Modify, pause, resume, or delete

- Modify only requested fields and preserve all others.
- Pause or resume with the automation tool's status field.
- Delete only after resolving the exact automation ID and confirming it is the watchdog task.
- Never create a second watchdog merely to work around an update error.

## Verification

After every write:

1. Re-read the automation through the tool or persisted configuration.
2. Confirm the kind, cadence, model, reasoning effort, notification policy, project, and script path.
3. Ensure the prompt invokes neither Computer Use nor screen capture.
4. Ensure no personal path or identifier has entered the distributed repository.

For process testing, prefer `--status` or `--dry-run`. Do not run `--run` merely to validate scheduling syntax.
