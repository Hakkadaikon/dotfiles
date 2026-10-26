import unittest

from order import Order


class HiddenRefund(unittest.TestCase):
    def test_refund_paths(self):
        for path in (["paid"], ["paid", "shipped"]):
            o = Order(1, amount=500)
            for s in path:
                o.transition(s)
            o.transition("refunded")
            self.assertEqual(o.state, "refunded")
            self.assertEqual(o.refunded_amount, 500)

    def test_refund_forbidden(self):
        with self.assertRaises(ValueError):
            Order(1).transition("refunded")
        o = Order(1)
        o.transition("paid")
        o.transition("refunded")
        for s in ("paid", "shipped", "cancelled", "refunded"):
            with self.assertRaises(ValueError):
                o.transition(s)

    def test_amount(self):
        self.assertEqual(Order(1).refunded_amount, 0)
        with self.assertRaises(ValueError):
            Order(1, amount=-1)

    def test_history(self):
        o = Order(1)
        self.assertEqual(o.history, ["created"])
        o.transition("paid")
        with self.assertRaises(ValueError):
            o.transition("created")
        o.transition("shipped")
        self.assertEqual(o.history, ["created", "paid", "shipped"])


if __name__ == "__main__":
    unittest.main()
