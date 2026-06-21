#!/usr/bin/env bash
# =============================================================================
# Orchelium Community Plugin — Hello World
# =============================================================================
#
# PURPOSE
#   Outputs a greeting message in the format:
#       <greeting>, <name>! Today is <current date>.
#
#   This script is intentionally simple and heavily commented to serve as a
#   reference template for developers building their own Orchelium plugins.
#
# HOW ORCHELIUM CALLS THIS SCRIPT
#   The Orchelium hub prepends INPUT_JSON as a shell variable before executing
#   this script on the agent. The agent captures stdout to the job log.
#   stderr is merged into stdout below so everything appears in one stream.
#
#   You can also invoke this script manually for testing:
#       INPUT_JSON='{"greeting":"Hello","recipient":"World"}' bash run.sh
#   or:
#       bash run.sh '{"greeting":"Hello","recipient":"World"}'
#
# OUTPUT CONTRACT
#   Orchelium expects one of:
#     • Free-form text lines (format: auto) — displayed as-is in the log viewer
#     • A final JSON object on the last line — parsed and shown as structured
#       output in the node detail panel when output.format is set to json
#
#   This template uses format: auto and emits a JSON summary at the end.
#   The hub treats the script exit code as success (0) or failure (non-zero).
#
# =============================================================================

set -uo pipefail

# Merge stderr into stdout so all output appears in the Orchelium log viewer.
# Without this, error messages from failed commands are invisible to the user.
exec 2>&1

# =============================================================================
# STEP 1 — Receive input
# =============================================================================
# INPUT_JSON is injected by the hub as a variable prepended to this script.
# The fallback to $1 allows direct manual invocation for local testing.

INPUT_JSON="${INPUT_JSON:-${1:-}}"

if [ -z "$INPUT_JSON" ]; then
  echo "[hello-world] ERROR: No input JSON provided."
  echo '{"success":false,"error":"No input JSON provided"}'
  exit 1
fi

# =============================================================================
# STEP 2 — Parse inputs
# =============================================================================
# parse_field() extracts a single named field from the INPUT_JSON string using
# Python's json module. This is the recommended approach for Orchelium plugins
# because it handles quoted strings, unicode, and nested values safely without
# requiring jq to be installed on the agent.
#
# For plugins with many fields, define all parse_field calls together here so
# there is one clear place to see every input the plugin accepts.

parse_field() {
  local field="$1"
  python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('$field',''))" \
    <<< "$INPUT_JSON" 2>/dev/null || echo ""
}

GREETING=$(parse_field greeting)
RECIPIENT=$(parse_field recipient)

# =============================================================================
# STEP 3 — Validate inputs
# =============================================================================
# Always validate required fields explicitly and emit a clear error message.
# Exit with a non-zero code so Orchelium marks the node as failed and can
# trigger downstream failure branches or alert notifications.

if [ -z "$GREETING" ]; then
  echo "[hello-world] ERROR: 'greeting' is a required field."
  echo '{"success":false,"error":"greeting is required"}'
  exit 1
fi

if [ -z "$RECIPIENT" ]; then
  echo "[hello-world] ERROR: 'recipient' is a required field."
  echo '{"success":false,"error":"recipient is required"}'
  exit 1
fi

# =============================================================================
# STEP 4 — Execute
# =============================================================================
# Record a start timestamp so we can report duration in the JSON summary.
# This is useful for longer-running operations and gives the user a sense
# of how long each plugin step takes in the orchestration timeline.

START_TS=$(date +%s)
EXIT_CODE=0

# Capture the current date in a human-readable format.
CURRENT_DATE=$(date '+%A, %d %B %Y')

# Prefix log lines with [plugin-name] so they are easy to identify in
# multi-step orchestration logs where output from several plugins is mixed.
echo "[hello-world] Starting Hello World plugin"
echo "[hello-world] Greeting  : ${GREETING}"
echo "[hello-world] Recipient : ${RECIPIENT}"
echo "[hello-world] Date      : ${CURRENT_DATE}"
echo ""

# --- The actual work ----------------------------------------------------------

OUTPUT_MESSAGE="${GREETING}, ${RECIPIENT}! Today is ${CURRENT_DATE}."

echo "[hello-world] Output:"
echo ""
echo "  ${OUTPUT_MESSAGE}"
echo ""

# =============================================================================
# STEP 5 — Emit structured JSON summary
# =============================================================================
# Emitting a JSON object as the final line of output is optional but strongly
# recommended. It allows:
#   • Downstream condition nodes to branch based on field values
#   • The Orchelium node detail panel to display a structured result
#   • Easier debugging — the full context is captured alongside log output
#
# Use python3 to construct JSON safely. Never build JSON by hand with string
# concatenation — user-provided values may contain quotes or special characters
# that would produce invalid JSON.
#
# Keep variable expansion inside the PYEOF block quoted and double-escaped
# where necessary. For complex values, write them to a temp file and read them
# in Python, or pass them via environment variables.

DURATION=$(( $(date +%s) - START_TS ))

python3 - <<PYEOF
import json

result = {
    "success":         True,
    "exitCode":        0,
    "greeting":        "$GREETING",
    "recipient":       "$RECIPIENT",
    "date":            "$CURRENT_DATE",
    "message":         "$OUTPUT_MESSAGE",
    "durationSeconds": $DURATION,
}

print(json.dumps(result))
PYEOF

EXIT_CODE=$?

# =============================================================================
# STEP 6 — Exit
# =============================================================================
# Always exit with the real exit code of the last meaningful operation.
# Orchelium uses this to determine node success or failure.

echo ""
echo "[hello-world] Done (exit ${EXIT_CODE})"
exit $EXIT_CODE
