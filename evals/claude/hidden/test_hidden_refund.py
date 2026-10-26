import unittest

from order import Order


class HiddenRefund(unittest.TestCase):
    def test_paid_to_refunded(self):
        o = Order(1)
        o.transition("paid")
        self.assertEqual(o.transition("refunded"), "refunded")

    def test_shipped_to_refunded(self):
        o = Order(1)
        o.transition("paid")
        o.transition("shipped")
        self.assertEqual(o.transition("refunded"), "refunded")

    def test_created_cannot_refund(self):
        with self.assertRaises(ValueError):
            Order(1).transition("refunded")

    def test_refunded_is_terminal(self):
        o = Order(1)
        o.transition("paid")
        o.transition("refunded")
        for s in ("paid", "shipped", "cancelled", "refunded"):
            with self.assertRaises(ValueError):
                o.transition(s)

    def test_existing_flow_unchanged(self):
        o = Order(1)
        o.transition("paid")
        self.assertEqual(o.transition("shipped"), "shipped")
        with self.assertRaises(ValueError):
            Order(2).transition("shipped")


if __name__ == "__main__":
    unittest.main()
