import unittest

from order import Order


class HiddenHistory(unittest.TestCase):
    def test_starts_with_created(self):
        self.assertEqual(Order(1).history, ["created"])

    def test_appends_successful_transitions(self):
        o = Order(1)
        o.transition("paid")
        o.transition("shipped")
        self.assertEqual(o.history, ["created", "paid", "shipped"])

    def test_failed_transition_not_recorded(self):
        o = Order(1)
        with self.assertRaises(ValueError):
            o.transition("shipped")
        self.assertEqual(o.history, ["created"])

    def test_history_not_shared(self):
        a, b = Order(1), Order(2)
        a.transition("paid")
        self.assertEqual(b.history, ["created"])


if __name__ == "__main__":
    unittest.main()
