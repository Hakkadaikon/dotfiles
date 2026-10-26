import unittest

from order import Order


class HiddenFee(unittest.TestCase):
    def test_no_fee_before_cancel(self):
        self.assertEqual(Order(1, amount=999).cancellation_fee, 0)

    def test_created_cancel_is_free(self):
        o = Order(1, amount=1000)
        o.transition("cancelled")
        self.assertEqual(o.cancellation_fee, 0)

    def test_paid_cancel_charges_ten_percent_rounded_down(self):
        o = Order(1, amount=999)
        o.transition("paid")
        o.transition("cancelled")
        self.assertEqual(o.cancellation_fee, 99)

    def test_default_amount(self):
        o = Order(1)
        o.transition("paid")
        o.transition("cancelled")
        self.assertEqual(o.cancellation_fee, 0)


if __name__ == "__main__":
    unittest.main()
