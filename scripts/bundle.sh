#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

APP="DynamicIsland.app"
BUILD=".build/release"

swift build -c release

rm -rf "$BUILD/$APP"
mkdir -p "$BUILD/$APP/Contents/MacOS" "$BUILD/$APP/Contents/Resources"
cp "$BUILD/DynamicIsland" "$BUILD/$APP/Contents/MacOS/"
cp App/Info.plist "$BUILD/$APP/Contents/"
cp App/AppIcon.icns "$BUILD/$APP/Contents/Resources/"
codesign --force --sign - "$BUILD/$APP"

if [ -w /Applications ]; then DEST=/Applications; else DEST="$HOME/Applications"; mkdir -p "$DEST"; fi

pkill -x DynamicIsland 2>/dev/null || true
rm -rf "$DEST/$APP"
cp -R "$BUILD/$APP" "$DEST/"

echo "Installed to $DEST/$APP"

if [ "${1:-}" = "--open" ]; then open "$DEST/$APP"; fi
