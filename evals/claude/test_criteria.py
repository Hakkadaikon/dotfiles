#!/usr/bin/env python3
"""Self-check for the e-review criteria: real findings must match, quoted diff lines and clean reviews must not."""

import json
import os
import re
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from run import expand  # noqa: E402

CASE = next(c for c in json.load(open(os.path.join(HERE, "cases.json"))) if c["id"] == "e-review")
CANCEL, PAYMENT = (expand(p) for p in CASE["expect_all"])

FINDINGS = [
    (CANCEL, "cancelled から shipped への遷移が許されている"),
    (CANCEL, "`cancelled` → `shipped` が allowed になっている"),
    (CANCEL, "キャンセル済みでも発送できる"),
    (CANCEL, '- must: order.py:9 `"cancelled": {"shipped"}` でキャンセル済みの注文が発送できてしまう。'),
    (CANCEL, "キャンセル済みでも発送できる。テストが無い"),
    (PAYMENT, "二重決済を許してしまう"),
    (PAYMENT, "`self.payments = 1` で2回目の支払いが数えられない"),
    (PAYMENT, "paid -> paid で二重決済が通ってしまう"),
]
NOT_FINDINGS = [
    '+    "cancelled": {"shipped"},',
    "+            self.payments = 1",
    "指摘なし。cancelled と shipped の状態を確認した。",
    "cancelled と shipped の遷移に問題なし",
    "cancelled → shipped も確認できた",
    "payments のカウントは問題ない",
    "cancelled と shipped の遷移は問題ありません",
]


class ReviewCriteria(unittest.TestCase):
    def test_findings_match(self):
        for pattern, text in FINDINGS:
            with self.subTest(text=text):
                self.assertRegex(text, pattern)

    def test_non_findings_do_not_match(self):
        for text in NOT_FINDINGS:
            for pattern in (CANCEL, PAYMENT):
                with self.subTest(text=text):
                    self.assertIsNone(re.search(pattern, text))


class AllReviewCases(unittest.TestCase):
    """Every planted-bug review case: a recorded real review scores full marks, the bare diff scores zero."""

    def test_recorded_reviews_score_full(self):
        samples = json.load(open(os.path.join(HERE, "hidden", "review_samples.json")))
        cases = {c["id"]: c for c in json.load(open(os.path.join(HERE, "cases.json")))}
        for cid, texts in samples.items():
            for text in texts:
                for pattern in cases[cid]["expect_all"]:
                    with self.subTest(case=cid, pattern=pattern[:40], text=text[:40]):
                        self.assertRegex(text, expand(pattern))

    def test_bare_diff_scores_zero(self):
        import subprocess
        import tempfile

        for c in json.load(open(os.path.join(HERE, "cases.json"))):
            if "expect_all" not in c:
                continue
            repo = os.path.join(tempfile.mkdtemp(), "x")
            subprocess.run(["bash", os.path.join(HERE, "scaffold.sh"), repo, c["variant"]], check=True, capture_output=True)
            diff = subprocess.run(["git", "diff"], cwd=repo, capture_output=True, text=True).stdout
            for pattern in c["expect_all"]:
                with self.subTest(case=c["id"], pattern=pattern[:40]):
                    self.assertIsNone(re.search(expand(pattern), diff))


if __name__ == "__main__":
    unittest.main()
