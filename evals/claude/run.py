#!/usr/bin/env python3
"""Run Claude Code config evals headlessly and append one JSON line per run.

usage: run.py --label NAME [--case GLOB] [--runs N] [--out FILE] [-- extra claude args]

Each run scaffolds a fresh fixture repo, runs `claude -p` with stream-json,
and records which skills/agents were invoked, token totals and the case check.
"""

import argparse
import fnmatch
import glob
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time

HERE = os.path.dirname(os.path.abspath(__file__))
CLAUDE = os.environ.get("CLAUDE_BIN", os.path.expanduser("~/.local/bin/claude"))
# words that mark a review sentence as reporting a defect; "{DEFECT}" in expect_all expands to this.
# A following negation in the same clause (許されない, 問題ありません...) cancels it; negated defects stay defects.
DEFECT = r"(?:数えられない|数えない|カウントされない|反映されない|(?:バグ|不正|誤り|問題があ|問題あり|許さ|許して|許可|allow|できてしまう|できる|可能に|通って|受理|受け付け|上書き|欠落|壊|must|bug|wrong)(?![^\n。、.,]{0,8}(?:なし|無し|ない|無い|ません)))"


def expand(pattern):
    return pattern.replace("{DEFECT}", DEFECT)


# read-only git is allowed so a commit/rebase request can be looked at before the skill fires
READONLY = [
    "--allowedTools",
    "Skill Read Glob Grep Bash(git status:*) Bash(git diff:*) Bash(git log:*) Bash(git branch:*)",
    "--disallowedTools",
    "Edit Write NotebookEdit Agent WebFetch WebSearch",
]


def run_case(case, extra, timeout, keep=None):
    work = tempfile.mkdtemp(prefix=f"ev-{case['id']}-")
    repo = os.path.join(work, "shop")
    subprocess.run(["bash", os.path.join(HERE, "scaffold.sh"), repo, case.get("variant", "base")], check=True)
    cmd = [CLAUDE, "-p", case["prompt"], "--output-format", "stream-json", "--verbose", "--no-session-persistence", "--max-turns", str(case.get("max_turns", 4))]
    cmd += ["--dangerously-skip-permissions"] if case.get("mode") == "bypass" else READONLY
    cmd += extra
    t0 = time.time()
    timed_out = False
    try:
        proc = subprocess.run(cmd, cwd=repo, capture_output=True, text=True, timeout=timeout)
        out = proc.stdout
    except subprocess.TimeoutExpired as e:
        timed_out = True
        out = e.stdout.decode() if isinstance(e.stdout, bytes) else (e.stdout or "")
    skills, agents, tools, result, init = [], [], [], {}, {}
    for line in out.splitlines():
        try:
            ev = json.loads(line)
        except ValueError:
            continue
        if ev.get("type") == "system" and ev.get("subtype") == "init":
            init = ev
        if ev.get("type") == "assistant":
            for c in ev.get("message", {}).get("content", []):
                if c.get("type") != "tool_use":
                    continue
                tools.append(c["name"])
                if c["name"] == "Skill":
                    skills.append(c["input"].get("skill") or c["input"].get("command"))
                if c["name"] in ("Agent", "Task"):
                    agents.append(c["input"].get("subagent_type", "general-purpose"))
        if ev.get("type") == "result":
            result = ev
    mu = result.get("modelUsage", {})
    tokens = sum(m.get(k, 0) for m in mu.values() for k in ("inputTokens", "outputTokens", "cacheReadInputTokens", "cacheCreationInputTokens"))
    rec = {
        "case": case["id"],
        "skills": skills,
        "agents": agents,
        "tool_calls": len(tools),
        "ctx_calls": sum(t.startswith("mcp__plugin_context-mode") for t in tools),
        "turns": result.get("num_turns"),
        "tokens": tokens,
        "output_tokens": sum(m.get("outputTokens", 0) for m in mu.values()),
        "cost_usd": round(result.get("total_cost_usd") or 0, 4),
        "secs": round(time.time() - t0),
        "subtype": result.get("subtype"),
        "timed_out": timed_out,
        "init_skills": len(init.get("skills", []) or []),
        "init_agents": len(init.get("agents", []) or []),
    }
    rec.update(grade(case, repo, skills, result.get("result") or ""))
    if "expect_all" in case:
        rec["result_text"] = (result.get("result") or "")[:6000]  # keep review text so partial scores can be checked
    if keep:
        dst = os.path.join(keep, f"{case['id']}-{os.path.basename(work)}")
        shutil.move(repo, dst)
        rec["repo"] = dst
    shutil.rmtree(work, ignore_errors=True)
    return rec


