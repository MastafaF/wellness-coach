# wellness-coach

> Stop ignoring your body while you ship. A Claude Code skill that knows your back pain, your deadlines, and your equipment — and gives you the *right* break at the right moment.

---

## Install

**One command — works on Windows, macOS, and Linux:**

```bash
git clone https://github.com/MastafaF/wellness-coach.git ~/.claude/wellness-coach-src && bash ~/.claude/wellness-coach-src/install.sh
```

That's it. The installer will:
- Copy the skill into Claude Code
- Optionally add a terminal-startup tip to your shell
- Optionally set up background notifications (even when Claude Code is closed)

After install, open Claude Code and run:

```
/wellness
```

You'll answer 4 quick questions and get your first personalized tip in under a minute.

---

## Commands

| Command | What it does |
|---|---|
| `/wellness` | First run: onboards you (4 questions). Subsequent runs: personalized coaching session. |
| `/wellness update` | Update your profile when your situation changes. |
| `/wellness focus` | Opens a random focus video from any category. |
| `/wellness focus breathing` | Opens a video from the `breathing` category (e.g. Wim Hof). |
| `/wellness focus focus` | Opens a video from the `focus` category (deep-work music). |
| `/wellness log` | Show today's habit checklist and mark habits complete. |
| `/wellness log workout` | Quick-mark a single habit done for today. |
| `/wellness notifications` | Manage background notifications (Windows toast / macOS / Linux). |
| `/loop 1h wellness` | Auto check-ins every hour — set it and forget it. |

---

## How it works

1. **First run** — you answer 4 questions about your wellness goals, work context, stress level, and available equipment.
2. **Profile saved** — your answers are written to `~/.claude/wellness-profile.md` on your machine. Nothing leaves your device.
3. **Every `/wellness` call after that** — Claude reads your profile and prescribes one specific, actionable break tailored to you.

### Weekly habit review (Mondays)

On Monday check-ins, the coach automatically prepends a weekly summary before your coaching tip:

```
Weekly Habit Review — Week of 2026-03-16

| Habit    | Days completed |
|----------|---------------|
| workout  | 5/7           |
| vitamins | 3/7           |

Most consistent: workout — great streak, keep it going.
One to improve: vitamins — aim for 5+ days this week.
```

The summary is shown once per week and skipped on subsequent Monday check-ins.

### Habit tracking

Track daily habits with `/wellness log`:

```bash
/wellness log              # show today's checklist, mark habits complete
/wellness log workout      # quick-mark workout done for today
/wellness update           # mention "add habit: meditation" to add new tracked habits
```

Habit data is stored locally at `~/.claude/wellness-habits.md` — never in the repo.

### Auto focus videos on slow builds

> **Not installed by default.** This hook opens a focus video automatically during slow commands — which may be intrusive. Use `/wellness focus` instead for on-demand video opening.

If you still want it, add the hook from `settings.json.example` to your `~/.claude/settings.json` manually. It triggers on commands like `npm install` or `cargo build` and opens a random focus video in your browser.

---

## Privacy

Your wellness data is stored **only** on your local machine:

| File | Contents |
|------|----------|
| `~/.claude/wellness-profile.md` | Wellness profile (goals, equipment, stress level) |
| `~/.claude/wellness-habits.md` | Habit registry + daily log |
| `~/.claude/wellness-weekly.md` | Tracks which week's summary was last shown |

None of these files are tracked in the repo. Delete them anytime:

```bash
rm ~/.claude/wellness-profile.md ~/.claude/wellness-habits.md ~/.claude/wellness-weekly.md
```

---

## Cross-session notifications

Wellness tips can fire **even when Claude Code is closed** — while you're coding in VS Code, a browser, or any other app.

There are two layers, both using a shared interval guard (default: 60 minutes, configurable) so you're never double-notified:

### Layer 1 — Terminal startup tip (all platforms, zero config)

Every new terminal prints a tip if the configured interval has passed since the last one. The installer adds this automatically, or you can add it manually:

