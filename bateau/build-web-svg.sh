#!/usr/bin/env bash
# Build a single, continuous-page SVG of bateau.3.ly for the web --
# everything LilyPond would normally paginate across several A4 pages
# (including the copyright, footnote, and LilyPond tagline) on one
# page sized to fit, without a hand-picked height baked in.
#
# Two things make this fiddlier than "just measure the content":
#  - The footer (copyright/tagline) always glues to the bottom margin
#    of whatever page height it's given -- it does not mark where the
#    real content ends, so "measure the lowest thing on the page" is
#    circular. -dcrop gives the real content height instead (it crops
#    to content but -- confusingly -- also drops the footer, so it's
#    only good for this measurement, not the final output).
#  - If the page height is too close to the content height, LilyPond's
#    page-fitting *estimate* (not the real layout) badly misjudges how
#    much fits and pathologically splits into many small pages instead
#    of one. There's a threshold a fair bit above the real content
#    height past which it reliably settles on one page, with some
#    margin for the footer below the content as a side effect.
#
# So: pass 1 measures real content height via -dcrop; pass 2 adds a
# margin and builds for real, growing the margin and retrying if
# LilyPond still split it into more than one page.
#
# Usage: ./build-web-svg.sh   (run from the bateau/ directory)
set -euo pipefail
cd "$(dirname "$0")"

NAME=bateau.3
WRAPPER=_web-build-wrapper.ly
MARGIN_MM=200
MAX_ATTEMPTS=5

cleanup() {
  rm -f "$WRAPPER" "$NAME-web".midi "$NAME-web"-*.midi \
        "$NAME-web".svg "$NAME-web"-*.svg "$NAME-web.cropped.svg"
}
trap cleanup EXIT

make_wrapper() {
  cat > "$WRAPPER" <<EOF
\\version "2.26.0"
#(define web-svg #t)
#(define web-svg-height $1)
\\include "$NAME.ly"
EOF
}

run_lilypond() {
  lilypond -dbackend=svg -dno-point-and-click "$@" -o "$NAME-web" "$WRAPPER" \
    2>&1 | grep -v "^Processing\|^Parsing\|^Interpreting\|^Preprocessing\|^Calculating\|^MIDI output\|unsupported formats"
}

echo "Pass 1: measuring real content height (excluding the footer) via -dcrop..."
cleanup
make_wrapper 2000
run_lilypond -dcrop
CONTENT_MM=$(python3 -c "
import re
svg = open('$NAME-web.cropped.svg', encoding='utf-8').read()
m = re.search(r'height=\"([\d.]+)mm\"', svg)
print(round(float(m.group(1))))
")
echo "Content is ${CONTENT_MM}mm."

for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
  HEIGHT_MM=$((CONTENT_MM + MARGIN_MM))
  echo "Pass 2 (attempt $attempt): building at ${HEIGHT_MM}mm (margin ${MARGIN_MM}mm)..."
  cleanup
  make_wrapper "$HEIGHT_MM"
  run_lilypond
  PAGES=$(ls "$NAME-web"*.svg 2>/dev/null | wc -l | tr -d ' ')
  if [ "$PAGES" = "1" ]; then
    mv "$NAME-web.svg" "$NAME.web.svg"
    echo "Wrote $NAME.web.svg (${HEIGHT_MM}mm tall)"
    exit 0
  fi
  echo "  -> split into $PAGES pages at that height; growing the margin and retrying."
  MARGIN_MM=$((MARGIN_MM * 2))
done

echo "Gave up after $MAX_ATTEMPTS attempts -- still splitting into multiple pages." >&2
exit 1