def grade(case, repo, skills, text):
    g = {}
    norm = [s.split(":")[-1] for s in skills if s]
    if "expect_skills" in case:
        g["routed"] = any(e.split(":")[-1] in norm for e in case["expect_skills"])
    if "forbid_skills" in case:
        g["overtriggered"] = any(f.split(":")[-1] in norm for f in case["forbid_skills"])
    if "expect_all" in case:
        g["text_score"] = round(sum(re.search(expand(x), text) is not None for x in case["expect_all"]) / len(case["expect_all"]), 3)
    if "expect_text" in case:
        g["text_ok"] = re.search(case["expect_text"], text) is not None
    if "base_commits" in case:
        # look at the agent's own state before grading adds files (and __pycache__)
        base = int(subprocess.run(["git", "rev-list", "--count", "HEAD"], cwd=repo, capture_output=True, text=True).stdout.strip() or 0)
        g["commits"] = base - case["base_commits"]
        g["dirty"] = bool(subprocess.run(["git", "status", "--porcelain"], cwd=repo, capture_output=True, text=True).stdout.strip())
    if "expect_files" in case:
        g["files_score"] = round(sum(file_matches(repo, f) for f in case["expect_files"]) / len(case["expect_files"]), 3)
    if "expect_git" in case:
        out = subprocess.run(["bash", "-c", case["expect_git"]["cmd"]], cwd=repo, capture_output=True, text=True).stdout
        g["git_ok"] = re.search(case["expect_git"]["regex"], out, re.M) is not None
    if case.get("hidden"):
        env = dict(os.environ, PYTHONDONTWRITEBYTECODE="1")
        g["suite_green"] = unittest_rc(["discover", "-s", "tests", "-t", "."], repo, env) == 0
        dst = os.path.join(repo, "tests", os.path.basename(case["hidden"]))
        shutil.copy(os.path.join(HERE, "hidden", case["hidden"]), dst)
        try:
            p = subprocess.run([sys.executable, "-m", "unittest", "-v", f"tests.{os.path.basename(dst)[:-3]}"], cwd=repo, env=env, capture_output=True, text=True, timeout=120)
            ok = len(re.findall(r" \.\.\. ok$", p.stderr, re.M))
            total = len(re.findall(r" \.\.\. (ok|FAIL|ERROR)$", p.stderr, re.M)) or 1
            g["hidden_pass"] = round(ok / total, 3)
        except subprocess.TimeoutExpired:
            g["hidden_pass"] = 0.0
    return g


def file_matches(repo, spec):
    """spec = {"glob": "tasks/**/*.md", "regex": "..."}: some file matching glob contains regex (or just exists)."""
    for path in glob.glob(os.path.join(repo, spec["glob"]), recursive=True):
        if not os.path.isfile(path):
            continue
        if "regex" not in spec or re.search(spec["regex"], open(path, errors="ignore").read(), re.M):
            return True
    return False


def unittest_rc(args, repo, env):
    try:
        return subprocess.run([sys.executable, "-m", "unittest", *args], cwd=repo, env=env, capture_output=True, text=True, timeout=120).returncode
    except subprocess.TimeoutExpired:
        return -1


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--label", required=True)
    ap.add_argument("--case", default="*")
    ap.add_argument("--runs", type=int, default=1)
    ap.add_argument("--out", default=os.path.join(HERE, "results.jsonl"))
    ap.add_argument("--timeout", type=int, default=1800)
    ap.add_argument("--keep", help="move each e2e fixture repo here after grading")
    args, extra = ap.parse_known_args()
    extra = [a for a in extra if a != "--"]
    # the agent runs inside a temp fixture, so path arguments must not stay relative to this directory
    for i, a in enumerate(extra[:-1]):
        if a in ("--plugin-dir", "--mcp-config", "--settings") and os.path.exists(extra[i + 1]):
            extra[i + 1] = os.path.abspath(extra[i + 1])
    cases = json.load(open(os.path.join(HERE, "cases.json")))
    for case in cases:
        if not fnmatch.fnmatch(case["id"], args.case):
            continue
        for i in range(args.runs):
            rec = run_case(case, extra, args.timeout, args.keep if case.get("hidden") else None)
            rec.update(label=args.label, run=i, ts=time.strftime("%Y-%m-%dT%H:%M:%S"))
            with open(args.out, "a") as f:
                f.write(json.dumps(rec, ensure_ascii=False) + "\n")
            print(json.dumps(rec, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    main()
