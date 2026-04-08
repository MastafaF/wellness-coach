#!/usr/bin/env bash
# install.sh — Learning Coach one-command setup
#
# What this does:
#   1. Copies skill files into ~/.claude/skills/learning-coach/
#   2. Copies the root SKILL.md into ~/.claude/skills/learn/ (Claude Code skill slot)
#   3. Appends the terminal-startup tip hook to ~/.bashrc (Layer 1 notifications)
#   4. On Windows: optionally registers the Task Scheduler toast (Layer 2)
#   5. On macOS/Linux: optionally adds a cron job for background notifications
#
# Usage:
#   bash install.sh          — interactive install
#   bash install.sh --silent — skip all prompts, install everything

set -euo pipefail

SILENT=false
[[ "${1:-}" == "--silent" ]] && SILENT=true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load centralized config for defaults (paths, interval, etc.)
source "$SCRIPT_DIR/skills/learn/scripts/config.sh"
INSTALL_DIR="$LEARNING_INSTALL_DIR"
SKILL_SLOT="${LEARNING_BASE}/skills/learn"

# ── Helpers ───────────────────────────────────────────────────────────────────
print_step() { echo ""; echo "  ▸ $1"; }
print_ok()   { echo "    ✓ $1"; }
print_skip() { echo "    – $1 (skipped)"; }

ask() {
  # ask <prompt> → returns 0 (yes) or 1 (no)
  local prompt="$1"
  if [[ "$SILENT" == true ]]; then
    return 0
  fi
  read -r -p "    $prompt [Y/n] " reply
  [[ -z "$reply" || "$reply" =~ ^[Yy] ]]
}

OS="$(uname -s 2>/dev/null || echo unknown)"

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo "  ╭──────────────────────────────────────────────────────╮"
echo "  │  Learning Coach — installer                          │"
echo "  ╰──────────────────────────────────────────────────────╯"
echo ""
echo "  Installing into: $INSTALL_DIR"

# ── Step 1: Copy skill files ──────────────────────────────────────────────────
print_step "Copying skill files to ~/.claude/skills/learning-coach/"
mkdir -p "$INSTALL_DIR/scripts"
cp -r "$SCRIPT_DIR/skills/learn/scripts/." "$INSTALL_DIR/scripts/"
cp "$SCRIPT_DIR/skills/learn/focus-videos.md" "$INSTALL_DIR/"
print_ok "Scripts and focus-videos.md copied"

# ── Step 2: Register the Claude Code skill ────────────────────────────────────
print_step "Registering skill in ~/.claude/skills/learn/"
mkdir -p "$SKILL_SLOT"
cp "$SCRIPT_DIR/skills/learn/SKILL.md" "$SKILL_SLOT/SKILL.md"
print_ok "SKILL.md installed at $SKILL_SLOT/SKILL.md"
echo "    → You can now run /learn inside Claude Code"

# ── Step 3: Create user config stub ───────────────────────────────────────
print_step "Configuration"
USER_CONFIG="${LEARNING_BASE}/learning-config.sh"
if [[ -f "$USER_CONFIG" ]]; then
  print_ok "User config already exists at $USER_CONFIG"
else
  cat > "$USER_CONFIG" << 'CONF'
# Learning Coach — user overrides
# Uncomment and edit any line to customize. Changes take effect immediately.
#
# LEARNING_INTERVAL=60          # minutes between notifications
# LEARNING_CATEGORY_POOL="quran hadith dua seerah ancient modern civilizations solar-system cosmos exploration javascript python git linux"
# LEARNING_FALLBACK_VIDEO="https://www.youtube.com/watch?v=bSkzWpcWz-o"
# LEARNING_TASK_NAME="LearningCoach"
CONF
  print_ok "Created $USER_CONFIG (edit to customize)"
fi

