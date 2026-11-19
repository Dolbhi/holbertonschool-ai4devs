from test_1 import run, build_srt

def test_empty_file_stays_empty(tmp_path):
    out = run(tmp_path, "", 3_600_000)

    assert out == ""