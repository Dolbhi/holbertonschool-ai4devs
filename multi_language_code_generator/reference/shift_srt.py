import sys

def pad_zero(word, tgt_len):
    while len(word) < tgt_len:
        word = "0" + word
    return word

class Timestamp:
    def __init__(self, hrs, mins, secs, ms):
        self.ms = ((hrs * 60 + mins) * 60 + secs) * 1000 + ms

    def __str__(self):
        ms = pad_zero(str(self.ms % 1000),3)

        left = self.ms // 1000
        secs = pad_zero(str(left % 60),2)

        left = left // 60
        mins = pad_zero(str(left % 60),2)

        left = left // 60
        hrs = pad_zero(str(left),2)

        return f"{hrs}:{mins}:{secs},{ms}"

def parse_timestamp(word: str):
    splits = word.split(':')
    hrs = int(splits[0])
    mins = int(splits[1])
    secs = int(splits[2][:2])
    ms = int(splits[2][-3:])

    return Timestamp(hrs, mins, secs, ms)

def parse_blocks(text):
    blocks = []
    block = []
    for line in text.splitlines():
        if line.strip() == "":
            if block:
                blocks.append(block)
                block = []
        else:
            block.append(line)
    if block:
        blocks.append(block)
    return blocks

def shift_timestamp_line(line, shift_ms):
    splits = line.split("-->")
    stamp_1 = parse_timestamp(splits[0].strip())
    stamp_1.ms += shift_ms
    stamp_2 = parse_timestamp(splits[1].strip())
    stamp_2.ms += shift_ms
    return f"{stamp_1} --> {stamp_2}"

def shift_timestamps(file_name, shift_ms, out_file):
    with open(file_name, "r", encoding="utf-8") as file:
        blocks = parse_blocks(file.read())

    with open(out_file, "w", encoding="utf-8") as o_file:
        for block in blocks:
            o_file.write(block[0] + "\n")
            if len(block) > 1 and "-->" in block[1]:
                o_file.write(shift_timestamp_line(block[1], shift_ms) + "\n")
                text_lines = block[2:]
            else:
                text_lines = block[1:]
            for line in text_lines:
                o_file.write(line + "\n")
            o_file.write("\n")

if __name__ == "__main__":
    shift_timestamps(sys.argv[1], int(sys.argv[2]), sys.argv[3])
