#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
build_dir=$(realpath -m -- "${1:-$repo_dir/build-linux}")
linuxdeploy=$(realpath -- "${LINUXDEPLOY:?Set LINUXDEPLOY to the verified linuxdeploy AppImage}")
app_dir="$build_dir/AppDir"
build_id=$(git -C "$repo_dir" rev-parse --short=12 HEAD)
architecture=$(uname -m)

test -x "$app_dir/usr/bin/SpaceCadetPinball"
install -m 755 "$repo_dir/Platform/Linux/AppRun" "$app_dir/AppRun"
install -Dm 644 "$repo_dir/LICENSE" "$app_dir/usr/share/doc/SpaceCadetPinball/LICENSE"
install -m 644 "$repo_dir/Platform/Linux/README.md" "$app_dir/usr/share/doc/SpaceCadetPinball/README.md"

# Supply instruments for SDL_mixer's FluidSynth MIDI backend on systems without
# a system SoundFont. Keep the original license alongside the bundled file.
install -Dm 644 /usr/share/sounds/sf2/TimGM6mb.sf2 "$app_dir/usr/share/sounds/sf2/TimGM6mb.sf2"
install -Dm 644 /usr/share/doc/timgm6mb-soundfont/copyright "$app_dir/usr/share/doc/timgm6mb-soundfont/copyright"

mkdir -p "$build_dir/dist"
export ARCH="$architecture"
export APPIMAGE_EXTRACT_AND_RUN=1
export LDAI_OUTPUT="$build_dir/dist/SpaceCadetPinball-linux-$architecture-$build_id.AppImage"
export LINUXDEPLOY_OUTPUT_VERSION="$build_id"
"$linuxdeploy" --appdir "$app_dir" \
    --desktop-file "$repo_dir/Platform/Linux/SpaceCadetPinball.desktop" \
    --icon-file "$app_dir/usr/share/icons/hicolor/128x128/apps/SpaceCadetPinball.png" \
    --custom-apprun "$repo_dir/Platform/Linux/AppRun" \
    --output appimage

cd "$build_dir/dist"
sha256sum ./*.tar.gz ./*.AppImage > SHA256SUMS
printf 'AppImage: %s\n' "$LDAI_OUTPUT"
