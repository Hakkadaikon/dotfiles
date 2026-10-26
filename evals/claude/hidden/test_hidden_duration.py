import unittest

from duration import parse_duration


class HiddenDuration(unittest.TestCase):
    pass


def _valid(text, want):
    return lambda self: self.assertEqual(parse_duration(text), want, text)


def _invalid(text):
    def t(self):
        with self.assertRaises(ValueError, msg=repr(text)):
            parse_duration(text)

    return t


VALID = [('1h30m', 5400), ('45s', 45), ('2h', 7200), (' 0s ', 0), ('1h2m3s', 3723), ('10m', 600), ('0h0m0s', 0), ('100s', 100)]
INVALID = ['', '   ', '1x', '1h1h', '30m1h', 'h', '1', '-1s', '+1s', '1 h', '1.5h', '1hm']
for i, (text, want) in enumerate(VALID):
    setattr(HiddenDuration, f"test_valid_{i:02d}", _valid(text, want))
for i, text in enumerate(INVALID):
    setattr(HiddenDuration, f"test_invalid_{i:02d}", _invalid(text))

if __name__ == "__main__":
    unittest.main()