```bash
# Add to ~/.bashrc (or ~/.zshrc on macOS):
bash "$HOME/.claude/skills/wellness-coach/scripts/notify.sh" 2>/dev/null
```

### Layer 2 — Background OS notification (truly background)

Fires even when no terminal is open. Run once to register:

```bash
bash ~/.claude/skills/wellness-coach/scripts/setup-scheduler.sh enable
```

Platform support:

| Platform | Mechanism | Requirement |
|---|---|---|
| **Windows** | Windows toast via Task Scheduler | Git Bash (already installed if you're here) |
| **macOS** | System notification via `osascript` | Built-in, nothing to install |
| **Linux** | Desktop notification via `notify-send` | `libnotify-bin` (`sudo apt install libnotify-bin`) |

The notification includes an **"Open focus video"** button that opens a random video from your curated playlist.

To check status or remove:

```bash
bash ~/.claude/skills/wellness-coach/scripts/setup-scheduler.sh status
bash ~/.claude/skills/wellness-coach/scripts/setup-scheduler.sh disable   # pause
bash ~/.claude/skills/wellness-coach/scripts/setup-scheduler.sh delete    # remove entirely
```

### Configuration

All settings can be customized in `~/.claude/wellness-config.sh` (created by the installer):

```bash
# ~/.claude/wellness-config.sh — uncomment any line to override
WELLNESS_INTERVAL=45                    # minutes between notifications (default: 60)
WELLNESS_CATEGORY_POOL="breathing breathing stretch-home presence eyes"  # weighted tip categories
WELLNESS_FALLBACK_VIDEO="https://..."   # fallback video URL
WELLNESS_TASK_NAME="WellnessCoach"      # Windows Task Scheduler name
```

Changes take effect immediately — no reinstall needed (except for cron interval, which requires re-running the installer or manually updating your crontab).

You can also set `WELLNESS_INTERVAL` as an environment variable:

```bash
export WELLNESS_INTERVAL=45  # tips every 45 minutes
```

### Tips library

Tips live in `scripts/tips.md` — 19 curated tips across 5 categories matched to your profile:
- **breathing** (4 tips) — highest priority
- **stretch-home** (4 tips) — yoga mat exercises
- **stretch-office** (4 tips) — chair-only stretches
- **presence** (4 tips) — mindfulness/focus resets
- **eyes** (3 tips) — screen fatigue relief

The script reads your `~/.claude/wellness-profile.md` to bias category selection toward your goals.

---

## Adding focus videos

Edit `~/.claude/skills/wellness-coach/focus-videos.md`. Bare URLs go in the uncategorized pool; use `[category]` headers to organize by type:

```
# Uncategorized — included in all random picks
https://www.youtube.com/watch?v=bSkzWpcWz-o

[breathing]
https://www.youtube.com/watch?v=tybOi4hjZFQ

[focus]
https://www.youtube.com/watch?v=YOUR_DEEP_WORK_MUSIC
```

Then use `/wellness focus breathing` or `/wellness focus focus` to open a video from a specific category, or `/wellness focus` to pick from everything.

---

## Uninstall

```bash
# Remove skill files
rm -rf ~/.claude/skills/wellness-coach ~/.claude/skills/wellness

# Remove wellness data (optional)
rm -f ~/.claude/wellness-profile.md ~/.claude/wellness-habits.md ~/.claude/wellness-weekly.md

# Remove background notifications
bash ~/.claude/skills/wellness-coach/scripts/setup-scheduler.sh delete  # Windows / scheduled
# Then remove the notify.sh line from ~/.bashrc or ~/.zshrc

# Remove source clone
rm -rf ~/.claude/wellness-coach-src
```

---

## Value props

- **Personalized, not generic** — knows your back pain, equipment, and stress level
- **Habit tracking built in** — daily log + weekly review, all local
- **Privacy-first** — all data at `~/.claude/`, nothing sent anywhere
- **Cross-platform** — Windows, macOS, Linux
- **One-command automation** — `/loop 1h wellness` is a complete workflow in one line

---

## License

MIT © [MastafaF](https://github.com/MastafaF)
