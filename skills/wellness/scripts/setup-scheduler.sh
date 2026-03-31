#!/usr/bin/env bash
# setup-scheduler.sh — Manage Wellness Coach cross-session notifications (Windows)
#
# Usage:
#   bash setup-scheduler.sh           → same as 'enable'
#   bash setup-scheduler.sh enable    → create/re-enable the scheduled task
#   bash setup-scheduler.sh disable   → pause notifications (task kept, not deleted)
#   bash setup-scheduler.sh delete    → remove the scheduled task entirely
#   bash setup-scheduler.sh status    → show current state
#
# Note: schtasks flags use // instead of / to prevent Git Bash path translation.

set -euo pipefail

# Load centralized config
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
TASK_NAME="$WELLNESS_TASK_NAME"
CMD="${1:-enable}"

# ── Derive Windows-style home path ───────────────────────────────────────────
if command -v cygpath &>/dev/null; then
  WIN_HOME=$(cygpath -w "$HOME")
else
  WIN_HOME=$(echo "$HOME" | sed 's|^/\([a-zA-Z]\)/|\1:\\|; s|/|\\|g')
fi
PS1_SCRIPT="${WIN_HOME}\\.claude\\skills\\wellness-coach\\scripts\\notify.ps1"

echo ""
echo "  Wellness Coach — Notification Manager"
echo "  ──────────────────────────────────────"
echo ""

# ── Windows check ────────────────────────────────────────────────────────────
if ! command -v schtasks &>/dev/null; then
  echo "  ERROR: schtasks not found. This script requires Windows (Git Bash / MSYS2)."
  exit 1
fi

# ── Helper: check if task exists ─────────────────────────────────────────────
task_exists() {
  schtasks //Query //TN "$TASK_NAME" &>/dev/null
}

# ── Helper: get task status ───────────────────────────────────────────────────
task_status() {
  if task_exists; then
    local info
    info=$(schtasks //Query //TN "$TASK_NAME" //FO LIST 2>/dev/null)
    if echo "$info" | grep -qi "disabled"; then
      echo "disabled"
    else
      echo "enabled"
    fi
  else
    echo "not installed"
  fi
}

# ── Commands ─────────────────────────────────────────────────────────────────
case "$CMD" in

  enable)
    echo "  Action: enable toast notifications"
    echo ""
    if task_exists; then
      schtasks //Change //TN "$TASK_NAME" //ENABLE 2>&1
      echo "  Task '$TASK_NAME' re-enabled — toasts will fire every $WELLNESS_INTERVAL minutes."
    else
      schtasks //Create \
        //SC MINUTE //MO "$WELLNESS_INTERVAL" \
        //TN "$TASK_NAME" \
        //TR "powershell -WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File \"$PS1_SCRIPT\"" \
        //F 2>&1
      echo "  Task '$TASK_NAME' created — toasts will fire every $WELLNESS_INTERVAL minutes."
    fi
    echo ""
    echo "  To manage later:"
    echo "    bash setup-scheduler.sh status   → check current state"
    echo "    bash setup-scheduler.sh disable  → pause without deleting"
    echo "    bash setup-scheduler.sh delete   → remove entirely"
    ;;

  disable)
    echo "  Action: disable toast notifications (task preserved)"
    echo ""
    if ! task_exists; then
      echo "  Nothing to disable — task '$TASK_NAME' is not installed."
      echo "  Run 'bash setup-scheduler.sh enable' to set it up."
    else
      schtasks //Change //TN "$TASK_NAME" //DISABLE 2>&1
      echo "  Task '$TASK_NAME' disabled. No more toasts until you re-enable."
      echo ""
      echo "  To re-enable:  bash setup-scheduler.sh enable"
      echo "  To delete:     bash setup-scheduler.sh delete"
    fi
    ;;

  delete)
    echo "  Action: delete scheduled task entirely"
    echo ""
    if ! task_exists; then
      echo "  Nothing to delete — task '$TASK_NAME' is not installed."
    else
      schtasks //Delete //TN "$TASK_NAME" //F 2>&1
      echo "  Task '$TASK_NAME' deleted. Toast notifications are fully removed."
      echo ""
      echo "  Layer 1 (terminal startup tips via ~/.bashrc) is unaffected."
      echo "  To disable that too, remove or comment out this line in ~/.bashrc:"
      echo "    bash ~/.claude/skills/wellness-coach/scripts/notify.sh 2>/dev/null"
    fi
    ;;

  status)
    echo "  Scheduled task status"
    echo ""
    state=$(task_status)
    case "$state" in
      enabled)
        echo "  [ON]  Task '$TASK_NAME' is active — toasts fire every $WELLNESS_INTERVAL minutes."
        ;;
      disabled)
        echo "  [OFF] Task '$TASK_NAME' exists but is disabled."
        echo "        Run 'bash setup-scheduler.sh enable' to re-enable."
        ;;
      "not installed")
        echo "  [--]  Task '$TASK_NAME' is not installed."
        echo "        Run 'bash setup-scheduler.sh enable' to set it up."
        ;;
    esac
    echo ""
    # Layer 1 status
    if grep -q "notify.sh" "$HOME/.bashrc" 2>/dev/null; then
      if grep -q "^#.*notify.sh\|^[[:space:]]*#.*notify.sh" "$HOME/.bashrc" 2>/dev/null; then
        echo "  [OFF] Layer 1 (terminal tip) is commented out in ~/.bashrc"
      else
        echo "  [ON]  Layer 1 (terminal tip) is active in ~/.bashrc"
      fi
    else
      echo "  [--]  Layer 1 (terminal tip) is not in ~/.bashrc"
    fi
    ;;

  *)
    echo "  Unknown command: $CMD"
    echo ""
    echo "  Usage: bash setup-scheduler.sh [enable|disable|delete|status]"
    exit 1
    ;;

esac

echo ""
