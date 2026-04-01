# Agent Instruction for Long-Running Task Execution

## Core Concept
This framework enables session-agnostic handling of large tasks (e.g., full paper proofreading, codebase refactoring) by breaking work into atomic chunks with persistent progress tracking. Agents pick up work where previous agents left off with zero context loss.

---

## Task Files
| File | Purpose |
|------|---------|
| `prompt-task.md` (this file) | Universal instruction set for all agents |
| `progress-<slug>.md` | Single source of truth for task state: context, work breakdown, progress logs, and next actions |

---

## Agent Workflow

### Step 1: Initialize or Load Progress File
1. Check if `progress-<slug>.md` exists for the task.
2. **If it does not exist (first run):**
   - Create it using the template below.
   - Break the task into independent, atomic work chunks (~15-30 min each).
   - Create an executable `<slug>-run.sh` runner script (see template below).
3. **If it exists:**
   - Read the entire file. Do NOT reprocess completed chunks.

### Step 2: Execute One Work Chunk
- Pick the highest-priority pending chunk.
- Complete only that single chunk (unless explicitly instructed otherwise).
- **You may adjust the chunk list** if the initial breakdown is suboptimal: merge, split, add, remove, or reorder chunks as needed. Document all changes in the work log.

### Step 3: Update Progress File
After completing the chunk:
1. Mark it as completed with a timestamp.
2. Add a work log entry (see template) covering: what was done, files changed, any task list modifications, and notes for the next agent.
3. If chunks remain: state the next action. If all complete: mark status as `FINISHED`.

If you hit a blocker before finishing, mark the task as `BLOCKED`, explain the issue in the work log, and notify the requester.

### Step 4: Exit
- If work remains: signal that the task is ready for the next agent.
- If complete: notify the requester with a link to the progress file.

---

## Progress File Template

```markdown
---
slug: <short-id>
task_name: <human-readable name>
task_context: |
  Full task description, requirements, constraints, and paths to relevant files.
total_chunks: <N>
status: IN_PROGRESS | FINISHED | BLOCKED
---

## Work Chunks
| ID | Description | Status | Assignee | Completed At |
|----|-------------|--------|----------|--------------|
| 1 | <description> | PENDING | | |
| 2 | <description> | PENDING | | |

## Work Log
> Newest entries first.

### [YYYY-MM-DD HH:MM] <agent name>
- Completed chunk <X>: <summary>
- Changes made: <files and key modifications>
- **Task list modified** (if applicable): <what changed and why>
- Next action: <what the next agent should do>
- Notes: <context, warnings, unresolved items>

---
## Next Action
> Present only when status=IN_PROGRESS.
<Explicit instruction for the next agent, including any context from prior chunks.>
```

---

## Runner Script Template

```bash
#!/bin/bash
# Task runner for <task-name>
set -euo pipefail

yolo() {
  fish -c 'source ~/.config/fish/yolo.fish; yolo $argv' -- "$@"
}

echo "<Task Name> Automatic Runner"
echo "==========================="

while true; do
  if grep -q "status: FINISHED" progress-<slug>.md; then
    echo "TASK COMPLETED!"
    break
  fi

  next_action=$(awk '/## Next Action/{flag=1; next} /---/{flag=0} flag' progress-<slug>.md | grep -v '^$' | head -1)
  echo "Starting next chunk: $next_action"

  yolo --loadenv ark claude -p "
    STRICTLY FOLLOW THE INSTRUCTIONS IN prompt-task.md FOR LONG-RUNNING TASKS.
    1. Read progress-<slug>.md to understand the current task state
    2. Complete ONLY the NEXT PENDING work chunk (do NOT attempt multiple chunks)
    3. Update progress-<slug>.md with your work log, any task list adjustments, and updated chunk status
    4. Exit immediately after finishing the single chunk
  "
  echo "Chunk completed"
done
```

---

## Rules
1. **No work duplication:** Never reprocess chunks marked as completed.
2. **Atomic execution:** Complete the full chunk before updating the progress file.
3. **Transparent logging:** Write enough detail so the next agent needs no rechecking.
4. **Independent chunks:** No dependencies between chunks unless explicitly documented.
5. **Document task list changes:** When modifying chunks, update `total_chunks`, renumber IDs if needed, and explain changes in the work log.
6. **No assumptions:** If the progress file is ambiguous, ask for clarification before proceeding.
