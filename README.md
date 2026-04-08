# learning-coach

> Stop wasting idle moments. A Claude Code skill that knows your interests — Deen, History, Space, and Tech — and drops a useful knowledge nugget at the right moment, delivered straight to your OS notifications.

---

## Install

**One command — works on Windows, macOS, and Linux:**

```bash
git clone https://github.com/MastafaF/wellness-coach.git ~/.claude/learning-coach-src && bash ~/.claude/learning-coach-src/install.sh
```

That's it. The installer will:
- Copy the skill into Claude Code
- Optionally add a terminal-startup tip to your shell
- Optionally set up background notifications (even when Claude Code is closed)

After install, open Claude Code and run:

```
/learn
```

You'll answer 4 quick questions and get your first learning nugget in under a minute.

---

## Commands

| Command | What it does |
|---|---|
| `/learn` | First run: onboards you (4 questions). Subsequent runs: sends a learning tip via OS notification. |
| `/learn update` | Update your profile when your interests change. |
| `/learn focus` | Opens a random learning video from any category. |
| `/learn focus deen` | Opens a video from the `deen` category. |
| `/learn focus space` | Opens a video from the `space` category. |
| `/learn log` | Show today's habit checklist and mark habits complete. |
| `/learn log quran-reading` | Quick-mark a single habit done for today. |
| `/learn notifications` | Manage background notifications (Windows toast / macOS / Linux). |
| `/loop 1h learn` | Auto tips every hour — set it and forget it. |

---

## How it works

1. **First run** — you answer 4 questions about your learning topics, depth preference, knowledge level, and goals.
2. **Profile saved** — your answers are written to `~/.claude/learning-profile.md` on your machine. Nothing leaves your device.
3. **Every `/learn` call after that** — a tip is selected based on your profile and delivered via OS notification. Claude Code output stays minimal (one line) so there's nothing to expand.

### The 4 topics

| Topic | Categories | What you'll learn |
|---|---|---|
| **Deen (Islam)** | Quran, Hadith, Dua, Seerah | Ayah insights, hadith wisdom, daily duas, Prophet's life |
| **History** | Ancient, Modern, Civilizations | Key events, turning points, remarkable civilizations |
| **Space** | Solar system, Cosmos, Exploration | Planet facts, cosmic wonders, space missions |
| **Tech** | JavaScript, Python, Git, Linux | Practical tips, hidden features, CLI tricks |

### Weekly habit review (Mondays)

On Monday check-ins, the coach automatically shows a weekly summary:

```
Weekly Learning Review — Week of 2026-03-30

| Habit            | Days completed |
|------------------|---------------|
| quran-reading    | 5/7           |
| learning-session | 3/7           |

Most consistent: quran-reading — great streak, keep it going.
One to improve: learning-session — aim for 5+ days this week.
```

### Habit tracking

Track daily habits with `/learn log`:

```bash
/learn log                  # show today's checklist, mark habits complete
/learn log quran-reading    # quick-mark quran-reading done for today
/learn update               # mention "add habit: meditation" to add new tracked habits
```

Habit data is stored locally at `~/.claude/learning-habits.md` — never in the repo.

---

## Privacy

Your learning data is stored **only** on your local machine:

| File | Contents |
|------|----------|
| `~/.claude/learning-profile.md` | Learning profile (topics, depth, goals) |
| `~/.claude/learning-habits.md` | Habit registry + daily log |
| `~/.claude/learning-weekly.md` | Tracks which week's summary was last shown |

None of these files are tracked in the repo. Delete them anytime:

```bash
rm ~/.claude/learning-profile.md ~/.claude/learning-habits.md ~/.claude/learning-weekly.md
```

---

## Cross-session notifications

Learning tips can fire **even when Claude Code is closed** — while you're coding in VS Code, a browser, or any other app.

There are two layers, both using a shared interval guard (default: 60 minutes, configurable) so you're never double-notified:

### Layer 1 — Terminal startup tip (all platforms, zero config)

Every new terminal prints a tip if the configured interval has passed since the last one. The installer adds this automatically, or you can add it manually:

