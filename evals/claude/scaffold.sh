#!/usr/bin/env bash
# Build the fixture repo for one eval run: scaffold.sh <dest> <variant>
# variants: base (clean tree), dirty (uncommitted change), plan (a written plan to execute)
set -euo pipefail
dest="$1"
variant="${2:-base}"
mkdir -p "$dest"
cd "$dest"

cat >order.py <<'EOF'
"""Order state machine."""

STATES = ("created", "paid", "shipped", "cancelled")

ALLOWED = {
    "created": {"paid", "cancelled"},
    "paid": {"shipped", "cancelled"},
    "shipped": set(),
    "cancelled": set(),
}


class Order:
    def __init__(self, order_id):
        self.order_id = order_id
        self.state = "created"
        self.payments = 0

    def transition(self, new_state):
        if new_state not in ALLOWED[self.state]:
            raise ValueError(f"{self.state} -> {new_state} is not allowed")
        if new_state == "paid":
            self.payments += 1
        self.state = new_state
        return self.state
EOF

cat >duration.py <<'EOF'
"""Duration parsing."""


def parse_duration(text):
    """Parse strings like "1h30m", "45s", "2h" into seconds. See README."""
    raise NotImplementedError
EOF

cat >README.md <<'EOF'
# shop

## parse_duration(text) -> int

Returns the number of seconds in `text`.

- Units: `h` (3600), `m` (60), `s` (1). Each unit appears at most once, in the order h, m, s.
- Each number is a non-negative decimal integer without sign or spaces.
- Leading and trailing whitespace is ignored. Empty or whitespace-only input raises `ValueError`.
- Anything else (unknown unit, repeated unit, wrong order, missing number, missing unit) raises `ValueError`.
- Examples: `"1h30m"` -> 5400, `"45s"` -> 45, `"2h"` -> 7200, `" 0s "` -> 0.
EOF

mkdir -p tests && : >tests/__init__.py
cat >tests/test_order.py <<'EOF'
import unittest

from order import Order


class OrderTest(unittest.TestCase):
    def test_pay_then_ship(self):
        o = Order(1)
        o.transition("paid")
        self.assertEqual(o.transition("shipped"), "shipped")

    def test_cannot_ship_unpaid(self):
        with self.assertRaises(ValueError):
            Order(1).transition("shipped")


if __name__ == "__main__":
    unittest.main()
EOF

git init -q -b main
git config user.email eval@example.com
git config user.name eval
git add -A
git commit -q -m "chore: initial shop fixture"

case "$variant" in
base) ;;
dirty)
  python3 - <<'EOF'
p = "order.py"
s = open(p).read()
s = s.replace('        if new_state == "paid":\n', '        if new_state == "paid" and self.payments:\n            raise ValueError("already paid")\n        if new_state == "paid":\n')
open(p, "w").write(s)
EOF
  ;;
bug | logs)
  python3 - <<'EOF2'
p = "order.py"
s = open(p).read()
s = s.replace('"cancelled": set(),', '"cancelled": {"shipped"},')
s = s.replace('"paid": {"shipped", "cancelled"},', '"paid": {"shipped", "cancelled", "paid"},')
s = s.replace('            self.payments += 1\n', '            self.payments = 1\n')
open(p, "w").write(s)
EOF2
  ;;
esac
case "$variant" in
base | dirty | bug) ;;
logs)
  mkdir -p logs
  python3 - <<'EOF2'
import random
random.seed(7)
with open("logs/app.log", "w") as f:
    for i in range(60000):
        oid = random.randint(1000, 9999)
        f.write(f"2026-10-20T{i // 3600 % 24:02d}:{i // 60 % 60:02d}:{i % 60:02d} INFO order={oid} transition created->paid ok latency_ms={random.randint(3, 90)}\n")
        if i == 41234:
            f.write(f"2026-10-20T11:27:14 ERROR order=4711 shipment created for cancelled order (transition cancelled->shipped accepted)\n")
        if i == 52001:
            f.write(f"2026-10-20T14:26:41 ERROR order=5120 payments counter=1 after second payment attempt was accepted (expected rejection or count 2)\n")
EOF2
  git add logs order.py && git commit -q -m "chore: add production log"
  ;;
plan | plansdd)
  mkdir -p docs
  cat >docs/plan.md <<'EOF'
# Plan: refunds for orders

Spec is settled. Execute every task in order. Use `python3 -m unittest discover -s tests -t .` to run tests.

## Task 1: refunded state
- Add a `refunded` state. Allowed only from `shipped` and `paid`. `refunded` is terminal.
- Tests: paid -> refunded ok, shipped -> refunded ok, created -> refunded raises ValueError, refunded -> anything raises ValueError.
- Commit: `feat(order): add refunded state`

## Task 2: refund amount bookkeeping
- `Order.__init__(order_id, amount=0)` stores `amount` (non-negative int, else ValueError).
- Entering `refunded` sets `refunded_amount = amount`; before that `refunded_amount` is 0.
- Tests for the default, a negative amount, and the refunded amount after refund.
- Commit: `feat(order): record refunded amount`

## Task 3: history
- `Order.history` is a list of states in visit order, starting with `["created"]`; each successful transition appends the new state; failed transitions do not.
- Tests for a full path and for a failed transition leaving history unchanged.
- Commit: `feat(order): keep state history`
EOF
  if [ "$variant" = plansdd ]; then
    printf '%s\n\n%s\n' '> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.' "$(cat docs/plan.md)" >docs/plan.md
  fi
  git add docs/plan.md
  git commit -q -m "docs: add refund plan"
  ;;
*)
  echo "unknown variant: $variant" >&2
  exit 1
  ;;
esac
