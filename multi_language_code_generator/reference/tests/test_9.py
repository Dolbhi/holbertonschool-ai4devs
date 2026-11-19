from test_1 import run, build_srt

def test_multiline_subtitle_text_is_preserved(tmp_path):
    # Expected to FAIL with the current code: the parser assumes exactly
    # one text line per block, so the second text line is misread as an index
    # and the next index is misread as a timestamp (IndexError).
    content = (
        "1\n00:00:01,000 --> 00:00:02,000\nfirst line\nsecond line\n\n"
        "2\n00:00:03,000 --> 00:00:04,000\nsingle line\n"
    )
    expected = (
        "1\n00:00:02,000 --> 00:00:03,000\nfirst line\nsecond line\n\n"
        "2\n00:00:04,000 --> 00:00:05,000\nsingle line\n\n"
    )

    out = run(tmp_path, content, 1_000)

    assert out == expected