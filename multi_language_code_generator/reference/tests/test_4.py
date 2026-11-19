from test_1 import run, build_srt

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