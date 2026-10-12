import unittest

import yomiyasu_lint as lint


class CodeFenceTests(unittest.TestCase):
    def test_tilde_fenced_code_is_excluded_from_analysis(self):
        text = "\n".join(
            [
                "本文です。",
                "~~~python",
                "コード内の文です。",
                "コード内の文です。",
                "コード内の文です。",
                "~~~",
                "本文は続きます。",
            ]
        )

        result = lint.lint_text(text)

        self.assertEqual([], result["findings"])
        self.assertEqual(13, result["metrics"]["char_count"])

    def test_different_fence_marker_does_not_close_code_block(self):
        text = "\n".join(
            [
                "```python",
                "~~~",
                "コード内の文です。",
                "```",
                "本文です。",
            ]
        )

        result = lint.lint_text(text)

        self.assertEqual([], result["findings"])
        self.assertEqual(5, result["metrics"]["char_count"])

    def test_marker_like_code_line_does_not_close_code_block(self):
        for marker in ("~~~", "```"):
            with self.subTest(marker=marker):
                text = "\n".join(
                    [
                        f"{marker}python",
                        f"{marker}not-a-closing-fence",
                        "地味に効く。",
                        marker,
                        "本文です。",
                    ]
                )

                result = lint.lint_text(text)

                self.assertEqual([], result["findings"])
                self.assertEqual(5, result["metrics"]["char_count"])

    def test_shorter_fence_does_not_close_code_block(self):
        for marker in ("~~~", "```"):
            with self.subTest(marker=marker):
                longer_marker = marker + marker[0]
                text = "\n".join(
                    [
                        f"{longer_marker}python",
                        marker,
                        "地味に効く。",
                        longer_marker,
                        "本文です。",
                    ]
                )

                result = lint.lint_text(text)

                self.assertEqual([], result["findings"])
                self.assertEqual(5, result["metrics"]["char_count"])


if __name__ == "__main__":
    unittest.main()
