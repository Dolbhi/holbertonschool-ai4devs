from test_1 import run, build_srt

def test_padded_file_has_no_extra_leading_or_trailing_newlines(tmp_path):
    entries = [(i * 2000, i * 2000 + 1500, f"line {i}") for i in range(100)]
    shifted = [(s + 10_500, e + 10_500, t) for s, e, t in entries]
    content = "\n\n\n" + build_srt(entries) + "\n\n\n"

    out = run(tmp_path, content, 10_500)

    assert out == build_srt(shifted) + "\n"  # output ends with "text\n\n", no more
    assert not out.startswith("\n")