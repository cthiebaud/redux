# video/

Generates `dist/bateau_video_draft.mp4`: a lyric-video-style rendering of
the solo guitar take, with chord names and section labels synced to the
music.

## Source audio

Track: **bateau_partiel_solo_guitar_0**, Suno share link:
https://suno.com/s/1I7CzpkucLf0XSSu

The audio file isn't committed to this repo (it's fetched content, not
project source) -- it lives in `cache/`, which is gitignored. To get it:

1. Install and load [suno-tape](https://github.com/cthiebaud/suno-tape)
   (a Chrome extension -- see its own README for setup).
2. Open the Suno link above, start a recording, let the full track play
   to the end (or stop it manually once it does).
3. Move the resulting `<track name>-<timestamp>.webm` from your Downloads
   folder into `cache/`.
4. Update `video_timeline.yaml`'s `audio:` field to that exact filename.
5. Sanity-check the duration matches what's expected (`ffprobe -v error
   -show_entries format=duration -of default=noprint_wrappers=1
   cache/<file>`) -- the cue timings in `video_timeline.yaml` were tuned
   against this specific take, so a meaningfully different duration means
   a different take and would need re-syncing.

## Building

```
python3 generate_video.py
```

Reads `video_timeline.yaml` (cues: chords, section labels, comments,
background images) and `cache/`'s audio, renders the background
slideshow/Ken-Burns zoom (cached in `build/`, see `generate_video.py`'s
own comments), overlays text via `ffmpeg`'s `drawtext`, and muxes
everything into `dist/bateau_video_draft.mp4`.

Not yet wired into the top-level `bateau/tasks.py` invoke pipeline --
run directly for now.
