# Distribution Plan — Phase 0

## Goal

Get the first 500 active users for wellness-coach by making it discoverable where developers already hang out.

---

## 1. Publish to Claude Code Plugin Registry

**Priority: Highest — this is the native distribution channel.**

The project already has `.claude-plugin/plugin.json` configured. This is the lowest-friction path to users because they never leave Claude Code.

### What the registry gives us

- **One-command install** — users type something like `/install wellness-coach` instead of cloning a repo
- **Browse-and-discover** — anyone exploring the plugin marketplace sees us listed under wellness/productivity tags
- **Trust signal** — being in an official registry implies a baseline of quality
- **Auto-updates** — users get new features without re-cloning

### Steps to publish

1. **Verify `plugin.json` is complete** — current metadata (name, version 1.1.0, description, tags) looks good. Confirm it meets the registry schema when submission docs are published.
2. **Check the official plugin submission process** — Anthropic's plugin/skill marketplace is evolving. Monitor:
   - [Claude Code GitHub](https://github.com/anthropics/claude-code) for announcements
   - Anthropic's developer docs for a "publish your skill" guide
   - Community Discord/forums for early-access submission programs
3. **Be in the first wave of submissions** — early plugins get disproportionate visibility because the catalog is small. First-mover advantage matters here.
4. **Optimize listing metadata** — the plugin description should sell the value in one line. Current: *"Personalized wellness and productivity coaching for developers"* — good, but could add *"privacy-first, zero dependencies"*.
5. **Consider a landing page within the repo** — a `/docs` folder or GitHub Pages site with screenshots, so the registry listing can link somewhere polished.

### Fallback if registry is delayed

If the official registry isn't open for submissions yet:
- Publish the repo link in Anthropic community channels as a "manual install" skill
- Write a Claude Code CLAUDE.md snippet that auto-suggests the skill to new users
- List it in community-maintained skill directories if any emerge

---

## 2. Launch Posts

Post a short, authentic launch announcement on these platforms (same week). The goal is not to go viral — it's to reach 50-100 people who actually try it.

### Platform-by-platform playbook

**Reddit r/ClaudeAI** (Post first — this is the warmest audience)
- Format: Show-and-tell with embedded GIF
- Title: *"I built a wellness coach skill for Claude Code — it knows your back pain and your deadlines"*
- Body structure: problem (3 sentences) -> demo GIF -> one-liner install command -> link to repo
- Engage in comments for the first 2 hours — this is what drives Reddit visibility
- Timing: Tuesday or Wednesday morning (US time), when the sub is most active

**Reddit r/programming** (Post 2-3 days after r/ClaudeAI)
- Title: *"I built a CLI wellness coach that fires stretch/breathing tips based on your profile — no cloud, no accounts"*
- Angle: emphasize the technical design (bash-only, cross-platform, privacy-first) — this audience cares about *how* it's built, not just what it does
- Avoid sounding like marketing — be honest about scope ("it's a simple skill, not an app")
- Expect skeptics — have clear answers for "why not just set a timer?" (answer: personalization + habit tracking + weighted tips)

**Hacker News — Show HN** (Post the following week)
- Title: *"Show HN: Wellness Coach — a privacy-first CLI skill that gives developers personalized break tips"*
- HN body: 3-4 sentences max. Lead with what makes it different (privacy, zero deps, profile-based). Link to GitHub.
- HN rewards simplicity and novel angles. The "runs inside Claude Code" hook is novel enough.
- Best time to post: 8-9 AM ET on a weekday
- If it doesn't gain traction in 2 hours, it won't — don't repost, move on

**X/Twitter** (Same day as the first Reddit post)
- Format: 4-tweet thread
  1. The hook: *"Developers sit 10+ hours a day and ignore their bodies. I built something about that."*
  2. What it does: one command, personalized tips, habit tracking, cross-platform notifications
  3. The demo GIF (this tweet gets the most engagement)
  4. The install command + GitHub link
- Tag relevant accounts: @AnthropicAI, @claudecode (if they exist), developer wellness advocates
- Use hashtags sparingly: #ClaudeCode #DevTools (max 2)

**Dev.to / Hashnode** (Publish as a blog post, same week as HN)
- Title: *"How I stopped ignoring my body while shipping code"*
- Format: personal story (2 min read) + technical overview + install instructions
- Structure:
  1. The problem (personal anecdote — back pain, skipped meals, eye strain)
  2. Why timers don't work (generic, easy to ignore, no personalization)
  3. What I built (screenshots, code snippets showing the SKILL.md approach)
  4. How the weighted tip system works (brief technical dive)
  5. Install + try it (one-liner)
- Add canonical URL to your own blog if you have one (SEO benefit)
- Cross-post to both Dev.to AND Hashnode — different audiences, same content is fine

### Key message across all posts

> "One command. No accounts. No cloud. Your wellness data stays on your machine."

### What makes a post succeed or fail

- **Succeed:** authentic tone, working demo GIF, one-command install, responds to every comment in first 3 hours
- **Fail:** sounds like an ad, no visual demo, broken install link, ghost the comments

### Post templates

Keep drafts of each post in a `plans/launch-posts/` folder so co-maintainers can review before publishing.

---

## 3. Demo Content

Create before any launch post:

- **30-second GIF** showing: install -> first `/wellness` run -> personalized tip appearing
- **2-minute YouTube walkthrough** covering: install, onboarding, habit tracking, notifications
- **Screenshot** of a macOS toast notification with a wellness tip

These assets get reused across every platform.

---

## 4. GitHub Discoverability

- Add relevant **topics** to the repo: `claude-code`, `wellness`, `developer-tools`, `productivity`, `cli`, `health`, `breaks`, `habit-tracker`
- Add a **social preview image** (1280x640) to the repo settings
- Make sure the README one-liner install works flawlessly — first impression matters
- Add **badges** to README: license, platform support, version

---

## 5. Community Seeding

- Share in **Claude Code Discord** (if one exists) or Anthropic community channels
- Post in **developer wellness** communities (e.g., DevHealthy, Healthy Hacker groups)
- Share in **remote work** communities (remote devs sit more, care more about this)
- Mention in relevant GitHub Discussions on claude-code or anthropic repos

---

## 6. Leverage the Plugin Ecosystem

- Write a short guide: "How to build a Claude Code skill" using wellness-coach as the example
- This positions the project as both a useful tool AND a reference implementation
- Developers who find the guide will install the skill to try it

---

## 7. Organic Growth Hooks (built into the product)

These are already partially in place — double down on them:

- **`/loop 1h wellness`** — once set up, users interact with it daily without thinking
- **Monday weekly reviews** — creates a habit loop that keeps users coming back
- **Habit streaks** — people don't want to break streaks (future feature: streak counter in the tip)
- **Word of mouth prompt** — after 7 days of use, the coach could say: "You've been consistent for a week. Know a dev who sits too much? Share: github.com/MastafaF/wellness-coach"

---

## 8. Timing

| Week | Action |
|------|--------|
| 1 | Record demo GIF + video, polish README, add GitHub topics + social preview |
| 2 | Post on Reddit (r/ClaudeAI first, then r/programming), X/Twitter thread |
| 3 | Submit Show HN, publish Dev.to blog post |
| 4 | Share in Discord/community channels, post the "how to build a skill" guide |
| Ongoing | Respond to issues, ship user-requested features, post updates |

---

## Success Metrics

- **GitHub stars** — vanity but signals traction (target: 100 in first month)
- **Clones/installs** — track via GitHub traffic insights
- **Issues & PRs from external contributors** — real engagement signal
- **Repeat usage** — users who set up `/loop` or cron notifications are retained

---

## What NOT to Do

- Don't pay for ads — this is a free dev tool, organic is the right channel
- Don't spam — one post per platform, then engage in comments
- Don't over-promise — "simple wellness tips" not "AI life coach"
- Don't gate anything behind accounts or signups — frictionless install is the moat
