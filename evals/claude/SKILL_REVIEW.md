# Skill review status

Every skill was read in this pass. `changed` means its files differ from before the review (hymme `502abd7`, dotfiles `cb1d801`). Evaluated cases are in `cases.json`; results in `results.jsonl` (labels `B0h` = hymme 0.10.1, `N1`/`N2` = 0.13.1).

## hymme skills

| skill | listed | changed | how it was checked |
|---|---|---|---|
| ai-nondeterministic | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| blackbox-cause-effect | hidden | no | content read, no correction needed; references checked by `check-doc-refs` in nix flake check |
| blackbox-covering | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| blackbox-partition | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| blackbox-state | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| commit-flow | yes | yes | eval: r-commit, r-en-commit, r-split |
| diff-review | yes | yes | eval: e-review, e-review-classattr, e-review-durbug, e-review-eval, e-review-mutable, e-review-swallow, r-en-review, r-review |
| experience-checklist | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| experience-exploratory | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| experience-scenario | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| flakiness-concurrency | hidden | yes | content read and corrected where wrong; accepted in r-debug / r-flaky, where the model chose systematic-debugging |
| flakiness-external | hidden | yes | content read and corrected where wrong; accepted in r-debug / r-flaky, where the model chose systematic-debugging |
| flakiness-value | hidden | yes | content read and corrected where wrong; accepted in r-debug / r-flaky, where the model chose systematic-debugging |
| formal-verification | yes | yes | eval: r-fv, v-fv-catalog |
| generative-fuzzing | hidden | no | content read, no correction needed; references checked by `check-doc-refs` in nix flake check |
| generative-property | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| gh-ci-investigate | yes | yes | eval: r-ci |
| good-test-principles | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| ledger-flow | yes | yes | eval: r-ledger |
| levels-operational | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| levels-service | hidden | no | content read, no correction needed; references checked by `check-doc-refs` in nix flake check |
| levels-system | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| levels | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| loop-engineering | yes | yes | eval: r-en-tla, r-loopeng, r-smt, v-loopeng-extract |
| loopeng-extract | hidden | yes | eval via router loop-engineering: r-en-tla, r-loopeng, r-smt, v-loopeng-extract |
| loopeng-formalize | hidden | yes | eval via router loop-engineering: r-en-tla, r-loopeng, r-smt, v-loopeng-extract |
| loopeng-gherkin | hidden | yes | eval via router loop-engineering: r-en-tla, r-loopeng, r-smt, v-loopeng-extract |
| loopeng-modelcheck | hidden | yes | eval via router loop-engineering: r-en-tla, r-loopeng, r-smt, v-loopeng-extract |
| loopeng-smt | hidden | yes | eval via router loop-engineering: r-en-tla, r-loopeng, r-smt, v-loopeng-extract |
| loopeng-tracecheck | hidden | yes | eval via router loop-engineering: r-en-tla, r-loopeng, r-smt, v-loopeng-extract |
| micro-commit | yes | yes | eval: g-split, r-commit, r-en-commit, r-split |
| mutation-testing | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| nonfunctional-attributes | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| nonfunctional-perf | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| nonfunctional-resilience | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| oracle-differential | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| oracle-model-based | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| oracle-past-output | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| oracle-relational | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| pr-create | yes | yes | eval: r-pr |
| process-static | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| rebase-flow | yes | yes | eval: g-rebase, r-rebase, r-squash |
| reset-flow | yes | yes | eval: g-reset, r-reset |
| review-feedback | yes | yes | eval: r-feedback |
| strategy-allocation | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| strategy-operations | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| tdd-cycle | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| tdd-green-strategy | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| test-catalog | hidden | yes | eval via router test-design: r-mutation, r-tdd, r-testdesign, r-testreview, v-testdesign-ledger |
| test-design-quality | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| test-design | yes | yes | eval: r-mutation, r-tdd, r-testdesign, r-testreview, v-testdesign-ledger |
| test-doubles | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| test-extract | hidden | yes | eval via router test-design: r-mutation, r-tdd, r-testdesign, r-testreview, v-testdesign-ledger |
| test-structure-anatomy | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| test-structure-lifecycle | hidden | no | content read, no correction needed; references checked by `check-doc-refs` in nix flake check |
| test-target-design | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| test-targeted | yes | yes | eval: r-targeted |
| test-verify | hidden | yes | eval via router test-design: r-mutation, r-tdd, r-testdesign, r-testreview, v-testdesign-ledger |
| testing-principles | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| using-hymme | hidden | yes | injected map; exercised by every case; session-start test |
| verifiability | yes | yes | eval: r-verifiability, v-verifiability |
| whitebox-controlflow-basic | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| whitebox-controlflow-path | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |
| whitebox-dataflow-loop | hidden | yes | content read and corrected where wrong; references checked by `check-doc-refs` in nix flake check |

## hymme agents

| agent | status | how it was checked |
|---|---|---|
| diff-reviewer | kept; takes all lenses | e-review* (6 cases) |
| verification-reviewer | new: merges 4 reviewers | v-* (dispatched in v-testdesign-ledger) |
| modeler | kept | read; loop-engineering route kept |
| prover | kept | read; formal-verification route kept |
| coder | removed | e-plansddforce A/B: same quality, -10% tokens without it |
| code-reviewer | removed | duplicated ponytail-review |
| loop-engineering / test-design / formal-verification / verifiability reviewers | merged into verification-reviewer | flake check on skills/*/reviewer.md |

## superpowers skills (foundation, unchanged)

| skill | how it was checked |
|---|---|
| brainstorming | read; conflicts with hymme resolved on the hymme side; eval: r-brainstorm, r-plan |
| diagnosing-superpowers | read; conflicts with hymme resolved on the hymme side |
| dispatching-parallel-agents | read; conflicts with hymme resolved on the hymme side |
| executing-plans | read; conflicts with hymme resolved on the hymme side; eval: e-plan, e-planflow, e-plansdd, e-plansddforce |
| finishing-a-development-branch | read; conflicts with hymme resolved on the hymme side; eval: r-pr |
| receiving-code-review | read; conflicts with hymme resolved on the hymme side; eval: r-feedback |
| requesting-code-review | read; conflicts with hymme resolved on the hymme side |
| subagent-driven-development | read; conflicts with hymme resolved on the hymme side; eval: e-plansddforce |
| systematic-debugging | read; conflicts with hymme resolved on the hymme side; eval: r-debug, r-flaky |
| test-driven-development | read; conflicts with hymme resolved on the hymme side; eval: r-tdd |
| using-git-worktrees | read; conflicts with hymme resolved on the hymme side |
| using-superpowers | read; conflicts with hymme resolved on the hymme side |
| verification-before-completion | read; conflicts with hymme resolved on the hymme side |
| writing-plans | read; conflicts with hymme resolved on the hymme side; eval: r-plan |
| writing-skills | read; conflicts with hymme resolved on the hymme side |

## dotfiles skills

| skill | listed | changed | how it was checked |
|---|---|---|---|
| designing-with-nasa-manual | hidden | yes | read; hidden from the model list (user-invoked only) |
| genshijin | yes | no | read; applies to every reply via rules/genshijin.md, unchanged |
| utility-create-skill | hidden | yes | read; fixed a Skill call to a hidden skill |
| utility-creating-rules | hidden | yes | read; hidden from the model list (user-invoked only) |
| utility-reviewing-skills | hidden | yes | read; hidden from the model list (user-invoked only) |
| yomiyasu | yes | no | read; triggered by rules/yomiyasu.md for Japanese prose, unchanged (fired in v-fv-catalog) |
