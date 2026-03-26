# wellness-coach

> Stop ignoring your body while you ship. A Claude Code plugin that knows your back pain, your deadlines, and your equipment — and gives you the *right* break at the right moment.

---

## Why this exists

Generic wellness apps tell everyone the same thing. This one asks you four questions, builds a private profile, and prescribes breaks tailored to *your* goals, stress level, and physical limits. It lives inside Claude Code — where you already are.

---

## Install

```bash
/plugin install https://github.com/MastafaF/wellness-coach.git
```

Once on the official marketplace:
```bash
/plugin install wellness-coach
```

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
| `/wellness notifications` | Manage background Windows toast notifications. |
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

Install the optional hook (included in `settings.json.example`) and whenever you run a slow command like `npm install` or `cargo build`, a focus video automatically opens in your browser so you don't just stare at the terminal.

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

## Cross-session notifications (Windows)

Wellness tips can fire **even when Claude Code is closed** — while you're coding in VS Code, a browser, or any other app.

There are two layers, both using a shared 60-minute interval guard so you're never double-notified:

### Layer 1 — Terminal startup tip (zero config)
Every new Git Bash / PowerShell terminal prints a tip if 60 minutes have passed since the last one. Set up in one step:

```bash
# Appended to ~/.bashrc automatically on install, or add manually:
bash ~/.claude/skills/wellness-coach/scripts/notify.sh 2>/dev/null
```

### Layer 2 — Windows toast notification (truly background)
A Windows Task Scheduler task fires every 60 minutes. Run once to register it:

```bash
bash ~/.claude/skills/wellness-coach/scripts/setup-scheduler.sh
```

The toast includes a **"Open focus video"** button that opens your curated playlist. To remove the scheduled task:

```bash
schtasks /Delete /TN WellnessCoach /F
```

### Configuring the interval
Both layers respect the `WELLNESS_INTERVAL` env var (minutes, default `60`):
```bash
export WELLNESS_INTERVAL=45  # tips every 45 minutes
```

### Tips file
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

## Value props

- **Personalized, not generic** — knows your back pain, equipment, and stress level
- **Habit tracking built in** — daily log + weekly review, all local
- **Privacy-first** — all data at `~/.claude/`, nothing sent anywhere
- **One-command automation** — `/loop 1h wellness` is a complete workflow in one line

---

## License

MIT © [MastafaF](https://github.com/MastafaF)
