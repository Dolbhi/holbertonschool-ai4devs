# Cross-Language Specification - Shift SRT

## Algorithm
Generate a copy of a given SRT file with all timestamps shifted by a fixed timestep:
- Maintain valid SRT formatting
- Ensure the time difference between timestamps is the same in the new file

## Inputs
- SRT file
- Target timestep to shift by in seconds

## Outputs
- Adjusted SRT file

## Edge Cases
- Empty file
- Missing newlines
- Extra newlines

## Test Cases
- small.srt, 60s → srt file with 100 subtitles shifted by 1 m compared to the original
- odd_time.srt, 132.1s → srt with 50 subtitles shifted by 2 m, 12 s and 100 ms
- empty.srt, 3600s → srt file which is also empty
- irregular.srt, 3600s → srt file with 100 subtitles separated by 1 newline each
- padded.srt 10.5s → srt file with 100 subtitles, no extra newlines before and after first and last subtitle