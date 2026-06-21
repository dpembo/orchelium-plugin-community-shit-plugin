# orchelium-plugin-community-hello-world

An [Orchelium](https://github.com/dpembo/orchelium) community plugin that outputs
a greeting message with the current date. Simple by design — its primary purpose
is to serve as a **reference template** for developers building their own plugins.

---

## What It Does

```
Hello, World! Today is Monday, 23 June 2025.
```

Given a **greeting** and a **name**, the plugin outputs:

```
<greeting>, <name>! Today is <weekday, DD Month YYYY>.
```

---

## Installation

Open the Orchelium **Plugin Manager**, find **Hello World** under the Community
tab, and click **Install**. The plugin is ready to use immediately — no agent
restart required.

Or install manually on the Orchelium host:

```bash
# From the Orchelium plugins directory
git clone https://github.com/your-github-username/orchelium-plugin-community-hello-world \
  plugins/orchelium-plugin-community-hello-world
```

---

## Usage

Add a **Hello World** node to any orchestration and set:

| Field | Example |
|-------|---------|
| Greeting Message | `Hello` |
| Name | `World` |

The node log will show:

```
[hello-world] Starting Hello World plugin
[hello-world] Greeting  : Hello
[hello-world] Recipient : World
[hello-world] Date      : Monday, 23 June 2025

[hello-world] Output:

  Hello, World! Today is Monday, 23 June 2025.

{"success":true,"exitCode":0,"greeting":"Hello","recipient":"World","date":"Monday, 23 June 2025","message":"Hello, World! Today is Monday, 23 June 2025.","durationSeconds":0}

[hello-world] Done (exit 0)
```

---

## For Plugin Developers

This plugin is intentionally simple so the structure is easy to follow. The
`run.sh` is heavily commented and covers every convention an Orchelium plugin
should follow:

| Section | What it covers |
|---------|----------------|
| **Input handling** | How `INPUT_JSON` is injected by the hub and how to test locally |
| **Field parsing** | Using `python3` to safely extract values from JSON |
| **Validation** | Checking required fields and exiting cleanly with errors |
| **Log output** | Prefixing lines, merging stderr, structured progress messages |
| **JSON summary** | Emitting a final result object for condition nodes and the UI |
| **Exit codes** | Propagating the real exit code so Orchelium marks nodes correctly |

### Plugin File Structure

Every Orchelium community plugin repository must contain these files at the
repo root:

```
orchelium-plugin-community-<name>/
├── plugin.yaml      # Plugin metadata, input schema, and command declaration
├── run.sh           # The shell script executed on the agent
├── docs.md          # End-user documentation (rendered in the Plugin Manager)
├── README.md        # This file — repo landing page for developers
└── icon.svg         # (optional) Plugin icon shown in the Plugin Manager UI
```

### Naming Convention

Community plugin repositories **must** follow this naming pattern for automatic
discovery by the Orchelium Plugin Manager:

```
orchelium-plugin-community-<your-plugin-name>
```

Where `<your-plugin-name>` is lowercase alphanumeric with hyphens only.
Examples: `orchelium-plugin-community-rsync`, `orchelium-plugin-community-mysql-dump`.

### plugin.yaml Checklist

```yaml
name: your-plugin-name       # lowercase, matches repo suffix
version: 1.0.0               # semver — bump on every release
label: Your Plugin Label     # shown in the Plugin Manager UI
description: |               # shown on the plugin card
  One or two sentences.
source: community            # must be "community" for auto-discovery
maintainer: "github-user"    # your GitHub username
repository_url: "https://github.com/..."
category: backup             # backup | databases | file-sync | storage |
                             # containers | system | network | tools | archiving
tags: [tag1, tag2]
inputs:
  - name: field_name
    label: Human Label
    type: string             # string | secret | number | boolean | select | list | json
    required: true
    description: |
      Shown as help text in the plugin form.
command: ./run.sh
output:
  format: auto               # auto | json | text
```

### Testing Locally

Before pushing, test `run.sh` directly on a machine that has the same
environment as your target agent:

```bash
# Basic test
INPUT_JSON='{"greeting":"Hello","recipient":"World"}' bash run.sh

# Missing required field — should exit non-zero with a clear error
INPUT_JSON='{"greeting":"Hello"}' bash run.sh

# Empty input — should exit non-zero
bash run.sh
```

---

## Requirements

- Any Linux agent supported by Orchelium
- `python3` (used for JSON parsing — available on virtually all Linux systems)

---

## Contributing

Bug reports and pull requests welcome. If you build a plugin you think others
would find useful, submit it to the
[Orchelium community plugin directory](https://github.com/dpembo/orchelium/discussions).

---

## License

[Apache License 2.0](LICENSE)
