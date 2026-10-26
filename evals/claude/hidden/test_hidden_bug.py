import unittest

from order import Order


class HiddenBug(unittest.TestCase):
    def test_cancelled_cannot_ship(self):
        o = Order(1)
        o.transition("cancelled")
        with self.assertRaises(ValueError):
            o.transition("shipped")

    def test_paid_cancel_then_no_ship(self):
        o = Order(1)
        o.transition("paid")
        o.transition("cancelled")
        with self.assertRaises(ValueError):
            o.transition("shipped")

    def test_normal_flow_still_works(self):
        o = Order(1)
        o.transition("paid")
        self.assertEqual(o.payments, 1)
        self.assertEqual(o.transition("shipped"), "shipped")


if __name__ == "__main__":
    unittest.main()
