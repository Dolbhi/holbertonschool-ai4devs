from test_1 import run, build_srt

def test_zero_shift_preserves_timestamps(tmp_path):
    entries = [(i * 2000, i * 2000 + 1500, f"line {i}") for i in range(20)]

    out = run(tmp_path, build_srt(entries), 0)

    assert out == build_srt(entries) + "\n"