#!/bin/sh
# Humanize sensation-randomized.ustx: tiny random timing/pitch/dynamics
# variation so the duet sounds less quantized. Tune the values below and
# rerun; see `python3 humanize_ustx.py --help` for what each one means.
set -eu

cd "$(dirname "$0")"

SEED=3

TIMING_SIGMA=8.0
TIMING_MAX=20.0

DURATION_SIGMA=2.0
DURATION_MAX=4.0
MIN_DURATION=115

TUNING_SIGMA=1.0
TUNING_MAX=2.0

PITCH_SIGMA=1.0
PITCH_MAX=2.0

VOL_SIGMA=5.0
VOL_MAX=8.0

python3 humanize_ustx.py sensation-randomized.ustx -o sensation-randomized.humanized.ustx \
  --seed "$SEED" \
  --timing-sigma "$TIMING_SIGMA" --timing-max "$TIMING_MAX" \
  --duration-sigma "$DURATION_SIGMA" --duration-max "$DURATION_MAX" \
  --min-duration "$MIN_DURATION" \
  --tuning-sigma "$TUNING_SIGMA" --tuning-max "$TUNING_MAX" \
  --pitch-sigma "$PITCH_SIGMA" --pitch-max "$PITCH_MAX" \
  --vol-sigma "$VOL_SIGMA" --vol-max "$VOL_MAX"
