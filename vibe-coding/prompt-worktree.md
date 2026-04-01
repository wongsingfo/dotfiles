# Repo Structure

This root directory is a **management wrapper**, not the project source. It has its own `.git` that tracks only tasks and orchestration files.

## Directory Layout

| Path | Purpose |
|------|---------|
| `./main/` | The real project repo (has its own `.git`) |
| `./dev/` | Git worktree of `./main` — default workspace for development |
| `./tasks/` | Task management (see below) |
| `./scripts/` | Shared utility scripts — **read-only** unless user says otherwise |

## Rules

1. **Know your worktree before writing code.** Ask if unclear. Default: `./dev/`.
2. **Never confuse the root git with `./main` git.** They are separate repositories. When asked to `git commit` for a subdirectory like `dev/`, you must `cd` into it first — it has its own `.git`.
3. **Project-level AGENTS.md lives in `./main/AGENTS.md`** — read it for build commands, architecture, and conventions.

## Task System

Task folders use the format `TXXX-slug` where the slug is a short kebab-case descriptor (e.g., `T001-ws-support`, `T002-web-search-tool`).

When assigned a task (e.g., `T001-ws-support`):

1. Read `./tasks/T001-ws-support/README.md` — contains the task description and prior agent notes.
2. Work in the correct worktree (usually `./dev/`).
3. Append or update plans, findings, progress, and useful context back to the task's `README.md` as you go.
4. Use the task folder for scratch files and logs during investigation.
