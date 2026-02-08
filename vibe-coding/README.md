# Vibe Coding Best Practices

This directory contains resources, prompts, and guidelines for efficient "Vibe Coding" (AI-assisted development).

## Project Setup & Organization

To maintain a clean repository while collaborating with others, keep your personal AI context and temporary files separate from the codebase.

### 1. Workspace Directory
Create a `workspace/` directory at the root of your repository. This is where you will store task-specific context, prompts, and specifications.

**Configuration:**
Add `workspace/` to your global `.gitignore` to ensure it is ignored in all your projects without modifying individual project `.gitignore` files.
```bash
git config --global core.excludesfile ~/.gitignore
echo "workspace/" >> ~/.gitignore
```

### 2. Directory Structure
Organize your workspace by feature or task. Include a global `AGENTS.md` for shared agent configurations.

```text
workspace/
├── 001-feature-login/
├── 002-feature-dashboard/
├── 003-debug-api/
└── AGENTS.md
```

## Workflow: Spec Is Code Is Tests

*Reference: [matklad's blog](https://matklad.github.io/2025/08/31/vibe-coding-terminal-editor.html#Spec-Is-Code-Is-Tests)*

Avoid unstructured, back-and-forth chatting with LLMs in the terminal. This often leads to messy context and makes it difficult to track changes. instead, maintain a **Specification (Spec)**.

Treat the LLM as a "translator" that converts between Specification, Code, and Tests.

### The Spec-Driven Workflow

For each task, maintain a `spec.md` file:
```text
workspace/
└── 001-feature-xxxx/
    └── spec.md
```

1.  **Write/Update `spec.md`**: specific the desired behavior, logic, or changes clearly in this file first.
2.  **Align the AI**: Instruct the AI to read `spec.md` to understand the context.
3.  **Verify**: Ensure the spec clearly covers the logic before asking for code.
4.  **Implement**: Have the AI generate code and tests based strictly on the spec.

## Concurrent Workflows

If you work on multiple tasks simultaneously using **git worktree**:

1.  Create separate worktrees for different branches/jobs.
2.  Use symbolic links (soft links) to map your central `workspace/` directory into each worktree. This allows you to reuse your Vibe Coding context across different working states.

## Agent Tools & Evolution

AI tools and CLI agents evolve rapidly. To maintain peak productivity:
- **Stay Updated**: Regularly update your CLI tools and local agent environments.
- **SOTA Models**: Always prefer State-of-the-Art (SOTA) models for complex reasoning and code generation.
- **Continuous Learning**: Keep track of new patterns in agent interaction and tool-use.

**Reference**: [CLI Agent ABC by wz21](https://wz21.notion.site/CLI-Agent-ABC-300c4329534580c6b5d2f9164ae4ea8c)

