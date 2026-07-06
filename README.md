# fable-5

Fable 5's working loop for hard, multi-step tasks, packaged as a Claude Code plugin.

Built by [LearNer](https://github.com/Learn57130).

**Core loop:** decompose along verification boundaries → attack the load-bearing unknown first → verify with the smallest check that would fail if you're wrong → pick the next action by what would change the plan.

## Contents

- `skills/fable-5/` — the skill: 8-step loop, verification catalog (smallest failing check per task type), decomposition patterns, `preflight.sh` pre-completion sweep.
- `skills/fable-5/agents/` — `fable-scout` (read-only comprehension pass) and `fable-refuter` (adversarial verifier, defaults to REFUTED when uncertain). Registered automatically on plugin install; also usable as plain prompt templates in other harnesses.

## Install

**Claude Code** (skill + agents auto-registered):
```bash
claude plugin marketplace add https://github.com/Learn57130/fable-5
claude plugin install fable-5@fable-5
```

**Codex / Cursor / Kimi** — the repo ships `.codex-plugin/`, `.cursor-plugin/`, `.kimi-plugin/` manifests pointing at `skills/`; install via each tool's plugin mechanism, or just symlink:
```bash
git clone https://github.com/Learn57130/fable-5
ln -s "$(pwd)/fable-5/skills/fable-5" ~/.codex/skills/fable-5
```

**Gemini CLI** — install as an extension (`gemini extensions install https://github.com/Learn57130/fable-5`); `gemini-extension.json` loads `AGENTS.md` (the compact loop) as always-on context. Or drop `skills/fable-5` into `~/.agents/skills/`, which Gemini auto-scans.

**Antigravity** — no plugin format; clone and symlink the skill:
```bash
ln -s "$(pwd)/fable-5/skills/fable-5" ~/.gemini/antigravity/skills/fable-5
```

Note: if you already expose `skills/fable-5` as a personal skill (e.g. via `~/.claude/skills`), installing the plugin duplicates it in Claude Code — use one or the other per machine.
