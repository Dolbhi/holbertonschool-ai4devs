from test_1 import run, build_srt

def test_odd_time_shifted_by_2m_12s_100ms(tmp_path):
    entries = [(i * 5000 + 1000, i * 5000 + 4000, f"sub {i}") for i in range(50)]
    shift = 2 * 60_000 + 12_000 + 100  # 132_100 ms
    shifted = [(s + shift, e + shift, t) for s, e, t in entries]

    out = run(tmp_path, build_srt(entries), shift)

    assert out == build_srt(shifted)