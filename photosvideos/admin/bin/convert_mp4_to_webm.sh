#!/usr/bin/env bash
set -euo pipefail

OUTDIR="webm"
mkdir -p "$OUTDIR"

for f in $(ls *.mp4 | sort); do
    out="$OUTDIR/${f%.mp4}.webm"
    echo "Converting: $f -> $out"
    ffmpeg -i "$f" \
        -c:v libvpx-vp9 \
        -crf 33 -b:v 0 \
        -c:a libopus -b:a 128k \
        -row-mt 1 \
        "$out"
    echo "Done: $out"
done

echo "All files converted. Output in: $OUTDIR/"
