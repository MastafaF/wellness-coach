#!/usr/bin/env bash
# config.sh — Wellness Coach centralized defaults
# All scripts source this file. User overrides go in:
#   ~/.claude/wellness-config.sh

# ── Paths ────────────────────────────────────────────────────────────────
WELLNESS_BASE="${WELLNESS_BASE:-$HOME/.claude}"
WELLNESS_INSTALL_DIR="${WELLNESS_BASE}/skills/wellness-coach"
WELLNESS_PROFILE="${WELLNESS_PROFILE:-${WELLNESS_BASE}/wellness-profile.md}"
WELLNESS_TIMESTAMP="${WELLNESS_TIMESTAMP:-${WELLNESS_BASE}/wellness-last-check}"
WELLNESS_TIPS="${WELLNESS_TIPS:-${WELLNESS_INSTALL_DIR}/scripts/tips.md}"
WELLNESS_FOCUS_VIDEOS="${WELLNESS_FOCUS_VIDEOS:-${WELLNESS_INSTALL_DIR}/focus-videos.md}"
WELLNESS_HABITS="${WELLNESS_HABITS:-${WELLNESS_BASE}/wellness-habits.md}"
WELLNESS_WEEKLY="${WELLNESS_WEEKLY:-${WELLNESS_BASE}/wellness-weekly.md}"

# ── Timing ───────────────────────────────────────────────────────────────
WELLNESS_INTERVAL="${WELLNESS_INTERVAL:-60}"

# ── Category weights ─────────────────────────────────────────────────────
# Weighted pool: repeat a category name to increase its probability.
WELLNESS_CATEGORY_POOL="${WELLNESS_CATEGORY_POOL:-breathing breathing breathing stretch-home stretch-home stretch-office presence presence eyes}"

# ── Windows Task Scheduler ───────────────────────────────────────────────
WELLNESS_TASK_NAME="${WELLNESS_TASK_NAME:-WellnessCoach}"

# ── Fallback focus video ─────────────────────────────────────────────────
WELLNESS_FALLBACK_VIDEO="${WELLNESS_FALLBACK_VIDEO:-https://www.youtube.com/watch?v=bSkzWpcWz-o}"

# ── User overrides (sourced last so they win) ────────────────────────────
_wc_user_config="${WELLNESS_BASE}/wellness-config.sh"
if [[ -f "$_wc_user_config" ]]; then
  # shellcheck source=/dev/null
  source "$_wc_user_config"
fi
unset _wc_user_config
