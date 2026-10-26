import unittest

from order import ALLOWED, Order


class HiddenBehaviour(unittest.TestCase):
    """The original state machine, which a refactor must keep."""

    def test_allowed_paths(self):
        for start, targets in {"created": {"paid", "cancelled"}, "paid": {"shipped", "cancelled"}}.items():
            for t in targets:
                o = Order(1)
                if start == "paid":
                    o.transition("paid")
                self.assertEqual(o.transition(t), t)

    def test_forbidden_paths(self):
        for path, bad in ((["paid", "shipped"], "paid"), (["cancelled"], "paid"), ([], "shipped"), ([], "created")):
            o = Order(1)
            for s in path:
                o.transition(s)
            with self.assertRaises(ValueError):
                o.transition(bad)

    def test_payment_count(self):
        o = Order(1)
        o.transition("paid")
        self.assertEqual(o.payments, 1)

    def test_allowed_table_kept(self):
        self.assertEqual(ALLOWED["shipped"], set())
        self.assertEqual(ALLOWED["cancelled"], set())


if __name__ == "__main__":
    unittest.main()
