#!/usr/bin/env bash
set -euo pipefail

executable=$(realpath -- "${1:?Pass the executable or extracted AppRun path}")
test_dir=$(mktemp -d)
trap 'rm -rf -- "$test_dir"' EXIT
mkdir -p "$test_dir/data" "$test_dir/config"

# No proprietary game data is needed: reach SDL, the software renderer, ImGui
# and data discovery, then require the expected missing-data error and exit 1.
set +e
(
    cd "$test_dir"
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy \
        XDG_DATA_HOME="$test_dir/data" XDG_CONFIG_HOME="$test_dir/config" \
        timeout 20s "$executable" -sw -noaudio
) >"$test_dir/startup.log" 2>&1
status=$?
set -e
cat "$test_dir/startup.log"
test "$status" -eq 1
grep -Fq 'Using SDL renderer: software' "$test_dir/startup.log"
grep -Fq 'BL error: Could not load game data' "$test_dir/startup.log"
printf 'Startup smoke test passed: %s\n' "$executable"
