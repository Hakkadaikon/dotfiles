#!/usr/bin/env python3
"""Summarize results.jsonl per label and case: summary.py [FILE] [LABEL...]"""

import json
import os
import statistics
import sys
from collections import defaultdict

path = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1].endswith(".jsonl") else os.path.join(os.path.dirname(os.path.abspath(__file__)), "results.jsonl")
labels = [a for a in sys.argv[1:] if not a.endswith(".jsonl")]
rows = [json.loads(l) for l in open(path) if l.strip()]
if labels:
    rows = [r for r in rows if r["label"] in labels]
by = defaultdict(list)
for r in rows:
    by[(r["label"], r["case"])].append(r)


def quality(r):
    if "hidden_pass" in r:
        return r["hidden_pass"] * (1 if r.get("commits", 0) > 0 else 0.5)
    if "text_score" in r:
        return r["text_score"]
    q = [r.get("routed", True), r.get("text_ok", True), not r.get("overtriggered", False)]
    return sum(q) / len(q)


tot = defaultdict(lambda: [0, 0, 0])
print(f"{'label':10} {'case':14} {'n':>2} {'quality':>7} {'tokens':>10} {'out':>7} {'secs':>5}  skills/agents")
for (label, case), rs in sorted(by.items(), key=lambda kv: (kv[0][1], kv[0][0])):
    q = statistics.mean(quality(r) for r in rs)
    t = statistics.mean(r["tokens"] for r in rs)
    o = statistics.mean(r["output_tokens"] for r in rs)
    s = statistics.mean(r["secs"] for r in rs)
    sk = sorted({x for r in rs for x in r["skills"] + ["@" + a for a in r["agents"]]})
    print(f"{label:10} {case:14} {len(rs):2} {q:7.2f} {t:10.0f} {o:7.0f} {s:5.0f}  {' '.join(sk)[:90]}")
    tot[label][0] += q
    tot[label][1] += t
    tot[label][2] += 1
print()
for label, (q, t, n) in tot.items():
    print(f"{label:10} cases={n} mean_quality={q / n:.3f} sum_tokens={t:.0f}")
