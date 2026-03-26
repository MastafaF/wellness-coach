#!/usr/bin/env bash
# setup-scheduler.sh — One-time setup for Wellness Coach cross-session notifications
#
# Registers a Windows Task Scheduler task that fires every 60 minutes
# and shows a toast notification even when no terminal is open.
#
# Run once: bash ~/.claude/skills/wellness-coach/scripts/setup-scheduler.sh
# Remove:   schtasks /Delete /TN WellnessCoach /F

set -euo pipefail

TASK_NAME="WellnessCoach"
PS1_SCRIPT="$USERPROFILE\\.claude\\skills\\wellness-coach\\scripts\\notify.ps1"

echo ""
echo "  Wellness Coach — Cross-Session Notification Setup"
echo "  ─────────────────────────────────────────────────"
echo ""

# ── Check we're on Windows ───────────────────────────────────────────────────
if ! command -v schtasks &>/dev/null; then
  echo "  ERROR: schtasks not found. This script requires Windows."
  echo "  Layer 1 (terminal startup tip) still works via ~/.bashrc."
  exit 1
fi

# ── Register the scheduled task ─────────────────────────────────────────────
echo "  Registering Task Scheduler task: $TASK_NAME"
echo "  Interval: every 60 minutes"
echo ""

schtasks /Create \
  /SC MINUTE \
  /MO 60 \
  /TN "$TASK_NAME" \
  /TR "powershell -WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File \"$PS1_SCRIPT\"" \
  /F \
  2>&1

echo ""
echo "  Done! Task '$TASK_NAME' created."
echo ""
echo "  What happens now:"
echo "  - Every 60 minutes, a toast notification will appear"
echo "  - The 60-min interval is shared with terminal startup tips"
echo "    (you'll never get two notifications within an hour)"
echo ""
echo "  ── Layer 1: Terminal startup tip ────────────────────────"
echo "  Add this line to ~/.bashrc to also get a tip on each new terminal:"
echo ""
echo "    bash ~/.claude/skills/wellness-coach/scripts/notify.sh 2>/dev/null"
echo ""
echo "  ── Manage the scheduled task ────────────────────────────"
echo "  View:    schtasks /Query /TN $TASK_NAME"
echo "  Disable: schtasks /Change /TN $TASK_NAME /DISABLE"
echo "  Remove:  schtasks /Delete /TN $TASK_NAME /F"
echo ""