# ── Step 4: Layer 1 — terminal startup tip via ~/.bashrc ──────────────────────
print_step "Layer 1: terminal startup tip (appended to ~/.bashrc)"
BASHRC="$HOME/.bashrc"
HOOK_LINE="bash \"\$HOME/.claude/skills/learning-coach/scripts/notify.sh\" 2>/dev/null"

if grep -qF "notify.sh" "$BASHRC" 2>/dev/null; then
  print_skip "Hook already present in ~/.bashrc"
else
  if ask "Add terminal startup tip to ~/.bashrc?"; then
    echo "" >> "$BASHRC"
    echo "# Learning Coach — show a tip on terminal startup" >> "$BASHRC"
    echo "$HOOK_LINE" >> "$BASHRC"
    print_ok "Hook added to ~/.bashrc (takes effect in new terminals)"
  else
    print_skip "~/.bashrc hook"
    echo "    To add manually, append to ~/.bashrc:"
    echo "      $HOOK_LINE"
  fi
fi

# ── Step 4: Layer 2 — background OS notifications ─────────────────────────────
print_step "Layer 2: background notifications"

case "$OS" in
  MINGW*|CYGWIN*|MSYS*)
    echo "    Platform: Windows"
    if ask "Register Windows Task Scheduler toast (fires every $LEARNING_INTERVAL min, even when Claude is closed)?"; then
      bash "$INSTALL_DIR/scripts/setup-scheduler.sh" enable
      print_ok "Windows scheduled task registered"
    else
      print_skip "Windows Task Scheduler"
      echo "    To enable later:  bash ~/.claude/skills/learning-coach/scripts/setup-scheduler.sh enable"
    fi
    ;;

  Darwin)
    echo "    Platform: macOS"
    echo "    macOS notifications use osascript (built-in, no extra install needed)."
    if ask "Set up a cron job to fire a notification every $LEARNING_INTERVAL minutes?"; then
      CRON_LINE="*/$LEARNING_INTERVAL * * * * bash \"$INSTALL_DIR/scripts/notify.sh\" --toast-only 2>/dev/null"
      # Check if already present
      if crontab -l 2>/dev/null | grep -qF "learning-coach/scripts/notify.sh"; then
        print_skip "Cron entry already exists"
      else
        (crontab -l 2>/dev/null; echo "$CRON_LINE") | crontab -
        print_ok "Cron job added (every $LEARNING_INTERVAL min)"
      fi
    else
      print_skip "macOS cron job"
      echo "    To enable later, run:"
      echo "      (crontab -l 2>/dev/null; echo '*/$LEARNING_INTERVAL * * * * bash \"$INSTALL_DIR/scripts/notify.sh\" --toast-only 2>/dev/null') | crontab -"
    fi
    ;;

  Linux)
    echo "    Platform: Linux"
    echo "    Linux notifications use notify-send (install libnotify-bin if missing)."
    if ask "Set up a cron job to fire a notification every $LEARNING_INTERVAL minutes?"; then
      CRON_LINE="*/$LEARNING_INTERVAL * * * * bash \"$INSTALL_DIR/scripts/notify.sh\" --toast-only 2>/dev/null"
      if crontab -l 2>/dev/null | grep -qF "learning-coach/scripts/notify.sh"; then
        print_skip "Cron entry already exists"
      else
        (crontab -l 2>/dev/null; echo "$CRON_LINE") | crontab -
        print_ok "Cron job added (every $LEARNING_INTERVAL min)"
      fi
    else
      print_skip "Linux cron job"
    fi
    ;;

  *)
    echo "    Platform: unrecognized ($OS) — skipping background notifications"
    ;;
esac

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "  ╭──────────────────────────────────────────────────────╮"
echo "  │  Installation complete                               │"
echo "  ╰──────────────────────────────────────────────────────╯"
echo ""
echo "  Next steps:"
echo "    /learn              → first-run profile setup in Claude Code"
echo "    /learn focus        → open a random learning video"
echo "    /loop 1h learn      → auto tips every hour"
echo ""
