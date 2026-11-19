from test_1 import run, build_srt

def test_negative_shift_within_range(tmp_path):
    entries = [(5_000, 6_000, "earlier")]
    shifted = [(4_000, 5_000, "earlier")]

    out = run(tmp_path, build_srt(entries), -1_000)

    assert out == build_srt(shifted) + "\n"