#!/usr/bin/env bash
# notify.sh — Wellness Coach cross-session notification core
# Shared by both Layer 1 (terminal startup) and Layer 2 (Task Scheduler toast)
#
# Usage: bash notify.sh
# Env vars:
#   WELLNESS_INTERVAL  — minutes between notifications (default: 60)

set -euo pipefail

PROFILE="$HOME/.claude/wellness-profile.md"
TIMESTAMP="$HOME/.claude/wellness-last-check"
TIPS="$HOME/.claude/skills/wellness-coach/scripts/tips.md"
INTERVAL="${WELLNESS_INTERVAL:-60}"

# ── 1. Interval guard ────────────────────────────────────────────────────────
if [[ -f "$TIMESTAMP" ]]; then
  last_modified=$(stat -c %Y "$TIMESTAMP" 2>/dev/null || stat -f %m "$TIMESTAMP" 2>/dev/null || echo 0)
  now=$(date +%s)
  elapsed_minutes=$(( (now - last_modified) / 60 ))
  if (( elapsed_minutes < INTERVAL )); then
    exit 0  # Too soon — exit silently
  fi
fi

# ── 2. Tips file must exist ──────────────────────────────────────────────────
if [[ ! -f "$TIPS" ]]; then
  exit 0
fi

# ── 3. Pick category based on profile keywords ──────────────────────────────
# Default weight: breathing gets 3 slots (highest priority per profile),
# others get 1-2 each. Uses a weighted random pick via array repetition.
category_pool=(breathing breathing breathing stretch-home stretch-home stretch-office presence presence eyes)

if [[ -f "$PROFILE" ]]; then
  profile_text=$(tr '[:upper:]' '[:lower:]' < "$PROFILE")
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
mapfile -t candidates < <(grep -E "^\[${category}\]" "$TIPS" 2>/dev/null || true)

# Fallback: pick any tip if category had no matches
if [[ ${#candidates[@]} -eq 0 ]]; then
  mapfile -t candidates < <(grep -E "^\[[a-z-]+\]" "$TIPS" 2>/dev/null || true)
fi

if [[ ${#candidates[@]} -eq 0 ]]; then
  exit 0
fi

tip_index=$(( RANDOM % ${#candidates[@]} ))
raw_tip="${candidates[$tip_index]}"

# Strip the [category] prefix
tip_text="${raw_tip#\[*\] }"

# ── 5. Print formatted tip ───────────────────────────────────────────────────
echo ""
echo "  ╭──────────────────────────────────────────────────────╮"
echo "  │  Wellness check-in                                   │"
echo "  ╰──────────────────────────────────────────────────────╯"
# Word-wrap tip to ~54 chars for the box
echo "$tip_text" | fold -s -w 54 | while IFS= read -r line; do
  printf "  %s\n" "$line"
done
echo ""

# ── 6. Update timestamp ──────────────────────────────────────────────────────
touch "$TIMESTAMP"
