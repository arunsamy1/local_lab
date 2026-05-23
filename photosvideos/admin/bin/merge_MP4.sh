#!/usr/bin/env bash
set -euo pipefail

OUTPUT="merged.mp4"
LIST="filelist.txt"

# Build the list file in sorted order
> "$LIST"
for f in $(ls *.mp4 | sort); do
    [[ "$f" == "$OUTPUT" ]] && continue
    echo "file '$f'" >> "$LIST"
done

echo "Merging the following files:"
cat "$LIST"

ffmpeg -f concat -safe 0 -i "$LIST" -c copy "$OUTPUT"

rm "$LIST"
echo "Done: $OUTPUT"
