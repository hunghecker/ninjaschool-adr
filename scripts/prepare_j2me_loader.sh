#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <j2me-loader-dir> <game.jar>" >&2
  exit 2
fi

JL_DIR="$(cd "$1" && pwd)"
GAME_JAR="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"

[ -f "$JL_DIR/app/build.gradle" ] || { echo "Not a J2ME-Loader checkout: $JL_DIR" >&2; exit 3; }
[ -f "$GAME_JAR" ] || { echo "Game JAR not found: $GAME_JAR" >&2; exit 4; }

mkdir -p "$JL_DIR/app/libs"
cp "$GAME_JAR" "$JL_DIR/app/libs/ninja-school.jar"

mkdir -p "$JL_DIR/app/src/midlet/resources/MIDLET-META-INF"
unzip -p "$GAME_JAR" META-INF/MANIFEST.MF > \
  "$JL_DIR/app/src/midlet/resources/MIDLET-META-INF/MANIFEST.MF"

# Remove the sample MIDlet source. The actual MIDlet classes come from game.jar.
rm -rf "$JL_DIR/app/src/midlet/java/com/example/porting" || true

python3 - "$JL_DIR/app/build.gradle" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')
needle = "dependencies {\n"
line = "    midletImplementation files('libs/ninja-school.jar')\n"
if line not in s:
    if needle not in s:
        raise SystemExit('dependencies block not found in app/build.gradle')
    s = s.replace(needle, needle + line, 1)
p.write_text(s, encoding='utf-8')
PY

# The main J2ME Loader manifest already requests INTERNET and Bluetooth-related
# permissions. We deliberately do not add direct RFCOMM code: this game patch uses
# TCP for LAN/Bluetooth PAN.

echo "Prepared J2ME Loader MIDlet flavor for: $(grep -a '^MIDlet-Name:' "$JL_DIR/app/src/midlet/resources/MIDLET-META-INF/MANIFEST.MF" | head -1)"
