# import pytest
from shift_srt import shift_timestamps


def fmt(ms):
    """Independent SRT timestamp formatter, used to build expected output."""
    h, rem = divmod(ms, 3_600_000)
    m, rem = divmod(rem, 60_000)
    s, ms_ = divmod(rem, 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms_:03d}"


def build_srt(entries):
    """Canonical SRT: one blank line between blocks, trailing newline."""
    blocks = [f"{i}\n{fmt(s)} --> {fmt(e)}\n{text}"
              for i, (s, e, text) in enumerate(entries, 1)]
    return "\n\n".join(blocks) + "\n"


def run(tmp_path, content, shift_ms):
    src = tmp_path / "in.srt"
    dst = tmp_path / "out.srt"
    src.write_text(content, encoding="utf-8")
    shift_timestamps(str(src), shift_ms, str(dst))
    return dst.read_text(encoding="utf-8")


def test_small_file_shifted_by_one_minute(tmp_path):
    entries = [(i * 2000, i * 2000 + 1500, f"line {i}") for i in range(100)]
    shifted = [(s + 60_000, e + 60_000, t) for s, e, t in entries]

    out = run(tmp_path, build_srt(entries), 60_000)

    assert out == build_srt(shifted)


def test_odd_time_shifted_by_2m_12s_100ms(tmp_path):
    entries = [(i * 5000 + 1000, i * 5000 + 4000, f"sub {i}") for i in range(50)]
    shift = 2 * 60_000 + 12_000 + 100  # 132_100 ms
    shifted = [(s + shift, e + shift, t) for s, e, t in entries]

    out = run(tmp_path, build_srt(entries), shift)

    assert out == build_srt(shifted)


def test_empty_file_stays_empty(tmp_path):
    out = run(tmp_path, "", 3_600_000)

    assert out == ""


def test_irregular_blank_lines_normalized_to_one(tmp_path):
    entries = [(i * 2000, i * 2000 + 1500, f"line {i}") for i in range(1, 101)]
    shifted = [(s + 3_600_000, e + 3_600_000, t) for s, e, t in entries]

    # Between blocks, use 1, 2, or 3 blank lines, cycling
    content = ""
    for i, (s, e, t) in enumerate(entries, 1):
        content += f"{i}\n{fmt(s)} --> {fmt(e)}\n{t}\n" + "\n" * (1 + i % 3)

    out = run(tmp_path, content, 3_600_000)

    assert out == build_srt(shifted)
    assert "\n\n\n" not in out


def test_padded_file_has_no_extra_leading_or_trailing_newlines(tmp_path):
    entries = [(i * 2000, i * 2000 + 1500, f"line {i}") for i in range(100)]
    shifted = [(s + 10_500, e + 10_500, t) for s, e, t in entries]
    content = "\n\n\n" + build_srt(entries) + "\n\n\n"

    out = run(tmp_path, content, 10_500)

    assert out == build_srt(shifted) + "\n"  # output ends with "text\n\n", no more
    assert not out.startswith("\n")


def test_zero_shift_preserves_timestamps(tmp_path):
    entries = [(i * 2000, i * 2000 + 1500, f"line {i}") for i in range(20)]

    out = run(tmp_path, build_srt(entries), 0)

    assert out == build_srt(entries) + "\n"


def test_shift_carries_across_hour_boundary(tmp_path):
    entries = [(3_599_999, 3_600_500, "crosses hour")]  # 00:59:59,999 -> 01:00:00,500
    shifted = [(3_600_000, 3_600_501, "crosses hour")]  # 01:00:00,000 -> 01:00:01,501

    out = run(tmp_path, build_srt(entries), 1)

    assert out == build_srt(shifted) + "\n"


def test_negative_shift_within_range(tmp_path):
    entries = [(5_000, 6_000, "earlier")]
    shifted = [(4_000, 5_000, "earlier")]

    out = run(tmp_path, build_srt(entries), -1_000)

    assert out == build_srt(shifted) + "\n"


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