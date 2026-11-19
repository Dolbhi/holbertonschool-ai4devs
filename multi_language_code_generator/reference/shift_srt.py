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

def shift_timestamps(file_name, shift_ms):
    with open(file_name, "r") as file:
        lines = []
        for line in file.readlines():
            if line != "\n":
                lines.append(line)
        with open("output.srt", "w") as o_file:
            i = 0
            for line in lines:
                if i % 3 == 0:
                    # number
                    o_file.write(line)
                elif i % 3 == 1:
                    # timestamp
                    splits = line.split()
                    stamp_1 = parse_timestamp(splits[0])
                    stamp_1.ms += shift_ms
                    stamp_2 = parse_timestamp(splits[2])
                    stamp_2.ms += shift_ms
                    o_file.write(f"{str(stamp_1)} {splits[1]} {str(stamp_2)}\n")
                elif i % 3 == 2:
                    # subs
                    o_file.write(line)
                    o_file.write("\n")
                i += 1