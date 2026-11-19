from test_1 import run, build_srt

def test_whitespace_only_blank_lines_are_treated_as_blank(tmp_path):
    # Expected to FAIL with the current code: the filter only drops lines
    # exactly equal to "\n", so "   \n" is kept and shifts the block grouping.
    content = (
        "1\n00:00:01,000 --> 00:00:02,000\nhello\n   \n"
        "2\n00:00:03,000 --> 00:00:04,000\nworld\n"
    )
    expected = (
        "1\n00:00:02,000 --> 00:00:03,000\nhello\n\n"
        "2\n00:00:04,000 --> 00:00:05,000\nworld\n\n"
    )

    out = run(tmp_path, content, 1_000)

    assert out == expected