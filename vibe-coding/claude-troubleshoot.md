# Claude Code CLI Troubleshooting Guide

Common problems and solutions when using the Claude Code CLI.

---

## 1. WebFetch "Unable to verify domain is safe" error

**Symptom:** WebFetch fails with:

```
Error: Unable to verify if domain <domain> is safe to fetch.
This may be due to network restrictions or enterprise security policies blocking claude.ai.
```

**Root cause:** Before fetching any URL, WebFetch calls `claude.ai/api/web/domain_info` to validate the target domain. If `claude.ai` itself is blocked or unreachable (common in corporate/restrictive networks), the preflight check fails -- even though the target URL is accessible via curl or browser.

**Workarounds:** Skip preflight validation -- add to your Claude Code settings `.claude/settings.json`:

```json
{
  "skipWebFetchPreflight": true
}
```

Note: This flag is undocumented and was discovered from source code.

**Reference:** [anthropics/claude-code#6388](https://github.com/anthropics/claude-code/issues/6388)

---

## 2. How to add a callback function when a job is done

To run custom shell commands when a job finishes (common use case: send desktop notification, push notification, or sound alert when a long task completes), you can use Claude Code **hooks**.

Hooks are configured in your `~/.claude/settings.json` file. The correct structure is:

```json
{
  "hooks": {
    "EVENT_NAME": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "YOUR_SHELL_COMMAND_OR_SCRIPT_HERE"
          }
        ]
      }
    ]
  }
}
```

**Useful events for callbacks:**

- `Stop` - fires when Claude finishes responding (after every agent job completes)
- `post-run` - fires after a run completes
- All available hook events: [See hooks documentation](https://docs.anthropic.com/en/docs/claude-code/hooks#available-hooks)

### Example: Send push notification after job completes (Pushdeer)

Here's a working example from actual `settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 -c \"\nimport sys, json, urllib.parse, urllib.request\ndata = json.load(sys.stdin)\nmsg = data.get('last_assistant_message', 'No message')[:200]\nencoded = urllib.parse.quote(msg)\nimport os\nkey = os.environ.get('PUSHDEER_API_KEY', '')\nurllib.request.urlopen(f'https://api2.pushdeer.com/message/push?pushkey={key}&text={encoded}')\n\""
          }
        ]
      }
    ]
  }
}
```

## Still having issues?

Check the official documentation at [https://docs.anthropic.com/en/docs/claude-code](https://docs.anthropic.com/en/docs/claude-code) or search for existing issues on [GitHub](https://github.com/anthropics/claude-code/issues).

