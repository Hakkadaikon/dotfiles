import unittest

from duration import parse_duration


class HiddenDuration(unittest.TestCase):
    def test_valid(self):
        for text, want in [("1h30m", 5400), ("45s", 45), ("2h", 7200), (" 0s ", 0),
                           ("1h2m3s", 3723), ("10m", 600), ("0h0m0s", 0), ("100s", 100)]:
            self.assertEqual(parse_duration(text), want, text)

    def test_invalid(self):
        for text in ["", "   ", "1x", "1h1h", "30m1h", "h", "1", "-1s", "+1s", "1 h", "1.5h", "1hm"]:
            with self.assertRaises(ValueError, msg=repr(text)):
                parse_duration(text)


if __name__ == "__main__":
    unittest.main()
