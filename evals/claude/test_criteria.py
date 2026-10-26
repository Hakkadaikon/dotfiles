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


if __name__ == "__main__":
    unittest.main()
