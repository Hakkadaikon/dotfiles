#!/usr/bin/env python3
"""Middle-loop meta-oracle: does the TLA+ spec actually catch bugs?

Mutation testing for design specs. We inject small mutations into a .tla file
(flip a comparison, drop a conjunct, weaken a guard) and run TLC. A spec that is
worth anything must FAIL (find a counterexample / invariant violation) on the
mutant. A mutant that still passes is a "survivor": the spec is too weak to
distinguish correct behaviour from that bug -- the oracle reports it.

Usage:
    tla_mutate_oracle.py <spec.tla> [--cfg spec.cfg] [--workers N]

Env:
    TLA_JAR   path to tla2tools.jar (set by conf.d/loopeng.fish). If unset we
              assume the `tlc` wrapper from the flake is on PATH instead.

ponytail: regex mutations on TLA+ source, not an AST. Good enough to surface a
spec that can't catch an off-by-one; swap in a real parser if the false-positive
rate hurts.
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile

# (name, pattern, replacement) -- each flips one operator to inject a bug.
MUTATIONS = [
    ("lt->le", re.compile(r"(?<![<>=/\\])<(?![<>=])"), "\\\\leq"),
    ("le->lt", re.compile(r"\\leq"), "<"),
    ("gt->ge", re.compile(r"(?<![<>=/\\])>(?![<>=])"), "\\\\geq"),
    ("eq->neq", re.compile(r"(?<![<>=/\\:])=(?![<>=])"), "#"),
    ("and->or", re.compile(r"/\\"), "\\\\/"),
    ("plus->minus", re.compile(r"(?<![+])\+(?![+])"), "-"),
]


def run_tlc(spec_path, cfg, workers):
    """Return (passed, output). passed=True means TLC found no violation."""
    jar = os.environ.get("TLA_JAR")
    if jar:
        cmd = ["java", "-cp", jar, "tlc2.TLC"]
    elif shutil.which("tlc"):
        cmd = ["tlc"]
    else:
        sys.exit("error: neither TLA_JAR nor a `tlc` wrapper is available")
    cmd += ["-workers", str(workers), "-deadlock"]
    if cfg:
        cmd += ["-config", cfg]
    cmd.append(os.path.basename(spec_path))
    proc = subprocess.run(
        cmd, cwd=os.path.dirname(spec_path) or ".",
        capture_output=True, text=True, timeout=600,
    )
    out = proc.stdout + proc.stderr
    # TLC exits non-zero on a violation; "No error" appears on a clean run.
    passed = proc.returncode == 0 and "Error:" not in out
    return passed, out


def apply_one_mutation(src, name, pat, repl):
    """Return list of (label, mutated_src) -- one per matched site."""
    out = []
    for i, m in enumerate(pat.finditer(src)):
        mutated = src[: m.start()] + re.sub(pat, repl, m.group(), count=1) + src[m.end():]
        if mutated != src:
            out.append((f"{name}#{i}@{m.start()}", mutated))
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("spec", help="path to the .tla spec")
    ap.add_argument("--cfg", help="TLC config (defaults to <spec>.cfg if present)")
    ap.add_argument("--workers", default="auto")
    args = ap.parse_args()

    spec = os.path.abspath(args.spec)
    if not os.path.isfile(spec):
        sys.exit(f"error: no such spec: {spec}")
    cfg = args.cfg or (spec[:-4] + ".cfg" if spec.endswith(".tla") else None)
    if cfg and not os.path.isfile(cfg):
        cfg = None

    src = open(spec).read()

    # Sanity: the unmutated spec must pass, else mutation results are meaningless.
    base_pass, base_out = run_tlc(spec, cfg, args.workers)
    if not base_pass:
        print("BASELINE FAILS -- fix the spec before mutation testing:\n")
        print(base_out[-2000:])
        return 2

    survivors, killed, total = [], 0, 0
    base_dir = os.path.dirname(spec)
    for name, pat, repl in MUTATIONS:
        for label, mutated in apply_one_mutation(src, name, pat, repl):
            total += 1
            with tempfile.NamedTemporaryFile(
                "w", suffix=".tla", dir=base_dir, delete=False,
                prefix=os.path.basename(spec)[:-4] + "_mut_",
            ) as tf:
                # keep the module name = file name so SANY is happy
                mod = os.path.basename(tf.name)[:-4]
                tf.write(re.sub(r"^----+ MODULE \w+", f"---- MODULE {mod}", mutated, count=1))
                mut_path = tf.name
            try:
                passed, _ = run_tlc(mut_path, cfg, args.workers)
            finally:
                os.unlink(mut_path)
            if passed:
                survivors.append(label)  # spec did NOT catch the bug
                print(f"  SURVIVOR  {label}")
            else:
                killed += 1
                print(f"  killed    {label}")

    print(f"\nmutants: {total}  killed: {killed}  survivors: {len(survivors)}")
    if survivors:
        print("spec is TOO WEAK to catch:", ", ".join(survivors))
        return 1
    print("spec kills every mutant -- design invariants are tight.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
