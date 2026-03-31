#!/usr/bin/env bash
# notify.sh — Wellness Coach cross-session notification core
# Shared by both Layer 1 (terminal startup) and Layer 2 (OS background toast)
#
# Usage: bash notify.sh [--toast-only]
#   --toast-only  Skip terminal print; only fire the OS toast (used by schedulers)
# Env vars:
#   WELLNESS_INTERVAL  — minutes between notifications (default: 60)

set -euo pipefail

# Load centralized config (paths, interval, category weights, etc.)
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
INTERVAL="$WELLNESS_INTERVAL"
TOAST_ONLY=false
[[ "${1:-}" == "--toast-only" ]] && TOAST_ONLY=true

# ── 1. Interval guard ────────────────────────────────────────────────────────
if [[ -f "$WELLNESS_TIMESTAMP" ]]; then
  last_modified=$(stat -c %Y "$WELLNESS_TIMESTAMP" 2>/dev/null || stat -f %m "$WELLNESS_TIMESTAMP" 2>/dev/null || echo 0)
  now=$(date +%s)
  elapsed_minutes=$(( (now - last_modified) / 60 ))
  if (( elapsed_minutes < INTERVAL )); then
    exit 0  # Too soon — exit silently
  fi
fi

# ── 2. Tips file must exist ──────────────────────────────────────────────────
if [[ ! -f "$WELLNESS_TIPS" ]]; then
  exit 0
fi

# ── 3. Pick category based on profile keywords ──────────────────────────────
# Default weight: breathing gets 3 slots (highest priority per profile),
# others get 1-2 each. Uses a weighted random pick via array repetition.
IFS=' ' read -ra category_pool <<< "$WELLNESS_CATEGORY_POOL"

if [[ -f "$WELLNESS_PROFILE" ]]; then
  profile_text=$(tr '[:upper:]' '[:lower:]' < "$WELLNESS_PROFILE")
  # Adjust pool based on detected keywords
  extra=()
  grep -q "breathing" <<< "$profile_text"   && extra+=(breathing breathing)
  grep -q "yoga mat\|home" <<< "$profile_text" && extra+=(stretch-home)
  grep -q "office\|chair" <<< "$profile_text"  && extra+=(stretch-office)
  grep -q "mindful\|present\|focus" <<< "$profile_text" && extra+=(presence)
  grep -q "eye\|screen\|fatigue" <<< "$profile_text" && extra+=(eyes)
  category_pool+=("${extra[@]}")
fi

# Pick a random category from the weighted pool
pool_size=${#category_pool[@]}
random_index=$(( RANDOM % pool_size ))
category="${category_pool[$random_index]}"

# ── 4. Pick a random tip from that category ──────────────────────────────────
# Read all lines matching [category] from tips.md
mapfile -t candidates < <(grep -E "^\[${category}\]" "$WELLNESS_TIPS" 2>/dev/null || true)

# Fallback: pick any tip if category had no matches
if [[ ${#candidates[@]} -eq 0 ]]; then
  mapfile -t candidates < <(grep -E "^\[[a-z-]+\]" "$WELLNESS_TIPS" 2>/dev/null || true)
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
if [[ -f "$WELLNESS_FOCUS_VIDEOS" ]]; then
  mapfile -t all_urls < <(grep -E "^https?://" "$WELLNESS_FOCUS_VIDEOS" 2>/dev/null || true)
  if [[ ${#all_urls[@]} -gt 0 ]]; then
    url_index=$(( RANDOM % ${#all_urls[@]} ))
    focus_url="${all_urls[$url_index]}"
  fi
fi

# ── 6. Print formatted tip to terminal ───────────────────────────────────────
if [[ "$TOAST_ONLY" == false ]]; then
  echo ""
  echo "  ╭──────────────────────────────────────────────────────╮"
  echo "  │  Wellness check-in                                   │"
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
    osascript -e "display notification \"${osa_msg}\" with title \"Wellness check-in\"" 2>/dev/null || true
    # If a focus URL is available, offer it via a second notification
    if [[ -n "$focus_url" ]]; then
      osascript -e "display notification \"Open focus video: ${focus_url}\" with title \"Wellness — focus video\"" 2>/dev/null || true
    fi
    ;;
  Linux)
    # Linux — use notify-send if available
    if command -v notify-send &>/dev/null; then
      notify-send "Wellness check-in" "$tip_text" --icon=dialog-information --urgency=low 2>/dev/null || true
    fi
    ;;
  MINGW*|CYGWIN*|MSYS*)
    # Windows/Git Bash — toast is handled by notify.ps1 (Task Scheduler layer)
    # Terminal print above is sufficient for Layer 1 (bashrc startup)
    ;;
esac

# ── 8. Update timestamp ──────────────────────────────────────────────────────
touch "$WELLNESS_TIMESTAMP"
