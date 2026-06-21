# Hello World Plugin

Output a greeting message with the current date. Use this plugin to verify
that your Orchelium agent is reachable and executing plugins correctly, or as
a lightweight status step inside an orchestration.

---

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| **Greeting Message** | Yes | The greeting word or phrase, e.g. `Hello` or `Good morning` |
| **Name** | Yes | The name of the person or system being greeted, e.g. `World` or `Proxmox-01` |

---

## Output

The plugin writes a single formatted message to the job log:

```
<Greeting>, <Name>! Today is <Weekday, DD Month YYYY>.
```

### Example

With **Greeting** set to `Good morning` and **Name** set to `Dave`:

```
Good morning, Dave! Today is Friday, 20 June 2025.
```

---

## Structured Output

The plugin also emits a JSON summary at the end of the log, which can be read
by downstream **Condition** nodes in an orchestration:

```json
{
  "success": true,
  "exitCode": 0,
  "greeting": "Good morning",
  "recipient": "Dave",
  "date": "Friday, 20 June 2025",
  "message": "Good morning, Dave! Today is Friday, 20 June 2025.",
  "durationSeconds": 0
}
```

---

## Example Node Configuration

```
Greeting Message:  Hello
Name:              World
```

Produces:

```
Hello, World! Today is Monday, 23 June 2025.
```

---

## Use Cases

- **Agent connectivity check** — place a Hello World node at the start of an
  orchestration to confirm the target agent is online and responsive before
  running longer backup steps.

- **Smoke test after deployment** — run this plugin immediately after installing
  or updating an agent to confirm the plugin engine is working correctly.

- **Orchestration labelling** — use a greeting message like `Starting backup for`
  and a name like your NAS hostname to add a clear human-readable marker at the
  top of a job log.

---

## Requirements

- Any Linux agent supported by Orchelium
- `python3` available on the agent (used for JSON parsing and output)
- No additional packages required
