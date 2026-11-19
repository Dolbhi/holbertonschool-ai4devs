from test_1 import run, build_srt

def test_shift_carries_across_hour_boundary(tmp_path):
    entries = [(3_599_999, 3_600_500, "crosses hour")]  # 00:59:59,999 -> 01:00:00,500
    shifted = [(3_600_000, 3_600_501, "crosses hour")]  # 01:00:00,000 -> 01:00:01,501

    out = run(tmp_path, build_srt(entries), 1)

    assert out == build_srt(shifted) + "\n"