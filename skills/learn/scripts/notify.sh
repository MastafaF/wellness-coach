#!/usr/bin/env bash
# notify.sh — Learning Coach cross-session notification core
# Shared by both Layer 1 (terminal startup) and Layer 2 (OS background toast)
#
# Usage: bash notify.sh [--toast-only] [--force]
#   --toast-only  Skip terminal print; only fire the OS toast (used by schedulers)
#   --force       Skip interval guard (used when SKILL.md has its own guard)
# Env vars:
#   LEARNING_INTERVAL  — minutes between notifications (default: 60)

set -euo pipefail

# Load centralized config (paths, interval, category weights, etc.)
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
INTERVAL="$LEARNING_INTERVAL"
TOAST_ONLY=false
FORCE=false
for arg in "$@"; do
  case "$arg" in
    --toast-only) TOAST_ONLY=true ;;
    --force)      FORCE=true ;;
  esac
done

# ── 1. Interval guard ────────────────────────────────────────────────────────
if [[ "$FORCE" == false ]] && [[ -f "$LEARNING_TIMESTAMP" ]]; then
  last_modified=$(stat -c %Y "$LEARNING_TIMESTAMP" 2>/dev/null || stat -f %m "$LEARNING_TIMESTAMP" 2>/dev/null || echo 0)
  now=$(date +%s)
  elapsed_minutes=$(( (now - last_modified) / 60 ))
  if (( elapsed_minutes < INTERVAL )); then
    exit 0  # Too soon — exit silently
  fi
fi

# ── 2. Tips file must exist ──────────────────────────────────────────────────
if [[ ! -f "$LEARNING_TIPS" ]]; then
  exit 0
fi

# ── 3. Pick category based on profile keywords ──────────────────────────────
# Default weight: equal across all 4 topics (Deen, History, Space, Tech).
# Uses a weighted random pick via array repetition.
IFS=' ' read -ra category_pool <<< "$LEARNING_CATEGORY_POOL"

if [[ -f "$LEARNING_PROFILE" ]]; then
  profile_text=$(tr '[:upper:]' '[:lower:]' < "$LEARNING_PROFILE")
  # Adjust pool based on detected keywords
  extra=()
  grep -q "quran\|salah\|islam\|deen" <<< "$profile_text"          && extra+=(quran hadith dua seerah)
  grep -q "history\|ancient\|civilization" <<< "$profile_text"      && extra+=(ancient modern civilizations)
  grep -q "space\|astronomy\|nasa\|cosmos" <<< "$profile_text"      && extra+=(solar-system cosmos exploration)
  grep -q "javascript\|python\|coding\|tech" <<< "$profile_text"    && extra+=(javascript python git linux)
  category_pool+=("${extra[@]}")
fi

# Pick a random category from the weighted pool
pool_size=${#category_pool[@]}
random_index=$(( RANDOM % pool_size ))
category="${category_pool[$random_index]}"

# ── 4. Pick a random tip from that category ──────────────────────────────────
# Read all lines matching [category] from tips.md (compatible with bash 3.2+)
candidates=()
while IFS= read -r line; do
  candidates+=("$line")
done < <(grep -E "^\[${category}\]" "$LEARNING_TIPS" 2>/dev/null || true)

# Fallback: pick any tip if category had no matches
if [[ ${#candidates[@]} -eq 0 ]]; then
  while IFS= read -r line; do
    candidates+=("$line")
  done < <(grep -E "^\[[a-z-]+\]" "$LEARNING_TIPS" 2>/dev/null || true)
fi

if [[ ${#candidates[@]} -eq 0 ]]; then
  exit 0
fi

tip_index=$(( RANDOM % ${#candidates[@]} ))
raw_tip="${candidates[$tip_index]}"

# Strip the [category] prefix
tip_text="${raw_tip#\[*\] }"

# ── 5. Pick a focus video URL ────────────────────────────────────────────────
focus_url=""
if [[ -f "$LEARNING_FOCUS_VIDEOS" ]]; then
  all_urls=()
  while IFS= read -r line; do
    all_urls+=("$line")
  done < <(grep -E "^https?://" "$LEARNING_FOCUS_VIDEOS" 2>/dev/null || true)
  if [[ ${#all_urls[@]} -gt 0 ]]; then
    url_index=$(( RANDOM % ${#all_urls[@]} ))
    focus_url="${all_urls[$url_index]}"
  fi
fi

# ── 6. Print formatted tip to terminal ───────────────────────────────────────
if [[ "$TOAST_ONLY" == false ]]; then
  echo ""
  echo "  ╭──────────────────────────────────────────────────────╮"
  echo "  │  Did You Know?                                       │"
  echo "  ╰──────────────────────────────────────────────────────╯"
  # Word-wrap tip to ~54 chars for the box
  echo "$tip_text" | fold -s -w 54 | while IFS= read -r line; do
    printf "  %s\n" "$line"
  done
  echo ""
fi

# ── 7. OS toast notification (background schedulers) ────────────────────────
OS="$(uname -s 2>/dev/null || echo unknown)"

case "$OS" in
  Darwin)
    # macOS — use osascript (built-in, no install required)
    osa_msg=$(echo "$tip_text" | sed "s/'/\\\\'/" | cut -c1-200)
    osascript -e "display notification \"${osa_msg}\" with title \"Did You Know?\"" 2>/dev/null || true
    # If a focus URL is available, offer it via a second notification
    if [[ -n "$focus_url" ]]; then
      osascript -e "display notification \"Open learning video: ${focus_url}\" with title \"Learning — watch & learn\"" 2>/dev/null || true
    fi
    ;;
  Linux)
    # Linux — use notify-send if available
    if command -v notify-send &>/dev/null; then
      notify-send "Did You Know?" "$tip_text" --icon=dialog-information --urgency=low 2>/dev/null || true
    fi
    ;;
  MINGW*|CYGWIN*|MSYS*)
    # Windows/Git Bash — toast is handled by notify.ps1 (Task Scheduler layer)
    # Terminal print above is sufficient for Layer 1 (bashrc startup)
    ;;
esac

# ── 8. Update timestamp ──────────────────────────────────────────────────────
touch "$LEARNING_TIMESTAMP"
