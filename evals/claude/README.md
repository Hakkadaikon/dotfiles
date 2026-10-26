# Claude Code config evals

Headless evals for the Claude Code setup in `home/.claude` and the hymme / superpowers plugins. They measure two things per run: quality (right skill, correct answer, hidden tests) and productivity (total tokens).

```sh
# all cases, 2 runs each, against the installed config
python3 run.py --label baseline --runs 2
# a hymme working tree instead of the installed plugin
python3 run.py --label try --case 'r-*' --runs 2 -- --settings '{"enabledPlugins":{"hymme@hymme":false}}' --plugin-dir ../../../hymme
# always-on context only, without MCP servers (their connect timing makes the number jump by ~1k)
python3 run.py --label probe --case probe -- --strict-mcp-config
python3 summary.py results.jsonl
```

- `scaffold.sh` builds a fresh fixture repo per run (`base`, `dirty`, `bug`, `logs`, `plan`, `plansdd`).
- `cases.json`: `probe` (always-on context), `r-*` (routing: read-only tools, a few turns, did the expected skill fire), `e-*` (end to end with permissions bypassed, graded by `hidden/` tests or by the planted bugs a review must find). `e-plan*` compare plan execution modes, `e-logs` traces a bug through a 4.7MB log.
- Extra arguments after `--` go to `claude`. Each run costs real tokens; a full pass with 2 runs is roughly 3–4M tokens.
- Compare one change at a time against the previous label, and keep a change only when quality holds and tokens drop.
