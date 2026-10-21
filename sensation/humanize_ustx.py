#!/usr/bin/env python3
"""
Add small, natural-feeling random variation to the timing, pitch and
dynamics of every note in a .ustx (OpenUtau) project.

Timing:   each note's duration gets a tiny random nudge. A note's start
          only gets its own independent jitter if there was already a gap
          (rest) before it in the source; if it was legato with the
          previous note (its start tick == the previous note's end tick),
          it stays glued to the previous note's new end exactly - OpenUtau
          requires that exact tick match to render legato at all, and even
          a single-tick gap silently breaks it.
Pitch:    the per-note "tuning" offset (cents) gets a small random jitter
          (up or down). The pitch curve is only touched at the END of a
          note - i.e. its lead-in points into the following note - and is
          only ever nudged DOWNWARD, like a slight natural sag before the
          next note.
Dynamics: a "vol" (volume) phoneme expression is added/adjusted on each
          note with a small random value around 100.

All effects are independently randomized per note and per voice part, so
two simultaneous tracks (e.g. a duet) drift apart slightly instead of
moving in lockstep like a quantized robot.

Usage:
    python3 humanize_ustx.py input.ustx -o output.ustx [--seed 42]
"""
import argparse
import random
from pathlib import Path

from ruamel.yaml import YAML


def clamp(value, lo, hi):
    return max(lo, min(hi, value))


def jitter(base, sigma, max_abs, rng):
    delta = clamp(rng.gauss(0, sigma), -max_abs, max_abs)
    return base + delta


def humanize_notes(notes, rng, cfg):
    prev_end = None
    prev_orig_end = None
    for note in notes:
        orig_start = note["position"]
        orig_dur = note["duration"]

        is_legato = prev_orig_end is not None and orig_start == prev_orig_end
        if is_legato:
            # OpenUtau's legato requires the previous note's end and this
            # note's start to land on the exact same tick. Jittering them
            # independently opens a gap and silently breaks the legato.
            # So: no jitter on this boundary at all, just follow the
            # (possibly already-shifted) end of the previous note.
            new_start = prev_end
        else:
            new_start = jitter(orig_start, cfg.timing_sigma, cfg.timing_max, rng)
            if prev_end is not None:
                new_start = max(new_start, prev_end)
            new_start = int(round(new_start))

        new_dur = jitter(orig_dur, cfg.duration_sigma, cfg.duration_max, rng)
        new_dur = max(cfg.min_duration, int(round(new_dur)))

        note["position"] = new_start
        note["duration"] = new_dur
        prev_end = new_start + new_dur
        prev_orig_end = orig_start + orig_dur

        tuning = note.get("tuning", 0) or 0
        note["tuning"] = int(round(jitter(tuning, cfg.tuning_sigma, cfg.tuning_max, rng)))

        # Pitch points with x < 0 sit before this note's start, i.e. they
        # describe the tail end of the PREVIOUS note (the transition into
        # this one). Points with x >= 0 describe this note's own attack
        # settle and are left untouched. The dip is always downward.
        pitch = note.get("pitch")
        if pitch and pitch.get("data"):
            for pt in pitch["data"]:
                if pt.get("x", 0) < 0:
                    dip = clamp(abs(rng.gauss(0, cfg.pitch_sigma)), 0, cfg.pitch_max)
                    pt["y"] = int(round((pt.get("y", 0) or 0) - dip))

        if cfg.vol_sigma == 0 and cfg.vol_max == 0:
            continue  # dynamics jitter disabled: leave phoneme_expressions untouched

        vol_value = int(round(jitter(100, cfg.vol_sigma, cfg.vol_max, rng)))
        exprs = note.get("phoneme_expressions")
        if exprs is None:
            exprs = []
            note["phoneme_expressions"] = exprs
        for e in exprs:
            if e.get("index") == 0 and e.get("abbr") == "vol":
                e["value"] = vol_value
                break
        else:
            exprs.insert(0, {"index": 0, "abbr": "vol", "value": vol_value})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path)
    parser.add_argument("-o", "--output", type=Path, default=None,
                         help="defaults to <input>.humanized.ustx")
    parser.add_argument("--seed", type=int, default=None)
    parser.add_argument("--timing-sigma", type=float, default=4.0, help="ticks")
    parser.add_argument("--timing-max", type=float, default=12.0, help="ticks")
    parser.add_argument("--duration-sigma", type=float, default=3.0, help="ticks")
    parser.add_argument("--duration-max", type=float, default=8.0, help="ticks")
    parser.add_argument("--min-duration", type=int, default=60, help="ticks")
    parser.add_argument("--tuning-sigma", type=float, default=0.5, help="cents")
    parser.add_argument("--tuning-max", type=float, default=1.5, help="cents")
    parser.add_argument("--pitch-sigma", type=float, default=0.5,
                         help="cents, end-of-note dip only, always downward")
    parser.add_argument("--pitch-max", type=float, default=1.5,
                         help="cents, hard cap on the downward dip")
    parser.add_argument("--vol-sigma", type=float, default=3.0)
    parser.add_argument("--vol-max", type=float, default=8.0)
    cfg = parser.parse_args()

    if cfg.output is None:
        cfg.output = cfg.input.with_suffix(".humanized.ustx")

    rng = random.Random(cfg.seed)

    yaml = YAML()
    yaml.preserve_quotes = True
    yaml.width = 4096

    with open(cfg.input, encoding="utf-8-sig") as f:
        doc = yaml.load(f)

    for voice_part in doc["voice_parts"]:
        humanize_notes(voice_part["notes"], rng, cfg)

    with open(cfg.output, "w", encoding="utf-8-sig") as f:
        yaml.dump(doc, f)

    print(f"wrote {cfg.output}")


if __name__ == "__main__":
    main()