```bash
# Add to ~/.bashrc (or ~/.zshrc on macOS):
bash "$HOME/.claude/skills/learning-coach/scripts/notify.sh" 2>/dev/null
```

### Layer 2 — Background OS notification (truly background)

Fires even when no terminal is open. Run once to register:

```bash
bash ~/.claude/skills/learning-coach/scripts/setup-scheduler.sh enable
```

Platform support:

| Platform | Mechanism | Requirement |
|---|---|---|
| **Windows** | Windows toast via Task Scheduler | Git Bash (already installed if you're here) |
| **macOS** | System notification via `osascript` | Built-in, nothing to install |
| **Linux** | Desktop notification via `notify-send` | `libnotify-bin` (`sudo apt install libnotify-bin`) |

The notification includes a **"Watch & learn"** button that opens a random video from your curated playlist.

To check status or remove:

```bash
bash ~/.claude/skills/learning-coach/scripts/setup-scheduler.sh status
bash ~/.claude/skills/learning-coach/scripts/setup-scheduler.sh disable   # pause
bash ~/.claude/skills/learning-coach/scripts/setup-scheduler.sh delete    # remove entirely
```

### Configuration

All settings can be customized in `~/.claude/learning-config.sh` (created by the installer):

```bash
# ~/.claude/learning-config.sh — uncomment any line to override
LEARNING_INTERVAL=45                    # minutes between notifications (default: 60)
LEARNING_CATEGORY_POOL="quran hadith dua seerah ancient modern civilizations solar-system cosmos exploration javascript python git linux"
LEARNING_FALLBACK_VIDEO="https://..."   # fallback video URL
LEARNING_TASK_NAME="LearningCoach"      # Windows Task Scheduler name
```

Changes take effect immediately — no reinstall needed (except for cron interval, which requires re-running the installer or manually updating your crontab).

### Tips library

Tips live in `scripts/tips.md` — curated tips across 14 categories matched to your profile:

**Deen (Islam)**
- **quran** (3 tips), **hadith** (3 tips), **dua** (2 tips), **seerah** (2 tips)

**History**
- **ancient** (2 tips), **modern** (2 tips), **civilizations** (2 tips)

**Space**
- **solar-system** (2 tips), **cosmos** (2 tips), **exploration** (2 tips)

**Tech**
- **javascript** (2 tips), **python** (2 tips), **git** (2 tips), **linux** (2 tips)

The script reads your `~/.claude/learning-profile.md` to bias category selection toward your interests.

---

## Adding learning videos

Edit `~/.claude/skills/learning-coach/focus-videos.md`. Bare URLs go in the uncategorized pool; use `[category]` headers to organize by topic:

```
[deen]
https://www.youtube.com/watch?v=YOUR_DEEN_VIDEO

[history]
https://www.youtube.com/watch?v=YOUR_HISTORY_VIDEO

[space]
https://www.youtube.com/watch?v=YOUR_SPACE_VIDEO

[tech]
https://www.youtube.com/watch?v=YOUR_TECH_VIDEO
```

Then use `/learn focus deen` or `/learn focus tech` to open a video from a specific category, or `/learn focus` to pick from everything.

---

## Uninstall

```bash
# Remove skill files
rm -rf ~/.claude/skills/learning-coach ~/.claude/skills/learn

# Remove learning data (optional)
rm -f ~/.claude/learning-profile.md ~/.claude/learning-habits.md ~/.claude/learning-weekly.md

# Remove background notifications
bash ~/.claude/skills/learning-coach/scripts/setup-scheduler.sh delete  # Windows / scheduled
# Then remove the notify.sh line from ~/.bashrc or ~/.zshrc

# Remove source clone
rm -rf ~/.claude/learning-coach-src
```

---

## Value props

- **4 knowledge domains** — Deen, History, Space, and Tech in one tool
- **OS notifications** — tips appear as native notifications, no need to expand collapsed views
- **Habit tracking built in** — daily log + weekly review, all local
- **Privacy-first** — all data at `~/.claude/`, nothing sent anywhere
- **Cross-platform** — Windows, macOS, Linux
- **One-command automation** — `/loop 1h learn` is a complete workflow in one line

---

## License

MIT © [MastafaF](https://github.com/MastafaF)
