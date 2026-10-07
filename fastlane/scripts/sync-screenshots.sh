#!/usr/bin/env bash
# Copy exported marketing screenshots into fastlane/deliver layout (en-US).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SRC="$ROOT/marketing/app-store-screenshots/exported-store-screenshots"
DEST="$ROOT/fastlane/screenshots/en-US"
IMESSAGE_DEST="$ROOT/fastlane/screenshots/iMessage/en-US"

mkdir -p "$DEST" "$IMESSAGE_DEST"

# Archive old raw simulator dumps if present
if ls "$DEST"/*Simulator* 1>/dev/null 2>&1; then
  mkdir -p "$DEST/_archive_old"
  mv "$DEST"/*Simulator* "$DEST/_archive_old/" 2>/dev/null || true
fi

resize_to() {
  local src="$1" dest="$2" height="$3" width="$4"
  sips -z "$height" "$width" "$src" --out "$dest" >/dev/null
}

HERO="$SRC/01-hero-sunrise-1320x2868.png"
NEXT="$SRC/02-next-up-sunrise-1320x2868.png"
TWILIGHT="$SRC/03-twilight-sunrise-1320x2868.png"
LOCATIONS="$SRC/04-locations-sunrise-1320x2868.png"
WEATHER="$SRC/05-weather-sunrise-1320x2868.png"
CREATIVE="$SRC/06-universal-creative-sunrise-5244x2950.png"

for f in "$HERO" "$NEXT" "$TWILIGHT" "$LOCATIONS" "$WEATHER"; do
  if [[ ! -f "$f" ]]; then
    echo "Missing export: $f" >&2
    echo "Run: cd marketing/app-store-screenshots && npm run generate:screenshots" >&2
    exit 1
  fi
done

# iPhone 6.9" (1320x2868)
cp "$HERO"      "$DEST/iPhone 6.9\" Display-01.png"
cp "$NEXT"      "$DEST/iPhone 6.9\" Display-02.png"
cp "$TWILIGHT"  "$DEST/iPhone 6.9\" Display-03.png"
cp "$LOCATIONS" "$DEST/iPhone 6.9\" Display-04.png"
cp "$WEATHER"   "$DEST/iPhone 6.9\" Display-05.png"

# iPad Pro 12.9" (3rd gen) — filename must include ipadPro129
resize_to "$HERO"      "$DEST/iPad Pro (12.9-inch) (3rd generation) ipadPro129-01.png" 2732 2048
resize_to "$NEXT"      "$DEST/iPad Pro (12.9-inch) (3rd generation) ipadPro129-02.png" 2732 2048
resize_to "$TWILIGHT"  "$DEST/iPad Pro (12.9-inch) (3rd generation) ipadPro129-03.png" 2732 2048
resize_to "$LOCATIONS" "$DEST/iPad Pro (12.9-inch) (3rd generation) ipadPro129-04.png" 2732 2048
resize_to "$WEATHER"   "$DEST/iPad Pro (12.9-inch) (3rd generation) ipadPro129-05.png" 2732 2048

# iMessage
resize_to "$HERO" "$IMESSAGE_DEST/iPhone XS Max (iMessage)-01.png" 2778 1284
resize_to "$HERO" "$IMESSAGE_DEST/iPad Pro (12.9-inch) (3rd generation) ipadPro129 (iMessage)-01.png" 2732 2048

# Keep promotional creative outside screenshots/ — deliver rejects non-locale dirs there.
if [[ -f "$CREATIVE" ]]; then
  mkdir -p "$ROOT/fastlane/promotional"
  cp "$CREATIVE" "$ROOT/fastlane/promotional/universal-creative-5244x2950.png"
  echo "Promotional creative: fastlane/promotional/universal-creative-5244x2950.png"
fi

# Remove stale promotional dir if present (breaks deliver language validation).
rm -rf "$ROOT/fastlane/screenshots/promotional"

echo "Synced iPhone, iPad, and iMessage screenshots to fastlane/screenshots/"
