#!/usr/bin/env python3
"""Summarize results.jsonl per label and case: summary.py [FILE] [LABEL...]

quality only scores what a case defines (routing, expected text, over-triggering,
planted-bug text, hidden tests + expected commits). Runs that timed out or ended
without a result are left out of the token means and counted separately.
"""

import json
import os
import statistics
import sys
from collections import defaultdict

path = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1].endswith(".jsonl") else os.path.join(os.path.dirname(os.path.abspath(__file__)), "results.jsonl")
labels = [a for a in sys.argv[1:] if not a.endswith(".jsonl")]
rows = [json.loads(line) for line in open(path) if line.strip()]
if labels:
    rows = [r for r in rows if r["label"] in labels]
cases = {c["id"]: c for c in json.load(open(os.path.join(os.path.dirname(os.path.abspath(path)), "cases.json")))}
by = defaultdict(list)
for r in rows:
    by[(r["label"], r["case"])].append(r)


def quality(r):
    case = cases.get(r["case"], {})
    if "hidden_pass" in r:
        want = case.get("expect_commits", 1)
        return r["hidden_pass"] * (1 if r.get("commits", 0) >= want else 0.5)
    checks = []
    if "text_score" in r:
        checks.append(r["text_score"])
    if "files_score" in r:
        checks.append(r["files_score"])
    if "git_ok" in r:
        checks.append(r["git_ok"])
    if "expect_commits" in case and "commits" in r:
        checks.append(r["commits"] >= case["expect_commits"])
    if "routed" in r:
        checks.append(r["routed"])
    if "text_ok" in r:
        checks.append(r["text_ok"])
    if "overtriggered" in r:
        checks.append(not r["overtriggered"])
    return sum(checks) / len(checks) if checks else 1.0


def finished(r):
    return not r.get("timed_out") and r.get("subtype") is not None and r["tokens"] > 0


tot = defaultdict(lambda: [0.0, 0.0, 0])
case_sets = defaultdict(set)
print(f"{'label':10} {'case':14} {'n':>2} {'quality':>7} {'tokens':>10} {'usd':>6} {'secs':>5} {'lost':>4}  skills/agents")
for (label, case), rs in sorted(by.items(), key=lambda kv: (kv[0][1], kv[0][0])):
    done = [r for r in rs if finished(r)] or rs
    q = statistics.mean(quality(r) for r in rs)
    t = statistics.mean(r["tokens"] for r in done)
    usd = statistics.mean(r.get("cost_usd", 0) for r in done)
    s = statistics.mean(r["secs"] for r in done)
    sk = sorted({x for r in rs for x in r["skills"] + ["@" + a for a in r["agents"]]})
    print(f"{label:10} {case:14} {len(rs):2} {q:7.2f} {t:10.0f} {usd:6.2f} {s:5.0f} {len(rs) - len([r for r in rs if finished(r)]):4}  {' '.join(sk)[:80]}")
    tot[label][0] += q
    tot[label][1] += t
    tot[label][2] += 1
    case_sets[label].add(case)
print()
for label, (q, t, n) in tot.items():
    print(f"{label:10} cases={n} mean_quality={q / n:.3f} sum_tokens={t:.0f}")
if len({frozenset(v) for v in case_sets.values()}) > 1:
    print("\nwarning: labels cover different cases; compare mean_quality / sum_tokens only over the cases they share")
