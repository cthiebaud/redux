#!/usr/bin/env python3
"""
One-off repair for a .ustx source file: some notes ended up with two
pitch-curve points stacked at the exact same x (almost certainly a stray
drag/double-click in OpenUtau's pitch editor), leaving the note with no
point on the other side of its boundary. This mirrors the duplicate onto
the missing side (same |x| offset, opposite sign) so each note gets a
proper lead-in (x<0) + settle (x>=0) pair back.

Usage:
    python3 fix_duplicate_pitch_points.py sensation-randomized.ustx
(edits the file in place; make your own backup first if you haven't)
"""
import sys
from pathlib import Path

from ruamel.yaml import YAML


def fix_notes(notes, track_no, report):
    for i, note in enumerate(notes):
        pts = note["pitch"]["data"]
        xs = [p["x"] for p in pts]
        if len(xs) == len(set(xs)):
            continue  # no duplicates

        has_neg = any(x < 0 for x in xs)
        has_pos = any(x >= 0 for x in xs)
        if has_neg and has_pos:
            continue  # duplicate exists but both sides already covered

        dup_x = next(x for x in xs if xs.count(x) > 1)
        if dup_x >= 0:
            # mirror the first occurrence onto the negative side
            idx = xs.index(dup_x)
        else:
            # mirror the last occurrence onto the positive side
            idx = len(xs) - 1 - xs[::-1].index(dup_x)

        before = (pts[idx]["x"], pts[idx]["y"])
        pts[idx]["x"] = -dup_x
        after = (pts[idx]["x"], pts[idx]["y"])
        report.append((track_no, i, note["lyric"], before, after))


def main():
    path = Path(sys.argv[1])

    yaml = YAML()
    yaml.preserve_quotes = True
    yaml.width = 4096

    with open(path, encoding="utf-8-sig") as f:
        doc = yaml.load(f)

    report = []
    for vp in doc["voice_parts"]:
        fix_notes(vp["notes"], vp["track_no"], report)

    with open(path, "w", encoding="utf-8-sig") as f:
        yaml.dump(doc, f)

    for track_no, idx, lyric, before, after in report:
        print(f"track={track_no} note={idx} lyric={lyric!r}: point {before} -> {after}")
    print(f"fixed {len(report)} note(s) in {path}")


if __name__ == "__main__":
    main()
