---
name: task-board
description: Coordinate resumable multi-agent work through tasks.csv plus task-local directories under tasks/{id}/. Use for multi-step, long-running, claimable work with durable handoff memory; skip task creation for simple work.
---

# Task Board

## Overview

Use this skill for multi-step or resumable work that benefits from explicit task claiming. Coordinate `tasks.csv` through `scripts/task_tracker.py`. Each task gets a working directory at `tasks/{id}/`. Agents manage `tasks/{id}/AGENTS.md` directly and may keep logs, scratch notes, generated snippets, and temporary files inside `tasks/{id}/`. Keep task creation minimal.

## Default Loop

1. Run `init` if `tasks.csv` or `tasks/` is missing.
2. Prefer existing work: use `claim` for a pending leaf task, and use `list` or `show` when you need to inspect the board first.
3. Do the work. Keep the CSV `result` short and append findings, blockers, and handoff notes to the end of `tasks/{id}/AGENTS.md`.
4. Use `update` only for CSV fields such as status, short result, and task name. If a task goes stale, the user may reset `ongoing` back to `pending`.

## Rules

- `tasks.csv` must be UTF-8 with header `id,task_name,status,parent_id,result`.
- Each task uses `tasks/{id}/` as its local work directory.
- `tasks/{id}/AGENTS.md` stores task description, acceptance criteria, progress notes, and handoff details.
- Do not edit `tasks.csv` manually. Use the script for `init`, `list`, `claim`, `create`, and `update`.
- Edit `tasks/{id}/AGENTS.md` directly. Append notes at the end.
- Appended notes do not need date stamps.
- Put task-local logs, scratch outputs, and temporary files under `tasks/{id}/`, not at the repo root.
- ID shape: top level `T001`, child `T001-1`, grandchild `T001-1-1`. Do not create deeper child like `T001-1-1-1`.
- Statuses: `pending`, `ongoing`, `completed`, `failed`.
- Claimable means `pending` with no children.
- Prefer claiming unfinished tasks over creating duplicates.
- Create child tasks only when needed to expose the next actionable leaf.
- Read `tasks/{id}/AGENTS.md` before resuming. Append useful memory before yielding, failing, or completing.
- Do not start a task already in `ongoing` unless the user reset it or you are intentionally taking it over.

## Commands

```bash
python /path/to/task-board/scripts/task_tracker.py init --root "$PWD"
python /path/to/task-board/scripts/task_tracker.py claim --root "$PWD"
python /path/to/task-board/scripts/task_tracker.py create --root "$PWD" --parent-id T001 --task-name "Map protocol matrix"
python /path/to/task-board/scripts/task_tracker.py update --root "$PWD" --id T001-1-1 --status completed --result "Mapped protocol matrix"
```
