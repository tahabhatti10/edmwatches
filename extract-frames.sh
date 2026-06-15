#!/usr/bin/env bash
# extract-frames.sh
# Run this after placing hero.mp4 in the project root.
# Requires ffmpeg to be installed.

set -e

VIDEO="hero.mp4"
OUT_DIR="public/frames"

if [ ! -f "$VIDEO" ]; then
  echo "❌  hero.mp4 not found in project root."
  echo "    Download it from Higgsfield and place it here first."
  exit 1
fi

echo "📹  Probing video..."
ffprobe -v quiet -print_format json -show_streams "$VIDEO" | \
  python3 -c "
import json, sys
data = json.load(sys.stdin)
for s in data['streams']:
  if s.get('codec_type') == 'video':
    print(f'  Duration : {s.get(\"duration\", \"N/A\")}s')
    print(f'  Frame rate: {s.get(\"avg_frame_rate\", \"N/A\")}')
    print(f'  Resolution: {s[\"width\"]}x{s[\"height\"]}')
"

mkdir -p "$OUT_DIR"

echo "🖼️  Extracting frames at 24 fps, 1920px wide..."
ffmpeg -i "$VIDEO" \
  -vf "fps=24,scale=1920:-1" \
  -q:v 3 \
  "${OUT_DIR}/frame_%04d.jpg"

FRAME_COUNT=$(ls "${OUT_DIR}"/frame_*.jpg 2>/dev/null | wc -l | tr -d ' ')
echo "✅  Extracted ${FRAME_COUNT} frames → ${OUT_DIR}/"
echo ""
echo "⚡  Now update ScrollHero.tsx:"
echo "    const FRAME_COUNT = ${FRAME_COUNT}"
echo ""
echo "    Then run:  npm run dev"
