#!/usr/bin/env bash
# Converts JPG/JPEG/PNG files to WebP using cwebp (install: sudo apt install webp).
# Usage: ./convert_to_webp.sh [quality] [input_dir] [output_dir]
#   quality    : 1-100, default 85 (sweet spot for size vs visual quality)
#   input_dir  : directory with source images, default current dir
#   output_dir : where to put .webp files, default <input_dir>/webp

set -euo pipefail

if ! command -v cwebp &>/dev/null; then
    echo "cwebp not found. Install it with: sudo apt install webp"
    exit 1
fi

QUALITY="${1:-85}"
INPUT_DIR="${2:-.}"
OUTPUT_DIR="${3:-$INPUT_DIR/webp}"

mkdir -p "$OUTPUT_DIR"

shopt -s nullglob
files=("$INPUT_DIR"/*.jpg "$INPUT_DIR"/*.jpeg "$INPUT_DIR"/*.JPG "$INPUT_DIR"/*.JPEG "$INPUT_DIR"/*.png "$INPUT_DIR"/*.PNG)

if [[ ${#files[@]} -eq 0 ]]; then
    echo "No JPG/PNG files found in $INPUT_DIR"
    exit 1
fi

echo "Converting ${#files[@]} image(s) → WebP (quality=$QUALITY)"
echo "Output dir: $OUTPUT_DIR"
echo "---"

total_src=0
total_dst=0

for src in "${files[@]}"; do
    base=$(basename "$src")
    name="${base%.*}"
    dst="$OUTPUT_DIR/${name}.webp"

    cwebp -q "$QUALITY" -m 6 -mt -quiet "$src" -o "$dst"

    src_size=$(stat -c%s "$src")
    dst_size=$(stat -c%s "$dst")
    pct=$(awk "BEGIN { printf \"%.0f\", (1 - $dst_size/$src_size) * 100 }")
    total_src=$((total_src + src_size))
    total_dst=$((total_dst + dst_size))

    printf "  %-35s  %6s KB → %6s KB  (-%s%%)\n" \
        "$base" \
        "$((src_size / 1024))" \
        "$((dst_size / 1024))" \
        "$pct"
done

echo "---"
total_pct=$(awk "BEGIN { printf \"%.0f\", (1 - $total_dst/$total_src) * 100 }")
printf "Total: %d KB → %d KB  (-%d%% overall)\n" \
    "$((total_src / 1024))" "$((total_dst / 1024))" "$total_pct"
