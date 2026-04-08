#!/usr/bin/env bash
# config.sh — Learning Coach centralized defaults
# All scripts source this file. User overrides go in:
#   ~/.claude/learning-config.sh

# ── Paths ────────────────────────────────────────────────────────────────
LEARNING_BASE="${LEARNING_BASE:-$HOME/.claude}"
LEARNING_INSTALL_DIR="${LEARNING_BASE}/skills/learning-coach"
LEARNING_PROFILE="${LEARNING_PROFILE:-${LEARNING_BASE}/learning-profile.md}"
LEARNING_TIMESTAMP="${LEARNING_TIMESTAMP:-${LEARNING_BASE}/learning-last-check}"
LEARNING_TIPS="${LEARNING_TIPS:-${LEARNING_INSTALL_DIR}/scripts/tips.md}"
LEARNING_FOCUS_VIDEOS="${LEARNING_FOCUS_VIDEOS:-${LEARNING_INSTALL_DIR}/focus-videos.md}"
LEARNING_HABITS="${LEARNING_HABITS:-${LEARNING_BASE}/learning-habits.md}"
LEARNING_WEEKLY="${LEARNING_WEEKLY:-${LEARNING_BASE}/learning-weekly.md}"

# ── Timing ───────────────────────────────────────────────────────────────
LEARNING_INTERVAL="${LEARNING_INTERVAL:-60}"

# ── Category weights ─────────────────────────────────────────────────────
# Weighted pool: repeat a category name to increase its probability.
# Equal weight across all 4 topics (Deen, History, Space, Tech) by default.
LEARNING_CATEGORY_POOL="${LEARNING_CATEGORY_POOL:-quran hadith dua seerah ancient modern civilizations solar-system cosmos exploration javascript python git linux}"

# ── Windows Task Scheduler ───────────────────────────────────────────────
LEARNING_TASK_NAME="${LEARNING_TASK_NAME:-LearningCoach}"

# ── Fallback focus video ─────────────────────────────────────────────────
LEARNING_FALLBACK_VIDEO="${LEARNING_FALLBACK_VIDEO:-https://www.youtube.com/watch?v=bSkzWpcWz-o}"

# ── User overrides (sourced last so they win) ────────────────────────────
_lc_user_config="${LEARNING_BASE}/learning-config.sh"
if [[ -f "$_lc_user_config" ]]; then
  # shellcheck source=/dev/null
  source "$_lc_user_config"
fi
unset _lc_user_config
