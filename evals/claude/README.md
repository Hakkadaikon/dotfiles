# Claude Code config evals

Headless evals for the Claude Code setup in `home/.claude` and the hymme / superpowers plugins. They measure two things per run: quality (right skill, correct answer, hidden tests) and productivity (total tokens).

Prerequisites: Python 3, git, and the `claude` CLI (`~/.local/bin/claude`, or set `CLAUDE_BIN`). Runs use your installed `~/.claude` config, plugins and hooks as they are. `e-*` cases run with `--dangerously-skip-permissions` inside a throwaway fixture repo.

```sh
# all cases, 2 runs each, against the installed config
python3 run.py --label baseline --runs 2
# a hymme working tree instead of the installed plugin
python3 run.py --label try --case 'r-*' --runs 2 -- --settings '{"enabledPlugins":{"hymme@hymme":false}}' --plugin-dir ~/Desktop/src/repos/hakkadaikon/hymme
# always-on context only, without MCP servers (their connect timing makes the number jump by ~1k)
python3 run.py --label probe --case probe -- --strict-mcp-config
python3 summary.py results.jsonl
```

- `scaffold.sh` builds a fresh fixture repo per run: `base`, `dirty`, `two` (two unrelated changes), `bug` / `swallow` / `mutable` / `evaldur` / `durbug` / `classattr` (planted bugs for reviews), `logs`, `plan` / `plansdd`, `spec`, `ledger`, `branch` (a feature branch behind main).
- `cases.json` (53 core cases): `probe` (always-on context), `r-*` (routing, 22 positive and 5 negative: read-only tools plus read-only git, a few turns, did the expected skill fire and did heavy skills stay quiet), `v-*` (verification routes: did the loop-engineering / test-design / formal-verification / verifiability artifact appear), `g-*` (guardrails: backup before rebase, safety before reset, split commits), `e-*` (end to end with permissions bypassed, graded by `hidden/` tests or by the planted bugs a review must find). `e-plan*` compare plan execution modes, `e-logs` traces a bug through a 4.7MB log.
- Extra arguments after `--` go to `claude`. Each run costs real tokens. Measured per run: routing cases about 0.1M; `e-duration`, `e-logs`, `e-review` 0.2–0.4M; `e-plan`, `e-plansdd` 0.5–0.7M; `e-planflow` 1.4–3.9M (the high end when it picks SDD); `e-plansddforce` 2.2–2.6M. Filter with `--case`. `tokens` counts cache reads at full weight; `summary.py` also prints `usd` for the billed cost.
- `python3 test_criteria.py` checks that the `e-review` criteria accept real findings and reject quoted diff lines and clean reviews; run it after editing them.
- Compare one change at a time against the previous label, and keep a change only when quality holds and tokens drop.
- Rows in `results.jsonl` recorded before the scoring fixes (commit after `cf3433b`) have `dirty` / `suite_green` measured after the hidden tests were added, and `e-review` / `e-logs` rows used the earlier fixture whose second bug could not be triggered; read those fields with that in mind.
